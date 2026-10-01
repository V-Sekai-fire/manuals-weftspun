# RFD 2287's first rung, release by release

Each release RFD 2293 plans, measured on the Steam Frame over SSH from the desk (an M2 Pro
Mac): the apparatus, every gate with its control, and what stayed unchecked. The headset's
own sizing is in [`logbook-steam-frame-sizing.md`](logbook-steam-frame-sizing.md).

## The compatibility layer

Every passing headset run used `~/rfd2287/proton-xrfix` with the prefix
`~/rfd2287/compat-xrfix` (`headset4` at 06:47, `rung` at 08:10, `ctl-baseline` at 12:47 on
2026-09-30). Stock Proton with the prefix `compat` exits 3 (`headset1`, `headset2`, 06:44 and
06:45).

`diff -rq` of the copy against stock Proton 11.0 (ARM64), `proton-11.0-2c-arm64`, names one
file, and `cmp -l` names one byte in it:

| | Stock | `proton-xrfix` |
| --- | --- | --- |
| `files/lib/wine/aarch64-unix/win32u.so` | 2,313,208 bytes | 2,313,208 bytes |
| sha256 | `922534cd…a53a449` | `e7137688…262f10059` |
| Byte at file offset `0x13dd35` | `0xe9` | `0xed` |
| Instruction at `0x13dd34`, in `.text` | `ldr x4, [x9, #976]` | `ldr x4, [x9, #984]` |

The patch loads the next 8-byte slot of the table `x9` points at into the fifth argument.
`tools/frame/proton-xrfix.sh` makes the copy from stock: its output against the live copy is
empty under `diff -rq`, the file keeps mode 555, a second run changes nothing, and the control,
the patched copy given as the source, is refused by name. `run-xr.sh` defaults to this copy
and prefix.

Unchecked: which function the slot at `#984` holds, and why the call needs it.

## dev: the branch's pen on the hand-made binaries

The pen is `transport-meshing-pen` `feat/rung-dev` at `3eee45f`, `git archive` rsynced over
`~/rfd2287/pen` with `--delete`, keeping only `.godot/` and `bintr/`. The engine and the double
DLL are the hand-made ones from the sizing entry; `run-xr.sh` is the branch's.

| Tag | Mode | Result | Read from |
| --- | --- | --- | --- |
| `dev-pen-hand` | `xr` | PASS: `session_visible` at 4.77 s; 6 strokes, 2 cycles, 2 openings; 940 vertices, 1748 faces | `logs/dev-pen-hand.txt` |
| `dev-pen-hand-hidden` | `hidden` | FAIL as required: view flat, expected xr, rc 1 | `logs/dev-pen-hand-hidden.txt` |

The gate passes without what the hand copy carried and the branch does not, all of it
absent together: an untracked `override.cfg` (`xr/openxr/enabled`, `xr/shaders/enabled`, the
startup alert off), binary translation on with `res://bintr/` libraries keyed to its own
ELFs, and other builds of `curvenet.elf` and `dress_on.elf`. Its `xr_main.tscn`, `main.gd` and action map
differ from the branch only by CRLF line endings. The branch runs every guest interpreted
and at single precision.

Unchecked: the `hidden` run's gate prints `XR_RUNTIME_JSON=` empty. The variable reaches the
Unix-side loader, which the flat view shows, and not the Windows environment Godot reads.

## The release builds

`service-godot-build` carries the recipes: `double.yml` for the engine at double, editor and
`template_release`, on windows x86_64 (llvm-mingw 20260922), linux x86_64 and macos arm64;
`addon.yml` for godot-sandbox at double, `template_release`, on the same hosts with macOS
universal.

The first dispatch failed at checkout on every job. `double.yml` named
`97dab7a638b5d2a0e1b9b57e0fdc1c2cb4b6b8e2`, which `entities-godot` does not have (HTTP 422);
the headset build's commit is `97dab7a638ae8b613dcf6e657f93f020471d9040`, resolved from the
placed checkout and confirmed on the remote. `addon.yml` named `feat/bintr-emit`, which
godot-sandbox deleted when PR #7 merged; `ade650e` is that merge, `b1118e5` with the
bintr-emit change to `src/sandbox.cpp`. The macOS addon was arm64, a name the pen's
`.gdextension` never loads, since it maps `macos.*.double` to `.universal.framework`.
`service-godot-build` PRs #2 and #3 fix all three; the second dispatch is runs 36809657978
(engine, tag `v20260930-double.1`) and 36809660359 (addon, tag `v20260930-addon.1`) from
`d6a6de0`.
