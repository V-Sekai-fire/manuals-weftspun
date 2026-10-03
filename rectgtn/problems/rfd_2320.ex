# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2320-an-agent-drives-the-oxrsys-simulator-through-cua-driver.exs
defmodule Rfd2320 do
  use Taskweft.DSL

  @name "rfd_2320"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2320": 4}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2320": 0}}
  }

  @todo_list []
end
