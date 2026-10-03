# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1038-trellis2-image-to-textured-mesh.exs
defmodule Rfd1038 do
  use Taskweft.DSL

  @name "rfd_1038"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1038": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1038": 0}}
  }

  @todo_list [
    ["prepare", "1038"],
    ["land", "1038"]
  ]
end
