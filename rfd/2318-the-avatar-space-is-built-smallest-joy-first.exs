# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2318, "the avatar Space is built smallest joy first", :discussion do
  flight_level :l2
  feature "a static Space where a visitor drops a model, sees it move and takes it home, grown
one visitor-visible step at a time up to a shared room"
  scope "the build order of the avatar Space: a pre-made dance, live rigging, text-to-motion and
the shared room, and the engine build each step needs"

  prose ~S"""
  :: decision
  - The avatar Space ships in four steps, each one a thing a visitor can do
    (operator, 2026-10-13).
  - Step one: drop a model, play a pre-made dance on it, download it. It
    is built mostly from pieces the workspace holds.
  - Step two: rig the dropped model live with SkinTokens, once GPU guests run
    in the browser.
  - Step three: make motion from text with Kimodo.
  - Step four: the shared room, where visitors see each other's characters
    move. It unparks RFD66606-2317.
  :: problem
  The shared room is the step with the most unknowns: a WebTransport client in
  the web export, a server, a Bao engine, Fly networking and sign-in. A
  blocker audit of it on 2026-10-13 found work in all of them but sign-in.
  Building it first would put weeks between a visitor and anything they can
  do. The earlier steps each give a visitor something to keep, and each one
  builds and proves a piece the room reuses.
  :: related
  - RFD66606-2317, a browser joins a WebTransport server with a Bao ticket.
  - RFD66606-2314, the SkinTokens Space viewer runs as sandbox guests.
  - RFD66606-2315, web shaders are baked by the browser that runs them.
  - RFD66606-1046, SkinTokens; RFD66606-1045, Kimodo text-to-motion.
  """

  details_title "the avatar Space is built smallest joy first"

  prose ~S"""
  :: details Sources
  Written on 2026-10-13 from the operator's build order, given in one session
  after a blocker audit of the shared room. The audit read the code of our
  entities-godot fork's http3 module, the godot-sandbox module, the assembly
  recipe, the Bao listener settings and Fly's UDP documentation. Nothing in
  it was built or run in a browser.
  :: details Step one: drop, dance, download
  The visitor drops a model, picks a dance, watches it play and downloads
  the result as glTF.
  - The viewer is RFD66606-2314's: Model Explorer in a web export, every script a
    sandbox guest.
  - The dance must be one the workspace may ship. The pose-source rule in
    the working agreements forbids shipping targeted third-party motion in a
    deliverable, and a downloaded file is a deliverable. The dance therefore
    comes from ANNY or SOMA's own pose library or is authored here. Which
    one is chosen in this step.
  - The model must already carry a humanoid skeleton. A model without one
    waits for step two.
  - Gate: a dropped humanoid model plays the dance and the downloaded file
    plays the same clip in a second glTF viewer. Control: a downloaded file
    with the animation stripped must fail that check.
  :: details Step two: live rigging
  The visitor drops an unrigged model and the Space rigs it with SkinTokens.
  - It waits on GPU guests in the browser. The first cartridge check, on the
    threaded dlink web template, stops inside the first `Sandbox.load_buffer`
    with no error, and that stop is not yet located.
  - The rig writes no humanoid joint map yet: the auto-rig service's joint-map
    write raises `NotImplementedError`. Step one's dances need that map to
    play on a rigged model.
  :: details Step three: text-to-motion
  The visitor types a motion and Kimodo makes it. Kimodo's motion guest is a
  sandbox guest like the rigging one, so it waits on the same GPU guests.
  :: details Step four: the shared room
  RFD66606-2317's flow, with avatars in place of its text board. The audit's
  blockers, each read in code:
  - The web client never receives: the web backend declares
    `godot_wt_recv_datagram` and nothing calls it.
  - The browser glue opens `new WebTransport(url)` with no options, so a
    pinned certificate hash never reaches the browser, and its datagram loop
    takes a new reader on a stream the first reader still holds.
  - Reliable sends on the web return `ERR_UNAVAILABLE`, and RFD66606-2317 sends
    the ticket on a stream.
  - A client picks a random peer id while the server numbers sessions from
    two, and a client only hears of the server.
  - Godot's TLS client options carry no client certificate, and the Bao
    listener requires one, so the room server reaches Bao through a sidecar.
  - No Ed25519 verify was found in the engine's mbedTLS; RFD66606-2317's ticket
    signature is to be settled before the server is written.
  - Avatars use the fabric zone's pose layout (a root and up to 55 humanoid
    bones), so every avatar in the room carries a humanoid map.
  - Fly takes UDP only on a dedicated IPv4 address, bound to
    `fly-global-services` on the external port.
  The server side of the http3 module already listens: `create_server` runs
  picoquic on its own thread with server-only TLS.
  :: details The engine build
  Every step runs one web export, assembled with git-assembler (RFD66606-2243)
  from the http3, sandbox, platform-web, double-precision and WebGPU
  branches of our entities-godot fork. A local trial assembly of those five
  merged with no conflict. The WebGPU branch is not yet a line in the
  recipe.
  - The sandbox module there is a hand port of the extension as it stood in
    August 2025, and it no longer compiles against the fork's
    `ScriptLanguage`. It is being replaced by the extension's own sources,
    compiled into the engine and loaded through
    `GDExtensionManager.load_extension_from_function`, so the extension and
    the module become one tree.
  """
end
