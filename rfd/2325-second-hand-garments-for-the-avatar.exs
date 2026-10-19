# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2325, "second-hand garments for the avatar", :discussion do
  flight_level :l1
  feature "a photographed second-hand garment becomes a garment ANNY wears"
  scope "the second-hand fashion dataset, interactor-drape, interactor-garment-fit and EditScore"

  prose ~S"""
  :: decision
  Each garment in the second-hand fashion dataset becomes a garment on ANNY
  (the reference rig), made two ways and compared. The draft route traces
  the flat-lay photo at the tape's scale into front and back pattern
  pieces, sews them and drapes them on the GPU. The mesh route makes a mesh
  from the photo with TRELLIS.2 or Pixal3D and fits it onto the body. A try
  passes when the drape gates pass and EditScore rates the render against
  the photo above a bar. Frontier learning picks which garments to practise
  and keeps a change to the drafting rules only when the pass rate rises.
  Rung 1 is ten garments from the eval split (operator, 2026-10-19).
  :: problem
  The avatar has no wardrobe. The dataset holds 32,036 real garments, each
  photographed flat, front and back, with a size, a type and a cut. Nothing
  turns a photo into a garment.
  :: references
  - Nauman et al., Second-Hand Fashion Dataset (doi 10.5281/zenodo.13788681), CC-BY-4.0
  - Faro et al., Frontier Learning (doi 10.48550/arXiv.2609.35426)
  - Luo et al., EditScore (doi 10.48550/arXiv.2509.23909)
  :: related
  - RFD 2309 (frontier learning, Alyx planner): levels and regret.
  """

  details_title "second-hand garments for the avatar"

  prose ~S"""
  :: details Where the request came from
  The operator requested it on 2026-10-19: use frontier learning to
  recreate the second-hand garments as avatar garments, with the stack we
  have. The operator chose ANNY with sizes from the labels, both routes
  compared, EditScore plus the drape gates as the score, and this RFD
  before ten garments.

  :: details The source
  The Zenodo record repacked as parquet, one row per garment: a front
  photo, a back photo, type, cut, size, pattern, colours and material.
  Each photo is 1280 by 720, top down, on a table marked with a measuring
  tape, and the garment lies on its side with the collar to the right.
  - train: 28,474 garments, the source for practice.
  - eval: 298 gold garments, for rung 1 and for looking at.
  - test: 3,164 garments, blinded. Never read, never used to pick a rule.

  Eval is 295 women's garments, almost all upper body: top 95, T-shirt 37,
  cardigan 33, sweater 31, tank top 21, blouse 21, shirt 20, dress 18.
  Sizes: M 64, L 54, S 53, none 49, and EU numbers for the rest.

  :: details Levels and problems
  A level is a type, a cut and a size band, for example T-shirt, C-collar,
  M. A problem is one garment of that level. Regret is one when any of the
  last eight tries passed, minus the pass rate. Levels at zero regret are
  not practised: mastered ones run at tag, impossible ones are a defect to
  fix. A step changes one drafting rule for one level, for example how far
  the sleeve cap sits below the shoulder line. The change is kept only when
  the level's pass rate rises and no other level's rate falls.

  :: details The two routes
  - Draft: segment the garment from the table, read the tape for scale,
    rotate collar up, split the outline into body, sleeves and collar,
    mirror front onto back where the back photo agrees, sew the side and
    shoulder seams, and drape with interactor-drape's AVBD kernels and IPC
    contact, emitted from Lean. Texture comes from the photo, through the
    Slug pipeline.
  - Mesh: TRELLIS.2 or Pixal3D on the front and back photos, then
    interactor-garment-fit moves it onto the body.

  Both end as OpenUSD with materials, then glTF for the avatar.

  :: details The body
  ANNY, posed in A-pose, with its girths set from the size: bust, waist
  and hip from a standard EU size chart for S, M, L and the numbers. A
  garment with no size gets M. The body is made a closed solid before any
  gate reads it.

  :: details The score
  - Gates, all required: no cloth inside the body on any frame, seam gap
    p99 under 2 mm (about one penny), strain p99 under 10 percent, drift
    under 1 mm per half second at the end.
  - EditScore: the front photo is the source, the instruction is "dress
    the avatar in this garment", and the front render is the result. The
    pass bar is set on rung 1 and then frozen.

  :: details What rung 1 has measured
  Ten eval garments, all from one collection station: two tops, a shirt, a
  cardigan, a dress, two T-shirts, a tank top, a sweater and a blouse. The
  tape's scale moves between photo sessions at the same station: about 7.6
  px per cm on one layout and 8.3 px per cm on another, so scale is read
  per photo. Reading the tape's 10 cm marks found the scale on 5 of the 10
  garments and failed on the other 5, where the tape is partly hidden or
  the marks are faint.

  :: details What is not known
  - Whether EditScore ranks a render against a flat-lay photo at all. It
    was trained on image edits. Gate 2 settles it.
  - How well the tape reads. A wrong scale shows as a garment that is a
    size off on a body of the labelled size.
  - Which route wins for which type. That is the result, not an input.

  :: details Gates and controls
  1. Drape gates: the existing gates on each try. Control: a planted
     vertex 5 mm inside the body FAILs.
  2. The scorer can tell: each garment's render scores above the same
     render paired with another garment's photo. Control: a swapped pair
     that scores higher FAILs the scorer, and it is not used.
  3. The learner keeps only gains: a planted change that lowers a level's
     pass rate is rejected by name.
  4. The holdout stays shut: no read of the test split in the run log.
     Control: a planted read FAILs.

  A gate that passes with its control also passing counts as a FAIL.

  :: details Rung 1
  Ten eval garments, at most two per type, both routes each. Report per
  garment: gates, EditScore, wall time, and a render beside the photo. The
  result sets the pass bar and the first rules to tune.
  """
end
