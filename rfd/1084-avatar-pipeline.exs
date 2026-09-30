# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 1084. `mix rfd.render` renders rfd/1084-avatar-pipeline/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD1084 do
  use RFD.DSL

  rfd 1084, "The avatar pipeline, image to downloaded VRM" do
    state :abandoned

    scope "`src/library/avatarPipelineCatalog.js`, `taskManager.js`, `avatarPipelineExport.js`"

    attest_in :none

    decision ~S"""
    State the chain once: a photo goes to `3DAIGC-API`'s mesh-generation
    task, then its template auto-rigging task (`rig_mode: template`),
    landing a rigged GLB in the viewport. `exportAvatarPipelineVrm()`
    then builds a `.vrm` blob client-side and triggers a browser
    download; nothing uploads unless the user mints or saves elsewhere.
    Rig alignment is validated against RFD 1083's contract, checked with
    a `[API-Contract] PASS` log line, and the client applies no
    rig-repair heuristic of its own for `fromAigc` loads; a backward or
    floating rig means re-running after pulling the latest API, not a
    client-side patch.

    See `DETAILS.md` for the task-type table, the blend-shape source
    table, and the key files.
    """

    problem ~S"""
    "Avatar from Image" chains two API jobs (mesh generation, then
    template rigging) and a client-side export step. Nothing stated the
    chain in one place, so "does VRM export upload anywhere" and "why
    does the rig look backward" were open questions each time someone
    hit them.
    """

    related ~S"""
    RFD 1083 gives the rig contract this pipeline validates against.
    RFD 1104 gives the separate, user-uploaded-VRM path this pipeline
    does not use.
    """

    drafted_by :ai
  end
end
