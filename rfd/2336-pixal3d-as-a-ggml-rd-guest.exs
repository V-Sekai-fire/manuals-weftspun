# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2336, "Pixal3D as a ggml-rd guest", :discussion do
  feature "Pixal3D image-to-3D, multi-view shape and PBR texture, in a godot-sandbox guest"
  scope "the Pixal3D guest, its GGUF weights, and the ggml-rd kernels it reaches"

  prose ~S"""
  :: decision
  - Pixal3D runs as a godot-sandbox guest ELF whose ggml graph runs on
    &{repo("contract-ggml-rd")}. No PyTorch, no container and no CUDA extension (operator,
    2026-10-27).
  - The first version is the whole pipeline: up to four views in, a mesh with PBR material out
    (operator, 2026-10-27).
  - The model code starts from `pixal3d-ggml`, a TRELLIS.2 port with per-stage parity, vendored
    into a guest repository shaped like &{repo("interactor-rfdetr-seg-guest")}. The new part
    is Pixal3D's multi-view conditioning.
  - Each stage passes on ggml-cpu against the PyTorch reference, then on ggml-rd against
    ggml-cpu. Each gate has a planted control that must fail.
  - Weights convert to GGUF in their original dtype, BF16 for the flows. The image encoder's
    GGUF ships with the others (operator, 2026-10-27).
  - Input without alpha goes through the MIT high-resolution matting model (operator,
    2026-10-27).
  - The material bakes to UDIM texture tiles, then each tile becomes a material of its own
    with UVs in 0 to 1, the split the MIT UDIM unpack tool makes (operator, 2026-10-27).
  :: problem
  The Pixal3D demo needs PyTorch, CUDA 13 and five CUDA extensions, each built for one GPU
  generation only. It runs outside a guest, which RFD66606-2290 rules out for ggml work. The
  ggml port that exists was unplaced for carrying a runtime of its own.
  :: related
  - RFD66606-2290, ggml only in guests; RFD66606-1040, the Pixal3D model image; RFD66606-2294.
  """

  details_title "Pixal3D as a ggml-rd guest"

  prose ~S"""
  :: details What the workspace holds today
  - The demo pipeline: background removal, a ViT-L/16 image encoder (DINOv3), four flow
    transformers of 1.3B parameters each (sparse structure at 64, shape at 512 and 1024, texture
    at 1024), the structure decoder and the shape and texture decoders. Each flow takes
    features from the encoder projected onto its voxel grid from every view.
  - Views 1 to 3 carry azimuth and elevation. Each camera maps relative to view 0, as
    `F @ inv(C_0) @ C_i`, so the front view stays at azimuth 0 and elevation 0.
  - `pixal3d-ggml` (TRELLIS.2 single view) passes parity on every stage it ports: preprocess
    byte-exact, encoder rel-L2 under 7e-7, the structure flow 2.4e-4, the structure decoder
    2e-5, the shape flow 2.9e-4, the shape decoder under 6e-7, the 1024 cascade within 2e-2. It
    also ports the texture flow and decoder, dual-grid mesh extraction and GLB export with
    per-vertex PBR.
  - It calls 69 ggml functions. &{repo("contract-ggml-rd")} carries a kernel for every op among
    them, including direct 3D convolution and flash attention.
  - The projected multi-view features are not ported: the grid projection and the multi-view
    feature extractor, and the multi-view checkpoints that read them.
  :: details What each CUDA extension did, and what replaces it
  | Extension | Role in the demo | In the guest |
  |---|---|---|
  | sparse GEMM | sparse convolution in the decoders | gather and matmul, as the port does |
  | voxel to mesh | surface from the decoded voxels | the port's dual-grid extraction |
  | mesh clean-up | simplify, repair, UV unwrap | meshoptimizer, already in the port |
  | rasteriser | renders for the texture bake | a texture-bake kernel on ggml-rd |
  | PBR render | environment-lit preview | not used: the viewer renders |
  :: details UDIM tiles, and where the unpack runs
  The unpack tool picks each polygon's tile from its lowest U and V (1001 plus the U column,
  plus ten per V row, ten columns), with a small tolerance at tile edges. It splits the
  material into one copy per tile and shifts the UVs back into 0 to 1. glTF has no UDIM, so
  that split is what lets one baked material reach a GLB as plain textures.
  The tool reads and writes FBX through a closed vendor SDK that no guest can link. Its tile
  rule and material split are ported, MIT, into the bake guest that already packs atlases and
  moves UVs. They run on the guest's mesh arrays, not on FBX.
  The tool skips a polygon whose UVs span more than one tile, leaving it on the first
  material. Our bake lays out every chart inside one tile, so the port refuses such a polygon
  instead of skipping it.
  Gate: each polygon's tile and its shifted UVs equal the tool's output on a fixture with
  three tiles. Control: a planted polygon spanning two tiles must fail the bake.
  :: details Weights
  Measured from the multi-view checkpoint files on disk, all MIT:
  - Structure flow 5,360 MB; shape flow 512 and shape flow 1024, 5,547 MB each; texture flow
    5,547 MB. BF16.
  - Structure decoder 148 MB; shape and texture decoders 948 MB each. FP16.
  - Image encoder 1.21 GB, under its own licence rather than MIT. Matting model 0.44 GB, MIT.
  One generation reads about 24 GB of weights, above a 24 GB card, so stages load one at a time.
  :: details Gates and controls
  | Gate | Pass | Control that must fail |
  |---|---|---|
  | each stage on ggml-cpu | the port's tolerance against PyTorch | a planted wrong weight |
  | multi-view projection | grid features against PyTorch | view 0 and view 1 swapped |
  | each stage on ggml-rd | against ggml-cpu | a planted broken kernel |
  | whole run | mesh close to PyTorch's (same seed) | a different seed |
  Distance is chamfer on the normalized mesh. The pass bound for the whole run is set from the
  seed-to-seed spread, measured first.
  :: details What is not known
  - How each texel is filled on ggml-rd: rasterising into UV space with a kernel of its own,
    or sampling the voxel PBR field at each texel. The first step settles it.
  - How many tiles and what texel density per tile. Not measured.
  - Time per generation and peak device memory on ggml-rd: not measured.
  - Flash attention at the 1024 cascade's token count on ggml-rd: not measured.
  """
end
