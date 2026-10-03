# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2280-pixal3d-latents-as-mesh-tokens.exs
defmodule Rfd2280 do
  use Taskweft.DSL

  @name "rfd_2280"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2280": 1}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2280": 0}}
  }

  @todo_list [
    ["prepare", "2280"],
    ["land", "2280"]
  ]
end
