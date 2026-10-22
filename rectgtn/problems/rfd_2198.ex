# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2198-lladao-speed-work-for-dressing-overlay.exs
defmodule Rfd2198 do
  use Taskweft.DSL

  @name "rfd_2198"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2198": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2198": 0}}
  }

  @todo_list [
    ["prepare", "2198"],
    ["land", "2198"]
  ]
end
