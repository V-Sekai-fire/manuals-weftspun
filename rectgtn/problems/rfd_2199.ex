# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2199-hailo-real-4bit-qat.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2199 do
  use Taskweft.DSL

  @name "rfd_2199"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2199": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2199": 0}}
  }

  @todo_list [
    ["prepare", "2199"],
    ["land", "2199"]
  ]
end
