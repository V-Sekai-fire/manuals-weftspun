# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2351, "one INNOVATION-TOKEN ledger for three orgs", :discussion do
  feature "an INNOVATION-TOKEN is what the stack cannot run without, so nineteen cover the app and
both upstream orgs"
  scope "the INNOVATION-TOKEN ledger in the private working agreements and the private plan, the
private blocklist, and the repos of V-Sekai-fire, chibifire-stages and the private org"

  prose ~S"""
  :: hook
  How many INNOVATION-TOKENS does the app and both upstream orgs spend?
  :: intrigue
  The ledger counts features. The pen and `zone.elf` take two INNOVATION-TOKENS and run on one
  substrate.
  :: exit
  Check a new technology against the rule: an INNOVATION-TOKEN is a substrate, and the tech stack
  crashes without it.
  :: decision
  An INNOVATION-TOKEN is a substrate: delete it and the tech stack crashes. The name keeps it
  apart from a credential (operator, 2026-11-01). The ledger has nineteen. INNOVATION-TOKEN 1 is
  guest ELFs on the pinned double engine. The meshing pen and `zone.elf` both run there, so they
  share it, with the ggml-rd models, `slug.elf`, voice, the USD guest and the Lean tests.
  INNOVATION-TOKEN 2 is one store, SQLite on FoundationDB pages. CockroachDB is retired
  (operator, 2026-10-18). INNOVATION-TOKEN 3 is Bao, and INNOVATION-TOKEN 4 is Fly, which hosts
  the store, Bao and the KMS key that unseals Bao. INNOVATION-TOKEN 5 is Tailscale, because the
  game cannot be updated without it, so transactions are affected (operator, 2026-11-01).
  INNOVATION-TOKEN 6 is FEX and INNOVATION-TOKEN 7 is Proton, which run the campus beta's win64
  build on the Steam Frame, the Steam Deck and a Mac (RFD66606-2360). The operator ruled the
  rest on 2026-11-01: INNOVATION-TOKEN 8 is Windows, 9 is pixi, 10 is prek, 11 is GitHub, 12 is
  the Fedora cross-build image, 13 is LLVM, 14 is llvm-mingw, 15 is osxcross, 16 is the SteamVR
  runtime, 17 is Godot Engine and 18 is the taskweft persona engine and 19 is Elixir (operator,
  2026-11-01). The guest BEAM is unship (operator, 2026-10-29). The count was three, then two,
  and is nineteen. The ledger changes between rungs, not in an open one, and the operator moved
  the two documents on 2026-10-30 rather than wait for a rung to claim them.
  """

  details_title "one INNOVATION-TOKEN ledger for three orgs"

  prose ~S"""
  :: details The measured gap
  The upstream orgs ran a second database. Of 312 repos that use a non-boring
  technology, 182 fit inside one INNOVATION-TOKEN when each technology is its own.
  :: details How the ledger was found
  The operator requested it on 2026-10-18: study the three orgs and
  consolidate the INNOVATION-TOKENS with frontier learning, with no limit on the
  count. Each org is a level. Each repo that uses a non-boring technology
  is a problem: 298 in V-Sekai-fire, 10 in the private org (the local
  checkouts, because the token cannot list the org) and 4 in
  chibifire-stages. A problem passes when every technology it uses is in
  one INNOVATION-TOKEN. Repos were tagged against 33 technologies from their names,
  descriptions, topics and languages.

  A step tries one move, "technology X rides on INNOVATION-TOKEN Y". The level with
  the most regret picks it. The move is kept only when total passes rise
  and at least two repos use both. Two planted moves with no relation
  (Ink onto OpenBao, Janet onto CockroachDB) were controls, and both were
  rejected.

  :: details What it measured
  - Passes rose from 182 to 263 of 312 (58% to 84%): 23 moves kept, 11 rejected.
  - Per level at the end: V-Sekai-fire 251 of 298, the private org 8 of
    10, chibifire-stages 4 of 4.
  - Kept onto the guest INNOVATION-TOKEN: the pen, `zone.elf`, ggml-rd (and the
    Python reference models and Slang kernels behind it), MuJoCo,
    OpenUSD, voice, Rust guests, `slug.elf`, the double engine with
    xr-pilot and CineForm, and Lean as tests.
  - Kept onto the BEAM: taskweft, MCP, holographic reduced representations.
  - Not merged, for want of shared repos: CockroachDB, the casync chunk
    store, OpenBao and parquet into the store. Retiring CockroachDB was
    an operator decision, not a measured one.

  :: details What is still split
  - Elixir and guest code meet in 29 repos (taskweft compiled to a
    guest, the Godot build service, the MCP guest, the private org's
    double-engine repository). That boundary decides two big INNOVATION-TOKENS or
    one.
  - Terraform, Ink, Janet, TLA+, gaussian splats, hypercore and
    Go each sit alone. Each is a candidate to retire or park.
  - The tagging reads metadata, not code. Two third-party engine
    scripting tags landed in the guest INNOVATION-TOKEN on a loose keyword. The
    moves were written by the agent. The measurement only checked them
    against shared repos.

  :: details The parts added on 2026-11-01, classified
  The operator asked for the ledger to name these parts and ruled on each (operator, 2026-11-01).
  - Bao is INNOVATION-TOKEN 3. The zone talks to the store directly, and reaches Bao rarely, to
    get or renew the credential it presents to the store.
  - Fly is INNOVATION-TOKEN 4. Delete it and the store, Bao and the KMS key that unseals Bao go
    with it.
  - Tailscale is INNOVATION-TOKEN 5. Delete it and the game cannot be updated, so the
    transactions of a CRUD update are affected.
  - FEX is INNOVATION-TOKEN 6 and Proton is INNOVATION-TOKEN 7. Delete either and the win64
    build stops running on the Steam Frame, the Steam Deck or the Mac test, so the campus beta
    of RFD66606-2360 crashes on those targets.
  - Windows is INNOVATION-TOKEN 8, pixi is 9, prek is 10 and GitHub is 11. The build and gate
    tools count as the tech stack.
  - The Fedora cross-build image is INNOVATION-TOKEN 12, LLVM is 13, llvm-mingw is 14 and
    osxcross is 15. Each is its own substrate, so deleting one stops a cross-build.
  - The SteamVR runtime is INNOVATION-TOKEN 16, Godot Engine is 17, and the taskweft persona
    engine is 18. Godot Engine and the pinned double engine of INNOVATION-TOKEN 1 are
    separate INNOVATION-TOKENs (operator, 2026-11-01).
  - Elixir is INNOVATION-TOKEN 19 (operator, 2026-11-01). It runs every gate and the ledger's
    own tools, and its failure stops them, so it counts under the tool ruling.
  - GitHub's identity-token login rides INNOVATION-TOKEN 3, because it is a login to Bao.

  :: details What is not known

  :: details Related RFDs
  - RFD66606-2341, dev.next, where this waits; RFD66606-2309, frontier learning.
  - RFD66606-2006 and RFD66606-2075, abandoned.
  - The private blocklist, the CockroachDB row.

  :: details CockroachDB, retired
  - The private org: a row in the private blocklist.
  - Weftspun: a manuals pull request, merged.
  - Moved to SQLite on FoundationDB, all merged 2026-10-18: the zone
    backend contract (its leftover CockroachDB deploy and notes), the
    taskweft MMOG agent and the residual FSQ recommender (both tested in
    CI on a real FoundationDB), and the multiplayer fabric hosting
    service (compose only, never run: no desk runs containers).
  - Also moved, merged 2026-10-18: weftspun-character-taxonomy. Its
    image no longer starts a CockroachDB node, and CI finds its test
    database's keys in FoundationDB. The smoke-test scripts in the
    multiplayer fabric meta repo wait for a merge with no CI.
  - Archived: the fabric's CockroachDB service, the Dokku CockroachDB
    service, the vertex interactor, the fabric's container service, the
    fabric gateway transport and the fabric infra service (the Terraform
    for the Fly app, whose daily backup found no started machine on
    2026-10-18).
  - The pinned taskweft dependency still pulls postgrex.
  - The analysis script was Python in a scratch directory. It is not kept
    here, by the languages rule.

  :: details The BEAM row, unship (operator, 2026-10-29)
  No guest runs BEAM bytecode, and no `beam.elf` exists in the tree. The
  only novel piece of the row is RFD66606-2330's static riscv64 BEAM, and
  that is the piece to unship. Counting the BEAM as an INNOVATION-TOKEN spent the slot
  that merging the pen and the shared world freed.

  :: details The two rows, moved (operator, 2026-10-30)
  - The private plan: "The three innovation tokens" is two. The ledger
    table's pen row and zones row are one guest row, which absorbs the
    "already paid" RISC-V row, and the store row is INNOVATION-TOKEN 2.
  - The private working agreements: "There are three, and all three are
    spent" is two, naming guest ELFs on the pinned double engine as the
    INNOVATION-TOKEN the pen and `zone.elf` share.
  - The operator moved both on 2026-10-30, outside a rung, rather than
    waiting for one to claim them, and RFD66606-2341's item left
    dev.next.
  :: details The problem
  Elixir runs every tool and is INNOVATION-TOKEN 19.
  """
end
