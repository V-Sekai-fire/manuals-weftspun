# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 1078, "An H2O/FoundationDB game-state server", :abandoned do
  preamble ~S"""
  Developed in its own repository,
  [weftspun/h2o-bench-tpcc](https://github.com/weftspun/h2o-bench-tpcc)
  (`rfd/0022-weftspun-studio-consumer.md`,
  [PR #1](https://github.com/weftspun/h2o-bench-tpcc/pull/1)),
  per the user's own direction: `weftspun_studio` is a backend
  service, not the state database, so the open question belongs
  beside the project that would host the state, not here.
  """
end
