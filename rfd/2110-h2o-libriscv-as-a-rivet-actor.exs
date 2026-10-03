# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2110, "H2o libriscv as a rivet actor", :abandoned do
  prose ~S"""
  :: decision
  The full argument is in git at `a6eb679`.
  :: problem
  | Item | Value | | ---------------- |
  ------------------------------------------------------------ | | Port
  | The `PORT` environment variable | | Readiness | The port must open
  within 30 seconds, by default | | Shutdown | `SIGTERM`, then 25
  seconds grace, then `SIGKILL`, by default | | Raw HTTP | Arrives under
  `/request/*`, which the runner strips | | WebSocket | Clients use the
  `rivet` subprotocol | | Per-actor config | CBOR `input`, with
  `command`, `args`, and `env` |
  :: related
  The full argument is in git at `a6eb679`.
  """
end
