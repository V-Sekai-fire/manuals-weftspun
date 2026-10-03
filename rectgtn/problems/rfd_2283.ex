# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2283-play-mode-verification-by-recording.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2283 do
  use Taskweft.DSL

  @name "rfd_2283"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2283": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2283": 1}}
  }

  @todo_list [
    ["prepare", "2283"],
    ["land", "2283"]
  ]
end
