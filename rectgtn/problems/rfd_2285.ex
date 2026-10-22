# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2285-unship-the-web-demo-and-xr-paths.exs
defmodule Rfd2285 do
  use Taskweft.DSL

  @name "rfd_2285"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2285": -2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2285": 0}}
  }

  @todo_list []
end
