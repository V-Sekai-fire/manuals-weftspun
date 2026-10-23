# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2332, "A marker suit measures the skin SOMA-X predicts", :discussion do
  flight_level :l1

  feature "a printed fiducial suit whose tracked marker corners give a measured skin surface to
hold SOMA-X's pose correctives against"

  scope "the suit's print template, its fabric and print, the marker tracking code, and the
registration of tracked corners to an ANNY fit"

  prose ~S"""
  :: decision
  The workspace's capture suit is the ChArUco suit of SOMA-2606.09246, the muscle-anatomy paper
  (Alvarado et al., ECCV 2026), made from its MIT code's template: `DICT_4X4_1000` markers
  22 mm wide, about a nickel, centred in 30 mm squares, 1593 markers on a 150 by 200 cm
  sheet, dye-sublimated at 300 DPI onto stretch matte fabric. Its multi-view captures are
  tracked with that code's detect, triangulate and clean stages. The tracked corners are
  registered to an ANNY fit rather than the paper's own scanned templates, and the residual
  against ANNY with SOMA-X's correctives is the measurement.
  - The template is generated from the detector's own board object, 49 squares by 65, with
    every marker drawn as vector modules.
  - The paper's SKIM captures are not used until their terms are read.
  - The allowlist names the code, read and run only (operator, 2026-10-22).
  - Each project named SOMA is written by its arXiv number, never as a bare SOMA: SOMA-2603.16858
    is the body layer, SOMA-2606.09246 the muscle paper (operator, 2026-10-25).
  - The muscles under the measured skin come from MS-Human-700 in MuJoCo (operator, 2026-10-25).
  :: problem
  SOMA-X predicts pose-dependent surface correctives (RFD66606-2282), and nothing here measures
  where the skin goes, so the correctives have no target. A joint fit (RFD66606-2327) says nothing
  about the surface between joints.
  :: related
  - RFD66606-2282, the correctives this measures; RFD66606-2327, the joint keypoints the fit
    starts from.
  """

  details_title "A marker suit measures the skin SOMA-X predicts"

  prose ~S"""
  :: details Sources
  - Alvarado, Kim, Nolte, Runte, Botsch, Habermann and Theobalt, SOMA: From Surface
    Observations to Muscle Anatomy, ECCV 2026, arXiv 2606.09246. Code MIT, at
    `edualvarado/SOMA`, read on 2026-10-22.
  - Its suit parameters are in `01-Suit-Processing/configs/suits/charuco-suit.json` and
    `suit-manufacturing/charuco-suit/create-charuco-template.py`; the detector's board is in
    `caliboards/suit/suit.py`.

  :: details Two projects named SOMA, and their identifiers
  Two unrelated projects carry the name SOMA. Each has one globally unique text identifier,
  built from its arXiv number, and RFDs write that identifier instead of the bare name.
  - `SOMA-2603.16858`: NVIDIA's body layer (arXiv 2603.16858). SOMA-X is its code, the route
    to ANNY; Kimodo-SOMA is the text-to-motion model that emits its pose. A pose, joint or rig
    called SOMA anywhere in the corpus is this one.
  - `SOMA-2606.09246`: SOMA: From Surface Observations to Muscle Anatomy (Alvarado et al., ECCV
    2026, arXiv 2606.09246). It recovers muscles from a ChArUco marker suit; this RFD takes its
    suit and its tracking code. It shares nothing with the body layer.
  Code and names that upstream wrote stay as written: `rig="soma"`, `SOMA_wrap.obj`, the
  repository and package names.

  :: details The muscle model
  The paper recovers muscle anatomy, and the workspace had no musculoskeletal body to recover it
  into. MS-Human-700 is that body (operator, 2026-10-25): a whole-body model in MuJoCo XML,
  Apache-2.0, with 700 muscle-tendon units on 90 bodies and 206 joints. MuJoCo is the workspace's
  simulator for it. The tracked skin fixes the surface, ANNY with SOMA-X's correctives places the
  bones, and the muscle activations are solved in MS-Human-700.

  :: details From a SOMA-2603.16858 pose to muscle activations
  SOMA-X gives kinematics only: joint rotations and a root translation for 77 joints.
  MS-Human-700 is a forward-dynamics model; muscle activations from its 700 muscle-tendon units
  make the joint torques, and the torques move the skeleton. The path between them has three
  steps.
  1. **Retarget.** Map the 77 SOMA-2603.16858 joints to MS-Human-700's joint degrees of freedom.
     NVIDIA's SOMA retargeter maps the same output to a humanoid robot's tree; adapt it by
     swapping that tree for MS-Human-700's.
  2. **Inverse kinematics in MuJoCo.** Solve the retargeted motion in MS-Human-700 so each pose
     obeys its joint limits and coordinate frames.
  3. **Muscle activations.** The model moves by muscles, not joint motors, so joint angles cannot
     drive it directly. Inverse dynamics gives the joint torques for the solved motion; an
     optimiser, or one of the model's published neural controllers, then picks which of the 700
     muscles fire to make them (the muscle redundancy problem). This is the hardest step.

  :: details The template as published
  - Markers come from `DICT_4X4_1000`: 4 by 4 bits inside a one-module black border, six
    modules across. At 22 mm a module is 3.67 mm, about half a pencil's width.
  - The page is 1500 by 2000 mm and fits 50 columns of 30 mm squares. The script places 3185
    squares, 1593 white ones carrying a marker, in those 50 columns.
  - Marker IDs run 0 to 1592 and wrap at 1000, so IDs 0 to 592 appear twice. A detection's
    identity comes from its neighbours' IDs (`refine_outlier_ids`, `resolve_conflicts`).
  - The canonical step detects markers on the unwrapped skin texture and fixes four wrong
    IDs by hand.
  - The paper's supplement reports 2310 markers on the suit, with IDs used at most twice and
    told apart by an instance index. The template's 1593 is a smaller layout of the same scheme.

  :: details What the template gets wrong
  The script renders each marker as a 22-pixel image and stretches it to 22 mm. Six modules
  do not divide 22 pixels, so OpenCV 4.10's marker image gives modules 4, 4, 3, 4, 4 and 3
  pixels wide, which print as 4 and 3 mm against 3.67 mm. An inner edge sits up to 0.67 mm
  off, a little under a credit card's thickness. The outer corners, which the tracker
  triangulates, stay where they belong; the bit sampling inside each cell loses margin.
  Control: a 24-pixel and a 30-pixel marker give 4 and 5 pixels a module, equal throughout.
  Drawing each module as a vector rectangle removes the rounding at any print resolution.

  The detector declares a ChArUco board of 49 squares by 65, which OpenCV builds with IDs 0
  to 1591. The template lays the same IDs out 50 columns wide, so a marker's printed
  neighbours are not the board's. Generating the template from the detector's board makes
  the two agree by construction.

  :: details Fabric and print
  The paper names stretchable matte fabric, tight on the skin, to cut specular reflection.
  The template script states dye-sublimation, 300 DPI, 150 cm width, for wearers up to 200 cm
  tall. The fabric's stretch at the joints moves each square; the triangulated corners are
  where the skin is, and the template position is only the marker's identity.

  :: details Registration to ANNY
  The tracked corners are fitted with an ANNY body posed from the joint keypoints, then
  SOMA-X's correctives are applied at that pose. Per corner, the distance to the corrected
  surface is the residual, reported in millimetres with its household equivalent. The floor
  is the same residual with the correctives off.

  :: details What is not known
  - How many calibrated cameras the desk can field; the paper captures with 120.
  - The SKIM data's licence: it is a separate download, and its terms are not read.
  - Whether 22 mm markers resolve at the desk's camera distance and resolution.

  :: details Markers lost at seams, and a pattern that recovers them
  A suit is cut into panels, so a marker across a seam does not decode. SOMA accepts the loss:
  each marker is read on its own, its corners give a skin point, and 120 cameras cover the gaps.
  The meshing pen's rendered suit (panels from the engine's xatlas) shows the same loss. At
  1.1 m the detector reads 15 of the 210 markers in view on Maro's side and 65 of 342 from the
  front. Every marker read is the one the UV map puts there; a mirrored image reads 2 right of 18.

  The print keeps SOMA's board as it is, so SOMA's detector reads it unchanged, and adds
  two coarser position levels on top. Each 60 mm and 120 mm cell carries one bit of a perfect
  map (every 4 by 4 window unique on the sheet) as a shift in the level of its squares. On a
  flat sheet with OpenCV's full ChArUco detector, the board reads the same markers and
  corners with the levels as without them, and the levels still place a window at a pixel per
  square, where no marker decodes.

  On the bodies the levels do not yet carry. From a lighthouse stand (1080p, 90 degree lens,
  3 m out) no marker decodes even in a clean render; the levels place 5% of the visible
  squares clean and none once the frame is degraded as a cheap 60 or 120 fps camera. A 240 mm
  window is larger than most panels. The meshing pen's `suit-sim` records these frames with
  their truth renders, and the cell size and level strength are open until it improves on them.
  """
end
