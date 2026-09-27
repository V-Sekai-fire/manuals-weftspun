# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2272. `mix rfd.render` renders rfd/2272-rf-detr-segmentation-as-a-sandbox-guest-on-ggml-rd/README.md
# and DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2272 do
  use RFD.DSL

  rfd 2272, "RF-DETR segmentation as a sandbox guest on ggml-rd" do
    state :discussion

    flight_level :l1

    feature "RF-DETR seg-nano runs as a godot-sandbox guest on ggml-rd,
checked against a CPU flat control and a fault-injected negative control"

    scope "interactor-dress-on's rfdetr_seg.elf (PR #22), the weight pump, and
the one new ggml-rd kernel it needed"

    decision ~S"""
    `rfdetr_seg.elf` is a godot-sandbox guest on ggml-rd, with its weights
    streamed through the pump (416 tensors, 117.9 MiB). The one new kernel,
    `cpy_f32_i32`, went through L0 to L3. Gate 9 passes against a flat
    control, rf-detr-ggml's `seg_cli` on the CPU, and fails 23 of 23 under
    `GGML_RD_FAULT=1`. A CPY kernel's L3 negative control is the swap-nb
    check at L2, not the fault switch, because the fault switch perturbs a
    tensor CPY never reads.
    """

    problem ~S"""
    RFD 2262 says the loop's scoring runs as godot-sandbox guests on ggml-rd,
    not a second runtime. Segmentation had not been shown to run there, and
    a gate is only evidence when a broken build fails it.
    """

    related ~S"""
    - RFD 2262 (make it with the pen), scoring as sandbox guests on ggml-rd.
    - RFD 2230 (ggml adapters in godot-sandbox), the guest shape.
    - RFD 1168 (segmenting with rf-detr), the segmentation head.
    - RFD 2273 (accepting person masks), what the masks are checked by.
    """

    drafted_by :ai

    details_title "RF-DETR segmentation as a sandbox guest on ggml-rd"

    details "The new kernel", ~S"""
    `cpy_f32_i32` is the only kernel the guest needed that ggml-rd lacked.

    - L2: 634 of 634 bit-exact, and a swapped-stride (swap-nb) variant is
      detected.
    - L3: test-backend-ops CPY, 163 OK and 0 FAIL.
    """

    details "Gate 9", ~S"""
    The flat control is rf-detr-ggml's `seg_cli` on the CPU. Worst max
    difference against it, with the gate beside each:

    | Output | Worst | Gate |
    | --- | --- | --- |
    | boxes | 8.7e-4 | 5e-2 |
    | logits | 7.8e-3 | 5e-2 |
    | masks | 4.3e-2 | 0.15 |

    The negative control, `GGML_RD_FAULT=1`, fails 23 of 23.
    """

    details "Why the fault switch is not CPY's control", ~S"""
    `GGML_RD_FAULT` perturbs `src[1]`. For CPY, `src[1]` is the destination,
    which the kernel writes and never reads, so the perturbation cannot
    change CPY's result and a passing run under it proves nothing. CPY's
    negative control is the swap-nb check at L2.
    """
  end
end
