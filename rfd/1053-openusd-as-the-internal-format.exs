# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 1053, "OpenUSD as the internal format", :committed do
  flight_level :l2
  feature "asset interchange"
  attest_in :none

  prose ~S"""
  :: decision
  OpenUSD is the internal format. Every stage reads a stage and writes a
  layer. glTF, VRM, and KHR avatar stay the transmission formats, and
  the pipeline converts to them at the edge.

  USD is to this pipeline what `.blend` is to Blender. It is the working
  file, and it never reaches a browser.

  See `DETAILS.md` for why layers beat a flat mesh format, the
  internal/transmission boundary, worlds, the shared runtime, and what
  every model image must return.

  Committed 2026-09-02: CLAUDE.md ratifies the choice as a hard
  constraint (OpenUSD `.usda` for text-editable, ZStandard parquet for
  bulk; zip and gzip banned; usdz exempt). RFD 2169 abandoned the
  Elixir studio core; the `fabric-stage-runtime` Hex package still
  ships OpenUSD to every consumer.
  :: problem
  Each pipeline stage reads a GLB and writes a GLB. A rig stage rewrites
  the whole file to add bones. A texture stage rewrites it again.

  Every rewrite loses what came before. glTF holds one flat result, thus
  a stage cannot add an opinion without erasing the previous author.
  When a mesh is wrong, no record says which stage made it wrong.
  :: related
  RFD 1036 gives the model image convention. `fabric-stage-runtime`
  (Hex) links this runtime to every stage. RFD 1002 records the
  pipeline stages that become layers.
  """

  details_title "OpenUSD as the internal format"

  prose ~S"""
  :: details Why layers, and not a better mesh format
  USD composes. A stage adds a sublayer with its own opinion, and the
  layer below stays intact and readable.

  | Stage        | Writes                                |
  | ------------ | ------------------------------------- |
  | image to 3D  | the base mesh layer                   |
  | retopology   | a layer that overrides the mesh       |
  | UV unwrap    | a layer that adds the primvar         |
  | segmentation | a layer of part scopes                |
  | rig          | a layer of skeleton and skin bindings |
  | texture      | a layer of material bindings          |

  A caller may then mute the retopology layer and see the original. That
  is not possible in a flat file.
  :: details The boundary
  | Direction  | Format                       |
  | ---------- | ---------------------------- |
  | Internal   | `.usdc`, and `.usda` to read |
  | Avatar out | VRM, or KHR avatar           |
  | Asset out  | glTF binary                  |
  | Archive    | `.usdz`                      |

  Convert at the boundary only. A stage that converts in the middle
  throws away the composition this RFD exists to keep.
  :: details Worlds
  A world is a USD stage as well. Its root layer names a spawn point and
  sublayers the environment and the props; each prop is a prim with its
  mesh, transform and interaction type. The avatar, the world and its
  props stay in separate layers, so loading one never replaces another.
  :: details The runtime
  `fabric-stage-runtime` ships OpenUSD 26.5.0 as an Elixir Hex package.
  It exposes `include_dir/0`, `lib_dir/0`, and `target/0`, thus every
  consumer links the same USD build the model images write. (An
  earlier draft named "the Elixir core from RFD 1019" as the consumer;
  RFD 2169 abandoned that plan, and the Hex package survives without
  the studio-core wrapper.)

  One USD version across the pipeline matters. A layer written by a
  newer build may not open in an older one.
  :: details What each model image must do
  `predict()` returns the USD layer, and it returns the transmission
  file as well. The caller keeps the layer, and it ships the other.

  RFD 1036 records this in the model image convention.
  """
end
