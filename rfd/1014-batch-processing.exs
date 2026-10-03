# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 1014, "Batch processing", :abandoned do
  feature "batch processing"
  attest_in :none

  prose ~S"""
  :: decision
  Add batch processing with manifest files.

  - The user loads a manifest.json that lists the input files.
  - The app runs each item through the editing pipeline.
  - BatchDownload saves the output VRMs.

  The pipeline also renders VRM thumbnails, spritesheets, and LoRA
  training data from the same manifests.
  :: problem
  One avatar at a time is slow. A user with many VRM files wants to
  process them in one run. The app must accept a manifest and produce
  many results.
  :: references
  - UI: `src/pages/BatchManifest.jsx`
  - UI: `src/pages/BatchDownload.jsx`
  - Parser: `src/library/manifestDataManager.js`
  - Docs: `docs/docs/Modders/manifest-files/`
  :: related
  RFD 1005 defines the avatar pipeline that batch processing runs.
  """
end
