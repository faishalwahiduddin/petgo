// PetGo — earthy sage & warm caramel with playful paw-print trails across seams
(function () {
  const CARAMEL = '#D4A373';
  let paws = '';
  for (let x of [400, 1080, 1600, 2160, 2800, 3240, 3800]) {
    const y = 380 + Math.sin(x) * 60;
    paws += '<circle cx="' + x + '" cy="' + y + '" r="16" fill="' + CARAMEL + '" opacity=".6"/>' +
            '<circle cx="' + (x - 14) + '" cy="' + (y - 18) + '" r="6" fill="' + CARAMEL + '" opacity=".5"/>' +
            '<circle cx="' + x + '" cy="' + (y - 24) + '" r="6" fill="' + CARAMEL + '" opacity=".5"/>' +
            '<circle cx="' + (x + 14) + '" cy="' + (y - 18) + '" r="6" fill="' + CARAMEL + '" opacity=".5"/>';
  }
  window.STORE_ART = {
    generic: false,
    theme: { bg: 'linear-gradient(180deg, #3E5A3D 0%, #293D28 55%, #162215 100%)', ink: '#FAF7F2' },
    panoramaSvg:
      '<svg viewBox="0 0 4320 1920" preserveAspectRatio="xMidYMid slice" xmlns="http://www.w3.org/2000/svg">' +
        paws +
      '</svg>',
    rtlReverse: true
  };
})();
