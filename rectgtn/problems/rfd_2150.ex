# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2150-rectgtn-on-openplc4-over-coap-oscore.exs
defmodule Rfd2150 do
  use Taskweft.DSL

  @name "rfd_2150"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2150": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2150": 0}}
  }

  @todo_list [
    ["prepare", "2150"],
    ["land", "2150"]
  ]
end
