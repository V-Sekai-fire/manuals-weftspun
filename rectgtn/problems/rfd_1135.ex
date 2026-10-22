# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/1135-one-environment-per-elixir-app.exs
defmodule Rfd1135 do
  use Taskweft.DSL

  @name "rfd_1135"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"1135": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"1135": 0}}
  }

  @todo_list [
    ["prepare", "1135"],
    ["land", "1135"]
  ]
end
