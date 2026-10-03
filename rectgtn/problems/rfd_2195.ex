# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2195-weftspun-bao-tailscale-sidecar.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2195 do
  use Taskweft.DSL

  @name "rfd_2195"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2195": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2195": 0}}
  }

  @todo_list [
    ["prepare", "2195"],
    ["land", "2195"]
  ]
end
