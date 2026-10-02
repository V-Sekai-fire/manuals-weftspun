# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2293. `mix rfd.render` renders
# rfd/2293-the-skateboards-workspace-and-the-first-rungs-plan/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2293 do
  use RFD.DSL

  rfd 2293, "the Skateboard's workspace, and the first rung's plan" do
    state :discussion

    flight_level :l1

    feature "RFD 2287's first rung, from a hand-built headset run to a session on the Frame"

    scope "a new skateboard manifest, the pen, the double build, and the rung's guests"

    decision ~S"""
    A new manifest, `contract-manifest-skateboard`, places only the
    rung's repositories with gates and bootstrap copied from the taskweft
    manifest. Eight steps land as four releases (dev, beta, rc, released),
    each playable on the Steam Frame through the Windows double build.
    Zones run as ghost servers on Fly's headless Linux double build; GPU
    stages run on a sidecar client; every guest runs natively translated.
    """

    problem ~S"""
    The rung ran once in the headset at 72 fps from a build made by hand
    outside every repository, with no zone, no CA and no voice. None of it
    is reproducible from a checkout, and every guest is single precision
    against a double engine.
    """

    related ~S"""
    - RFD 2262, the ladder; RFD 2287, the rung; RFD 2263, the simulator gate.
    - RFD 2256, the transport; RFD 2288 and RFD 2291, the capabilities.
    - RFD 2289, a placement is the manifest row; RFD 2142, the Bao PKI.
    - Abandons RFD 2067: the ladder's tags are the pen's `v<date>-dev.N`, and
      the packaging repository its semver tags named is not placed.
    """

    drafted_by :ai

    details_title "the Skateboard's workspace, and the first rung's plan"

    details "What the desk found on 2026-09-30", ~S"""
    - The double build that held 72 fps in the headset (`entities-godot`
      master `97dab7a63`, godot-sandbox `b1118e5`, llvm-mingw 20260922)
      lives at `C:/b/godot-dbl` and `~/rfd2287/godot-dbl`, outside every
      repository. No workflow, script or `7-service/godot-build` variant
      passes `precision=double`; no double binary is in the workspace.
    - The godot-sandbox source is not placed; the pen vendors single
      binaries at `addons/godot_sandbox/bin`, and its `.gdextension`
      already names the absent `*.double.*` files.
    - The guest `Variant` is 24 bytes at single and 40 at double
      (`2-contract/guest-runtime/vendor/sandbox-api/docker/api/variant.hpp:304`).
      `vendor/sandbox-api/cmake/CMakeLists.txt:15` passes
      `DOUBLE_PRECISION_REAL_T` to programs and never to the `sandbox_api`
      library; `node2d.cpp:26,48` and `vector.cpp:57-141` return `float`.
      Every ELF in the pen is single (`build/rv64/CMakeCache.txt`).
    - `3-interactor/lasso` is done as a library with Lean tests and
      planted controls; nothing in the pen loads `lasso.elf`. The RFD 2263
      replay (`tools/gate_replay.gd`, `tools/strokes/skirt.usda`) passes
      in CI on stock single 4.7.2, has no control in replay mode, and
      `skirt.usda` carries no `meta.expected`.
    - The pen's action map is Godot's default: no Frame controller
      profile, no hand tracking, Stage space not local-floor, no haptics,
      no mirror. The garment is a `MeshInstance3D` on a FoxGirl OBJ; no
      `Skeleton3D`; `usd.elf` reads no skeletons; Godot master has no USD
      importer.
    - The headset harness is on the unmerged pen branches
      `feat/companion-pens` (`tools/frame/run-xr.sh`, `still.sh`,
      `clip.sh`, the `hand.gd` null guard the double build needs) and
      `feat/windows-run`; `xr/companion_pens.gd` turns the companions off
      whenever OpenXR is active.
    - `frame-controller-sim`'s `feat/windows-driver` (`724f7f6`) registers
      the companions as controllers with
      `Prop_ControllerHandSelectionPriority_Int32 = -1` and carries the
      feeder (`src/vpen_feeder.cpp`, `tools/vpen_feeder.py`); `main/main`
      is `50f41be`, trackers only.
    - `interactor-fabric-zone` and `interactor-voice` do not exist. The
      engine-native sources sit in `4-entities/godot-fabric`:
      `modules/multiplayer_fabric` (4.8k lines, `FabricZone` subclasses
      `SceneTree`), `modules/multiplayer_fabric_asset`, `modules/http3`
      over `thirdparty/picoquic` and `picotls` (picoquic owns its socket;
      the client installs a null verifier), `modules/speech` over
      `thirdparty/opus_speech`.
    - The avatars `chibifire-stages/character-mille-mire-feuille` and
      `character-marocchino` are on GitHub (Apache-2.0, USD) and not
      placed; the 53-role map is in Marocchino's `.fbx.meta` and Mire's
      `.unitypackage`; the USD joints are renamed (`Upper_leg.L` to
      `Upper_leg_L`); Mire has no FBX.
    - `sakuragaoka-station` is placed at
      `3-interactor/sakuragaoka-station-upstream` (`4112f57`, MIT): a
      deterministic procedural three.js town (`ctx.rng` is mulberry32,
      `Math.random` banned), `build(ctx)` per module, `tools/check.mjs`
      builds it headless in node, and `src/core/batch2.js` already bakes
      every toon colour into vertex colours and merges by cell.
    - `1-transport/meshing-pen/tools/build.exs:27` fetches the riscv64
      sysroot from `interactor-mujoco-sandbox-demo`; `build.sh` runs
      `3-interactor/drape/kernels/avbd/gen.sh` unconditionally;
      `.github/workflows/guests.yml:52` syncs eighteen repositories by
      name.
    - The Frame advertises `_steamos-devkit._tcp` as `fire-s-frame` and
      `fire-s-frame.local` is in `known_hosts`; `~/.ssh/config` has no
      `Host frame` block yet. The headset harness expects `~/rfd2287/pen`,
      `~/rfd2287/godot-dbl`, `~/rfd2287/proton-xrfix` and its prefix.
    - This desk, an M2 Pro Mac, is the desktop client and the GPU sidecar;
      it has clang, cmake, ninja, lake, elixir, Blender, `op` and
      `flyctl`, and no llvm-mingw. `desktop-ai4kuou` (Windows, the
      NVENC card) is online on the tailnet and is not a client.
    - `gh` on this desk is the App installation `v-sekai-fire-persona[bot]`
      (keyring service `gh:github.com`); `git` mints installation tokens
      through `~/.local/bin/git-credential-gh-app` and
      `gh-installation-token`, cached in the login keychain under account
      `github-app-4890712` (services `github-app-token-<org>`,
      `github-app-token-expiry-<org>`; the retired `.keychain-jwt.bak`
      path also used `github-app-private-key`). None of it is in 1Password.
    """

    details "The workspace: contract-manifest-skateboard", ~S"""
    One repository, `V-Sekai-fire/contract-manifest-skateboard`, branch
    `main/main`, made by `gh repo create` under the `v-sekai-fire-persona`
    user and given the taskweft manifest's ruleset shape: PR plus merge
    queue, the six required contexts `manifest-comments`,
    `manifest-dupes`, `manifest-root`, `manifest-root-shepherd`,
    `manifest-xml`, `sync-preflight`, never `--admin`. Its contents:

    - `default.xml`, the five gates and the preflight copied from
      `contract-manifest-taskweft` (`check_manifest_{comments,dupes,root,xml}`,
      `sync.exs`, `.github/workflows/gates.yml`), each keeping its
      `--self-test`.
    - `bootstrap.sh`, `bootstrap.ps1`, `install.sh`, `install.ps1`,
      `bootstrap-pins.txt`, `pixi.toml`, `pixi.lock`, `check_bootstrap.py`
      and the bootstrap workflow copied from `contract-bootstrap`, with
      `bootstrap.sh`'s two defaults (`WEFTSPUN_RAW`, `WEFTSPUN_MANIFEST`)
      and `bootstrap.ps1`'s pointed at the new repository. `pixi.toml`
      loses the `web` feature and the `emsdk-install` task; the
      `llvm-mingw` pin moves to 20260922, the version the headset build
      used.
    - `default.xml` places the repository itself at `2-contract/bootstrap`
      with the seven `<linkfile>`s `contract-bootstrap` carries today, so
      `bootstrap.sh`'s `repo sync 2-contract/bootstrap` and step 4's
      `cmp` of the pins hold without change.

    The rows, by side, every one at the revision the taskweft manifest
    pins today unless named:

    - 1-transport: `transport-meshing-pen` at `main/main` once
      `feat/dress-on` lands there; `weftspun-studio`,
      `transport-cineform-tui`, `transport-elixir-libgodot-connector`,
      `transport-central-launcher`, `transport-usbip-frame`.
    - 2-contract: `manuals-weftspun` with its five linkfiles,
      `contract-guest-runtime`, `contract-guest-common`,
      `contract-ggml-rd`, `ggml`, `plausible-witness-dag`,
      `weftspun-agreements`, and the manifest itself.
    - 3-interactor: `interactor-curvenet`, `interactor-lasso`,
      `interactor-usd-guest`, `interactor-fabric-zone` and
      `interactor-voice` (new, step 4), `interactor-av1mkv`,
      `interactor-cineform`, `interactor-mujoco-sandbox-demo`,
      `frame-controller-sim`, `interactor-taskweft-godot-sandbox`,
      `sakuragaoka-station` at `4112f57` (the three.js original, the
      parity oracle), and a `pyrowave` fork at `89f7e47` carrying
      `pwbench.cpp`.
    - 4-entities: `entities-godot` at `4-entities/godot` (master) and at
      `4-entities/godot-fabric` (the fabric tag, the port source for
      steps 4 to 7), `entities-godot-sandbox` at `b1118e5` (new),
      `entities-sakuragaoka-station` (new, the Godot port),
      `entities-godot-cineform`, `godot_openvr` at `feat/frame-devices`,
      `godot-vrm`, `entities-godot-sandbox-gdscript-compiler`.
    - 5-repository: `repository-riscv64-sysroot`;
      `character-mille-mire-feuille` and `character-marocchino` from the
      `chibifire-stages` remote at `https://github.com/chibifire-stages`,
      each with a `<linkfile>` of its committed glTF into the pen's
      gitignored `avatars/`.
    - 6-datasource: `datasource-cassie`; `datasource-store`
      (fabric-store, the SQLite VFS whose pages live in FoundationDB,
      with its `<linkfile>` of `fdb_vfs.c` into
      `7-service/bao-sqlite-fdb/thirdparty/store/`) and
      `datasource-foundationdb`.
    - 7-service: `service-godot-build` (the workflows' home),
      `service-cineform`, `service-openbao`, `service-bao-sqlite-fdb`
      (the OpenBao secrets engine that runs catalogued SQL over
      fabric-store databases; the zone journals' home), `service-zone`
      (new; the Fly app's Containerfile and `fly.toml`).
    - The dot repositories `.github`, `dot-claude`, `dot-vscode`,
      `fire-s-extension-pack`.

    The manual's Sides paragraph names the new repository as the live
    goal manifest for the Skateboard and the taskweft one as the goal
    manifest of everything else; the allowlist gains picoquic (MIT),
    picotls (MIT), mbedTLS (Apache-2.0), SQLite (public domain), spmemvfs
    (BSD), zstd (BSD-3) and Opus (BSD-3) for step 4.

    Check: on a bare directory, `curl -fsSL <raw>/bootstrap.sh | sh`
    ends with `sync.exs --preflight` at zero blocking and every row on
    disk; `check_bootstrap.py --self-test` and the five gates'
    `--self-test` pass. Control: a row whose revision does not resolve
    is refused by `check_manifest_xml.py` by name.
    """

    details "The hands: priority mode", ~S"""
    The assistant draws with the pen through SteamVR, not through the app.
    `frame-controller-sim` merges `feat/windows-driver` (`724f7f6`, a
    superset of `feat/tracker-companions-hidden`) to `main/main`, keeping
    the aarch64 `build.sh` beside `build-win.sh`, and gains a `priority`
    key in `driver/vpen/resources/settings/default.vrsettings`, read in
    `CServerDriver::Init`. With it on, slots 0 and 1 activate as
    `TrackedDeviceClass_Controller` with `Prop_ControllerRoleHint_Int32`
    LeftHand and RightHand, `Prop_ControllerHandSelectionPriority_Int32`
    above the Frame controllers' own (read off `vrserver.txt` and
    recorded), `Prop_ControllerType_String = "vive_controller"` and the
    installed `{htc}/input/vive_controller_profile.json`, whose
    components (`trigger/value|click`, `grip/click`,
    `application_menu/click`, `system/click`, `trackpad/x|y|click|touch`,
    `output/haptic`) are what the pen's action map binds: `trigger`,
    `menu_button` for `pen_bridge.finish`, `primary_click` for boundary
    mode. Slots 2 and up stay hidden handed trackers at priority -1. No
    SteamVR global setting is touched; the physical controllers lose the
    hand roles by priority alone.

    The feeder, `tools/vpen_replay.py` on the Frame, is `vpen_feeder.py`'s
    `open_shm`/`write_frame` with `replay_oxrsys.py`'s plan loop: slot 1
    holds the plan's `calib` until `gate_replay.gd` writes
    `replay_plan.json`, then plays each stroke with the trigger down, a
    trackpad click when a stroke's boundary flag changes, and the
    application menu at the end; slot 0 is parked left. `--live` reads
    JSON pose lines on stdin for a model to write. It keeps `--selftest`
    with its wrong-value control.

    Check, on the Frame, through `tools/frame/run-xr.sh <tag> replay`:
    `gate_replay.gd` asserts both hands' tracker profile is
    `/interaction_profiles/htc/vive_controller` and `run-xr.sh` finds
    `vpen_0` and `vpen_1` holding LeftHand and RightHand in the
    `vrserver.txt` slice it cuts. Controls: `PRIORITY=0` (the Frame's
    serials hold the hands, zero strokes, FAIL) and `NOFEED=1` (priority
    on, feeder not started, the calibration never settles, FAIL on the
    wall clock).
    """

    details "The world: Sakuragaoka Station, in Godot", ~S"""
    The station is three.js and the rung is Godot, so the generation is
    ported, as RFD 2267 says a port is. A new repository,
    `V-Sekai-fire/entities-sakuragaoka-station` at
    `4-entities/sakuragaoka-station`, is a Godot addon,
    `addons/sakuragaoka_station/`, in the station's own shape: one
    `world/<module>.gd` per `src/world/<module>.js` with a `build(ctx)`,
    `world/layout.gd` as the world contract (coordinates, roads, lots,
    spots, `heightAt`), `core/rng.gd` as mulberry32 so a seed gives the
    same town in both, `core/toon.gdshader` for the 4-band ramp on vertex
    colour, and `core/batch.gd` merging static meshes by cell as
    `batch2.js` does. Materials are vertex colours as in the original;
    textured signs are blank. The pen instances `station.tscn` under
    `World/Station`, origin on the plaza at `(-1, 0, -11.4)`, metres and
    Y up as the original, no conversion.

    The port goes in the order the person sees it: `layout`,
    `environment` (ground, sky, far hills), `plaza`, `station`, `sakura`,
    then `street`, `poles`, `railway`, `props`, then `houses`, `shopsA`,
    `shopsB`, `shrine`. Trains, vehicles, characters, petals and audio are
    animation and stay out of the rung; they are later modules of the same
    addon. The first measurement, before any code: `npm ci && node
    tools/check.mjs <modules>` in the fork prints the triangle count per
    module, and the fork gains `tools/reference.mjs`, which writes
    `reference.json`: per module, its triangle count, its bounding box,
    and the count of meshes by colour, all at seed 1 and `t = 0`. That
    file is the oracle.

    Check, `tools/gate_station.gd` in the addon, headless: for each ported
    module, the Godot build at seed 1 matches `reference.json` on triangle
    count within 2% and bounding box within 0.1 m, and the whole scene
    holds 72 fps in the headset gate (p95 at or under 13.9 ms); the plaza
    is seen on the devkit's stream, and `tools/frame/clip.sh` and
    `still.sh` keep what was seen under `logs/`. Controls:
    `--control=drop_lot` removes one lot from `layout.gd` and the plaza
    module's count must miss the oracle by name; `--control=seed_2` builds
    at seed 2 and must miss it, confirming the match depends on the
    seed and not the budget.
    """

    details "Step 1. Build", ~S"""
    - `~/rfd2287/proton-xrfix` on the Frame is stock Proton 11.0
      (ARM64) with a wineopenxr tweak made by hand. It is reproduced,
      not pinned: `diff -rq` of the copy against
      `steamapps/common/Proton 11.0 (ARM64)` over `ssh frame` names the
      changed files, `tools/frame/proton-xrfix.sh` applies the same
      change to a fresh copy and checks the sha256s match, and the
      logbook records the diff. The harness runs on the scripted copy
      from then on.
    - This Mac as the desktop client: the macOS double editor from the
      release, the addon's macOS double library, compute-rd on Metal
      through the same `rdc::Device`, `tools/run-mac.sh` beside
      `run-windows.sh` for the flat client and the sidecar; the pen's
      parked `macos.yml` becomes the macOS arm of the headless gates.
    - Branches first: merge `feat/companion-pens` into `feat/dress-on`
      (it diverged before the build files existed, so the merge adds
      `tools/frame/*`, `xr/companion_pens.gd`, `xr/companion_hand.gd` and
      the `hand.gd` guard without deleting anything; drop
      `tools/sync_dress_on.sh`), then `tools/run-windows.sh` from
      `feat/windows-run`, then `feat/dress-on` to `main/main`.
    - GitHub Actions builds every binary; nothing is built by hand
      again. `7-service/godot-build` is the workflows' home, so the
      engine fork keeps upstream's nine workflows off and pays no
      runner minutes for them: its `.github/workflows/double.yml` checks
      out `entities-godot` at the pinned commit and runs a matrix of
      `windows-x86_64` (llvm-mingw 20260922, `use_mingw=yes
      use_llvm=yes`), `linux-x86_64` and `macos-arm64`, each at
      `precision=double` for `target=editor` and `target=template_release`
      (`debug_symbols=yes` on the template, for the fault below), sccache
      on the runner's cache, and a release on a tag `v<date>-double.N`
      carrying the six binaries and their sha256s. The escript in the same
      repository gains `--precision` and `--extra` so the Windows job
      replays on a Windows desk when a runner is not at hand. The pen's `CITATION.cff` records
      the engine commit, the toolchain, the flag line and each sha256.
      The Frame pulls the Windows release with `curl` over `ssh frame`
      into `~/rfd2287/godot-dbl`; this Mac pulls the macOS one.
    - Linux x86_64 double, the servers' build, comes only from the
      workflow: there is no Linux machine on the desk any more (the WSL
      Fedora is deleted), so the matrix's `linux-x86_64` job is the one
      Linux build, it runs `--headless` in the Fly image, and the pen's
      headless gates run on the `ubuntu` runner. The Frame's own Linux
      path, the compatibility layer's missing XCursor and xkbcommon, is
      a runtime `dlopen`; the x86_64 `SteamLinuxRuntime_sniper` entry
      point under FEX is tried once from the headset and `LD_DEBUG=libs`
      logged either way, and no rung waits on it.
    - The addon at double, from the placed `4-entities/godot-sandbox` at
      `b1118e5` plus `feat/bintr-emit`, by `addon.yml` in the same
      workflows' home: `scons
      platform=windows arch=x86_64 target=template_release
      precision=double use_mingw=yes use_llvm=yes`, the linux x86_64 and
      macos arm64 twins, released on a tag and vendored into
      `addons/godot_sandbox/bin` under the names the `.gdextension`
      already maps, with commit, flags and sha256 in `CITATION.cff`. The
      unrecorded double binaries in `taskweft-godot-sandbox` are not
      copied.
    - Native binary translation, required, interpretation never: every
      ELF ships with its translation. The addon is built from
      `feat/bintr-emit` (`GODOT_SANDBOX_BINTR_EMIT=<dir>` writes each
      program's translation as C99; `RISCV_ASMJIT=OFF`, no JIT), and
      the pen's `guests.yml` emits each program's C99 on the linux
      runner and compiles one library per program hash,
      `res://bintr/bintr-<HASH>.so` for linux x86_64, `.dll` for
      windows x86_64 through llvm-mingw, and `.dylib` for macos arm64,
      at double; `tools/build.exs` does the same on a desk.
      `stages/sandbox_util.gd`'s `enable_native_translation` drops its
      Linux-only guard and turns the setting on wherever a library for
      the platform is shipped; the Windows segfault of 2026-09-23 (the
      setting on with no library present) is reproduced on the double
      build, its backtrace logged, and fixed in the placed addon source,
      not avoided. `guests.yml` and the release carry the libraries
      beside the ELFs with their sha256s. Check: `probe_load.gd` asserts
      `Sandbox.is_binary_translated()` for every ELF on the Frame, the
      desktop and the Fly image, and the logbook records each ELF's
      instructions per second translated against interpreted. Control:
      an ELF whose hash has no library reports untranslated and the gate
      fails by name.
    - Guests at double, in `contract-guest-runtime`'s vendored
      sandbox-api: `target_compile_definitions(sandbox_api PUBLIC
      DOUBLE_PRECISION_REAL_T)` under the option; `node2d.cpp` returns
      `real_t`; `vector.cpp`'s wrappers take `real_t`, checked against
      the host's `ECALL_VEC3_OPS` handler in the placed source for what
      `fa0` carries. The pen's `build.sh` passes `-DDOUBLE_PRECISION=ON`;
      `godot_lite` stays float, since the host boundary is `api.hpp`'s
      `Variant` and `PackedFloat32Array` is float either way. `lasso` and
      `curvenet` export `variant_bytes()`.
    - The pen's build loses the next rung: `CMakeLists.txt` drops every
      `DRAPE_ROOT`, `LBFGSB_ROOT`, `GARMENT_FIT_ROOT`, `CAGE_ROOT`,
      `HEADFIT_ROOT`, `MOTION_GUEST_ROOT`, `RFDETR_SEG_ROOT`,
      `ANNY_KERNELS_ROOT`, `SINEW_ALIGN_ROOT` line and the `avbd`
      library; `tools/build.exs`'s `@elfs` becomes `curvenet lasso usd
      probes dress_on rd_worker ggml_test` and its sysroot fetch moves to
      `5-repository/riscv64-sysroot`; `guests.yml` syncs the new
      manifest's names; the drape, fit, cage, headfit, motion and rfdetr
      ELFs and fixtures are deleted. One PR, because `build.sh` runs
      drape's `gen.sh` unconditionally.
    - The `template_release` fault, diagnosed not guessed: the
      debug-symbol template, flat and headless with
      `tools/probe_load.gd`, under the two controls already seen (no
      addon; single engine with single DLL), its backtrace into
      `logbook-steam-frame-sizing.md`. The rung ships on the editor
      build.

    Check: `tools/probe_load.gd` loads `lasso.elf` (seven PASS lines with
    their controls) and asserts `OS.has_feature("double")` implies
    `variant_bytes() == 40` for curvenet and lasso; `tools/test.sh` and
    the replay pass on the double editor and template builds in CI on
    linux x86_64 and on the Frame through `run-xr.sh`. Control:
    `--control=single_elf` loads the committed single `curvenet.elf`
    from `087b43a` and must print `RESULT: FAIL`. `linux.yml` gains
    `feat/*` and stays as the single-precision arm.
    """

    details "The guests the pen ships", ~S"""
    `transport-meshing-pen` ships five guest ELFs at its root, each line from
    the header of the guest's `main.cpp`:

    - `curvenet.elf` (`interactor-curvenet`): the curvenet stage, Cassie's pen
      to curvenet to mesh and mesh back to curvenet, CPU only.
    - `dress_on.elf` (`contract-guest-runtime`): the guest's public surface,
      exposing the GPU layer's own Stage 1 probes.
    - `mujoco.elf` (`interactor-mujoco-sandbox-demo`): MuJoCo as a RISC-V
      sandbox guest stepped from GDScript; its `main.cpp` has no header, so
      this line is the project README's.
    - `rd_worker.elf` (`contract-guest-runtime`): Gate 6G.1, `rd_compute`
      called from a worker Thread's vmcall.
    - `usd.elf` (`interactor-usd-guest`): OpenUSD opens a `.usdz` package
      from bytes the host hands over, with no filesystem, and answers with
      packed arrays.

    The addon carries its own `addons/godot_sandbox/gdscript.elf`. The pen
    builds `probes`, `ggml_test`, `lasso`, `cage`, `headfit`, `rfdetr_seg`,
    `motion`, `cassie_graph` and `usd_probe` without shipping them, and its
    `.gitignore` names each. The census is `git ls-files '*.elf'` on the
    pen's `release/v20261001-dev.1`; this list holds by agreement, and no
    gate compares it with the pen.
    """

    details "Step 2. Draw", ~S"""
    - `stages/pipeline.gd` runs `INFER, RIG, AUTHOR, MESH, ATTACH, DONE`:
      `_mesh_done` goes to `ATTACH`, which emits `garment_ready` and the
      new `attach_ready(bone)`; the fit, check and drape states, their
      options and `main.gd`'s wrappers go. FIT and DRAPE are the next
      rung's.
    - `stages/lasso_stage.gd` opens `lasso.elf` through `make_sandbox`
      with `lasso_snap`, `lasso_redirect`, `lasso_check_all`;
      `xr/lasso_pointer.gd` on each `XRController3D` sends the hand's
      basis and origin as the source and the `lasso_targets` group (the
      avatar, the mirror, the garment) as targets while `grip` is held,
      highlights the snapped target, pulses `haptic` when it changes, and
      on trigger over the avatar calls `Main.dress_on_wear()`.
      `lasso.elf` leaves `.gitignore` and is committed like
      `curvenet.elf`; `4-entities/godot-fabric/modules/lasso` is deleted.
    - The world-locked grid `addons/procedural_3d_grid/core/procedural_grid_3d.tscn`
      is instanced under `World` at the floor.
    - `project.godot`: `xr/openxr/reference_space=2` (local floor) and
      `xr/openxr/extensions/hand_tracking=true`; the action map gains
      `/interaction_profiles/ext/hand_interaction_ext` with `trigger` on
      pinch and `aim_pose`. Godot master has no Frame controller profile,
      so the gate logs each hand's `get_tracker_profile()` and the
      logbook records the measured binding.
    - `tools/gate_replay.gd` gets its control: `skirt.usda`'s
      `customLayerData` carries `expected = {cycles: 2, openings: 2}`
      (regenerated by `tools/make_skirt.gd`), and `--control=drop_seam`
      drops the stroke `seam_back` in `_author` before `StrokesUsd.events`
      and must fail at MESH.

    Check: the replay passes headless on the double build and on the
    Frame in priority mode (six strokes, two cycles, two openings); the
    Lean tests in `3-interactor/lasso/tests/lasso` pass with their
    controls; `elixir tools/build.exs --no-elfs --gates=load,crossings`.
    Controls: `drop_seam` fails; `hidden` and `flat --expect=xr` fail;
    priority off draws nothing.
    """

    details "Step 3. Wear", ~S"""
    - Each avatar repository, in `chibifire-stages` itself, gets a
      commit with a glTF exported once by this Mac's Blender from
      `Mire.blend` and `Marocchino.fbx` (Godot master imports glTF and
      FBX, not USD) and a `<name>.humanoid.tsv` of role to joint, 53
      roles in `SkeletonProfileHumanoid`'s vocabulary, derived from
      Marocchino's `.fbx.meta` and Mire's `.unitypackage`. The manifest
      gains a `chibifire-stages` remote and links each glTF into the
      pen's `avatars/`.
    - `util/avatar_load.gd` loads the glTF at runtime
      (`GLTFDocument.append_from_file`, `generate_scene`), returns the
      `Skeleton3D`, the rest-pose body surfaces, and a rig
      `{positions, bones, names}` that `util/skeleton15.gd`'s `adapt`
      already maps by alias (`Hips`, `Upper_leg_L`, `Lower_leg_L`,
      `Upper_arm_L`, `LeftHand` are in Marocchino's joint list).
      `stages/infer_stage.gd` takes `opts.avatar` and keeps FoxGirl as
      the fixture when it is empty.
    - `xr/xr_world.gd` on `attach_ready` makes a `BoneAttachment3D` on
      the TSV's Hips joint and reparents `Body/Garment` under it with
      the global transform kept; a haptic pulse marks it. The mirror,
      `xr/mirror.gd`: a `SubViewport` camera on the mirror plane facing
      the person, shown on a 1 by 2 m quad 2 m away, a world-locked video
      mirror, which is what it is called.
    - `tools/frame/push.sh` rsyncs the pen, the engine and the DLL to
      `~/rfd2287/`, because the headset sync was never recorded.

    Check, in `tools/gate_xr_scripted.gd` after DONE: move the hips bone
    0.100 m up and read the garment's box centre one frame later;
    displacement 0.100 m within 0.002 m (a tenth of a metre, about a soda
    can and a half across; the tolerance about a credit card and a half);
    the waist loop's mean height within 0.15 m below and 0.05 m above the
    hips. `--png` and `still.sh` give the stills, one of them in the
    mirror. Control: `--control=no_attach` leaves the garment under
    `Body`, displacement zero, FAIL.
    """

    details "Step 4. Transport and lock-down", ~S"""
    Two repositories shaped like `interactor-lasso`, placed after it:
    `interactor-fabric-zone` at `3-interactor/fabric-zone` and
    `interactor-voice` at `3-interactor/voice`. `zone.elf` has a player
    mode, as `FabricZone::is_player` does, so there is no `client.elf`.
    picoquic lives only in `zone.elf`; `ca.elf` carries mbedTLS only.

    - `guest/transport`: `quic_picoquic_backend.cpp` rewritten without
      `picoquic_packet_loop` and its thread: `picoquic_incoming_packet`
      and `picoquic_prepare_next_packet_ex`, driven by `tick(now_us)`;
      entropy and clock come from the host (`net_seed`, `zone_tick`'s
      wall time); the null verifier is replaced by
      `ptls_mbedtls_get_certificate_verifier` over the session root DER;
      `thirdparty/webtransportd/frame.c` verbatim.
    - `guest/ca`: a root key made in guest memory at `ca_open`;
      `ca_issue(csr, name, now)` issues one-hour certificates for names
      matching `^[a-z0-9-]+\.zone\.fabric\.internal$`. `ca.elf` has no
      transfer entry point at all.
    - `guest/capability`: macaroons as an HMAC-SHA256 chain with caveats
      vm, verb, object, expires, epoch; the host (`stages/capability.gd`)
      holds the root key and hands each VM a derived key, so `ca.elf`,
      which gets none, can verify no transfer. The per-VM bit in the
      godot-sandbox host-call table lands in `entities-godot-sandbox`.
    - Host: `stages/zone_stage.gd` owns a `PacketPeerUDP`, drains it into
      `net_rx`, sends `net_tx`, calls `zone_tick` once a frame; enrolment
      is a CSR on an `ENROL` stream the desktop hands to `ca_stage.gd`,
      then a reconnect with mTLS. The root DER passes out of band as a
      launch argument.
    - Vendored at riscv64 from the fabric tag by
      `tools/vendor/from_godot_fabric.py`: picoquic without its socket
      loops and other TLS backends, picotls's four files, mbedTLS with
      `FS_IO`, `THREADING`, `NET` and `SSL` off, SQLite as `OS_OTHER` on
      `spmemvfs`, zstd's three directories; each directory with a
      `CITATION.cff` naming the tag.

    Check, Lean tests over the compiled C++ with an in-memory UDP pair:
    a certificate from another CA is refused (control: the null verifier
    accepts it); an expired one is refused (control: the clock frozen at
    issue accepts it); an out-of-pattern name is not issued (control: a
    suffix check issues `a.zone.fabric.internal.evil.com`); a transfer
    with no capability is refused and goes ahead once minted (control: a
    table that skips the bit test lets it through; a macaroon with one
    caveat altered still verifies).
    """

    details "Step 5. Zone", ~S"""
    `guest/fabric`: `fabric_zone_types.h`, `relativistic_zone.h`,
    `predictive_bvh.h`, `r128.h` and the adapter verbatim with `real_t`
    as `double`; the static `_*_s` routines, intent packing and ghost
    helpers verbatim; `initialize`, `physics_process` and `finalize`
    rewritten as `ZoneCore::open(cfg)` and `tick(now_us)` with the
    `SceneTree`, `Engine`, `OS` and `ResourceSaver` calls replaced by
    arguments and byte buffers; the journal verbatim on in-memory SQLite
    with `export()` behind the write capability; the peer rewritten as
    `fabric_link.cpp`, one WebTransport session per neighbour with the
    channel in the frame. Each player is one entity; its pose is one
    `CH_POSE` datagram a tick, 53 swing-twist triplets as int16, relayed
    with `local_broadcast_raw`.

    The journal does not stay in the guest. `OpenBao -> fdb -> s3` is the
    placement: `service-openbao` on FoundationDB, `datasource-store`'s
    `fdb_vfs.c` giving SQLite pages that live in the same cluster, and
    `service-bao-sqlite-fdb` answering `bao read <mount>/query/<name>` and
    `bao write <mount>/exec/<db>/<name>` from a startup catalog and
    nothing else. `stages/zone_stage.gd` drains `zone_journal_export`
    under the write capability every tick that changed a row and hands
    the rows to the host's Bao client (the desk's agent identity over
    Tailscale, RFD 2142's shape), which runs the catalogued execs
    `append_mutation` and `append_snapshot` on the database
    `zone-<id>`; the schema is `fabric_zone_journal.cpp`'s two tables,
    `entity_mutations` and `entity_snapshots`, in a `schema "zone-*"`
    block. A zone that restarts loads its last snapshot back through
    `query/zone-<id>/latest_snapshot` into `zone_load_snapshot`, so one
    owner per entity holds across a restart as well as across a
    hand-off. The garment's index hash is a row in the same journal, so
    step 6's fetch has a record a session later.

    Check: a row the zone wrote is read back by `bao read` with the same
    entity id and tick, and a restarted zone resumes at its last
    snapshot's tick. Controls: an export with no write capability is
    refused by `capability.gd` before any Bao call; an exec name not in
    the catalog is refused by Bao; the plugin's own `--self-test` plants
    a fenced database opened without its fence.

    Check: `tests/gate_fabric_two_clients.gd` runs server, worker and two
    players over loopback and reads each client's view of the other's
    pose; the Lean tests search for a frame with two owners or none across
    boundary crossings at candidate speeds and link delays. Control: the
    staging timeout floor removed with a one-tick delay rolls A back to
    OWNED while B's ACK is in flight, and the search finds two owners.
    """

    details "Step 6. Worker zone: a ghost server, and the GPU as a sidecar", ~S"""
    The worker zone is tiny and has no GPU, so it owns and dispatches and
    does not compute. `zone.elf` in worker mode (zone 1) keeps the job
    queue, the garment's ownership and the asset index; the GPU stage runs
    on a sidecar, a client that has a GPU and the pen's sandbox (this
    Mac in this rung, the Frame when it is idle), which registers with
    the worker over a `CH_JOB` stream when it connects. On
    `strokes_ready` the worker sends the stroke set to one sidecar; the
    sidecar's `stages/sidecar_stage.gd` runs `curvenet.elf` on
    compute-rd, then `asset_store` through `asset.elf`, and streams the
    `.caibx` and the chunks back on `CH_ASSET`; the worker verifies every
    chunk against its id (`guest/asset`: `parse_caibx`, the buzhash
    chunker, `sha512_256`, `decompress_and_verify_chunk`,
    `assemble_from_caibx`, lifted from `fabric_mmog_asset.cpp` onto std
    types; HTTP, keychain and ACL dropped), writes them under the server's
    store, records the index hash in its journal, then
    `zone_garment_spawn(hash)` and `zone_handoff(eid, 0)`. The ghost
    carries the index hash; each client fetches by it and assembles. When
    no sidecar is attached the worker runs the CPU target of the same
    Lean-emitted kernels (`kernels/cassie/cpp`, the slangc cpp emits
    under slang-rt, one source two targets) itself, slower and the same
    answer within RFD 2269's intervals.

    Check: the two-client gate counts the garment's owners every tick and
    finds exactly one; a garment the sidecar made lies inside the CPU
    oracle's intervals (RFD 2269); the Lean chunk property stores random
    data up to 1 MiB, verifies every chunk and assembles the input.
    Controls: one byte of one chunk flipped with the expectation kept
    must be caught at the worker; a sidecar kernel built with
    `-ffp-contract=on` falls outside the interval and is named; the
    worker with no sidecar makes the garment itself and the gate records
    both times.
    """

    details "Step 7. Talk", ~S"""
    `interactor-voice`: Opus 1.6.1 without `dnn/`, `celt/x86`, `celt/arm`,
    rnnoise, AEC3 or libsamplerate, with its own `opus_guest_config.h`;
    `voice_encode` on 960-sample frames at 48 kHz, `voice_push` and
    `voice_pull` over a jitter buffer with packet-loss concealment, lifted
    from `speech.cpp` onto std containers. The host sets
    `audio/driver/mix_rate=48000`, captures through `AudioEffectCapture`
    on a Mic bus, sends packets as `CH_VOICE` datagrams through the local
    `zone.elf`, and plays each remote player at their avatar's head bone
    through an `AudioStreamPlayer3D` fed by `voice_pull`.

    Check: `tests/gate_voice_loopback.gd` round-trips speech between the
    two clients; the Lean property decodes a frame and holds 15 dB SNR
    against its input. Control: one packet dropped with the expectation
    kept falls below the threshold.
    """

    details "Live: the ghost servers on Fly", ~S"""
    Live means the machines Fly already runs for this org, logged in as
    the operator on 2026-09-30: `weftspun-fdb`, three `shared-cpu-2x`
    machines in `sjc` with 1 GB volumes (`cluster_health` passing on all
    three; `backup_fresh` and `backup_fresh_dr` critical on all three
    with `connect: connection refused`, the backup-freshness probe of
    `6-datasource/store/fly/backup-fresh.sh` not answering, so the
    backups are unverified and that service is brought back and checked
    before the journals depend on the cluster), and `weftspun-bao`, one `shared-cpu-1x` in `sjc`
    with a dedicated IPv6, OpenBao on FoundationDB storage, mutual TLS on
    8200, a Tailscale sidecar, and the `sqlite-fdb` and GitHub plugins
    built into the image under `/bao/plugins` and left unregistered. None
    of them has a GPU, and none will.

    A new app, `weftspun-zone`, from a new repository
    `V-Sekai-fire/service-zone` at `7-service/zone`: a Containerfile that
    takes the Linux x86_64 double headless engine, the addon's double
    `.so`, and the pen at the release tag, and runs `godot --headless
    --path pen --script tools/zone_main.gd` with a `--mode=<server|worker>`
    argument after the script separator; a
    `fly.toml` with two process groups, `server` (zone 0 and `ca.elf`,
    `shared-cpu-1x`) and `worker` (zone 1, the ghost, `shared-cpu-2x` for
    the CPU fallback), a UDP service on a dedicated IPv4 that the host
    binds at `fly-global-services`, and no public TCP. The worker and the
    server reach Bao over the private network at
    `weftspun-bao.internal:8200` with a client certificate from a new
    cert-auth role `zone-fly` whose policy is `sqlite-fdb/exec/zone-*`
    and `sqlite-fdb/query/zone-*` and nothing else; the players never
    reach Bao. The certificate is issued by Bao itself: the org's
    intermediate CA (the chain in `~/.bao-creds/ca-chain.pem`, its key in
    1Password) is installed into a `pki_int` mount from 1Password with
    the root token, in RFD 2142's shape (`bao secrets enable -path=pki_int
    pki`, `bao write pki_int/config/ca pem_bundle=@-` from `op item get`,
    a role `zone-fly` limited to that common name and a 30-day TTL), the
    cert and key land as Fly secrets on `weftspun-zone`, and the cert-auth
    role binds to the certificate's common name. The desk's own `gh` is
    an hourly installation token minted the same way
    (`gh-installation-token <org>` through `bao-mint-github` over
    Tailscale), so every GitHub step needs a Bao tailnet node online,
    which `tailscale status` says. `7-service/openbao` ships the catalog
    (`schema "zone-*"`, `exec append_mutation`, `exec append_snapshot`,
    `query latest_snapshot`) and sets `BAO_SQLITE_FDB_CATALOG` and
    `BAO_SQLITE_FDB_CLUSTER`; the operator registers and enables the
    plugin once with the root token from 1Password and creates the role,
    both recorded in the logbook with the sha256 Bao was given.

    The clients are what have GPUs: the Frame's Adreno and this Mac's
    M2 Pro. Both render, both run `curvenet.elf` on compute-rd for their
    own drawing (Vulkan on the Frame, Metal here), and the Mac is the
    worker's sidecar. The round trip
    from the Frame to `sjc` is measured and logged beside the Wi-Fi
    numbers already in `logbook-steam-frame-sizing.md`; pose and voice
    datagrams at 50 to 90 Hz sit inside it or the rung says so.

    Check: `fly machine run` of the image with `--mode=server` reaches
    Bao (`bao token lookup` under the role's cert) and the two-client
    gate passes with the headset and the desktop as the clients against
    the Fly address; `fly checks list -a weftspun-zone` is all passing.
    Controls: the image with the role's key swapped for the desk agent's
    is refused by Bao's listener; a `zone-2` database name is refused by
    the policy; the UDP service with the bind on `[::]` instead of
    `fly-global-services` receives nothing, confirming the bind
    matters.
    """

    details "Step 8. Evidence", ~S"""
    One session: the person in the headset and the operator on the
    desktop, the assistant's hands on the pen through priority mode and
    the live feeder. The headset view is `clip.sh` from the compositor
    mirror and `still.sh`; the desktop view is `godot-cineform` rebuilt
    at double for macOS arm64 (its own manifest's `godot-cpp` with
    precision double) writing `session.cfhd` through Movie Maker at a
    fixed 30 fps on the flat client, never the XR one; `av1mkv mkv` makes
    the lossless wrap here, which with its `.cff` is the whole deliverable,
    and no WebM is made; the zone logs are the three
    `zone.elf` journals exported under the write capability.
    `logbook/logbook-rfd2287-rung.md` carries the apparatus (the exact
    `run-xr.sh` lines, driver settings, sha256s), the numbers with their
    baselines (frame ms with and without the world, the bone-follow
    displacement, the tracker profiles in both modes), every control's
    outcome, and the counted unchecked items. Check: `av1mkv info`'s frame
    count equals the `.cfhd`'s; control: a truncated `.cfhd` is refused
    by `av1mkv check`.
    """

    details "Credentials", ~S"""
    The App installation `v-sekai-fire-persona[bot]` creates the new
    repositories and sets their rulesets (the operator says it can; the
    first `gh repo create` is the check, and a 403 is logged and handed
    back rather than worked around). The Bao root token is read from
    1Password with `op` exactly once, for `bao plugin register`,
    `bao secrets enable` and the `zone-fly` cert role, never stored, and
    the logbook records the three commands and the plugin sha256. Fly
    changes run in the personal org without asking: the app, the
    dedicated IPv4, and whatever `weftspun-fdb`'s checks say. The Frame
    is `steamos@fire-s-frame.local`, given a `Host frame` block in
    `~/.ssh/config` first thing.

    The desk's stored GitHub credentials, none of them in 1Password, are
    destroyed once the manifest repository and the avatar links exist:
    the `gh` keyring login (`gh auth logout -h github.com -u
    'v-sekai-fire-persona[bot]'`), the cached installation tokens and
    their expiries (`security delete-generic-password -a
    github-app-4890712 -s github-app-token-<org>` and
    `github-app-token-expiry-<org>` for each org), the App private key
    if the retired path left one (`-s github-app-private-key`), and
    `gh-installation-token.keychain-jwt.bak`. The Bao agent bundle in
    `~/.bao-creds` is not a GitHub credential and stays. Check:
    `security dump-keychain | grep github-app-4890712` prints nothing
    and `gh auth status` reports no account. Anything that needs GitHub
    after that is a release workflow, not the desk.
    """

    details "Operator decisions", ~S"""
    - The out-of-band channel for the session root DER (a launch argument
      is the default).
    - Whether the taskweft manifest gets a row pointing at the new one,
      or is left untouched.
    - Which rulesets the new repository carries beyond the manifest's
      six contexts.
    - Fly: the dedicated IPv4 for the UDP service, the region (`sjc`,
      where Bao and FoundationDB are), the machine sizes, and who holds
      the root token for the one-time plugin registration and the
      `zone-fly` role.
    - The wineopenxr tweak in `proton-xrfix`, if the diff on the Frame
      does not explain itself.
    """

    details "The release ladder: dev, beta, rc, released", ~S"""
    The work lands as four releases, each a whole playable build before
    the next starts, in RFD 2262's sense: a person
    puts it on and does the thing it claims. A release is a tag on
    `transport-meshing-pen` (`v<date>-dev.N`, `-beta.N`, `-rc.N`, then
    `v<date>`), a GitHub release on the pen carrying the rung's double
    engine and addon, the ELFs and their sha256s, a playtest recorded on
    the rung's platform (on the Frame, the release uploaded to the
    headset as a development title and played by a named person; on
    macOS, the persona locomotion run below), and every gate of the
    release green with its control, logged
    in `logbook-rfd2287-rung.md`. A
    release that is not playable is not cut. The Windows build is what
    climbs on the Frame; the headless Linux build is what the ghost
    servers run on Fly from rc on; only the Frame's own Linux path is
    logged without gating.

    **The dev rungs play on macOS, not the Frame.** They run
    the macOS arm64 double editor and addon through the oxrsys OpenXR
    runtime and its simulator, streaming with PyroWave, so one machine
    carries the whole loop; the release carries the macOS engine and
    addon checked against their sums, with oxrsys pinned in
    `tools/frame/releases.env`. Collision and walking run in the MuJoCo
    guest, never Godot's physics, because the guest is bit-deterministic
    and migratable. The playtest of a dev rung is persona locomotion: a
    named visitor persona, driven by a language model through the
    simulator, visits the station beat by beat, each beat with a
    screenshot, and the logbook records it as the playtest with that
    deviation named.

    **dev.1: one person visits the station.** The four ported modules
    (`environment`, `station`, `plaza`, `sakura`), each a faithful port
    of 4112f57, with their colliders sent to the MuJoCo guest exactly as
    the original's `physics.js` calls make them. A walker ported from the
    original's `player.js` (radius 0.3 m, height 1.7 m, step 0.45 m) on
    the guest's kinematics, read through rx's hand input, with snap turn
    and teleport. World grab stays available as a fallback. Gates:
    `gate_colliders` (every collider matches the original's), and
    `gate_locomotion` (walk, step-up and its refusal, snap turn,
    teleport, and bit-identical poses across two runs), each with a
    control that must fail. Playable: arrive on the platform, walk to the
    plaza, climb the station stairs, turn, teleport. Past the four
    modules the terrain is open where the town's houses and shops stand
    in the original; the logbook names that gap.

    **dev.2: dev.1's counted gaps closed, the addon rebased, and joy on
    sheets** (operator, 2026-10-02):
    - the gaps `logbook-rfd2287-rung.md` counts: a teleport onto the 8 cm
      handrail is refused through a walkable-floor ray; `solid_land` gets
      a control of its own, apart from `no_resolve`; `tools/probe_player.gd`
      gets a negative control and runs in CI; a frame-time baseline is
      taken with no station loaded, so the frame time has its floor beside
      it; the persona reaches the platform and climbs the stairs, and each
      radial beat shows the radial inside the head-camera frame;
    - the godot-sandbox fork rebased on upstream `8a1774d`
      (V-Sekai-fire/godot-sandbox#15), with the host's unboxed-argument
      path packing `Vector2`, `Vector3`, `Vector4` and `Plane` at double
      rather than as float, its CI green, the addon released from it, and
      every guest rebuilt for the packed-array calls at `ECALL` +68 and +69;
    - the joy forecasts below shown as contact sheets, composed as RFD
      2294's visual comparisons are.
    Each gap closes with the control the logbook counts it as lacking.
    Playable: dev.1's route, with the persona reaching every beat.

    **dev.next: a placeholder for everything not yet assigned to a dev
    rung.** It holds the work that waits for a rung of its own, and an
    item moves out of it into a numbered dev rung when that rung is
    planned:
    - one player with a body: the walker, rx's player controllers and
      motion.elf merged into one player in rx's `sar_game_framework`
      through a MuJoCo-backed movement component, vendored into the pen;
      motion.elf at double driving Mire, the headset player's avatar,
      seen in a mirror, with a foot-slide gate measuring planted-foot
      drift in millimetres against the source clip's own;
    - world grab moved behind a radial menu (hold B or Y, tilt, release);
    - Maro as the dress-on statue beside the plaza monument, with a pen
      to draw on it;
    - the `street` and `railway` modules, then `crossing`, `houses`,
      `vehicles`, `poles`, `props`, `shopsA`, `shopsB`, `trains`,
      `characters` and `petals`;
    - Meta Touch Plus bindings generated from motion-guest's route table;
    - the station's crowds (contract-zone-backend#111), capsule shadows
      (#110) and its drawn materials (#72);
    - rx's scripts shipped as `.sgd` (#92) on the merged-compiler addon
      (#87);
    - the PyroWave encoder pipelined to hold 144 Hz;
    - no hand-placed colliders: every collider decomposed from its mesh
      by CoACD running as a godot-sandbox guest ELF over ggml-rd and
      compute-rd, and handed to the MuJoCo guest;
    - the headset path: the release uploaded to the Frame as a
      development title, the Frame streaming from the desktop over
      oxrsys, and the extra companion controllers.

    **beta: one person wears what they draw, and the assistant draws
    too.** Guests at double with the precision gate; priority mode and
    the replay feeder, with `PRIORITY=0` and `NOFEED=1`; lasso, the grid,
    local-floor, hand tracking and haptics; the avatars placed, the rigid
    attach and the mirror with `no_attach`; the rest of the town's
    modules. Playable: draw, lasso the avatar, wear it, walk to the
    mirror; hand the pen to the assistant and watch it draw.

    **rc: two people in one zone, talking, the garment made elsewhere,
    the zones live on Fly.**
    `interactor-fabric-zone` and `interactor-voice` placed; `ca.elf` and
    the capability table; the transport over the host's UDP; the zone
    with the one-owner search; the worker zone and `asset.elf` with the
    corrupted chunk; voice with the dropped packet; the zone journals on
    `service-bao-sqlite-fdb` over FoundationDB, read back by `bao read`
    and resumed after a restart; `weftspun-zone` deployed and the
    two-client gate run against its address with the headset as one
    client and the desktop as the other and the sidecar. Playable: one
    in the headset, one
    on the desktop, each sees the other's avatar and hears them; the
    drawn garment materialises from the worker zone and is worn.

    **released: the rung, live and reproducible from a bare machine.** The evidence
    session recorded as CineForm with the zone journals;
    `contract-manifest-skateboard` created with the gates and the
    bootstrap, and a bare directory bootstrapped to the released tag;
    the manual's Sides and allowlist edits and this RFD landed; the
    desk's GitHub credentials destroyed. Playable: anyone with the
    bootstrap line and a Frame reaches the rc build and plays it against
    the live zones.
    """

    details "Which features are likely to bring joy", ~S"""
    Each feature carries a forecast, in RFD 2295's tag form, of the chance
    that a player finds joy in it, judged on a sense-of-wonder rubric of
    five criteria: a new sense (an experience new technology makes
    possible), a new standard (it changes how a player sees games),
    emergence (AI or other people make it come alive), motivation (seeing
    it makes someone want to play) and surprise. Infrastructure a player
    never notices rates low however necessary it is; the forecasts say
    where joy is expected, not what is worth building.

    | rung | feature | criteria | joy |
    | --- | --- | --- | --- |
    | dev.1 | walking a faithful station in VR | motivation, surprise | (likely, p=0.70) |
    | dev.1 | world grab: turning the town like a model | sense, surprise | (likely, p=0.65) |
    | dev.1 | the persona visitor touring on its own | emergence | (even, p=0.45) |
    | dev.1 | stick walking, snap turn, teleport | none | (unlikely, p=0.20) |
    | dev.1 | MuJoCo collision, bit-deterministic | none | (unlikely, p=0.15) |
    | dev.1 | playing on macOS via oxrsys, PyroWave | none | (unlikely, p=0.10) |
    | dev.next | drawing a garment onto Maro | sense, surprise, motivation | (likely, p=0.80) |
    | dev.next | companion controllers drawing alongside | emergence, sense | (likely, p=0.70) |
    | dev.next | Mire's body, met in the mirror | sense, motivation | (likely, p=0.70) |
    | dev.next | trains, petals and walkers | surprise, motivation | (likely, p=0.65) |
    | dev.next | crowds on the platform | surprise | (even, p=0.55) |
    | dev.next | the station's drawn materials | surprise | (even, p=0.40) |
    | dev.next | PyroWave held at 144 Hz | none | (unlikely, p=0.25) |
    | dev.next | colliders decomposed by CoACD | none | (unlikely, p=0.15) |
    | dev.next | capsule shadows | none | (unlikely, p=0.20) |
    | dev.next | a development title on the Frame | none | (unlikely, p=0.20) |
    | dev.next | world grab behind a radial menu | none | (unlikely, p=0.15) |
    | dev.next | the foot-slide gate | none | (remote, p=0.05) |
    | dev.2 | the godot-sandbox rebase | none | (remote, p=0.05) |
    | dev.next | `.sgd` scripts, generated bindings | none | (remote, p=0.05) |

    The most joy rests on dev.next's drawing, companion and avatar
    features.
    """

    details "Verification, end to end", ~S"""
    0. Each release: the tag, the GitHub release with sha256s, `push.sh`
       onto the Frame, the named playtest and its `clip.sh` capture, the
       release's gates and controls in the logbook.
    1. A bare-directory bootstrap of the new manifest;
       `elixir .repo/manifests/sync.exs . --preflight` at zero blocking;
       the five gates and `check_bootstrap.py` with `--self-test`.
    2. `cd 1-transport/meshing-pen && elixir tools/build.exs
       --gates=load,crossings` on the double build, every ELF at
       `DOUBLE_PRECISION=ON` with its `bintr-<HASH>` library for both
       platforms; `tools/probe_load.gd` asserts every ELF translated;
       `--control=single_elf` and an ELF with no library both fail.
    3. Lean tests, `lake build && lake exe tests --write=$TMPDIR/nc.txt &&
       diff $TMPDIR/nc.txt native-checks.txt`, in
       `3-interactor/lasso/tests/lasso`,
       `3-interactor/fabric-zone/tests/fabric_zone` and
       `3-interactor/voice/tests/voice`.
    4. On the Frame: `tools/frame/run-xr.sh <tag> replay` in priority mode,
       then `PRIORITY=0`, `NOFEED=1`, `hidden`, `flat --expect=xr` and
       `--control=drop_seam` as controls; `run-xr.sh wear replay` with
       `--control=no_attach`; `gate_station.gd` with `drop_lot` and `seed_2`.
    5. Headless pen gates on the double build: `gate_replay.gd`,
       `gate_capability.gd`, `gate_fabric_two_clients.gd`,
       `gate_voice_loopback.gd`; the same two-client gate against
       `weftspun-zone` on Fly, and `fly checks list -a weftspun-zone`.
    6. `mix rfd.check && mix rfd.render && mix rfd.board --check && prek run
       --all-files` in `2-contract/manuals-weftspun`;
       `python scripts/check_anti_entropy.py` read in full.
    """
  end
end
