# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2431-internal-assets-are-openusd-and-transmission-is-gltf-vrm-or-usdz.exs
defmodule Rfd2431 do
  use Taskweft.DSL

  @name "rfd_2431"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2431": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2431": 2}}
  }

  @todo_list [
    ["prepare", "2431"],
    ["land", "2431"]
  ]
end
