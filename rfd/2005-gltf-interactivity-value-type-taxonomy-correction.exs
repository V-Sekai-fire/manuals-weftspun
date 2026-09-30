# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2005. `mix rfd.render` renders rfd/2005-gltf-interactivity-value-type-taxonomy-correction/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2005 do
  use RFD.DSL

  rfd 2005, "Gltf interactivity value type taxonomy correction" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `a6eb679`.
    """

    problem ~S"""
    `rfd/2001-zonefabric-roadmap-vs-mas-bandwidth-fps/index.md`, item 5,
    described `gltf_interactivity`'s value-type system as a two-way split:
    primitive types versus `ref`. The real specification, vendored at
    `taskweft/thirdparty/gltf_interactivity/`, defines three signature
    categories, not two. This RFD corrects the record and states which
    category `zone-server-h2o` actually implements.
    """

    related ~S"""
    The full argument is in git at `a6eb679`.
    """

    drafted_by :ai
  end
end
