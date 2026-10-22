# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1080-fly-deploy-cost.exs
defmodule Rfd1080 do
  use Taskweft.DSL

  @name "rfd_1080"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1080": 3}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1080": 0}}
  }

  @todo_list [
    ["prepare", "1080"],
    ["land", "1080"]
  ]
end
