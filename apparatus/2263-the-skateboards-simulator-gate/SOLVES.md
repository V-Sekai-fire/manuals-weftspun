<!-- SPDX-License-Identifier: MIT -->
<!-- Copyright (c) 2026 K. S. Ernest (iFire) Lee -->

# Cached solves

GENERATED. The taskweft planner derived every row below from `domain.ex` plus
each rung's `problem.ex`. The order is not written in any source file; it is
solved from the action guards. Regenerate against the pinned solver rather than
editing by hand.

- Solver: `taskweft_nif 0.2.0-dev.20`
- Reference date: `2026-09-26T00:00:00-07:00`
- Origin: `PT0S`
- Machine-readable copies: `rung1_mesh.solve.json`, `rung2_closed_solid.solve.json`, `rung3_garment.solve.json` (full plan + temporal block).

The domain on its own does not solve. Its `have` init sets `strokes: false`, so
`a_curvenet`'s guard is unmet and `Taskweft.plan` returns `no_plan`. A rung's
`problem.ex` supplies the stroke fixture (`strokes: true`) and names the target
artifact, never the steps. That is the point of the ladder: the solver is never
told the answer.

## rung 1 — mesh (`/have/mesh`)

Total `PT7M`, temporally consistent. Shippable now (RFD 2263 Phase A replay gate).

| # | action | start | end | duration |
|---|--------|-------|-----|----------|
| 1 | a_curvenet | PT0S | PT2M | PT2M |
| 2 | a_mesh | PT2M | PT7M | PT5M |

## rung 2 — closed solid (`/have/closed_solid`)

Total `PT17M`, temporally consistent.

| # | action | start | end | duration |
|---|--------|-------|-----|----------|
| 1 | a_curvenet | PT0S | PT2M | PT2M |
| 2 | a_mesh | PT2M | PT7M | PT5M |
| 3 | a_repair | PT7M | PT12M | PT5M |
| 4 | a_close | PT12M | PT17M | PT5M |

## rung 3 — garment (`/have/garment`)

Total `PT42M`, temporally consistent. The full pipeline, and the domain's own
default goal. `a_drape` is GPU work behind a `rebac/check` `may-use--gpu` guard:
drop that edge from the capabilities graph and this rung returns `no_plan` while
rung 1 still solves.

| # | action | start | end | duration |
|---|--------|-------|-----|----------|
| 1 | a_curvenet | PT0S | PT2M | PT2M |
| 2 | a_mesh | PT2M | PT7M | PT5M |
| 3 | a_repair | PT7M | PT12M | PT5M |
| 4 | a_close | PT12M | PT17M | PT5M |
| 5 | a_drape | PT17M | PT37M | PT20M |
| 6 | a_deliver | PT37M | PT42M | PT5M |
