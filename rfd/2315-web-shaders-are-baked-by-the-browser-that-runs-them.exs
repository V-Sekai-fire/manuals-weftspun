# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2315, "web shaders are baked by the browser that runs them", :discussion do
  flight_level :l2
  feature "a web export ships the shader cache the browser itself writes, so a first visit
converts almost no shaders"
  scope "the WebGPU web template of our entities-godot fork, its shader cache, the export
pipeline of the SkinTokens Space viewer and the Chrome and Firefox it runs in"

  prose ~S"""
  :: decision
  A web export ships a shader cache that a browser wrote. The pipeline opens
  the exported page once with the page argument `--warmup`. The page draws
  one small sphere for each StandardMaterial3D shader key that the glTF
  importer produces, waits for the shaders, and prints its
  `user://shader_cache` to the console. The pipeline rebuilds those files
  and the next export carries them in the pck, where the engine reads them
  before it compiles anything. The editor's shader baker for WebGPU stays,
  but it does not decide what ships.
  :: problem
  The Meta Quest store limits a load to 4 seconds. A cold visit to the
  SkinTokens Space viewer takes 12.6 seconds on a Mac mini, and 7.2 seconds
  of the main thread wait on shader conversion: GLSL to SPIR-V to WGSL,
  done in wasm, in the browser. A repeat visit takes 3.75 seconds, because
  the browser kept the converted shaders.
  :: related
  - RFD 2314, the SkinTokens Space viewer runs as sandbox guests.
  - RFD 2245, WebGPU inside Godot.
  """

  details_title "web shaders are baked by the browser that runs them"

  prose ~S"""
  :: details Sources
  Written on 2026-10-13 from the operator's requests in one session, and
  from builds, exports and browser runs on the Mac mini. Chrome is
  Playwright's Chromium; Firefox is 157.0.1 with wgpu 29. The operator chose
  the browser bake over making the editor match the browser.
  :: details Why the editor bake misses
  The editor's shader baker now has a WebGPU target, and it compiles for the
  target's SPIR-V version instead of the editor's own driver. Still, a cold
  visit with the editor-baked pck took 11.5 seconds instead of 12.5. After
  that visit the browser had written 41 cache files, and 13 of them were not
  in the pck. Each cache file name holds a hash of the shader's compile
  inputs, and the editor's inputs differ from the browser's:
  - The web template is double precision and the editor is single, which
    adds a define to every 3D material shader.
  - The canvas and tonemap shaders get different variant lists on the web,
    because WebGPU has no point size and no subpasses.
  - The lightmap count comes from the device's texture limit, which is
    higher on Metal than on WebGPU.
  A cache file whose name does not match is ignored with no error. The
  engine commit is in the hash as well, so a template and an editor from
  different commits share no file at all.
  :: details Why the browser bake fits
  The browser runs the same engine binary that will read the cache, so
  every name matches by construction. Mods and dropped models mostly use
  StandardMaterial3D, whose shader is a function of its feature key and not
  of its textures, so a warm-up over the keys the glTF importer produces
  covers them too. The warm-up set is 29 materials: roughness channel,
  normal map, emission and alpha scissor in every combination, ambient
  occlusion and two-sided with alpha scissor and normal map, unshaded with
  and without culling and alpha scissor, and vertex colour.
  :: details Chrome and Firefox
  One warm-up run in each browser wrote 69 files, 8.5 MB, and the two sets
  are byte-identical. The cache holds WGSL and binding data, not a driver
  binary, so one bake serves both browsers.
  :: details Measured so far
  | Visit                         | Engine start | Sample shown |
  | ----------------------------- | ------------ | ------------ |
  | Cold, no bake                 | 4.2 s        | 12.4-12.6 s  |
  | Cold, editor bake             | 3.3 s        | 11.5-11.6 s  |
  | Repeat visit                  | 0.15 s       | 3.65 s       |

  A cold visit with the browser bake shipped is not measured yet. The
  repeat visit is its likely floor, and it is still 3.65 seconds on the Mac,
  so the 4 second limit also needs the guest build of the viewer to get
  faster and the downloads to get smaller.
  :: details Open
  - Ship the harvested cache in the pck and measure a cold visit in both
    browsers, then on a Quest.
  - Custom shaders that no warm-up predicts still convert on the first
    draw; the first frame should not wait for them.
  - The harvest prints the cache as hex console lines. A file written into
    the page's storage would be smaller and faster.
  - The pipeline must fail when the harvested cache does not match the
    template, rather than ship files that are ignored.

  This RFD was drafted by an AI and read by a human before it shipped.
  """
end
