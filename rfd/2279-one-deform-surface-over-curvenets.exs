# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2279. `mix rfd.render` renders this file's README.md and DETAILS.md under
# rfd/2279-one-deform-surface-over-curvenets/; the Markdown is a build artifact
# (RFD 2232).
defmodule RFD2279 do
  use RFD.DSL

  rfd 2279, "one deform surface over curvenets" do
    state :prediscussion

    feature "cages, sketched curvenets and skeletons bind and deform a mesh
through one sandbox vmcall table, and any binding bakes to bones or to
blend shapes"

    scope "`deform_guest.sigs` and `guest/common/deform/` in interactor-cage,
registered by `cage.elf` and `curvenet.elf`; the Lean kernels behind it"

    decision ~S"""
    The curvenet is the only control. A cage is a curvenet built from an
    arbitrary mesh: edges are curves, vertices are knots, faces are
    cycles. A skeleton is a curvenet with bones for curves, joints for
    knots and no cycles. A binding method (biharmonic, harmonic, inverse
    distance, linear blend) turns a curvenet and a mesh into per-vertex
    weights and refuses a curvenet that fails its precondition. Every
    binding bakes to bones, shape sets decompose to bones, and bones bake
    back to shapes. Every kernel is emitted from Lean.
    """

    problem ~S"""
    The cage deformer and CASSIE's profile mover both bind a control to
    weights and deform, and neither knows the other: two control types,
    two weight tables, one skin bake. Bones, twist bones and corrective
    shapes had no place in either.
    """

    related ~S"""
    - RFD 2277 (cage fitting as a sandbox guest), the biharmonic method.
    - RFDs 2265 and 2274, the curvenet guest and its crossings.
    - RFD 2275 (unified expressions), the first client.
    """

    drafted_by :ai

    details_title "one deform surface over curvenets"

    details "How it was drafted", ~S"""
    Drafted 2026-09-28 after the operator asked whether the cage deformer
    and the curvenet could share one API surface, and then ruled that a
    cage is a kind of curvenet, since cages are arbitrary meshes. The
    operator also asked for corrective shapes, twist bones and
    conversion between shapes and bones both ways, and pointed at
    SkinTokens. The split of work with the cage session is agreed there.
    """

    details "What the survey found", ~S"""
    Neither tool uses the other. Both bind a control to per-vertex
    weights once and deform linearly after that.

    - The cage deformer (`MeshMorph3D`) computes biharmonic coordinates
      for triangle cages (Thiery, Michel and Chen, SIGGRAPH 2024) and
      deforms by the sum of weighted cage vertices and weighted face
      normals. Its derivatives exist as free functions and are unbound.
    - CASSIE's `CassieProfileMover` binds a surface patch to curvenet
      knots by inverse distance or by a harmonic solve with the curves
      as the boundary, and its `bake_skin` already writes one bone per
      knot.

    They differed in four ways: control variables, weight domain
    (volumetric or on the surface), dense closed form or sparse solve,
    and whether a skin bake exists. The first dissolves once a cage is a
    curvenet, since a cage vertex is a knot's translation. The second and
    third become properties of a binding method. The fourth becomes one
    call every method shares.
    """

    details "The surface", ~S"""
    Godot types, integer handles, one destroy, in the `cage_guest.sigs`
    format:

        int net_from_mesh(PackedFloat32Array xyz, PackedInt32Array faces,
            PackedInt32Array counts);
        int net_from_skeleton(PackedFloat32Array rest, PackedInt32Array parents,
            PackedInt32Array twist_of);
        int net_from_strokes();
        int mesh_create(PackedFloat32Array xyz, PackedInt32Array tri);
        int bind(int net, int mesh, String method);
        Dictionary weights(int bind);
        PackedFloat32Array deform(int bind, PackedFloat32Array knots_posed);
        PackedFloat32Array jacobian(int bind, PackedInt32Array vertex_ids);
        int bake_skin(int bind, int max_influences);
        int shapes_to_skin(int mesh, PackedStringArray shapes, int bones,
            int init_skin);
        PackedStringArray skin_to_shapes(int skin, Dictionary poses);
        int corrective(int mesh, String a, String b, Dictionary rule);
        int pose_corrective(int skin, Dictionary pose, String target);
        PackedFloat32Array twist_split(int skin, int bone,
            PackedFloat32Array shares);
        void destroy(int handle);

    `net_from_mesh` takes polygons of any size (`counts` per face).
    `net_from_strokes` reads the curvenet guest's own state and exists in
    `curvenet.elf` only. `knots_posed` is one transform per knot; a
    method that reads only translations ignores the rest.
    """

    details "Methods and their preconditions", ~S"""
    - `bhc13`, biharmonic: the net's cycles form a closed, consistently
      oriented surface. Polygon cycles are triangulated at bind time and
      the net keeps its polygons. Volumetric: any point inside binds.
    - `harmonic`: the curves lie on the bound mesh. A Laplacian solve on
      the mesh with the curves as the boundary, as CASSIE's mover does.
    - `idw`: any net. Nearest samples per curve, the mover's fallback.
    - `lbs`: a net with transforms on its knots, a skeleton in practice.

    A bind that fails its precondition is refused with the reason named,
    so an open cage never binds by the biharmonic method and returns
    weights that look plausible.
    """

    details "Bones and shapes, both ways", ~S"""
    `bake_skin` turns any binding into bones and linear-blend weights,
    one bone per knot, capped at `max_influences`, generalising the
    mover's bake. `shapes_to_skin` decomposes a set of blend shapes into
    rigid bone poses and weights (Le and Deng, doi 10.1145/2185520.2185573)
    and returns what the bones cannot carry as residual shapes.
    `init_skin` may be a SkinTokens rig, which runs as a ggml guest the
    way RFD 2272 runs RF-DETR. `skin_to_shapes` bakes bone poses back to
    blend shapes, each the deformed mesh minus the rest.

    So every expression can ship as a shape, a bone or both, whichever a
    host drives: Godot's face modifier drives shapes only, and a jaw or a
    tongue reads better as bones.
    """

    details "Twist bones and correctives", ~S"""
    A skeleton net carries `twist_of`: a twist bone takes a share of its
    parent's roll. `twist_split` distributes the roll along the chain,
    and the shares sum to the roll and stay inside the kusudama twist
    range. This is the guard for the forearm twist defect PITFALLS
    records at the lowerarm01/lowerarm02 weight boundary.

    `corrective` makes the shape for a pair: with both parents at weight
    1, the smallest Laplacian-smoothed displacement that clears the
    crossings the rule names. `pose_corrective` does the same where a
    pose of linear-blend and twist bones misses a sculpt, as a
    pose-space correction.
    """

    details "Who owns what", ~S"""
    The cage session owns `cage.elf`, the sandbox host in the other
    engine, the NDMF pass, the head-fit entries, the biharmonic bind,
    deform and Jacobian, and the L-BFGS-B solver. This RFD's author owns
    the rest of `guest/common/deform/`: the net builders, the harmonic,
    inverse-distance and linear-blend methods, `weights`, the skin bake,
    the shape and bone conversions, the correctives and twist. The
    biharmonic code sits in `guest/common/deform/bhc13/` behind an
    internal interface the table wraps. Every kernel, the Jacobian's
    vector-Jacobian products included, is emitted from Lean.
    """

    details "What is measured before it ships", ~S"""
    Each check has a planted control that must fail:

    - `gates/4-curvenet` (in the archived `interactor-dress-on`) stays at
      10 of 10 with the table registered;
    - a cage built with `net_from_mesh` binds by `bhc13` to the same
      weights `MeshMorph3D` computes, and an open cage is refused;
    - `bake_skin` on a sketched net matches `CassieProfileMover`'s bake;
    - `shapes_to_skin` recovers an analytic set of rigid-motion shapes
      exactly, and noise planted in one shape shows as its residual;
    - shape to skin to shape round-trips within a stated bound in
      millimetres with a household equivalent;
    - `twist_split` shares sum to the roll and stay in range;
    - each corrective clears its crossings at both parents set to 1.
    """

    details "What this RFD does not decide", ~S"""
    The cage's own construction around a head or a garment, which RFD
    2277 owns. Whether SkinTokens' predicted skeletons are in
    distribution for stylised faces. GPU dispatch of the kernels through
    compute-rd, which RFD 2265 governs for the curvenet.
    """
  end
end
