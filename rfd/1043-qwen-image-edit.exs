# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 1043. `mix rfd.render` renders rfd/1043-qwen-image-edit/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD1043 do
  use RFD.DSL

  rfd 1043, "Model image for qwen_q4_k_m_image_edit" do
    state :abandoned

    feature "model packaging"

    attest_in :none

    decision ~S"""
    Ship Q4_K_M only. Never build a bf16 variant of this model image.

    At 0.55 bytes per parameter it needs 14.85 GB, and not 54.0 GB. That
    one choice saves 39.15 GB, which RFD 1027 records as the largest
    single saving in the catalog.
    """

    problem ~S"""
    Qwen image edit is the largest model in the catalog at 27.0 B
    parameters. In bf16 it needs 54.0 GB, which is 46 percent of the whole
    catalog on its own.

    The model id already names the format. It ships Q4_K_M, and the
    catalog entry records that choice in its name.
    """

    related ~S"""
    RFD 1027 selects the format and records the saving. RFD 1026 gives
    the row. RFD 1028 clears Apache 2.0.
    """

    drafted_by :ai
  end
end
