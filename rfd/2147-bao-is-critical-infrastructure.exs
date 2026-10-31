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
  2. **Auto-unseal.** A transit seal on a Seal Bao on Fly, unwrapped from Fly KMS at boot
     (operator, 2026-10-30). It replaces the Mac mini seal, which the operator rescinded.
  3. **Consumers cache what they can.** A bearer held for a few
     minutes puts Bao in the critical path only at cache expiry.
  4. **No CDN proxy in front of workspace services.** CF-proxied
     records have Cloudflare terminating TLS at its edge, every byte
     plaintext at CF for the round trip. Workspace services stay
     DNS-only; edge cache, if needed, is Fly-side or origin-side.

  Details, sub-decisions, migration in `DETAILS.md`. S2147.
  :: problem
  Bao was one machine, Shamir seal single share, operator+1P recovery
  per restart. RFD66606-2140's `ha_enabled = "false"` fit that framing.
  RFD66606-2146 then moved every routine credential read, coordination write,
  and policy check onto Bao. Every consumer now depends on Bao being
  up, and RFD66606-2140's reliability budget is smaller than what routes
  through Bao now needs.
  :: related
  RFD66606-2140, RFD66606-2144, RFD66606-2145, RFD66606-2146.
  """

  details_title "Bao is critical infrastructure now"

  prose ~S"""
  :: details Why HA now, not before
  RFD66606-2140 chose `ha_enabled = "false"` when Bao was one machine and one
  operator. Under that arrangement, Bao being down meant one thing was
  down: the Bao API. Everything else routed around Bao by holding its
  credentials in Fly secrets or 1P.

  RFD66606-2146 turned that inside out. Every consumer now authenticates to
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

  Recommendation: Fly KMS, through a Seal Bao. Fly app secret keys are a
  first-party KMS, usable only from inside a machine of the owning app, and
  OpenBao has no Fly seal type, so a Seal Bao bridges the two (operator,
  2026-10-30). The break-glass key for the day the KMS itself is the outage
  (RFD66606-2144 defect #11's day) is the Seal Bao's static key, held offline
  as a Shamir share, whose count may be 1.

  An auto-unseal wrapper does not change the CRL-loop bug logged
  during the DR (Bao's authenticated paths going flaky after a
  particular sequence of issuer imports). That is a separate item.
  :: details Transit seal on Fly, unwrapped by Fly KMS
  The operator chose on 2026-10-13 to unseal the Fly instances from a small Bao,
  rescinded the Mac mini as its host on 2026-10-30, and chose a Seal Bao on Fly that
  unwraps its own key from Fly KMS (operator, 2026-10-30).

  - Encrypt and decrypt with a Fly secret key work only from inside a machine of the
    owning app, through the machine's local API socket; the public API refuses. The Seal
    Bao's start-up script decrypts a wrapped 32-byte key into memory and starts Bao with a
    `static` seal. Every other Bao uses a stock transit seal against it.
  - The Seal Bao runs as one machine or as an HA set of three voters. Two voters tolerate
    no failure, so two is not a valid setting (operator, 2026-10-30). One machine relies on
    a restore from backup that has been tested.
  - It listens only on its tailnet address, over TLS, and the tailnet policy lets only Bao
    nodes reach it. No peer reaches a localhost or public listener.
  - Each Bao has its own transit key and a policy limited to encrypt and decrypt on that
    key. A certificate login yields a short token, but a seal needs its token at boot, so
    each Bao also holds a periodic orphan token for its key: a Fly secret on the Fly
    instances, a file readable only by its own user elsewhere. Measured on a throwaway Bao,
    the seal renews that token while the Bao runs; the token expires if the Bao is down
    longer than its period, so the period is set to days and a longer outage needs a new
    token.
  - If the Seal Bao is down, a restarted Bao stays sealed until it is back. Running Baos
    keep serving.
  - The break-glass key is the Seal Bao's static key, held offline as a Shamir share even
    when the count is 1, and never in the backup bucket. A new Seal Bao started with that
    key and a restored snapshot unlocks every other Bao. Each Bao's Shamir recovery keys
    authorise operations such as generating a root token; they do not unseal.
  - The Seal Bao backs up to the same bucket as the others, under its own prefix, with
    unique object names and a retention lock; plain-text config files stay out of the
    snapshots and are protected separately.
  - The change is proved with a planted control: with the Seal Bao stopped, a restarted
    Bao stays sealed. The recovery test passes before prod moves: on clean hosts with Fly
    blocked, restore the Seal Bao from the offline key and the backup, then restore one
    other Bao through it and read back data.
  :: details Recovery without Fly KMS
  This procedure needs no Fly account, no Fly machine and no network path to Fly. It is
  the one the recovery test runs (operator, 2026-10-30).

  1. Gather the materials: the offline Shamir share or shares of the Seal Bao's static
     key, the Seal Bao's configuration without its secrets, and the newest snapshot of
     the Seal Bao from the backup bucket.
  2. Rebuild the key: combine the shares into the 32-byte key (one share is the key
     itself). Check the length and the key id the configuration names before use.
  3. Start a new Seal Bao on any host with a `static` seal whose key is a file in memory
     backed storage, and with the same listener rules: tailnet address, TLS.
  4. Restore the snapshot into it. Whether the restore needs the force option under a
     fresh barrier is not yet measured; the recovery test settles it.
  5. Check that the transit keys, the policies and the cert roles are back, and that one
     other Bao unseals through the new address with its existing periodic token.
  6. Point the other Baos at the new address if it changed, one at a time.
  7. Resume hands-off unsealing by wrapping the key with a new KMS, or by leaving it
     manual until one exists. A Bao that stays up needs none of this; only a restart does.
  8. Write down what the restore took and which step was unclear, then amend this block.

  The key never leaves the offline store except during steps 2 and 3, and the memory copy
  is destroyed when the host stops.
  :: details Alternative wrapper: a passkey
  Fly KMS is the hands-off wrapper. A passkey can wrap the same 32-byte static key when no
  Fly KMS is available, at the price of a person at every restart (operator, 2026-10-30).
  The route has not been run here; the recovery test measures it.

  - **Passkey.** A passkey whose authenticator offers a secret-derivation extension can
    derive a wrapping key from a challenge, with a touch. Support differs by authenticator
    and by client library, so confirm that the same credential returns the same secret on
    a second host before relying on it. A passkey that only signs cannot wrap anything.
  - **Hardware seal in Bao.** OpenBao can seal through a PKCS#11 module, but that needs a
    token that decrypts or unwraps with a mechanism the seal supports; whether a passkey
    does is not known. Until measured, the passkey wraps the static key and Bao keeps its
    `static` seal.
  - Keep two passkeys, stored apart, since one lost token otherwise ends recovery. A
    passkey stays out of the backup bucket and off any Fly host.
  :: details How the key arrives, and rotating the seal
  A Bao on a `static` seal holds one 32-byte key. How that key reaches the process is a
  mode in the start-up script, not part of the seal. Every mode supplies the same key, so
  a node changes mode with no migration (operator, 2026-10-30).

  - `tpm`: a non-exportable TPM key unwraps a wrapped copy of the key at start, with no
    PIN and no touch. The wrapped file opens only on that machine.
  - `kms`: the start-up script asks the Seal Bao, or on Fly the machine's own KMS, for
    the key.
  - `passkey`: a person touches the passkey at each start.
  - `manual`: the script asks a person for the key, for example from the offline Shamir
    shares, and then starts Bao. Bao does not start without the key, and a `static` seal
    has no manual unseal of its own. A node left in this mode starts nothing on its own.
  - The plain key is held in memory-backed storage only for the start, and the file is
    deleted once Bao reports unsealed.
  - Changing the seal type is a different act: it is seal key rotation, run with
    `bao operator unseal -migrate` while the old seal still answers, and it needs a
    restart.

  Measured on the operator's desktop on 2026-10-30, a TPM 2.0 firmware TPM: a 32-byte key
  wrapped to a non-exportable key unwrapped to the same bytes; a changed byte in the
  wrapped file, an export of the private key and a deleted key were each refused. A Bao
  with a `static` seal fed by that unwrap initialised, restarted and unsealed with nobody
  typing, and a wrong key left it sealed. Not measured: a reboot, a copy of the wrapped file
  on another machine, and the `kms`, `passkey` and `manual` modes. The Steam Deck shows a
  TPM 2.0 device that `systemd-creds` cannot use without root; the Steam Frame is
  unchecked.
  :: details Consumer-side cache: what and for how long
  Every read against Bao is a Bao dependency. Two ends of the spectrum:

  - Never cache. Simple, correct, hot dependency on Bao.
  - Cache forever. Wrong for rotating secrets (RFD66606-2145 leaves at
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
  4. Stand up the Seal Bao on Fly and pass its recovery test, add a `seal "transit"`
     block to the Fly config, and migrate with one last Shamir unseal (`-migrate`).
     The Shamir key stays offline as the recovery key.
  :: details A desk reaches the active instance
  Read on 2026-10-16. The three instances elect one leader, and only the
  leader answers a login; a standby redirects to the leader's
  `<machine>.vm.weftspun-fdb.internal` address, which no desk resolves.
  Two of the three carried tailnet names that day (`weftspun-bao-3`,
  `weftspun-bao-4`), both unsealed standbys, and the leader, the third
  machine, had none, so a desk asking the tailnet found no
  leader and the desk helper exited without a word.

  The route that worked: read `sys/leader` from any instance (no token,
  mTLS only), take the machine id out of `leader_address`, and run
  `fly proxy 8200:8200 <id>.vm.weftspun-fdb.internal -a weftspun-fdb` as a
  background process. The desk then uses `BAO_ADDR=https://127.0.0.1:8200`
  with `BAO_TLS_SERVER_NAME=weftspun-bao.internal` and its agent
  certificate. The proxy exits on its own after some minutes; a
  `connection refused` on 127.0.0.1:8200 means restart it, not that Bao
  is down.

  The retired `weftspun-bao` app still exists, stopped. `fly proxy -a
  weftspun-bao` fails with `host was not found in DNS` because nothing
  runs there, and starting its machine brings up a second Bao against the
  same FDB storage, which stops again within a minute. It was started
  twice that day by mistake before the route above was found; it is not
  started again, and its deletion is an open item.
  :: details Sub-decisions open
  - Delete the retired `weftspun-bao` app and its volume, so a desk
    cannot start a second Bao by mistake.
  - Every instance joins the tailnet under its own name, or the leader's
    name is published where a desk can read it without a Fly login.
  - 3 replicas, one per FDB machine (operator, 2026-10-13).
  - Standbys serve reads (`disable_performance_standby = false`) vs
    forward to leader. Read-heavy workload argues for serving.
  - The seal provider: a Seal Bao on Fly, unwrapped from Fly KMS (operator, 2026-10-30).
  - Whether the Seal Bao runs as one machine or as three voters; both are allowed.
  - The FDB and Bao data machines run as one machine or as an HA set; the one-machine form
    relies on tested backups (operator, 2026-10-30).
  - Where the offline copy of the Seal Bao's key is kept.
  - Whether to write the CRL-loop fix (a separate bug) into this
    rollout or before it.
  :: details Sources
  - OpenBao HA storage docs (FDB backend supports HA via leader
    election on the shared FDB cluster).
  - Vault auto-unseal precedent for the KMS wrapper pattern
    (`cloud kms auto-unseal`, applies unchanged to OpenBao forks).
  - RFD66606-2140 (Bao on FDB, this raises its ambition), 2144 (defect
    #11: the without-auto-unseal failure mode), 2145 (leaf and CA
    rotation cadence this HA has to survive), 2146 (the capability
    topology this now underwrites).
  """
end
