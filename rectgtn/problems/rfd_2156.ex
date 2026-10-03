# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2156-safegdscript-compile-step.exs
defmodule Rfd2156 do
  use Taskweft.DSL

  @name "rfd_2156"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2156": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2156": 0}}
  }

  @todo_list [
    ["prepare", "2156"],
    ["land", "2156"]
  ]
end
