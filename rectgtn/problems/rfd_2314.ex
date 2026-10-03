# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2314-the-skintokens-space-viewer-runs-as-sandbox-guests.exs
defmodule Rfd2314 do
  use Taskweft.DSL

  @name "rfd_2314"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2314": 2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2314": 2}}
  }

  @todo_list [
    ["prepare", "2314"],
    ["land", "2314"]
  ]
end
