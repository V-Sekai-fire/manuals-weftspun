# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2336-pixal3d-as-a-ggml-rd-guest.exs
defmodule Rfd2336 do
  use Taskweft.DSL

  @name "rfd_2336"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2336": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2336": 0}}
  }

  @todo_list [
    ["prepare", "2336"],
    ["land", "2336"]
  ]
end
