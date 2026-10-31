# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2368-station-parity-is-measured-against-a-warp-render.exs
defmodule Rfd2368 do
  use Taskweft.DSL

  @name "rfd_2368"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2368": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2368": 2}}
  }

  @todo_list [
    ["prepare", "2368"],
    ["land", "2368"]
  ]
end
