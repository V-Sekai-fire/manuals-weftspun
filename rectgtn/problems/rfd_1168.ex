# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1168-segmenting-the-3d-latent-with-rf-detr.exs
defmodule Rfd1168 do
  use Taskweft.DSL

  @name "rfd_1168"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1168": 1}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1168": 0}}
  }

  @todo_list [
    ["prepare", "1168"],
    ["land", "1168"]
  ]
end
