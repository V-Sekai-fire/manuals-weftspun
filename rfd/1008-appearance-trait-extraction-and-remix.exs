# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 1008, "Appearance trait extraction and remix", :abandoned do
  feature "appearance traits"
  attest_in :none

  prose ~S"""
  :: decision
  Map See-Through layer names to appearance slots. The map uses the
  existing appearance vocabulary. Hair, eyes, and face map to Head.
  Torso and clothing map to Chest. Legs and shoes map to Legs.

  The layer_decomposition node stores the mapped slots. The Studio
  page shows the remix candidates. A future remix flow equips the
  layer artifacts into the avatar slots.
  :: problem
  The See-Through layers split an image into body parts. Each part
  maps to an appearance slot. The app should reuse the layers for
  trait remixing.
  :: references
  - Mapping: `src/library/appearanceClothing.js`
  - Trait authoring: `src/pages/AppearanceSimple.jsx`
  - Slots: `src/library/lootAssetsConfig.js`
  :: related
  RFD 1006 produces the layers. RFD 1005 defines the avatar slots.
  """
end
