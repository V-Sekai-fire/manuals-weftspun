# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2292. `mix rfd.render` renders
# rfd/2292-the-organization-is-one-rectgtn-domain/README.md and DETAILS.md from
# this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2292 do
  use RFD.DSL

  rfd 2292, "the organization is one RECTGTN domain" do
    state :committed

    flight_level :l3

    feature "one Taskweft domain for the organization, one problem per RFD,
and the plan it compiles to rendered into that RFD's own Markdown"

    scope "`RFD.RECTGTN`, the `steps` block in `RFD.DSL`, `mix rfd.rectgtn`,
`rectgtn/organization.ex`, `rectgtn/problems/`, and
`scripts/check_rectgtn_plan.exs`"

    decision ~S"""
    The organization is the domain and each RFD is a problem against it. The
    domain holds the ladder an RFD climbs and what preparing a document,
    running a step and landing it are; a problem holds one RFD's place on that
    ladder and the state of each step it declares. Both halves are Taskweft's
    own Elixir DSL, rendered by `mix rfd.rectgtn` from the RFD sources, and
    `Taskweft.Compose.compose_strings/2` merges a pair so the planner compiles
    it into a solution. That solution renders into the RFD's `DETAILS.md`, and a
    gate holds it against what the planner returns.
    """

    problem ~S"""
    RFD 2287 states its critical path as eight numbered paragraphs. A paragraph
    cannot be asked which step comes next, which steps are blocked, or what a
    failure costs, and the eight repeat a shape every rung of every ladder in
    this workspace already has: a step names a repository, what is missing, and
    the check it ends at. Written once as a domain, the question "what is next
    for this RFD" is a plan rather than a reading.
    """

    related ~S"""
    RFD 2287 (the first rung) is the first problem; RFD 2204 (RECTGTN fleet
    coordination) plans over peers rather than documents; RFD 2232 (RFD
    authoring as an Elixir DSL) gives the build-artifact rule; RFD 2177 carries
    the flight levels the domain holds.
    """

    drafted_by :ai

    details_title "the organization is one RECTGTN domain"

    details "Where the declarations live", ~S"""
    A `steps` block inside an `rfd` block declares the critical path:

        steps do
          step "Build",
            repos: ["entities-godot", "the godot-sandbox addon"],
            missing: "the exported template_release build faults in a StringName copy",
            check: "an OpenXR session starts on each path and the pen scene draws in it",
            state: :failed
        end

    `repos` and `check` are required, because a step nobody owns and a step that
    ends at nothing are the two ways a critical path rots. `missing` is what the
    step needs that does not exist yet, `control` is the planted defect its check
    must catch, and `state` is where the step stands. A step declared `parked`
    states what it is missing, so parking is never silent.
    """

    details "Why the Elixir DSL and not JSON-LD", ~S"""
    Taskweft reads a domain written in its own Elixir DSL, and
    `Taskweft.Compose.compose_strings/2` composes DSL sources directly, so
    nothing here authors JSON-LD. Writing the first draft against the JSON-LD
    path found three defects in `Taskweft.DSL.SafeParser`, all one bug: a value
    went through `to_string/1`.

    - An integer `value: 1` reached the planner as the string `"1"`.
    - A negative literal raised `Protocol.UndefinedError` on its unary-minus
      AST, in an action body, a variable's `init` and an alternative's `check`.
    - A computed `value: %{type: "math/add", ...}` was dropped to `{}` or
      raised.

    The same bug had been fixed once before for a goal's `eq`, and the comment
    recording it is still in `dsl_goal_test.exs`. Six controls in
    `dsl_value_type_test.exs` cover the three sites now; five of them fail
    against the parser as it was.
    """

    details "Where the antifragility is", ~S"""
    A failure makes the plan longer rather than making it fail. The `step`
    method's alternatives are `already_checked`, `close_the_gap_first`,
    `parked_and_named`, `run_it`, `park_it`, and a step the problem states as
    `failed` matches the second, which plans `close-the-gap` **and then**
    `run-step`.

    Measured over one four-step problem, changing only step 3's state:

    | step 3 | plan length | what the planner adds |
    | --- | --- | --- |
    | `ready`, the control | 7 | nothing |
    | `failed` | 8 | `close-the-gap` before the retry |
    | `parked` | 6 | nothing, and step 3 is not run |
    | `checked` | 6 | nothing, and step 3 is not run again |

    A system that merely survived the failure would have planned 7 again and
    retried the same step. RFD 2287 carries this today: its Build step is
    `failed`, so its solution is 12 steps and opens with the gap.
    """

    details "What the gate measures", ~S"""
    `scripts/check_rectgtn_plan.exs` reads each RFD that declares steps, takes
    the solution its `DETAILS.md` renders, and asks the planner for the plan:
    `Taskweft.Compose.compose_strings/2` over `rectgtn/organization.ex` and that
    RFD's problem, then `Taskweft.NIF.plan/1`. A difference fails the command.

        elixir scripts/check_rectgtn_plan.exs             # 1/1 solutions are the planner's
        elixir scripts/check_rectgtn_plan.exs --self-test # 14 controls

    Taskweft is a separate checkout, so the gate runs at the manual stage where a
    `repo` workspace exists, and a missing checkout is a FAIL rather than a skip.
    Fourteen controls cover the plan shape without it, including that a failure
    lengthens the plan and that a parked step naming nothing missing is refused.
    """

    details "What this does not do", ~S"""
    The planner does no work; it names the next step. Nothing writes a step's
    state from a check run, so a step's `state` is a declaration a reader keeps
    honest, the same way a blocklist row is.

    One problem per RFD is rendered for all of them, and 360 of the 361 carry no
    steps, so their solutions are `prepare`, `gate`, `open-pr`, `enqueue` and say
    little. The shape is worth having before the second rung declares its path.
    """
  end
end
