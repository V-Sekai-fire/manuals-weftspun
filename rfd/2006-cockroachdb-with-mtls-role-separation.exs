# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2006. `mix rfd.render` renders rfd/2006-cockroachdb-with-mtls-role-separation/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2006 do
  use RFD.DSL

  rfd 2006, "Cockroachdb with mtls role separation" do
    state :abandoned

    decision ~S"""
    Use CockroachDB, with separate mTLS client certificates for schema
    migrations (DDL) and application queries (DML).
    """

    problem ~S"""
    The stack needs a relational database reachable by the Elixir gateway
    and the Phoenix zone backend. It must support schema migrations (DDL)
    separately from application queries (DML) to limit blast radius if
    application credentials are compromised.
    """

    related ~S"""
    RFD 1020 names the catalog store. RFD 2075 names the zone state store.
    """

    drafted_by :ai
  end
end
