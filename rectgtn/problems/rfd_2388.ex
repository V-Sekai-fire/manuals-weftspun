# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2388-the-servers-linux-double-build-comes-only-from-the-workflow.exs
defmodule Rfd2388 do
  use Taskweft.DSL

  @name "rfd_2388"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2388": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2388": 1}}
  }

  @todo_list [
    ["prepare", "2388"],
    ["land", "2388"]
  ]
end
