# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2174, "Index of open RFDs citing abandoned RFDs", :committed do
  feature "documentation index for stale citations to abandoned RFDs"
  scope "every open RFD that cites an abandoned or moved RFD"

  prose ~S"""
  :: hook
  One citable index lists the open RFDs that still cite abandoned ones.
  :: intrigue
  An audit found 32 pairs of (open RFD, abandoned RFD it cites). The class of concern is open
  RFDs that lean on an abandoned RFD's decision as if it still holds, without knowing the
  citation went stale.
  :: exit
  Look up your RFD below and migrate any citation of an abandoned RFD to the successor named
  there.
  :: decision
  This RFD is the citable index for open-to-abandoned citation drift; the 32 pairs sit in
  DETAILS.md, and individual RFDs migrate their citations when next touched.
  :: section Details
  Each pair in DETAILS.md is annotated with what the citing RFD's claim depends on and where the
  successor lives. Cheaper than 32 amendments; provides one URN to cite when a reader hits a
  stale reference and needs the successor without a rewrite pass. Pattern established by
  RFD66606-2173 (Qwen3-VL swap index).
  :: related
  Spine: urn:oid:1.3.6.1.4.1.66606.1.1.1000 (RFD conventions).
  Applies to: 30-plus open RFDs; see DETAILS.md for the full list.
  """

  details_title "Index of open RFDs citing abandoned RFDs"

  prose ~S"""
  :: details_preamble
  Full pair list from the 2026-09-02 audit. Format: citing RFD (state)
  → cited abandoned RFD → successor to migrate to, or note.
  :: details Concentrations
  Concentrations: RFD66606-1122 (wholebody detector, abandoned by 2168) cited by 11 open RFDs;
  RFD66606-1166 (See-Through scoring plan) cited by 7; RFD66606-1049-1052 (abandoned model images)
  cited by 1133 and 1171; RFD66606-1019 (strangler-fig studio core, abandoned by 2169) cited by 4.
  :: details Citations of RFD66606-1122 (abandoned by RFD66606-2168)
  RFD66606-1122's bespoke wholebody detector never shipped; RFD66606-1143 (published)
  and 1173 (discussion) settled the pipeline differently. Every citation
  below treats 1122's rendered-ANNY corpus route as authoritative when
  the workspace actually uses ANNY-as-pose-primitive per RFD66606-1143.

    RFD66606-1121 (discussion) → RFD66606-1143 + RFD66606-1173
    RFD66606-1123 (discussion) → RFD66606-1143
    RFD66606-1126 (discussion) → RFD66606-1143
    RFD66606-1128 (discussion) → RFD66606-1143
    RFD66606-1130 (discussion) → RFD66606-1143
    RFD66606-1131 (discussion) → RFD66606-1143
    RFD66606-1132 (discussion) → RFD66606-1143
    RFD66606-1134 (discussion) → RFD66606-1143
    RFD66606-1142 (discussion) → RFD66606-1143
    RFD66606-1148 (discussion) → RFD66606-1143
    RFD66606-1170 (ideation)   → RFD66606-1173
    RFD66606-1171 (ideation)   → RFD66606-1173
  :: details Citations of RFD66606-1166 (abandoned)
  RFD66606-1166 was the See-Through scoring plan; RFD66606-1168 (segment 3D
  latent with rf-detr) replaced it.

    RFD66606-1006 (discussion) → RFD66606-1168
    RFD66606-1044 (discussion) → RFD66606-1168
    RFD66606-1167 (ideation)   → RFD66606-1168
    RFD66606-1168 (ideation)   → self (chain, keep)
    RFD66606-1169 (ideation)   → RFD66606-1168
    RFD66606-1170 (ideation)   → RFD66606-1168
    RFD66606-1171 (ideation)   → RFD66606-1168
    RFD66606-1173 (discussion) → RFD66606-1168
  :: details Citations of RFD66606-1049-1052 (abandoned model images)
  Weftspun-image-to-world, LingBot map, WorldMirror2, TripoSplat:
  all abandoned in the 2026-09-01 catalog prune.

    RFD66606-1038 (discussion) → drop (RFD66606-1038 mesh model is the same shape)
    RFD66606-1133 (discussion) → self (chain, keep)
    RFD66606-1171 (ideation)   → drop
  :: details Citations of RFD66606-1019 (abandoned by RFD66606-2169)
  The Elixir strangler-fig studio core.

    RFD66606-1022 (discussion) → RFD66606-2169
    RFD66606-1023 (discussion) → RFD66606-2169
    RFD66606-1055 (discussion) → RFD66606-2169
    RFD66606-1056 (discussion) → RFD66606-2169
  :: details Citations of RFD66606-1155 (abandoned)
  RFD66606-1155 abandoned Gemma 4 as an accelerator target; ironic given
  the reasoning-core swap in RFD66606-2169. Cite path chain intentional.

    RFD66606-1157 (ideation)   → self (chain, keep)
    RFD66606-1169 (ideation)   → self (chain, keep)
    RFD66606-1170 (ideation)   → self (chain, keep)
    RFD66606-1171 (ideation)   → self (chain, keep)
  :: details Citations of other abandoned RFDs
    RFD66606-1018 (discussion) → RFD66606-1012 (Phygital passport, abandoned)  → drop
    RFD66606-1073 (prediscussion) → RFD66606-1062 (Fly.io toplevel, abandoned) → drop
    RFD66606-1075 (prediscussion) → RFD66606-1062                              → drop
    RFD66606-1076 (prediscussion) → RFD66606-1062 + RFD66606-1074 (moved)           → drop
    RFD66606-1077 (prediscussion) → RFD66606-1067 (CockroachDB rerank, aband.) → RFD66606-2140
    (OpenBao on FDB) RFD66606-1112 (discussion) → RFD66606-1090, RFD66606-1100 (IWSDK + moat
    abandoned) → drop RFD66606-2150 (prediscussion) → RFD66606-2151 (CoAP+OSCORE NIF, abandoned) →
    drop RFD66606-2173 (committed) → RFD66606-2139 (MaskScore QAFT budget, aband.) → self (chain,
    keep)
  :: details Categories
    chain, keep   , retraction chain; the citation IS the walk-back
    successor RFD , migrate the citation on next edit
    drop          , reference is stale, no successor, remove on next edit

  Roughly 60% of the 32 pairs are legitimate retraction chains. The
  remaining ~13 pairs (marked with a successor or drop) are real drift.
  :: details The problem
  Not all are drift: a retraction
  chain legitimately cites what it walks back, and RFD66606-2168 (wholebody detector retraction)
  and 2169 (studio-core abandonment) do exactly this.
  """
end
