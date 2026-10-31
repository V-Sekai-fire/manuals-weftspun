# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2429-the-maskscore-pipeline-runs-from-a-container-to-hf.exs
defmodule Rfd2429 do
  use Taskweft.DSL

  @name "rfd_2429"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2429": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2429": 2}}
  }

  @todo_list [
    ["prepare", "2429"],
    ["land", "2429"]
  ]
end
