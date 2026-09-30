# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 1077. `mix rfd.render` renders rfd/1077-h2o-edge-cdn/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD1077 do
  use RFD.DSL

  rfd 1077, "An H2O edge, not yet a CDN" do
    state :abandoned

    scope "the deploy target, `apps/weftspun_studio/`, `apps/usd_viewer_app/`"

    attest_in :none

    decision ~S"""
    Not yet, and not that repo. `h2o-bench-tpcc`
    is a TPC-C benchmark harness with no reverse-proxy or caching code,
    and real H2O itself, checked against its own directive reference,
    has no response-caching module at all, unlike nginx's `proxy_cache`
    or Varnish. A multi-region H2O deployment gives closer HTTP/3
    termination, not a cached origin fetch; the slow hop this problem
    names would still cross regions on every request.

    The GREEN step ships instead: `Cache-Control` headers, at the
    existing origin, no new service. RFD 1058 and RFD 1067 both already
    found no load that needs more than this. If load ever does, the
    REFACTOR step names Tigris, Fly's own S3-compatible object storage
    with automatic edge replication, not H2O.
    """

    problem ~S"""
    The gallery's proxy chain (RFD 1076) sets no `Cache-Control`
    anywhere. Every asset, including the multi-megabyte `emHdBindings.wasm`
    and `.data` files, refetches on every request, through two Fly
    machines, both in `sjc`. The user asked for "a fast CDN," and named
    `h2o-bench-tpcc`'s own `libh2o` dependency as the mechanism.
    """

    related ~S"""
    RFD 1076 gives the proxy chain this fixes. RFD 1058 and RFD 1067
    give the "no demonstrated load" finding this reapplies. RFD 1073
    adopts this RFD's REFACTOR step, Tigris, for a different reason:
    not load, but that `versitygw` (RFD 1058's loopback-only bind)
    became unreachable from `apps/usd_viewer_app/` once RFD 1076 split
    it onto its own machine. A real reachability blocker, not a
    capacity one, moved that decision to "now," not "if load ever does."
    """

    drafted_by :ai
  end
end
