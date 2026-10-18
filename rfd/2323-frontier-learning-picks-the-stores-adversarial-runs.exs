# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2323, "frontier learning picks the store's adversarial runs", :discussion do
  feature "the SQLite on FoundationDB store's timing, crash, fence and cluster attacks are levels
whose regret is measured on a planted defect, and a clean run on the real store counts only after
its attack is shown to find that defect"
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
  store is a defect. Lanes fill performance first, then round trip (data
  written reads back whole), then security (operator, 2026-10-18).
  :: problem
  A clean run cannot say whether the store is sound or the attack is weak:
  one crash point drawn from 6 to 21 at 400 rows found a planted torn commit
  in 2 to 7 of 8 runs. Against a sound store every level scores zero.
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
  FoundationDB, then to triage performance first, round trip second and
  security third, with performance levels that have a baseline and a planted
  slow path. The measurements below are from the store's frontier branch on
  the same day.

  :: details Why one target gives no signal
  RFD 2309's learner is a policy that sometimes succeeds. Here the learner is
  the attack, and its success is a witness: a slow commit, a torn commit, a
  lost key, a superseded writer whose write landed, or a cluster that answered
  without a quorum. A sound store gives every level `s = 0`, so every level
  reads as impossible and regret is zero everywhere. That is the result we
  want from the store, and it teaches the attack nothing.

  The planted target restores the gradient. It is the same build with one
  defect switched on, so a level's kill rate on it is how well that attack
  finds that defect. A level between none and all of its runs is the frontier
  the paper samples from.

  The cluster run's negative control left all 200 keys readable under single
  redundancy, so its zone kill is uncontrolled. It is the same failure as the
  crash band in the first runs below: an attack that finds its defect by luck.

  :: details The levels
  | Level | Planted defect | Witness |
  |---|---|---|
  | commit rate | `WEFT_PLANT_SLOW_COMMIT=1` | under 97% of the slowest real run |
  | crash at a commit | `WEFT_PLANT_TORN_COMMIT=1` | two distinct row values |
  | kill at a delay | `WEFT_PLANT_TORN_COMMIT=1` | two distinct row values |
  | fence read | `WEFT_PLANT_STALE_VIEW=1` | a stale read accepted |
  | superseded writer | the fence check skipped | a superseded write lands |
  | handoff | the commit kept in the writer's cache | the reader sees fewer rows |
  | parallel commit | two databases as two transactions | a grant lost or doubled |
  | zone kill | `single` redundancy | a key that does not read |
  | quorum loss | none yet | a write accepted without quorum |
  | loss and restore | the restore skipped | zero keys after restore |

  The attributes: rows and repetitions for the commit rate; rows and a crash
  point or delay band for crash and kill; readers and cache for fence read;
  connections for the superseded writer; grants and a crash point band for
  the parallel commit; keys, shards and an aimed or named zone for the zone
  kill.

  The slow commit adds one read round trip before each commit. The torn
  commit makes each page visible in its own transaction. Those two, the stale
  view and `single` redundancy exist as switches. The others are new planted
  switches, each inert unless its variable is set. A level with no planted
  defect cannot be calibrated, and the report counts it under that name.

  A timed level's first three real runs are its baseline and are not judged.
  After that, a run is slow when its rate is under 97% of the slowest of the
  last eight real runs.

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

  Inside each lane, levels are taken in the triage order first: performance,
  round trip, security. Priority orders the levels within a family.

  :: details Mutation
  One attribute moves per proposal, to the neighbour the frontier needs.
  For the commit rate: two more repetitions, so the median is less noisy.
  For a crash or kill: each half of the band, and the next commit size in
  the crash search's list. For the zone kill: more data until it spans
  several shards, then a kill aimed at the team that holds the keys, which
  is the fix `qa/README.md` names for the uncontrolled control. For a
  parallel commit: a band around the two crash points the protocol is built
  around. For fence, superseded writer and handoff: one more reader,
  connection or row batch. A proposal is dropped once its window is full and
  its kill rate is no higher than its parent's.

  :: details Where it runs
  The scheduler is Lean, `witness/Frontier.lean` in the store's `witness/`
  package beside the crash search. The attack programs stay C, and the
  cluster runs stay where they are. One run is one record: level, target,
  drawn parameter, outcome, value and milliseconds. A witness's text sits in
  its own relation, so a clean run carries no empty field. The first runs
  keep them as tab separated text beside the scheduler; ZStandard parquet is
  the target once the record set grows.

  :: details The scheduler's own controls
  - A level that never finds its planted defect classifies as blind.
  - A level that finds it eight times in eight classifies as calibrated.
  - One miss in eight leaves a level on the frontier with regret.
  - A planted witness on the real target produces an escape row.
  - A calibrated level whose cost is planted at 100 times leaves the per
    change lane by name.
  - Shuffled records give the same plan.
  - A record naming a level the scheduler cannot decode is rejected.
  - A zero budget gives an empty lane.
  - Performance is picked before round trip, and round trip before security.
  - A timed run inside the baseline's spread is not slow, and one well under
    it is.
  - A frontier level proposes a split band and a bigger commit.
  - A mutation whose kill rate does not rise is dropped.

  A planted scheduler defect, `classify` never answering calibrated, failed
  three of the eleven controls that existed then.

  :: details First runs
  Fedora 44 under WSL on the Windows desk, FoundationDB 7.3.76 with one
  process, single redundancy and the memory engine. Two runs of three and
  five generations; the records are in the store's `witness/records/`.
  - The commit rate's baseline was 213 to 230 commits a second. With the slow
    commit planted it was 167 to 204, and the level calibrated at 8 of 8.
  - The first run stopped on a false escape: 210 a second was judged slow
    against a median of 224, inside the baseline's own spread. The rule now
    judges against the slowest recent real run.
  - The commit stage's crash band, 400 rows at points 6 to 21, found the torn
    commit in 4 to 7 of 8 runs in the first run, and the second ended at 2.
    Splitting the band did not help: the halves stayed between 3 and 6. The
    bigger commit did: 2000 rows at points 6 to 21 found it 8 of 8.
  - Correction. Each frontier run draws one crash point, so those rates are
    per point, not per stage. The commit stage walks six fixed points, and at
    400 rows 3 of the 6 tore in each of five walks, so the stage did catch
    the plant. At 2000 rows all 6 tore in each of five walks.
  - 8 rows at points 1 to 30 found it 0 of 8. One page per round leaves
    nothing to tear, so the level is blind.
  - 2000 rows at points 6 to 80 was 8 of 8 in the first run and 7 of 8 in the
    second, so calibration is a window, not a property a level keeps.
  - Fence reads, writer and reader, were 8 of 8 on the stale view plant.
  - No real store run was a witness in the second run.

  :: details Triage
  Performance:
  - Keep. A commit costs about 4.5 ms here, against the 1.1 ms round trip the
    benchmark's notes record. The latency probe read 1.8 ms to start a
    transaction and 2.0 ms to commit, and every commit starts a fresh one.
    Measure on the served cluster before changing the commit path.
  - Keep. The timing check's margin is thin: the slowest real run was 213 and
    the fastest planted one 204. The mutation to three repetitions is next.

  Round trip:
  - Done. The commit stage walks its six crash points at 2000 rows, then walks
    them again with the torn commit planted and fails unless one tears. Each
    run uses fresh database names: a database torn by an earlier planted walk
    makes the writer fail, which would count as a tear the plant did not
    cause.
  - Defer. The handoff level has no planted defect yet.

  Security:
  - Defer. The superseded writer has no planted defect yet.
  - Park. Quorum loss needs a planted cluster that answers without a quorum.

  :: details What it cannot test
  One machine stops processes and does not cut networks. A partition, the
  only case where split-brain is possible, needs two hosts, and no level
  here produces one. The cluster levels need three zones on one host, which
  the cluster runs already set up.

  :: details Open questions
  - The per change budget for the real store lane. 120 s is the default
    until a measured run says otherwise.
  - Which host runs the soak lane in CI. The Fedora WSL desk runs it now.
  """
end
