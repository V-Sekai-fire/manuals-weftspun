# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2281, "face shapes from three sources", :prediscussion do
  front_matter ~S"""
  ---
  name: rfd-2281-face-shapes-from-three-sources
  description: >-
    When a purchased face needs the unified-expression set: bake it from artist
    sculpts, headfit.elf and cage.elf through the sandbox host; gate each at 0.76 mm.
  tools: Read, Edit, Bash
  ---
  """

  flight_level :l1
  feature "every name a face-tracking controller binds exists on the face
mesh, each shape tagged with its source and held to a credit card's thickness"
  scope "the NDMF head-fit component and its bake in the engine project;
headfit.elf and cage.elf as committed `.bytes`; the sandbox host's ECALL table"

  prose ~S"""
  :: decision
  A face shape comes from one of three sources, recorded per shape. The
  artist's own sculpt carries the name when one exists, and is exact.
  headfit.elf transfers ANNY's actions after fitting ANNY's head, gated at
  0.76 mm. cage.elf deforms a box cage by a data table of knot moves for
  names ANNY lacks. C# marshals and never fits. The bake reads the required
  names from the merged controllers' curve bindings.
  :: problem
  A purchased face ships with hundreds of artist shapes and none that
  moves the jaw, lips, cheeks or tongue for tracking, and a hand-mixed
  stand-in has no error bar at all.
  """

  related "RFD 2275 (the head fit), RFD 2277 (the engine half), RFD 2279
(the deform surface; its corrective stage replaces the cage placeholders)."
  details_title "face shapes from three sources"

  prose ~S"""
  :: details Measured on the first avatar
  | source | names | error |
  | --- | --- | --- |
  | artist sculpt | 16 | 0.0000 mm |
  | ANNY transfer | 45 | 8 pass at 0.76 mm over all vertices, 31 over reached vertices |
  | cage table | 12 | bind identity 0.0002 to 0.0004 mm |

  - The transfer error counts an ANNY vertex the fitted surface misses by
    more than 8 mm as its whole delta, so it follows fit coverage.
  - Loss weights do not close the gap. Cranium 0, dial prior 0.1 and
    12 × 100 iterations lowered the mouth residual from 2.7 to 2.2 mm and
    cut the passes from 8 to 4. Five dials sat at their −1 limit.
  - Meeting the budget needs a non-rigid step between fit and transfer.
  :: details Running the bake
  - The bake runs on the editor's update in 40 ms slices: about 3 minutes
    for 653 uploads and the fit, 2 more for 73 transfers.
  - An unfocused editor throttles update. Driving the private step in a
    45 s loop is full duty under the tool's 60 s timeout.
  - Progress is read from the process: two CPU-time samples 15 s apart
    that barely move mean the bake has ended.
  - A re-bake replaces the head-fit shapes and leaves the artist and cage
    shapes in place.
  :: details The cage table
  - `group <name> <region shape> <L|R|*> <margin_mm>` boxes the vertices an
    artist shape moves, on one side.
  - `move <shape> <group> <knots> <dx dy dz mm>` accumulates knot moves.
  - Each bind returns the rest mesh under an identity deform before a
    shape is kept.
  - `cage_deform` takes nV × 12 row-major `[R | t]`, where t is the knot's
    new absolute position.
  - The moves are authored and have no reference, so they are
    placeholders for RFD 2279's corrective stage.
  :: details Host gaps
  An unhandled ECALL is a host gap, not a guest fault. Dictionary ops (524)
  was the first. A new handler follows the guest's op enum, passes
  `sbhost_probe` on the Linux build, and carries a control. The control
  rebuilds without the handler and fails the same call with the same
  message. The DLL is replaced before the Editor first loads it.
  :: details Verifying a shape
  Each shape renders at 100% from a baked snapshot on its own layer,
  because the live preview ignores weights set on the source renderer.
  It is diffed against neutral. Two controls run with it: neutral twice
  differs by 0 px, and a known-empty shape differs by 0 px. Tongue shapes
  inside a closed mouth read 0 px alone and are tested with the tongue out.
  """
end
