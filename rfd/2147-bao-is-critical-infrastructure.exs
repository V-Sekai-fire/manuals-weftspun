# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2147, "Bao is critical infrastructure now", :discussion do
  scope "weftspun-bao, its consumers, its DR runbook."
  attest_in :details

  prose ~S"""
  :: decision
  Bao's availability class rises to match its consumers'. Recovery
  becomes hands-off, not operator-with-1P.

  1. **Replicas on the FDB machines, coordinated over FDB.** `ha_enabled = true`,
     one Bao beside each of the three weftspun-fdb machines (operator, 2026-10-13).
  2. **Auto-unseal.** A transit seal on a small Bao on the operator's Mac mini, which
     unlocks itself from the macOS Keychain at boot (operator, 2026-10-13).
  3. **Consumers cache what they can.** A bearer held for a few
     minutes puts Bao in the critical path only at cache expiry.
  4. **No CDN proxy in front of workspace services.** CF-proxied
     records have Cloudflare terminating TLS at its edge, every byte
     plaintext at CF for the round trip. Workspace services stay
     DNS-only; edge cache, if needed, is Fly-side or origin-side.

  Details, sub-decisions, migration in `DETAILS.md`. S2147.
  :: problem
  Bao was one machine, Shamir seal single share, operator+1P recovery
  per restart. RFD 2140's `ha_enabled = "false"` fit that framing. RFD
  2146 then moved every routine credential read, coordination write,
  and policy check onto Bao. Every consumer now depends on Bao being
  up, and RFD 2140's reliability budget is smaller than what routes
  through Bao now needs.
  :: related
  RFD 2140, 2144, 2145, 2146.
  """

  details_title "Bao is critical infrastructure now"

  prose ~S"""
  :: details Why HA now, not before
  RFD 2140 chose `ha_enabled = "false"` when Bao was one machine and one
  operator. Under that arrangement, Bao being down meant one thing was
  down: the Bao API. Everything else routed around Bao by holding its
  credentials in Fly secrets or 1P.

  RFD 2146 turned that inside out. Every consumer now authenticates to
  Bao with its per-service cert, reads its credentials from Bao at
  runtime, and coordinates state through Bao's KV. When Bao goes down,
  the DNS-editing path goes down, the R2-write path goes down, the FDB
  coordinator info lookup goes down, and any new spend gate that
  follows the same pattern goes down with them. The single-machine
  posture that was fine as a convenience store is not fine as the
  switchboard.
  :: details Colocated on the FDB machines
  The operator chose on 2026-10-13 to run Bao on the three weftspun-fdb
  machines instead of in its own app. The Fly plan in use includes
  three `shared-cpu-1x` 256 MB machines and 3 GB of volumes; three FDB
  machines plus a separate Bao machine overran both, and the separate
  machine bought no redundancy. FDB keeps `double` redundancy and three
  coordinators, so one machine may still be lost.

  Each machine runs fdbserver, the backup agent, Bao, tailscaled and
  sshd, at 512 MB. Measured on 2026-10-13 at 256 MB: an FDB machine used
  about 130 MB, and the Bao machine about 130 MB, of which Bao was 77 MB,
  tailscaled 26 MB and the plugin 18 MB. The two together do not fit in
  the 207 MB a 256 MB machine leaves usable.

  - The `weftspun-bao` app retires once the three instances serve. Its
    volume held no secrets: Bao's storage is FDB, and the volume kept the
    tailnet identity, the SSH host key and renewed listener certificates.
  - Each instance advertises its own machine address as `api_addr` and
    `cluster_addr`, so standbys forward to the active instance. Standbys
    are not assumed to serve reads.
  - Clients keep verifying the listener as `weftspun-bao.internal`; the
    name in the certificate does not move with the app.
  - One machine carries the existing tailnet state and keeps the
    `weftspun-bao` node; the others join under their own names.
  - The SSH tunnel port is balanced across all three machines, so they
    share one host key, held as a secret rather than generated per
    volume.
  - The change is proved on a throwaway three-machine app before
    weftspun-fdb is touched: an initialised test Bao, a secret written
    and read back, one machine restarted and unsealed while the others
    keep serving.
  :: details Replicas: 3 in sjc, coordinated over FDB
  OpenBao's FDB backend supports HA by leader election over the same
  storage the writes go to. One instance runs on each FDB machine, so
  Bao spreads across the same three zones FDB does.

  Standby replicas can either serve reads directly or forward every
  request to the leader. Read-serving standbys would suit the read/write
  ratio the cert-auth path establishes (many reads per one write); until
  the fork is shown to serve reads from a standby, standbys forward.

  The 3-machine scale exposes one wrinkle: three machines mean three
  seal states, three unseal calls per fleet restart. This is the reason
  auto-unseal stays the goal.
  :: details Auto-unseal: KMS wrapper, Shamir stays as break-glass
  Shamir with a manual share is the right seal for one-of-one, wrong for
  three-of-three. Options:

  - **Cloud KMS seal** (AWS KMS, GCP KMS, Azure Key Vault, Oracle). The
    key stays in the cloud KMS; Bao decrypts the master key at boot via
    the KMS API. Standard pattern. Cost is per-request against the KMS,
    measured in fractions of a cent per unseal.
  - **Transit seal** (a second, seed-only Bao). Chicken-and-egg unless
    the seed Bao is truly offline (Raspberry Pi, HSM, boot-from-USB).
    Adds a second thing to maintain.
  - **HSM / PKCS#11**. Right answer for a fleet in a datacenter with
    its own HSM. Overkill for this workspace's scale.
  - **HCP Vault / OpenBao managed**. Not this workspace's shape.

  Recommendation: cloud KMS. The workspace does not yet have a KMS
  account of any of the three big providers; standing one up is the
  tax. Fly does not offer a first-party KMS at this scale. The Shamir
  key in 1P stays as break-glass for the day the KMS itself is the
  outage (RFD 2144 defect #11's day).

  An auto-unseal wrapper does not change the CRL-loop bug logged
  during the DR (Bao's authenticated paths going flaky after a
  particular sequence of issuer imports). That is a separate item.
  :: details Transit seal on the Mac mini
  The operator chose on 2026-10-13 to unseal the Fly instances from a
  small Bao on the Mac mini, after declining to have the Fly instances
  unseal each other from a key kept in Bao itself. The Mac is always on
  and already on the tailnet; it holds no other Bao data.

  - The seal Bao keeps file storage on the Mac and a transit key whose
    only use is wrapping the Fly cluster's root key. Its own seal is a
    static key read from the macOS Keychain when the launchd agent
    starts, so a reboot of the Mac needs no approval. Anyone holding the
    Mac's logged-in session can therefore unseal the Fly cluster; the
    operator accepted that.
  - The seal Bao listens only on the Mac's tailnet address, with mutual
    TLS, and the tailnet policy lets only the Fly Bao nodes reach it.
  - The Fly instances authenticate with a periodic orphan token limited
    to encrypt and decrypt on that one key, held as a Fly secret.
  - If the Mac is off or off the tailnet, a restarted Fly instance stays
    sealed until it is back. The instances still running keep serving.
  - After migration the Shamir key becomes a recovery key: it authorises
    operations such as generating a root token, but it no longer
    unseals. Losing the seal Bao would lose the Fly cluster, so its
    storage and its static key are backed up to 1Password.
  - The change is proved on a throwaway three-machine app first: a cold
    start of all three unseals without a human, and a planted control
    with the Mac's listener stopped must leave a restarted instance
    sealed.
  :: details Consumer-side cache: what and for how long
  Every read against Bao is a Bao dependency. Two ends of the spectrum:

  - Never cache. Simple, correct, hot dependency on Bao.
  - Cache forever. Wrong for rotating secrets (RFD 2145 leaves at
    90 days; a hot bearer at hour 720 leaks past its rotation).

  The middle: cache for a duration shorter than the shortest thing the
  cached value protects. For a DNS bearer that itself has a Cloudflare
  API-token lifetime, minutes-to-an-hour is safe. For an FDB cluster
  file that changes only on a scale event, an hour is safe. Cache
  should live in the CONSUMER's memory, not on disk, and it should
  refresh on a Bao error by simply retrying rather than by holding the
  stale value.
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
  :: details Migration path
  Enabling all of this on the live cluster is:

  1. Update `service-openbao/config-fdb.hcl`: `ha_enabled = "true"`.
  2. Build one image carrying the FDB server and Bao, and deploy it to
     the three weftspun-fdb machines one at a time, unsealing each.
  3. Stop the `weftspun-bao` app, then destroy it once the three serve.
  4. Stand up the seal Bao on the Mac mini, add a `seal "transit"` block
     to the Fly config, and migrate with one last Shamir unseal
     (`-migrate`). The Shamir key stays in 1Password as the recovery key.

  A cloud KMS can replace the Mac later through the same seal migration.
  :: details Sub-decisions open
  - 3 replicas, one per FDB machine (operator, 2026-10-13).
  - Standbys serve reads (`disable_performance_standby = false`) vs
    forward to leader. Read-heavy workload argues for serving.
  - The seal provider: the Mac mini's transit Bao (operator, 2026-10-13).
  - Whether to write the CRL-loop fix (a separate bug) into this
    rollout or before it.
  :: details Sources
  - OpenBao HA storage docs (FDB backend supports HA via leader
    election on the shared FDB cluster).
  - Vault auto-unseal precedent for the KMS wrapper pattern
    (`cloud kms auto-unseal`, applies unchanged to OpenBao forks).
  - RFD 2140 (Bao on FDB, this raises its ambition), 2144 (defect
    #11: the without-auto-unseal failure mode), 2145 (leaf and CA
    rotation cadence this HA has to survive), 2146 (the capability
    topology this now underwrites).
  """
end
