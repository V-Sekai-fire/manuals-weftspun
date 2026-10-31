# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2319, "a serving host's certificate comes from agent CA v2", :committed do
  feature "a host that serves on the tailnet gets a server certificate for its own agent identity,
signed by Bao's agent CA v2 without the root token"
  scope "weftspun-bao's `pki-agents` and `pki-agents-v2` mounts, the `csr-signer` policy, and
every stunnel or edge endpoint that serves under an agent identity"

  prose ~S"""
  :: hook
  A serving host gets its tailnet server certificate from agent CA v2, with no root token.
  :: intrigue
  Bao has two agent CAs, and nothing said which one does what. Bao signs a certificate in
  `pki-agents` that names the tailnet host anyway, and every client then rejects it.
  :: exit
  Read the details for the mounts and the `agent-endpoint` role.
  :: decision
  A host that serves takes a second certificate for its agent name from the
  `pki-agents-v2` mount, through role `agent-endpoint`. That role sets server
  and client use, allows `*.agents.weftspun`, `*.stonecat-ratio.ts.net` and
  tailnet addresses, caps a certificate at 90 days and stores no record of it.
  The `csr-signer` policy may sign through it, so an agent identity issues an
  endpoint certificate without the root token. The key is made on the host and
  never leaves it.
  :: related
  - RFD66606-2142 (Bao PKI service TLS), the first PKI mount.
  - RFD66606-2145 (certificate lifetimes), the 90-day leaf ceiling.
  - RFD66606-2316 (Bao bounded storage), why no record is stored.
  - RFD66606-2311 (Bonsai 2 serving), the first host to need this.
  """

  details_title "a serving host's certificate comes from agent CA v2"

  prose ~S"""
  :: details What failed
  `pki-agents`
  holds the agent CA, whose name constraints allow only `chibifire.com` and
  `agents.weftspun`. On 2026-10-16 a server certificate
  for the Linux 4090 host failed this way.
  :: details Sources
  Read on 2026-10-16 from the live cluster through the active `weftspun-fdb`
  machine: each mount's CA certificate and name constraints, the
  `csr-signer` policy, and the issuers on `pki-agents`. The Authority
  Information Access field of the Mac's own server certificate named
  `pki-agents-v2`, which is how that mount was found.

  :: details The mounts
  - `pki-agents`: issuer chibifire.com agent CA, constrained to `chibifire.com`
    and `agents.weftspun`. An agent signs with `agent-client`: client use
    only, 1 year.
  - `pki-agents-v2`: issuer chibifire.com agent CA v2, constrained to the two
    above, `stonecat-ratio.ts.net` and `100.64.0.0/10`. An agent signs with
    `agent-endpoint` (this RFD).
  - `pki`: issuer Intermediate CA v2, no constraints read. No agent role; its
    key is unreadable on the node.
  - `pki-listener`: issuer bao listener CA, constrained to Bao's own names.
    Bao's listener only.

  Every issuer chains to the chibifire.com Root CA, so a client that trusts
  the Root (`~/.bao.d/server-ca.pem` on the Mac) verifies both agent CAs.

  :: details The role
      pki-agents-v2/roles/agent-endpoint
        allowed_domains   agents.weftspun,stonecat-ratio.ts.net
        allow_subdomains  true
        allow_ip_sans     true
        enforce_hostnames true
        server_flag       true
        client_flag       true
        use_csr_sans      true
        ttl, max_ttl      2160h
        no_store          true

  With `no_store`, Bao keeps no copy and cannot revoke the certificate. Each
  one expires within 90 days, which is the revocation (RFD66606-2316). The login
  certificate an agent already holds stays as it is; the endpoint certificate
  is a second one for the same name.

  :: details Issuing one
  1. On the host, make a P-256 key and a request whose config file carries
     `extendedKeyUsage=serverAuth,clientAuth` and the subject names: the
     agent name, the host's `stonecat-ratio.ts.net` name and its tailnet
     address.
  2. Copy only the request off the host. An agent signs it with
     `pki-agents-v2/sign/agent-endpoint` under its own cert login.
  3. Install the leaf with agent CA v2 after it as the full chain, and leave
     the Root out of the chain.

  :: details Witnesses
  - **Chain.** `openssl verify -purpose sslserver` of the leaf against the
    Root, with agent CA v2 as the untrusted intermediate, prints OK. The
    same request signed on `pki-agents` fails with error 47, permitted
    subtree violation.
  - **Use.** A client-only `agent-client` leaf fails the same check with
    error 26, unsupported certificate purpose.
  - **Signer.** `bao token capabilities pki-agents-v2/sign/agent-endpoint`
    under an agent cert login returns create and update.

  The first two controls were run on 2026-10-16 and failed as planted, and
  the passing case ran the same day on the certificate below.

  :: details What went wrong first
  On 2026-10-16 the role was written on `pki-agents`, the mount the client
  role lives on. It signed a certificate for the Linux host that failed error
  47, and that certificate (serial `28:01:5a:de`) was revoked the same hour.
  A role named `agent-endpoint` already existed there and was overwritten
  without being read, so its earlier settings are lost. The `csr-signer`
  policy gained `pki-agents/sign/agent-endpoint` in the same write. Both
  were removed later that day, when the role was written on `pki-agents-v2`.

  `pki-agents-v2` already carried `agent-endpoint` and `agent-client`, both
  allowing `agents.weftspun`, `stonecat-ratio.ts.net` and tailnet addresses.
  The existing `agent-endpoint` had a one-year ceiling and stored each
  certificate; this RFD's write changed it to 90 days and `no_store`. The
  Mac's own server certificate came from that role before the change.

  The operator then requested the old settings back. Only the root token can
  write the role, and it sits in the password manager, which routine work
  does not use. The operator kept the 90-day role and had both certificates
  rotated through it instead.

  :: details The certificates in use
  Both were rotated on 2026-10-16 with a fresh P-256 key made on each host
  and signed by the Mac agent identity with no root token. Each is valid to
  2027-01-14, passes the chain gate, and matches its key.
  - `fedora-9a6c28.agents.weftspun`, serial `5d:9c:e6:f3`, at
    `~/.bao-creds/fedora-9a6c28/srv-fullchain.pem`. It replaces serial
    `21:f0:0c:1d`, issued earlier the same day, never served, and deleted
    with its key.
  - `mac-mini-fire-01b8f5.agents.weftspun`, serial `3e:dd:70:c0`, at
    `~/.bao-creds/mac-mini-fire-01b8f5/srv-fullchain.pem`. It replaces
    serial `60:1e:4b:98`, a one-year certificate from the old role. No
    agent identity may revoke on `pki-agents-v2`, so that one stays valid
    to 2027-10-12; nothing on the Mac reads it.
  """
end
