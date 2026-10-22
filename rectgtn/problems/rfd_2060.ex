# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2060-org-scoped-github-app-token-for-gh-access.exs
defmodule Rfd2060 do
  use Taskweft.DSL

  @name "rfd_2060"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2060": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2060": 0}}
  }

  @todo_list [
    ["prepare", "2060"],
    ["land", "2060"]
  ]
end
