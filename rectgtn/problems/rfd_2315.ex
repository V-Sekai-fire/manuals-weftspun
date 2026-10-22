# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2315-web-shaders-are-baked-by-the-browser-that-runs-them.exs
defmodule Rfd2315 do
  use Taskweft.DSL

  @name "rfd_2315"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2315": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2315": 0}}
  }

  @todo_list [
    ["prepare", "2315"],
    ["land", "2315"]
  ]
end
