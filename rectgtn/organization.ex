# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# `mix rfd.rectgtn` renders this from RFD.RECTGTN; it is a build artifact
# (RFD 2232, extended to the organization domain by RFD 2292). The problems
# beside it in problems/ are rendered from the RFD sources.
defmodule WeftspunOrganization do
  use Taskweft.DSL

  @name "weftspun_organization"

  @enums %{
    rfd_state: %{abandoned: -2, moved: -1, prediscussion: 0, ideation: 1, discussion: 2, published: 3, committed: 4},
    step_state: %{parked: -2, failed: -1, ready: 0, checked: 1},
    flight_level: %{l1: 1, l2: 2, l3: 3}
  }

  @variables %{
    rfd_state: %{type: :int, init: %{}},
    step_state: %{type: :int, init: %{}},
    flight_level: %{type: :int, init: %{}}
  }

  @actions %{
    "draft": %{params: [:serial], body: [%{pointer_set: "/rfd_state/{serial}", value: 2}]},
    "run-step": %{params: [:serial, :step], body: [%{pointer_set: "/step_state/{serial}.{step}", value: 1}]},
    "close-the-gap": %{params: [:serial, :step], body: [%{pointer_set: "/step_state/{serial}.{step}", value: 0}]},
    "park-step": %{params: [:serial, :step], body: [%{pointer_set: "/step_state/{serial}.{step}", value: -2}]},
    "gate": %{params: [:serial], body: [%{pointer_set: "/rfd_state/{serial}", value: 3}]},
    "open-pr": %{params: [:serial], body: []},
    "enqueue": %{params: [:serial], body: [%{pointer_set: "/rfd_state/{serial}", value: 4}]}
  }

  @methods %{
    prepare: %{
      params: [:serial],
      alternatives: [
        %{
          name: :already_drafted,
          check: [%{eval: %{type: "math/eq", a: %{pointer_get: "/rfd_state/{serial}"}, b: 2}}],
          subtasks: []
        },
        %{name: :draft_it, subtasks: [["draft", "{serial}"]]}
      ]
    },
    step: %{
      params: [:serial, :index],
      alternatives: [
        %{
          name: :already_checked,
          check: [%{eval: %{type: "math/eq", a: %{pointer_get: "/step_state/{serial}.{index}"}, b: 1}}],
          subtasks: []
        },
        %{
          name: :close_the_gap_first,
          check: [%{eval: %{type: "math/eq", a: %{pointer_get: "/step_state/{serial}.{index}"}, b: -1}}],
          subtasks: [
            ["close-the-gap", "{serial}", "{index}"],
            ["run-step", "{serial}", "{index}"]
          ]
        },
        %{
          name: :parked_and_named,
          check: [%{eval: %{type: "math/eq", a: %{pointer_get: "/step_state/{serial}.{index}"}, b: -2}}],
          subtasks: []
        },
        %{name: :run_it, subtasks: [["run-step", "{serial}", "{index}"]]},
        %{name: :park_it, subtasks: [["park-step", "{serial}", "{index}"]]}
      ]
    },
    land: %{
      params: [:serial],
      alternatives: [
        %{
          name: :already_landed,
          check: [%{eval: %{type: "math/eq", a: %{pointer_get: "/rfd_state/{serial}"}, b: 4}}],
          subtasks: []
        },
        %{
          name: :gate_then_queue,
          subtasks: [
            ["gate", "{serial}"],
            ["open-pr", "{serial}"],
            ["enqueue", "{serial}"]
          ]
        }
      ]
    }
  }

  @todo_list []
end
