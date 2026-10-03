# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 1013, "Public demo deploy", :abandoned do
  feature "public demo"
  attest_in :none

  prose ~S"""
  :: decision
  Deploy a public viewport demo on Vercel. The build sets
  VITE_PUBLIC_DEMO=1 and loads loot assets through a CDN.

  The verify:public-env script blocks client secrets in CI and on
  Vercel. Full AI generation stays on local dev and the self-hosted
  backend. The demo does not require VITE_API_ENDPOINT.
  :: problem
  The app runs against a private DGX backend. A public deploy must
  not expose LAN or DGX secrets. A demo must still show the viewport,
  VRM upload, and traits.
  :: references
  - Config: `vercel.json`
  - Guard: `scripts/verify-public-build-env.mjs`
  - Docs: `docs/PUBLIC_DEPLOY.md`
  - UI toggle: `src/library/runtimeUi.js`
  :: related
  RFD 1001 defines the app shell that the demo deploys.
  """
end
