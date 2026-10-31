# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2414-no-workflow-or-background-subagent-runs-unless-the-operator-asks.exs
defmodule Rfd2414 do
  use Taskweft.DSL

  @name "rfd_2414"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2414": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2414": 2}}
  }

  @todo_list [
    ["prepare", "2414"],
    ["land", "2414"]
  ]
end
