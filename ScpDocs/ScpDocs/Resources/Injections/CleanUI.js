/**
 * Wikidot (scp-wiki / scp-jp) 向けの読み取り用クリーンアップ。
 * テーマ色は `window.__SCPDOCS_THEME__`（Swift の documentStart 注入）と同期する。
 */
(function () {
  "use strict";

  var STYLE_ID = "scpdocs-clean-ui";

  function defaultTheme() {
    return {
      background: "#0A0A0A",
      text: "#C0C0C0",
      link: "#C0C0C0",
      linkHover: "#E0E0E0",
      container: "#0A0A0A",
      inset: "#1C1C1E",
    };
  }

  function theme() {
    var t = window.__SCPDOCS_THEME__;
    if (!t || typeof t !== "object") {
      return defaultTheme();
    }
    var d = defaultTheme();
    return {
      background: t.background || d.background,
      text: t.text || d.text,
      link: t.link || d.link,
      linkHover: t.linkHover || d.linkHover,
      container: t.container || d.container,
      inset: t.inset || d.inset,
    };
  }

  function injectStyle() {
    var T = theme();
    var style = document.getElementById(STYLE_ID);
    if (!style) {
      style = document.createElement("style");
      style.id = STYLE_ID;
      style.type = "text/css";
      (document.head || document.documentElement).appendChild(style);
    }
    var insetBorder =
      T.inset && T.background && T.inset !== T.background
        ? "rgba(226, 224, 214, 0.32)"
        : "rgba(26, 26, 26, 0.14)";
    var boxSelectors = [
      "#page-content blockquote",
      "#page-content .blockquote",
      "#page-content .content-panel",
      "#page-content .jumbo",
      "#page-content .collapsible-block",
      "#page-content .quote",
      "#page-content .pseudonote",
      "#page-content .note",
      "#page-content .dashed",
      "#page-content .paper",
      "#page-content .modal-body",
      "#page-content table.wiki-content-table",
      "#page-content pre",
    ];
    var insetIs = ":is(" + boxSelectors.join(", ") + ")";
    style.textContent =
      "html, body { background: " +
      T.background +
      " !important; color: " +
      T.text +
      " !important; " +
      "font-family: -apple-system, system-ui, sans-serif !important; " +
      "overflow-x: hidden !important; max-width: 100% !important; box-sizing: border-box !important; " +
      "padding-left: env(safe-area-inset-left, 0px) !important; " +
      "padding-right: env(safe-area-inset-right, 0px) !important; }" +
      "a, a:visited { color: " +
      T.link +
      " !important; text-decoration-color: " +
      T.link +
      " !important; }" +
      "a:hover { color: " +
      T.linkHover +
      " !important; }" +
      "#header, #top-bar, #side-bar, #footer, .action-area, " +
      "#login-status, #search-top-box, #page-options-container, " +
      ".page-options-bottom, .footer-wikiwalk-nav, .licensebox { " +
      "display: none !important; visibility: hidden !important; }" +
      "#container, #content-wrap, #main-content, #page-content { " +
      "max-width: 100% !important; margin: 0 !important; " +
      "padding: 10px 4px !important; box-sizing: border-box !important; }" +
      "#container { background: " +
      T.container +
      " !important; }" +
      /* Wikidot テーマの白/オフ白ボックスをダークで可読化（:is で子孫一括。リンクは下で別指定） */
      insetIs +
      " { background: " +
      T.inset +
      " !important; color: " +
      T.text +
      " !important; " +
      "border: 1px dashed " +
      insetBorder +
      " !important; " +
      "box-shadow: none !important; }" +
      insetIs +
      " *:not(a):not(svg) { color: " +
      T.text +
      " !important; }" +
      insetIs +
      " a, " +
      insetIs +
      " a:visited { color: " +
      T.link +
      " !important; text-decoration-color: " +
      T.link +
      " !important; }" +
      insetIs +
      " a:hover { color: " +
      T.linkHover +
      " !important; }";
  }

  function hideLegacyNodes() {
    var selectors = [
      "#header",
      "#top-bar",
      "#side-bar",
      "#footer",
      ".action-area",
      "#login-status",
      "#search-top-box",
      "#page-options-container",
      ".page-options-bottom",
      ".footer-wikiwalk-nav",
      ".licensebox",
    ];
    selectors.forEach(function (sel) {
      try {
        document.querySelectorAll(sel).forEach(function (el) {
          el.style.setProperty("display", "none", "important");
        });
      } catch (e) {
        /* ignore */
      }
    });
  }

  function apply() {
    injectStyle();
    hideLegacyNodes();
  }

  window.__SCPDOCS_applyCleanUITheme = function (T) {
    if (T && typeof T === "object") {
      window.__SCPDOCS_THEME__ = T;
    }
    apply();
  };

  apply();

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", apply);
  }

  var target = document.documentElement || document.body;
  if (target && typeof MutationObserver !== "undefined") {
    var scheduled = false;
    var observer = new MutationObserver(function () {
      if (scheduled) {
        return;
      }
      scheduled = true;
      requestAnimationFrame(function () {
        scheduled = false;
        apply();
      });
    });
    try {
      observer.observe(target, { childList: true, subtree: true });
    } catch (e) {
      /* ignore */
    }
  }
})();
