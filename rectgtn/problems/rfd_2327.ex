# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2327-keypoints-supports-and-contacts.exs
defmodule Rfd2327 do
  use Taskweft.DSL

  @name "rfd_2327"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2327": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2327": 1}}
  }

  @todo_list [
    ["prepare", "2327"],
    ["land", "2327"]
  ]
end
