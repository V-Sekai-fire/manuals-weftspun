# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2417-github-activity-stays-in-our-two-organisations.exs
defmodule Rfd2417 do
  use Taskweft.DSL

  @name "rfd_2417"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2417": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2417": 2}}
  }

  @todo_list [
    ["prepare", "2417"],
    ["land", "2417"]
  ]
end
