# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2386-this-mac-is-the-desktop-client.exs
defmodule Rfd2386 do
  use Taskweft.DSL

  @name "rfd_2386"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2386": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2386": 1}}
  }

  @todo_list [
    ["prepare", "2386"],
    ["land", "2386"]
  ]
end
