# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2356, "Workspace services stay DNS-only", :discussion do
  scope "the DNS records of every workspace service."
  attest_in :details

  prose ~S"""
  :: hook
  Workspace services stay DNS-only, so no CDN reads their traffic.
  :: intrigue
  A proxied record puts Cloudflare between a client and the service for every request.
  :: exit
  If a workspace service lands under a proxied subdomain, take the proxy flag off before it
  serves requests.
  :: decision
  CF-proxied records have Cloudflare terminating TLS at its edge, every byte plaintext at
  CF for the round trip. Workspace services stay DNS-only; edge cache, if needed, is
  Fly-side or origin-side.
  :: problem
  Services here carry auth tokens and hostname-bound credentials.
  :: related
  RFD66606-2146.
  Split from the old RFD66606-2147: RFD66606-2353 (replicas), 2354 (unseal), 2355 (cache).
  """

  details_title "Workspace services stay DNS-only"

  prose ~S"""
  :: details No CDN proxy in front of workspace services
  Cloudflare's `proxied: true` mode has CF terminating TLS at its edge
  using its Universal SSL cert and re-encrypting to origin. Every byte
  of the request headers and body is plaintext at CF for the round
  trip. CF is not the workspace's tenant. That is a MITM regardless of
  intent, and it is not compatible with services that carry auth
  tokens or hostname-bound credentials.

  Records for services this workspace runs stay `proxied: false`. Edge
  caching, if it is ever needed, lives Fly-side (Fly's own Anycast +
  edge) or origin-side (an in-process cache).

  One record in the `chibifire.com` zone as of 2026-09-01 is
  CF-proxied: `hub-700a.chibifire.com`, pointing at
  `173.180.240.105 / 2001:569:7e58:dd00:...`. That is a personal home
  network endpoint, outside this workspace's scope. If a workspace
  service ever lands under a subdomain that is currently proxied, the
  proxy flag comes off before the service starts serving requests.
  """
end
