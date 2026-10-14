// Default art module — palette-driven generic supergraphic.
// Used for any app without a bespoke art/<app>.js. Reads the palette that
// config.js already applied to CSS custom properties at document level.
(function () {
  const css = getComputedStyle(document.documentElement);
  const primary = (css.getPropertyValue('--primary') || '#2E7D32').trim();
  const dark = (css.getPropertyValue('--dark') || '#1B5E20').trim();
  const accent = (css.getPropertyValue('--accent') || '#F9A825').trim();

  // A continuous wave band + drifting dots crossing all four seams.
  window.STORE_ART = {
    theme: { bg: 'linear-gradient(160deg, ' + primary + ' 0%, ' + dark + ' 100%)' },
    panoramaSvg:
      '<svg viewBox="0 0 4320 1920" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg">' +
        '<defs>' +
          '<linearGradient id="dfw" x1="0" y1="0" x2="1" y2="0">' +
            '<stop offset="0" stop-color="' + accent + '" stop-opacity=".22"/>' +
            '<stop offset="1" stop-color="' + accent + '" stop-opacity=".08"/>' +
          '</linearGradient>' +
        '</defs>' +
        '<path d="M0,320 C540,200 1080,440 1620,320 S2700,200 3240,320 S4320,440 4320,320 L4320,0 L0,0 Z" fill="url(#dfw)"/>' +
        '<path d="M0,1700 C720,1560 1440,1840 2160,1700 S3600,1560 4320,1700 L4320,1920 L0,1920 Z" fill="' + accent + '" opacity=".10"/>' +
        '<g fill="#FFFFFF" opacity=".14">' +
          '<circle cx="380" cy="520" r="10"/><circle cx="1060" cy="240" r="7"/>' +
          '<circle cx="1520" cy="560" r="9"/><circle cx="2140" cy="300" r="12"/>' +
          '<circle cx="2680" cy="520" r="7"/><circle cx="3230" cy="260" r="10"/>' +
          '<circle cx="3820" cy="540" r="8"/><circle cx="4180" cy="320" r="7"/>' +
        '</g>' +
      '</svg>',
    rtlReverse: true,
  };
})();
