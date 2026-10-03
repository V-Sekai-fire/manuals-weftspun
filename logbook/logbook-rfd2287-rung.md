# RFD 2287's first rung: dev.1, the station walked through the MuJoCo guest

Measured on 2026-10-02 on the Mac desk (macOS 26, Apple silicon), for the
`release/v20261001-dev.1` cut of `V-Sekai-fire/transport-meshing-pen`. Times are PDT.

## What dev.1 carries

- Four ported station modules: `environment`, `station`, `plaza`, `sakura`. Built in
  28 281 ms and realized in 9 668 ms on the double editor.
- The station's 1089 primitive colliders and its terrain height field loaded into the
  MuJoCo guest (`mujoco.elf`, SBXV 40). Godot's physics is not used.
- The walker, a port of the original's `player.js`, on the guest's ray and contact queries:
  walk, the 0.45 m step-up, snap turn and teleport. No jump, no fly.
- rx's stick movement and rotation components, ported into the pen.

Out of dev.1: the radial menu, the Maro statue, body motion, `street` and `railway`.

## Apparatus

- Engine: `godot.macos.editor.double.arm64` from service-godot-build `v20260930-double.1`.
- Addon: `libgodot_riscv.macos.template_release.double.universal` from `v20260930-addon.1`.
- oxrsys at `V-Sekai-fire/oxrsys` `ac4c1456c0`, Metal.
- Pen branch `feat/station-walking`. The collider gate ran at `76098db`. The locomotion gate
  ran at `fac7b4f`, with one uncommitted addition in the working tree (`ray_walkable` in
  `stages/station_physics_stage.gd`, which the gate does not call).
- Station port: `V-Sekai-fire/entities-sakuragaoka-station` #10, merged as `8feb534`.

Every headless gate passes `--xr-mode off`. Without it, the OpenXR loader finds no runtime and
macOS raises a modal alert that holds the process at 0% CPU until the job's timeout.

    G=godot.macos.editor.double.arm64
    $G --headless --xr-mode off --path . --script tools/gate_colliders.gd -- [--control=drop_one|shift]
    $G --headless --xr-mode off --path . --script tools/gate_locomotion.gd -- [--control=...]
    python3 tools/walk_oxrsys.py --self-test

## The collider gate (2026-10-02T08:53-07:00)

| run | result |
| --- | --- |
| as built | PASS: 1089 colliders / original 1089, 0 dynamic / original 0 |
| control `drop_one` | FAIL, as it must: 1088 / 1089, first mismatch #99 cz -21.05 / -21.75 |
| control `shift` | FAIL, as it must: #99 cx 68.80 / 68.75 |

The `shift` control moves one box 5 cm, about two and a half nickels side by side, and the
gate sees it. The population is fixed, so the gate enumerates all 1089 rather than sampling.

## The oxrsys preflight (2026-10-02T08:54-07:00)

The pen's `xr_main.tscn` under oxrsys reached session state 5 (focused) with the streaming
server up. `WaitFrame` pacing settled at a mean of 12.05 ms, standard deviation 0.04 ms
(n=83 per second), against the runtime's 120 Hz target of 8.33 ms: about 83 fps. The first
second after focus averaged 15.28 ms (max 44.48 ms) while the station realized. The only
errors were action-map paths for an interaction profile the pen does not bind.

No simulator client was connected, so tracking input was not exercised. That is counted below.

## The locomotion gate (2026-10-02T09:12-07:00)

A fixed step of 1/60 s, no scene, the walker driven directly.

| check | as built |
| --- | --- |
| walk | 8.138 m in 3 s from the hero point at stick 0.9 |
| step up | feet 0.000 to 1.250 m, z -24.70: six treads of 0.179 m, each about three soda cans flat |
| ledge refused | feet stay at 0.000 m; stopped at x -4.309, a radius (0.30 m) and 9 mm short of the 1.25 m ledge |
| wall stops | x 3.060: the 8 cm handrail's face at 3.36, less the 0.30 m radius |
| snap turn | 0.5236 rad, position unchanged |
| teleport lands | onto the plaza 4 m ahead |
| teleport refused | a target overlapping the handrail is refused |
| repeats bit for bit | two fresh runs of 120 frames, 6720 bytes of poses, identical |

`RESULT: PASS (0 FAIL)`. Each control rewrites the stage or walker source at load time and must
end `RESULT: FAIL` with a non-zero exit:

| control | what it breaks | checks that fail | exit |
| --- | --- | --- | --- |
| `step_high` | step height 1.2 m in walker and stage | wall stops (x 5.890), teleport refused | 1 |
| `no_resolve` | `resolve` returns its input | ledge refused (feet fall to -13.650 m), wall stops (x 7.747), teleport refused | 1 |
| `solid_land` | the same rewrite as `no_resolve` | the same three | 1 |
| `ulp` | the second run's stick moves by one ulp, 0.9 to 0.9000000000000001 | repeats bit for bit | 1 |

`step_high` was planned to climb the refused ledge. It does not, and why is not yet diagnosed.
It fails on the handrail instead, which the 1.2 m step now climbs. The ledge check is held by
`no_resolve`.

## The persona walk driver (2026-10-02T09:09-07:00)

`tools/walk_oxrsys.py` sends `ClientConnect` and then 90 Hz `TrackingPacket`s with thumbsticks
and face buttons, which the simulator app does not send. Its self-test: the tracking packet is
1008 bytes and `ClientConnect` 80, as in `Protocol.h`; the sticks and buttons read back at their
offsets; and a control reading one field later does not see the sticks. 5 of 5 PASS.

## The release dry run (2026-10-02T09:14-07:00)

`release.yml`'s download and sum steps, run locally with `shasum -a 256` in place of `sha256sum`:

| file | size | sha256 | result |
| --- | --- | --- | --- |
| `godot.macos.editor.double.arm64` | 137 518 624 B | `5f6f2df3...1de8dce` | OK |
| `libgodot_riscv.macos.template_release.double.universal` | 15 360 968 B | `e2464e81...115bf0822` | OK |

Control: the engine with one byte at offset 4096 set to zero is `FAILED` against the same line.

## The persona run

2026-10-02T09:28-07:00 to 09:29-07:00, pen `feat/station-walking` at c4e46b5, the macOS double editor under the oxrsys
runtime with the PyroWave encoder named in the runtime log. The visitor "Hana" is
`tools/walk_oxrsys.py` sending touch-controller tracking to the simulator, driven by the beats in
`tools/persona_hana.json`; `tools/persona_capture.gd` logs a `persona` line and saves a head-camera
frame every 0.5 s (74 frames).

| beat | logged pose | result |
| --- | --- | --- |
| walk from the plaza toward the station | z 34.00 to 19.55, feet 0.812 to 0.407 m | moved |
| snap turn right, then back | yaw 4 to -26 to 4 degrees | 30 degrees each, cooldown held |
| teleport, no stick motion | z 19.55 to 14.93, 4.6 m (about 2.6 adult heights) | landed |
| walk to the forecourt | feet 0.000 m | on the ground |
| open the radial, world grab off then on | `grab false` to `grab true` | toggled |

Frame rate held 45 to 50 fps and dipped to 39 with the radial open, against the runtime's
120 Hz target.

What the run did not show:
- Hana did not reach the platform or climb the station stairs; the beats walk down to the
  forecourt.
- The radial's wedges sit below the head-camera frame, so its beats are confirmed by the log
  line and not by an image. `screencapture` has no screen permission from the job.
- The session receives tracking only when `walk_oxrsys` connects after the focused state; the
  two runs before this one connected early and lost their beats.

## The release

`release/v20261001-dev.1` and the annotated tag `v20261001-dev.1` point at ee80fb5, the merge
of transport-meshing-pen#26. `release.yml` published the prerelease, and every asset downloaded
from it passes `shasum -a 256 -c SHA256SUMS`: the double engine, the addon library and the
`curvenet`, `dress_on`, `mujoco`, `rd_worker` and `usd` ELFs.

## Deviations from RFD 2293's dev rung

- macOS through oxrsys, not the Frame.
- The playtest is a persona run driven by the assistant, with no human seat.
- The lesser port: four modules; `street`, `railway` and the rest wait.

## Known gaps, counted

1. A teleport whose centre lies inside the 8 cm handrail is accepted: contact push-out from
   inside a box thinner than the player gives no direction (likely, p=0.65), so `resolve`
   returns the point unmoved. The gate prints it as a `NOTE` and does not fail on it.
2. `solid_land` is not independent of `no_resolve`: it breaks the shared `resolve`, not the
   teleport's own refusal, so the teleport check has no control of its own.
3. Tracking input under oxrsys was not exercised in the preflight (no client connected).
4. `tools/probe_player.gd` has no negative control and is not in CI.
5. No frame-time baseline without the world was taken, so the 12.05 ms has no floor beside it.

## Forecasts

- The persona run completes every beat (likely, p=0.75). Resolved false: the platform and
  stairs beats were not reached.
- dev.1 is tagged by 2026-10-02T11:00-07:00 (likely, p=0.70). Resolved true: tagged before
  2026-10-02T10:00-07:00.

# dev.2: dev.1's counted gaps closed on the rebased addon

Measured 2026-10-02 on the Mac desk (M2 Pro, Metal) and in the pen's CI, for the tag
`v20261002-dev.2` at e2ab330. Times are ISO 8601. The rung ran
2026-10-02T16:16:46Z/2026-10-03T00:06:35Z, PT7H49M49S, from godot-sandbox#15 opening to the
release.

## The gaps, closed with their controls

The `double` run 37075755487 on e2ab330 is green, and each gap's control fails as planted:

1. A teleport onto the handrail is refused. The `no_floor` control fails on "handrail top
   refused".
2. `solid_land` has a control of its own, which fails on "teleport refused".
3. `tools/probe_player.gd` runs in CI, and its `no_cooldown` control fails on "snap cooldown".
4. The frame-time floor: the persona run below reads a median 60 fps with no station loaded,
   against 55 fps with it.

## The addon and the guests

godot-sandbox#15 merged at c7db89a. On that commit 25 CI runs succeeded and 5 were cancelled,
so "its CI green" holds for the runs that finished. `v20261002-addon.1` was released from it,
and all nine of its jobs passed. The five guests were rebuilt with `SBXV` 40 in
transport-meshing-pen#32.

## The playtest

The persona Hana went through oxrsys with PyroWave on #32's head (c47c469), driven by
`walk_oxrsys.py` with the double editor on Metal, 2026-10-02T14:21:45-07:00/2026-10-02T14:23:31-07:00,
PT1M46S:

    persona stairs down: monotonic PASS, 6 tread levels hit
    persona stairs up: monotonic PASS, 8 tread levels hit: 0.000 0.179 0.357 0.536 0.714 0.893 1.071 1.250
    persona RESULT: PASS (1 passes down, 1 up, each tread 0.179 m, about one and a half soda cans tall)
    persona fps: median 55 over 60 half-second samples
    persona fps: median 60 over 59 half-second samples (no station)

That closes dev.1's unreached stairs beat. `gate_xr_scripted --expect=flat` also passed there
(PT51S), and its `drop_seam` control failed at MESH.

## The release

The `release` run 37080604767 published the prerelease, 2026-10-03T00:06:10Z/2026-10-03T00:06:38Z,
PT28S. All ten assets downloaded from it pass `shasum -a 256 -c SHA256SUMS`:

- the macOS arm64 and Windows x86_64 double editors;
- both double addon libraries;
- the `curvenet`, `dress_on`, `mujoco`, `rd_worker` and `usd` ELFs.

The tag's "Build Platform Target" run failed only in `itch-upload`: curl exit 6 resolving
butler's host. That job is archived (transport-meshing-pen#34).

## Deviations and gaps, counted

1. The release is the editor, the addon and the ELFs, not one executable with its `.pck`.
   One-file exports are dev.3's.
2. The playtest is the assistant's persona run, with no human seat, on macOS.
3. The joy orbit views, the world-grab video and the Mitsuba guest moved to dev.next.

This entry was drafted by an AI and read by a human before it shipped.
