# Eye tracking on the headset stopped holding on the 0.4.2 OS beta

Measured on 2026-09-30 over SSH from the Windows desk. At 07:13 that day the headset took the
0.4.2 beta of its OS (BUILD_ID 20260928.6175029, runtime and eye tracking 2.18.1).

## What the log shows

| OS partition | Eye-tracking sessions | Read from |
| --- | --- | --- |
| before 0.4.2 | 85 starts and 36 stops, so sessions held | `~/.local/share/Steam/logs/eyetracking.txt` |
| 0.4.2 beta | 10 of 10 boots: every `HMD on, starting eye tracking` met `HMD off, stopping eye tracking` 0.25 to 2.5 s later | the same log |

On the beta the frameeyeosc heartbeat read the eye feed at 0 Hz. A worn headset with a held
session feeds it at 90 Hz, with a sequence counter in `/dev/shm/eye-server.mmap`.

`CGazeEstimatorCdsp: Failed to grab cdsp input buffer: 1` does not separate the two: the
partition where sessions held logs it 601 times. The flap began before the companion-tracker
driver was loaded and outlasted runtime restarts, so neither caused it. The 0.4.2 release notes
name a change to the proximity sensor logic that decides whether the headset is on a face,
which is the suspect.

## Not tested

The daemon `/opt/steamvr/tools/eyetracking/bin/linuxarm64/eyetracking` takes `-b/--backend`,
with CPU as its own default, while the runtime launches it with `-b CDSP`. It reads
`-c /persist/eyetracking.json`. Whether the CPU backend avoids the flap is unknown.

## Re-running

1. Check the OS channel before anything else; the flap is tied to the 0.4.2 beta.
2. With the headset worn, `grep -E 'HMD (on|off)' ~/.local/share/Steam/logs/eyetracking.txt`
   must show a start with no stop within seconds.
3. `journalctl --user -u frameeyeosc` must show the eye feed above 0 Hz.

Every runtime restart recreates `/dev/shm/eye-server.mmap` and leaves frameeyeosc mapped to the
old segment, so `systemctl --user restart frameeyeosc` follows any runtime restart.

## Outcome

The operator moved the headset back to the stable channel the same day and parked the work.
