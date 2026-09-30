# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2276. `mix rfd.render` renders the README.md and DETAILS.md from this
# file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2276 do
  use RFD.DSL

  rfd 2276, "Kusudama governs a ggml-rd persona policy" do
    state :discussion
    feature "one joint primitive governs a learned persona controller and its authoring IK"

    scope "godot-kusudama IK, motion-bricks PPO, contract-ggml-rd, Appendix E.3 ROM"

    decision ~S"""
    A character-persona motion policy trains offline and runs on ggml-rd, and the
    continuous soft kusudama is its runtime range-of-motion governor. One phenotype
    envelope (`starforged-std-3001-appendix-e`, section E.3) feeds both the training
    reward and the runtime constraint, so the deployed limit is the trained limit.
    Inference is ggml-rd and compute-rd only; no torch and no ONNX at runtime.
    """

    problem ~S"""
    Training rewards a policy for one range of motion while the runtime enforces
    another, so a controller drifts past the limit it learned. A hard nearest-cone
    projection jerks at the medial axis, which is unsafe on hardware. And the policy
    runs on the RenderingDevice, not a foreign inference stack.
    """

    references ~S"""
    - Continuous soft and prismatic kusudama: `4-entities/godot-kusudama`, commit 04924abc.
    - Offline PPO with the E.3 ROM envelope: RFD 2238; `3-interactor/motion-bricks-ggml`.
    - ggml-rd (the RD0 backend, kernels from Lean): `2-contract/ggml-rd`; its gate, `gates/3-ggml-rd`, is in the archived `interactor-dress-on`.
    - Phenotype ROM: `chibifire/starforged-std-3001-appendix-e`, section E.3.
    """

    related ~S"""
    RFD 2238 sets the mjlab PPO formula this reuses. RFD 2230 is the ggml adapter the
    policy reaches the avatar through. RFD 2265 is the compute-rd precedent. RFD 2172
    is the tenseless voice this follows.
    """

    details_title "Kusudama governs a ggml-rd persona policy"

    details "Two sides, one compute rule", ~S"""
    Offline training may use torch: the RFD 2238 mjlab, MuJoCo-Warp and rsl-rl PPO
    pipeline on the owned 4090 produces GGUF weights (the baseline reproduces at ROM
    clearance 0.7831, and the 30-degree envelope-shift control drops it to 0.7508).
    Runtime is ggml-rd and compute-rd only: the policy runs as the RD0 backend (ggml
    over Godot's RenderingDevice, kernels generated from Lean to Slang to SPIR-V), the
    normalize and retarget math runs as compute-rd, and the kusudama enforces the
    phenotype ROM jerk-free. The offline checkpoint exports to a GGUF that a ggml graph
    reproduces to 5.6e-7 against torch; there is no ONNX in the path.
    """

    details "The ELU kernel", ~S"""
    The rsl-rl actor reads ELU, which the RD0 kernel set did not carry. It is added as
    a Lean kernel in `kernels/ggml/` alongside relu and leaky_relu: the identity above
    zero, and `exp(x)` less one below it. Its emitted Slang is proved against the pin,
    and the cpp fallback emit and the RD0 gate run on the canonical slangc.
    """

    details "The release ladder", ~S"""
    The first working version is the policy graph on RD0 matched to the 5.6e-7 reference on one
    phenotype. It grows by conditioning the policy across the phenotype range, then by
    text control: kimodo (text to motion) is a scaffold on the SOMA-77 skeleton and
    stays an offline authoring tool until it is ported to ggml-rd. osquery records the
    training host for provenance and sources the deployment health-gate.
    """

    drafted_by :ai
  end
end
