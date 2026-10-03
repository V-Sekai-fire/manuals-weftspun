# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 1075. Abandoned; the application it logs into is archived.
use RFD.DSL

rfd 1075, "GitHub OAuth login, gated on weftspun org membership", :abandoned do
  feature "retracted"
  scope "retracted"

  decision ~S"""
  Retracted 2026-09-10. This RFD registers an OAuth application against
  `weftspun-studio`, whose repository was archived on 2026-09-09 and whose
  manifest entry is removed. There is no longer a service to log in to.
  """
end
