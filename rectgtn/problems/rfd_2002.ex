# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2002-taskweft-value-narrowing-primitives-and-refs.exs
defmodule Rfd2002 do
  use Taskweft.DSL

  @name "rfd_2002"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2002": -2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2002": 0}}
  }

  @todo_list []
end
