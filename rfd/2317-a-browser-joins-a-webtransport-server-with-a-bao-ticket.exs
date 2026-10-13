# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2317, "a browser joins a WebTransport server with a Bao ticket", :discussion do
  flight_level :l2
  feature "a page on a static Space signs in, gets a five-minute ticket from a Bao engine and
talks to a WebTransport server that trusts nothing but that ticket"
  scope "a Bao secrets plugin `wt`, a WebTransport server on Fly, a static Space page, and the
Bao identity and PKI mount the server uses"

  prose ~S"""
  :: decision
  - A static Space page signs in with Hugging Face, makes a WebCrypto key it
    cannot export, and opens a WebTransport session to a server on Fly.
  - A Bao plugin `wt` checks the sign-in itself, checks a ReBAC tuple, and
    signs a five-minute ticket bound to the page's key. It stores no ticket.
  - The server holds no user secret. It accepts a stream only with a valid
    ticket and a fresh proof of the page's key, and keeps its data in memory.
  - The server's QUIC certificate is a 13-day P-256 certificate from a Bao
    PKI mount, and the page pins its hash (operator, 2026-10-13).
  :: problem
  Nothing in the workspace shows a browser reaching a service under the zero
  trust rules the desks follow. A browser cannot hold a Bao client
  certificate, and a public page cannot keep a secret, so the browser needs a
  credential that is short-lived, tied to that browser, and issued by Bao
  without growing Bao's storage.
  :: related
  - RFD 2316, Bao holds a bounded set.
  - RFD 2256, WebTransport inside a sandbox guest, the QUIC stack.
  - RFD 2200, ReBAC agent roles.
  - RFD 2142, zero-trust service TLS via OpenBao PKI.
  """

  details_title "a browser joins a WebTransport server with a Bao ticket"

  prose ~S"""
  :: details Sources
  Written on 2026-10-13 from the operator's choices in one session: a demo
  on a static Space, Bao on FDB, zero trust, a Bao secrets engine, the
  industry pattern for browser credentials, and data in the server's memory.
  The pattern follows NIST SP 800-207 (no trust from network position), the
  OAuth guidance for browser apps (sign-in with PKCE, short-lived tokens) and
  RFC 9449 (a token bound to a key the browser holds).
  :: details The flow
  1. The page signs in with Hugging Face OAuth, scopes `openid profile`, with
     PKCE. The token it gets can only read who the user is.
  2. The page makes a P-256 key with `extractable: false`. Its public JWK
     thumbprint is the key id the ticket will name.
  3. The page reads the server's certificate hash over HTTPS from the same
     Fly app, then opens WebTransport with `serverCertificateHashes`.
  4. On the first stream the page sends the sign-in token, its public key and
     a signature over the session's server nonce. The server passes the
     token and key to `wt/ticket` through its own Bao login.
  5. The engine asks Hugging Face who the token belongs to, looks up the
     tuple `hf-<user>--joins--wt-demo`, and signs a ticket with its Ed25519
     key: subject, audience (the server's name), expiry, key thumbprint. It
     returns the ticket with no lease.
  6. The server checks the ticket against `wt/keys`, which it reads once at
     start and again when an unknown key id appears, then checks the proof.
     A reconnect within five minutes sends the ticket and a new proof, with
     no call to Bao or Hugging Face.
  :: details What each party is trusted with
  - The page: nothing. It is public code; a user can change it.
  - The server: the sign-in token in transit, which can only read the
    user's profile, and its own Bao login, whose policy reaches only
    `wt/ticket` and `wt/keys`. It cannot sign a ticket.
  - The engine: the signing key, which never leaves Bao storage, and the
    tuples. Per RFD 2316 it stores one key entry, its configuration and the
    tuples the operator writes, and nothing per ticket.
  - The network: nothing. The server's certificate is pinned by hash; the
    hash is served over the Fly app's HTTPS.
  :: details The demo
  A shared board of the last 50 lines, kept in the server's memory and lost
  on restart, on a bidirectional stream; datagrams on the same session echo
  a timestamp so the page shows the round trip.
  :: details Gates and controls
  Each gate has a control that must be refused:
  - a valid ticket and proof open a stream; no ticket is refused;
  - an expired ticket, a ticket for another audience, and a ticket signed by
    a key not in `wt/keys` are refused;
  - a valid ticket with a proof from another key is refused;
  - a signed-in user with no tuple gets no ticket;
  - the RFD 2316 growth gate on 1,000 tickets, with its storing control;
  - the page connects only when the pinned hash matches, and a page pinned
    to another hash fails to connect.
  :: details Steps that need the operator
  - Enrolling the server's Bao identity and mounting the PKI path take the
    root token (one 1Password approval).
  - Registering the plugin on weftspun-bao is a change to critical
    infrastructure and waits for a go-ahead.
  - The Fly app needs a dedicated IPv4 address for UDP, which is billed.
  - The Hugging Face OAuth app is created on the operator's account.
  """
end
