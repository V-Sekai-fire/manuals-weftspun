# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2275. `mix rfd.render` renders this file's README.md and DETAILS.md under
# rfd/2275-unified-expressions-by-fitting-a-parametric-head/; the Markdown is a
# build artifact (RFD 2232).
defmodule RFD2275 do
  use RFD.DSL

  rfd 2275, "unified expressions by fitting a parametric head" do
    state :prediscussion

    feature "a purchased anime avatar with no tracking shapes gains the
unified-expression set from ANNY's facial actions, through one fitting core
whose interop is a `.sigs` file"

    scope "`headfit.sigs` and the C-ABI core behind it; its hosts (the NDMF
build pass in character-fox, a Godot import step, a native check runner);
ANNY's CC0 source data; `unified_expressions.map`; the avatar's face mesh"

    decision ~S"""
    Fit ANNY's head to the avatar's face and carry ANNY's 52 facial
    actions across under unified-expression names. One C-ABI core does
    both. `headfit.sigs` declares its surface and is drift-gated like
    `idtx_core.sigs`, and every host binds it through the generated
    table. The core reads ANNY's CC0 sources directly, with no Python
    anywhere. Names come from a one-line-per-name catalog. Blinks, gaze
    and the tongue start from the artist's sculpts; the core derives
    the tongue and corrective shapes they lack. GNM Head is the control.
    """

    problem ~S"""
    The face has 448 artist shapes and none moves the jaw, lips, cheeks
    or tongue for tracking. Its tracking layer kept 14 bindings, all eyes;
    the rest drive nothing. Sculpting some 90 shapes by hand is the cost
    this avoids.
    """

    related ~S"""
    - RFD 2271 (headset eye tracking to social VR), the sender of the
      unified-expression floats, and a `.sigs` boundary of its own.
    - RFD 2253 (a character creator on ANNY), the 52 actions and the
      non-Python port of ANNY's coefficient math.
    - RFD 2239 (traits and one binary): nothing at runtime reaches Python.
    """

    drafted_by :ai

    details_title "unified expressions by fitting a parametric head"

    details "How it was drafted", ~S"""
    Drafted 2026-09-28 from a survey of the avatar project, the Godot
    face modifier's name table, ANNY, SOMA-X and the GNM head fit, after
    the operator asked to fit either SOMA-X's ANNY or GNM Head. Revised
    the same day on three operator calls: the fit runs as an NDMF build
    pass, the interop follows the `.sigs` pattern, and no Python takes
    part. The artwork is a purchased avatar, described here by its
    measurements alone.
    """

    details "What the avatar has", ~S"""
    One skinned face mesh, 7,065 vertices in two submeshes, with 448
    blend shapes: visemes, a large set of stylised eye, brow and mouth
    sculpts, and ten shapes renamed in place to the 52-action capture
    names for eye closure and gaze. It has no squint, wide, jaw, lip,
    cheek, nose or tongue tracking shapes.

    The avatar's FX controller carries a baked face-tracking template
    layer. The bake dropped every binding whose shape was missing, so 14
    eye bindings survive and the rest are no-ops. The template set's
    unified variant animates about 90 names on the same path, and the
    same names are the primary spelling in Godot's face modifier table.
    """

    details "Why ANNY is the source", ~S"""
    ANNY's 52 facial actions are named, identity-independent and CC0.
    Everything the fit needs is plain text under ANNY's data directory:
    the MPFB2 base mesh `mpfb2/3dobjs/base.obj` (19,158 vertices), 99
    phenotype targets in `mpfb2/targets/macrodetails/*.target.gz`, the
    local-change targets beside them, the 52 actions in
    `faceunits01/targets/faceunits/*.target` indexed on that same base
    mesh, and the head region in `segmentation/`. Each target is lines of
    `index dx dy dz`, so the core parses them with no Python in between.

    GNM Head (Apache-2.0) has 253 identity and 383 expression components,
    eyeballs, teeth and a 32-component tongue. Its expressions are a
    learned basis with no names, and GNM is off the allowlist. It enters
    as the control: the same fit with GNM's head, so a residual only
    ANNY shows is ANNY's and not the avatar's.
    """

    details "The interop contract", ~S"""
    `headfit.sigs` holds one C declaration per line, opaque handles and
    primitives only, in the format of `iceoryx2.sigs` and
    `eye_server.sigs`. `generate_stubs.py` drift-gates it against the
    core's public header and emits the dlopen table each host binds, so
    a host adds no link dependency. A change to the fitting method is a
    change to this file, and the gate shows it to every host.

        hf_mesh *hf_mesh_create(const float *xyz, int32_t nv, const int32_t *tri, int32_t nt);
        int32_t hf_mesh_add_shape(hf_mesh *mesh, const char *name, const float *deltas);
        hf_model *hf_model_load(const char *anny_data_dir, int32_t region);
        hf_marks *hf_marks_create(const int32_t *model, const int32_t *avatar, int32_t n);
        hf_fit *hf_solve(const hf_model *m, const hf_mesh *t, const hf_marks *k, const float *w);
        float hf_fit_residual_mm(const hf_fit *fit, int32_t region);
        int32_t hf_transfer(const hf_fit *f, const char *shape, float *out_d, float *out_mm);
        void hf_fit_destroy(hf_fit *fit);
        void hf_marks_destroy(hf_marks *marks);
        void hf_model_destroy(hf_model *model);
        void hf_mesh_destroy(hf_mesh *mesh);

    The file lives with the fitting core in character-fox, whose owner
    implements it; this RFD fixes its shape.
    """

    details "The name catalog", ~S"""
    `unified_expressions.map` gives one line per unified name, in the
    style of a converter's API catalog:

        JawOpen          <= jawOpen
        LipFunnel        <= mouthFunnel
        LipSuckUpperLeft <= mouthRollUpper * mask:left
        EyeClosedLeft    <= artist:eye_closed_left
        TongueUpLeftMorph <= artist:tongue_up + artist:tongue_left
        TongueRoll       <= procedural:roll
        EyeClosedSquintCorrectiveLeft <= corrective:EyeClosedLeft*EyeSquintLeft

    Six forms: direct, split by a smooth mask across the midline or the
    lip line, an artist sculpt named by role, a sum of other entries, a
    procedural shape the core computes, and a corrective for a pair. The avatar's own sculpt names
    stay in character-fox. An audit reports zero unmapped names against
    the template set and Godot's face modifier table, with no `absent`
    entries, and a split pair sums to its parent.
    """

    details "The fit", ~S"""
    The fit runs on the MPFB2 base topology, the one the face units are
    indexed on. Unknowns: rigid transform, one scale, the six phenotype
    axes and the head and face local changes. The anchor rule that turns
    an axis value into target weights is ported with anny-creator's
    `anny_coeffs.gd` as the reference, and checked by that project's
    Godot parity check. Loss: the core's own point-to-surface distance
    to the avatar face, plus sparse landmarks (mouth corners, lip
    midline, chin, brow ends) marked once. LBFGS in double precision.

    The eyes leave the loss, because a stylised eye is a large flat
    painted region with no anatomy behind it; the nose is weighted down.
    The residual is reported per region with a household equivalent.
    GNM Head reached 4.38 mm, about three stacked pennies, against ANNY
    on human heads, which bounds what a human-to-human fit costs.
    """

    details "The transfer", ~S"""
    Each avatar vertex takes the barycentric blend of an action's deltas
    at the fitted surface point it projects to along its own normal. A
    normal test rejects surfaces facing away, and misses stay unmatched.
    Deltas are carried through the fit's rotation and scale into mesh
    space before skinning. A shape whose support has no matched vertex
    is refused, because at weight 0 it would look correct.

    Resampling is the first rung. If the lips smear because the avatar's
    mouth is far smaller than ANNY's, deformation transfer (Sumner and
    Popovic, doi 10.1145/1015706.1015736) over the same correspondence is
    the next.
    """

    details "The tongue and the mouth interior", ~S"""
    A surface fit cannot reach the tongue: it sits inside the mouth, and
    ray projection from it lands on nothing or on the lips. The tongue
    is handled on its own terms.

    The avatar carries about nine tongue sculpts: extend, up, down, each
    side, thinner, curl up, curl down. By role they give TongueOut,
    TongueUp, TongueDown, TongueLeft, TongueRight, TongueCurlUp and
    TongueBlendDown. TongueOutStep1 and TongueOutStep2 split the extend
    sculpt at the lip line: step 1 carries the tongue to the lips and
    step 2 carries it the rest of the way, and the two sum to the
    sculpt. The four diagonal morphs are sums of an up or down sculpt
    with a side sculpt.

    The sculpts do not cover TongueRoll, TongueTwistLeft/Right,
    TongueFlat and TongueSquish, so the core computes them in a tongue
    frame: tip, root and midline, marked as landmarks once. Roll lifts the
    lateral edges about the midline, twist rotates about the root-to-tip
    axis, flat widens and thins in height, and squish shortens and
    widens, each with a smooth falloff to zero at the root. ANNY's one
    tongueOut action, transferred, is compared against the extend sculpt
    as a cross-check.

    JawOpen moves the whole mouth interior. The lower teeth and the
    tongue take the rigid rotation about the jaw hinge that best fits the
    transferred chin and lower-lip deltas, so the interior opens with the
    jaw; the upper teeth stay still. An interior vertex that fits neither
    rigid part is reported.
    """

    details "Corrective shapes", ~S"""
    The template set drives seven correctives at the product of two
    weights: EyeClosed with BrowDown, BrowInnerUp, BrowOuterUp and
    EyeSquint, per side where the pair is sided. Each fixes what the two
    shapes do wrong together: a closed upper lid pushed through the brow
    or past the lower lid.

    The core derives each one. With both parents at weight 1, it finds
    the vertices that cross a surface they must stay behind: the upper
    lid against the brow and against the lower lid line, measured on the
    posed mesh. The corrective is the smallest displacement that clears
    every crossing by a fixed gap, spread by a Laplacian solve over the
    lid and brow region so it has no edge. A pair whose sum crosses
    nothing gets a zero corrective, written anyway, so the template's
    binding exists and its no-op is measured rather than assumed.

    JawOpen with MouthClosed is the one corrective the sources already
    carry: ANNY's mouthClose action is that shape, transferred like the
    rest.
    """

    details "Why build time", ~S"""
    The operator chose an NDMF build pass on 2026-09-28, as a deliberate
    exception for this tool to the 2026-09-12 direction that the avatar
    hold its built result. Three outputs keep it measurable: the NDMF
    preview, a build report, and a dump of the would-be-built mesh. The
    dump must equal the check runner's output bit for bit, so the build
    host cannot drift from the measured core.
    """

    details "What is measured before it ships", ~S"""
    The native check runner binds the core through the same table, and
    every check has a planted control that must fail, in the manner of
    anny-creator's `checks/run.sh`:

    - weight 0 on every new shape is the source mesh: drift 0 over all
      7,065 vertices;
    - the fit residual per region, and the GNM Head control;
    - each shape's error against its own magnitude, the unmatched count
      and the refusal list;
    - split pairs sum to their parent within float precision;
    - the catalog audit at zero unmapped;
    - the tongue step pair sums to the extend sculpt; each procedural
      tongue shape is zero at the root and changes volume by under 5%;
      with JawOpen at 1, no tongue or lower-teeth vertex is closer to the
      upper teeth than at rest;
    - with each corrective's parents at 1 and the corrective at 1, no
      vertex crosses the surface it must stay behind; with the corrective
      at 0, the crossings it was made for are counted and non-zero, or
      the corrective is zero;
    - procedurally generated heads with analytic ground truth recover
      their known transform and shapes;
    - the rebuilt tracking layer keeps a binding for every shape that
      exists, counted against the 14 today.
    """

    details "What this RFD does not decide", ~S"""
    Whether GNM's 32-component tongue should replace the procedural
    tongue shapes once it is on the allowlist. The core's language
    behind the C ABI, which its owner picks. Any second avatar: the
    catalog and landmarks are per avatar, and a second avatar is a second
    run.
    """
  end
end
