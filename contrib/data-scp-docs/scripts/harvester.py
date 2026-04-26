#!/usr/bin/env python3
"""
JP 支部向けハイブリッド索引: シリーズ一覧（基礎層）＋ page-tags（属性層）＋
foundation-tales-jp（著者層）を統合し list/jp/*.json を生成する。

マニフェスト（schemaVersion 2）: `manifest_scp-*.json` / `manifest_tales.json` /
`manifest_gois.json` / `manifest_canons.json` / `manifest_jokes.json` に entries（u,i,t）と
スパース metadata（主キー i）を出力する。listVersion は前回出力と差分が無い場合は据え置き。
GoI（`manifest_gois.json`）のみ schemaVersion 3: `goi-formats-jp` の h1/h2 構造に基づき `en` / `jp` / `other` の団体ツリー + 子記事を格納（`goiRegions`）。詳細は同梱 `docs/GOI_MANIFEST_V3_ja.md`。

Canon（`manifest_canons.json`）: `canon-hub-jp` / `canon-hub` の `#page-content div.canon-title` 内リンクのみをカノンハブとして収集し、
`canonRegions.jp` / `canonRegions.en` に分離。フラット `entries` + `metadata[].r`（`jp` / `en`）も併記。

収集は Wikidot のみ（scp_list.json には依存しない）。
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
import time
from dataclasses import dataclass, field
from datetime import datetime, timezone
from typing import Any
from urllib.parse import urljoin, urlparse

import requests
from bs4 import BeautifulSoup

REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))

MANIFEST_SCHEMA_VERSION = 2
GOI_MANIFEST_SCHEMA_VERSION = 3

HTTP_HEADERS = {
    "User-Agent": "ScpDocsHarvester/1.0 (+https://github.com/Kzky-Works/data-scp-docs)",
    "Accept-Language": "ja,en;q=0.8",
}

REQUEST_DELAY_SEC = 0.45

SERIES_JP: list[tuple[int, str]] = [
    (0, "/scp-series-jp"),
    (1, "/scp-series-jp-2"),
    (2, "/scp-series-jp-3"),
    (3, "/scp-series-jp-4"),
    (4, "/scp-series-jp-5"),
]
SERIES_MAIN: list[tuple[int, str]] = [
    (0, "/scp-series"),
    (1, "/scp-series-2"),
    (2, "/scp-series-3"),
    (3, "/scp-series-4"),
    (4, "/scp-series-5"),
]

SCP_JP_HREF = re.compile(r"^/scp-(\d+)-jp$")
SCP_MAIN_HREF = re.compile(r"^/scp-(\d+)$")

# 属性層: オブジェクトクラス語（page-tags タグ名 = URL 末尾）
OBJECT_CLASS_TAGS = (
    "safe",
    "euclid",
    "keter",
    "thaumiel",
    "neutralized",
    "explained",
    "apollyon",
    "esoteric-class",
)

INTERNATIONAL_HUB = "/scp-international"
INTL_LIST_HINTS = (
    "liste-fr",
    "lista-pl",
    "scp-list-ru",
    "scp-serie-de",
    "series-1-pt",
    "scp-it-serie",
    "scp-it-e-",
    "serie-scp-es",
    "scp-series-ua",
    "scp-series-vn",
    "scp-series-ko",
    "scp-series-cn",
    "scp-series-th",
    "scp-series-cs",
    "scp-series-zh",
    "scp-series-sk",
    "series-archive",
    "scp-series-unofficial",
    "joke-scp-series-unofficial",
)
INTL_PATH_RE = re.compile(r"^/scp-\d+-[a-z]{2}$")
MAX_INTL_LIST_PAGES = 80

# カノンハブ索引（div.canon-title のみ解析。series-hub-jp は対象外）
CANON_HUB_PAGES: tuple[tuple[str, str], ...] = (
    ("/canon-hub-jp", "jp"),
    ("/canon-hub", "en"),
)
JOKE_INDEX_PATHS: tuple[str, ...] = ("/joke-scps", "/joke-scps-jp")
GOI_FORMATS_HUB = "/goi-formats-jp"
FOUNDATION_TALES_EN = "/foundation-tales"

PAGE_LINK_EXCLUDE_PREFIXES: tuple[str, ...] = (
    "/system:",
    "/nav:",
    "/search:",
    "/admin:",
    "/login",
    "/register",
    "/_:",
    "/local--",
    "/forum",
    "/blog:",
    "/activity",
)

JOKE_HUB_PATHS_LOWER = frozenset({"/joke-scps", "/joke-scps-jp"})


@dataclass
class BranchConfig:
    """支部（言語）単位の設定。他支部は別インスタンスを組み立てる。"""

    code: str = "jp"
    site_host: str = "https://scp-jp.wikidot.com"
    output_dir: str = field(default_factory=lambda: os.path.join(REPO_ROOT, "list", "jp"))
    foundation_tales_path: str = "/foundation-tales-jp"
    goi_tag: str = "goi-format"
    goi_tag_max_pages: int = 8

    def abs_url(self, path: str) -> str:
        p = path if path.startswith("/") else "/" + path
        return self.site_host.rstrip("/") + p


@dataclass
class ArticleRow:
    path: str  # /scp-173-jp
    u: str
    i: str
    t: str
    c: str | None = None
    o: str | None = None
    g: list[str] = field(default_factory=list)
    a: str | None = None  # 報告書では通常使わない（互換のためキーは出力時省略）


def sleep_delay() -> None:
    time.sleep(REQUEST_DELAY_SEC)


def fetch_html(session: requests.Session, url: str, *, retries: int = 6) -> str:
    last: Exception | None = None
    for attempt in range(retries):
        sleep_delay()
        try:
            r = session.get(url, headers=HTTP_HEADERS, timeout=(15, 75))
            if r.status_code in (429, 502, 503) and attempt < retries - 1:
                time.sleep(min(90, 6 * (2**attempt)))
                continue
            r.raise_for_status()
            r.encoding = r.encoding or "utf-8"
            return r.text
        except Exception as e:
            last = e
            if attempt < retries - 1:
                time.sleep(min(60, 5 * (attempt + 1)))
    assert last is not None
    raise last


def extract_title_from_li(li) -> str | None:
    full = li.get_text(separator="", strip=False).strip()
    if " - " not in full:
        return None
    _, title = full.split(" - ", 1)
    t = title.strip()
    return t if t else None


@dataclass(frozen=True)
class SeriesRange:
    lo: int
    hi: int


def range_for_series(series: int) -> SeriesRange:
    m = {
        0: SeriesRange(1, 999),
        1: SeriesRange(1000, 1999),
        2: SeriesRange(2000, 2999),
        3: SeriesRange(3000, 3999),
        4: SeriesRange(4000, 4999),
    }
    return m[series]


def scrape_series_jp(session: requests.Session, cfg: BranchConfig) -> dict[str, ArticleRow]:
    base = cfg.site_host.rstrip("/")
    out: dict[str, ArticleRow] = {}
    for series, path in SERIES_JP:
        url = base + path
        html = fetch_html(session, url)
        soup = BeautifulSoup(html, "html.parser")
        rng = range_for_series(series)
        for li in soup.find_all("li"):
            a = li.find("a", href=True)
            if not a:
                continue
            href = (a.get("href") or "").strip()
            pu = urlparse(urljoin(base + "/", href))
            m = SCP_JP_HREF.match(pu.path)
            if not m:
                continue
            n = int(m.group(1), 10)
            if not (rng.lo <= n <= rng.hi):
                continue
            title = extract_title_from_li(li)
            if not title:
                continue
            path_norm = pu.path
            i = path_norm.lstrip("/").lower()
            u = base + path_norm
            out[path_norm] = ArticleRow(path=path_norm, u=u, i=i, t=title)
    return out


def scrape_series_main(session: requests.Session, cfg: BranchConfig) -> dict[str, ArticleRow]:
    base = cfg.site_host.rstrip("/")
    out: dict[str, ArticleRow] = {}
    for series, path in SERIES_MAIN:
        url = base + path
        html = fetch_html(session, url)
        soup = BeautifulSoup(html, "html.parser")
        rng = range_for_series(series)
        for li in soup.find_all("li"):
            a = li.find("a", href=True)
            if not a:
                continue
            href = (a.get("href") or "").strip()
            pu = urlparse(urljoin(base + "/", href))
            m = SCP_MAIN_HREF.match(pu.path)
            if not m:
                continue
            n = int(m.group(1), 10)
            if not (rng.lo <= n <= rng.hi):
                continue
            title = extract_title_from_li(li)
            if not title:
                continue
            path_norm = pu.path
            i = path_norm.lstrip("/").lower()
            u = base + path_norm
            out[path_norm] = ArticleRow(path=path_norm, u=u, i=i, t=title)
    return out


def validate_manifest_entries_metadata(
    entries: list[dict[str, Any]], metadata: dict[str, Any], label: str
) -> None:
    """metadata のキーは必ず entries[].i に存在する（孤児禁止）。"""
    ids: set[str] = set()
    for e in entries:
        if not isinstance(e, dict):
            continue
        i = e.get("i")
        if isinstance(i, str) and i.strip():
            ids.add(i.strip())
    for k in metadata:
        if k not in ids:
            raise ValueError(f"manifest {label}: metadata key {k!r} has no matching entry.i")


def light_article_row_dict(row: ArticleRow) -> dict[str, Any]:
    return {"u": row.u, "i": row.i, "t": row.t}


def sparse_trifold_metadata_chunk(row: ArticleRow) -> dict[str, Any] | None:
    """entries 以外に載せる c / o / g のみ（空なら None）。o は t と異なる場合だけ。"""
    chunk: dict[str, Any] = {}
    if row.c and str(row.c).strip():
        chunk["c"] = str(row.c).strip()
    if row.o and str(row.o).strip():
        ost = str(row.o).strip()
        if ost != (row.t or "").strip():
            chunk["o"] = ost
    if row.g:
        chunk["g"] = [str(x).strip() for x in row.g if isinstance(x, str) and str(x).strip()]
    return chunk if chunk else None


def attach_jp_mainlist_title_from_main_series(
    jp_rows: dict[str, ArticleRow], main_rows: dict[str, ArticleRow]
) -> None:
    """支部行の o に本家 /scp-n 一覧タイトルを載せる（一覧 t と異なるときのみ）。"""
    for path, row in jp_rows.items():
        m = SCP_JP_HREF.match(path)
        if not m:
            continue
        n = int(m.group(1), 10)
        main_row = main_rows.get(f"/scp-{n}")
        if main_row is None:
            continue
        mt = (main_row.t or "").strip()
        jt = (row.t or "").strip()
        if mt and mt != jt:
            row.o = mt


def trifold_rows_to_manifest_parts(
    rows: dict[str, ArticleRow],
) -> tuple[list[dict[str, Any]], dict[str, Any]]:
    entries_out: list[dict[str, Any]] = []
    metadata: dict[str, Any] = {}
    for _, row in sorted(rows.items()):
        entries_out.append(light_article_row_dict(row))
        chunk = sparse_trifold_metadata_chunk(row)
        if chunk:
            metadata[row.i] = chunk
    return entries_out, metadata


OC_TAG_TO_DISPLAY = {
    "safe": "Safe",
    "euclid": "Euclid",
    "keter": "Keter",
    "thaumiel": "Thaumiel",
    "neutralized": "Neutralized",
    "explained": "Explained",
    "apollyon": "Apollyon",
    "esoteric-class": "Esoteric",
}


def map_object_class_from_tag_pages(session: requests.Session, cfg: BranchConfig, paths: set[str]) -> dict[str, str]:
    """属性層: system:page-tags/tag/<class> に掲載された記事パス → OC（先に列挙したタグを優先）。"""
    base = cfg.site_host.rstrip("/")
    path_to_class: dict[str, str] = {}
    for tag in OBJECT_CLASS_TAGS:
        url = f"{base}/system:page-tags/tag/{tag}"
        try:
            html = fetch_html(session, url, retries=4)
        except Exception as ex:
            print(f"WARN: OC tag page {tag}: {ex}", file=sys.stderr)
            continue
        soup = BeautifulSoup(html, "html.parser")
        oc_display = OC_TAG_TO_DISPLAY.get(tag, tag.replace("-", " ").title())
        for a in soup.find_all("a", href=True):
            raw = (a.get("href") or "").strip()
            pu = urlparse(urljoin(base + "/", raw))
            if pu.netloc and pu.netloc != urlparse(base).netloc:
                continue
            pth = pu.path or ""
            if pth not in paths:
                continue
            if pth not in path_to_class:
                path_to_class[pth] = oc_display
    return path_to_class


def is_english_main_series_list(path: str) -> bool:
    pl = path.lower()
    if pl == "/scp-series":
        return True
    return bool(re.match(r"^/scp-series-\d+$", pl))


def looks_intl_list(path: str) -> bool:
    pl = path.lower()
    if pl in {"/", "/scp-international"}:
        return False
    if "scp-series-jp" in pl:
        return False
    if is_english_main_series_list(path):
        return False
    return any(s in pl for s in INTL_LIST_HINTS)


def discover_intl_list_urls(session: requests.Session, cfg: BranchConfig) -> list[str]:
    base = cfg.site_host.rstrip("/")
    hub = base + INTERNATIONAL_HUB
    html = fetch_html(session, hub)
    soup = BeautifulSoup(html, "html.parser")
    out: list[str] = []
    seen: set[str] = set()
    for a in soup.find_all("a", href=True):
        raw = (a.get("href") or "").strip()
        absu = urljoin(hub, raw)
        pu = urlparse(absu)
        if pu.netloc != urlparse(base).netloc:
            continue
        path = pu.path or "/"
        if not looks_intl_list(path):
            continue
        u = f"{urlparse(base).scheme}://{pu.netloc}{path}"
        if u not in seen:
            seen.add(u)
            out.append(u)
    out.sort()
    return out


def extract_intl_titles(html: str, base_host: str) -> dict[str, str]:
    soup = BeautifulSoup(html, "html.parser")
    titles: dict[str, str] = {}
    base = base_host.rstrip("/")
    for li in soup.find_all("li"):
        a = li.find("a", href=True)
        if not a:
            continue
        raw = (a.get("href") or "").strip()
        pu = urlparse(urljoin(base + "/", raw))
        pth = pu.path
        if not INTL_PATH_RE.match(pth) or pth.endswith("-jp"):
            continue
        t = extract_title_from_li(li) or a.get_text(separator=" ", strip=True)
        if not t:
            continue
        prev = titles.get(pth)
        if prev is None or len(t) > len(prev):
            titles[pth] = t
    return titles


def crawl_intl_titles(session: requests.Session, cfg: BranchConfig) -> dict[str, str]:
    urls = discover_intl_list_urls(session, cfg)[:MAX_INTL_LIST_PAGES]
    merged: dict[str, str] = {}
    for u in urls:
        try:
            html = fetch_html(session, u, retries=4)
        except Exception as ex:
            print(f"WARN: intl list {u}: {ex}", file=sys.stderr)
            continue
        part = extract_intl_titles(html, cfg.site_host)
        for p, t in part.items():
            prev = merged.get(p)
            if prev is None or len(t) > len(prev):
                merged[p] = t
    return merged


def build_int_rows_from_wikidot(session: requests.Session, cfg: BranchConfig) -> list[dict[str, Any]]:
    """国際支部リンクは /scp-international から辿った各一覧ページのスクレイプ結果のみ（scp_list 不要）。"""
    titles = crawl_intl_titles(session, cfg)
    base = cfg.site_host.rstrip("/")
    rows: list[dict[str, Any]] = []
    if not titles:
        print("WARN: no intl paths discovered; scp-int manifest may be empty", file=sys.stderr)
    for p in sorted(titles.keys()):
        i = p.lstrip("/").lower()
        u = base + p
        raw_t = titles.get(p, "")
        t = raw_t.strip() if isinstance(raw_t, str) and raw_t.strip() else _fallback_int_title(p)
        rows.append({"u": u, "i": i, "t": t})
    return rows


def _fallback_int_title(path: str) -> str:
    m = re.match(r"^/scp-(\d+)-([a-z]{2})$", path)
    if not m:
        return path.lstrip("/").upper()
    return f"SCP-{m.group(1)}-{m.group(2).upper()}"


def next_list_version_and_generated_at(
    path: str, entries: list[dict[str, Any]], metadata: dict[str, Any]
) -> tuple[int, str]:
    """entries + metadata（正規化後）が前回と同一なら listVersion を据え置き、変化時のみ +1。"""
    dt = datetime.now(timezone.utc)
    gen = dt.strftime("%Y-%m-%dT%H:%M:%SZ")
    md_norm = {k: v for k, v in metadata.items() if isinstance(v, dict) and v}
    if os.path.isfile(path):
        try:
            with open(path, encoding="utf-8") as f:
                old = json.load(f)
        except Exception:
            old = {}
        old_lv = int(old.get("listVersion") or 0)
        if old.get("entries") == entries and (old.get("metadata") or {}) == md_norm:
            return old_lv, gen
        return old_lv + 1, gen
    return int(dt.timestamp()), gen


def next_canon_list_version_and_generated_at(
    path: str,
    entries: list[dict[str, Any]],
    metadata: dict[str, Any],
    canon_regions: dict[str, list[dict[str, Any]]],
) -> tuple[int, str]:
    """entries + metadata + canonRegions が前回と同一なら listVersion 据え置き。"""
    dt = datetime.now(timezone.utc)
    gen = dt.strftime("%Y-%m-%dT%H:%M:%SZ")
    md_norm = {k: v for k, v in metadata.items() if isinstance(v, dict) and v}
    cr_norm = {
        "jp": canon_regions.get("jp") or [],
        "en": canon_regions.get("en") or [],
    }
    if os.path.isfile(path):
        try:
            with open(path, encoding="utf-8") as f:
                old = json.load(f)
        except Exception:
            old = {}
        old_lv = int(old.get("listVersion") or 0)
        old_cr = old.get("canonRegions") or {}
        if (
            old.get("entries") == entries
            and (old.get("metadata") or {}) == md_norm
            and (old_cr.get("jp") or []) == cr_norm["jp"]
            and (old_cr.get("en") or []) == cr_norm["en"]
        ):
            return old_lv, gen
        return old_lv + 1, gen
    return int(dt.timestamp()), gen


def write_manifest(path: str, entries: list[dict[str, Any]], metadata: dict[str, Any]) -> None:
    """schemaVersion 2: entries（軽）+ metadata（スパース、キーは i）。"""
    md = {k: v for k, v in metadata.items() if isinstance(v, dict) and v}
    validate_manifest_entries_metadata(entries, md, os.path.basename(path))
    lv, gen = next_list_version_and_generated_at(path, entries, metadata)
    payload: dict[str, Any] = {
        "listVersion": lv,
        "schemaVersion": MANIFEST_SCHEMA_VERSION,
        "generatedAt": gen,
        "entries": entries,
        "metadata": md,
    }
    os.makedirs(os.path.dirname(path), exist_ok=True)
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)
        f.write("\n")
    os.replace(tmp, path)


def write_canon_manifest(
    path: str,
    entries: list[dict[str, Any]],
    metadata: dict[str, Any],
    canon_regions: dict[str, list[dict[str, Any]]],
) -> None:
    """manifest_canons.json: entries + metadata（r=jp|en）+ canonRegions。"""
    md = {k: v for k, v in metadata.items() if isinstance(v, dict) and v}
    validate_manifest_entries_metadata(entries, md, os.path.basename(path))
    cr_norm: dict[str, list[dict[str, Any]]] = {
        "jp": canon_regions.get("jp") or [],
        "en": canon_regions.get("en") or [],
    }
    lv, gen = next_canon_list_version_and_generated_at(path, entries, metadata, cr_norm)
    payload: dict[str, Any] = {
        "listVersion": lv,
        "schemaVersion": MANIFEST_SCHEMA_VERSION,
        "generatedAt": gen,
        "entries": entries,
        "metadata": md,
        "canonRegions": cr_norm,
    }
    os.makedirs(os.path.dirname(path), exist_ok=True)
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)
        f.write("\n")
    os.replace(tmp, path)


def _page_link_excluded(path: str) -> bool:
    pl = path.lower()
    if not pl.startswith("/"):
        return True
    for pfx in PAGE_LINK_EXCLUDE_PREFIXES:
        if pl.startswith(pfx):
            return True
    return False


def extract_page_content_link_map(
    session: requests.Session, cfg: BranchConfig, page_path: str
) -> dict[str, str]:
    """#page-content 内の同一サイト単一スラッグへのリンク → {正規パス: 表示テキスト}。"""
    base = cfg.site_host.rstrip("/")
    url = cfg.abs_url(page_path)
    html = fetch_html(session, url)
    soup = BeautifulSoup(html, "html.parser")
    root = soup.select_one("#page-content") or soup.body
    out: dict[str, str] = {}
    if root is None:
        return out
    for a in root.find_all("a", href=True):
        raw = (a.get("href") or "").strip().split("#")[0]
        if not raw or raw.startswith("javascript:"):
            continue
        absu = urljoin(url, raw)
        pu = urlparse(absu)
        if pu.netloc and pu.netloc != urlparse(base).netloc:
            continue
        p = pu.path or "/"
        if p == "/" or _page_link_excluded(p):
            continue
        segs = [x for x in p.strip("/").split("/") if x]
        if len(segs) != 1:
            continue
        slug = segs[0]
        if ":" in slug:
            continue
        title = a.get_text(" ", strip=True) or slug
        prev = out.get(p)
        if prev is None or len(title) > len(prev):
            out[p] = title
    return out


def is_joke_article_path(path: str) -> bool:
    pl = path.lower()
    if pl in JOKE_HUB_PATHS_LOWER:
        return False
    # 日本支部オリジナル（-jp-j）を本家系（-j）より先に判定
    if re.match(r"^/scp-.+-jp-j$", pl):
        return True
    if re.match(r"^/scp-.+-j$", pl):
        return True
    if pl.startswith("/joke-scp"):
        if re.match(r"^/joke-scp[\w-]*$", pl) and pl not in JOKE_HUB_PATHS_LOWER:
            return True
    return False


def scrape_joke_index_entries(session: requests.Session, cfg: BranchConfig) -> list[dict[str, Any]]:
    merged: dict[str, str] = {}
    for hub in JOKE_INDEX_PATHS:
        part = extract_page_content_link_map(session, cfg, hub)
        for p, t in part.items():
            if not is_joke_article_path(p):
                continue
            prev = merged.get(p)
            if prev is None or len(t) > len(prev):
                merged[p] = t
    base = cfg.site_host.rstrip("/")
    out: list[dict[str, Any]] = []
    for path, title in sorted(merged.items(), key=lambda x: x[0]):
        i = path.lstrip("/").lower()
        u = base + path
        out.append({"u": u, "i": i, "t": title})
    return out


def extract_canon_title_hubs(
    session: requests.Session, cfg: BranchConfig, page_path: str
) -> list[tuple[str, str]]:
    """#page-content 内の div.canon-title に限り、カノンハブへの単一スラッグリンクを文書順で列挙。"""
    base = cfg.site_host.rstrip("/")
    page_url = cfg.abs_url(page_path)
    html = fetch_html(session, page_url)
    soup = BeautifulSoup(html, "html.parser")
    root = soup.select_one("#page-content") or soup.body
    if root is None:
        return []
    site_netloc = urlparse(base).netloc.lower()
    seen_order: list[str] = []
    best_title: dict[str, str] = {}
    for block in root.select("div.canon-title"):
        for a in block.find_all("a", href=True):
            raw = (a.get("href") or "").strip().split("#")[0]
            if not raw or raw.startswith("javascript:"):
                continue
            absu = urljoin(page_url, raw)
            pu = urlparse(absu)
            if pu.netloc and pu.netloc.lower() != site_netloc:
                continue
            p = pu.path or "/"
            if p == "/" or _page_link_excluded(p):
                continue
            segs = [x for x in p.strip("/").split("/") if x]
            if len(segs) != 1:
                continue
            slug = segs[0]
            if ":" in slug:
                continue
            title = a.get_text(" ", strip=True) or slug
            if p not in best_title:
                seen_order.append(p)
                best_title[p] = title
            elif len(title) > len(best_title[p]):
                best_title[p] = title
    return [(p, best_title[p]) for p in seen_order]


def scrape_canon_manifest_payload(
    session: requests.Session, cfg: BranchConfig
) -> tuple[list[dict[str, Any]], dict[str, Any], dict[str, list[dict[str, Any]]]]:
    """canon-hub-jp → jp / canon-hub → en のハブ行とフラット entries + metadata.r。"""
    base = cfg.site_host.rstrip("/")
    region_lines: dict[str, list[dict[str, Any]]] = {"jp": [], "en": []}
    for hub_path, region in CANON_HUB_PAGES:
        hubs = extract_canon_title_hubs(session, cfg, hub_path)
        for path, title in hubs:
            ikey = path.lstrip("/").lower()
            region_lines[region].append(
                {"u": base + path, "i": ikey, "t": title}
            )
    by_i: dict[str, tuple[dict[str, Any], str]] = {}
    for region in ("jp", "en"):
        for line in region_lines[region]:
            ik = line.get("i")
            if not isinstance(ik, str) or not ik.strip():
                continue
            iks = ik.strip()
            if iks not in by_i:
                by_i[iks] = (line, region)
    light: list[dict[str, Any]] = []
    metadata: dict[str, Any] = {}
    for iks in sorted(by_i.keys()):
        line, region = by_i[iks]
        t_raw = line.get("t")
        t_str = (
            t_raw.strip()
            if isinstance(t_raw, str) and t_raw.strip()
            else iks
        )
        light.append({"u": line["u"], "i": iks, "t": t_str})
        metadata[iks] = {"r": region}
    return light, metadata, region_lines


def _goi_h1_region_label(h1_text: str) -> str | None:
    """要注意団体ブロック用 h1 から en / jp / other、該当しなければ None。"""
    t = " ".join(h1_text.split())
    if "要注意団体-JP" in t:
        return "jp"
    if "要注意団体-EN" in t:
        return "en"
    if t.startswith("要注意団体-") and "インフォメーション" not in t:
        return "other"
    return None


def _goi_find_anchor_name_before_h2(h2) -> str | None:
    prev = h2.find_previous_sibling()
    while prev is not None:
        if prev.name == "p":
            an = prev.find("a", attrs={"name": True})
            if an is not None:
                name = (an.get("name") or "").strip()
                if name:
                    return name
        prev = prev.find_previous_sibling()
    return None


def _goi_abs_path_for_href(
    href: str, page_url: str, site_host_base: str
) -> str | None:
    raw = (href or "").strip().split("#")[0]
    if not raw or raw.startswith("javascript:"):
        return None
    absu = urljoin(page_url, raw)
    pu = urlparse(absu)
    site_netloc = urlparse(site_host_base).netloc
    if pu.netloc and pu.netloc.lower() != site_netloc.lower():
        return None
    p = (pu.path or "/").rstrip("/") or "/"
    if p == "/" or _page_link_excluded(p):
        return None
    segs = [x for x in p.strip("/").split("/") if x]
    if len(segs) != 1:
        return None
    if ":" in segs[0]:
        return None
    return p if p.startswith("/") else "/" + p


def _goi_collect_links_after_h2(h2, page_url: str, site_host: str) -> list[dict[str, str]]:
    """h2 直後から次の h1/h2 までの兄弟ノード内の同一サイト article リンク。"""
    base = site_host.rstrip("/")
    seen: set[str] = set()
    out: list[dict[str, str]] = []
    n = h2.next_sibling
    while n is not None:
        if isinstance(n, str):
            n = n.next_sibling
            continue
        if not getattr(n, "name", None):
            n = n.next_sibling
            continue
        if n.name in ("h1", "h2"):
            break
        for a in n.find_all("a", href=True):
            pth = _goi_abs_path_for_href(a.get("href", ""), page_url, base)
            if pth is None or pth in seen:
                continue
            title = a.get_text(" ", strip=True) or pth.lstrip("/")
            seen.add(pth)
            i = pth.lstrip("/").lower()
            u = base + pth
            out.append({"u": u, "i": i, "t": title})
        n = n.next_sibling
    return out


def _goi_parse_h2_group(h2, page_url: str, site_host: str) -> dict[str, Any] | None:
    span = h2.find("span")
    if span is None:
        return None
    a = span.find("a", href=True)
    hub_path: str | None = None
    if a is not None:
        raw_h = (a.get("href") or "").strip()
        hub_path = _goi_abs_path_for_href(raw_h, page_url, site_host.rstrip("/"))
        name = a.get_text(" ", strip=True) or (hub_path or "").lstrip("/")
    else:
        name = span.get_text(" ", strip=True)
        if not name:
            return None
    anchor = _goi_find_anchor_name_before_h2(h2) or (
        re.sub(r"[^0-9a-zA-Z]+", "-", name).strip("-").lower() or "goi-group"
    )
    entries = _goi_collect_links_after_h2(h2, page_url, site_host)
    grp: dict[str, Any] = {
        "i": anchor[:120],
        "t": name,
        "entries": entries,
    }
    if hub_path is not None:
        grp["u"] = site_host.rstrip("/") + hub_path
    return grp


def scrape_goi_formats_hub_structured(
    session: requests.Session, cfg: BranchConfig
) -> tuple[dict[str, list[dict[str, Any]]], list[dict[str, Any]], dict[str, Any]]:
    """goi-formats-jp を DOM 構造で解釈し、en/jp/other の団体ツリーと flat entries + metadata を返す。"""
    base = cfg.site_host.rstrip("/")
    page_url = cfg.abs_url(GOI_FORMATS_HUB)
    html = fetch_html(session, page_url)
    soup = BeautifulSoup(html, "html.parser")
    root = soup.select_one("#page-content .content-panel") or soup.select_one("#page-content")
    regions: dict[str, list[dict[str, Any]]] = {"en": [], "jp": [], "other": []}
    if root is None:
        return regions, [], {}

    current: str | None = None
    for h in root.find_all(["h1", "h2"]):
        if h.name == "h1":
            r = _goi_h1_region_label(h.get_text(" ", strip=True))
            if r is not None:
                current = r
            continue
        if h.name == "h2" and current is not None:
            g = _goi_parse_h2_group(h, page_url, base)
            if g is not None:
                regions[current].append(g)

    flat_by_id: dict[str, dict[str, str]] = {}
    metadata: dict[str, Any] = {}
    region_key: dict[str, str] = {"en": "en", "jp": "jp", "other": "other"}
    for reg, groups in regions.items():
        r_label = region_key[reg]
        for grp in groups:
            gname = (grp.get("t") or "").strip() or str(grp.get("i", ""))
            for e in grp.get("entries") or []:
                if not isinstance(e, dict):
                    continue
                i = e.get("i", "")
                u = e.get("u", "")
                if not isinstance(i, str) or not i.strip() or not isinstance(u, str) or not u.strip():
                    continue
                ii = i.strip()
                t = (e.get("t") or "").strip() or ii
                prev = flat_by_id.get(ii)
                if prev is None or len(t) > len((prev.get("t") or "")):
                    flat_by_id[ii] = {"u": u.strip(), "i": ii, "t": t}
                if ii not in metadata:
                    metadata[ii] = {"g": [gname] if gname else [], "r": r_label}
                else:
                    m = metadata[ii]
                    if not isinstance(m, dict):
                        continue
                    otags = [str(x) for x in (m.get("g") or []) if str(x).strip()]
                    if gname and gname not in otags:
                        otags.append(gname)
                    metadata[ii] = {**m, "g": otags, "r": m.get("r") or r_label}

    flat = sorted(flat_by_id.values(), key=lambda e: e.get("i") or "")
    return regions, flat, metadata


def _next_goi_v3_list_version(
    path: str, new_payload: dict[str, Any]
) -> int:
    """entries + metadata + goiRegions が不変なら listVersion 据え置き。"""
    if not os.path.isfile(path):
        return int(datetime.now(timezone.utc).timestamp())

    try:
        with open(path, encoding="utf-8") as f:
            old = json.load(f)
    except Exception:
        return int(datetime.now(timezone.utc).timestamp())
    if int(old.get("schemaVersion") or 0) < GOI_MANIFEST_SCHEMA_VERSION:
        return int(old.get("listVersion") or 0) + 1

    def norm(p: dict[str, Any]) -> dict[str, Any]:
        return {
            "entries": p.get("entries"),
            "metadata": p.get("metadata") or {},
            "goiRegions": p.get("goiRegions") or {},
        }

    if norm(old) == norm(new_payload):
        return int(old.get("listVersion") or 0)
    return int(old.get("listVersion") or 0) + 1


def write_goi_manifest_v3(path: str, payload: dict[str, Any]) -> None:
    light = payload.get("entries")
    if not isinstance(light, list):
        raise ValueError("goi v3: entries must be a list")
    md = payload.get("metadata") or {}
    if not isinstance(md, dict):
        raise ValueError("goi v3: metadata must be object")
    validate_manifest_entries_metadata(light, md, os.path.basename(path))
    tmp_payload = {**payload}
    tmp_payload["metadata"] = md
    tmp_payload["schemaVersion"] = GOI_MANIFEST_SCHEMA_VERSION
    lv = _next_goi_v3_list_version(path, tmp_payload)
    gen = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    tmp_payload["listVersion"] = lv
    tmp_payload["generatedAt"] = gen
    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
    tpath = path + ".tmp"
    with open(tpath, "w", encoding="utf-8") as f:
        json.dump(tmp_payload, f, ensure_ascii=False, indent=2)
        f.write("\n")
    os.replace(tpath, path)


def tales_raw_to_manifest_parts(raw: list[dict[str, Any]]) -> tuple[list[dict[str, Any]], dict[str, Any]]:
    light: list[dict[str, Any]] = []
    metadata: dict[str, Any] = {}
    for e in raw:
        if not isinstance(e, dict):
            continue
        i = e.get("i")
        if not isinstance(i, str) or not i.strip():
            continue
        u = e.get("u")
        t = e.get("t")
        if not isinstance(u, str) or not u.strip():
            continue
        light.append({"u": u.strip(), "i": i.strip(), "t": (t if isinstance(t, str) and t.strip() else i.strip())})
        a = e.get("a")
        if isinstance(a, str) and a.strip():
            metadata[i.strip()] = {"a": a.strip()}
    return light, metadata


def simple_multiform_raw_to_manifest_parts(
    raw: list[dict[str, Any]],
) -> tuple[list[dict[str, Any]], dict[str, Any]]:
    """Canon / Joke 等: u,i,t のみ（metadata 空）。"""
    light: list[dict[str, Any]] = []
    for e in raw:
        if not isinstance(e, dict):
            continue
        i = e.get("i")
        u = e.get("u")
        if not isinstance(i, str) or not i.strip() or not isinstance(u, str) or not u.strip():
            continue
        t = e.get("t")
        ikey = i.strip()
        light.append(
            {
                "u": u.strip(),
                "i": ikey,
                "t": (t if isinstance(t, str) and t.strip() else ikey),
            }
        )
    return light, {}


# --- 著者層: foundation-tales-jp（Swift パーサと同等の簡易ロジック） ---

AUTHOR_TABLE_OPEN = '<table style="width: 100%;margin-top:1.2em">'
WIKI_TABLE_OPEN = '<table class="wiki-content-table">'


def parse_foundation_tales_jp(html: str, cfg: BranchConfig) -> list[dict[str, Any]]:
    entries: list[dict[str, Any]] = []
    base = cfg.site_host.rstrip("/")
    scan = 0
    while True:
        idx = html.find(AUTHOR_TABLE_OPEN, scan)
        if idx < 0:
            break
        inner_b = idx + len(AUTHOR_TABLE_OPEN)
        end = html.find("</table>", inner_b)
        if end < 0:
            break
        author_inner = html[inner_b:end]
        author_name = _extract_author_name(author_inner)
        after_author = end + len("</table>")
        next_author = html.find(AUTHOR_TABLE_OPEN, after_author)
        tail_end = next_author if next_author >= 0 else len(html)
        tail = html[after_author:tail_end]
        wiki_open = tail.find(WIKI_TABLE_OPEN)
        tales_block = ""
        if wiki_open >= 0:
            wc = wiki_open + len(WIKI_TABLE_OPEN)
            wiki_close = tail.find("</table>", wc)
            if wiki_close >= 0:
                tales_block = tail[wc:wiki_close]
        for m in re.finditer(
            r'<td><a href="([^"]+)">([^<]*)</a></td>',
            tales_block,
            flags=re.IGNORECASE,
        ):
            href = m.group(1).strip()
            title = (
                m.group(2)
                .replace("&amp;", "&")
                .replace("&lt;", "<")
                .replace("&gt;", ">")
                .strip()
            )
            if not href:
                continue
            pu = urlparse(urljoin(base + "/", href))
            if pu.netloc and pu.netloc != urlparse(base).netloc:
                continue
            path = pu.path or "/"
            i = path.lstrip("/").lower()
            u = base + (path if path.startswith("/") else "/" + path)
            t = title if title else i
            ent: dict[str, Any] = {"u": u, "i": i, "t": t}
            if author_name:
                ent["a"] = author_name
            entries.append(ent)
        # 次の著者ブロック先頭へ（同一位置の再検索ループを防ぐ）
        scan = next_author if next_author >= 0 else len(html)
    return entries


def _extract_author_name(fragment: str) -> str | None:
    em = re.search(
        r'<span class="error-inline"[^>]*>.*?<em>([^<]+)</em>',
        fragment,
        flags=re.DOTALL | re.IGNORECASE,
    )
    if em:
        s = em.group(1).strip()
        if s:
            return s
    last: str | None = None
    for m in re.finditer(
        r'<a href="https?://www\.wikidot\.com/user:info/[^"]+"[^>]*>([^<]*)</a>',
        fragment,
        flags=re.IGNORECASE,
    ):
        t = m.group(1).strip()
        if t:
            last = t
    return last


def parse_goi_tag_pages(session: requests.Session, cfg: BranchConfig) -> list[dict[str, Any]]:
    """goi-format タグ一覧からエントリを収集（ページ数上限あり）。"""
    base = cfg.site_host.rstrip("/")
    seen: set[str] = set()
    out: list[dict[str, Any]] = []
    for page in range(1, cfg.goi_tag_max_pages + 1):
        url = f"{base}/system:page-tags/tag/{cfg.goi_tag}"
        if page > 1:
            url += f"/p/{page}"
        try:
            html = fetch_html(session, url, retries=4)
        except Exception as ex:
            print(f"WARN: goi tag page {page}: {ex}", file=sys.stderr)
            break
        soup = BeautifulSoup(html, "html.parser")
        page_had_new = False
        for a in soup.select(".list-pages-box a[href], .pages-list-item a[href], #page-content a[href]"):
            href = (a.get("href") or "").strip()
            if not href.startswith("/"):
                continue
            if "/system:" in href:
                continue
            title = a.get_text(strip=True)
            pu = urlparse(urljoin(base + "/", href))
            if pu.netloc and pu.netloc != urlparse(base).netloc:
                continue
            path = pu.path or "/"
            if not path.startswith("/scp-"):
                continue
            i = path.lstrip("/").lower()
            if i in seen:
                continue
            seen.add(i)
            u = base + path
            ent: dict[str, Any] = {"u": u, "i": i, "t": title or i}
            out.append(ent)
            page_had_new = True
        if not page_had_new and page > 1:
            break
    return out


class JapaneseBranchHarvester:
    """JP 支部の収集 orchestrator。"""

    def __init__(self, cfg: BranchConfig | None = None):
        self.cfg = cfg or BranchConfig()
        self.session = requests.Session()

    def run(self) -> None:
        cfg = self.cfg
        os.makedirs(cfg.output_dir, exist_ok=True)

        print("INFO: base layer — JP series", file=sys.stderr)
        jp_rows = scrape_series_jp(self.session, cfg)

        print("INFO: base layer — mainlist", file=sys.stderr)
        main_rows = scrape_series_main(self.session, cfg)
        attach_jp_mainlist_title_from_main_series(jp_rows, main_rows)

        jp_paths = set(jp_rows.keys())
        main_paths = set(main_rows.keys())

        print("INFO: attribute layer — object class tags", file=sys.stderr)
        oc_jp = map_object_class_from_tag_pages(self.session, cfg, jp_paths)
        oc_main = map_object_class_from_tag_pages(self.session, cfg, main_paths)
        for p, row in jp_rows.items():
            if not row.c and p in oc_jp:
                row.c = oc_jp[p]
        for p, row in main_rows.items():
            if not row.c and p in oc_main:
                row.c = oc_main[p]

        print("INFO: intl lists (hub crawl)", file=sys.stderr)
        int_entries = build_int_rows_from_wikidot(self.session, cfg)

        print("INFO: tales — foundation-tales-jp + foundation-tales", file=sys.stderr)
        tales_html = fetch_html(self.session, cfg.abs_url(cfg.foundation_tales_path))
        tale_entries = parse_foundation_tales_jp(tales_html, cfg)
        try:
            tales_en_html = fetch_html(self.session, cfg.abs_url(FOUNDATION_TALES_EN), retries=4)
            tale_entries.extend(parse_foundation_tales_jp(tales_en_html, cfg))
        except Exception as ex:
            print(f"WARN: foundation-tales (EN hub): {ex}", file=sys.stderr)
        tale_by_i: dict[str, dict[str, Any]] = {}
        for ent in tale_entries:
            ik = ent.get("i")
            if isinstance(ik, str) and ik.strip():
                tale_by_i[ik.strip()] = ent
        tale_entries = list(tale_by_i.values())

        print("INFO: gois — goi-formats-jp (structured, schema v3)", file=sys.stderr)
        goi_regions, goi_flat, goi_meta = scrape_goi_formats_hub_structured(
            self.session, cfg
        )
        goi_payload: dict[str, Any] = {
            "entries": goi_flat,
            "metadata": {
                k: v for k, v in goi_meta.items() if isinstance(v, dict) and v
            },
            "goiRegions": {
                "en": goi_regions.get("en") or [],
                "jp": goi_regions.get("jp") or [],
                "other": goi_regions.get("other") or [],
            },
        }

        print("INFO: canons — canon-hub-jp + canon-hub (div.canon-title only)", file=sys.stderr)
        canon_light, canon_meta, canon_regions = scrape_canon_manifest_payload(
            self.session, cfg
        )

        print("INFO: jokes — joke-scps + joke-scps-jp", file=sys.stderr)
        joke_entries = scrape_joke_index_entries(self.session, cfg)

        man_jp = os.path.join(cfg.output_dir, "manifest_scp-jp.json")
        man_main = os.path.join(cfg.output_dir, "manifest_scp-main.json")
        man_int = os.path.join(cfg.output_dir, "manifest_scp-int.json")
        man_tales = os.path.join(cfg.output_dir, "manifest_tales.json")
        man_gois = os.path.join(cfg.output_dir, "manifest_gois.json")
        man_canons = os.path.join(cfg.output_dir, "manifest_canons.json")
        man_jokes = os.path.join(cfg.output_dir, "manifest_jokes.json")

        ej, mj = trifold_rows_to_manifest_parts(jp_rows)
        write_manifest(man_jp, ej, mj)
        em, mm = trifold_rows_to_manifest_parts(main_rows)
        write_manifest(man_main, em, mm)
        write_manifest(man_int, int_entries, {})

        tl, tm = tales_raw_to_manifest_parts(tale_entries)
        write_manifest(man_tales, tl, tm)
        write_goi_manifest_v3(man_gois, goi_payload)
        write_canon_manifest(man_canons, canon_light, canon_meta, canon_regions)
        jl, jm = simple_multiform_raw_to_manifest_parts(joke_entries)
        write_manifest(man_jokes, jl, jm)

        print(
            f"OK: wrote {man_jp}, {man_main}, {man_int}, {man_tales}, {man_gois}, {man_canons}, {man_jokes}",
            file=sys.stderr,
        )


def main() -> int:
    p = argparse.ArgumentParser(description="Hybrid harvester for list/jp/*.json")
    p.add_argument(
        "--output-dir",
        type=str,
        default="",
        help="list/jp 相当の書き出し先（未指定なら <本スクリプトの直上>/list/jp）",
    )
    args = p.parse_args()
    cfg = BranchConfig()
    if args.output_dir:
        cfg.output_dir = os.path.abspath(args.output_dir)
    try:
        JapaneseBranchHarvester(cfg).run()
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
