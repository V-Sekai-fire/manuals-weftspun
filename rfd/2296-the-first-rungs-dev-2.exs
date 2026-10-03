# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2296. `mix rfd.render` renders
# rfd/2296-the-first-rungs-dev-2/README.md and DETAILS.md from
# this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2296 do
  use RFD.DSL

  rfd 2296, "the first rung's dev.2" do
    state :discussion

    flight_level :l1

    feature "the dev rung that follows dev.1 on RFD 2293's release ladder"

    scope "the pen's `v<date>-dev.2` release"

    decision ~S"""
    dev.2 closes the gaps dev.1's logbook counts, rebases the godot-sandbox
    fork on upstream and releases the addon from it, and rebuilds every
    guest for the moved packed-array calls.
    """

    problem ~S"""
    RFD 2293 is the Skateboard's workspace and its whole ladder, and the
    dev rungs past dev.1 change daily while the rest of it does not. Kept
    there, each rung's edit is a diff to the workspace plan.
    """

    related ~S"""
    - RFD 2293, the workspace, the ladder and dev.1; its release rules
      (tag, GitHub release, playtest, gates with controls) hold here.
    - RFD 2287, the rung; RFD 2262, the ladder.
    - RFD 2295, the forecast tags; RFD 2294, the visual comparisons.
    - RFD 2297, dev.3; RFD 2298, dev.next.
    """

    drafted_by :ai

    details_title "the first rung's dev.2"

    details "dev.2: dev.1's counted gaps closed and the addon rebased", ~S"""
    Operator, 2026-10-02.

    - The gaps `logbook-rfd2287-rung.md` counts: a teleport onto the 8 cm
      handrail is refused through a walkable-floor ray; `solid_land` gets
      a control of its own, apart from `no_resolve`; `tools/probe_player.gd`
      gets a negative control and runs in CI; a frame-time baseline is
      taken with no station loaded, so the frame time has its floor beside
      it.
    - The godot-sandbox fork rebased on upstream `8a1774d`
      (V-Sekai-fire/godot-sandbox#15), with the host's unboxed-argument
      path packing `Vector2`, `Vector3`, `Vector4` and `Plane` at double
      rather than as float, its CI green, the addon released from it, and
      every guest rebuilt for the packed-array calls at `ECALL` +68 and +69.

    Each gap closes with the control the logbook counts it as lacking.
    The order is the rebase, then the addon release, then the guest
    rebuilds, then the tag, because a guest built against the old numbers
    lands its packed acquire on the array-window call. Playable: dev.1's
    route.
    """

    details "Which features are likely to bring joy", ~S"""
    Each forecast uses RFD 2293's sense-of-wonder rubric and RFD 2295's
    tag form.

    | rung | feature | criteria | joy |
    | --- | --- | --- | --- |
    | dev.2 | the godot-sandbox rebase | none | (remote, p=0.05) |

    dev.2's own feature is plumbing, so its joy rests on what it unblocks.
    """
  end
end
