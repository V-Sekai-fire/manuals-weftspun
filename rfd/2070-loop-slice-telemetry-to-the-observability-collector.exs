# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2070. `mix rfd.render` renders rfd/2070-loop-slice-telemetry-to-the-observability-collector/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2070 do
  use RFD.DSL

  rfd 2070, "Loop slice telemetry to the observability collector" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `a6eb679`.
    """

    problem ~S"""
    The loop-slice server emits OpenTelemetry through the `OpenTelemetry`
    C++ engine module: spans for the loop's phases, counters and gauges
    for grants and ticks, and log lines. Export is opt-in. The server
    reads `OTEL_EXPORTER_OTLP_ENDPOINT`, and with no endpoint set it stays
    idle — it records signals in process but exports nothing, which keeps
    a server that has no collector from retrying against one that is not
    there. The observability stack
    (`rfd/200b-observability-stack-victoriatraces`) runs an OTEL collector
    """

    related ~S"""
    The full argument is in git at `a6eb679`.
    """

    drafted_by :ai
  end
end
