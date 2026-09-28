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
unified-expression set, carried from ANNY's facial actions onto its face by
fitting ANNY's head to it"

    scope "character-fox: the avatar's face mesh, `Tools/rig`, one editor
writer beside `FitOffsetWriter`; ANNY's 52 facial actions; the social-VR
face-tracking template layer the avatar already carries"

    decision ~S"""
    Fit ANNY's head to the avatar's face, then carry ANNY's 52 facial
    actions across as shapes with unified-expression names; the fit turns
    that into the resampling `blendshape_transfer.py` already measures.
    Blinks and gaze reuse the artist's own sculpts. Side and lip splits
    are masks over the 52. Weight 0 is the original mesh, checked. GNM
    Head is the control, not the source: its expressions carry no names.
    """

    problem ~S"""
    The face has 448 artist shapes and none moves the jaw, lips, cheeks
    or tongue for tracking. Its tracking layer kept 14 bindings, all eyes;
    the rest drive nothing. Sculpting some 90 shapes by hand is the cost
    this avoids.
    """

    related ~S"""
    - RFD 2271 (headset eye tracking to social VR), the sender of the
      unified-expression floats these shapes receive.
    - RFD 2253 (a character creator on ANNY), the 52 actions under FACS
      action-unit numbers.
    - RFD 2234 (dress-on pipeline), the LBFGS head fit and its residual.
    """

    drafted_by :ai

    details_title "unified expressions by fitting a parametric head"

    details "How it was drafted", ~S"""
    Drafted 2026-09-28 from a survey of the avatar project, the Godot
    face modifier's name table, ANNY, SOMA-X and the GNM head fit, after
    the operator asked to fit either SOMA-X's ANNY or GNM Head. The
    choice of ANNY as the source is the AI's proposal. The artwork is a
    purchased avatar, described here by its measurements alone.
    """

    details "What the avatar has", ~S"""
    One skinned face mesh, 7,065 vertices in two submeshes, with 448
    blend shapes: visemes, a large set of stylised eye, brow and mouth
    sculpts, and ten shapes renamed in place to the 52-action capture
    names for eye closure and gaze. There are no squint, wide, jaw, lip,
    cheek, nose or tongue tracking shapes.

    The avatar's FX controller carries a baked face-tracking template
    layer. Its clips address shapes on the face mesh by name, and the
    bake dropped every binding whose shape was missing, so 14 eye
    bindings survive and everything else is a no-op.

    The template set's unified-expression variant animates about 90
    names on the same path. The same names are the primary spelling in
    Godot's face modifier table, so one name set serves the social-VR
    build and a Godot or glTF export.
    """

    details "Why ANNY is the source", ~S"""
    ANNY's 52 facial actions are named, are identity-independent (a fixed
    delta on the template, the same for every phenotype), and ship in
    the tree as CC0 sparse targets under `faceunits01`. `Anny(topology=
    "head", facial_actions="all")` gives a head submodel with eyes and
    tongue. ANNY is already on the allowlist.

    GNM Head (Apache-2.0) has the richer face: 253 identity and 383
    expression components, eyeballs, teeth and a 32-component tongue. Its
    expressions are a learned basis plus an emotion sampler, so a named
    shape would first have to be solved for as a coefficient vector, a
    second fit with no ground truth. GNM is also not on the allowlist.
    It enters as the control: the same fit run with GNM's head, so a
    residual that only ANNY shows is ANNY's and not the avatar's.
    """

    details "The fit", ~S"""
    Unknowns: rigid transform, one scale, ANNY's six phenotype axes and
    its head and face local changes. Loss: point-to-surface distance from
    ANNY's head vertices to the avatar face, plus sparse landmarks
    (mouth corners, lip midline, chin, brow ends) marked once on the
    avatar. `soma-x`'s Chamfer loss supplies the distance term. LBFGS in
    float64, as RFD 2234 uses.

    The eyes are excluded from the loss. A stylised eye is a large,
    nearly flat painted region with no human anatomy behind it, and
    fitting to it would pull the brow and cheek. The nose is weighted
    down for the same reason.

    The residual is reported per region (lips, jaw, cheeks, brows) in
    millimetres with a household equivalent; GNM Head reached 4.38 mm,
    about three stacked pennies, against ANNY on human heads, which
    bounds what a human-to-human fit costs.
    """

    details "The transfer", ~S"""
    After the fit, each avatar vertex has a nearest point on ANNY's
    surface, and `blendshape_transfer.transfer_all` resamples each
    action's deltas there: ray mode along the avatar's normals, a normal
    test, and misses left unmatched, never filled. Deltas are carried
    through the fit's rotation and scale into mesh space before skinning.

    `shape_error` is reported for every shape against its own magnitude.
    A shape whose support has no matched vertex is refused rather than
    written, because at weight 0 it would look correct.

    Resampling is the first rung. If the lips come back smeared because
    the avatar's mouth is far smaller than ANNY's, deformation transfer
    (Sumner and Popovic, doi 10.1145/1015706.1015736) over the same
    correspondence is the next rung.
    """

    details "The names", ~S"""
    Direct: each of the 52 goes to its unified name through the alias
    table in Godot's face modifier (`jawOpen` to JawOpen, `mouthFunnel`
    to LipFunnel, `mouthRollUpper` to LipSuckUpper, `eyeBlinkLeft` to
    EyeClosedLeft).

    Split: unified names finer than the 52 (LipSuckUpperLeft,
    LipFunnelLowerRight, CheekPuffLeft, MouthUpperUpLeft and the like)
    are the parent delta times a smooth mask across the face's midline
    or its lip line. A split pair sums to its parent, checked.

    Artist: eye closure, squint, wide and gaze use the artist's own
    sculpted eye shapes, copied under the unified name. The ten shapes
    already renamed in place are left as they are.

    Absent: corrective shapes and tongue steps the template set drives
    stay outside this RFD; their bindings stay no-ops.
    """

    details "What is measured before it ships", ~S"""
    - Weight 0 on every new shape is the original mesh: maximum vertex
      drift 0 over all 7,065 vertices, measured by baking the mesh.
    - The fit residual per region, and the same fit with GNM Head as the
      control.
    - Each transferred shape's `shape_error` and unmatched count, and a
      refusal list.
    - Split pairs sum to their parent within float precision.
    - An isolated screenshot of each shape at weight 1 beside the
      parent action on ANNY, read by a person.
    - The template layer rebuilt against the new mesh keeps a binding for
      every shape that now exists, counted against the 14 today.
    """

    details "What this RFD does not decide", ~S"""
    Tongue geometry beyond ANNY's one tongue action; GNM's 32-component
    tongue is the candidate. Corrective shapes. Whether the stylised
    artist shapes should be rebuilt from the transferred ones. Any second
    avatar: the writer names its target mesh, and a second avatar is a
    second run.
    """
  end
end
