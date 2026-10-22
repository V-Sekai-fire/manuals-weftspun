# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2309, "frontier learning for the alyx planner", :discussion do
  flight_level :l1
  feature "Bonsai 2 stays frozen while frontier learning's regret picks the Half-Life: Alyx
practice tasks that change the planner's RECTGTN elements, and the traces accumulate into an
EditScore-style multimodal dataset"
  scope "interactor-alyx-planner's levels, `frontier` step, corpus and dataset export, the XR
Pilot MCP `plan` tool as the rollout driver, and the frozen local Bonsai 2 model"

  prose ~S"""
  :: decision
  Hypothesis: with Bonsai 2's weights frozen, the planner improves by
  iterating its RECTGTN elements. Frontier learning's level search (Faro et
  al., 2026) picks practice tasks: a level is a task template with fixed
  attributes, a problem one instance played with XR Pilot's `plan` tool, and
  regret `1[s ≥ 1] − s/n` drives replay, exploration and mutation. Each step
  revises the domain (learned methods, Bonsai 2's proposed alternatives,
  checks) and keeps a change only when frontier success rises. Screenshots,
  instructions and scores accumulate as EditScore-shaped rows (operator,
  2026-10-11).
  :: problem
  The learner sees only what the agent happened to do: head sweeps,
  screenshots and `health` checks. Training Bonsai 2 needs compute the desk
  lacks, and Alyx is not a procedural generator, the paper's stated limit.
  :: references
  - Faro et al., Frontier Learning (doi 10.48550/arXiv.2609.35426)
  - Luo et al., EditScore (doi 10.48550/arXiv.2509.23909)
  :: related
  RFD 2304 (`Plan.lean`'s library), RFD 2161 (EditScore), RFD 2307 (recording).
  """

  details_title "frontier learning for the alyx planner"

  prose ~S"""
  :: details The paper's loop
  Each step draws `n_ℓ` levels from a buffer `ℬ` by Zipfian sampling over
  `P(ℓ, t) = R(ℓ) + λ_s · (t − t_ℓ)`, replaces each with a uniform level with
  probability `φ`, mutates one attribute of the rest with probability
  `p_inf`, `p_easy` or `p_hard` by the level's mean success (between 0.05 and
  0.95, above, below), rolls out `n_p` problems with `n_r` rollouts each and
  updates the policy with GRPO. Regret is zero for impossible and mastered
  problems and needs no extra rollouts. Appendix values: `φ` 0.3, `λ_s` 0.05,
  `p_inf` 0.4, `p_easy` 0.25, `p_hard` 0.02, `B_max` 100, Zipf temperature
  1.0, window 16, `R_0` 0.5, `n_ℓ` 4, `n_p` 16, `n_r` 8. On Dice it reaches
  71.8 ± 6.2% against 33.3% for the best baseline; mutation carries most of
  the gain (PLR with mutation 62.5%).

  :: details What iterates in place of GRPO
  The paper's policy is model weights; here it is the planner domain, and
  Bonsai 2 is a frozen proposer and namer. After each step:
  - `compress` relearns methods from the corpus, the frontier traces
    included, and the namer documents them.
  - For a level whose success is between 0.05 and 0.95, Bonsai 2 proposes
    one change: a new alternative for a method, a reordering, or a tighter
    `check`. The change is replayed on that level's problems and kept only if
    its success rises, as a hill-climbing step on the domain.
  - Every kept change is a commit with the rollouts that justified it, so the
    domain's history is the learning curve.

  :: details Levels for Alyx
  | Template | Attributes | Success check |
  |---|---|---|
  | `menu_select` | menu depth, item index | expected page in pilot state |
  | `grab_at` | distance, height, hand | object held |
  | `reload` | magazine source, time limit | ammo counter full |
  | `walk_to` | distance, turns, locomotion | head within 0.3 m of the goal |
  | `open_door` | handle side, swing | door past 60° |

  Each template is a `plan` domain whose goal is its success check, so XR
  Pilot's planner reports success. Attributes are discrete, so grid seeding,
  uniform exploration and one-attribute mutation work as in the paper.

  :: details What a step costs
  The paper's step is `4 · 16 · 8 = 512` rollouts; at 30 s each that is over
  four hours. Here `n_ℓ` 2, `n_p` 2, `n_r` 4, window 8 and `B_max` 32 give 16
  rollouts, about eight minutes; the other values stay the paper's.

  :: details The EditScore-shaped dataset
  An EditScore-Reward-Data row is `task_type`, `instruction`, `images` (the
  original, then the edit), two 0 to 25 `expected_scores` and an evaluator
  `conversations` pair. A rollout fills the same shape:
  - `task_type`: the template; `instruction`: the level rendered as an
    instruction ("pick up the magazine 1.2 m away with the left hand").
  - `images`: the pilot's screenshot before the plan and after it.
  - `expected_scores`: goal reached, and actions spent against the shortest
    successful rollout of that level, each scaled to 0 to 25.
  - `conversations`: the evaluator prompt and a reasoning string.
  The scores come from the planner's success checks and pilot state, not from
  Bonsai 2, so the labels are constructed. Bonsai 2's reasoning text is
  generated synthetic data: it is kept in its own column with the model,
  checkpoint and prompt, and evaluation reads only the constructed scores
  (CLAUDE.md, data hygiene). The rows are ETNF parquet with screenshots by
  hash.

  :: details Where it lives
  - `AlyxPlanner/Frontier.lean`: levels, regret, priority, buffer, replay,
    exploration and mutation as pure functions over a seeded random state,
    tested and modelled like `XrPilot/Stream.lean`.
  - A `frontier` executable runs one step: it reads the buffer and the last
    step's results and writes the next problems as `plan` domains. It does
    not talk to the game.
  - Any MCP client plays the problems with `plan`; `tools/export_corpus.py`
    brings the traces into the corpus and the dataset export.

  :: details Guards
  - Phase 1: 30 steps, with per-level success curves and the buffer's path.
  - Phase 2: domain changes that raise frontier success, and methods that
    recur across successful rollouts of hard levels.
  - Phase 3: a dataset export whose rows load in EditScore's own reader and
    whose scores agree with a held-out set of hand-checked rollouts.

  :: details Risks
  - Problems need a known start: practice saves loaded by name, never the
    operator's own slots (Start New Game asked to overwrite one).
  - Pixel success checks are noisier than pilot-state checks; each template
    records which it uses.
  - With `n_r` 4 and two problems a level the regret estimate is coarse; the
    paper's own Dice result spreads ±6.2 points over four seeds.
  - Hill-climbing on the domain can overfit a level's few problems; a change
    must also hold on the level's neighbours in the buffer.
  - The game, SteamVR, the pilot and NInfer share the RTX 4090; the namer and
    proposer run on the 3090 during rollouts.
  """
end
