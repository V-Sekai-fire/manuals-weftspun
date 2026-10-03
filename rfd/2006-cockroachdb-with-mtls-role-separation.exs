# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2006, "Cockroachdb with mtls role separation", :abandoned do
  prose ~S"""
  :: decision
  Use CockroachDB, with separate mTLS client certificates for schema
  migrations (DDL) and application queries (DML).
  :: problem
  The stack needs a relational database reachable by the Elixir gateway
  and the Phoenix zone backend. It must support schema migrations (DDL)
  separately from application queries (DML) to limit blast radius if
  application credentials are compromised.
  :: related
  RFD 1020 names the catalog store. RFD 2075 names the zone state store.
  """
end
