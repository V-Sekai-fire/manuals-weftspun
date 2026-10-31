# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2377-a-translation-links-into-the-addon-one-bake-per-platform.exs
defmodule Rfd2377 do
  use Taskweft.DSL

  @name "rfd_2377"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2377": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2377": 2}}
  }

  @todo_list [
    ["prepare", "2377"],
    ["land", "2377"]
  ]
end
