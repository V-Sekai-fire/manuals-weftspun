// Copyright (c) 2026 K. S. Ernest (iFire) Lee
// SPDX-License-Identifier: Apache-2.0 OR MIT
// The interactive progress map: radial rings around the goal, token ledger, settled and ready skills.
(() => {
  const root = document.getElementById("tree");
  const raw = document.getElementById("tree-data");
  if (!root || !raw) return;
  const data = JSON.parse(raw.textContent);
  const NS = "http://www.w3.org/2000/svg";
  const INNOV = ["#e6194b", "#f58231", "#b8860b", "#00a5cf", "#4363d8", "#911eb4", "#008080"];
  const BORE = ["#2e7d32", "#689f38", "#00897b", "#827717"];
  const all = [...data.tokens, ...data.boring];
  const color = (id) => (typeof id === "number" ? INNOV[id - 1] : BORE[+id.slice(1) - 1]);
  const tokenOf = (id) => all.find((t) => t.i === id);
  const byN = new Map(data.nodes.map((n) => [n.n, n]));
  const unlinked = all.filter((t) => t.owners.length === 0);
  const st = { depth: 2, focus: null, filter: null, skips: true, pos: new Map(), hex: new Map() };
  let vb = { x: 0, y: 0, w: 1000, h: 1000 };
  let drag = null, moved = false;

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
  const done = (n) => n.s === "published" || n.s === "committed";
  const visible = () => data.nodes.filter((n) => n.d <= st.depth);
  const needs = (id) => {
    const n = byN.get(id);
    return n ? n.c.filter((m) => byN.has(m) && byN.get(m).d > n.d && byN.get(m).d <= st.depth) : [];
  };
  const neededBy = (id) => visible().filter((m) => needs(m.n).includes(id)).map((m) => m.n);
  const skipped = (a, b) => done(byN.get(a)) && !done(byN.get(b));

  function closure(start, next) {
    const seen = new Set([start]);
    const queue = [start];
    while (queue.length) for (const m of next(queue.shift())) if (!seen.has(m)) { seen.add(m); queue.push(m); }
    return seen;
  }
  const path = (id) => closure(id, needs);
  const status = (id) => {
    if (done(byN.get(id))) return "done";
    return needs(id).every((m) => done(byN.get(m))) ? "ready" : "blocked";
  };
  const share = (id) => {
    const p = [...path(id)];
    return p.filter((m) => done(byN.get(m))).length / p.length;
  };

  const bar = h("div", { class: "tree-bar" });
  const wallet = h("div", { class: "tree-wallet" });
  const stage = h("div", { class: "tree-stage" });
  const panel = h("aside", { class: "tree-panel" });
  root.append(bar, wallet, stage, panel);
  const svg = mk("svg", { class: "tree-svg", role: "img", "aria-label": "Progress map" });
  stage.appendChild(svg);

  function layout() {
    st.pos.clear();
    st.hex.clear();
    const vis = visible();
    st.pos.set(data.goal, { x: 0, y: 0, a: 0 });
    let prev = 0;
    for (let d = 1; d <= st.depth; d++) {
      const ring = vis.filter((n) => n.d === d);
      if (!ring.length) continue;
      const rad = Math.max(prev + 135, (ring.length * 72) / (2 * Math.PI));
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
        st.pos.set(w.n.n, { x: Math.cos(a) * rad, y: Math.sin(a) * rad, a });
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

  function lit() {
    if (st.focus !== null) return new Set([...path(st.focus), ...closure(st.focus, neededBy)]);
    if (st.filter === null) return null;
    const hit = new Set();
    for (const n of visible()) {
      const f = st.filter;
      const ok = ["done", "ready", "blocked"].includes(f)
        ? status(n.n) === f
        : f === "unlinked" ? unlinked.some((t) => n.k.includes(t.i) || n.b.includes(t.i))
        : n.k.includes(f) || n.b.includes(f);
      if (ok) hit.add(n.n);
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
        const skip = byN.get(m).d > n.d && skipped(n.n, m);
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
        mk("line", { x1: hx.x, y1: hx.y, x2: p.x, y2: p.y,
          class: "edge skip" + (on && !on.has(u) ? " dim" : "") }, edges);
      }
    }
    for (const n of vis) node(n, on);
    for (const t of unlinked) hexagon(t);
    const ext = outer + 70;
    vb = { x: -ext, y: -ext, w: ext * 2, h: ext * 2 };
    fit();
    side();
    coins();
  }

  function dots(g, n, r) {
    const slots = [...n.k.map((i) => ({ i, sq: true })), ...n.b.map((i) => ({ i, sq: false }))];
    slots.forEach((s, i) => {
      const a = -Math.PI / 2 + (i * 2 * Math.PI) / 10;
      const x = Math.cos(a) * (r + 8), y = Math.sin(a) * (r + 8);
      if (s.sq) mk("rect", { x: x - 3.5, y: y - 3.5, width: 7, height: 7, fill: color(s.i), class: "dot" }, g);
      else mk("circle", { cx: x, cy: y, r: 3.5, fill: color(s.i), class: "dot" }, g);
    });
  }

  function node(n, on) {
    const p = st.pos.get(n.n);
    const goal = n.n === data.goal;
    const r = goal ? 40 : 20;
    const stat = status(n.n);
    const cls = ["node", n.s, stat, goal ? "goal" : "", data.repos.some((x) => x.n === n.n) ? "repo" : "",
      on && !on.has(n.n) ? "dim" : "", st.focus === n.n ? "focus" : ""].join(" ");
    const g = mk("g", { class: cls, transform: "translate(" + p.x + "," + p.y + ")", tabindex: 0 }, svg);
    const pct = Math.round(share(n.n) * 100);
    mk("title", {}, g).textContent = short(n.n) + ": " + n.t + " (" + n.s + ", " + stat + ", path " + pct + "% settled)";
    const arc = 2 * Math.PI * (r + 4);
    mk("circle", { r: r + 4, class: "ring-track" }, g);
    mk("circle", { r: r + 4, class: "ring-fill", "stroke-dasharray": (arc * pct) / 100 + " " + arc,
      transform: "rotate(-90)" }, g);
    mk("circle", { r, class: "body" }, g);
    mk("text", { "text-anchor": "middle", dy: "0.35em" }, g).textContent = String(n.n);
    dots(g, n, r + 4);
    const pick = () => { st.focus = st.focus === n.n ? null : n.n; draw(); };
    g.addEventListener("click", (e) => { if (!moved) { e.stopPropagation(); pick(); } });
    g.addEventListener("keydown", (e) => { if (e.key === "Enter") pick(); });
  }

  function hexagon(t) {
    const hx = st.hex.get(t.i);
    const pts = [0, 1, 2, 3, 4, 5].map((k) => {
      const a = (Math.PI / 3) * k;
      return Math.cos(a) * 28 + "," + Math.sin(a) * 28;
    }).join(" ");
    const dim = st.filter !== null && st.filter !== "unlinked" && st.filter !== t.i;
    const g = mk("g", { class: "hexnode" + (dim ? " dim" : ""), transform: "translate(" + hx.x + "," + hx.y + ")" }, svg);
    mk("title", {}, g).textContent = "Token " + t.i + ": " + t.name + ". No RFD title names it.";
    mk("polygon", { points: pts, stroke: color(t.i) }, g);
    mk("text", { "text-anchor": "middle", dy: "0.35em" }, g).textContent = t.name;
  }

  function coins() {
    wallet.replaceChildren();
    const row = (label, list, boring) => {
      wallet.appendChild(h("span", { class: "tw-label" }, label));
      list.forEach((t) => {
        const users = t.users.filter((u) => byN.has(u));
        const ok = users.filter((u) => done(byN.get(u))).length;
        const c = h("button", { type: "button",
          class: "boring-coin" + (ok ? " on" : "") + (st.filter === t.i ? " sel" : ""),
          title: t.name + ": settled in " + ok + " of " + users.length + " skills" },
          (boring ? "" : t.i + " ") + t.name + " " + ok + "/" + users.length);
        c.addEventListener("click", () => {
          st.filter = st.filter === t.i ? null : t.i;
          st.focus = null;
          controls();
          draw();
        });
        c.style.borderColor = color(t.i);
        if (ok) c.style.background = color(t.i);
        wallet.appendChild(c);
      });
    };
    row("Innovation tokens", data.tokens, false);
    row("Boring tokens", data.boring, true);
    const p = [...path(data.goal)];
    const count = { done: 0, ready: 0, blocked: 0 };
    p.forEach((id) => { count[status(id)]++; });
    const pct = Math.round((count.done / p.length) * 100);
    wallet.appendChild(h("span", { class: "tw-goal" },
      "As of " + data.asof + ", the path to " + short(data.goal) + " is " + pct + "% settled: "
      + count.done + " of " + p.length + " skills done, " + count.ready + " ready, "
      + count.blocked + " blocked. The goal is " + byN.get(data.goal).s + "."));
  }

  function side() {
    panel.replaceChildren();
    const n = st.focus === null ? byN.get(data.goal) : byN.get(st.focus);
    panel.appendChild(h("h3", {}, short(n.n)));
    panel.appendChild(h("p", { class: "tp-title" }, n.t));
    const stat = status(n.n);
    panel.appendChild(h("p", { class: "tp-state " + stat },
      n.s + ", " + stat + ", " + Math.round(share(n.n) * 100) + "% of its path settled"));
    panel.appendChild(h("h4", {}, "Spends"));
    const tags = h("p", { class: "tp-tags" });
    [...n.k, ...n.b].forEach((i) => {
      const c = h("span", { class: "chip" }, tokenOf(i).name);
      c.style.borderColor = color(i);
      tags.appendChild(c);
    });
    if (!n.k.length && !n.b.length) tags.textContent = "No token on the ledger named.";
    panel.appendChild(tags);
    panel.appendChild(h("h4", {}, "Last changed"));
    panel.appendChild(h("p", {}, n.u || "unknown"));
    panel.appendChild(h("h4", {}, "Logbook evidence (" + n.l.total + ")"));
    if (!n.l.total) panel.appendChild(h("p", {}, "No logbook entry cites it."));
    else {
      const ul = h("ul");
      n.l.latest.forEach(([date, label, id]) => {
        const li = h("li");
        li.appendChild(h("a", { href: "#" + id }, date + " " + label));
        ul.appendChild(li);
      });
      panel.appendChild(ul);
    }
    const list = (label, ids, flag) => {
      if (!ids.length) return;
      panel.appendChild(h("h4", {}, label));
      const ul = h("ul");
      ids.forEach((m) => {
        const b = h("button", { type: "button", class: "link" },
          short(m) + " " + byN.get(m).t + " (" + byN.get(m).s + ")");
        b.addEventListener("click", () => { st.focus = m; draw(); });
        const li = h("li");
        li.appendChild(b);
        if (flag && skipped(n.n, m)) li.appendChild(h("span", { class: "flag" }, " skipped ahead"));
        ul.appendChild(li);
      });
      panel.appendChild(ul);
    };
    list("Blocked by", needs(n.n).filter((m) => !done(byN.get(m))), true);
    list("Needs, settled", needs(n.n).filter((m) => done(byN.get(m))), false);
    list("Needed by", neededBy(n.n), false);
    data.repos.filter((r) => r.n === n.n).forEach((r) => {
      panel.appendChild(h("h4", {}, "Repository"));
      panel.appendChild(h("a", { href: "https://github.com/" + r.repo }, r.repo));
      panel.appendChild(h("p", {}, r.note));
    });
    panel.appendChild(h("p", {})).appendChild(h("a", { href: "#" + n.id, class: "open" }, "Open the RFD"));
  }

  function controls() {
    bar.replaceChildren();
    const chip = (label, key, c) => {
      const b = h("button", { type: "button", class: "chip" + (st.filter === key ? " on" : "") }, label);
      if (c) b.style.borderColor = c;
      b.addEventListener("click", () => { st.filter = st.filter === key ? null : key; st.focus = null; controls(); draw(); });
      bar.appendChild(b);
    };
    chip("done", "done", "#1a5fb4");
    chip("ready", "ready", "#e67e00");
    chip("blocked", "blocked", "#888");
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
  }

  function fit() { svg.setAttribute("viewBox", [vb.x, vb.y, vb.w, vb.h].join(" ")); }
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
