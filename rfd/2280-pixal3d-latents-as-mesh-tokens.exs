# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2280. `mix rfd.render` renders this file's README.md and DETAILS.md under
# rfd/2280-pixal3d-latents-as-mesh-tokens/; the Markdown is a build artifact
# (RFD 2232).
defmodule RFD2280 do
  use RFD.DSL

  rfd 2280, "Pixal3D latents as mesh tokens" do
    state :ideation

    feature "Pixal3D's shape latent quantized into discrete mesh tokens, so a
token policy reads and writes meshes the way SkinTokens reads and writes
skin weights"

    scope "`3-interactor/pixal3d-ggml` and `pixal3d-upstream`, the shape
stage's sparse latent; `3-interactor/skin-tokens-ggml`, whose FSQ and
policy shape this copies"

    decision ~S"""
    Parked. The idea: put an FSQ bottleneck on Pixal3D's shape latent,
    the per-voxel features of its sparse structured latent, so each
    active voxel becomes one discrete code. A mesh is then a token
    sequence a Qwen-sized policy can read, edit and emit, as SkinTokens'
    TokenRig does for skin through its SkinVAE and FSQ codes. Mesh tokens
    and skin tokens in one stream would carry a rigged mesh as text. It
    stays parked until the round-trip loss and sequence length are
    measured.
    """

    problem ~S"""
    Pixal3D's latent is continuous, so the loop that carries it (RFD 1146)
    can only hand it to a decoder, and a repair arm that takes a mesh
    needs an extract step first. Nothing can edit a latent the way a
    language model edits text.
    """

    related ~S"""
    - RFD 1146 (latent to Pixal3D), the loop that carries the latent.
    - RFD 1040 (Pixal3D image to textured mesh), the model.
    - RFD 1046 (SkinTokens auto-rig), the pattern copied.
    - RFD 2279 (one deform surface), where skin tokens meet the mesh.
    """

    drafted_by :ai

    details_title "Pixal3D latents as mesh tokens"

    details "How it was drafted", ~S"""
    Drafted 2026-09-28 at the operator's request to write the idea down
    and park it, while RFDs 2275 and 2279 were in progress.
    """

    details "What the latent is", ~S"""
    Pixal3D is a three-stage cascade: sparse structure at 32 to 64,
    shape at 256 to 1024, and texture at 256 to 1024, all conditioned on
    pixel-aligned projection over two view-aligned latents. The shape
    stage's latent is a set of active voxels with a feature vector each,
    decoded to a mesh. Tokens would quantize those feature vectors, and
    the active-voxel set, which the first stage already makes discrete,
    orders the sequence.
    """

    details "Why the SkinTokens pattern fits", ~S"""
    SkinTokens runs a mesh encoder, a Qwen policy over its TokenRig
    grammar, FSQ code expansion and a chunked SkinVAE decoder, all in
    ggml in `skin-tokens-ggml`. FSQ needs no codebook to learn and no
    commitment loss, which is why it suits a bottleneck added to a
    trained latent. The workspace already holds residual FSQ in
    `3-interactor/residual-fsq-recommender`, a candidate when one level
    of codes loses too much.
    """

    details "What un-parks it", ~S"""
    Three measurements, each on held-out assets:

    - round-trip loss: mesh to latent to tokens to latent to mesh, as
      Chamfer distance at resolution 1024, against the continuous path;
    - sequence length per asset against the policy's context window,
      with the voxel order that keeps it shortest;
    - one token edit (move a region, delete a part) that decodes to a
      valid mesh without the extract step RFD 1146 needs.

    If the round-trip loss is not small beside the decoder's own error,
    the idea stays parked.
    """

    details "What it does not decide", ~S"""
    The texture latent, which would be a second token stream. Training
    data and compute for the bottleneck. Whether mesh and skin tokens
    share one vocabulary or two.
    """
  end
end
