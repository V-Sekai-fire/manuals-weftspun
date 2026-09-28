# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2277. `mix rfd.render` renders this file's README.md and DETAILS.md under
# rfd/2277-curvenet-cage-refit-and-unified-expressions-in-modular-avatar/; the
# Markdown is a build artifact (RFD 2232).
defmodule RFD2277 do
  use RFD.DSL

  rfd 2277, "curvenet-cage refit and unified expressions in Modular Avatar" do
    state :prediscussion

    flight_level :l2

    feature "a Modular Avatar build gives Miroir-Re unified expressions from
ANNY and a dress refitted by a curvenet cage so it does not clip in motion"

    scope "dress-on's `cage.elf` and `motion.elf`; the Unity sandbox; two NDMF
components; Miroir-Re's dress and face"

    decision ~S"""
    Ship it as a Skateboard: one NDMF build of Miroir-Re whose dress
    clears the body in every frame of our own motion, and whose face
    carries every unified-expression name transferred from ANNY. A CASSIE
    curvenet becomes a closed cage, bound by (1,3) biharmonic coordinates
    and solved over the motion's frames with dress-on's L-BFGS-B in
    float32/df32. Every kernel comes from Lean. The guests reach the engine
    only through the sandbox API. C# holds no logic, and no Python.
    """

    problem ~S"""
    The dress, made for another avatar and moved by rigid bone offsets,
    sinks up to 14.3 mm into the neck base, and pushing vertices out
    failed at 1,732% edge strain. The face has 448 artist shapes and none
    moves the jaw, lips, cheeks or tongue for tracking.
    """

    references [
      "Thiery, Michel, Chen. Biharmonic Coordinates for Triangular 3D Cages. SIGGRAPH 2024",
      "V-Sekai-fire/interactor-tool-godot-cage-deformer; fireflyk64/udon2godot"
    ]

    related "RFD 2275 (unified expressions from ANNY, the method); RFD 2279
(one deform surface over curvenets; this RFD owns bhc13); RFD 2262 (the
vehicles); RFD 2278 (remeshed cages, parked); RFD 2239 (no Python)."

    drafted_by :ai

    details_title "curvenet-cage refit and unified expressions in Modular Avatar"

    details "Skateboard to car", ~S"""
    - **Skateboard** (earliest testable). Does one Modular Avatar build on
      the desk give Miroir-Re a dress that clears the body and a face with
      the whole unified-expression set?
      - A scripted pen draws the neckline and strap curves (a printed
        stand-in for a person). `curvenet.elf` builds the patches, and
        `cage.elf` caps and coarsens them into a closed cage.
      - `bhc13` binds the five dress renderers. L-BFGS-B clears them by
        2 mm in every sampled frame of our own motion.
      - The motion comes from Kimodo-SOMA-RP-v1.1 (text to motion on
        SOMA-77) and MotionBricks-G1, both run as guests on ggml-rd.
      - `hf_*` fits ANNY's head to the face and transfers its 52 actions
        under unified-expression names, through `unified_expressions.map`.
      - Everything runs on the CPU path, through the Unity sandbox, in one
        NDMF build, and is checked in the Editor.
    - **Scooter.** Does it hold up when worn and seen? Uploaded to VRChat,
      with VRCFT driving the expressions live, and the tongue and corrective
      shapes from RFD 2275/2279.
    - **Bicycle** (earliest usable). Does it work on the next garment and
      avatar? The cardigan's 22.5 mm at the upper arm and the drawers'
      31.6 mm at the thigh, then another purchased avatar.
    - **Motorcycle** (earliest lovable). A person draws the curvenet in VR
      with the pen, and the Unity sandbox's RD path makes the fit
      interactive in Unity too.
    - **Car.** Remeshed cages (RFD 2278), only if people ask.
    """

    details "How it was drafted", ~S"""
    Drafted 2026-09-28 from a measured diagnosis of the dress clipping, a
    survey of the cage deformer, CASSIE, dress-on and godot-sandbox's host
    ABI, and a libriscv-on-Windows survey. The operator made these calls
    the same day:

    - an NDMF build-time pass;
    - a real libriscv sandbox;
    - udon2godot mirrored in reverse;
    - rule 2 kept strictly;
    - float32/df32;
    - no C# port;
    - no Unity access except through the sandbox API;
    - `.sigs` for the host;
    - no Python;
    - the curvenet builds the cage;
    - the full ANNY transfer in the Skateboard;
    - refit means not clipping in motion;
    - motion from our own Kimodo and MotionBricks models, in the sandbox on
      ggml-rd (the VRChat SDK's clips are blocklisted).

    Renumbered from 2276 after a collision, split with RFD 2279, and
    replanned as vehicles.
    """

    details "The diagnosis", ~S"""
    The measurements were baked, welded, and taken as signed distance to the
    body, with nearest triangles checked clear of the body's 220 boundary
    edges.

    | Garment | Inside | Deepest |
    | --- | --- | --- |
    | Dress_shoulder | 28 of 214 | 7.0 mm |
    | Dress_shoulder_frill | 114 | 11.6 mm |
    | Dress_Ribbon | 100 | 10.0 mm |
    | Dress | 33 | 11.9 mm |
    | Dress_frill | 149 | 14.3 mm |

    The StrapClipping witness DAG (plausible-witness-dag) proves by `decide`:

    - **Refuted:** Adjust_WAKI, Breast_Small and Hide_Chest2 as causes, and
      skin weights as the cause.
    - **Supported:** the dress was modelled for another avatar (a bind
      offset of at least 57 mm, a fit offset of at most 0.2 mm).
    - **requiresManualReview:** a body shrink with Hide_Chest1. The frill
      stays 6 mm deep, and 61 bare-skin vertices would sink.
    """

    details "The guest", ~S"""
    The guest is `guest/cage/` (dress-on rule 6). The bind, deform and
    Jacobian are the `bhc13` method of RFD 2279's shared surface, in
    `guest/common/deform/bhc13/`.

    - **Curvenet to cage:**
      - The pen's curves go to `curvenet.elf`, which builds its patches.
      - `cage.elf` caps the open patch boundaries and coarsens them to about
        100 vertices, then passes the result to RFD 2279's `net_from_mesh`.
      - `bind(net, mesh, "bhc13")` refuses unless the cycles form a closed,
        consistently oriented surface. It must also contain every bound
        vertex, and cage vertices away from the region are frozen.
    - **Garment, in bind space:** `y = Φ(c0 + u) + Ψ n(c0 + u)`, where `u` is
      the cage displacement.
    - **Motion:** `motion.elf` runs Kimodo-SOMA-RP-v1.1 and MotionBricks-G1
      on ggml-rd from text prompts (walk, idle, reach, sit, dance).
      - The retarget is the pose-envelope rule of commit 13f3c4bf: joint
        flexion carried about the avatar's own measured axes.
      - A clip-range report says which joint ranges each clip actually
        visits.
      - The Skateboard samples 64 frames. Each frame gives bone matrices
        `M_p`.
    - **In-motion loss:**
      `Σ_p w_p Σ_i max(0, m − d_p(LBS_p(y_i)))² + w_L ‖Lu‖² + w_r ‖u‖²`,
      with m = 2 mm.
      - `d_p` is fit.elf's brick-grid SDF, with the Lean tricubic sampler,
        of the body skinned to frame p.
      - The cage lives in bind space, so the result bakes directly into the
        mesh and needs no unskin step.
    - **Head fit (RFD 2275's method):**
      - It fits rigid + scale + 6 phenotype axes + local head changes to
        the face `Body`.
      - The loss is point-to-surface distance plus landmarks, with the
        eyes masked and the nose down-weighted.
      - The same L-BFGS-B solves it.
      - The transfer is barycentric resampling along the target normal.
      - ANNY's CC0 data is uploaded by the host.
    - **Gradients:** each frame's gradient is carried back through the
      linear part of `LBS_p`. Then `Φᵀg`, plus the normal pull-back
      `(I − nnᵀ) g_n / |N|` onto each triangle's vertices, plus `2 w_L LᵀLu`.
    - **Kernels, all from Lean** (`lean/Cage/`, `kernels/cage/`) through
      Slang to `cpp` and `spirv`:
      - the bind with its dense LU;
      - the two products;
      - LBS and its transpose;
      - the cage normals and their VJP;
      - the Laplacian;
      - the head-fit residuals.
      Embedding and kernel tables are generated without Python.
    - **Solver:** reverse communication, one L-BFGS-B step per host tick
      (rule 4).
    - **Entries:** `cage_build`, `cage_preview` and `cage_dump` for the dress;
      `hf_*` for the face. They reach the engine only through the
      Godot-shaped API, so the same code drives Godot and Unity.
    """

    details "Interop", ~S"""
    Three `.sigs` files, each drift-gated by an Elixir mix task. None is
    registered until RFD 2279 lands.

    - `unity_sandbox.sigs` (this RFD): the host C ABI. Machine create and
      destroy, the instruction limit, the bridge table, `has_function`,
      `vmcall` and the last error.
    - `cage_guest.sigs` (this RFD): the cage fit entries, `cage_build`,
      `cage_preview`, `cage_dump`, and `hf_*`.
    - `deform_guest.sigs` (RFD 2279): `net_from_mesh`, `net_from_strokes`,
      `net_from_skeleton`, `bind`, `weights`, `deform`, `jacobian` and the
      rest.

    Handles are guest ints, with one destroy. The guest has no filesystem.
    """

    details "The Unity sandbox", ~S"""
    `unity_sandbox.dll` wraps libriscv's C API, with the fireflyk64 patches
    applied. It is built with pixi, CMake and llvm-mingw `-static`, like
    `Tools/hullmerge`. It keeps godot-sandbox's `GuestVariant` layout, its
    scoped and permanent slots, and its unboxed vmcall byte for byte.

    The CPU path needs these ECALLs:

    | ECALL | Purpose |
    | --- | --- |
    | 511 | throw |
    | 517 | vcreate |
    | 518 | vclone |
    | 519 | vfetch |
    | 526 | string ops |
    | 533, 534 | math (the libm overrides) |
    | 547 | sandbox_add |
    | 480-491 | native heap and memory |

    The object ECALLs (504, 506, 532) forward to a C# bridge. The bridge
    resolves every Godot name through a declarative catalog to a Unity
    member, and anything unmapped traps with its Godot name. Coordinate
    mirroring (x negated, Basis conjugated, triangle winding flipped) is a
    property of the Variant types in that catalog.

    Guards:
    - Machines are torn down on `beforeAssemblyReload`.
    - Every vmcall has an instruction limit.
    - The plugin is Editor-only.

    The Skateboard generates motion in `motion.elf` under Godot's sandbox,
    where ggml-rd already runs, and stores the clips as OpenUSD `.usda`,
    which `cage.elf` reads in either engine. The Unity sandbox's RD path
    (22 RenderingDevice methods, Slang built with `-target hlsl`) is the
    Motorcycle's.
    """

    details "The components", ~S"""
    Both components are `MonoBehaviour`s implementing `INDMFEditorOnly` and
    `IEditorOnly`. They hold settings and the `cage.elf` bytes, and nothing
    else.

    - **`CageDeformer`**, on each dress renderer: the curvenet asset, the
      body renderers, the margin, the loss weights and the frozen region.
    - **`UnifiedExpressions`**, on the face `Body`: the landmark pairs, the
      region, and the ANNY data asset.

    The pass runs in the Transforming phase, before Modular Avatar. Each
    component makes one vmcall; the guest then does everything:
    - bakes and reads the meshes, bones, bindposes and the motion clips;
    - fits in bind space over the clips' frames;
    - writes the refitted mesh or the new blend shapes;
    - saves through `AssetSaver`;
    - registers the replacement;
    - writes the report and `evidence.json`.

    Scene assets are never written. The preview is an `IRenderFilter`, and
    the dump's hash must equal the build's.
    """

    details "Phases and status", ~S"""
    - **A.** `cage.elf`, `bhc13` and the Lean kernels, on dress-on
      `feat/cage-elf`. Stopped with partial work; G1 (the Lean bind against
      the oracle) is the critical path. Then the in-motion fit, curvenet to
      cage, and `hf_*`.
    - **A2.** `motion.elf`, the Kimodo SOMA and MotionBricks G1 graphs on
      ggml-rd, with clips written to OpenUSD.
    - **B.** The Unity sandbox. Stopped with partial work; validated on
      `drape.elf`, then on `cage.elf`.
    - **C.** The two components and the NDMF pass. Waits on A and B.
    - **D.** The Skateboard build of Miroir-Re. Waits on C.

    Nothing is committed or pushed until the operator asks.
    """

    details "The Skateboard's gates", ~S"""
    Each passes before the next is built on.

    - **A, the guest in Godot:**
      - Lean weights against a native `BHC.h` oracle;
      - a zero fit returns the mesh;
      - the fit against a native LBFGSpp oracle;
      - a corrupted weight and a push-vertex control must fail;
      - the curvenet cage is closed, has positive volume and contains every
        bound vertex;
      - the head fit's residual in mm is reported per region;
      - `motion.elf` matches the native kimodo-ggml and motion-bricks.cpp
        output on the same prompt and seed, and the clip-range report is
        written;
      - `gate_cage.gd` in stock Godot.
    - **B, the Unity host:**
      - `drape.elf`, then `cage.elf`, match the Godot run bit for bit,
        mirror applied;
      - an unmapped call traps with its name;
      - a runaway guest trips the instruction limit;
      - a domain reload survives a live machine.
    - **C, the components:**
      - the build hash equals the dump hash;
      - the scene assets are unchanged;
      - the C# computes nothing.
    - **D, the avatar, in one NDMF build:**
      - all five dress renderers have 0 vertices inside body + margin in
        every frame of every clip. That includes held-out frames not used in
        the fit, reported separately;
      - no new body exposure;
      - edge strain at most 10%;
      - the face carries every name in `unified_expressions.map`, with 0
        unmapped and 0 absent, and every transferred shape's error reported;
      - screenshots of the neck and of JawOpen, EyeClosed and a lip shape;
      - the build's `evidence.json` proves `verdict fix_F1 = .justified`
        by `decide` in StrapClipping, or the build fails.

    Stand-ins, printed in the results:
    - a scripted pen instead of a person;
    - 64 sampled frames instead of the whole clip;
    - motion generated under Godot's sandbox and read back as USD;
    - the Editor, not an upload.
    """
  end
end
