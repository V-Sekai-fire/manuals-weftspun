# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2290-trim-the-independent-ggml-runtimes.exs
defmodule Rfd2290 do
  use Taskweft.DSL

  @name "rfd_2290"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2290": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2290": 0}}
  }

  @todo_list [
    ["prepare", "2290"],
    ["land", "2290"]
  ]
end
