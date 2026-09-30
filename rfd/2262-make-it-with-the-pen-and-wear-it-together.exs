# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2262. `mix rfd.render` renders rfd/2262-make-it-with-the-pen-and-wear-it-together/README.md
# and DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2262 do
  use RFD.DSL

  rfd 2262, "make it with the pen and wear it together" do
    state :discussion

    flight_level :l3

    feature "Pen meshing in a shared world with graded annotations: a person
draws their character and outfit with the meshing pen, wears it and moves in
it where others see it, and gets a grade that teaches them to draw better"

    scope "interactor-dress-on, transport-meshing-pen, and the
V-Sekai client and server that host the loop"

    decision ~S"""
    The strategy is a release ladder: each release is a whole product put
    in front of real people to test one assumption, never a half-built
    release. One release advances at a time; later releases change with
    what the active one teaches. The loop is godot-sandbox guest ELFs a host
    loads, with no engine module of its own. The scoring it relies on
    runs the same shape: EditScore and MaskScore are decision models,
    godot-sandbox guests on ggml-rd and compute-rd, not a second
    runtime. OpenUSD is the internal format, VRM the one a player shares.
    """

    problem ~S"""
    An anonymous 16-person survey of the shared world's own community
    asked for two things: to create and share what others can see (8),
    and to be with people (8). One asked for emotes; none for rendered
    clips, hair motion or faces.
    """

    related ~S"""
    - RFD 2263 and RFD 2287, the active release's simulator gate and first rung.
    - RFD 2234 (dress-on pipeline), the loop the releases ride on.
    - RFD 1053 (OpenUSD as the internal format).
    - RFD 2229 (interchangeable parts), the rule new parts answer to.
    - RFD 2267 (persona NPCs in ported scenes), a parked content idea behind
      the releases, not one of them.
    """

    drafted_by :ai

    details_title "make it with the pen and wear it together"

    details "The releases", ~S"""
    Each release names what it tests, who tries it and where it stands.

    - **Demand test.** Do people want to make 3D things with a pen in VR,
      and what do they make? The public tried the published CASSIE sketch
      study (Yu et al., doi 10.1145/3411764.3445158). Done: people liked
      it, and wearables exist in what they drew (36 study shoes, a dress,
      two hats).
    - **First testable release.** Can a person draw an outfit, wear it,
      and show it to someone who talks with them? The simulator first, a
      replayed sketch (RFD 2263); then the first rung, two people in one
      zone with the garment made on a worker zone (RFD 2287). Active.
    - **Shareable release.** Will people save, share and wear what they made
      where others see it? The same creators and whoever they share with,
      phones included. Next: save as OpenUSD, export VRM, wear it and move
      in it in the world.
    - **First usable release.** Will creators use it for their own
      avatar? Early adopters from the survey. Later: their own body (ANNY
      fitted in a guest, or their own mesh), rigged, delivered as VRM.
    - **First lovable release.** Will people show it to friends?
      Anyone. Later: the character in parts (body, head, hair), and more
      emotes and dances.
    - **Full product.** Only if people ask for it. Later: faces and hair
      motion; nobody in the survey asked.

    Enabling work (CI, the drape's precision, comfort settings against
    motion sickness, the org's rules) is not a release; it runs as the
    active release needs it.
    """

    details "Where it runs", ~S"""
    The first host is `transport-meshing-pen`: the xr-grid pen with the
    dress-on ELFs inserted through godot-sandbox. It has two
    implementations, chosen per process through the OpenXR runtime
    manifest (`XR_RUNTIME_JSON`):

    - the simulator, OXRSys with a replayed hand, repeatable on a desk
      and in CI;
    - a standalone VR headset on a Linux-based OS, a person holding the
      pen.

    Later hosts are the shared world's client and a dedicated server
    running the same ELFs, for people on phones and anyone who would
    rather not wait; the server hands back the VRM.
    """

    details "Formats", ~S"""
    - OpenUSD is internal: Pixal3D's answer, the loop's meshes and
      materials, and a person's strokes (one linear `BasisCurves` prim
      per stroke, the boundary mark a per-curve primvar).
    - VRM is delivery: what a player loads and shares.
    """

    details "The grade that teaches", ~S"""
    The loop ends in a critique, not only a wearable. The score step returns a
    grade with annotations on the drawing, so a person reads where it marked
    them down and learns to draw better; the wearable and the lesson come from
    one pass.

    The grader is a decision model, EditScore retrained, and it runs inside the
    loop, so it is sized to the loop. A checkpoint that needs a workstation to
    answer is too large; the target is a compact retrain that answers in the
    sandbox, not the biggest model available.

    Measured 2026-09-27: stock EditScore (Qwen3-VL-8B with its LoRA) does
    not judge segmentation masks. On 23 social-VR frames it agreed with a
    MoGe-3 depth-edge check on 6. A readout of the score-slot logits, with
    no reasoning generated and the frame prefix shared, answers about 12x
    faster than generating the reasoning but ranks only 0.42 to 0.52
    (Spearman) against it. Both point to the compact retrain, not the
    stock model.
    """

    details "Shared means moving", ~S"""
    Shared means the person locomotes: they walk, turn and sit in the world
    wearing what they drew, and others see the outfit move with them. The
    shared world's client animates locomotion by sliding the avatar in its
    T-pose, and that is not acceptable: nothing bends, drapes or plants a
    foot, so a wearable seen there is seen standing still.

    Shared also means voice: people talk to each other while they move,
    over voice chat from the `modules/speech` module on entities-godot's
    `feat/module-speech` branch.

    The loop's locomotion is its own: a generated clip retargeted onto the
    avatar (interactor-dress-on gate 10), with the body grounded on the GPU
    as one rigid move per frame, so a foot stays where it lands and a seat
    holds a sitting body. Every contact is held to a penny (1.52 mm), within
    100 ms end to end and 1.0 ms of GPU time per frame on the standalone
    headset.
    """

    details "Moving in it: the mocap track, parked", ~S"""
    Wearing it and moving together needs body motion to drive the avatar.
    That track is Sinew, inertial motion capture from a worn suit. It sits
    behind the releases above, recorded here so it is not lost and not
    scheduled.

    - Shelved 2026-09-26: the mount-drift calibrator's training corpus
      shipped as `chibifire/mount-drift-caldata-motion` (558 rows of
      continuous microduck-gated clips, human and starforged phenotypes).
      Training the calibrator on it and measuring arm and hand mount
      recovery against a real-caldata baseline remains. Unpark when GPU
      budget and a held-out real capture are both in hand.
    - Shelved 2026-09-26: the IMU-recovery half, raw sensor to per-tracker
      orientation, stays unproven. Unpark with a clean low-IK recapture,
      the worn suit with motion smoothing and IK off, so the vendor pose
      approximates the raw tracker orientations for a direct match.
    - Shelved 2026-09-26: motion generation runs on the owned GPUs now
      (CUDA in WSL, both cards, via the bf16 op_repeat fix in the shared
      ggml). Unpark to scale the corpus with continuous motion-matching
      sequences when training needs more than the pilot.
    - Shelved 2026-09-26: fleet agents mint GitHub tokens from the bao
      GitHub secrets engine and land PRs through the merge queue. Unpark to
      make that the standing path when multi-agent coordination is the card
      in motion.
    """

    details "Faces: the track behind the full product, deferred", ~S"""
    Faces belong to the full product, which waits on people asking. The work toward
    them is recorded here so it is not lost and not scheduled.

    - Shelved 2026-09-27: avatar-person segmentation for faces. RF-DETR
      seg-nano runs on ggml-rd as a godot-sandbox guest
      (interactor-dress-on PR #22; gate 9 passes against a CPU flat
      control and a `GGML_RD_FAULT` negative control). A fine-tune loop
      exists (interactor-rf-detr-ggml PR #25), and a 300-image CC0 VRM
      pilot carries exact masks (datasource-anny-render-corpus PR #41).
      Unpark when a release needs avatar-person detection.
    """
  end
end
