# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2196-huggingface-dataset-viewer-rules.exs
defmodule Rfd2196 do
  use Taskweft.DSL

  @name "rfd_2196"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2196": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2196": 0}}
  }

  @todo_list [
    ["prepare", "2196"],
    ["land", "2196"]
  ]
end
