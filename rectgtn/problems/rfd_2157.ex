# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2157-fbd-to-elf-compiler-in-lean4.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2157 do
  use Taskweft.DSL

  @name "rfd_2157"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2157": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2157": 0}}
  }

  @todo_list [
    ["prepare", "2157"],
    ["land", "2157"]
  ]
end
