# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2272-rf-detr-segmentation-as-a-sandbox-guest-on-ggml-rd.exs
defmodule Rfd2272 do
  use Taskweft.DSL

  @name "rfd_2272"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2272": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2272": 1}}
  }

  @todo_list [
    ["prepare", "2272"],
    ["land", "2272"]
  ]
end
