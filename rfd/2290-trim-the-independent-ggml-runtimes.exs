# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2290, "Trim the independent ggml runtimes", :discussion do
  feature "one ggml on the route, no second runtime beside it"
  scope "every placed row that carries a tensor runtime of its own"

  prose ~S"""
  :: decision
  ggml reaches the GPU through &{repo("contract-ggml-rd")} and compute-rd, inside
  godot-sandbox guests. A row carrying a runtime of its own, reached by a CLI
  or a NIF, is drift, so the manifest does not place it.

  Unplaced, five rows, 1,699,925 lines, no build reading any of them:
  `stable-diffusion-ggml`, `skin-tokens-ggml`, `nx-ggml`, `pixal3d-ggml`,
  `motion-bricks-ggml`. &{repo("kimodo-ggml")} is unplaced too; its
  sources are vendored in &{repo("interactor-motion-guest")}.

  Kept: &{repo("ggml")}, the library the guest ELFs link, and
  &{repo("interactor-rf-detr-ggml")}, the port, converters and weights.
  :: problem
  Eight placed rows carried ggml, four of them a vendored tree of about 2,130
  files each: 2,575,482 lines, 17 per cent of what the manifest placed on
  2026-10-01, on 0.71 GB. The cost is drift across eight trees, not disk. RFD
  2188 decided one canonical ggml with vendored copies deleted: Phase 1
  landed the framework, and this is Phase 2, the consumers.
  :: related
  - RFD 2188 placed &{repo("ggml")}; this is its Phase 2.
  - RFD 2287 computes in guest ELFs on ggml-rd or compute-rd, RFD 2268 makes
    EditScore a decision model there, and RFD 2289 abandoned the off-route
    runtimes. Abandons RFD 2230 beside 2242: no engine tree has `modules/ggml`.
  - RFD 2272's Gate 9 reads `rf-detr-ggml`'s `seg_cli`.
  """

  details_title "Trim the independent ggml runtimes"

  prose ~S"""
  :: details The inventory, measured 2026-10-01
  Lines are physical lines of tracked source. `vendored` counts files under a
  `ggml/`, `third_party/ggml` or `thirdparty/ggml` path inside the row.

  | row | lines | files | vendored | last commit | state |
  |---|---|---|---|---|---|
  | `stable-diffusion-ggml` | 755,287 | 3,824 | 3,421 | 2026-09-15 | unplaced |
  | `skin-tokens-ggml` | 437,355 | 2,211 | 2,136 | 2026-09-11 | unplaced |
  | &{repo("interactor-nx-ggml")} | 426,704 | 2,180 | 2,134 | 2026-08-21 | unplaced |
  | `pixal3d-ggml` | 40,727 | 87 | 0 | 2026-09-09 | unplaced |
  | `motion-bricks-ggml` | 39,852 | 593 | 153 | 2026-09-09 | archived, vendored in motion-guest |
  | &{repo("kimodo-ggml")} | 6,453 | 95 | 0 | 2026-09-29 | archived, vendored in motion-guest |
  | &{repo("ggml")} | 432,459 | 2,157 | canonical | 2026-09-30 | kept, the library |
  | &{repo("interactor-rf-detr-ggml")} | 436,645 | 2,260 | 2,133 | 2026-09-30 | kept, port and weights |
  | &{repo("contract-ggml-rd")} | 426,240 | 311 | the route | 2026-09-30 | kept, the route |
  :: details Why the five are free, by name
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
    `motion-guest/vendor/motion-bricks-ggml`, vendored at `e61da1f`, not
    this row.
  :: details Guest repositories build their own ELFs
  Each guest ELF builds in its own repository through
  &{repo("contract-guest-runtime")}'s `cmake/guest_runtime.cmake`, which
  supplies `add_stage_elf`, `sandbox_api`, `rd_compute`, `pump`, `ggml_rd`
  and &{repo("ggml")} stamped with a fixed `GGML_COMMIT`, so an ELF does
  not change with every ggml commit. The module maps each root through
  `-ffile-prefix-map`, so no ELF carries a checkout path.

  - &{repo("interactor-motion-guest")} builds `motion.elf` from
    `vendor/kimodo-ggml` (vendored at `9e62d0e`, byte-identical to
    kimodo-ggml's last commit) and `vendor/motion-bricks-ggml`, with
    `kimodo_weights.cpp` and `mb_runtime.cpp` beside them.
    `tools/motion_native` defaults `KIMODO_SRC` and `MB_SRC` to the same
    vendored trees.
  - &{repo("interactor-rfdetr-seg-guest")} builds `rfdetr_seg.elf` from
    `vendor/rf-detr-ggml`, the 14 `src/` files of
    &{repo("interactor-rf-detr-ggml")} at `ca2aef7`.
  - &{repo("interactor-rf-detr-ggml")} keeps the port itself, the
    `convert_*_to_gguf.py` converters, and the GGUF weights on its
    `v0.1.0-dev` release, which rfdetr-seg-guest pins by sha256.

  &{repo("transport-meshing-pen")} builds neither ELF. None of these is a
  second runtime, so none is trimmed.
  :: details How this is verified
  The claim is that the unplaced rows are not build inputs, so the test is
  the build rather than the argument.

  - The manifest gates, from `.repo/manifests`: `check_manifest_xml`
    (`--self-test`, then `--manifest default.xml`, which resolves every
    revision over the network), `check_manifest_comments`,
    `check_manifest_root --manifest-only`, `check_manifest_dupes` and
    `sync.exs --self-test`, each with its own negative controls.
  - Each guest repository's CI builds its ELF beside only
    contract-guest-runtime, contract-ggml-rd, ggml and
    &{repo("repository-riscv64-sysroot")}, with no `*-ggml` checkout.
    `tools/check_vendor.exs` refuses a planted line naming a `*-ggml`
    checkout in motion-guest, and a vendored file that differs from
    `ca2aef7` in rfdetr-seg-guest.
  - `tools/check_bintr.exs` in each guest repository runs the ELF in the
    pinned godot-sandbox addon with its native translation, asserts
    `is_binary_translated()` and outputs equal to the interpreter's, and
    fails with translation off.
  """
end
