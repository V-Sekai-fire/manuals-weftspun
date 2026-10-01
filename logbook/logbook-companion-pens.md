# Companion pens: tracked through OpenVR, rendered through OpenXR

The operator, 2026-09-29: "I want more controllers, so you can draw when I draw". Companion
pens are extra tracked devices that draw alongside the player. They are real runtime devices,
not engine objects ("only real. no godot."). Measured on the headset and the Windows desk on
2026-09-29 and 2026-09-30.

## OpenXR shows roles, not devices

An `XRServer.get_trackers` dump in a live XR session listed only the action map's role paths:
`left_hand`, `right_hand`, `head` and the 12 body-part roles. It never listed the companions'
serials `vpen_0` to `vpen_3`. The operator's own body trackers hold the body-part roles, so a
companion cannot take one.

OpenVR enumerates all 64 device indices by serial. The pen therefore reads companions through
`V-Sekai-fire/godot_openvr` on `feat/frame-devices`, which merges the upstream device branches
#182, #183, #184 and #187.

## The driver

`frame-controller-sim` (`feat/tracker-companions-hidden`, `295740b`) registers 15 companions.
Each is a generic tracker with the handed tracker profile and the opt-out flag. The runtime
honours the opt-out only for tracker-class devices; registered as controllers, the companions
took the person's hand roles. `Prop_RenderModelName` is `{vpen}hidden`, a bundled zero-area
mesh, and the real model rides in `Prop_ModelNumber`.

Checked with its negative control: 15 of 15 companions fed live poses and opted out, the
compositor drew no companion mesh, and the two physical controllers kept the hands.

## Two blockers, neither in our code

| Blocker | Seen as | Consequence |
| --- | --- | --- |
| OpenVR rendering asserts under the compatibility layer on frame submit | `_wassert (!status, src-vrclient/vrcompositor_manual.c:2321)` and a modal that freezes the loop | the headset renders through OpenXR; OpenVR only tracks |
| The double build dereferences null in `get_float` and `is_button_pressed` for a controller with no action map | a crash on the first input read | an OpenVR action manifest comes first |

## State

The pen's companions are on `transport-meshing-pen` `feat/companion-pens` (`6e0a9e7`). A
switch that hands the hand roles to two companion controllers and back is designed, not built.
