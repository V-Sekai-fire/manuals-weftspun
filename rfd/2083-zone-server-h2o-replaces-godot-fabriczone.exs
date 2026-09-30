# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2083. `mix rfd.render` renders rfd/2083-zone-server-h2o-replaces-godot-fabriczone/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2083 do
  use RFD.DSL

  rfd 2083, "Zone server h2o replaces godot fabriczone" do
    state :abandoned

    decision ~S"""
    The full argument is in git at `a6eb679`.
    """

    problem ~S"""
    The production zone server (`zone-server`, deployed as
    `multiplayer-fabric-zone` on Fly.io) is a boot scaffold today:
    OpenTelemetry init only, no WebTransport listener, no game logic
    (`project/main.gd`'s own `TODO(cycle-5)` comment). The real
    entity/simulation engine,
    `FabricZone`/`FabricZoneJournal`/`FabricMMOGZone`, exists as a working
    Godot C++ module in `V-Sekai-fire/multiplayer-fabric-build`
    (`godot/modules/multiplayer_fabric/`) but has never been wired into a
    """

    related ~S"""
    The full argument is in git at `a6eb679`.
    """

    drafted_by :ai
  end
end
