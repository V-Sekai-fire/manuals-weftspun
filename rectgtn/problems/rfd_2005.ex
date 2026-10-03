# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# A build artifact of `mix rfd.rectgtn` (RFD 2292), composed with ../organization.ex:
# rfd/2005-gltf-interactivity-value-type-taxonomy-correction.exs
defmodule Rfd2005 do
  use Taskweft.DSL

  @name "rfd_2005"
  @source "weftspun_organization"

  @variables %{
    rfd_state: %{type: :int, init: %{"2005": -2}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{"2005": 0}}
  }

  @todo_list []
end
