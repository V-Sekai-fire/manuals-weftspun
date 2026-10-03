# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 1042, "Model image for krea2_turbo_text_to_image", :abandoned do
  feature "model packaging"
  attest_in :none

  prose ~S"""
  :: decision
  Package it as one model image, and stage the loads. The text encoders
  load, they run, and they unload. The backbone then loads.

  Quantize to Q4_K_M. RFD 1027 selects that format for both
  text-to-image models, and it drops this one from 33.8 GB to 9.30 GB.
  :: problem
  Krea 2 Turbo is the largest model in the catalog that the project
  runs. It needs 33.8 GB in bf16, which is 29 percent of the whole
  catalog.

  It is also four models in one folder: a backbone, two text encoders, and
  a VAE. A model image that loads all four at once wastes memory, because
  the text encoders finish before the backbone starts.
  :: related
  RFD 1027 selects the format. RFD 1034 checks the arithmetic. RFD 1025
  gives the rule.
  """
end
