/* --------------------------------------------------------------------------
   Theme button. The site opens light. Dark is used only when the reader
   picks it, and that choice is remembered in this browser.
   -------------------------------------------------------------------------- */
(function () {
  var btn = document.getElementById('themebtn');
  if (!btn) return;
  var root = document.documentElement;

  function current() {
    return root.getAttribute('data-theme') === 'dark' ? 'dark' : 'light';
  }

  function label() {
    var text = current() === 'dark' ? 'Switch to light theme' : 'Switch to dark theme';
    btn.setAttribute('aria-label', text);
    btn.title = text;
  }

  label();

  btn.addEventListener('click', function () {
    var next = current() === 'dark' ? 'light' : 'dark';
    root.setAttribute('data-theme', next);
    try { localStorage.setItem('d3d-theme', next); } catch (e) {}
    label();
  });
})();

/* --------------------------------------------------------------------------
   The logo cube.

   A real cube, drawn the way the original mark is drawn.

   The projection is the 2:1 dimetric one the logo uses, not true 30 degree
   isometric: a point (x, y, z) on the unit cube lands at
       X = 12 + 3.6 * (x - z)
       Y = 12 + 1.8 * (x + z) - 3.6 * y
   At rest this reproduces the original three paths exactly, corner for
   corner, so the logo does not shift when the script takes over.

   Shading is a fixed light with a bias, tuned so the three faces you can see
   at rest come out as the original colours: #5e5e67 on top, #3e3e45 on the
   left, #29292f on the right. The light stays put while the cube turns, so
   faces brighten and darken as they come round.

   Faces are painted far to near, so the ones behind are simply covered.
   -------------------------------------------------------------------------- */
(function () {
  var brand = document.querySelector('#titlebar .brand');
  if (!brand) return;
  var group = brand.querySelector('.cube-faces');
  if (!group) return;

  // Unit cube corners. Index bits are (x, y, z), each -1 or 1.
  var V = [
    [-1, -1, -1], [1, -1, -1], [1, -1, 1], [-1, -1, 1],
    [-1,  1, -1], [1,  1, -1], [1,  1, 1], [-1,  1, 1]
  ];
  // Each face: its four corners, and the direction it points.
  var F = [
    { i: [4, 5, 6, 7], n: [0,  1,  0] },  // top
    { i: [0, 1, 2, 3], n: [0, -1,  0] },  // bottom
    { i: [3, 2, 6, 7], n: [0,  0,  1] },  // the left face you see at rest
    { i: [0, 1, 5, 4], n: [0,  0, -1] },
    { i: [1, 2, 6, 5], n: [1,  0,  0] },  // the right face you see at rest
    { i: [0, 3, 7, 4], n: [-1, 0,  0] }
  ];
  var LIGHT = [0.236, 0.849, 0.472];

  function spin(p, cos, sin) {
    return [p[0] * cos + p[2] * sin, p[1], -p[0] * sin + p[2] * cos];
  }

  function project(p) {
    return (12 + 3.6 * (p[0] - p[2])).toFixed(2) + ',' +
           (12 + 1.8 * (p[0] + p[2]) - 3.6 * p[1]).toFixed(2);
  }

  function shade(n) {
    var d = n[0] * LIGHT[0] + n[1] * LIGHT[1] + n[2] * LIGHT[2];
    var i = Math.max(0, Math.min(1, 1.326 * d - 0.126));
    return 'rgb(' + Math.round(30 + i * 64) + ',' +
                    Math.round(30 + i * 64) + ',' +
                    Math.round(35 + i * 68) + ')';
  }

  function render(angle) {
    var cos = Math.cos(angle), sin = Math.sin(angle);
    var corner = V.map(function (p) { return spin(p, cos, sin); });
    var order = F.map(function (f) {
      var depth = 0;
      f.i.forEach(function (k) {
        depth += corner[k][0] + corner[k][1] + corner[k][2];
      });
      return { f: f, depth: depth };
    }).sort(function (a, b) { return a.depth - b.depth; });

    var out = '';
    order.forEach(function (o) {
      out += '<polygon points="' +
        o.f.i.map(function (k) { return project(corner[k]); }).join(' ') +
        '" fill="' + shade(spin(o.f.n, cos, sin)) + '"/>';
    });
    group.innerHTML = out;
  }

  var reduced = window.matchMedia &&
                window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if (reduced) return;   // leave the still logo exactly as it shipped

  var TURN = 6000;       // one revolution, in milliseconds
  var angle = 0, last = 0, wanted = false, running = false;

  function frame(now) {
    if (!last) last = now;
    angle += ((now - last) / TURN) * Math.PI * 2;
    last = now;

    // When the pointer leaves, keep going to the next whole turn and stop
    // there, so the cube always settles facing forward.
    if (!wanted && angle >= Math.PI * 2) {
      angle = 0;
      running = false;
      render(0);
      return;
    }

    angle %= Math.PI * 2;
    render(angle);
    requestAnimationFrame(frame);
  }

  function start() {
    wanted = true;
    if (running) return;
    running = true;
    last = 0;
    requestAnimationFrame(frame);
  }

  function stop() { wanted = false; }

  brand.addEventListener('mouseenter', start);
  brand.addEventListener('mouseleave', stop);
  brand.addEventListener('focus', start);
  brand.addEventListener('blur', stop);
})();
