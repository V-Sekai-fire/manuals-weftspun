# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2313, "the full loop over colour passthrough", :discussion do
  flight_level :l2
  feature "draw on the dummy, dress the avatar, and see both stand in the real room over colour
passthrough"
  scope "the pen's AR mode on OXRSys, the walking scan, anchors in the shape of the OpenXR
spatial anchor and persistence extensions, capsule shadows and table occlusion"

  prose ~S"""
  :: decision
  The whole loop runs in AR. The person draws on the dummy, the avatar wears
  the garment, and both stand in the real room over the colour passthrough.
  The walking scan finds the floor and the table. The committed surfaces are
  kept as anchors in the shape of the OpenXR spatial anchor and persistence
  extensions. Capsule shadows ground the avatar and the dummy, and the table
  top hides what is behind it. Gates run sim-to-real in path-traced rooms
  first. This RFD joins no rung yet.
  :: problem
  A colour-passthrough recording of an anime character standing on a store
  floor shows the effect people want: the character is in the room, not on
  a screen. The pen already draws, meshes and dresses. It has never run over
  passthrough, and nothing in it knows where the real floor and table are.
  :: related
  - RFD 2262, make it with the pen and wear it together; RFD 2287, the first
    rung in a headset, which this RFD carries into the real room.
  - RFD 1108, the abandoned floor anchor in AR and VR; RFD 1171, MoGe in the
    presence loop.
  - RFD 2303, the XR requirements checklist the loop still answers to.
  """

  details_title "the full loop over colour passthrough"

  prose ~S"""
  :: details Sources
  Drafted on 2026-10-13 from six choices the operator made one at a time:
  the full loop in AR, the walking scan, persistence in the shape of the
  anchor extensions name for name, capsule shadows with table occlusion,
  sim-to-real first, and parking it outside any rung. The measurements below
  come from the walking-scan spike on dev seeds and from a MoGe-3 run on four
  frames of a public colour-passthrough recording, both taken on the Mac.
  :: details What already exists
  - OXRSys accepts the alpha blend mode with `passthrough_enabled`. The
    headset blends the camera image and the app sends only its own layer,
    with alpha.
  - Without root, the headset's runtime publishes one colour view as a
    loopback camera. It advertises 1920x1080 at 30 fps and measured 1.4 to
    3.8 fps.
  - MoGe-3 (MIT code; weights MIT per their model card) runs on the Mac GPU
    without its sparse refiner, about 1.2 s per 960 px frame. Its dense graph
    is 1,406 nodes. ggml-rd lacks replicate padding and one antialiased
    resize.
  :: details The surface: the walking scan
  The person looks at the set-down point while swaying or walking about a
  quarter turn, and nine frames are kept. The tracked camera poses fix the
  metric scale: features matched between frames are triangulated with the
  tracked projection matrices. A correction in log depth fits MoGe-3 to those
  points. Gravity is known, so a plane sweep tests level heights 1 mm apart
  within 15 cm of the corrected estimate, and each frame votes for one
  height. The floor and the table commit only when at least 5 votes agree
  within 1 cm. Otherwise the controller touches down. Refusals are counted
  apart from misses. With 8 of 8 votes agreeing, the sweep missed by -0.05
  to +0.26 cm on 11 dev seeds. That result is dev-stage and not
  pre-registered.

  A single MoGe-3 frame cannot tell a floor from a ceiling: on 4 frames of
  the recording, an upside-down copy of each frame still fit a level plane.
  Up comes from tracking, never from the image.
  :: details Persistence: anchors in the shape of the extensions
  Placement takes the shape of `XR_EXT_spatial_anchor` with
  `XR_EXT_spatial_persistence` and `XR_EXT_spatial_persistence_operations`
  as Godot's bundled OpenXR headers define them, each at spec version 1. The
  names, fields and states are the extensions' own. OXRSys implements none
  of the three today, so a FoundationDB-backed SQLite store holds the
  anchors behind that shape. When a runtime offers the extensions, the same
  calls go to it and the store stops holding poses.

  - Three anchors: the floor, the table top and the set-down point. Each is
    made from an `XrSpatialAnchorCreateInfoEXT`: `baseSpace`, `time` and
    `pose`, the committed plane's pose at the time the sweep committed.
    `xrCreateSpatialAnchorEXT` returns an `XrSpatialEntityIdEXT`.
  - An anchor reads back as `XR_SPATIAL_COMPONENT_TYPE_ANCHOR_EXT`, an
    `XrSpatialComponentAnchorListEXT` of `XrPosef` locations.
  - Persisting runs `xrPersistSpatialEntityAsyncEXT` with an
    `XrSpatialEntityPersistInfoEXT` in a persistence context of scope
    `XR_SPATIAL_PERSISTENCE_SCOPE_LOCAL_ANCHORS_EXT`. The completion,
    `XrPersistSpatialEntityCompletionEXT`, carries the `persistUuid`
    (`XrUuid`, 16 bytes). The store keys each anchor by that UUID.
  - A new session discovers the anchors with an
    `XrSpatialDiscoveryPersistenceUuidFilterEXT` over the saved UUIDs. Each
    answers `XR_SPATIAL_PERSISTENCE_STATE_LOADED_EXT` or
    `XR_SPATIAL_PERSISTENCE_STATE_NOT_FOUND_EXT`.
  - NOT_FOUND on any of the three asks for a new walking scan. Before a
    runtime holds the anchors, a reference-space change (a recentre) makes
    the store answer NOT_FOUND, and so does a new room.
  - Moving the set-down point runs `xrUnpersistSpatialEntityAsyncEXT` on the
    old anchor before the new one persists.
  :: details Grounding: capsule shadows and table occlusion
  The colour camera reaches the app at a few frames a second, so moving
  people in the room cannot hide the avatar. Only the static surfaces the
  scan committed are used.

  - Capsule shadows. Each of the avatar's bones and the dummy's stand
    carries a capsule. The capsules cast soft shadows, computed analytically,
    onto the committed floor and table. The shadow is drawn as darkening
    only, on a shadow-catcher surface that is otherwise transparent. This is
    the published occluder-proxy method: sphere sets with spherical-harmonic
    exponentiation (Ren et al., SIGGRAPH 2006), ellipsoid occluders for
    character soft shadows and ambient occlusion (Iwanicki, SIGGRAPH 2013
    course), and the capsule shadows shipped in commercial engines since. No
    shadow map is needed.
  - Table occlusion. The committed table top is a depth-only surface that
    writes zero alpha. What lies behind it, such as the avatar's legs, shows
    the real table through the passthrough.
  :: details Testing: sim-to-real first
  The gates run on path-traced rooms built from CC0 scanned furniture,
  through OXRSys in the alpha blend mode. The held-out rooms are frozen
  before they render. The station set is separate, because MoGe-3 is
  unproven on stylized frames. A real room comes after the gates pass, and
  only then.
  :: details Gates and controls
  1. Surface: on the held-out rooms, every committed floor and table height
     is within 3 cm of truth, about the width of a golf ball. Refusals are
     counted apart. Controls: a frame of a bare wall refuses, and
     `GGML_RD_FAULT=1` fails the fit.
  2. Anchors: a restored session discovers all three anchors by UUID as
     LOADED and places the dummy at the saved pose within 1 mm, about the
     thickness of a credit card. Every name and field the code uses matches
     the bundled `openxr.h`. Controls: a planted recentre event answers
     NOT_FOUND and forces a new scan; an unknown UUID answers NOT_FOUND; a
     field renamed away from the header fails by name.
  3. Occlusion: with the avatar standing behind the table, no pixel of it
     below the table top has alpha above zero in the app layer. Control: the
     occluder turned off fails by pixel count.
  4. Capsule shadow: the floor under each of the avatar's feet is darker
     than the floor one metre away. Control: the capsules removed fail.
  5. The loop: the pen draws on the dummy and the avatar wears the garment
     over passthrough, and the pen's mesh and inside-the-body gates still
     pass.
  6. Licence: the MoGe-3 weights' licence is confirmed from its primary
     source before any artifact carries them. Control: a planted unlicensed
     weight file fails by path.
  :: details Open
  - The ggml-rd port of MoGe-3: replicate padding and the antialiased
    resize.
  - Two steps of MoGe-3's pre- and post-processing still run on the CPU.
  - The walking scan's pre-registration.
  - Which rung claims this RFD.
  """
end
