// Copyright (c) 2026 K. S. Ernest (iFire) Lee
// SPDX-License-Identifier: Apache-2.0 OR MIT
// The interactive prerequisite map: radial rings around the goal, token filters, skipped-ahead links.
(() => {
  const root = document.getElementById("tree");
  const raw = document.getElementById("tree-data");
  if (!root || !raw) return;
  const data = JSON.parse(raw.textContent);
  const NS = "http://www.w3.org/2000/svg";
  const COLORS = ["#e6194b", "#f58231", "#b8860b", "#00a5cf", "#4363d8", "#911eb4", "#008080"];
  const GREEN = "#2e7d32";
  const byN = new Map(data.nodes.map((n) => [n.n, n]));
  const unlinked = data.tokens.filter((t) => t.owners.length === 0);
  const settled = (n) => n.s === "published" || n.s === "committed";
  const st = { depth: 2, focus: null, filter: null, skips: true, pos: new Map(), hex: new Map(),
    got: new Set(data.nodes.filter(settled).map((n) => n.n)) };
  const skipped = (a, b) => st.got.has(a) && !st.got.has(b);
  let vb = { x: 0, y: 0, w: 1000, h: 1000 };

  const mk = (tag, attrs = {}, parent) => {
    const e = document.createElementNS(NS, tag);
    for (const k in attrs) e.setAttribute(k, attrs[k]);
    if (parent) parent.appendChild(e);
    return e;
  };
  const h = (tag, attrs = {}, text) => {
    const e = document.createElement(tag);
    for (const k in attrs) e.setAttribute(k, attrs[k]);
    if (text !== undefined) e.textContent = text;
    return e;
  };
  const short = (n) => "RFD66606-" + n;

  const bar = h("div", { class: "tree-bar" });
  const stage = h("div", { class: "tree-stage" });
  const panel = h("aside", { class: "tree-panel" });
  const wallet = h("div", { class: "tree-wallet" });
  root.append(bar, wallet, stage, panel);
  const svg = mk("svg", { class: "tree-svg", role: "img", "aria-label": "Prerequisite map" });
  stage.appendChild(svg);

  function visible() { return data.nodes.filter((n) => n.d <= st.depth); }

  function layout() {
    st.pos.clear();
    st.hex.clear();
    const vis = visible();
    st.pos.set(data.goal, { x: 0, y: 0, a: 0, r: 0 });
    let prev = 0;
    for (let d = 1; d <= st.depth; d++) {
      const ring = vis.filter((n) => n.d === d);
      if (!ring.length) continue;
      const rad = Math.max(prev + 135, (ring.length * 70) / (2 * Math.PI));
      const want = ring.map((n) => {
        const kin = vis.filter((m) => m.d === d - 1 && m.c.includes(n.n)).map((m) => st.pos.get(m.n));
        const use = kin.length ? kin : vis.filter((m) => m.c.includes(n.n) && st.pos.has(m.n)).map((m) => st.pos.get(m.n));
        const sx = use.reduce((s, p) => s + Math.cos(p.a), 0);
        const sy = use.reduce((s, p) => s + Math.sin(p.a), 0);
        return { n, a: use.length ? Math.atan2(sy, sx) : n.n };
      });
      want.sort((p, q) => p.a - q.a || p.n.n - q.n.n);
      const base = d === 1 ? -Math.PI / 2 : want[0].a;
      want.forEach((w, i) => {
        const a = base + (i * 2 * Math.PI) / want.length;
        st.pos.set(w.n.n, { x: Math.cos(a) * rad, y: Math.sin(a) * rad, a, r: rad });
      });
      prev = rad;
    }
    const outer = prev + 120;
    unlinked.forEach((t, i) => {
      const users = t.users.filter((u) => st.pos.has(u));
      const a = users.length
        ? Math.atan2(
            users.reduce((s, u) => s + Math.sin(st.pos.get(u).a), 0),
            users.reduce((s, u) => s + Math.cos(st.pos.get(u).a), 0))
        : (i * 2 * Math.PI) / unlinked.length;
      st.hex.set(t.i, { x: Math.cos(a) * outer, y: Math.sin(a) * outer, users });
    });
    return outer;
  }

  function closure(start, next) {
    const seen = new Set([start]);
    const queue = [start];
    while (queue.length) for (const m of next(queue.shift())) if (!seen.has(m)) { seen.add(m); queue.push(m); }
    return seen;
  }
  const needs = (n) => (byN.get(n) ? byN.get(n).c.filter((m) => st.pos.has(m)) : []);
  const neededBy = (n) => visible().filter((m) => m.c.includes(n) && st.pos.has(m.n)).map((m) => m.n);

  function lit() {
    if (st.focus !== null) {
      const up = closure(st.focus, needs);
      const down = closure(st.focus, neededBy);
      return new Set([...up, ...down]);
    }
    if (st.filter === null) return null;
    const hit = new Set();
    for (const n of visible()) {
      if (st.filter === "boring" ? n.b.length : st.filter === "unlinked"
          ? unlinked.some((t) => n.k.includes(t.i)) : n.k.includes(st.filter)) hit.add(n.n);
    }
    return hit;
  }

  function draw() {
    const outer = layout();
    svg.replaceChildren();
    const on = lit();
    const edges = mk("g", { class: "edges" }, svg);
    const vis = visible();
    for (const n of vis) {
      for (const m of n.c) {
        if (!st.pos.has(m)) continue;
        const skip = skipped(n.n, m);
        if (skip && !st.skips) continue;
        const p = st.pos.get(n.n), q = st.pos.get(m);
        const dim = on && !(on.has(n.n) && on.has(m));
        mk("line", { x1: p.x, y1: p.y, x2: q.x, y2: q.y,
          class: "edge" + (skip ? " skip" : "") + (dim ? " dim" : "") }, edges);
      }
    }
    for (const t of unlinked) {
      const hx = st.hex.get(t.i);
      for (const u of hx.users) {
        const p = st.pos.get(u);
        const dim = on && !on.has(u);
        mk("line", { x1: hx.x, y1: hx.y, x2: p.x, y2: p.y, class: "edge skip" + (dim ? " dim" : "") }, edges);
      }
    }
    for (const n of vis) node(n, on);
    for (const t of unlinked) hexagon(t);
    const pad = 70, ext = outer + pad;
    vb = { x: -ext, y: -ext, w: ext * 2, h: ext * 2 };
    fit();
    side();
    coins();
  }

  function cost(ids) {
    const k = new Set(), b = new Set();
    for (const id of ids) { byN.get(id).k.forEach((i) => k.add(i)); byN.get(id).b.forEach((x) => b.add(x)); }
    return { k, b };
  }

  function coins() {
    wallet.replaceChildren();
    const spent = cost([...st.got].filter((n) => byN.has(n)));
    const path = closure(data.goal, (n) => byN.get(n).c.filter((m) => byN.has(m)));
    const need = cost([...path]);
    const missing = [...path].filter((n) => !st.got.has(n));
    wallet.appendChild(h("span", { class: "tw-label" }, "Innovation tokens"));
    data.tokens.forEach((t) => {
      const on = spent.k.has(t.i);
      const c = h("span", { class: "coin" + (on ? " on" : ""), title: t.name }, String(t.i));
      c.style.borderColor = COLORS[t.i - 1];
      if (on) c.style.background = COLORS[t.i - 1];
      wallet.appendChild(c);
    });
    wallet.appendChild(h("span", { class: "tw-label" }, "Boring"));
    data.boring.forEach((name) => {
      wallet.appendChild(h("span", { class: "boring-coin" + (spent.b.has(name) ? " on" : "") }, name));
    });
    wallet.appendChild(h("span", { class: "tw-goal" },
      "Goal " + short(data.goal) + ": " + missing.length + " of " + path.size
      + " skills on its path not acquired; its path spends " + need.k.size + " of "
      + data.tokens.length + " innovation tokens and " + need.b.size + " boring."));
  }

  function dots(g, n, r) {
    const slots = [...n.k.map((i) => ({ c: COLORS[i - 1], tok: true })), ...n.b.map(() => ({ c: GREEN, tok: false }))];
    slots.forEach((s, i) => {
      const a = -Math.PI / 2 + (i * 2 * Math.PI) / 8;
      mk(s.tok ? "rect" : "circle", s.tok
        ? { x: Math.cos(a) * (r + 7) - 3.5, y: Math.sin(a) * (r + 7) - 3.5, width: 7, height: 7, fill: s.c, class: "dot" }
        : { cx: Math.cos(a) * (r + 7), cy: Math.sin(a) * (r + 7), r: 3.5, fill: s.c, class: "dot" }, g);
    });
  }

  function node(n, on) {
    const p = st.pos.get(n.n);
    const goal = n.n === data.goal;
    const r = goal ? 40 : 20;
    const repo = data.repos.some((x) => x.n === n.n);
    const cls = ["node", n.s, st.got.has(n.n) ? "got" : "", goal ? "goal" : "", repo ? "repo" : "",
      on && !on.has(n.n) ? "dim" : "",
      st.focus === n.n ? "focus" : ""].join(" ");
    const g = mk("g", { class: cls, transform: "translate(" + p.x + "," + p.y + ")", tabindex: 0 }, svg);
    mk("title", {}, g).textContent = short(n.n) + ": " + n.t + " (" + n.s + ")";
    mk("circle", { r }, g);
    const t = mk("text", { "text-anchor": "middle", dy: "0.35em" }, g);
    t.textContent = goal ? "2360" : String(n.n);
    dots(g, n, r);
    const pick = () => { st.focus = st.focus === n.n ? null : n.n; draw(); };
    g.addEventListener("click", (e) => { if (!moved) { e.stopPropagation(); pick(); } });
    g.addEventListener("keydown", (e) => { if (e.key === "Enter") pick(); });
  }

  function hexagon(t) {
    const hx = st.hex.get(t.i);
    const pts = [0, 1, 2, 3, 4, 5].map((k) => {
      const a = (Math.PI / 3) * k;
      return Math.cos(a) * 26 + "," + Math.sin(a) * 26;
    }).join(" ");
    const dim = st.filter !== null && st.filter !== "unlinked" && st.filter !== t.i;
    const g = mk("g", { class: "hexnode" + (dim ? " dim" : ""), transform: "translate(" + hx.x + "," + hx.y + ")" }, svg);
    mk("title", {}, g).textContent = "Token " + t.i + ": " + t.name + ". No RFD title names it.";
    mk("polygon", { points: pts, stroke: COLORS[t.i - 1] }, g);
    mk("text", { "text-anchor": "middle", dy: "0.35em" }, g).textContent = t.name;
  }

  function side() {
    panel.replaceChildren();
    const n = st.focus === null ? byN.get(data.goal) : byN.get(st.focus);
    panel.appendChild(h("h3", {}, short(n.n)));
    panel.appendChild(h("p", { class: "tp-title" }, n.t));
    panel.appendChild(h("p", { class: "tp-state " + n.s }, n.s + (n.d ? ", ring " + n.d : ", the goal")));
    const tags = h("p", { class: "tp-tags" });
    n.k.forEach((i) => {
      const t = data.tokens.find((x) => x.i === i);
      tags.appendChild(h("span", { class: "chip", style: "border-color:" + COLORS[i - 1] }, i + " " + t.name));
    });
    n.b.forEach((b) => tags.appendChild(h("span", { class: "chip boring" }, b)));
    if (!n.k.length && !n.b.length) tags.textContent = "No technology on the ledger named.";
    panel.appendChild(tags);
    panel.appendChild(h("h4", {}, "Cost"));
    const own = cost([n.n]);
    panel.appendChild(h("p", {}, (own.k.size ? own.k.size + " innovation, " : "no innovation, ")
      + (own.b.size ? own.b.size + " boring" : "no boring")));
    const acq = h("button", { type: "button", class: "chip" + (st.got.has(n.n) ? " on" : "") },
      st.got.has(n.n) ? "Acquired. Release it" : "Acquire this skill");
    acq.addEventListener("click", () => { toggle(n.n, false); });
    panel.appendChild(acq);
    if (!st.got.has(n.n)) {
      const all = h("button", { type: "button", class: "chip" }, "Acquire its whole path");
      all.addEventListener("click", () => { toggle(n.n, true); });
      panel.appendChild(all);
    }
    const list = (label, ids) => {
      if (!ids.length) return;
      panel.appendChild(h("h4", {}, label));
      const ul = h("ul");
      ids.forEach((m) => {
        const b = h("button", { type: "button", class: "link" }, short(m) + " " + byN.get(m).t);
        b.addEventListener("click", () => { st.focus = m; draw(); });
        const li = h("li");
        li.appendChild(b);
        if (skipped(n.n, m)) li.appendChild(h("span", { class: "flag" }, " skipped ahead"));
        ul.appendChild(li);
      });
      panel.appendChild(ul);
    };
    list("Needs", needs(n.n));
    list("Needed by", neededBy(n.n));
    const rp = data.repos.filter((r) => r.n === n.n);
    rp.forEach((r) => {
      panel.appendChild(h("h4", {}, "Repository"));
      const a = h("a", { href: "https://github.com/" + r.repo }, r.repo);
      panel.appendChild(a);
      panel.appendChild(h("p", {}, r.note));
    });
    panel.appendChild(h("p", {}, "")).appendChild(h("a", { href: "#" + n.id, class: "open" }, "Open the RFD"));
  }

  function toggle(id, path) {
    if (path) closure(id, needs).forEach((m) => st.got.add(m));
    else if (st.got.has(id)) st.got.delete(id);
    else st.got.add(id);
    draw();
  }

  function controls() {
    bar.replaceChildren();
    const chip = (label, key, color) => {
      const b = h("button", { type: "button", class: "chip" + (st.filter === key ? " on" : "") }, label);
      if (color) b.style.borderColor = color;
      b.addEventListener("click", () => { st.filter = st.filter === key ? null : key; st.focus = null; controls(); draw(); });
      bar.appendChild(b);
    };
    data.tokens.forEach((t) => chip(String(t.i) + " " + t.name, t.i, COLORS[t.i - 1]));
    chip("boring", "boring", GREEN);
    chip("no link", "unlinked", "#c0392b");
    const sk = h("label", { class: "chk" });
    const cb = h("input", { type: "checkbox" });
    cb.checked = st.skips;
    cb.addEventListener("change", () => { st.skips = cb.checked; draw(); });
    sk.append(cb, " skipped ahead");
    bar.appendChild(sk);
    const dl = h("label", { class: "chk" });
    const rg = h("input", { type: "range", min: 1, max: 4, value: st.depth });
    const out = h("span", {}, " rings " + st.depth);
    rg.addEventListener("input", () => { st.depth = +rg.value; out.textContent = " rings " + st.depth; st.focus = null; draw(); });
    dl.append(rg, out);
    bar.appendChild(dl);
    const fb = h("button", { type: "button", class: "chip" }, "fit");
    fb.addEventListener("click", draw);
    bar.appendChild(fb);
    const rb = h("button", { type: "button", class: "chip" }, "reset skills");
    rb.addEventListener("click", () => {
      st.got = new Set(data.nodes.filter(settled).map((n) => n.n));
      draw();
    });
    bar.appendChild(rb);
  }

  function fit() { svg.setAttribute("viewBox", [vb.x, vb.y, vb.w, vb.h].join(" ")); }
  let drag = null, moved = false;
  svg.addEventListener("pointerdown", (e) => { drag = { x: e.clientX, y: e.clientY, vb: { ...vb } }; moved = false; });
  svg.addEventListener("pointermove", (e) => {
    if (!drag) return;
    const k = vb.w / svg.clientWidth;
    const dx = (e.clientX - drag.x) * k, dy = (e.clientY - drag.y) * k;
    if (Math.abs(dx) + Math.abs(dy) > 3 * k) moved = true;
    if (moved) { vb.x = drag.vb.x - dx; vb.y = drag.vb.y - dy; fit(); }
  });
  window.addEventListener("pointerup", () => { drag = null; setTimeout(() => { moved = false; }, 0); });
  svg.addEventListener("click", () => { if (!moved && st.focus !== null) { st.focus = null; draw(); } });
  svg.addEventListener("wheel", (e) => {
    e.preventDefault();
    const box = svg.getBoundingClientRect();
    const f = e.deltaY > 0 ? 1.15 : 1 / 1.15;
    const mx = vb.x + ((e.clientX - box.left) / box.width) * vb.w;
    const my = vb.y + ((e.clientY - box.top) / box.height) * vb.h;
    vb = { x: mx - (mx - vb.x) * f, y: my - (my - vb.y) * f, w: vb.w * f, h: vb.h * f };
    fit();
  }, { passive: false });
  window.addEventListener("keydown", (e) => { if (e.key === "Escape" && st.focus !== null) { st.focus = null; draw(); } });

  controls();
  draw();
})();
