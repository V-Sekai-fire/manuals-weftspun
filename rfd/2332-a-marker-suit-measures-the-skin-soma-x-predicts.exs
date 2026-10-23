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
  The workspace's capture suit is the ChArUco suit of the SOMA muscle-anatomy paper
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
  :: problem
  SOMA-X predicts pose-dependent surface correctives (RFD 2282), and nothing here measures
  where the skin goes, so the correctives have no target. A joint fit (RFD 2327) says nothing
  about the surface between joints.
  :: related
  - RFD 2282, the correctives this measures; RFD 2327, the joint keypoints the fit starts from.
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

  :: details Two projects named SOMA
  The workspace's SOMA is the body layer behind SOMA-X, the route to ANNY. The suit belongs to
  an unrelated muscle-anatomy paper of the same name. Nothing in this RFD changes the body
  layer; the suit only measures the surface it predicts.

  :: details The template as published
  - Markers come from `DICT_4X4_1000`: 4 by 4 bits inside a one-module black border, six
    modules across. At 22 mm a module is 3.67 mm, about half a pencil's width.
  - The page is 1500 by 2000 mm and fits 50 columns of 30 mm squares. The script places 3185
    squares, 1593 white ones carrying a marker, in those 50 columns.
  - Marker IDs run 0 to 1592 and wrap at 1000, so IDs 0 to 592 appear twice. A detection's
    identity comes from its neighbours' IDs (`refine_outlier_ids`, `resolve_conflicts`).
  - The canonical step detects markers on the unwrapped skin texture and fixes four wrong
    IDs by hand.
  - The paper's supplement reports 2310 markers on the suit. This RFD has not reconciled that
    count with the template's 1593.

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
  - The 2310 against 1593 marker count.

  :: details Markers lost at seams, and a pattern that recovers them
  A suit is cut into panels, so a marker across a seam does not decode. SOMA accepts the loss:
  each marker is read on its own, its corners give a skin point, and 120 cameras cover the gaps.
  The meshing pen's rendered suit (panels from the engine's xatlas) shows the same loss. At
  1.1 m the detector reads 15 of the 210 markers in view on Maro's side and 65 of 342 from the
  front. Every marker read is the one the UV map puts there; a mirrored image reads 2 right of 18.

  If 22 mm markers do not resolve at the desk's distance, the open fix is a pattern in which
  any small window is unique on the sheet (a perfect map, or De Bruijn torus), so a lost cell
  is recovered from its neighbours. Read at the marker level, the existing board already
  behaves this way: SOMA's `refine_outlier_ids` takes a detection's identity from its
  neighbours. A denser bit-level or multi-scale map would leave SOMA's detector and template,
  so it waits on the distance test, and would amend this RFD.
  """
end
