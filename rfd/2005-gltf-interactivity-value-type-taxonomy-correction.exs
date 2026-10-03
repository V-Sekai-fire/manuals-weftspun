# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2005, "Gltf interactivity value type taxonomy correction", :abandoned do
  prose ~S"""
  :: decision
  The full argument is in git at `a6eb679`.
  :: problem
  `rfd/2001-zonefabric-roadmap-vs-mas-bandwidth-fps/index.md`, item 5,
  described `gltf_interactivity`'s value-type system as a two-way split:
  primitive types versus `ref`. The real specification, vendored at
  `taskweft/thirdparty/gltf_interactivity/`, defines three signature
  categories, not two. This RFD corrects the record and states which
  category `zone-server-h2o` actually implements.
  :: related
  The full argument is in git at `a6eb679`.
  """
end
