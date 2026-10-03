# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2287-the-first-rung-draw-and-wear-it-in-a-headset.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
defmodule Rfd2287 do
  use Taskweft.DSL

  @name "rfd_2287"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2287": 2}},
    step_state: %{type: :int, init: %{"2287.1": -1, "2287.2": 0, "2287.3": 0, "2287.4": 0, "2287.5": 0, "2287.6": 0, "2287.7": 0, "2287.8": 0}},
    flight_level: %{type: :int, init: %{"2287": 1}}
  }

  @todo_list [
    ["prepare", "2287"],
    ["step", "2287", "1"],
    ["step", "2287", "2"],
    ["step", "2287", "3"],
    ["step", "2287", "4"],
    ["step", "2287", "5"],
    ["step", "2287", "6"],
    ["step", "2287", "7"],
    ["step", "2287", "8"],
    ["land", "2287"]
  ]
end
