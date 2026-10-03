# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2083, "Zone server h2o replaces godot fabriczone", :abandoned do
  prose ~S"""
  :: decision
  The full argument is in git at `a6eb679`.
  :: problem
  The production zone server (`zone-server`, deployed as
  `multiplayer-fabric-zone` on Fly.io) is a boot scaffold today:
  OpenTelemetry init only, no WebTransport listener, no game logic
  (`project/main.gd`'s own `TODO(cycle-5)` comment). The real
  entity/simulation engine,
  `FabricZone`/`FabricZoneJournal`/`FabricMMOGZone`, exists as a working
  Godot C++ module in `V-Sekai-fire/multiplayer-fabric-build`
  (`godot/modules/multiplayer_fabric/`) but has never been wired into a
  :: related
  The full argument is in git at `a6eb679`.
  """
end
