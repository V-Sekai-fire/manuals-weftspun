# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2365-every-video-ships-as-cineform-in-matroska.exs
defmodule Rfd2365 do
  use Taskweft.DSL

  @name "rfd_2365"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2365": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2365": 2}}
  }

  @todo_list [
    ["prepare", "2365"],
    ["land", "2365"]
  ]
end
