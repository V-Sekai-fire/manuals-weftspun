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
  const st = { depth: 2, focus: null, sphere: null, filter: null, skips: true,
    pos: new Map(), hex: new Map(), route: new Map() };
  const base = document.currentScript ? document.currentScript.src.replace(/[^/]*$/, "") : "assets/";
  const planner = { ask: null, error: null };
  import(base + "persona.mjs")
    .then((m) => m.default({ locateFile: (f) => base + f }))
    .then((mod) => {
      if (mod._persona_init() !== 0) throw new Error("persona_init failed");
      planner.ask = mod.cwrap("persona_plan", "string", ["string"]);
      draw();
      if (planner.onReady) planner.onReady();
    })
    .catch((e) => { planner.error = String(e); draw(); });
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

  const SPHERE_BASE = 900000;
  const sphereId = (tid) => SPHERE_BASE + all.findIndex((t) => t.i === tid) + 1;
  function route(goals) {
    if (!planner.ask || !goals.length) return null;
    const need = new Set();
    goals.forEach((g) => path(g).forEach((m) => need.add(m)));
    const lines = [...need].sort((a, b) => a - b).map((id) =>
      "skill " + id + " " + (done(byN.get(id)) ? 1 : 0) + " " + needs(id).join(" "));
    lines.push("skill 999999 0 " + goals.join(" "), "goal 999999");
    const out = JSON.parse(planner.ask(lines.join("\n")));
    if (!out.plan) return { error: out.refused };
    const order = out.plan.map((s) => +s.replace("activate-", "")).filter((n) => n !== 999999);
    return { order };
  }

  const bar = h("div", { class: "tree-bar" });
  const wallet = h("div", { class: "tree-wallet" });
  const stage = h("div", { class: "tree-stage" });
  const panel = h("aside", { class: "tree-panel" });
  root.append(bar, wallet, stage, panel);
  const svg = mk("svg", { class: "tree-svg", role: "img", "aria-label": "Progress map" });
  stage.appendChild(svg);

  function reduced(vis) {
    const kids = new Map(vis.map((n) => [n.n, needs(n.n)]));
    const reach = new Map();
    const down = (id) => {
      if (reach.has(id)) return reach.get(id);
      const s = new Set();
      reach.set(id, s);
      kids.get(id).forEach((c) => { s.add(c); down(c).forEach((x) => s.add(x)); });
      return s;
    };
    const edges = [];
    vis.forEach((n) => {
      const cs = kids.get(n.n);
      cs.forEach((c) => {
        if (!cs.some((o) => o !== c && down(o).has(c))) edges.push([n.n, c]);
      });
    });
    return edges;
  }

  function crossings(order, links) {
    let total = 0;
    for (let l = 0; l + 1 < order.length; l++) {
      const pos = new Map();
      order[l + 1].forEach((v, i) => pos.set(v, i));
      const seg = links.filter((e) => order[l].includes(e[0]) && pos.has(e[1]))
        .map((e) => [order[l].indexOf(e[0]), pos.get(e[1])]);
      for (let i = 0; i < seg.length; i++) {
        for (let k = i + 1; k < seg.length; k++) {
          if ((seg[i][0] - seg[k][0]) * (seg[i][1] - seg[k][1]) < 0) total++;
        }
      }
    }
    return total;
  }

  function layout() {
    st.pos.clear();
    st.hex.clear();
    st.dummies = new Map();
    const vis = visible();
    const edges = reduced(vis);
    const layer = new Map([[data.goal, 0]]);
    let grew = true;
    while (grew) {
      grew = false;
      for (const [a, b] of edges) {
        if (layer.has(a) && (layer.get(b) || -1) < layer.get(a) + 1) { layer.set(b, layer.get(a) + 1); grew = true; }
      }
    }
    const top = Math.max(...layer.values());
    const links = [];
    st.paths = [];
    let dummy = 0;
    edges.forEach(([a, b]) => {
      const chain = [a];
      for (let l = layer.get(a) + 1; l < layer.get(b); l++) { const id = "d" + dummy++; layer.set(id, l); chain.push(id); }
      chain.push(b);
      for (let i = 0; i + 1 < chain.length; i++) links.push([chain[i], chain[i + 1]]);
      st.paths.push({ a, b, chain });
    });
    let order = [];
    for (let l = 0; l <= top; l++) order.push([...layer].filter((e) => e[1] === l).map((e) => e[0]).sort((p, q) => String(p).localeCompare(String(q), undefined, { numeric: true })));
    const nbr = (id, dir) => links.filter((e) => e[dir ? 0 : 1] === id).map((e) => e[dir ? 1 : 0]);
    let best = order.map((o) => [...o]);
    let bestC = crossings(best, links);
    let seed = 7;
    const rnd = () => { seed = (seed * 16807) % 2147483647; return seed / 2147483647; };
    const start = order.map((o) => [...o]);
    for (let round = 0; round < 24 && bestC > 0; round++) {
      order = start.map((o) => (round ? [...o].sort(() => rnd() - 0.5) : [...o]));
      sweepAll();
      transpose();
      const c = crossings(order, links);
      if (c < bestC) { bestC = c; best = order.map((o) => [...o]); }
    }
    function transpose() {
      let better = true;
      while (better) {
        better = false;
        for (let l = 0; l < order.length; l++) {
          for (let i = 0; i + 1 < order[l].length; i++) {
            const before = crossings(order, links);
            [order[l][i], order[l][i + 1]] = [order[l][i + 1], order[l][i]];
            if (crossings(order, links) < before) better = true;
            else [order[l][i], order[l][i + 1]] = [order[l][i + 1], order[l][i]];
          }
        }
      }
    }
    function sweepAll() {
     for (let sweep = 0; sweep < 12; sweep++) {
      const down = sweep % 2 === 0;
      const ls = down ? [...order.keys()].slice(1) : [...order.keys()].slice(0, -1).reverse();
      ls.forEach((l) => {
        const ref = order[down ? l - 1 : l + 1];
        const bary = new Map(order[l].map((id, i) => {
          const ns = nbr(id, !down).map((x) => ref.indexOf(x)).filter((x) => x >= 0);
          return [id, ns.length ? ns.reduce((s, x) => s + x, 0) / ns.length : i];
        }));
        order[l] = [...order[l]].sort((p, q) => bary.get(p) - bary.get(q));
      });
     }
    }
    order = best;
    st.crossings = bestC;
    const GAP = 130, ROW = 36;
    const y = new Map();
    order.forEach((o) => o.forEach((id, i) => y.set(id, i * ROW)));
    for (let pass = 0; pass < 8; pass++) {
      (pass % 2 ? [...order.keys()].reverse() : [...order.keys()]).forEach((l) => {
        const o = order[l];
        const want = o.map((id) => {
          const ns = [...nbr(id, true), ...nbr(id, false)].map((x) => y.get(x));
          return ns.length ? ns.reduce((s, v) => s + v, 0) / ns.length : y.get(id);
        });
        let last = -Infinity;
        o.forEach((id, i) => { const v = Math.max(want[i], last + ROW); y.set(id, v); last = v; });
        const shift = want.reduce((s, v, i) => s + v - y.get(o[i]), 0) / o.length;
        o.forEach((id) => y.set(id, y.get(id) + shift));
      });
    }
    order.forEach((o, l) => o.forEach((id, i) => {
      const p = { x: y.get(id), y: l * GAP + (o.length > 8 && i % 2 ? 30 : 0) };
      if (typeof id === "number") st.pos.set(id, p);
      else st.dummies.set(id, p);
    }));
    const ys = [...y.values()];
    const lo = Math.min(...ys), hi = Math.max(...ys);
    const mid = (lo + hi) / 2;
    st.pos.forEach((p) => { p.x -= mid; });
    st.dummies.forEach((p) => { p.x -= mid; });
    const half = Math.max((hi - lo) / 2, ((all.length - 1) * 70) / 2);
    const row = top * GAP + 130;
    all.forEach((tk, i) => {
      const x = -half + (i * 2 * half) / Math.max(1, all.length - 1);
      st.hex.set(tk.i, { x, y: row, users: tk.users.filter((u) => st.pos.has(u)) });
    });
    return { x0: -half - 60, x1: half + 60, y0: -70, y1: row + 70 };
  }

  function lit() {
    if (st.sphere !== null) {
      const tk = tokenOf(st.sphere);
      const set = new Set();
      tk.users.filter((u) => byN.has(u)).forEach((u) => path(u).forEach((m) => set.add(m)));
      return set;
    }
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
    st.route = new Map();
    const goals = st.sphere !== null
      ? tokenOf(st.sphere).users.filter((u) => byN.has(u))
      : st.focus !== null ? [st.focus] : [];
    st.plan = goals.length ? route(goals) : null;
    if (st.plan && st.plan.order) st.plan.order.forEach((id, i) => st.route.set(id, i + 1));
    const edges = mk("g", { class: "edges" }, svg);
    const vis = visible();
    for (const pth of st.paths) {
      const skip = skipped(pth.a, pth.b);
      if (skip && !st.skips) continue;
      const pts = pth.chain.map((id) => st.pos.get(id) || st.dummies.get(id));
      let d = "M" + pts[0].x + "," + pts[0].y;
      for (let i = 1; i < pts.length; i++) {
        const p = pts[i - 1], q = pts[i], m = (p.x + q.x) / 2;
        d += " C" + m + "," + p.y + " " + m + "," + q.y + " " + q.x + "," + q.y;
      }
      const dim = on && !(on.has(pth.a) && on.has(pth.b));
      mk("path", { d, class: "edge" + (skip ? " skip" : "") + (dim ? " dim" : "") }, edges);
    }
    if (st.sphere !== null) {
      const hx = st.hex.get(st.sphere);
      for (const u of hx.users) {
        const p = st.pos.get(u);
        mk("path", { d: "M" + hx.x + "," + hx.y + " L" + p.x + "," + p.y, class: "edge sphere" }, edges);
      }
    }
    for (const n of vis) node(n, on);
    for (const t of all) hexagon(t);
    const cap = 1300;
    if (outer.x1 - outer.x0 > cap) {
      const gx = st.pos.get(data.goal).x;
      outer.x0 = gx - cap / 2;
      outer.x1 = gx + cap / 2;
    }
    const w = outer.x1 - outer.x0, hgt = outer.y1 - outer.y0;
    vb = { x: outer.x0, y: outer.y0, w, h: hgt };
    const ratio = svg.clientWidth && svg.clientHeight ? svg.clientWidth / svg.clientHeight : 1.6;
    if (w / hgt < ratio) { const nw = hgt * ratio; vb.x -= (nw - w) / 2; vb.w = nw; }
    else { const nh = w / ratio; vb.y -= (nh - hgt) / 2; vb.h = nh; }
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
    if (st.route.has(n.n)) {
      const bx = r * 0.8, by = -r * 0.8;
      mk("circle", { cx: bx, cy: by, r: 8, class: "step" }, g);
      mk("text", { x: bx, y: by, "text-anchor": "middle", dy: "0.35em", class: "steptext" }, g)
        .textContent = String(st.route.get(n.n));
    }
    const pick = () => { st.sphere = null; st.focus = st.focus === n.n ? null : n.n; draw(); };
    g.addEventListener("click", (e) => { if (!moved) { e.stopPropagation(); pick(); } });
    g.addEventListener("keydown", (e) => { if (e.key === "Enter") pick(); });
  }

  function hexagon(t) {
    const hx = st.hex.get(t.i);
    const open = t.owners.length === 0;
    const pts = [0, 1, 2, 3, 4, 5].map((k) => {
      const a = (Math.PI / 3) * k;
      return Math.cos(a) * 28 + "," + Math.sin(a) * 28;
    }).join(" ");
    const sel = st.sphere === t.i;
    const dim = (st.sphere !== null && !sel) || (st.filter !== null && st.filter !== "unlinked"
      && st.filter !== t.i) || st.focus !== null;
    const g = mk("g", { class: "hexnode" + (open ? " open" : "") + (sel ? " sel" : "")
      + (dim ? " dim" : ""), transform: "translate(" + hx.x + "," + hx.y + ")", tabindex: 0 }, svg);
    mk("title", {}, g).textContent = "Token " + t.i + ": " + t.name
      + (open ? ". No RFD title names it." : "") + " Select it to travel down it.";
    mk("polygon", { points: pts, stroke: color(t.i), fill: color(t.i) + (sel ? "55" : "18") }, g);
    mk("text", { "text-anchor": "middle", dy: "-0.1em" }, g).textContent = t.name.length > 8
      ? t.name.slice(0, 7) + "." : t.name;
    const us = t.users.filter((u) => byN.has(u));
    mk("text", { "text-anchor": "middle", dy: "1.2em", class: "count" }, g).textContent =
      us.filter((u) => done(byN.get(u))).length + "/" + us.length;
    const pick = () => { st.focus = null; st.sphere = sel ? null : t.i; draw(); };
    g.addEventListener("click", (e) => { if (!moved) { e.stopPropagation(); pick(); } });
    g.addEventListener("keydown", (e) => { if (e.key === "Enter") pick(); });
  }

  function coins() {
    wallet.replaceChildren();
    const p = [...path(data.goal)];
    const count = { done: 0, ready: 0, blocked: 0 };
    p.forEach((id) => { count[status(id)]++; });
    const pct = Math.round((count.done / p.length) * 100);
    wallet.appendChild(h("span", { class: "tw-goal" },
      "As of " + data.asof + ", the path to " + short(data.goal) + " is " + pct + "% settled: "
      + count.done + " of " + p.length + " skills done, " + count.ready + " ready, "
      + count.blocked + " blocked. The goal is " + byN.get(data.goal).s + ". Layout: "
      + st.crossings + " edge crossings."));
  }

  function routeList(goalsText) {
    panel.appendChild(h("h4", {}, "Route " + goalsText));
    if (planner.error) {
      panel.appendChild(h("p", { class: "flag" }, "The persona planner did not load: " + planner.error));
      return;
    }
    if (!planner.ask) { panel.appendChild(h("p", {}, "Loading the persona planner...")); return; }
    const p = st.plan;
    if (!p || p.error) { panel.appendChild(h("p", {}, "No route: " + (p ? p.error : "nothing to plan"))); return; }
    panel.appendChild(h("p", {}, p.order.length
      ? p.order.length + " skills to settle, in this order, planned by the persona planner (wasm)."
      : "Everything on this route is settled."));
    const ol = h("ol");
    p.order.slice(0, 12).forEach((id) => {
      const li = h("li");
      const b = h("button", { type: "button", class: "link" }, short(id) + " " + byN.get(id).t);
      b.addEventListener("click", () => { st.sphere = null; st.focus = id; draw(); });
      li.appendChild(b);
      ol.appendChild(li);
    });
    panel.appendChild(ol);
    if (p.order.length > 12) panel.appendChild(h("p", {}, "and " + (p.order.length - 12) + " more"));
  }

  function sphereSide(tk) {
    panel.appendChild(h("h3", {}, tk.name));
    panel.appendChild(h("p", { class: "tp-title" },
      (typeof tk.i === "number" ? "Innovation token " + tk.i : "Boring token") + ". Travel down it to settle every skill that spends it."));
    const users = tk.users.filter((u) => byN.has(u));
    const ok = users.filter((u) => done(byN.get(u))).length;
    panel.appendChild(h("p", { class: "tp-state" }, ok + " of " + users.length + " skills settled"));
    panel.appendChild(h("h4", {}, "RFDs whose title names it"));
    panel.appendChild(h("p", {}, tk.owners.length ? tk.owners.map(short).join(", ") : "none: no link"));
    routeList("down this sphere");
  }

  function side() {
    panel.replaceChildren();
    if (st.sphere !== null) { sphereSide(tokenOf(st.sphere)); return; }
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
    if (st.focus !== null && !done(n)) routeList("to this skill");
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
  svg.addEventListener("click", () => {
    if (!moved && (st.focus !== null || st.sphere !== null)) { st.focus = null; st.sphere = null; draw(); }
  });
  svg.addEventListener("wheel", (e) => {
    e.preventDefault();
    const box = svg.getBoundingClientRect();
    const f = e.deltaY > 0 ? 1.15 : 1 / 1.15;
    const mx = vb.x + ((e.clientX - box.left) / box.width) * vb.w;
    const my = vb.y + ((e.clientY - box.top) / box.height) * vb.h;
    vb = { x: mx - (mx - vb.x) * f, y: my - (my - vb.y) * f, w: vb.w * f, h: vb.h * f };
    fit();
  }, { passive: false });
  window.addEventListener("keydown", (e) => { if (e.key === "Escape") { st.focus = null; st.sphere = null; draw(); } });

  function betaPath() {
    const host = document.getElementById("beta-path");
    if (!host || !data.features) return;
    const dn = (id) => byN.get(id);
    const gates = [2436, 2437, 2438, 2439, 2440];
    const below = (id) => gates.includes(id)
      ? dn(id).c.filter((m) => dn(m) && m !== data.goal && !gates.includes(m))
      : dn(id).c.filter((m) => dn(m) && dn(m).d > dn(id).d);
    const reach = (ids) => {
      const seen = new Set(ids);
      const queue = [...ids];
      while (queue.length) below(queue.shift()).forEach((m) => { if (!seen.has(m)) { seen.add(m); queue.push(m); } });
      return seen;
    };
    const full = data.features.map((f) => reach(f.slices));
    const common = new Set([...full[0]].filter((n) => full.every((s) => s.has(n)) && !gates.includes(n)));
    const order = (ids) => {
      if (!planner.ask) return null;
      const nodes = [...reach(ids)].sort((a, b) => a - b);
      const lines = nodes.map((id) => "skill " + id + " " + (done(dn(id)) ? 1 : 0) + " " + below(id).join(" "));
      lines.push("skill 999999 0 " + ids.join(" "), "goal 999999");
      const out = JSON.parse(planner.ask(lines.join("\n")));
      return out.plan ? out.plan.map((s) => +s.replace("activate-", "")).filter((n) => n !== 999999) : [];
    };
    const spheresOf = (id) => [...dn(id).k, ...dn(id).b].map((i) => tokenOf(i));
    const steps = (list) => {
      const ol = h("ol");
      list.forEach((id) => {
        const li = h("li");
        li.appendChild(h("a", { href: "#" + dn(id).id }, short(id)));
        const sp = spheresOf(id).map((x) => x.name).join(", ");
        li.appendChild(document.createTextNode(" " + dn(id).t));
        const dep = below(id).filter((m) => !gates.includes(m));
        const bits = [];
        if (dep.length) bits.push("after " + dep.slice(0, 3).map((m) => m).join(", ") + (dep.length > 3 ? " and " + (dep.length - 3) + " more" : ""));
        if (sp) bits.push("needs " + sp);
        if (bits.length) li.appendChild(h("span", { class: "bp-dep" }, " (" + bits.join("; ") + ")"));
        ol.appendChild(li);
      });
      return ol;
    };
    const chipsFor = (nodes) => {
      const sph = new Map();
      nodes.forEach((n) => spheresOf(n).forEach((tk) => sph.set(tk.i, (sph.get(tk.i) || 0) + 1)));
      const p = h("p", { class: "bp-chips" });
      [...sph].sort((a, b) => b[1] - a[1]).forEach(([i, n]) => {
        const c = h("button", { type: "button", class: "chip" }, tokenOf(i).name + " " + n);
        c.style.borderColor = color(i);
        c.addEventListener("click", () => {
          st.sphere = i; st.focus = null; controls(); draw();
          document.getElementById("tree").scrollIntoView();
        });
        p.appendChild(c);
      });
      if (!sph.size) p.textContent = "No token named.";
      return p;
    };
    const depLine = (ids) => {
      const direct = [...new Set(ids.flatMap((g) => below(g)))];
      const toks = [...new Set(ids.flatMap((g) => spheresOf(g).map((x) => x.name)))];
      const p = h("p", { class: "bp-sub" });
      p.textContent = "Depends on: "
        + (direct.length ? direct.map((m) => short(m) + " " + dn(m).t).join("; ") : "no skill")
        + (toks.length ? ". Tokens its text names: " + toks.join(", ") + "." : ". No token its text names.");
      return p;
    };
    host.replaceChildren();
    host.appendChild(h("p", { class: "bp-def" },
      "A dependency is something that must be in place before a skill can be settled. A skill is an RFD. "
      + "It depends on the skills it cites, and on the tokens, the technologies, its text names: "
      + "an innovation token is a substrate the stack crashes without, and a boring token is one whose failure stops only a tool or a gate. "
      + "Follow a feature down through its dependencies to the foundation."));
    const top = h("div", { class: "bp-top" });
    top.appendChild(h("h3", {}, short(data.goal) + " " + dn(data.goal).t));
    top.appendChild(h("p", {}, "The beta freeze is cut when every slice gate passes with its control. "
      + gates.filter((g) => done(dn(g))).length + " of " + gates.length + " slices are settled."));
    const gl = h("p", { class: "bp-gates" });
    gates.forEach((g) => gl.appendChild(h("span", { class: "gate " + (done(dn(g)) ? "ok" : "open") },
      g + " " + dn(g).s)));
    top.appendChild(gl);
    host.appendChild(top);

    const base = [...common];
    const baseOpen = base.filter((n) => !done(dn(n)));
    const found = h("section", { class: "bp-card bp-base" });
    found.appendChild(h("h4", {}, "Shared foundation under all four features"));
    found.appendChild(h("p", { class: "bp-text" },
      "Every slice cites RFD66606-2374 and RFD66606-2390, so these skills sit under every feature. "
      + baseOpen.length + " of " + base.length + " are still open."));
    found.appendChild(chipsFor(baseOpen));
    found.appendChild(depLine([2374, 2390].filter((g) => dn(g))));
    const fo = order(base.length ? data.features.flatMap((f) => f.slices) : []);
    const fdet = h("details", {});
    fdet.appendChild(h("summary", {}, "Foundation route, in order"));
    if (fo) fdet.appendChild(steps(fo.filter((n) => common.has(n))));
    found.appendChild(fdet);
    host.appendChild(found);

    const grid = h("div", { class: "bp-grid" });
    data.features.forEach((f, k) => {
      const own = [...full[k]].filter((n) => !common.has(n) && !gates.includes(n));
      const ownOpen = own.filter((n) => !done(dn(n)));
      const card = h("section", { class: "bp-card" });
      card.appendChild(h("h4", {}, f.name));
      card.appendChild(h("p", { class: "bp-text" }, f.text));
      card.appendChild(h("p", { class: "bp-slices" }, "Slice: " + f.slices.map((g) => short(g) + " (" + dn(g).s + ")").join(", ")));
      card.appendChild(depLine(f.slices));
      if (!own.length) {
        card.appendChild(h("p", { class: "flag" },
          "No RFD names a prerequisite of its own for this feature. It stands only on the shared foundation, so its slice is skipped ahead without a link."));
      } else {
        card.appendChild(h("p", { class: "bp-sub" }, ownOpen.length + " of " + own.length + " skills of its own are still open."));
        card.appendChild(chipsFor(ownOpen));
        const o = order(f.slices);
        const det = h("details", {});
        det.appendChild(h("summary", {}, "Its own route, in order"));
        if (o) det.appendChild(steps(o.filter((n) => !common.has(n) && !gates.includes(n))));
        card.appendChild(det);
      }
      grid.appendChild(card);
    });
    host.appendChild(grid);
  }
  planner.onReady = betaPath;
  betaPath();
  controls();
  draw();
})();
