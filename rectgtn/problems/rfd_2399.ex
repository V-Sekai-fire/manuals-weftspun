# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2399-the-zone-journal-lives-in-bao-over-foundationdb.exs
defmodule Rfd2399 do
  use Taskweft.DSL

  @name "rfd_2399"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2399": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2399": 1}}
  }

  @todo_list [
    ["prepare", "2399"],
    ["land", "2399"]
  ]
end
