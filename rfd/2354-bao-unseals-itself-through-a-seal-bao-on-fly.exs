# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2354, "Bao unseals itself through a Seal Bao on Fly", :discussion do
  scope "the seal of every Bao, its key, and its recovery."
  attest_in :details

  prose ~S"""
  :: hook
  Bao restarts and unseals with no person at the keyboard.
  :: intrigue
  Three Baos mean three seal states and three unseal calls per fleet restart.
  :: exit
  Pass the recovery test on clean hosts before prod moves; the sections below hold the steps.
  :: decision
  A transit seal on a Seal Bao on Fly, unwrapped from Fly KMS at boot (operator,
  2026-10-30). Recovery becomes hands-off, not operator-with-1P. Superseded on 2026-11-01:
  Bao runs as one Fly machine and unseals from Fly KMS at boot, with an offline division of
  the seal key with n=1 as the last resort (operator, 2026-11-01).
  :: related
  RFD66606-2144, RFD66606-2145, RFD66606-2146.
  Split from the old RFD66606-2147: RFD66606-2353 (replicas), 2355 (cache), 2356 (no CDN proxy).
  """

  details_title "Bao unseals itself through a Seal Bao on Fly"

  prose ~S"""
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
  (the day RFD66606-2144 logs as its eleventh defect) is the Seal Bao's static key, held offline
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
  - A node lists the modes it has in order and uses the first that works, for example
    `tpm`, then `kms`, then `passkey`, then `manual`. Each node wraps the key once per
    mode it lists, so any one is enough (operator, 2026-10-30). The script logs which mode
    unwrapped the key, so a fallback shows. Splitting the key so that several modes are all
    required is not used: one broken mode would then block the start.
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
  :: details Migration to the transit seal
  Stand up the Seal Bao on Fly and pass its recovery test, add a `seal "transit"`
  block to the Fly config, and migrate with one last Shamir unseal (`-migrate`).
  The Shamir key stays offline as the recovery key.
  :: details Sub-decisions open
  - The seal provider: a Seal Bao on Fly, unwrapped from Fly KMS (operator, 2026-10-30).
  - Whether the Seal Bao runs as one machine or as three voters; both are allowed.
  - Where the offline copy of the Seal Bao's key is kept.
  - Whether to write the CRL-loop fix (a separate bug) into this
    rollout or before it.
  :: details Sources
  - Vault auto-unseal precedent for the KMS wrapper pattern
    (`cloud kms auto-unseal`, applies unchanged to OpenBao forks).
  - RFD66606-2144 (its eleventh defect: the without-auto-unseal failure mode).
  :: details The problem
  Bao was one machine, Shamir seal single share, operator+1P recovery per restart. Shamir with a
  manual share is the right seal for one-of-one, wrong for three-of-three.
  """
end
