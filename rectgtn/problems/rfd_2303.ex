# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2303-xr-technical-requirements-checklist.exs
defmodule Rfd2303 do
  use Taskweft.DSL

  @name "rfd_2303"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2303": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2303": 1}}
  }

  @todo_list [
    ["prepare", "2303"],
    ["land", "2303"]
  ]
end
