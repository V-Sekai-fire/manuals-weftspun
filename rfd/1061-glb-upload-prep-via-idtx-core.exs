# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 1061. `mix rfd.render` renders rfd/1061-glb-upload-prep-via-idtx-core/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD1061 do
  use RFD.DSL

  rfd 1061, "GLB upload prep moves to idtx_core, later" do
    state :abandoned

    scope "`thirdparty/3d_studio/src/library/glbCompress.js`, `thirdparty/fabric-flow-adapters/`"

    attest_in :none

    decision ~S"""
    The upload-prep job belongs on `idtx_core`'s USD-native transport,
    not on a second bespoke GLB pipeline in JavaScript.
    `thirdparty/fabric-flow-adapters/flow/` already carries what that
    job needs, and this repository's browser compression does not.

    None of that is reachable from a browser today.
    """

    problem ~S"""
    `__tests__/prepareGlbForApiUpload.test.js` tested two functions,
    `computeApiUploadSimplifyRatio` and `prepareGlbForApiUpload`, that
    `glbCompress.js` never defined. `TaskManager.jsx`'s skintokens
    auto-rig path imports `prepareGlbForApiUpload` at line 1163 and
    awaits it, and the import threw since whenever that call site was
    written. RFD 1023 first recorded this gap, and it stayed open
    through RFD 1060's move.

    The mesh a browser uploads today is prepared by `compressGlbBuffer`
    in the same file, over `gltf-transform`: client-side Draco, Meshopt,
    and WebP. RFD 1053 makes OpenUSD the internal format, the way
    `.blend` is internal to Blender, and it names glTF only a
    transmission format, converted at the boundary. GLB, Draco, and WebP
    belong at that boundary. They do not belong as the mesh-prep
    pipeline itself, which is what `compressGlbBuffer` is today.
    """

    related ~S"""
    RFD 1023 first recorded the `prepareGlbForApiUpload` gap. RFD 1053
    selects OpenUSD as the internal format this RFD defends. RFD 1057
    tracks open work of this shape.
    """

    drafted_by :ai
  end
end
