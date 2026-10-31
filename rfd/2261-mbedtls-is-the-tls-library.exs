# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2261, "mbedTLS is the TLS library", :committed do
  feature "New TLS, mutual-TLS and signing code, sandbox guests included,\nbuilds on mbedTLS"
  scope "code this workspace writes that opens TLS, presents a client
certificate or signs a token"

  prose ~S"""
  :: hook
  New TLS, mutual-TLS and signing code builds on mbedTLS.
  :: intrigue
  Each new component chose its own TLS stack.
  :: exit
  Read RFD66606-2256 next: its QUIC stack runs TLS 1.3 through picotls on mbedTLS.
  :: decision
  mbedTLS (Apache-2.0) is the TLS and crypto library for new code:
  the same library Godot vendors, so an engine build and a guest
  ELF share one implementation. It covers mutual TLS with an agent
  certificate and the RS256 signing an app-token JWT needs.
  :: problem
  A guest ELF that
  must reach Bao needs client certificates the engine's HTTP client
  cannot present.
  :: related
  - RFD66606-2256 (WebTransport inside a sandbox guest), whose QUIC stack
    runs TLS 1.3 through picotls on mbedTLS.
  """

  details_title "mbedTLS is the TLS library"
end
