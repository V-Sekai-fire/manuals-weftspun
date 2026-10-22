# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2166-maskscore-cineform-mkv-bundle.exs
defmodule Rfd2166 do
  use Taskweft.DSL

  @name "rfd_2166"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2166": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2166": 0}}
  }

  @todo_list [
    ["prepare", "2166"],
    ["land", "2166"]
  ]
end
