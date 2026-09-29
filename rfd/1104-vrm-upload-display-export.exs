# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 1104. `mix rfd.render` renders rfd/1104-vrm-upload-display-export/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD1104 do
  use RFD.DSL

  rfd 1104, "Uploaded VRM, rotate the scene root, never the hips" do
    state :abandoned

    scope "`src/library/vrmLoader.js`, `rigBoneUtils.js`, `VRMExporter.js`"

    attest_in :none

    decision ~S"""
    Rotate `vrm.scene`, the root, never the hips or the armature alone.
    Skip AIGC rig repair entirely when `userData.vrmNormalized` is set.
    Build the skeleton overlay from the primary skinned mesh, not from
    humanoid `Normalized_*` nodes. Yaw on export only when the model's
    world-forward direction actually needs it
    (`getWorldDirection().z > 0.5`), never an unconditional
    `rotateY(π)`. `processModel` early-returns for any VRM or
    `vrmBindPassthrough` model: no autoscale, no AIGC yaw repair.

    See `DETAILS.md` for the passthrough policy, the display-path rules,
    the export-path steps, the implementation map, and the retest
    checklist.
    """

    problem ~S"""
    This project once mutated an uploaded `.vrm` after load, instead of
    rendering it as-is: rotating the armature or hips alone, running
    AIGC rig-repair on it, and always yawing on export. On a VRM0
    UniGLTF multi-skin file (each of body, head, eyes, cornea, hair
    carrying its own skin index, bones as scene siblings), rotating only
    the armature moves bone world matrices relative to the mesh nodes it
    does not touch, drifting the bind worst at the eyes and finger
    extremities.
    """

    related ~S"""
    RFD 1083 gives the AIGC rig contract this upload path deliberately
    does not run. RFD 1084 gives the avatar pipeline that path serves
    instead.
    """

    drafted_by :ai
  end
end
