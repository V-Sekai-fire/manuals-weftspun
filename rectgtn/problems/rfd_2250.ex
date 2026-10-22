# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2250-cloth-fit-as-one-burrito-binary.exs
defmodule Rfd2250 do
  use Taskweft.DSL

  @name "rfd_2250"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2250": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2250": 0}}
  }

  @todo_list [
    ["prepare", "2250"],
    ["land", "2250"]
  ]
end
