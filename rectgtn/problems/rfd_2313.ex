# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2313-the-full-loop-over-colour-passthrough.exs
defmodule Rfd2313 do
  use Taskweft.DSL

  @name "rfd_2313"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2313": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2313": 2}}
  }

  @todo_list [
    ["prepare", "2313"],
    ["land", "2313"]
  ]
end
