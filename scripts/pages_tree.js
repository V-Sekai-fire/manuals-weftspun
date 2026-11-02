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
  const st = { depth: 4, focus: null, sphere: null, filter: null, skips: true,
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

  const W = 1000, H = 660, BAN = 58;
  svg.setAttribute("viewBox", "0 0 " + W + " " + H);

  function squarify(items, x, y, w, h) {
    const out = [];
    const rest = [...items];
    const total = rest.reduce((s, i) => s + i.v, 0) || 1;
    const scale = (w * h) / total;
    const worst = (row, side) => {
      const s = row.reduce((a, i) => a + i.v * scale, 0);
      return Math.max(...row.map((i) => Math.max((side * side * i.v * scale) / (s * s), (s * s) / (side * side * i.v * scale))));
    };
    while (rest.length) {
      const side = Math.min(w, h);
      const row = [rest.shift()];
      while (rest.length && worst([...row, rest[0]], side) <= worst(row, side)) row.push(rest.shift());
      const area = row.reduce((a, i) => a + i.v * scale, 0);
      if (w >= h) {
        const cw = area / h;
        let cy = y;
        row.forEach((i) => { const ch = (i.v * scale) / cw; out.push({ it: i, x, y: cy, w: cw, h: ch }); cy += ch; });
        x += cw; w -= cw;
      } else {
        const ch = area / w;
        let cx = x;
        row.forEach((i) => { const cw = (i.v * scale) / ch; out.push({ it: i, x: cx, y, w: cw, h: ch }); cx += cw; });
        y += ch; h -= ch;
      }
    }
    return out;
  }

  function lit() {
    if (st.focus !== null) return new Set([...path(st.focus), ...closure(st.focus, neededBy)]);
    if (st.sphere !== null) {
      const set = new Set();
      tokenOf(st.sphere).users.filter((u) => byN.has(u)).forEach((u) => path(u).forEach((m) => set.add(m)));
      return set;
    }
    if (st.filter === null) return null;
    const hit = new Set();
    for (const n of visible()) {
      const f = st.filter;
      const ok = ["done", "ready", "blocked"].includes(f)
        ? status(n.n) === f
        : f === "unlinked" ? all.some((t) => t.owners.length === 0 && (n.k.includes(t.i) || n.b.includes(t.i)))
        : n.k.includes(f) || n.b.includes(f);
      if (ok) hit.add(n.n);
    }
    return hit;
  }

  function draw() {
    svg.replaceChildren();
    const on = lit();
    const vis = visible().filter((n) => n.n !== data.goal);
    const size = new Map(all.map((tk) => [tk.i, tk.users.filter((u) => vis.some((n) => n.n === u)).length]));
    const groups = new Map();
    vis.forEach((n) => {
      const tags = [...n.k, ...n.b];
      const g = tags.length ? [...tags].sort((p, q) => size.get(q) - size.get(p))[0] : "none";
      if (!groups.has(g)) groups.set(g, []);
      groups.get(g).push(n);
    });
    st.route = new Map();
    const goals = st.sphere !== null ? tokenOf(st.sphere).users.filter((u) => byN.has(u))
      : st.focus !== null ? [st.focus] : [];
    st.plan = goals.length ? route(goals) : null;
    if (st.plan && st.plan.order) st.plan.order.forEach((id, i) => st.route.set(id, i + 1));
    const dep = st.focus !== null ? closure(st.focus, needs) : new Set();
    const by = st.focus !== null ? closure(st.focus, neededBy) : new Set();

    const gn = byN.get(data.goal);
    const gg = mk("g", { class: "tm-goal " + status(data.goal) + (st.focus === data.goal ? " focus" : ""), tabindex: 0 }, svg);
    mk("rect", { x: 0, y: 0, width: W, height: BAN - 6, rx: 6 }, gg);
    mk("text", { x: 14, y: 24, class: "tm-gt" }, gg).textContent = short(data.goal) + "  " + gn.t;
    mk("text", { x: 14, y: 44, class: "tm-gs" }, gg).textContent =
      "the goal, " + gn.s + ": settled when every territory below is settled";
    gg.addEventListener("click", (e) => { e.stopPropagation(); st.sphere = null; st.focus = st.focus === data.goal ? null : data.goal; draw(); });

    const items = [...groups].map(([g, ms]) => ({ g, ms, v: ms.length }))
      .sort((p, q) => q.v - p.v);
    squarify(items, 0, BAN, W, H - BAN).forEach((r) => {
      const { g, ms } = r.it;
      const tk = g === "none" ? null : tokenOf(g);
      const c = tk ? color(g) : "#999";
      const sel = st.sphere === g;
      const dimT = (st.sphere !== null && !sel) || (st.filter !== null && on && !ms.some((n) => on.has(n.n)));
      const zone = mk("g", { class: "tm-zone" + (dimT ? " dim" : "") + (sel ? " sel" : "") }, svg);
      mk("rect", { x: r.x + 1, y: r.y + 1, width: r.w - 2, height: r.h - 2, fill: c, "fill-opacity": 0.1, stroke: c,
        "stroke-width": sel ? 3 : 1.5, "stroke-dasharray": tk && tk.owners.length === 0 ? "6 4" : "none" }, zone);
      const ok = ms.filter((n) => done(n)).length;
      const head = mk("g", { class: "tm-head" }, zone);
      mk("rect", { x: r.x + 1, y: r.y + 1, width: r.w - 2, height: 20, fill: c, "fill-opacity": 0.28 }, head);
      mk("text", { x: r.x + 6, y: r.y + 15, class: "tm-ht" }, head).textContent =
        (tk ? (typeof g === "number" ? g + " " : "") + tk.name : "No token named") + "  " + ok + "/" + ms.length;
      if (tk) {
        head.addEventListener("click", (e) => {
          e.stopPropagation();
          st.focus = null; st.sphere = sel ? null : g; draw();
        });
      }
      const inner = squarify([...ms].sort((p, q) => p.d - q.d || p.n - q.n).map((n) => ({ n, v: 1 })),
        r.x + 4, r.y + 24, r.w - 8, r.h - 28);
      inner.forEach((cell) => {
        const n = cell.it.n;
        const stat = status(n.n);
        const skip = st.skips && done(n) && needs(n.n).some((m) => !done(byN.get(m)));
        const dim = on && !on.has(n.n);
        const cls = ["tm-cell", n.s, stat, skip ? "skip" : "", dim ? "dim" : "",
          st.focus === n.n ? "focus" : "", dep.has(n.n) && n.n !== st.focus ? "dep" : "",
          by.has(n.n) && n.n !== st.focus ? "by" : "",
          data.repos.some((x) => x.n === n.n) ? "repo" : ""].join(" ");
        const cg = mk("g", { class: cls, tabindex: 0 }, svg);
        mk("title", {}, cg).textContent = short(n.n) + ": " + n.t + " (" + n.s + ", " + stat + ")";
        mk("rect", { x: cell.x + 1.5, y: cell.y + 1.5, width: Math.max(2, cell.w - 3), height: Math.max(2, cell.h - 3), rx: 3 }, cg);
        if (cell.w > 26 && cell.h > 16) {
          mk("text", { x: cell.x + cell.w / 2, y: cell.y + cell.h / 2, "text-anchor": "middle", dy: "0.35em" }, cg).textContent = String(n.n);
        }
        [...n.k, ...n.b].filter((i) => i !== g).slice(0, 6).forEach((i, q) => {
          const dx = cell.x + cell.w - 7 - q * 7, dy = cell.y + 6;
          if (typeof i === "number") mk("rect", { x: dx - 3, y: dy - 3, width: 6, height: 6, fill: color(i), class: "dot" }, cg);
          else mk("circle", { cx: dx, cy: dy, r: 3, fill: color(i), class: "dot" }, cg);
        });
        if (st.route.has(n.n)) {
          mk("circle", { cx: cell.x + 10, cy: cell.y + 10, r: 8, class: "step" }, cg);
          mk("text", { x: cell.x + 10, y: cell.y + 10, "text-anchor": "middle", dy: "0.35em", class: "steptext" }, cg).textContent = String(st.route.get(n.n));
        }
        const pick = () => { st.sphere = null; st.focus = st.focus === n.n ? null : n.n; draw(); };
        cg.addEventListener("click", (e) => { e.stopPropagation(); pick(); });
        cg.addEventListener("keydown", (e) => { if (e.key === "Enter") pick(); });
      });
    });
    side();
    coins();
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
      + count.blocked + " blocked. The goal is " + byN.get(data.goal).s + "."));
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

  svg.addEventListener("click", () => {
    if (st.focus !== null || st.sphere !== null) { st.focus = null; st.sphere = null; draw(); }
  });
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
  function journey() {
    const host = document.getElementById("journey");
    if (!host) return;
    const dn = (id) => byN.get(id);
    const gates = [2436, 2437, 2438, 2439, 2440];
    const nodes = [...closure(data.goal, needs)].filter((n) => n !== data.goal);
    const open = nodes.filter((n) => !done(dn(n)));
    const wave = new Map();
    const level = (id) => {
      if (wave.has(id)) return wave.get(id);
      wave.set(id, 1);
      const w = 1 + Math.max(0, ...needs(id).filter((m) => !done(dn(m))).map(level));
      wave.set(id, w);
      return w;
    };
    open.forEach(level);
    const top = Math.max(1, ...open.map((n) => wave.get(n)));
    const doneIds = nodes.filter((n) => done(dn(n))).sort((a, b) => a - b);
    const early = doneIds.filter((n) => needs(n).some((m) => !done(dn(m))));
    const seen = new Set();
    host.replaceChildren();
    host.appendChild(h("p", { class: "bp-def" }, "The journey to " + short(data.goal) + ", " + dn(data.goal).t
      + ". An RFD that is committed counts as complete, whatever order it landed in. Each step right needs the steps before it. "
      + doneIds.length + " of " + nodes.length + " skills are committed, " + open.length + " remain."));
    const track = h("div", { class: "jr-track" });
    const col = (title, sub, cls) => {
      const c = h("section", { class: "jr-col " + cls });
      c.appendChild(h("h4", {}, title));
      c.appendChild(h("p", { class: "jr-sub" }, sub));
      track.appendChild(c);
      return c;
    };
    const chip = (id, c) => {
      const n = dn(id);
      const a = h("a", { class: "jr-chip " + (done(n) ? "done" : status(id)), href: "#" + n.id,
        title: short(id) + ": " + n.t + " (" + n.s + ")" }, id + " " + n.t);
      const first = [...n.k, ...n.b][0];
      if (first !== undefined) a.style.borderLeftColor = color(first);
      c.appendChild(a);
    };
    const dc = col("Committed", doneIds.length + " done" + (early.length ? ", " + early.length + " landed before something they need" : ""), "jr-done");
    doneIds.forEach((id) => {
      chip(id, dc);
      if (early.includes(id)) dc.lastChild.classList.add("early");
    });
    for (let w = 1; w <= top; w++) {
      const ids = open.filter((n) => wave.get(n) === w).sort((a, b) => a - b);
      const fresh = new Set();
      ids.forEach((id) => [...dn(id).k, ...dn(id).b].forEach((i) => { if (!seen.has(i)) { seen.add(i); fresh.add(i); } }));
      const sub = ids.length + " skills" + (fresh.size ? ", opens " + [...fresh].map((i) => tokenOf(i).name).join(", ") : "");
      const c = col(w === 1 ? "Next: ready now" : "Then, step " + w, sub, w === 1 ? "jr-now" : "");
      ids.forEach((id) => chip(id, c));
    }
    const end = col(short(data.goal), "beta freeze: " + gates.filter((g) => done(dn(g))).length + " of " + gates.length + " slice gates committed", "jr-end");
    gates.forEach((g) => chip(g, end));
    host.appendChild(track);
  }
  planner.onReady = () => { betaPath(); };
  journey();
  const _bp = betaPath;

  betaPath();
  controls();
  draw();
})();

