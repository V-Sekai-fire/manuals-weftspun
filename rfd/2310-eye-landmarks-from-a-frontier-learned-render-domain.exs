# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2310, "eye landmarks from a frontier-learned render domain", :discussion do
  flight_level :l1
  feature "an RF-DETR keypoint head finds each eye's lids, iris and pupil in the
headset's infrared frames, trained on constructed renders and Bonsai-scored real frames
that frontier learning picks over a compressed RECTGTN domain"
  scope "frameeyeosc's eye-camera rung, ANNY and SOMA-X renders on the shared Windows
desk, Ternary Bonsai 2 as decider and scorer, the RECTGTN domain and `compress`"

  prose ~S"""
  :: decision
  An RF-DETR keypoint head places 34 landmarks per eye, each with a
  visibility: 9 on each lid, 8 on the whole iris and 8 on the pupil rim.
  frameeyeosc turns them into openness, widening, squint and pupil size
  (RFD 2271). Training data is constructed ANNY eye renders with
  eyelashes, varied through SOMA-X by ANNY phenotypes, HMR identities and
  GMR motion, plus Gaze-in-Wild infrared frames picked and scored by
  Ternary Bonsai 2 (2-bit), first pretrained as a scorer on EditScore's
  reward corpus. Rows take
  EditScore's shape (RFD 2309). The pipeline is a RECTGTN domain whose
  actions and methods are residual FSQ codes; frontier learning picks the
  levels and `compress` learns new methods from the traces (operator,
  2026-10-12).
  :: problem
  No labelled infrared eye dataset can be remixed: OpenEDS and LPW are
  non-commercial, and TEyeD states no licence. The community fork's eye
  vision is about ten thousand lines of rules tuned on its own recordings.
  :: related
  RFD 2271, 2309, 2304, 2203, 2192, 2272, 2290, 2161, 2178, 2295.
  """

  details_title "eye landmarks from a frontier-learned render domain"

  prose ~S"""
  :: details Data and licences
  | Source | Role | Licence | Labels |
  |---|---|---|---|
  | ANNY eye renders, lashes on | training | Apache-2.0 | constructed |
  | SOMA-X identities from HMR fits | identity variation | Apache-2.0 | constructed |
  | GMR and Kimodo-SOMA motion | blink and gaze timing | Apache-2.0 | constructed |
  | Gaze-in-Wild infrared frames | real training frames | MIT | generated |
  | Headset recordings | held-out test | ours | real |
  | OpenEDS, LPW, TEyeD | excluded | NC or none | |

  The renders use ANNY's eye and eyelash helpers, its procedural eyes and
  its face units, on MakeHuman assets. The HMR fits come from
  licence-filtered COCO photos, each image keeping its own licence. The
  Gaze-in-Wild authors publish their 608,486 frames under MIT, and their
  labels here are Bonsai 2's picks.

  Decider picks are a teacher's predictions, so CLAUDE.md's four conditions
  for generated data hold: model, checkpoint and prompt recorded with each
  row; a separate manifest; never the only distribution; evaluation on real
  or constructed data only. Training starts from Apache-designated RF-DETR
  weights, not the separately hosted keypoint preview (RFD 2192).

  :: details References
  - Faro et al., Frontier Learning (doi 10.48550/arXiv.2609.35426)
  - Mentzer et al., Finite Scalar Quantization (doi 10.48550/arXiv.2309.15505)
  - Zhu et al., Robust Residual FSQ (doi 10.48550/arXiv.2508.15860)
  - Grand et al., LILO (doi 10.48550/arXiv.2310.19791)
  - Kothari et al., Gaze-in-wild (doi 10.1038/s41598-020-59251-5)
  - Luo et al., EditScore (doi 10.48550/arXiv.2509.23909)

  :: details Eyelashes
  Every render carries eyelashes; a lashless eye is not a training
  render. ANNY's MakeHuman base mesh has eyelash helpers on both lids of
  each eye, which move with the lids through blinks, widening and squints.
  They render as cards with an alpha mask, varied in length, density,
  curl, thickness and darkness under infrared light (mascara is dark
  there). The lid landmarks stay on the lid margin under the lashes, so
  lashes are occluders the head must see through, not landmarks; a point
  whose margin a lash hides keeps its position and drops its visibility.
  ANNY's SOMA topology drops unattached vertices, so the lash helpers are
  carried across by their lid attachment, checked at R0.

  :: details Bonsai 2 as scorer
  The scorer is Ternary Bonsai 2 27B at 2 bits, served by NInfer on the
  desk's RTX 4090; the EditScore model itself is not used. Before any eye
  row it is pretrained as a reward model on EditScore-Reward-Data (97,256
  rows, Apache-2.0: task type, instruction, images, two expected scores,
  an evaluator conversation) with a quantization-aware LoRA (RFD 2178), and
  measured on EditReward-Bench against the scores the EditScore authors
  published. Eye rows then use the same shape: the instruction names the
  landmarks, the images are the frame and the frame with a candidate fit
  drawn on it, and the expected scores are constructed from geometry for
  renders and from hand checks for real frames.

  :: details Decider labelling
  A model trained on constructed renders proposes up to three candidate
  fits for a Gaze-in-Wild frame. Bonsai 2 sees the frame with the
  candidates drawn on it and the bare options `(A)`, `(B)`, `(C)` and
  `(D) none fits`, and answers one letter at temperature 0, reasoning off,
  two tokens at most: no hint, distance or score in the prompt (the decider
  games' rule). A frame whose pick is `(D)` goes to a person. Gate: a
  hand-checked sample of picks, with a planted control of three wrong
  candidates that must come back `(D)`.

  :: details The RECTGTN domain
  The pipeline is a `plan` domain in XR Pilot's JSON acting DSL, run by the
  one RECTGTN library (RFD 2304). Actions are tool calls with constructed
  outcomes:
  | Action | Does |
  |---|---|
  | `render_eye(code, seed)` | one Blender render of one eye |
  | `project_labels(render)` | the 34 landmarks and visibility from geometry |
  | `infer(checkpoint, image)` | the keypoint head's landmarks |
  | `score(pred, truth)` | success: every visible point within 0.05 iris diameters |
  | `decide(frame, candidates)` | one Bonsai 2 letter |
  | `finetune(checkpoint, batch)` | one training step |
  Methods group them: a level's problem renders, labels, infers and scores;
  a frontier step samples levels, plays their problems and keeps a
  checkpoint only when frontier success rises and the held-out headset set
  does not fall. Every call is traced, and `compress` learns new methods
  from the traces by anti-unification under minimum description length, as
  it does for the Alyx planner. The rewritten traces must expand back to
  the recording exactly; Bonsai 2's method names are generated text in
  their own column.

  :: details Actions and methods as residual FSQ codes
  The eye state is a vector: each eye's openness, widening and squint, gaze
  x and y, pupil and iris size, eyelash length, density and curl, camera
  offset and identity coordinates.
  Residual FSQ quantizes it in stages. The first stage's digits are a
  level's discrete attributes, so a level is one code and the paper's
  one-attribute mutation is one digit moved by one; later stages are the
  continuous detail a problem draws within the level. `render_eye` takes the
  code, so an action is a codebook item, and a method that `compress`
  learns is a sequence of codes whose varying digits become its parameters.
  Each FSQ dimension with 2^b levels packs into b bits, which is the form
  frameeyeosc already sends for an avatar's binary parameters.

  :: details Frontier learning here
  RFD 2309's loop with one change: the policy is the keypoint head's
  weights, not a frozen domain. Success `s` counts the passing renders of a
  problem's `n` noise draws; regret `1[s ≥ 1] − s/n` is zero for impossible
  and mastered problems. Level draws, replay, exploration and mutation keep
  the paper's values until a step's measured cost says otherwise. Renders
  are procedural, which removes the limit RFD 2309 states for Alyx;
  Gaze-in-Wild frames have no level, so they are a fixed real mix, and the
  frames whose candidates disagree most go to the decider first.

  :: details Rungs
  | Rung | Work | Gate and control |
  |---|---|---|
  | S | Bonsai 2 pretrained as a scorer | EditReward-Bench agreement |
  | R0 | one ANNY eye render, lashes on | looked at, with landmarks drawn |
  | R1 | the generator over FSQ codes | same seed, same bytes |
  | R2 | decider labels for Gaze-in-Wild | a hand-checked audit sample |
  | R3 | frontier training and `compress` | held-out headset frames |
  | R4 | inference on the headset | latency inside a 90 Hz frame pair |

  Each gate has a control that must fail: S on shuffled scores; R0 with a
  landmark moved off the mesh, and with the lashes removed; R1 with a
  changed seed; R2 with three planted wrong candidates, which must come
  back `(D)`; R3 on a checkpoint that skips the frontier step.

  :: details Where it runs
  The shared Windows desk renders and trains on the RTX 3090, whose llama
  server was stopped for it (operator, 2026-10-12). The RTX 4090 keeps
  NInfer's Bonsai 2 on localhost, so decider jobs run on the desk. Every
  job is a named scheduled task with a fixed log and a done file, after a
  headroom check. Corpora are private datasets in ETNF parquet, constructed
  and generated in separate manifests.

  :: details Open questions
  - Inference home: frameeyeosc's own Slang kernels, or a ggml-rd guest as
    RFD 2272 and RFD 2290 require. Unmeasured; R4's latency decides.
  - The headset camera's intrinsics and light positions, to be measured
    from recordings before R1's camera is trusted.
  - A render's cost on the 3090, which sizes a frontier step.
  - Whether Bonsai 2 tells candidates apart at 400 by 400; likely (about
    0.6), unmeasured until R2's audit.
  - Whether the served Bonsai 2 build takes images at all; the decider
    games ran it with vision on, so likely (about 0.7), unchecked here.
  - Whether a quantization-aware LoRA on a 27B ternary model fits the
    3090's 24 GB beside the renders; unmeasured, so the renders and the
    scorer's training run one at a time.
  """
end
