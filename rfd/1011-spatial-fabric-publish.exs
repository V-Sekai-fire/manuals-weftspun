# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 1011, "Spatial fabric publish", :published do
  feature "spatial fabric"
  attest_in :none

  prose ~S"""
  :: hook
  A completed mesh task publishes to the spatial fabric in one flow.
  :: intrigue
  A completed mesh task should reach shared worlds, and the app has no publish path to
  the spatial fabric.
  :: exit
  Read `docs/SPATIAL_FABRIC_INTEGRATION.md` for the integration.
  :: decision
  Add a publish flow for completed tasks.

  - Publish RP1 sends the completed mesh to the spatial fabric.
  - Validate OMB tier checks the GLB export against the fabric.

  The flow opens the Scene Assembler in a new tab. The spatial
  fabric adapter checks the manifest and the tier presets.
  :: references
  - Adapter: `src/library/spatialFabricAdapter.js`
  - Hook: `src/hooks/useSpatialFabric.js`
  - Presets: `src/library/ombExportPresets.js`
  - Docs: `docs/SPATIAL_FABRIC_INTEGRATION.md`
  :: related
  RFD66606-1007 replaces the publish terminal validation with motion
  validation in the Studio pipeline.
  """

  prose ~S"""
  :: details The problem
  The fabric needs a valid
  manifest and a scene assembler.
  """
end
