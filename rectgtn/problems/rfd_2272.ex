# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from rfd/2272-rf-detr-segmentation-as-a-sandbox-guest-on-ggml-rd.exs; it is a build artifact
# (RFD 2292). Compose it with ../organization.ex and plan it for the solution.
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
