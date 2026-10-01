# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2294. `mix rfd.render` renders
# rfd/2294-agent-knowledge-lives-in-rfds-not-in-desk-memory/README.md and DETAILS.md from
# this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2294 do
  use RFD.DSL

  rfd 2294, "agent knowledge lives in RFDs, not in desk memory" do
    state :discussion

    flight_level :l2

    feature "where an agent session keeps what it learns about V-Sekai-fire and
chibifire-stages, and the operator's rules that lived in one desk's memory, written down"

    scope "`manuals-weftspun`, `CLAUDE.md`, every agent session's local memory, and the
rules below"

    decision ~S"""
    What any agent needs to know about V-Sekai-fire and chibifire-stages, their
    repositories, the headset and the services lives in an RFD in this repository:
    the RFD that owns the topic, or this one when none does. A desk's local memory
    keeps only what is true of that desk alone, such as its paths, its identities
    and its tools; a local note about a generic rule names the RFD that states it.
    An agent that learns a generic rule writes it into the RFD in the same session,
    through a pull request like any other change.
    """

    problem ~S"""
    An agent session's memory is a directory on one desk. On 2026-10-01 the
    operator's rules for locomotion, offline deployment, video and the station
    lived only on the Mac desk, and those for where compute runs and for binary
    translation only on the Windows desks, so no session saw all of them, and a
    rule changed on one desk disagreed with the others without anyone being told.
    """

    related ~S"""
    - RFD 2287, the first rung, whose interface moves a person by the world grab
      described under Locomotion.
    - RFD 2293, the Skateboard's workspace, which builds the translated libraries.
    - RFD 2265, compute-rd kernels with a CPU oracle; RFD 2230's native ggml
      module is off the route.
    - RFD 2283, verification by recording, which the contact sheets deliver.
    - RFD 2200, the desk agent's ReBAC rows.
    """

    drafted_by :ai

    details_title "agent knowledge lives in RFDs, not in desk memory"

    details "The work queue", ~S"""
    The agent sessions share one work-stealing queue, the issues labelled
    `worksteal` on `contract-zone-backend`; its protocol is pinned there as #58. An
    agent works its own queue newest first, and with nothing unclaimed steals the
    oldest unclaimed, unpinned issue from the fullest queue. A pinned issue needs one
    desk's hardware or credentials and is never stolen. The queue applies
    backpressure: a queue holding three or more open issues, pinned ones included,
    is full, its agent files nothing new and finishes first, a follow-up found
    mid-task becomes a checklist line in the issue that found it, and an operator
    request is still filed, with the queue's depth reported back so the operator can
    say what waits.
    """

    details "How a desk works", ~S"""
    An agent works from the placed tree, and branches where a pin is old. A
    procedure a desk repeats becomes an Elixir DSL or a tool in the tree rather than
    one-off shell. No workflow or background subagent runs unless the operator asks
    for one. Test marks go only in test scenes, never in a scene that ships. A
    large area is parked one top-level entry at a time, each pushed or moved into
    the tree and then removed until the area is empty, with no census of every file
    first, so the area visibly shrinks.

    All GitHub activity stays in V-Sekai-fire and chibifire-stages: forks, new
    repositories and pushes, and no pull request, issue, comment or mention in any
    other organisation, though reading and cloning public repositories is fine.
    Pushed text cites an upstream change by its bare commit SHA, never by an
    `owner/repo#N` reference or an issue or pull request URL, since GitHub posts
    those back onto the upstream's timeline.
    Our line of an upstream branch is `feat/<branch>` on the V-Sekai-fire fork,
    created at the upstream commit, so the upstream's branch-keyed workflows do not
    fire on it. A branch named `main/<x>` cannot sit beside one named `main`, since
    git stores each ref as a path.
    """

    details "Locomotion", ~S"""
    In the headset a person moves two ways, and both work. One is xr-grid's world
    grab: both grips pinch the world, and moving, turning or spreading the hands
    carries, turns or scales it about the hands' midpoint
    (`addons/procedural_3d_grid/core/xr_pinch.gd` on a canvas beside the hands, as
    `transport-meshing-pen` wires it). One grip moves nothing. The other is the
    controllers: smooth stick movement, snap turning and teleport. A character
    moved with a gamepad uses `interactor-motion-guest`: the motion models on
    ggml-rd with compute-rd in a godot-sandbox guest, retargeted onto the avatar,
    with the stick setting movement and facing. No hand-written character
    controller is added.
    """

    details "Deploying offline", ~S"""
    The whole stack deploys offline on one laptop, reachable on the LAN and perhaps
    the tailnet, with nothing needed from the WAN:

    - every build source is in the manifest and mirrored on the laptop, and release
      binaries are mirrored with their sha256s;
    - each runtime (FoundationDB, Uro, OpenBao, the zone servers, the object store)
      runs on the laptop, with only its own data;
    - names come from the laptop's own resolver or the tailnet, and certificates
      from the offline CA;
    - sign-in has a LAN-only method beside the third-party providers.

    Bubblewrap is the test: the stack runs with its network unshared, so a fetch
    that reaches past the laptop fails by name. Uro runs next to its FoundationDB
    cluster, so a page read never leaves one machine.
    """

    details "Video", ~S"""
    Every video ships as CineForm with FLAC in Matroska, with its `.cff`, and no
    WebM is made: videos are uploaded by hand, and a WebM does not play on every
    desk. It is recorded as `.cfhd` through `entities-godot-cineform` at double
    precision and delivered by `interactor-av1mkv`'s `deliver.exs`, which writes
    only those two files; no master is MJPEG. Nothing records
    through the encoder BLOCKLIST.md bars or through the desktop driver's own
    recorder: recordings are CineForm, the live stream is PyroWave, and the headset
    view comes from the compositor mirror.

    Marketing media and samples are marked with `https://github.com/v-sekai-fire`:
    it is the `url` in each `.cff`, the web statement in its XMP and the line on
    its exit card, and each follows the four-beat script below.

    A short runs exactly 40 seconds and is scripted before recording in four beats:
    hook, intrigue, delivery and exit (HIDE).
    The hook fills the first 3 s as on-screen text that works with the sound off and
    promises without answering. One line of intrigue makes the viewer feel the
    problem. The delivery is the one thing they came for. The exit gives them
    something to do. It is never about us. The length is 40 times the frame rate in
    Movie Maker frames, counted from the first rendered frame; the engine renders
    the captions, and no external tool re-encodes the file.
    """

    details "Visual comparisons", ~S"""
    A visual comparison is delivered as a labelled contact sheet, the format for
    both vision-model review and human QA: one row per case, one column per source
    (original, before, after, diff), each cell labelled with its metric, failures
    first, and the numbers kept beside the sheet. `entities-sakuragaoka-station`'s
    `tools/prop_shots.gd` is the precedent (RFD 2283). A copy goes to
    `lookdev-contact-sheets/` on the Desktop of the desk that made it, as
    `<topic>-NN.png`, the number rising so that no sheet is overwritten.

    A residual is fixed, never smudged: nothing blurs an image before the diff,
    loosens a threshold or masks a region. Fixes go down a ladder, each rung measured
    with the diff's own metric before and after: exact fixes at the source, then
    missing structure, then registration, where a camera that does not match is fixed
    in the camera and never by warping an image, then parameters fitted to the oracle
    with `contract-lbfgsb` on the GPU, coarse to fine, written back into the source
    assets and checked on views the fit did not use. What remains is reported beside
    its floor, and a later change may not raise it. Antialiasing and distance fades
    that belong to the renderer stay.
    """

    details "The station in Godot", ~S"""
    The Sakuragaoka Station port (`entities-sakuragaoka-station`):

    - realizes every closed solid through CSG, and carries each face's colour as a
      palette index in UV, since CSG keeps UV and drops vertex colour; CSG takes
      only manifold solids, so a geometry that fails the manifold check stays a
      plain surface, or goes through `remesh.elf` when it must be unioned;
    - shades with godot-vrm's MToon unchanged, and a variant includes it rather than
      forking it;
    - renders completely from meshes baked from the vector materials' data (signs,
      paving, bark, blossom cards), coarsened by LOD when over budget, so everything
      works with the runtime vector shader off;
    - runs `slughorn`'s per-pixel vector shader as a quality setting, on by default,
      adding detail to surfaces near the eye within the headset's GPU budget;
    - synthesizes finer detail only where the source is procedural;
    - judges alpha on the final composite of its layers: an opaque object ends with
      no transparency, and a transparent base-colour material writes alpha.

    No rasterized vector art or glyph outline goes into the headset. Meshes made
    from outlines are fine, and a glyph mesh goes through `remesh.elf` when its
    font's winding is invalid. Parity with the three.js original is measured at
    sphere-Hammersley views against `tools/oracle/shot.mjs` renders.
    """

    details "Where compute runs", ~S"""
    Heavy compute runs in a godot-sandbox guest: a riscv64 guest ELF on the CPU,
    which is also the parity oracle, or kernels on ggml-rd with compute-rd, authored
    in Lean and lowered through Slang to SPIR-V (RFD 2265). It never runs as a host
    Python or C++ pipeline or as a GDScript loop. Fragment shaders that render are
    fine, and Python bindings serve upstream contributions and their tests, never a
    pipeline. ggml runs only in such a guest: a native ggml module as RFD 2230 drew
    it, a GDExtension ggml API or a standalone runtime is off the route, and a
    standalone CLI may stay as a CPU oracle for a gate. Diffusion in ggml runs on
    ggml-rd with compute-rd as well, since EditScore's decision model builds on it
    (RFD 2268).

    A guest's source lives in the repository that consumes it and follows
    curvenet's split: `main.cpp` marshals and sees only `api.hpp`, and `*_api.cpp`
    sees the library. Mesh arrays cross in the layout of `contract-guest-common`'s
    `mesh_wire.h`. A vmcall takes at most seven arguments, an eighth failing with a
    register overflow, and each call returns inside the sandbox's
    `execution_timeout`.
    """

    details "Binary translation and the Windows build", ~S"""
    Everything that runs in godot-sandbox is binary-translated, guest ELFs and
    SafeGDScript alike, and an interpreted timing is never the one reported. No
    `.gd` ships: every script, third-party ones included, ships compiled as `.sgd`
    with its translation, and a script that does not compile is a counted FAIL, not
    a fallback.

    The game ships as a Windows build, run natively and through the headset's
    compatibility layer, so a translation is a precompiled Windows library linked
    against the universal C runtime that loads under that layer, never code
    generated at run time into writable executable memory. A Linux `.so` serves the
    Linux zone servers and never reaches the headset. The compatibility layer runs
    that same Windows build, so the Windows desk is where it is tested. RFD 2293
    builds the libraries.
    """

    details "The headset", ~S"""
    Tests and gates run on the Windows desk or as renders on the Mac, not in the
    headset the operator wears. A run, a runtime restart or a capture in the headset
    happens only when the operator asks for that run, and nothing captures the
    headset view while the operator is in a social session. The headset view comes
    from the compositor mirror (`/dev/video99`) with screen sharing on; X11 capture
    cannot see it.

    Asleep, the headset drops off the LAN entirely, answering neither mDNS nor
    ARP, so a name that does not resolve means it is asleep, not broken.

    The headset is the Mac desk's in the queue, so another desk coordinates with
    the Mac before touching it. A key appended to its `authorized_keys` starts on a
    new line with carriage returns stripped, because the file may end without a
    newline and a `.pub` written on Windows ends its lines with CRLF.
    """

    details "Merging", ~S"""
    An agent merges its own pull requests on V-Sekai-fire once they are green,
    through the merge queue where the repository has one, and never with an admin
    bypass. Where a repository requires no checks, `--auto` merges at once with its
    checks red, so there the agent waits for green and merges by hand. Repository
    admins may bypass a ruleset for a pull request; agents do not.
    """

    details "Where interactor-dress-on went", ~S"""
    `interactor-dress-on` is archived. Its stages live in their own repositories
    (`contract-guest-runtime`, `contract-guest-common`, `contract-ggml-rd`,
    `contract-lbfgsb`, `contract-anny-kernels`, `contract-sinew-align`, and
    `interactor-drape`, `-curvenet`, `-garment-fit`, `-cage`, `-headfit`, `-lasso`,
    `-motion-guest`, `-rfdetr-seg-guest`, `-usd-guest`, `-av1mkv`), and
    `transport-meshing-pen` builds the guest ELFs from those sibling checkouts.
    """

    details "Bao and the tokens it mints", ~S"""
    Bao runs as tailnet nodes named `weftspun-bao-N`, and a desk uses whichever is
    online, keeping `weftspun-bao.internal` as the TLS server name. A desk logs in
    with its certificate, passing no role `name`, so the certificate selects the
    role. The login token lives for
    the session: it is reused until its TTL lapses and revoked only when the
    operator asks or the session ends, never at the end of each task.

    A GitHub token is minted from `github/token`, never printed, and handed to git
    through a credential helper that reads it from the environment. When its task
    ends it is revoked with `DELETE /installation/token`, which answers 204 and
    leaves the token answering 401, and only then is its copy deleted. On a
    Windows desk, Git Bash rewrites an argument that starts with `/` into a Windows
    path, so the revoke goes through curl or names the path without its leading
    slash.

    Agents may use Bao to pass data to each other. What is written there is stored
    in S3 for 30 days and then rolled over (operator, 2026-10-01): Bao's storage is
    FoundationDB, whose backup goes to R2 (RFD 2143). An entry deleted from Bao
    stays in that copy until it rolls over.
    """
  end
end
