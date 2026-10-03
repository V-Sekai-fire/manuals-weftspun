# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1045-kimodo-text-to-motion.exs
defmodule Rfd1045 do
  use Taskweft.DSL

  @name "rfd_1045"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1045": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1045": 0}}
  }

  @todo_list [
    ["prepare", "1045"],
    ["land", "1045"]
  ]
end
