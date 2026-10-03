# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2175, "Abandon RFDs whose decision uses blocklisted rented compute", :published do
  feature "documentation retraction"
  scope "RFDs 1132, 1140, 1163, 2133, 2138"

  prose ~S"""
  :: decision
  Abandon five RFDs (1132, 1140, 1163, 2133, 2138) whose decisions name RunPod or Vast.ai rented
  compute, which CLAUDE.md's hard constraint now blocklists. Each moves to `abandoned` alongside
  this document landing.
  :: problem
  CLAUDE.md's hard constraint is "the local desktop GPU is the only compute; RunPod and Vast.ai
  blocklisted". Five open RFDs still name rented compute as their decision, so the RFD's whole
  reason for existing contradicts the blocklist. The RFDs themselves stay in the register for
  citation, per CLAUDE.md's "retractions stay in place next to what they retract".
  :: section The five
    RFD 1140  Rented GPUs on RunPod. Decision 'rented GPU work runs
              on RunPod' contradicts CLAUDE.md's RunPod blocklist.
    RFD 1132  Priority list of converted models. RunPod as serving
              interactor. Same contradiction.
    RFD 1163  The accelerator in the loops. 'flow runs on RunPod'.
    RFD 2133  The pool rents from the spot book. 'Rent single
              RTX 4090s from the vast.ai book'.
    RFD 2138  interactor-shuttle. Merges the spot-broker whose whole
              reason was renting vast.ai. Abandoned with 2133.
  :: related
  Retracts: urn:oid:1.3.6.1.4.1.66606.1.1.{1132,1140,1163},
  urn:oid:1.3.6.1.4.1.66606.1.2.{2133,2138}
  Anchor: CLAUDE.md's Compute hard constraint and the RunPod, Vast.ai blocklist rows.
  Companion: RFD 2169 (studio-core abandonment), same class of walk-back.
  """
end
