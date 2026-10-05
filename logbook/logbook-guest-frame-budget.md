# Guest frame budget: the station load, the dress flow and the CASSIE cycle target

Measured on 2026-10-04 on the Windows desk, in `transport-meshing-pen` on `feat/station-compiled`
(`efc193a` and the commits before it), with the double editor build and the guest ELFs that
branch vendors. The budgets these numbers led to are RFD 2302's; the graph port and replay rule
are RFD 2263's; the body fit is RFD 2287's.

## Apparatus

- The replay gate is `tools/gate_replay.gd`, run on `tools/strokes/dress.usda`, CASSIE's dress
  session converted once from its raw export (153 strokes, each followed by its mirror).
- Scene setup is timed frame by frame: the engine time each line carries, with and without the
  station in the scene (`--station` puts it back).
- The full flow is the dress through every stage to MESH, each stage's wall time printed by the
  pipeline.
- The expected cycle count comes from `tools/cassie_expected.gd` reading the session's patch log;
  its self-test carries a control that siblings of one stroke do not split each other.

## Scene load before the first frame

| Run | Before the first frame |
| --- | --- |
| Pen scene with the station | 47.6 s |
| Replay gate without the station | 1.5 s |

The station's 47.6 s, by module:

| Module | Seconds |
| --- | --- |
| environment | 18.3 |
| sakura | 21.8 |
| plaza | 1.5 |
| station | 1.0 |
| realize | 9.4 |

The station build was also tried in a `_process` on a node whose `process_thread_group` is
`SUB_THREAD`. Frame 2 took 19.7 s: the frame waits for every thread group's `_process` to return,
so the sub-thread moved the work and hid none of it. RFD 2302's 5 s first-frame budget is set
against these rows; the replay gate meets it and the station scene does not.

## The dress through the full flow

| Stage | Seconds |
| --- | --- |
| mesh_build | 21.3 |
| session replay through the graph port | 1.8 |
| body fit | 2.7 |
| triangulation | 0.66 |
| Full flow | 29.1 |

The four stages sum to 26.5 s; the other 2.6 s is the flow's remaining stages.

Before the deferral, every committed stroke re-meshed its cycles: a per-stroke run took 380 s,
341 s of it meshing. Meshing now runs once, after the last stroke.

The body fit places the drawn dress by Appendix E keypoints, then pushes each stroke out of the
body in drawing order through `mujoco.elf` with 4 mm of clearance, about five credit cards
stacked. A winding-number count over all 12307 stroke points finds 0 inside the body. Junction
misses are 4; pushing the strokes independently instead of in order gave 73.

## The expected cycle count

| Target | State | Why |
| --- | --- | --- |
| 190 | withdrawn | read off the final export as 190 of 202 patches alive at the end; the export logs every patch created and none of those dropped, so the count moved to the patch log |
| 157 | withdrawn | each stroke's patch batch was attributed to the next stroke, so a stroke's own patches split each other and real splits were missed |
| 104 | current | 225 found, less 9 deleted, 42 holding a deleted stroke or its mirror (id + 1), 70 split by a later stroke's batch |

The patches of a stroke are logged just before its `ADD_STROKE`, not after it, which is what moved
157 to 104. Against 104, the literal port of CASSIE's graph ends with 103 cycles, 101 of them
CASSIE patches stroke for stroke, and 2 found only by the port. The C++ port and a literal Python
port of the same classes agree on 425 of 425 events.

Replayed junctions use CASSIE's recorded intersection constraints and sit within 0.1 mm of the
recorded point, about an eighth of a credit card; the worst is 0.016 mm, about a fiftieth of one.

## The gdl String relocation fault

Godot's containers grow by `realloc`, a bytewise move. gdl `String` wrapped a `std::string`, whose
short-string buffer points into the object, so after a `HashSet<String>` grew, every key of 15
characters or fewer pointed into the freed block, and its destructor freed an address inside it.
The sandbox reported a possible double free; the dress replay stopped at stroke 116 of 153.

`contract-guest-runtime` #6 holds the `std::string` behind a pointer. `tests/string_relocatable.cpp`
moves a `String` bytewise and frees the original: the earlier `String` fails 3 of 4 cases and the
fixed one passes 4, with a short `std::string` as the control that must fail. #7 runs that test
in CI.
