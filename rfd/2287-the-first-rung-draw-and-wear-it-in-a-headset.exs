# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2287. `mix rfd.render` renders
# rfd/2287-the-first-rung-draw-and-wear-it-in-a-headset/README.md and DETAILS.md
# from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2287 do
  use RFD.DSL

  rfd 2287, "the first rung: draw it and wear it in a headset" do
    state :discussion

    flight_level :l1

    feature "A person in a headset draws an outfit with the pen and wears it,
while a second person in the same zone sees it and talks with them; a
worker zone makes the garment, and its ghost materializes in their zone"

    scope "entities-godot master built with precision=double, the godot-sandbox addon at
the same precision, transport-meshing-pen, and the zone, client, CA, asset, lasso, voice and
garment-stage guest ELFs. Using a standalone mode Steam Frame."

    decision ~S"""
    The first rung is two people in one zone, each with their own avatar:
    one in a headset, one on a desktop. They see each other and talk. The
    engine is base Godot built with double precision and the
    godot-sandbox addon, and it relays UDP and nothing else. Everything
    that computes is a C++ guest ELF on ggml-rd or compute-rd: the
    WebTransport stack (RFD 2256), the zones, the certificate authority,
    the voice codec and the dress-on loop. A worker zone owns the garment
    while it makes it; its ghost materializes in the players' zone, and
    then its ownership hands over to that zone. One zone owns it at every
    frame. The garment attaches rigidly to the avatar's bones.
    """

    problem ~S"""
    RFD 2262 asks whether people make and wear what they draw where
    others see it. Only people in the world answer that. The fabric
    already proves one owner per entity across zones; the rung carries
    that rule into a guest, so the engine stays base Godot.
    """

    related ~S"""
    - RFD 2262, the ladder this rung is on; RFD 2136, the rung precedent.
    - RFD 2263, step 2's regression test; RFD 2256, the transport.
    - RFD 2271, C++ guests with Lean tests; RFD 2288, their capabilities.
    """

    drafted_by :ai

    details_title "the first rung: draw it and wear it in a headset"

    details "How the guests are built and tested", ~S"""
    The zone, client, CA, asset, lasso and voice ELFs are C++, built from
    the fabric's, the lasso's and the codec's own sources against the
    namespaced engine shim in contract-guest-runtime that the curvenet guest already uses. Their
    tests are a Lean package beside them that links that C++ through a
    small FFI shim, as frame-eye-osc does; Lean is never in the running
    path. Every property the tests check is paired with a control that
    plants the defect and must be found.

    Every guest is built against the double-precision addon: a guest's
    `Variant` is 24 bytes at single precision and 40 at double, so a
    single-precision guest misreads every value the engine hands it.
    What is missing: the vendored sandbox-api in contract-guest-runtime, fabric-zone
    and voice does not pass `DOUBLE_PRECISION` to its own library, and
    its `node2d.cpp` and `vector.cpp` fail to compile at double;
    `fit.elf`, `usd.elf` and `mujoco.elf` are single precision.
    """

    details "The headset", ~S"""
    The headset is aarch64 SteamOS with SteamVR's OpenXR runtime, two
    2160 by 2160 panels at 108, 120 or 144 Hz, a recommended render
    target of 1728 by 1728 per eye, and 16 GB of memory shared with an
    Adreno 750. One Slang kernel measures 1.28 FP32 and 2.57 FP16
    TFLOPS on that GPU and 107 GFLOPS across its 8 CPU cores, about
    0.39 to 0.48 of the desk's M2 Pro on each. PyroWave encodes both eyes
    at 200 Mbit/s and 72 Hz in 12.4 ms through the CPU-buffer path,
    against 317 Mbit/s of measured Wi-Fi. `logbook/logbook-steam-frame-sizing.md`
    carries the apparatus and the numbers.
    """

    details "How the critical path is read", ~S"""
    The steps are `step` declarations rather than a numbered list, so the order,
    each step's repository, what it is missing and the check it ends at are data
    (RFD 2292, the organization as one RECTGTN domain). The table below is
    rendered from them, and the plan under it is what the planner returns.

    If the end of the rung's window arrives short, the steps land in this order
    and the rest wait: build, draw, wear, then transport and zone, then talk.
    """

    steps do
      step "Build",
        repos: ["entities-godot", "the godot-sandbox addon"],
        missing: ~S"""
        The Windows double editor build holds 72 fps in the headset; the
        exported `template_release` build faults in a `StringName` copy once
        the sandbox addon loads, and the Linux x86_64 build lacks XCursor and
        xkbcommon in the compatibility layer's root filesystem.
        """,
        check: ~S"""
        An OpenXR session starts on each path and the pen scene draws in it;
        transport-meshing-pen's headless gates pass on the double build. A path
        that fails is logged with its error, and the rung goes ahead on the
        other.
        """,
        state: :failed

      step "Draw",
        repos: ["transport-meshing-pen", "interactor-lasso"],
        missing: "Strokes become a curvenet through `curvenet.elf` in the pen's
sandbox, in the xr-grid scene, with the lasso from `lasso.elf` for picking far
targets.",
        check: "RFD 2263's replay still passes; the Lean tests link the lasso's
C++ and check it picks the target nearest the cone's axis.",
        control: "two targets' distances are swapped, and the pick must change"

      step "Wear",
        repos: ["transport-meshing-pen"],
        check: "A mirror shows the garment attached rigidly to the avatar's
bones, from a still of the headset's view."

      step "Transport and lock-down",
        repos: ["interactor-fabric-zone"],
        missing: ~S"""
        picoquic with h3zero, TLS 1.3 through picotls on mbedTLS, in the guest;
        the host relays UDP through `PacketPeerUDP` and never sees plaintext.
        `ca.elf` makes the session's root key in guest memory and issues
        one-hour certificates for zones and players, names limited to
        `*.zone.fabric.internal`.
        """,
        check: "Every end accepts only that root, and a VM transfer carries a
capability a ReBAC check mints (RFD 2288).",
        control: ~S"""
        a certificate from another CA is refused, an expired one is refused, an
        out-of-pattern name is not issued, and a transfer with no capability is
        refused while the same transfer goes ahead once its capability is minted
        """

      step "Zone",
        repos: ["interactor-fabric-zone"],
        missing: "`zone.elf`, all of `modules/multiplayer_fabric` as a guest
(entity pools, STAGING, ghosts, the SQLite journal and the predictive BVH),
hosting the headset and desktop clients with a humanoid pose payload.",
        check: "Each client sees the other's pose, and the Lean tests search for
a frame with two owners or none.",
        control: "a double hand-off is planted and must be found"

      step "Worker zone",
        repos: ["interactor-fabric-zone"],
        missing: "A second `zone.elf` takes a stroke set, runs `curvenet.elf`
with its kernels on compute-rd, and stores the garment with `asset.elf`
(casync); the garment's ghost carries its hash and ownership hands over.",
        check: "Exactly one zone owns the garment at every frame, and a fetched
garment's chunks match its index.",
        control: "one chunk is corrupted and must be caught"

      step "Talk",
        repos: ["interactor-voice"],
        missing: "`voice.elf`, the Opus codec as a guest, sends its packets as
WebTransport datagrams, played at the speaker's avatar.",
        check: "Speech round-trips between the two clients, and the Lean tests
check a decoded frame against its input.",
        control: "a packet is dropped and the decode must degrade rather than
desynchronise"

      step "Evidence",
        repos: ["transport-meshing-pen"],
        check: "One session, the person in the headset and the operator on the
desktop, recorded as CineForm and WebM, with the zone logs."
    end

    details "The interface", ~S"""
    The interface derives from xr-grid and CASSIE: the pen draws in a
    world-locked grid, and CASSIE's strokes, boundary marks and
    curvenet are what the person sees form. Selection far away is the
    lasso: a pointing cone that snaps to the nearest target, its math
    (`LassoDB`, `LassoPoint`) moved from the engine module into
    `lasso.elf`. Near things are touched directly. What a person makes
    is stored by content hash with casync (`.caibx` chunk indexes, the
    fabric asset code moved into `asset.elf`), so the other client
    fetches the garment by its hash, and the ghost carries only the
    hash.

    It keeps to common OpenXR practice:

    - Input binds to actions in the action map, never to raw buttons,
      with a profile for each controller and for hand tracking.
    - The reference space is local-floor. Interface panels are
      world-locked, 1 to 3 m away, never locked to the head, and their
      text is at least 1 degree tall.
    - The frame rate holds the headset's refresh rate. Any artificial
      movement is snap turn and teleport, with no smooth acceleration.
    - A haptic pulse confirms each stroke closed, lasso target taken
      and garment worn.
    - The mirror is a world-locked object the person walks up to, not a
      window on their view.
    """

    details "The avatars", ~S"""
    Both avatars are free original models under the Apache-2.0 licence,
    each in its own repository with its licence file and its Unity
    humanoid bone map (53 roles): `chibifire-stages/character-mille-mire-feuille`
    for the headset player and `chibifire-stages/character-marocchino`
    for the desktop player.
    """

    details "What the rung leaves out", ~S"""
    | Left out | Why | The rung that takes it |
    | --- | --- | --- |
    | Fit and drape | the fit takes about 10 minutes | the next rung, on the worker zone |
    | Moving through the world | needs the retargeted, grounded clips | the next rung |
    | The shared Bao signing the CA | needs one signing grant (RFD 2142) | the next rung |
    | VRM export | delivery, not the rung's question | the shareable release |
    """
  end
end
