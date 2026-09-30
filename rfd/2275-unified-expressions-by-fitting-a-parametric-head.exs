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
unified-expression set from ANNY's facial actions, fitted and carried
across by the cage guest"

    scope "the head-fit entries of `cage.elf` (RFD 2277) and the deform
table (RFD 2279); ANNY's CC0 source data; `unified_expressions.map`; the
avatar's face mesh"

    decision ~S"""
    Fit ANNY's head to the avatar's face through a cage and carry ANNY's
    52 facial actions across under unified-expression names. The work
    runs in the `cage.elf` sandbox guest (RFD 2277) on the deform table
    of RFD 2279, with no Python anywhere. Names come from a
    one-line-per-name catalog. Blinks, gaze and the tongue start from the
    artist's sculpts; the guest derives the tongue and corrective shapes
    they lack, and ships jaw and tongue as bones and as shapes. GNM Head
    is the control.
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
    - RFD 2277 (curvenet-cage refit and unified expressions in Modular Avatar), the host.
    - RFD 2279 (one deform surface over curvenets), bones and shapes.
    - RFD 2253 (a character creator on ANNY), the 52 actions.
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
    `index dx dy dz`. The guest has no filesystem, so the host uploads
    these files as job data and the guest parses them.

    GNM Head (Apache-2.0) has 253 identity and 383 expression components,
    eyeballs, teeth and a 32-component tongue. Its expressions are a
    learned basis with no names, and GNM is off the allowlist. It enters
    as the control: the same fit with GNM's head, so a residual only
    ANNY shows is ANNY's and not the avatar's.
    """

    details "The interop contract", ~S"""
    Three `.sigs` files carry the boundary, and this RFD points to them
    rather than holding a copy:

    - `unity_sandbox.sigs` (RFD 2277): the sandbox host's C ABI, which
      the second engine calls and a native check runner loads;
    - `cage_guest.sigs` (RFD 2277): `cage.elf`'s vmcall table, the
      head-fit entries (`hf_mesh_create`, `hf_model_load`,
      `hf_marks_create`, `hf_solve`, `hf_fit_residual_mm`,
      `hf_transfer`, `hf_destroy`) and the cage build, preview and dump;
    - `deform_guest.sigs` (RFD 2279): nets, binds, deform, Jacobian, the
      skin bake, the conversions between shapes and bones, correctives
      and twist.

    Handles are guest integers with one destroy. A mix task drift-gates
    each file against its implementation, and a change to the fitting
    method is a change to one of them.
    """

    details "The name catalog", ~S"""
    `unified_expressions.map` gives one line per unified name, in the
    style of a converter's API catalog:

        JawOpen          <= jawOpen
        LipFunnel        <= mouthFunnel
        LipSuckUpperLeft <= mouthRollUpper * mask:left
        EyeClosedLeft    <= artist:eye_closed_left
        TongueUpLeftMorph <= artist:tongue_up + artist:tongue_left
        TongueRoll       <= bone:tongue_chain
        EyeClosedSquintCorrectiveLeft <= corrective:EyeClosedLeft*EyeSquintLeft

    Six forms: direct, split by a smooth mask across the midline or the
    lip line, an artist sculpt named by role, a sum of other entries, a
    procedural shape, and a corrective for a pair. Two more come from
    RFD 2279: `bone:<name>` drives a bone, and `baked:<skin>` is a shape
    baked from bone poses. The avatar's own sculpt names stay in
    character-fox. An audit reports zero unmapped names against
    the template set and Godot's face modifier table, with no `absent`
    entries, and a split pair sums to its parent.
    """

    details "The fit", ~S"""
    The fit runs on the MPFB2 base topology, the one the face units are
    indexed on. Unknowns: rigid transform, one scale, the six phenotype
    axes and the head and face local changes. The anchor rule that turns
    an axis value into target weights is ported with anny-creator's
    `anny_coeffs.gd` as the reference, and checked by that project's
    Godot parity check. ANNY's head is bound to a coarse closed cage,
    a net built from that mesh by RFD 2279's biharmonic method, and the
    cage vertices join the unknowns. Loss: point-to-surface distance to
    the avatar face, plus sparse landmarks (mouth corners, lip midline,
    chin, brow ends) marked once. The solver is contract-lbfgsb's gated
    L-BFGS-B in single precision with double-single dot products, by the
    operator's ruling, with the Jacobian from Lean vector-Jacobian
    kernels.

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

    details "What ships in which stage", ~S"""
    RFD 2277's ladder carries this RFD in two steps.

    - **First stage.** The head fit and the transfer of all 52 actions
      under their unified names through `unified_expressions.map`, each
      with its error reported: the direct, split and artist forms of the
      catalog. The eye shapes come from the artist's sculpts here.
    - **Second stage.** Everything that is derived rather than
      transferred: the tongue (sculpt roles, the lip-line steps, flat and
      squish, the chain with its roll and twist), the jaw bone and the
      rigid mouth interior, the seven correctives, the bone and baked
      forms, and every conversion between shapes and bones from RFD 2279.

    The catalog audit is scoped to the stage: zero unmapped names among
    the first stage's forms, then zero unmapped names in all.
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
    TongueFlat and TongueSquish. Roll and twist come from the tongue
    chain under "Bones and shapes". Flat and squish are computed in a
    tongue frame (tip, root and midline, marked as landmarks once): flat
    widens and thins in height, squish shortens and widens, each with a
    smooth falloff to zero at the root. ANNY's one
    tongueOut action, transferred, is compared against the extend sculpt
    as a cross-check.

    JawOpen moves the whole mouth interior. The lower teeth and the
    tongue take the rigid rotation about the jaw hinge that best fits the
    transferred chin and lower-lip deltas, so the interior opens with the
    jaw; the upper teeth stay still. An interior vertex that fits neither
    rigid part is reported.
    """

    details "Bones and shapes", ~S"""
    Jaw and tongue ship both ways, through RFD 2279. `shapes_to_skin`
    over jawOpen and the mouth interior gives a jaw bone. Over the
    artist's tongue sculpts it gives a tongue chain, with a SkinTokens rig
    as the starting point where that converges faster. Tongue roll and
    twist are `twist_split` on that chain rather than procedural deltas.
    `skin_to_shapes` then bakes every bone-driven name back to a blend
    shape for hosts that drive shapes only, Godot's face modifier among
    them, and the bones stay for hosts that drive bones. Where a baked
    shape misses its sculpt, `pose_corrective` makes up the difference.
    """

    details "Corrective shapes", ~S"""
    The template set drives seven correctives at the product of two
    weights: EyeClosed with BrowDown, BrowInnerUp, BrowOuterUp and
    EyeSquint, per side where the pair is sided. Each fixes what the two
    shapes do wrong together: a closed upper lid pushed through the brow
    or past the lower lid.

    The guest derives each one. With both parents at weight 1, it finds
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
    host cannot drift from the measured guest.
    """

    details "What is measured before it ships", ~S"""
    The native check runner loads `cage.elf` through the sandbox C ABI, and
    every check has a planted control that must fail, in the manner of
    anny-creator's `checks/run.sh`:

    - weight 0 on every new shape is the source mesh: drift 0 over all
      7,065 vertices;
    - the fit residual per region, and the GNM Head control;
    - each shape's error against its own magnitude, the unmatched count
      and the refusal list;
    - split pairs sum to their parent within float precision;
    - the catalog audit at zero unmapped;
    - the tongue step pair sums to the extend sculpt; flat and squish
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
    Whether GNM's 32-component tongue should replace the
    tongue chain once it is on the allowlist. The guest's source language
    behind the vmcall table, which its owner picks. Any second avatar: the
    catalog and landmarks are per avatar, and a second avatar is a second
    run.
    """
  end
end
