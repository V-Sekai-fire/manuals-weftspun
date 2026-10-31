# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2431, "internal assets are OpenUSD and transmission is glTF, VRM or USDZ", :discussion do
  flight_level :l2
  scope "the file formats used inside the pipeline and the ones sent out of it."

  prose ~S"""
  :: hook
  Assets stay OpenUSD inside the pipeline and change format only where they leave it.
  :: intrigue
  Each stage adds a layer to the OpenUSD stage, and only the boundary may convert it.
  :: exit
  Check a new asset path against the rule: convert at the boundary only.
  :: decision
  - Internal: OpenUSD `.usda` / `.usdc` (RFD66606-1053 `committed`), each stage adds a layer.
  - Convert at the boundary only.
  :: related
  - RFD66606-1102, where this rule lived before the split.
  - RFD66606-1053, the `committed` OpenUSD stage.
  """

  details_title "internal assets are OpenUSD and transmission is glTF, VRM or USDZ"

  prose ~S"""
  :: details Transmission formats
  Transmission: glTF binary (asset), VRM (avatar), USDZ (archive).
  """
end
