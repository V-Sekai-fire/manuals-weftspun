# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1039-trellis2-image-mesh-painting.exs
defmodule Rfd1039 do
  use Taskweft.DSL

  @name "rfd_1039"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1039": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1039": 0}}
  }

  @todo_list [
    ["prepare", "1039"],
    ["land", "1039"]
  ]
end
