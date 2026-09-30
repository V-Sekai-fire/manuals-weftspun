# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2110. `mix rfd.render` renders rfd/2110-h2o-libriscv-as-a-rivet-actor/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2110 do
  use RFD.DSL

  rfd 2110, "H2o libriscv as a rivet actor" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `a6eb679`.
    """

    problem ~S"""
    | Item | Value | | ---------------- |
    ------------------------------------------------------------ | | Port
    | The `PORT` environment variable | | Readiness | The port must open
    within 30 seconds, by default | | Shutdown | `SIGTERM`, then 25
    seconds grace, then `SIGKILL`, by default | | Raw HTTP | Arrives under
    `/request/*`, which the runner strips | | WebSocket | Clients use the
    `rivet` subprotocol | | Per-actor config | CBOR `input`, with
    `command`, `args`, and `env` |
    """

    related ~S"""
    The full argument is in git at `a6eb679`.
    """

    drafted_by :ai
  end
end
