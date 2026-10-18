# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2323, "frontier learning picks the store's adversarial runs", :discussion do
  feature "the SQLite on FoundationDB store's crash, fence and cluster attacks are levels whose
regret is measured on a planted defect, and a clean run on the real store counts only after its
attack is shown to find that defect"
  scope "the store's attack programs and `qa/` cluster runs, a level scheduler beside the crash
search in `witness/`, and the run records it keeps"

  prose ~S"""
  :: decision
  The store's attacks are levels in RFD 2309's sense: an attack template
  with fixed attributes (fault, commit size, writers, redundancy). A problem
  is one run with a drawn crash point, delay or seed. Each level runs on the
  store as it is, and on the store with that level's defect planted.

  On the planted target, success is a witness found. Regret `1[s ≥ 1] − s/n`
  is high when the attack finds the defect only some of the time, so the
  level is measuring luck. Mutation moves one attribute and is kept only
  when the planted kill rate rises. A clean run on the real store counts
  only after its level killed the planted defect in each of its last eight
  runs, or the crash search covered its whole space. A witness on the real
  store is a defect, and it becomes a permanent level.
  :: problem
  A clean run cannot say whether the store is sound or the attack is weak.
  The cluster run's negative control left all 200 keys readable under single
  redundancy, so its zone kill is uncontrolled. Against a sound store every
  level scores zero, so regret on the real store alone gives no signal.
  :: related
  - RFD 2309, frontier learning for the alyx planner: the loop this reuses.
  - RFD 2109, two tiers with FoundationDB as the store: the store attacked.
  """

  details_title "levels, targets and the controls on the scheduler"

  prose ~S"""
  :: details Sources
  Drafted on 2026-10-18 from the store's main branch as read that day: the
  attack programs, the commit stage script, the soak script, `qa/README.md`
  and the crash search in `witness/CrashSearch.lean`. The operator's request
  was to apply frontier learning to adversarial testing of SQLite on
  FoundationDB.

  :: details Why one target gives no signal
  RFD 2309's learner is a policy that sometimes succeeds. Here the learner is
  the attack, and its success is a witness: a torn commit, a lost key, a
  superseded writer whose write landed, or a cluster that answered without a
  quorum. A sound store gives every level `s = 0`, so every level reads as
  impossible and regret is zero everywhere. That is the result we want from
  the store, and it teaches the attack nothing.

  The planted target restores the gradient. It is the same build with one
  defect switched on, so a level's kill rate on it is how well that attack
  finds that defect. A level between none and all of its runs is the frontier
  the paper samples from.

  :: details The levels
  | Level | Planted defect | Witness |
  |---|---|---|
  | crash at a commit | one transaction per page write | two distinct row values |
  | kill at a delay | one transaction per page write | two distinct row values |
  | fence read | `WEFT_PLANT_STALE_VIEW=1` | a stale read accepted |
  | superseded writer | the fence check skipped | a superseded write lands |
  | handoff | the commit kept in the writer's cache | the reader sees fewer rows |
  | parallel commit | two databases as two transactions | a grant lost or doubled |
  | zone kill | `single` redundancy | a key that does not read |
  | quorum loss | none yet | a write accepted without quorum |
  | loss and restore | the restore skipped | zero keys after restore |

  The attributes: rows and a crash point or delay band for crash and kill;
  readers and cache for fence read; connections for the superseded writer;
  grants and a crash point band for the parallel commit; keys, shards and an
  aimed or named zone for the zone kill.

  Only the stale view and `single` redundancy exist as switches today. The
  others are new planted switches, each inert unless its variable is set, in
  the same shape as `WEFT_PLANT_STALE_VIEW`. A level with no planted defect
  cannot be calibrated, and the report counts it under that name.

  :: details What each class does
  - Unknown, never run: one is explored per change, oldest first.
  - Frontier on the planted target, between none and all of the window: the
    soak lane runs it, and mutation proposes one neighbour.
  - Blind on the planted target, none of the window: the attack cannot see
    its defect. It is not rerun until the attack changes.
  - Calibrated, all of the last eight on the planted target: it runs on the
    real store. Its regret is zero on both targets, so the per change lane
    picks by RFD 2309's staleness term per second of cost, within budget.
  - Proven, the crash search reported that it covered every candidate: it
    leaves the per change lane and runs before a release.
  - A witness on the real store is never averaged into a rate. It stops the
    lane, keeps its database under its own name, and becomes an escape row
    and a level that runs on every change.

  :: details Mutation
  One attribute moves per proposal, to the neighbour the frontier needs.
  For the zone kill: more data until it spans several shards, then a kill
  aimed at the team that holds the keys, which is the fix `qa/README.md`
  names for the uncontrolled control. For a crash or kill: a narrower band
  around the points where witnesses were found, and the next commit size in
  the crash search's list. For a parallel commit: a band around the two crash
  points the protocol is built around. For fence, superseded writer and
  handoff: one more reader, connection or row batch. A proposal is kept only
  if the planted kill rate rises over the next window and the real store
  stays clean.

  :: details Where it runs
  The scheduler is Lean, in the store's `witness/` package beside the crash
  search, because the crash search is already the oracle: it runs one
  process per candidate, memoizes the answer and reports whether it covered
  the range. The attack programs stay C, and the cluster runs stay where they
  are. One run is one record: level, target, attributes, drawn parameter,
  outcome and seconds, in a ZStandard parquet. A witness's text sits in its
  own relation, so a clean run carries no empty field.

  :: details The scheduler's own controls
  - A level that never finds its planted defect classifies as blind.
  - A level that finds it eight times in eight classifies as calibrated.
  - A planted witness on the real target produces an escape row.
  - A calibrated level whose cost is planted at 100 times leaves the per
    change lane by name.
  - Shuffled records give the same plan.
  - A record with more successes than runs is rejected.
  - A zero budget gives an empty lane, which is a failure.

  :: details What it cannot test
  One machine stops processes and does not cut networks. A partition, the
  only case where split-brain is possible, needs two hosts, and no level
  here produces one. The cluster levels need three zones on one host, which
  the cluster runs already set up.

  :: details Open questions
  - The per change budget for the real store lane. 120 s is the default
    until a measured run says otherwise.
  - Which host runs the soak lane. It needs a FoundationDB server, and the
    Mac desk has none.
  """
end
