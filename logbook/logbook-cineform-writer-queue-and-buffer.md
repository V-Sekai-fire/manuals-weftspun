# The CineForm GDExtension writer: the encoder's job queue and the staging buffer

2026-09-29, the Windows desk. Engine: entities-godot `97dab7a63` built with `precision=double`,
llvm-mingw clang 23.1.1. Writer: `V-Sekai-fire/entities-godot-cineform`, the `.double` libraries
built from its pull request #3 with the same toolchain.

## What was measured

**The deadlock.** The SDK's `EncoderJobQueue` holds eight jobs, and a submit to a full queue
blocks until a sample is collected. Only the thread that submits frames collects. The -O0
`template_debug` library, which the editor binary loads, encodes 1080x1920 frames slower than
the engine renders them, so the eighth queued frame blocked the main thread in
`EncoderJobQueue::AddEncoderJob` while all sixteen encoder threads waited in `WaitForMessage`
(lldb stack dump of the hung editor). Three of three wear-clip recordings hung at frame 23.

**The overwrite.** Every queued frame was converted into one `staging` buffer. The SDK keeps the
pointer it is handed and reads it later on a worker thread, so the next frame's conversion could
overwrite a frame the encoder had not finished reading. Measured with a throwaway scene that
stamps each frame with its own number as twelve full-height stripes (test scene only; no marks
in real recordings), 300 frames at 1080x1920, decoded back with `tools/av1mkv dump-frame` and
read by `check_idx.py`, which re-decodes a wrong frame until three decodes agree so that the
decoder's own flakes are counted apart:

| library | debug | release |
| --- | --- | --- |
| queue fix only | 23 of 300 frames carry another frame's index | 2 of 300 |
| queue fix and per-frame buffers | 300 of 300 correct | 300 of 300 correct, 1 decoder flake |
| control: one frame planted with a neighbour's index | caught | — |

**The fix, checked on the wear clip** (`gate_loop.gd --gate=pen --avatar=Mire`, recorded as
`.cfhd`, the editor loading `template_debug.double`):

| library under the editor key | result |
| --- | --- |
| fixed debug, sha1 `d06246ea` | `CineForm: wrote 50 frames of 50 submitted`, `RESULT: PASS`, exit 0, 10 s; frames 0 and 49 decode as 1080x1920, frame 50 is refused |
| shipped debug, sha1 `f743ef5a` | no frame written after `STATE AUTHOR`, killed by a 150 s watchdog, movie truncated at 10 MB |

Comment density over the two source files fell from 21.8% to 21.0% across the two commits.

## What was retracted

- Every recording made with the shipped libraries before 2026-09-29 carries the overwrite: about
  one frame in 150 in release builds and one in 13 in debug builds may show a neighbouring frame's
  pixels. The wear and reel clips under `C:\b\rec-dbl\videos`, the round-1 wear-marocchino clip
  on the Desktop and the fullscreen test recordings are all in that set and are re-recorded
  once the fix lands.
- The desk launcher's preflight refuses the `template_debug` mapping on the editor key. That
  guard was a workaround for the deadlock, and it goes with the fix; the two runs above launched
  the engine directly because the guard forbids the configuration under test.

## Apparatus

`C:\b\cfq-idx` (the stripe scene, `check_idx.py`, `cfq-idx-rec.cmd`), `C:\b\cfq-wear` (a copy
of the rec-dbl project with `cfq-wear-rec.cmd` and `cfq-wear-run.ps1`, a 150 s wall clock that
stops only Godot processes running on that copy), logs `C:\b\cfq-idx\check*.log`,
`C:\b\cfq-wear-check.log`, `C:\b\cfq-wear-control.log`.
