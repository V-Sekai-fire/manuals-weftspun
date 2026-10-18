# Frontier learning, round 1: consensus with untrusted players and home servers

A study session on 2026-10-18, in a chat thread between the operator and the
agent. It uses RFD 2309's frontier rule on the operator's own computer science
knowledge instead of on the planner. A level is a topic. A problem is one
question about it. Each answer is scored 0, 1 or 2, so n = 2. Regret is
`1[s >= 1] - s/n`. A partial answer scores the highest regret, and that topic
is the frontier.

## Apparatus

- Six probe questions opened the round, one per level: consensus,
  complexity, compilers, GPU memory, numerics and Lean types.
- The operator answered the consensus question first. The level then
  followed the operator's own domain: Byzantine nodes with open membership.
- Each answer was scored when it arrived. The agent explained what was
  missing and set the next problem one step harder.

## Answers and scores

| Problem | Operator's answer, in short | Score | Regret |
| --- | --- | --- | --- |
| 1. Why a 3/2 split stops a 5-node Raft cluster | "A consensus theorem says n/3 + 1" | 1 | 0.5 |
| B. Which fault model fits our nodes | Players and home servers are Byzantine | not scored | |
| S1a. Stop 5 alts from earning votes, by graph | Likes from existing identities make cliques harder | 1 | 0.5 |
| S1b. The same, by graph | The home server the player chose is the trust anchor and passes trust along the player's relationships | 1 | 0.5 |
| S1c. The same, by time or stake | Epochs, like a store's $100 developer fee and a payment provider's one-month hold | 2 | 0 |
| S2. Which voter set settles a contested item | The item has an original owner. Macaroons, with the signature as a ReBAC validator | 2 | 0 |
| S3. Hand off a dead owner's sequencer | Named it recovery delegation | 2 | 0 |
| S3b. Is k of n guardians a new rule | "Isn't this the same as n/3 + 1" | 2 | 0 |

Regret on the level went 0.5, 0.5, 0.5, then 0, 0, 0, 0. After the last
three answers the level counts as known, and the next round opens a new level.

## What each answer was missing, and what fills it

**1.** `n >= 3f + 1` with quorum `2f + 1` is the Byzantine bound (Lamport,
Shostak and Pease, 1982). Raft assumes crash faults, so a majority
`floor(n/2) + 1` is enough: 3 of 5. The minority side cannot elect a leader.
The theorem in the question is CAP. Keeping both sides writable gives up
linearizability for eventual consistency, for example CRDTs.

**S1a.** Counting likes rewards a clique that likes itself. Score by trust flow
instead: a random walk with restart from seed identities, with each identity's
outgoing trust split across its likes. A clique's trust is then limited by its
attack edges, the edges from honest identities into it. The literature is
SybilGuard, SybilLimit and SybilRank.

**S1b.** One anchor per player is subjective trust: each anchor seeds its own
view. BFT needs every honest node to agree on the voter set, and two anchors'
views differ. A new server is also its own anchor and trusts itself. Server to
server trust needs the same flow rule one level up, plus a time or stake rule.

**S1c.** The operator's two examples are two mechanisms:

- An entry fee is stake that is not returned. The fee must exceed what one
  identity can earn by cheating before it is caught.
- A hold is a challenge window. It must be longer than the time it takes to
  detect fraud. Optimistic rollups use about 7 days, and proof of stake chains
  use an unbonding period.

Together, for home servers: a bond, one epoch before the first vote, and a
challenge window on trades. Any anchor may replay the zone's input log in the
window, and a replay that does not match burns the bond.

**S2.** An original owner turns the dispute into authorization, which needs no
vote. Two limits remain:

- A plain macaroon is an HMAC chain, so only the holder of the root key can
  verify it. Public key chains with Datalog caveats (Biscuit tokens) let
  anchors that do not trust each other verify the same chain, and Datalog fits
  ReBAC.
- A macaroon proves a holder may transfer an item, not that the holder did it
  once. A double spend needs one ordering point per item, such as the owner's
  anchor. Two valid transfer chains seen in the challenge window are a fraud
  proof.

**S3.** Recovery delegation has three parts: a delegation signed in advance
while the owner is online, a k of n guardian threshold, and a timelock the
returning owner can veto. Guardians come from different anchors, so they cannot
collude through one anchor.

**S3b.** The operator saw that this is the same rule. k must meet three
conditions, with f guardians that may lie:

1. Safety: `k >= f + 1`.
2. Liveness: `k <= n - f`.
3. No fork: two quorums share an honest guardian, so `2k - n >= f + 1`.

`n = 3f + 1` and `k = 2f + 1` meet all three: 3 of 4, or 5 of 7. Shamir style
recovery of one secret needs only condition 1, so `k = f + 1` is enough there.
When guardians must choose one successor, condition 3 applies and the bound is
the Byzantine one again.

## Still open

- S3's numbers for our game: n, k, the silence before recovery, the veto
  window, and what a player does when their own anchor goes offline.
- Problems 2 to 6 of the opening round are not scored: why HTN planning is
  undecidable, SSA phi nodes, cross-workgroup barriers, BF16 accumulation, and
  Prop against Type in Lean.
