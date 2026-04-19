/**
 * Wikidot (scp-wiki / scp-jp) 向けの読み取り用クリーンアップ。
 * Android 版でも同じファイルをバンドルに含めて再利用すること。
 */
(function () {
  "use strict";

  var STYLE_ID = "scpdocs-clean-ui";

  function injectStyle() {
    if (document.getElementById(STYLE_ID)) {
      return;
    }
    var style = document.createElement("style");
    style.id = STYLE_ID;
    style.type = "text/css";
    style.textContent =
      "html, body { background: #121212 !important; color: #C0C0C0 !important; " +
      "overflow-x: hidden !important; max-width: 100% !important; box-sizing: border-box !important; " +
      "padding-left: env(safe-area-inset-left, 0px) !important; " +
      "padding-right: env(safe-area-inset-right, 0px) !important; }" +
      "a, a:visited { color: #C0C0C0 !important; }" +
      "a:hover { color: #e0e0e0 !important; }" +
      "#header, #top-bar, #side-bar, #footer, .action-area, " +
      "#login-status, #search-top-box, #page-options-container, " +
      ".page-options-bottom, .footer-wikiwalk-nav, .licensebox { " +
      "display: none !important; visibility: hidden !important; }" +
      "#container, #content-wrap, #main-content, #page-content { " +
      "max-width: 100% !important; margin: 0 !important; " +
      "padding: 10px 4px !important; box-sizing: border-box !important; }" +
      "#container { background: #121212 !important; }";

    (document.head || document.documentElement).appendChild(style);
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
        /* ignore invalid selector environments */
      }
    });
  }

  function apply() {
    injectStyle();
    hideLegacyNodes();
  }

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
