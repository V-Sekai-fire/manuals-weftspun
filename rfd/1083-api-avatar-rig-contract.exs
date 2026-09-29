# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 1083. `mix rfd.render` renders rfd/1083-api-avatar-rig-contract/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD1083 do
  use RFD.DSL

  rfd 1083, "The API avatar rig export contract" do
    state :abandoned

    scope "`src/library/aigcRigContract.js`, `3DAIGC-API/core/utils/aigc_rig_contract.py`"

    attest_in :none

    decision ~S"""
    One canonical spec, this document (mirrored at
    `3DAIGC-API/docs/API_AVATAR_RIG_CONTRACT.md`, kept in lockstep), for
    every skinned humanoid GLB export: Y-up, -Z forward, feet on the
    floor, applied transforms, hips near mid-torso height. Both sides
    log `[API-Contract] PASS` or `FAIL`. The API fails the job outright
    on a critical code (upside down, facing backward, no skinned mesh,
    too few joints); the client applies only targeted skinned-mesh
    repair, and never reuses VRM-loader flags on an AIGC GLB, since a
    VRM upload and an AIGC rig follow deliberately separate paths (RFD
    1104 gives the VRM side).

    See `DETAILS.md` for the coordinate system, the full requirement and
    failure-code tables, the Blender export steps, and the retest
    procedure.
    """

    problem ~S"""
    An upside-down rig, a backward-facing character, and a rig
    floating at the hips were real, repeated regressions from the
    Blender export path. Two sides, the client and the DGX API, each
    validated a rigged GLB independently, with no shared spec, so a fix
    on one side could still drift from the other.
    """

    related ~S"""
    RFD 1084 gives the avatar pipeline that produces the GLB this
    contract validates. RFD 1104 gives the separate, contract-free VRM
    upload path.
    """

    drafted_by :ai
  end
end
