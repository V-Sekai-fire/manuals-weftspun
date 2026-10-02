# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2290. `mix rfd.render` renders this file's README.md and DETAILS.md under
# rfd/2290-trim-the-independent-ggml-runtimes/; the Markdown is a build artifact
# (RFD 2232).
defmodule RFD2290 do
  use RFD.DSL

  rfd 2290, "Trim the independent ggml runtimes" do
    state :discussion

    feature "one ggml on the route, no second runtime beside it"

    scope "every placed row that carries a tensor runtime of its own"

    decision ~S"""
    ggml reaches the GPU through `2-contract/ggml-rd` and compute-rd, inside
    godot-sandbox guests. A row carrying a runtime of its own, reached by a CLI
    or a NIF, is drift, so the manifest stops placing it.

    Unplaced, five rows, 1,699,925 lines, no build reading any of them and each
    staying on GitHub: `stable-diffusion-ggml`, `skin-tokens-ggml`, `nx-ggml`,
    `pixal3d-ggml`, `motion-bricks-ggml`.

    Kept: `2-contract/ggml`, the library the guest ELFs link, and the two ELF
    repos feeding `rfdetr_seg.elf` and `motion.elf`, renamed
    `interactor-rf-detr-elf-rd` and `interactor-kimodo-elf-rd`.
    """

    problem ~S"""
    Eight placed rows carry ggml, four of them a vendored tree of about 2,130
    files each: 2,575,482 lines, 17 per cent of what the manifest placed this
    morning, on 0.71 GB. The cost is drift across eight trees, not disk. RFD
    2188 decided one canonical ggml with vendored copies deleted: Phase 1
    landed the framework, and Phase 2, the consumers, did not.
    """

    related ~S"""
    - RFD 2188 placed `2-contract/ggml`; this is its Phase 2.
    - RFD 2287 computes in guest ELFs on ggml-rd or compute-rd, RFD 2268 makes
      EditScore a decision model there, and RFD 2289 abandoned the off-route
      runtimes. Abandons RFD 2230 beside 2242: no engine tree has `modules/ggml`.
    - RFD 2272's Gate 9 reads `rf-detr-ggml`'s `seg_cli`.
    """

    drafted_by :ai

    details_title "Trim the independent ggml runtimes"

    details "The inventory, measured 2026-10-01", ~S"""
    Lines are physical lines of tracked source. `vendored` counts files under a
    `ggml/`, `third_party/ggml` or `thirdparty/ggml` path inside the row.

    | row | lines | files | vendored | last commit | state |
    |---|---|---|---|---|---|
    | `3-interactor/stable-diffusion-ggml` | 755,287 | 3,824 | 3,421 | 2026-09-15 | unplaced |
    | `3-interactor/skin-tokens-ggml` | 437,355 | 2,211 | 2,136 | 2026-09-11 | unplaced |
    | `3-interactor/nx-ggml` | 426,704 | 2,180 | 2,134 | 2026-08-21 | unplaced |
    | `3-interactor/pixal3d-ggml` | 40,727 | 87 | 0 | 2026-09-09 | unplaced |
    | `3-interactor/motion-bricks-ggml` | 39,852 | 593 | 153 | 2026-09-09 | unplaced |
    | `2-contract/ggml` | 432,459 | 2,157 | canonical | 2026-09-30 | kept, the library |
    | `3-interactor/rf-detr-ggml` | 436,645 | 2,260 | 2,133 | 2026-09-30 | kept, ELF repo |
    | `3-interactor/kimodo-ggml` | 6,453 | 95 | 0 | 2026-09-29 | kept, ELF repo |
    | `2-contract/ggml-rd` | 426,240 | 311 | the route | 2026-09-30 | kept, the route |
    """

    details "Why the five are free, by name", ~S"""
    Each row was searched for by path string and by name across every
    CMakeLists.txt, .cmake, .sh, .exs, .ex, .toml, .yml and .py in the placed
    tree.

    - `stable-diffusion-ggml`, `skin-tokens-ggml` and `pixal3d-ggml`: nothing
      outside each row names it. `skin-tokens-ggml` appears in
      `ggml-rd/guest/ggml_test/app_graphs` as a comment and a CITATION.cff,
      which is a citation and not a build input.
    - `nx-ggml`: `trellis2-ex`'s mix.exs takes it as
      `{:nx_ggml, git: "https://github.com/weftspun/nx-ggml", branch: "main"}`,
      from GitHub rather than from the checkout, so that build is unaffected.
      Its other mentions are `scratch_*.exs` probe scripts.
    - `motion-bricks-ggml`: the guest reads
      `motion-guest/vendor/motion-bricks-ggml`, vendored inside motion-guest
      (meshing-pen's CMakeLists.txt line 268), not this row.

    THE ONE COST, NAMED. `motion-guest/tools/motion_native/CMakeLists.txt`
    line 18 defaults `MB_SRC` to a manifest-side checkout of
    `motion-bricks-ggml`, and `KIMODO_SRC` the same way. Both are `CACHE PATH`,
    so that host tool takes `-DMB_SRC=<dir>` instead. No guest ELF is affected.
    """

    details "An ELF repo is not a runtime, with the lines that show it", ~S"""
    transport-meshing-pen is the host that builds the guest ELFs, and three of
    the eight ggml rows are roots in its CMakeLists.txt. A `-ffile-prefix-map`
    entry exists only for a root whose sources are compiled in, so the map lines
    are the evidence rather than the inference.

    - `3-interactor/rf-detr-ggml` is an ELF repo. Line 33 sets
      `RF_DETR_GGML_ROOT`, line 46 maps it to `vendor/rf-detr-ggml/`, and
      `add_stage_elf(rfdetr_seg ...)` at line 246 compiles seven files out of
      its `src/`: ops, backbone, projector, deform_attn, decoder, keypoints and
      segmentation. Line 244 says what it is: RF-DETR instance segmentation on
      ggml-rd.
    - `3-interactor/kimodo-ggml` is the same shape, through `motion.elf`: line
      32 sets `KIMODO_GGML_ROOT`, line 45 maps it, and motion-guest's
      `kimodo_weights.cpp` and `mb_runtime.cpp` compile beside it.
    - `2-contract/ggml` is the library both ELFs link. Line 31 sets
      `GGML_ROOT`, line 145 is `add_subdirectory(${GGML_ROOT} ggml
      EXCLUDE_FROM_ALL)`, line 218 adds `${GGML_ROOT}/src` to the kernels test,
      and line 150 stamps `GGML_COMMIT="04b55bba"` into `ggml-base` so a
      committed ELF does not change with every ggml commit.

    None of the three is a second runtime, so none is trimmed.
    """

    details "The rename, and the one thing it must not change", ~S"""
    Two repositories, renamed on GitHub with `gh repo rename`, which leaves a
    redirect behind, then the manifest row's `name` and `path` together.

    - `interactor-rf-detr-ggml` becomes `interactor-rf-detr-elf-rd`, placed at
      `3-interactor/rf-detr-elf-rd`.
    - `interactor-kimodo-ggml` becomes `interactor-kimodo-elf-rd`, placed at
      `3-interactor/kimodo-elf-rd`.

    The blast radius is small and it is known: meshing-pen's CMakeLists.txt and
    its `guests` workflow, `ggml-rd`'s `tests/ggml_rd_kernels/cases/nx_rfdetr.cpp`
    and one Lean codegen comment, `rfdetr-seg-guest/guest/rfdetr_seg/main.cpp`,
    motion-guest's `kimodo_weights.cpp`, `kimodo_decode.h`, `main.cpp` and its
    `motion_native` tool, plus RFD 2272, RFD 2262 and the readme-length script's
    project list. The CMake variables become `RF_DETR_ELF_RD_ROOT` and
    `KIMODO_ELF_RD_ROOT`.

    WHAT MUST NOT CHANGE: the `-ffile-prefix-map` targets. Lines 45 and 46 map
    each root to `vendor/kimodo-ggml/` and `vendor/rf-detr-ggml/`, and those
    strings are baked into the ELF's debug info and `__FILE__` asserts. Keeping
    the map targets as they are keeps the guest ELFs byte-identical across the
    rename; changing them reissues every affected ELF for no gain. Rename the
    variable, hold the mapped string, and record that it is deliberate in the
    CMakeLists comment so it does not read as an oversight later.
    """

    details "How it lands, in order", ~S"""
    1. This document and its serial, as one PR on `manuals-weftspun`. Gates:
       `scripts/check-rfd-structure.py`, `check-rfd-serials.py`,
       `check-rfd-numbers.py`, `check_rfd_state_canonical.py`, then
       `mix rfd.render`.
    2. The manifest PR on `contract-manifest-taskweft`: branch
       `feat/unplace-independent-ggml` off `main/main`, the five rows removed,
       commit `Unplace the five independent ggml runtimes` in house style with
       one bullet per row, the kept rows named, the `MB_SRC` cost stated, and
       the gate results. Merged through the queue, never with `--admin`.
    3. `elixir .repo/manifests/sync.exs .`, then the orphaned
       `.repo/project-objects/*.git` stores for the five rows are deleted, as
       the 6.63 GB cleanup of 2026-10-01 did.
    4. The ELF build, as the proof rather than the claim.
    5. The two renames, in this order so nothing is ever unreachable: rename on
       GitHub, then the consumer PRs that follow the new name (meshing-pen and
       its workflow first, since it owns the build; then ggml-rd, rfdetr-seg-guest
       and motion-guest), then the manifest PR that moves the two rows to their
       new `name` and `path`, then one more sync. The GitHub redirect covers the
       window in between.
    6. The desk artifact re-measured to 152 rows, with this trim as its
       headline, the landed table extended to thirteen rows across four PRs,
       and the kept `*-elf-rd` rows named so they do not return as candidates.
    """

    details "How this is verified", ~S"""
    The claim is that the five rows are not build inputs, so the test is the
    build rather than the argument.

    - The manifest gates, from `.repo/manifests`: `check_manifest_xml`
      (`--self-test`, then `--manifest default.xml`, which resolves every
      revision over the network), `check_manifest_comments`,
      `check_manifest_root --manifest-only`, `check_manifest_dupes`,
      `sync.exs --self-test`, and `check_commit_style --base origin/main/main`.
      Each carries its own negative controls, run locally before the push and
      again on CI.
    - `elixir .repo/manifests/sync.exs .`: 152 projects enumerated, 0 blocking,
      and the five checkouts gone.
    - `elixir tools/build.exs` in `1-transport/meshing-pen` builds the guest
      ELFs with the five rows absent, run under `pixi exec` with lld and python
      3.12 and Homebrew's llvm first on PATH, as this desk requires. A failure
      reverts the PR instead of arguing with it. `grep -n ggml
      CMakeLists.txt` must still resolve `GGML_ROOT`, `GGML_RD_ROOT`,
      `KIMODO_GGML_ROOT` and `RF_DETR_GGML_ROOT` to present checkouts.
    - `python3 loc.py` over the manifest: the total falls by 1,699,925 lines.
    - `du -sh .repo` before and after the object-store cleanup.
    - After the renames: `check_manifest_xml --manifest default.xml` resolves
      both new names over the network, and the guest ELFs rebuild **byte-identical**
      to the ones built before the rename, which is what holding the
      `-ffile-prefix-map` targets buys. A diff in any ELF means a map target
      moved and the rename is wrong, not the build.
    """
  end
end
