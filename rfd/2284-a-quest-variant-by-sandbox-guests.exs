# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2284. `mix rfd.render` renders this file's README.md and DETAILS.md under
# rfd/2284-a-quest-variant-by-sandbox-guests/; the Markdown is a build artifact
# (RFD 2232).
defmodule RFD2284 do
  use RFD.DSL

  rfd 2284, "A Quest variant by sandbox guests" do
    state :prediscussion

    feature "Miroir-Re builds a Quest variant at Poor: one or two skinned
meshes, four materials or fewer, 20,000 polygons or fewer, 150 bones or
fewer"

    scope "dress-on's `remesh.elf`, `unwrap.elf`, `bake.elf` and
`skintokens.elf`; meshoptimizer 1.3; the NDMF merge pass; Miroir-Re"

    decision ~S"""
    The Quest variant is built by four godot-sandbox guests reached
    through libgodot, the shape RFD 2277 set: C# holds no logic.
    meshoptimizer 1.3's voxel remesher and simplifier cut the merged
    body, xatlas unwraps it, compute-rd bakes the lilToon look into one
    atlas for a mobile shader, and SkinTokens on ggml-rd rigs the result
    with up to 150 bones. Each stage is checked against the source avatar
    with a planted-defect control.
    """

    problem ~S"""
    Measured on Android on 2026-09-28, Miroir-Re is Very Poor in six
    categories: 69,443 polygons, 11 skinned meshes, 19 materials, 352
    bones, 82 MB of textures, and its PhysBones. Its lilToon shaders do
    not upload to Quest.
    """

    related ~S"""
    - RFD 2277 (curvenet-cage refit), guests reached from NDMF.
    - RFD 2278 (voxel remeshing for cages and solids), the remesher.
    - RFD 2272 (RF-DETR on ggml-rd), a model guest on ggml-rd.
    - RFD 1160 (SkinTokens edge fit), the rigger.
    """

    drafted_by :ai

    details_title "A Quest variant by sandbox guests"

    details "Stages", ~S"""
    | Stage | Guest | Runs on | Output |
    |---|---|---|---|
    | Merge | NDMF pass | Unity | one skinned mesh per kept toggle state |
    | Remesh, simplify | `remesh.elf` | guest CPU | 20,000 triangles or fewer |
    | Unwrap | `unwrap.elf` | guest CPU | one UV atlas |
    | Bake | `bake.elf` | compute-rd | one texture set, mobile shader |
    | Rig | `skintokens.elf` | ggml-rd | 150 bones or fewer, humanoid kept |

    meshoptimizer and xatlas are libraries, not models, so their CPU use
    in a guest is not the CPU-as-model-target row. SkinTokens is a model
    and runs on ggml-rd only.
    """

    details "Baseline", ~S"""
    The dress merge ships: six meshes to one, posed error 0.0005 mm
    against the originals, far under a credit card's 0.76 mm, while a
    planted 2 mm shift (about 1.3 pennies) reads 2.00 mm. Skinned meshes
    went from 16 to 11 on PC.
    """

    details "Open", ~S"""
    - `meshopt_remesh` is experimental and writes positions only;
      attributes, blendshapes and skin weights come back by
      closest-surface transfer, which is where the error budget goes.
    - godot-fabric vendors meshoptimizer 1.2, which lacks the remesher;
      the guests vendor the manifest pin `9e1f07b`, which is 1.3.
    - Which toggles survive on Quest decides how many merged states are
      built.
    - SkinTokens' ops not yet on ggml-rd each go through L0 to L3, as
      RFD 2272 did for `cpy_f32_i32`.
    """
  end
end
