# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2378-desktop-libraries-build-in-wsl-and-cross-build-from-the-mac.exs
defmodule Rfd2378 do
  use Taskweft.DSL

  @name "rfd_2378"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2378": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2378": 2}}
  }

  @todo_list [
    ["prepare", "2378"],
    ["land", "2378"]
  ]
end
