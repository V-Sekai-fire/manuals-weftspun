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
    - RFD 2262, the ladder; RFD 2136, the precedent; RFD 2263, step 2's test.
    - RFD 2256, the transport; RFD 2271, guests with Lean tests; RFD 2288, capabilities.
    - Abandons RFDs 2211, 2001 and 2075: the engine is base Godot; zones are `zone.elf`.
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

    details "The critical path", ~S"""
    Each step starts when the one before it runs. Each names its
    repository, what is missing, and its check.

    1. **Build.** Base Godot `master` with `precision=double` for x86_64
       Linux and Windows, and the godot-sandbox addon rebuilt at double
       precision. The headset runs the Windows build through its
       compatibility layer; a desktop OpenXR runtime also streams to it,
       and that stream is PyroWave, an intra-only wavelet codec in
       Vulkan compute whose exact rate control holds a frame to its byte
       budget. CineForm stays the recording codec. The Windows double
       editor build holds 72 fps in the headset; the exported
       `template_release` build faults in a `StringName` copy once the
       sandbox addon loads, and the Linux x86_64 build lacks XCursor and
       xkbcommon in the compatibility layer's root filesystem.
       Check: an OpenXR session starts on each path and the pen scene
       draws in it; transport-meshing-pen's headless gates pass on the double build.
       A path that fails is logged with its error, and the rung goes
       ahead on the other. (`entities-godot`, the godot-sandbox addon)
    2. **Draw.** Strokes become a curvenet in the headset through
       `curvenet.elf` in the pen's sandbox, in the xr-grid scene, with
       the lasso from `lasso.elf` for picking far targets. Check: RFD
       2263's replay still passes; the Lean tests link the lasso's C++
       and check it picks the target nearest the cone's axis, with a
       control that swaps two targets' distances.
       (`transport-meshing-pen`, `interactor-lasso`)
    3. **Wear.** The garment attaches rigidly to the avatar's bones; a
       mirror shows it. Check: a still from the headset's view.
       (`transport-meshing-pen`)
    4. **Transport and lock-down.** picoquic with h3zero, TLS 1.3 through
       picotls on mbedTLS, in the guest; the host relays UDP through
       `PacketPeerUDP` and never sees plaintext. Connections are direct.
       `ca.elf` makes the session's root key in guest memory and issues
       one-hour certificates for zones and players, names limited to
       `*.zone.fabric.internal`; every end accepts only that root. A
       guest's VM carries its memory, so every VM transfer (serializing
       it, snapshotting it, moving it to another zone, or a host read of
       its memory) needs a capability: a macaroon that a ReBAC check
       mints (RFD 2288). `ca.elf` gets no transfer capability. Check,
       each with its control: a certificate from another CA is refused,
       an expired one is refused, an out-of-pattern name is not issued,
       and a transfer with no capability is refused while the same
       transfer goes ahead once its capability is minted.
       (`interactor-fabric-zone`)
    5. **Zone.** `zone.elf`, all of `modules/multiplayer_fabric` as a
       guest (entity pools, STAGING, ghosts, the SQLite journal and the
       predictive BVH), hosting the headset and desktop clients with a
       humanoid pose payload for both avatars. Check: each client sees
       the other's pose; the Lean tests search for a frame with two
       owners or none, with a control that plants a double hand-off.
       (`interactor-fabric-zone`)
    6. **Worker zone.** A second `zone.elf` takes a stroke set and runs
       `curvenet.elf`, its kernels on compute-rd, and stores the garment
       with `asset.elf` (casync); the garment's ghost, carrying its hash,
       materializes in the players' zone, each client fetches it by the
       hash, then its ownership hands over. Check: exactly one zone owns
       the garment at every frame; a fetched garment's chunks match its
       index, with a control that corrupts one chunk and must be caught.
    7. **Talk.** `voice.elf`, the Opus codec as a guest, sends its packets
       as WebTransport datagrams, played at the speaker's avatar. Check:
       speech round-trips between the two clients; the Lean tests check
       a decoded frame against its input, with a dropped-packet control.
       (`interactor-voice`)
    8. **Evidence.** One session, the person in the headset and the
       operator on the desktop, recorded as CineForm, with the zone
       logs.

    If the end of the rung's window arrives short, the steps land in this
    order and the rest wait: build, draw, wear, then transport and zone,
    then talk.
    """

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
    - The frame rate holds the headset's refresh rate. A person moves by
      xr-grid's world grab, both grips pinching the world, with no smooth
      acceleration (RFD 2294).
    - A haptic pulse confirms each stroke closed, lasso target taken
      and garment worn.
    - The mirror is a world-locked object the person walks up to, not a
      window on their view.
    """

    details "The setting", ~S"""
    The two players stand in a train-station plaza, a port of the
    MIT-licensed procedural three.js scene `sakuragaoka-station`, placed
    at `3-interactor/sakuragaoka-station-upstream` (`4112f57`). Its
    43,727 lines of JavaScript under `src/` generate every texture in
    code and keep no mesh on disk, so the port rebuilds the scene in the
    engine with MToon materials rather than importing it. The port lives
    in `entities-sakuragaoka-station`, and the pen vendors it with
    `tools/vendor_station.sh <commit>`, which takes only a commit some
    remote branch contains.
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
