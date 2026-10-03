# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2265-curvenet-on-compute-rd.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2265 do
  use Taskweft.DSL

  @name "rfd_2265"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2265": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2265": 1}}
  }

  @todo_list [
    ["prepare", "2265"],
    ["land", "2265"]
  ]
end
