# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2355, "Consumers cache Bao reads in memory", :discussion do
  scope "every consumer of Bao: DNS, R2 writes, FDB coordinator lookup."
  attest_in :details

  prose ~S"""
  :: hook
  A consumer that holds a bearer for a few minutes keeps Bao out of its critical path.
  :: intrigue
  Every read against Bao is a Bao dependency.
  :: exit
  On a Bao error, retry; do not hold the stale value.
  :: decision
  Consumers cache what they can. A bearer held for a few minutes puts Bao in the critical
  path only at cache expiry.
  :: problem
  RFD66606-2146 moved every routine credential read onto Bao, so every consumer now depends on
  Bao being up.
  :: related
  RFD66606-2145, RFD66606-2146.
  Split from the old RFD66606-2147: RFD66606-2353 (replicas), 2354 (unseal), 2356 (no CDN proxy).
  """

  details_title "Consumers cache Bao reads in memory"

  prose ~S"""
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
  """
end
