# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2310-eye-landmarks-from-a-frontier-learned-render-domain.exs
defmodule Rfd2310 do
  use Taskweft.DSL

  @name "rfd_2310"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2310": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2310": 1}}
  }

  @todo_list [
    ["prepare", "2310"],
    ["land", "2310"]
  ]
end
