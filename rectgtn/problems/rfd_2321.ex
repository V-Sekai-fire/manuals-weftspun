# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2321-the-autobattler-fields-frames-that-wear.exs
defmodule Rfd2321 do
  use Taskweft.DSL

  @name "rfd_2321"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2321": 4}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2321": 0}}
  }

  @todo_list []
end
