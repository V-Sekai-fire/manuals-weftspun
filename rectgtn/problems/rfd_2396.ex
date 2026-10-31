# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2396-the-wear-step-attaches-the-garment-to-the-avatar-s-hips.exs
defmodule Rfd2396 do
  use Taskweft.DSL

  @name "rfd_2396"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2396": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2396": 1}}
  }

  @todo_list [
    ["prepare", "2396"],
    ["land", "2396"]
  ]
end
