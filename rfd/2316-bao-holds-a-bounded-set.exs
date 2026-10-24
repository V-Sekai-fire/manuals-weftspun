# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2316, "Bao holds a bounded set", :discussion do
  flight_level :l2
  feature "Bao's storage stays the same size whatever the number of users, sessions or requests"
  scope "weftspun-bao on weftspun-fdb, every secrets engine and auth method mounted on it, and
the plugins built for it"

  prose ~S"""
  :: decision
  - Bao stores keys, configuration, policies and ReBAC tuples, and nothing that
    grows with users, sessions or requests (operator, 2026-10-13).
  - An engine that issues a credential per request keeps no lease and no record
    of it. The credential carries its own expiry and is never revoked.
  - Application data lives outside Bao, in the service that owns it.
  - Every engine ships a growth gate: issuing many credentials leaves the
    engine's storage unchanged, and a control that stores each one fails it.
  :: problem
  Bao's storage is FoundationDB on three small machines, and the FDB backend
  writes each entry as one FDB value. FoundationDB refuses a value over
  100,000 bytes and a transaction over 10,000,000 bytes, so the limit is part
  of the design and not a setting. Bao's default is to keep a lease for every
  dynamic secret, so an engine on the defaults grows with its traffic until a
  write fails.
  :: related
  - RFD66606-2140, Bao on FDB.
  - RFD66606-2147, Bao is critical infrastructure now.
  - RFD66606-2200, ReBAC agent roles.
  - RFD66606-2317, the first engine held to this rule.
  """

  details_title "Bao holds a bounded set"

  prose ~S"""
  :: details Sources
  Written on 2026-10-13 from the operator's note that Bao has a hard data
  limit by design. The FDB backend was read in our OpenBao fork: `Put`
  calls one `Set` with the whole encrypted entry and splits nothing. The
  value and transaction limits are FoundationDB's published known limits.
  Neither limit has been measured on our cluster yet; the first engine's
  end-to-end test writes an entry just under and just over 100,000 bytes and
  records which one FDB refuses.
  :: details What may be stored
  An entry belongs in Bao when the count of such entries is set by the
  operator, not by traffic:
  - signing keys, CA keys and certificates of issuers;
  - engine and mount configuration;
  - policies, cert roles and ReBAC tuples;
  - one-off secrets an operator puts there, such as an API token.

  These do not belong in Bao:
  - a lease or record per issued credential;
  - sessions, messages, counters, logs or audit trails of a service;
  - files and blobs of any size.

  An engine that needs to hold a resource for a while, such as a slot in a
  shared cap, may still use a lease, because the number of leases is capped
  by the resource and not by traffic. Its growth gate then checks that the
  lease count stays at or under the cap.
  :: details The growth gate
  Each engine's unit tests run against `logical.InmemStorage` and count its
  keys with a recursive `List` before and after issuing 1,000 credentials.
  The gate passes when the count and the summed value size are unchanged.
  The control flips the engine to store each credential and must fail the
  same gate. The end-to-end test does the same against a dev server and also
  checks that the response carries no lease id.
  """
end
