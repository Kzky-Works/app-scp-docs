#!/usr/bin/env python3
"""
SCP-JP シリーズ一覧（Wikidot）からタイトルを取得し、アプリの SCPListRemotePayload 互換 JSON を生成する。

要件: ScpDocs の SCPListRemotePayload / SCPListRemoteEntry（series: 0…4, scpNumber: Int）に一致。
`hubLinkedPaths` は scp-international から辿る国際支部和訳（/scp-数字-2文字、-jp 以外）。
"""

from __future__ import annotations

import json
import re
import sys
import time
from dataclasses import dataclass
from datetime import datetime, timezone
from typing import Any
from urllib.parse import urljoin, urlparse, urlunparse

import requests
from bs4 import BeautifulSoup

# 取得間隔（秒）。短時間の連続アクセスを避ける。
REQUEST_DELAY_SEC = 2.5
# 国際ハブ配下の一覧ページ取得にも同間隔を使う。
REQUEST_DELAY_HUB_SEC = 2.5
# scp-international から辿る一覧ページの最大取得数（CI 時間・相手サーバ負荷の上限）。
MAX_INTL_LIST_PAGES = 150

# User-Agent（ブロック回避・識別用）
HTTP_HEADERS = {
    "User-Agent": "ScpDocsListBot/1.0 (+https://github.com/scp-docs; contact: repo owner)",
    "Accept-Language": "ja,en;q=0.8",
}

# SCPJPSeries.rawValue → Wikidot 一覧 URL
SERIES_PAGES: list[tuple[int, str]] = [
    (0, "https://scp-jp.wikidot.com/scp-series-jp"),
    (1, "https://scp-jp.wikidot.com/scp-series-jp-2"),
    (2, "https://scp-jp.wikidot.com/scp-series-jp-3"),
    (3, "https://scp-jp.wikidot.com/scp-series-jp-4"),
    (4, "https://scp-jp.wikidot.com/scp-series-jp-5"),
]

INTERNATIONAL_HUB_URL = "https://scp-jp.wikidot.com/scp-international"

SCP_HREF_RE = re.compile(r"^/scp-(\d+)-jp$")
# 国際支部の和訳記事（2 文字コード）。`-jp` はメインシリーズ側で扱うため除外。
INTL_SCP_ARTICLE_PATH_RE = re.compile(r"^/scp-\d+-[a-z]{2}$")

INTL_LIST_SUBSTRINGS = (
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


@dataclass(frozen=True)
class SeriesRange:
    lo: int
    hi: int


def range_for_series(series: int) -> SeriesRange:
    # SCPJPSeries.scpNumberRange と同一
    ranges = {
        0: SeriesRange(1, 999),
        1: SeriesRange(1000, 1999),
        2: SeriesRange(2000, 2999),
        3: SeriesRange(3000, 3999),
        4: SeriesRange(4000, 4999),
    }
    return ranges[series]


def is_english_main_series_list(path: str) -> bool:
    """英語本部の SCP シリーズ一覧（/scp-series, /scp-series-2 …）。"""
    pl = path.lower()
    if pl == "/scp-series":
        return True
    return bool(re.match(r"^/scp-series-\d+$", pl))


def looks_like_intl_branch_list_page(path: str) -> bool:
    """scp-international から辿る「国際支部の SCP 和訳一覧」候補。"""
    pl = path.lower()
    if pl in {"/", "/scp-international"}:
        return False
    if "scp-series-jp" in pl:
        return False
    if is_english_main_series_list(path):
        return False
    return any(s in pl for s in INTL_LIST_SUBSTRINGS)


def parse_scp_number_from_href(href: str) -> int | None:
    m = SCP_HREF_RE.match(href.strip())
    if not m:
        return None
    return int(m.group(1), 10)


def extract_title_from_li(li) -> str | None:
    # strip=True は子ノード単位で空白を削るため、「</a> - タイトル」の先頭スペースが落ちて
    # 「SCP-xxx-JP- タイトル」になり区切りが壊れる。全体を結合してから strip する。
    full = li.get_text(separator="", strip=False).strip()
    if " - " not in full:
        return None
    _, title = full.split(" - ", 1)
    t = title.strip()
    return t if t else None


def fetch_html_with_retry(session: requests.Session, url: str, retries: int = 4) -> str:
    last_err: Exception | None = None
    for attempt in range(retries):
        time.sleep(REQUEST_DELAY_HUB_SEC)
        try:
            r = session.get(url, headers=HTTP_HEADERS, timeout=90)
            if r.status_code == 503 and attempt < retries - 1:
                time.sleep(6 * (attempt + 1))
                continue
            r.raise_for_status()
            r.encoding = r.encoding or "utf-8"
            return r.text
        except Exception as e:
            last_err = e
            if attempt < retries - 1:
                time.sleep(5 * (attempt + 1))
    assert last_err is not None
    raise last_err


def extract_intl_article_paths_from_html(html: str) -> set[str]:
    soup = BeautifulSoup(html, "html.parser")
    out: set[str] = set()
    base = "https://scp-jp.wikidot.com/"
    for a in soup.find_all("a", href=True):
        raw = (a.get("href") or "").strip()
        if not raw or raw.startswith("#"):
            continue
        path = urlparse(urljoin(base, raw)).path
        m = INTL_SCP_ARTICLE_PATH_RE.match(path)
        if not m:
            continue
        if path.endswith("-jp"):
            continue
        out.add(path)
    return out


def fetch_international_hub_article_paths(session: requests.Session) -> list[str]:
    text = fetch_html_with_retry(session, INTERNATIONAL_HUB_URL)
    soup = BeautifulSoup(text, "html.parser")
    list_urls: list[str] = []
    seen_u: set[str] = set()
    for a in soup.find_all("a", href=True):
        raw = (a.get("href") or "").strip()
        if not raw or raw.startswith("#"):
            continue
        absu = urljoin(INTERNATIONAL_HUB_URL, raw)
        pu = urlparse(absu)
        if pu.netloc != "scp-jp.wikidot.com":
            continue
        path = pu.path or "/"
        if not looks_like_intl_branch_list_page(path):
            continue
        u = urlunparse(("https", "scp-jp.wikidot.com", path, "", "", ""))
        if u not in seen_u:
            seen_u.add(u)
            list_urls.append(u)
    list_urls.sort()
    articles: set[str] = set()
    for i, u in enumerate(list_urls):
        if i >= MAX_INTL_LIST_PAGES:
            break
        try:
            html = fetch_html_with_retry(session, u)
        except Exception as e:
            print(f"WARN: skip intl list {u}: {e}", file=sys.stderr)
            continue
        articles.update(extract_intl_article_paths_from_html(html))
    return sorted(articles)


def fetch_series_entries(series: int, url: str, session: requests.Session) -> list[dict[str, Any]]:
    time.sleep(REQUEST_DELAY_SEC)
    r = session.get(url, headers=HTTP_HEADERS, timeout=60)
    r.raise_for_status()
    r.encoding = r.encoding or "utf-8"

    soup = BeautifulSoup(r.text, "html.parser")
    rng = range_for_series(series)
    out: list[dict[str, Any]] = []

    for li in soup.find_all("li"):
        a = li.find("a", href=True)
        if not a:
            continue
        href = a.get("href", "") or ""
        n = parse_scp_number_from_href(href)
        if n is None:
            continue
        if not (rng.lo <= n <= rng.hi):
            continue
        title = extract_title_from_li(li)
        if not title:
            continue
        out.append({"series": series, "scpNumber": n, "title": title})

    return out


def validate_payload(payload: dict[str, Any]) -> None:
    schema = payload.get("schemaVersion")
    if schema != 1:
        raise ValueError(f"schemaVersion must be 1, got {schema!r}")

    lv = payload.get("listVersion")
    if not isinstance(lv, int) or lv <= 0:
        raise ValueError(f"listVersion must be positive int, got {lv!r}")

    gen = payload.get("generatedAt")
    if not isinstance(gen, str) or not gen:
        raise ValueError("generatedAt must be non-empty string")

    entries = payload.get("entries")
    if not isinstance(entries, list) or len(entries) == 0:
        raise ValueError("entries must be non-empty list")

    hub = payload.get("hubLinkedPaths", [])
    if not isinstance(hub, list):
        raise ValueError("hubLinkedPaths must be a list")
    for i, p in enumerate(hub):
        if not isinstance(p, str) or not p.startswith("/scp-"):
            raise ValueError(f"hubLinkedPaths[{i}] must be a path string starting with /scp-")

    seen: set[tuple[int, int]] = set()
    for i, e in enumerate(entries):
        if not isinstance(e, dict):
            raise ValueError(f"entries[{i}] is not an object")
        s = e.get("series")
        n = e.get("scpNumber")
        t = e.get("title")
        if not isinstance(s, int) or not (0 <= s <= 4):
            raise ValueError(f"entries[{i}].series invalid: {s!r}")
        if not isinstance(n, int):
            raise ValueError(f"entries[{i}].scpNumber must be int, got {n!r}")
        if not isinstance(t, str) or not t.strip():
            raise ValueError(f"entries[{i}].title invalid")
        rng = range_for_series(s)
        if not (rng.lo <= n <= rng.hi):
            raise ValueError(f"entries[{i}] scpNumber {n} out of range for series {s}")
        key = (s, n)
        if key in seen:
            raise ValueError(f"duplicate entry series={s} scpNumber={n}")
        seen.add(key)


def scrape_all() -> dict[str, Any]:
    session = requests.Session()
    all_entries: list[dict[str, Any]] = []

    for series, url in SERIES_PAGES:
        rows = fetch_series_entries(series, url, session)
        if len(rows) == 0:
            raise RuntimeError(f"No entries parsed for series={series} url={url}")
        all_entries.extend(rows)

    all_entries.sort(key=lambda e: (e["series"], e["scpNumber"]))

    hub_paths = fetch_international_hub_article_paths(session)

    now = datetime.now(timezone.utc)
    generated_at = now.strftime("%Y-%m-%dT%H:%M:%SZ")
    list_version = int(now.timestamp())

    payload: dict[str, Any] = {
        "listVersion": list_version,
        "schemaVersion": 1,
        "generatedAt": generated_at,
        "entries": all_entries,
        "hubLinkedPaths": hub_paths,
    }
    validate_payload(payload)
    return payload


def main() -> int:
    out_path = "scp_list.json"
    try:
        data = scrape_all()
    except Exception as e:
        print(f"ERROR: {e}", file=sys.stderr)
        return 1

    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")

    hub_n = len(data.get("hubLinkedPaths", []))
    print(f"Wrote {out_path} ({len(data['entries'])} entries, {hub_n} hubLinkedPaths).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
