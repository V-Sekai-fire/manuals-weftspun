# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2338, "a skin fit to four influences on the GPU L-BFGS-B", :discussion do
  flight_level :l2
  feature "a character's skin reaches a consumer that holds four influences a vertex"
  scope "the skin fit package, its call into the bounded solver, and the viewer's flex gate"

  prose ~S"""
  :: decision
  - A skin is reduced to the influences a consumer holds by a fit, not by cutting each
    vertex to its heaviest N; the export target is four, the limit a VRM viewer holds
    (operator, 2026-10-29).
  - The fit is a Lean package of its own, contract-skin-fit, and it reads a GLB, which
    carries the mesh, the skin weights, the skeleton and the inverse binds (operator,
    2026-10-29).
  - The solver places the helper joints as well as the weights, so a helper lands where it
    helps the bend rather than where a twist rule puts it (operator, 2026-10-29).
  - The solve runs on &{repo("contract-lbfgsb")} on the GPU, as RFD66606-2337 does. The
    residual is linear in the weights, so its gradient is analytic.
  - The pose set drives every joint on every degree of freedom the canonical joint table
    gives it, and every joint appears in the fit set.
  - The gate is the viewer's flex, RFD66606-2331: the posed mesh at the face-vertex.
  - Frontier learning drives the fit's iterations: a level is a pose family, a problem one
    pose, and only a rising success keeps a change (operator, 2026-10-29).
  :: problem
  A body authored with 24 influences a vertex reaches a consumer that holds four. Cutting
  each vertex to its heaviest four costs 0.22 m at the flex's own amplitude, about five
  golf balls, and 445 times the half millimetre the viewer's gate allows.
  :: related
  - RFD66606-2337, the garment fit at mesh on the same solver, and the gates this follows.
  - RFD66606-2331, the flex the reduction is judged by.
  - RFD66606-2328, finger skin weights from a fitted hand.
  """

  details_title "a skin fit to four influences on the GPU L-BFGS-B"

  prose ~S"""
  :: details The solve
  Over the weight field `W` and the helper rest transforms, with `x` the welded rest
  vertices and `S_j(p)` the skinning matrix of joint `j` in pose `p`:

  ```
  E(W) = sum over poses p, vertices v | sum_j w_vj S_j(p) x_v − ref_v(p) |^2
       + lambda * sum over edges (i, j) c_ij | w_i − w_j |^2
  ```

  subject to `w >= 0`, `sum_j w_vj = 1`, and at most four non-zero a vertex. `ref` is the
  authored skin's own deformation, which is what the viewer's gate compares against. The
  coupling term is the Laplacian the robust transfer already uses.

  The cardinality constraint is not a bound, so the solver cannot express it directly: the
  fit runs as an active set, keeping four a vertex and re-solving on the kept four.
  :: details What exists, and what is new
  - L-BFGS-B on the GPU, &{repo("contract-lbfgsb")}: the driver builds and links
    host-native, and the guest runs it over SPIR-V.
  - GLB parsing in Lean, the native glTF pipeline: the parser, the JSON chunk and the
    ByteArray accessors.
  - The canonical joint table and each joint's degrees of freedom, mapped for our rigs:
    the table exists, and the per-DOF sweep is new.
  - LBS and the face-vertex measurement: a host-side harness validated against the
    guest, which this package supersedes.
  - The fit package, and writing four influences back into the skin arrays: new.
  :: details Gates and controls
  - The authored skin reproduces itself: 0 beyond the tolerance. Control: a vertex's
    weights rolled.
  - The fit on poses it saw: 0 beyond the tolerance. Control: a fit set that skips a
    joint.
  - The fit on held-out extremes: 0 beyond the tolerance. Control: the cut, which is
    0.22 m.
  - The harness against the guest: one posed joint agrees. Control: reading a matrix
    without transposing it.
  Every gate runs on the body and on the overcoat, and on the garment fixtures
  RFD66606-2337 names.
  :: details The frontier the fit practises
  Frontier learning's level search drives the iterations (operator, 2026-10-29), as
  RFD66606-2309 sets it out. A level is a pose family with fixed attributes, a problem is
  one pose in it, and regret `1[s >= 1]` minus `s/n` picks what gets practised: the levels
  the fit sometimes solves and sometimes fails, which is where a change can move the
  number.
  A level fixes four attributes:
  - the joint class, one of the spine, a limb, a hand, a foot or the face;
  - the degree of freedom, flexion, abduction or rotation, or a combination of them;
  - the amplitude band, at the flex's own amplitude and at half of it;
  - the side, left or right.
  A problem is one pose: one joint, at one amplitude, on one degree of freedom, which is
  what the pose set already enumerates. A level passes a problem when the posed face-vertex
  error is inside the tolerance, so the frontier is the set of levels whose success sits
  strictly between none and all. What the loop revises is the fit's own elements: the
  active set, the coupling weight, the helper count and the helper placement.
  :: details What is not known
  - Whether four influences can hold the motion RFD66606-2331 specifies, with the helpers
    the solver places. The cut's 0.22 m is at the flex's amplitude and without helpers.
  - Whether the coupling term lowers the error at four influences. Smoothing the raw fit and
    cutting afterwards measured worse than the cut.
  - The per-DOF range the poses sweep, which RFD66606-1138 leaves open.
  - The name of the package's repository, which is placed in the manifest when it is created.
  """
end
