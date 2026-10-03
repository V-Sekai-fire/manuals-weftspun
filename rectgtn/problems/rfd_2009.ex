# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2009-ghcr-package-ownership-same-repo.exs
defmodule Rfd2009 do
  use Taskweft.DSL

  @name "rfd_2009"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2009": 0}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2009": 0}}
  }

  @todo_list [
    ["prepare", "2009"],
    ["land", "2009"]
  ]
end
