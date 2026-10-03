# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2192-rfdetr-keypoint-weights-licence-verification.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2192 do
  use Taskweft.DSL

  @name "rfd_2192"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2192": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2192": 0}}
  }

  @todo_list [
    ["prepare", "2192"],
    ["land", "2192"]
  ]
end
