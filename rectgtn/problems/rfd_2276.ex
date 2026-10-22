# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2276-kusudama-governs-a-ggml-rd-persona-policy.exs
defmodule Rfd2276 do
  use Taskweft.DSL

  @name "rfd_2276"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2276": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2276": 0}}
  }

  @todo_list [
    ["prepare", "2276"],
    ["land", "2276"]
  ]
end
