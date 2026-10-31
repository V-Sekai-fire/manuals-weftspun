# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2387-github-actions-builds-every-double-binary.exs
defmodule Rfd2387 do
  use Taskweft.DSL

  @name "rfd_2387"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2387": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2387": 1}}
  }

  @todo_list [
    ["prepare", "2387"],
    ["land", "2387"]
  ]
end
