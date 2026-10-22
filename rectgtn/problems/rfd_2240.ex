# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2240-citation-metadata-and-review-interchange.exs
defmodule Rfd2240 do
  use Taskweft.DSL

  @name "rfd_2240"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2240": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2240": 0}}
  }

  @todo_list [
    ["prepare", "2240"],
    ["land", "2240"]
  ]
end
