# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2271-headset-eye-tracking-to-social-vr-without-a-bridge.exs
defmodule Rfd2271 do
  use Taskweft.DSL

  @name "rfd_2271"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2271": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2271": 0}}
  }

  @todo_list [
    ["prepare", "2271"],
    ["land", "2271"]
  ]
end
