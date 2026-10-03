# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2051-headless-openxr-testing-with-monado.exs
defmodule Rfd2051 do
  use Taskweft.DSL

  @name "rfd_2051"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2051": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2051": 0}}
  }

  @todo_list [
    ["prepare", "2051"],
    ["land", "2051"]
  ]
end
