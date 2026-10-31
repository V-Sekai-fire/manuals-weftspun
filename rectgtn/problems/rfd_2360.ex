# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2360-the-campus-ships-one-beta.exs
defmodule Rfd2360 do
  use Taskweft.DSL

  @name "rfd_2360"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2360": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2360": 1}}
  }

  @todo_list [
    ["prepare", "2360"],
    ["land", "2360"]
  ]
end
