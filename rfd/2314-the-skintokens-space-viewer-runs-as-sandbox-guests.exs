# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2314, "the SkinTokens Space viewer runs as sandbox guests", :discussion do
  flight_level :l2
  feature "a public static Space that shows a dropped glTF in Model Explorer, with every script
a godot-sandbox guest"
  scope "the chibifire/skintokens-auto-rig static Space, the V-Sekai-fire fork of
entities-model-explorer, the gdscript compiler fork, godot-sandbox and the WebGPU driver"

  prose ~S"""
  :: decision
  The Space's viewer is Model Explorer. Every script in it is compiled by the
  gdscript compiler fork to a RISC-V program that godot-sandbox runs, and
  every scene file becomes a build procedure inside one of those programs.
  The export ships no GDScript and no scene file. Loading a `.elf` and the
  self-test sit on a separate console page. The first view is never black: a
  light backdrop, a sample model and a one-line hint. A colour checker
  stands in the world beside the model, and the lights are set so that it
  reads its reference values. A shader that renders on GL is not edited to
  fit WebGPU; the engine links its varyings the way GL does (operator,
  2026-10-13).
  :: problem
  The Space must show a visitor's own model on their own GPU, with no
  server. The viewer must run the way the rigging guest will run, as a
  sandbox guest, so that the path a dropped model takes is the path the rig
  will take.
  :: related
  - RFD66606-1046, the SkinTokens model image; RFD66606-2245, WebGPU inside Godot.
  - RFD66606-2213, VRM through a sandbox guest; RFD66606-2211, the base tree of
    entities-godot-sandbox.
  """

  details_title "the SkinTokens Space viewer runs as sandbox guests"

  prose ~S"""
  :: details Sources
  Written on 2026-10-13 from the operator's requests in one session, and
  from the build, the browser runs and the pixel reads taken on the Mac
  mini. Chrome is Playwright's Chromium; Firefox is 157.0.1 with wgpu 29.
  :: details Where the parts live
  - The viewer: the V-Sekai-fire fork of entities-model-explorer.
    `guest/build.py` compiles, `guest/tscn2gd.py` turns scenes into
    procedures and `guest/overlay/` holds the boot script, the controls card
    and the sample.
  - The engine: our entities-godot fork, with a threaded
    double-precision web template that has WebGPU.
  - The host: our godot-sandbox fork.
  - The compiler: our fork of the godot-sandbox gdscript compiler.
  :: details What the build changes
  - A guest passes a path to the host as a literal string, so a relative
    `preload` is rewritten to a `res://` path.
  - A scene becomes `<Name>_scene.gd` with `instantiate()`. It is called as
    `X.new().instantiate()`: a static call on a guest script fails.
  - Text `Transform3D` lists basis columns, and the converter emits them as
    columns.
  - Model Explorer's scripts hold more than 100 scoped values in one call,
    so godot-sandbox allows 8192 for a project script.
  - A dropped file is gone once the drop handler returns, and a guest cannot
    be entered from a second thread, so the web build loads on the main
    thread.
  :: details Renderer and the black screen
  - Forward+ draws the 3D view black on WebGPU with no error. Mobile draws
    it, so the web build uses Mobile.
  - Firefox's WebGPU shows neither the procedural sky nor the clear colour.
    The background is therefore a screen-filling quad at the far plane, and
    the canvas is configured opaque.
  - The boot splash colour, the default clear colour and a style rule over
    the web template's own black page are all light grey. Seven shots from
    0.5 s to 35 s after load were measured for near-black pixels: the old
    console page was 99 % dark for its first 3 s, and both pages are now at
    most 3 %, which is text and the model's dark parts.
  :: details Varyings on WebGPU
  WebGPU guarantees 16 locations between the vertex and fragment stages. A
  device gets 16 unless it asks for more, so the driver asks for the
  adapter's full value. The public device survey at web3dsurvey.com shows
  that this helps desktops only:
  - every report offers at least 16, and 89 % offer at least 28;
  - Windows, NVIDIA, AMD and Apple reports offer at least 28;
  - only 1 to 6 % of Qualcomm Adreno reports offer 28, so a standalone
    headset is taken to have 16. No headset was measured.
  On the Mac mini, headless Chrome on Apple Metal 3 offers 28, gives 16 to a
  device that does not ask, and 28 to one that does.

  MToon passes three `vec3` varyings from the vertex stage to the fragment
  stage. Under GL, Godot writes varyings with no location and the GL linker
  matches them by name. The Mobile renderer on RenderingDevice pins its own
  outputs to locations 0 to 14 and puts material varyings from 15, so MToon
  needs locations 15 to 17, and the browser refuses the pipeline.

  The operator asked for the engine to do what GL does, and for MToon to
  stay as it is. The WebGPU driver renumbers the locations each shader uses
  from 0, in the same order in every stage, before the shader becomes WGSL.
  It bounds-checks every SPIR-V word it reads, because guest programs pass
  raw SPIR-V. On the WebGPU driver, Godot's varying check counts only the
  material's own varyings, as it does on GL. GL also packs small varyings
  into one location; this does not, and a material with many varyings can
  pass Godot's check and still fail in the browser.

  The test drops Godette into the exported viewer, with a page script that
  holds the device to 16 locations:

  | Web template                  | Locations | Result                     |
  | ----------------------------- | --------- | -------------------------- |
  | With the renumbering          | 16        | draws, no pipeline errors  |
  | Renumbering removed (control) | 16        | nothing drawn, two `tspace` locations refused |
  | With the renumbering          | 28        | draws; 27 pixels differ from the 16 run |
  :: details The engine branch's comments
  The comments our WebGPU branch adds are held to 3 % of the non-blank lines
  it adds over the fork's main, the rung `check_comment_ladder.exs` uses for
  a peer codebase (operator, 2026-10-13). License headers are left out of
  the count: every new file needs one, and they alone are 6.6 % of the added
  lines. Whole comment blocks are kept or removed, and the ones kept say why
  the code is the way it is. The branch went from 9.2 % to under 3 %.
  :: details The viewer's own checks
  The viewer's GDScript is formatted with gdformat, run by prek in a checks
  workflow on every pull request and in the merge queue. The vendored MToon
  addon is left out, so a pull from its upstream brings no diff. A format
  change is checked by building every guest before and after it: only the
  section that holds source line numbers may differ.
  :: details Colour and light
  The colour checker is a board standing on the floor to the model's right,
  at half the model's height, with two 24-patch charts. The top chart is
  lit like the model. The bottom chart is unshaded, so it shows only the
  output transform. The boot script prints each patch's screen position,
  and a test reads the pixels there.

  | Setting                       | Neutral 5, ref 122 |
  | ----------------------------- | ------------------ |
  | Filmic, unshaded chart        | 155                |
  | Linear, unshaded chart        | 122                |
  | Ambient 0.6 + key 1.0, lit    | 141                |
  | Ambient 0.44 + key 0.73, lit  | 122                |

  The lit numbers are for a chart square to the camera. On the board in
  the world the camera looks down a little, and the lit chart reads 118.
  :: details The tools
  - Hide grid did nothing anywhere: the scene never sets the controller's
    grid. The camera also sat level with the grid, which then showed edge-on
    as nothing. The boot script sets the grid and tilts the camera down 12
    degrees.
  - WebGPU has no line polygon mode. On the web, wireframe adds a line copy
    of each mesh with the same skin.
  - Explode moves meshes apart, so it shows nothing on a one-mesh model.
  :: details Call numbers
  The compiler fork numbered the packed-array acquire and release calls 67
  and 68. Upstream godot-sandbox gives 67 to its array window call, and our
  host has acquire and release at 68 and 69, so a compiled loop over a
  packed array reached the wrong call. The fix keeps every upstream number
  and holds the two packed-array calls at 68 and 69. Upstream does not have
  them.
  :: details Sample models
  A sample must allow commercial use and must not be share-alike. Sophia,
  CC BY-NC-SA, was taken out. The sample is Mire, Apache-2.0, exported from
  `MireQuest.blend`, with the licence and a notice of the conversion.
  :: details Open
  - Upstream the two packed-array calls, or drop them and keep to upstream
    numbering.
  - Forward+ on WebGPU draws black.
  - Firefox runs out of executable memory on one visitor's machine.
  - The Hammersley contact sheet and `.usdz` through the USD guest are not
    in the viewer yet.
  - The console page's light-background export settings and the Starforged
    sample build script are parked, not in a repository.

  This RFD was drafted by an AI and read by a human before it shipped.
  """
end
