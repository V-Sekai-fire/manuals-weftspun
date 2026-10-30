# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2339, "a persona answers from a planning domain", :discussion do
  flight_level :l1
  feature "a persona answers from a goal-task network instead of from weights"
  scope "the persona repository, the planner it requires as a library, and its register row"

  prose ~S"""
  :: decision
  - A persona answers from a goal-task network rather than from weights: a domain and a
    goal go in, an exact plan comes out, and no sampling is involved (operator, 2026-10-30).
  - The planner is a library, not a reference. The persona requires the RECTGTN domain
    over GitHub, as the character domain does, and composes in its shared GTN space.
  - Its inputs are a code or a number. A code is the vocabulary: one level count a
    dimension, packed mixed-radix, the shape residual FSQ stacks its stages in.
  - A code the codebook does not hold, a variable the domain does not declare, and a goal
    the domain cannot reach are refused by name.
  - It is its own repository on the interactor side, placed when it is created, and the
    planner revision it builds against is recorded in its manifest.
  :: problem
  A request in words reaches a persona only by way of whoever authors the domain. A
  domain with a thin vocabulary answers a thin set of goals, and a persona cannot answer
  a question that is not a goal.
  :: related
  - RFD66606-2292, the organization domain this workspace's own RFDs render into.
  - RFD66606-2232, the renderer that turns an RFD into a planning problem.
  """

  details_title "a persona answers from a planning domain"

  prose ~S"""
  :: details What landed
  The persona is a Lean package of its own: a domain of state variables, a codebook and
  actions, a goal over the planner's own node space, and a search that composes the plan.
  The landing subject is "Compose the persona in Lean over the planner library".

  Its gate is a witness exe with a positive and a negative control per invariant: the
  codebook's size, basis and mixed-radix index; a code past its level and a code of the
  wrong arity both refused; a plan that executes to the goal; and three refusals, an
  unreachable goal, an undeclared variable and zero fuel.
  :: details The codebook is the vocabulary
  Eight levels over four dimensions is 4096 codes a stage, and four stages of those is
  281474976710656 codes from thirty-two small integers. A code is what a goal argument
  binds, and a number is the other half of the surface.

  The codec is the one this workspace already certifies for the residual-FSQ recommender:
  a mixed-radix index over per-dimension levels, injective and bounded at the real scale.
  :: details What is not known
  - Whether a grammar over the domain's own codes is enough to carry a request in words,
    or whether every request needs a caller that already knows the vocabulary.
  - How a persona composes with this workspace's rendered problems, which the organization
    domain answers today through the planner's Elixir consumer.
  - The temporal reading of a domain that declares no reads and no writes: the plan order
    is exact, and the timeline parallelizes what the domain leaves undeclared.
  """
end
