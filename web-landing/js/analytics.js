/**
 * Fleet landing analytics — GA4 + Meta Pixel, consent-gated.
 * Expects window.__LANDING_ANALYTICS__ = { gaId, metaPixelId, app }.
 * No-ops when both IDs are empty (scaffold mode).
 */
(function () {
  "use strict";

  var cfg = window.__LANDING_ANALYTICS__ || {};
  var gaId = (cfg.gaId || "").trim();
  var metaPixelId = (cfg.metaPixelId || "").trim();
  var appName = (cfg.app || "").trim() || "landing";
  var STORAGE_KEY = "faishal-landing-analytics-consent";

  if (!gaId && !metaPixelId) {
    return;
  }

  function readConsent() {
    try {
      var v = localStorage.getItem(STORAGE_KEY);
      return v === "granted" || v === "denied" ? v : null;
    } catch (e) {
      return null;
    }
  }

  function writeConsent(value) {
    try {
      localStorage.setItem(STORAGE_KEY, value);
    } catch (e) {
      /* ignore */
    }
  }

  function setConsentHeight(px) {
    document.documentElement.style.setProperty("--consent-h", px + "px");
  }

  function trackGa(name, params) {
    if (typeof window.gtag === "function") {
      window.gtag("event", name, params || {});
    }
  }

  function trackMeta(name, params) {
    if (typeof window.fbq === "function") {
      window.fbq("track", name, params || {});
    }
  }

  window.__landingTrack = function (name, params) {
    trackGa(name, params);
    if (name === "cta_store_clicked") {
      trackMeta("Lead", params);
    } else if (name === "blog_article_clicked") {
      trackMeta("ViewContent", params);
    }
  };

  function loadGa() {
    if (!gaId || document.getElementById("ga-gtag")) return;
    var script = document.createElement("script");
    script.id = "ga-gtag";
    script.async = true;
    script.src = "https://www.googletagmanager.com/gtag/js?id=" + encodeURIComponent(gaId);
    document.head.appendChild(script);
    window.dataLayer = window.dataLayer || [];
    function gtag() {
      window.dataLayer.push(arguments);
    }
    window.gtag = gtag;
    gtag("js", new Date());
    gtag("config", gaId, { anonymize_ip: true });
  }

  function loadMeta() {
    if (!metaPixelId || window.fbq) return;
    !(function (f, b, e, v, n, t, s) {
      if (f.fbq) return;
      n = f.fbq = function () {
        n.callMethod ? n.callMethod.apply(n, arguments) : n.queue.push(arguments);
      };
      if (!f._fbq) f._fbq = n;
      n.push = n;
      n.loaded = true;
      n.version = "2.0";
      n.queue = [];
      t = b.createElement(e);
      t.async = true;
      t.src = v;
      s = b.getElementsByTagName(e)[0];
      s.parentNode.insertBefore(t, s);
    })(window, document, "script", "https://connect.facebook.net/en_US/fbevents.js");
    window.fbq("init", metaPixelId);
    window.fbq("track", "PageView");
  }

  function bootTrackers() {
    loadGa();
    loadMeta();
    trackGa("page_view", { app: appName });
    trackMeta("ViewContent", { content_name: appName, content_category: "landing" });
  }

  function bindCtas() {
    document.addEventListener(
      "click",
      function (ev) {
        var el = ev.target.closest("a, button, [data-track]");
        if (!el) return;

        if (el.id === "play-store-download-btn" || (el.href && /play\.google\.com/.test(el.href))) {
          window.__landingTrack("cta_store_clicked", {
            store: "play",
            location: el.closest("#download") ? "download" : "other",
            app: appName,
          });
          return;
        }
        if (el.id === "app-store-upcoming-btn" || (el.href && /apps\.apple\.com/.test(el.href || ""))) {
          window.__landingTrack("cta_store_clicked", {
            store: "appstore",
            location: el.closest("#download") ? "download" : "other",
            app: appName,
          });
          return;
        }
        var blogLink = el.closest('a[href*="/blog/"]');
        if (blogLink && blogLink.href) {
          var m = blogLink.href.match(/\/blog\/([^/?#]+)/);
          window.__landingTrack("blog_article_clicked", {
            slug: m ? m[1] : "",
            location: blogLink.closest("#blog") ? "blog_section" : "nav",
            app: appName,
          });
        }
      },
      true
    );

    document.querySelectorAll("#lang-dropdown a[href]").forEach(function (a) {
      a.addEventListener("click", function () {
        var href = a.getAttribute("href") || "";
        var loc = "id";
        var parts = href.replace(/^https?:\/\/[^/]+/, "").split("/").filter(Boolean);
        if (parts[0] && parts[0].length <= 3) loc = parts[0];
        window.__landingTrack("lang_changed", { locale: loc, app: appName });
      });
    });
  }

  function showBanner() {
    var banner = document.getElementById("consent-banner");
    if (!banner) {
      bootTrackers();
      bindCtas();
      return;
    }
    banner.hidden = false;
    var measure = function () {
      setConsentHeight(banner.offsetHeight);
    };
    measure();
    if ("ResizeObserver" in window) {
      new ResizeObserver(measure).observe(banner);
    } else {
      window.addEventListener("resize", measure, { passive: true });
    }
    banner.querySelectorAll("[data-consent]").forEach(function (btn) {
      btn.addEventListener("click", function () {
        var value = btn.getAttribute("data-consent");
        if (value !== "granted" && value !== "denied") return;
        writeConsent(value);
        banner.hidden = true;
        setConsentHeight(0);
        if (value === "granted") {
          bootTrackers();
        }
        bindCtas();
      });
    });
  }

  var existing = readConsent();
  if (existing === "granted") {
    bootTrackers();
    bindCtas();
    return;
  }
  if (existing === "denied") {
    bindCtas();
    return;
  }
  showBanner();
})();
