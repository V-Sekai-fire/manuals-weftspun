# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2304, "one Lean 4 RECTGTN library generates the planner", :discussion do
  flight_level :l2
  feature "the planner's only implementation is one Lean 4 library that generates the NIF's C"
  scope "`taskweft_nif`, interactor-taskweft's `lean/` and its copy in weft-warp-burrito,
xr-pilot's `Plan.lean`, the FBD compiler's plan input and RFD 2292's gate"

  prose ~S"""
  :: decision
  One Lean 4 library is the single implementation of RECTGTN, the
  Relationship-Enabled Capability-Temporal Goal-Task-Network planner. It holds
  the types, the search, ReBAC and the theorems, and generates the C planner
  through `V-Sekai-fire/trust-lean`: Lean at build time and flat C shipped, the
  shape of RFD 2044. Elixir is one user, and its NIF glue (entry points, term
  conversion, the function table) is a small trusted C shim with a size
  budget. The domain loader and expression evaluator use doubles, trig and
  `math/random`, so they stay hand-written C++ checked against the Lean
  reference until Trust-Lean carries floats. xr-pilot, the FBD compiler and
  RFD 2292's `mix rfd.rectgtn` consume the same library. No C++ search is
  deleted before the equivalence check in `DETAILS.md` passes with its
  negative controls (operator, 2026-10-05).
  :: problem
  RECTGTN is written more than once, and the copies disagree. `taskweft_nif`
  0.2.0-dev.20 is C++ with no proofs. interactor-taskweft's `lean/Planner`,
  copied byte for byte into weft-warp-burrito, has proofs and no search,
  loader or C ABI. xr-pilot's `Plan.lean` acts without planning, and
  RFD 2292 expands plans by hand in Elixir. Where Lean and C++ overlap they
  differ on the goal test, the relation set, `check_rel` fuel and ReBAC
  definitions, so a theorem about one says nothing about the other.
  :: related
  - RFD 2044, Lean at build time and a flat C ABI at run time; RFD 2032,
    the same shape for GPU kernels through lean-slang.
  - RFD 2292, the organization as one RECTGTN domain, whose gate plans
    through `Taskweft.NIF.plan/1`.
  """

  details_title "one Lean 4 RECTGTN library generates the planner"

  prose ~S"""
  :: details The implementations, and what each brings
  - **`taskweft_nif` 0.2.0-dev.20**, C++, built from `V-Sekai-fire/nif` at
    tag `v0.2.0-dev.20` (758dc2a). weft-warp-burrito's `taskweft_nif/`
    subtree at e0507a7 is the placed copy, byte-identical to the Hex tarball.
    It brings the behaviour every caller sees: the search (method dispatch,
    backtracking, multigoal binding order, fuel, the fail cache, replan and
    explain) and the loader and evaluator. It gives up its hand-written
    search (`tw_planner.hpp`, `tw_replan.hpp`, `tw_soltree.hpp`,
    `tw_explain.hpp`, `tw_domain.hpp`) to generated C, its Fine wrapper to
    the C shim, and the 11 of its 23 NIF functions no workspace code calls.
  - **interactor-taskweft's `lean/`** brings the proofs: ReBAC check and
    expand with kernel-checked fuel monotonicity, the Floyd–Warshall temporal
    check, the fail-cache theorem, and the KHR Tier 1 witness vectors its
    tests compare against the C++. Those proofs move into the library or
    are imported by it, and the tree gives up its own semantics wherever
    they differ from dev.20.
  - **weft-warp-burrito's `taskweft/lean`** is a byte-identical copy that no
    CI builds. It brings nothing and goes.
  - **xr-pilot's `lean/XrPilot/Plan.lean`** acts: it runs each action as an
    MCP tool call, takes the first alternative whose checks hold, and does
    not roll back. It keeps that loop and takes its task-network types and
    parser from the library. xr-pilot is a Lean program, so it imports the
    library as a Lake package rather than through the C ABI.
  - **The FBD compiler's `TaskweftFbdCompiler.lean`** searches nothing. It
    lifts a plan's set and hold sequence into a scan controller, keeps that
    lift, and takes its plan input type from the library.
  - **RFD 2292's `RFD.RECTGTN.plan/1`** expands a plan by hand in Elixir,
    and `scripts/check_rectgtn_plan.exs` holds the expansion against
    `Taskweft.NIF.plan/1`. The expansion goes; the gate reads the NIF, which
    runs the generated planner.
  :: details Where Lean and C++ disagree, dev.20 decides
  Every caller runs dev.20 or dev.16, so the library takes dev.20's
  semantics where the two sides differ, and each theorem is restated
  against them:

  - Goal test: Lean's `goal_geq` is a threshold; dev.20 tests equality.
  - Relations: Lean's `RelationType` is a closed enum; dev.20 takes any
    relation string in `tw_rebac.hpp`, which RFD 2204's `CAN_ENTER` and
    `CAN_INSTANCE` need.
  - `check_rel` fuel: the two count fuel one apart, so an input at the
    boundary answers false in Lean and true in C++.
  - ReBAC definitions: Lean evaluates them; dev.20 stores them and ignores
    them.

  dev.20's fail cache is keyed without fuel, which makes the search
  incomplete: a problem can return `no_plan` that a build without the cache
  solves, against the `ValidCache` assumption `FailCache.lean` rests on. The
  generated planner reproduces that output byte for byte. Keying the cache
  by fuel is a versioned change of its own after M5, with the cases it
  changes as its acceptance test and a logbook entry.
  :: details What the NIF is made of
  - **The search, generated.** The search headers hold no `double`. The
    library writes the search as an explicit-stack machine over an arena,
    since Trust-Lean's call proofs cover only non-recursive bodies, and
    Trust-Lean emits it as C through its MicroC path. The machine returns to
    its caller whenever it needs the domain (apply an action, expand a
    method, test a goal, key a state) and resumes from the arena. Strings
    reach it as interned integers.
  - **The loader and evaluator, hand-written.** `tw_loader.hpp` evaluates
    doubles, trig and a non-deterministic `math/random` node; `tw_json`,
    `tw_value`, `tw_state`, `tw_temporal`'s durations and `plan_to_json`
    sit beside it. Trust-Lean's `Value` is an integer or a boolean, so this
    C++ stays and answers the machine's requests. A Lean reference evaluator
    checks it end to end.
  - **The shim, trusted.** Plain C over `erl_nif.h`: the entry points, term
    conversion and function table for the 12 NIFs with a caller. Its budget
    is the line count of the Fine wrapper it replaces, `c_src/taskweft_nif.cpp`
    at dev.20, and a gate in `V-Sekai-fire/nif` fails a shim past it, with a
    padded shim as the negative control.

  Each dev.20 NIF registers with flags 0, so a plan can hold a regular
  scheduler for its whole 5 s budget. The shim runs the machine in slices,
  charges each one with `enif_consume_timeslice`, and reschedules itself
  with `enif_schedule_nif` when the slice is spent, so a long plan shares
  the scheduler. The 5 s budget is checked between slices. Plans keep their
  bytes; other processes on that scheduler wait less.
  :: details The equivalence check
  The oracle is Hex `taskweft_nif` 0.2.0-dev.20, pinned by the checksum in
  interactor-taskweft's `mix.lock`. The goldens are not the oracle, because
  some pin `[]` for problems the planner solves. Two paths are checked
  apart: `tw_plan` behind plan, plan_with_temporal and replan, and
  `tw_plan_with_tree`, which spends fuel on every task and has no fast
  path, behind the explain NIFs.

  - **Level 1, C against C++.** One test binary loads each domain once with
    the dev.20 loader and runs both `tw_seek_plan` and the candidate search.
    It compares status, plan bytes and the request trace, every method,
    action and goal query with its arguments, since a trace catches
    search-order drift that equal plans hide. A shadow table with full keys
    counts fail-cache hash collisions.
  - **Level 2, Lean against the NIF.** `rectgtn_ref`, a Lean executable run
    only in CI, compares bytes with the NIF end to end. Its replay mode
    drives the Lean search from transcripts recorded from the C++, so search
    control is checked before the Lean evaluator covers every node.

  The corpus is enumerated where its population is fixed: the runnable
  goldens with domains recovered from `b315766^` and `22daccd^`, the DSL
  domains through `Taskweft.Compose`, RFD 2292's problems, the
  `use Taskweft.DSL` documents in the workspace, and the KHR Tier 1
  vectors. Generated blocks-world goal, multigoal and call problems state
  their detection floor of about 3/n, and a fuel family sits at the
  `TW_MAX_DEPTH` boundary. Runs that hit the 5 s budget, domains that use
  `math/random`, and detected hash collisions are counted as unchecked and
  published beside the pass count.

  The negative controls, each a dev.20 build patched one way, measured by
  the prototype harness on 2026-10-05 over 525 cases:

  - goal re-queue removed: 112 cases change;
  - both caches removed: 34 change, 19 of them inside the 5 s budget, each
    a dev.20 `no_plan` that the variant solves;
  - `TW_MAX_DEPTH` at 399: 11 change;
  - a golden truncated by one step: rejected.

  Removing best-first method reordering or the success cache changes 0 of
  525, so neither is a control. The library leaves both out, and a theorem
  states that neither can change output.

  No C++ is deleted until both levels show 0 differences on the corpus,
  every control fires on at least one case, and the unchecked counts sit in
  the same table.
  :: details Callers
  - At identical bytes no caller changes source: interactor-taskweft's CLI
    and MCP server, weftspun-studio, weftspun-character-taxonomy,
    taskweft-function-block-diagram-teacher through `taskweft_rebac`, and
    RFD 2292's gate.
  - weftspun-studio, weftspun-character-taxonomy, taskweft-godot-sandbox,
    taskweft-nmm-personas and taskweft-function-block-diagram-teacher lock
    dev.16. They move to dev.20 first, so the oracle is the version they
    run. That move changes plans for any domain that declares capabilities:
    dev.16 routes every goal binding through ReBAC when a capability graph
    exists, and f4457e5 in `V-Sekai-fire/nif` routes only ReBAC bindings.
  - The NIF yields between slices, as above.
  - The 11 NIFs no workspace code calls leave in a deprecation release of
    their own, because a Hex package can have callers outside the workspace.
  - datasource-queen, interactor-ward and two guest ELF repositories
    include the C++ headers directly. None is placed, so they keep building
    against dev.20's headers and sit outside this change.
  - Three defects sit outside this change and are named so they do not read
    as regressions: interactor-taskweft's `server.ex` raises `MatchError` on
    `{:error, "no_plan"}`; weftspun-studio's `steps/1` rejects the shape
    `replan` returns; taskweft-nmm-personas calls `Taskweft.Grafcet`, a
    module interactor-taskweft does not carry.
  :: details Milestones
  - **M1, the harness**, in `V-Sekai-fire/nif`. The prototype differential
    script becomes an in-process ExUnit `:differential` job: the dev.20
    headers linked twice, the request trace, a corpus enumerator and the
    unchecked counter. It needs neither Trust-Lean nor its licence. Exit:
    the job runs in under 5 minutes, the three live controls each fire on
    at least one case, and budget hits are counted.
  - **M2, the Lean search.** `Rectgtn.Search`, Mathlib-free, reproduces
    every output-changing behaviour of dev.20's `tw_seek_plan`, and replays
    recorded transcripts. Its theorems: a returned plan replays to the goal,
    the fuel bound, the irrelevance of reordering and the success cache, and
    the fail cache's incompleteness stated from a measured case. Exit: 0
    trace and plan differences.
  - **M3, the Lean evaluator.** A reference loader and evaluator, Float
    included. Exit: `rectgtn_ref` matches the NIF's bytes on the corpus,
    with `math/random` domains counted as unchecked.
  - **M4, the generated search.** Trust-Lean emits the machine, the C is
    committed, and a regenerate-and-diff gate fails on drift. A refinement
    theorem states that the emitted machine simulates `Rectgtn.Search`
    under any oracle. The C shim replaces the Fine wrapper and yields.
    `taskweft_nif` 0.3.0-dev ships it. Exit: 0 differences at both levels,
    and warm medians within 1.2 times dev.20's.
  - **M5, the hand-written search retires.** The C++ search and the Fine
    wrapper are deleted, weft-warp-burrito's copy of `lean/` goes,
    `taskweft_nif` 0.3.0 ships, and xr-pilot, the FBD compiler and RFD 2292's gate read the
    library. Exit: plan bytes unchanged for every caller, and
    interactor-taskweft's CI green.
  - **M6, the rest.** The ReBAC walk moves to generated C. The temporal
    check, the loader and the evaluator use doubles and follow when
    Trust-Lean carries floats; the C++ in the NIF then reaches zero.
  :: details Dependencies
  - **Licence.** `V-Sekai-fire/trust-lean` carries no licence file on its
    default branch; its pull request 2 adds MIT and is a draft.
  - **Allowlist.** Pull request 232 here adds rows for Trust-Lean and for
    Mathlib at build time.
  - **Placement.** Pull request 283 on `contract-manifest-taskweft` places
    Trust-Lean on the contract side. `V-Sekai-fire/nif`, which publishes
    the Hex package, is not placed.
  - **The TL4 to TL8 fix chain** on the fork. The library needs from it
    local declarations in the C backend, so the emitted code is reentrant
    across schedulers; bounded arrays or proved capacity invariants;
    `Value.int` agreeing with the emitted `int64_t`; a Mathlib-free split
    of Core and the C backend; and, for M6, floats. No branch or pull
    request on the fork carries TL4 to TL8 yet. Fixes land on the fork and
    go nowhere else.
  - **RFD 2292** sits on the parked branch `feat/evac-20261002-rfd-2292` and
    holds no serial on main, so its gate joins M5 once it lands.
  - **Toolchain.** Trust-Lean with its Mathlib, and interactor-taskweft's
    `lean/`, pin Lean v4.30.0; xr-pilot pins v4.34.1 and the FBD compiler v4.34.0-rc1. A
    Lake dependency needs one toolchain, so those two import the library
    once the pins agree.
  :: details Open questions
  - **Home.** The Lean search, the generated C and its drift gate want one
    repository. `V-Sekai-fire/nif` holds the NIF and is not placed;
    interactor-taskweft holds the Lean tree its CI builds. A new repository
    takes RFD 2111's `<type>-<name>` shape.
  - **contract-zone-backend.** `Uro.Planner.ElixirAdapter` is a pure-Elixir
    port of the C++ search without capabilities, enums, floats or most KHR
    nodes, and that repository's ADR 0038 removes native code on purpose.
    Whether it moves onto the library or runs the corpus as a third
    implementation is the operator's call.
  """
end
