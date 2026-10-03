# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2185, "Hierarchical OID part registry under PEN", :discussion do
  feature "stable OID identity for every body/clothing/accessory part"
  scope "shared taxonomy for layer decomposition, segmentation, retargeting"

  prose ~S"""
  :: preamble
  Shelved 2026-09-02: waiting for measurement showing See-Through V3
  (23 parts, RFD 2183 stopgap via `anny_v3_face_groups.py`) is a
  bottleneck. Resume when a task lands that V3 cannot label.
  :: decision
  Every part gets a stable OID under `1.3.6.1.4.1.66606.<arc>.parts.<hierarchy>`.
  Hierarchical addressing: `body/head/hair/front-fringe`, so a v4
  addition is a new child, not a schema break.

  Four leaf alias sets pointing at the same OID hierarchy: See-Through
  V3 (RFD 2183 stopgap), ANNY 104 joints (RFD 1122 topology),
  PASCAL-Part (public benchmark interop), VRM 1.0 humanoid bones
  (deployment interop). Ingest maps any leaf alias to the canonical
  OID; storage is OID, not string, so v3->v4 never rewrites a corpus.
  :: problem
  V3 (23 parts, RFD 2183 stopgap) covers 10 today. Finer tasks
  (skin/makeup, cloth sub-parts, multi-character, hair sub-strands)
  break a flat schema. String labels lose meaning across versions;
  OIDs do not. RFD 1122 (AlternativeTopology) is the precedent shape.
  :: related
  RFD 2183 (layer-decomp pipeline; V3 stopgap sits under this),
  RFD 2184 (EditScore bootstrap for unmapped parts), RFD 1122
  (AlternativeTopology; reference precedent), RFD 1000 (RFD
  conventions; OID arc rules).
  """
end
