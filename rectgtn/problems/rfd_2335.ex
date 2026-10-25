# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2335-ggml-stablehlo-bit-exact-on-pjrt.exs
defmodule Rfd2335 do
  use Taskweft.DSL

  @name "rfd_2335"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2335": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2335": 0}}
  }

  @todo_list [
    ["prepare", "2335"],
    ["land", "2335"]
  ]
end
