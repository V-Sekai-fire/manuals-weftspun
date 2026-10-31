# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2346, "decider-pong in the workspace", :committed do
  feature "decider-pong synced, pinned and mirrored like every other project"
  scope "the private manifest's `default.xml`, the decider-pong interactor and its upstream
decider interactor"

  prose ~S"""
  :: hook
  decider-pong is a manifest row, synced offline like every other project.
  :: intrigue
  The repo lived outside the workspace, on GitHub only, with its upstream as a submodule.
  :: exit
  Read RFD66606-2341 for the two open questions, parked in dev.next.
  :: decision
  decider-pong is a manifest row on the interactor side, tracking
  `main`. Its upstream, `Mapika/decider` (Apache-2.0), is a second row
  beside it, pinned to a commit. It was a git submodule; it is not any
  more. Both are in the local mirror, and a fresh offline client syncs
  them with 0 failures. The OpenBao credential helper was removed from
  the tree.
  :: problem
  The contract places a repo in the manifest
  the day it is created and pins upstreams as manifest rows. The repo
  also carried a blocklisted OpenBao helper. Two questions remain open:
  the repo is all Python, and its name lacks a side prefix.
  :: related
  - RFD66606-2341, dev.next, where the two open questions are parked.
  - RFD66606-2345, the video format; RFD66606-2347, the decider-pong
    review.
  """

  details_title "How the project was placed, and what is still open"

  prose ~S"""
  :: details Related
  - The private working agreements, the org and languages sections; the
    private blocklist.
  :: details The steps, in order
  1. The pending prompt change was committed in decider-pong.
  2. The submodule checkout was shallow, so the mirror refused it. It
     was unshallowed from GitHub, and the pinned upstream commit was
     pushed to a new bare mirror of the upstream. All 98 commits arrived
     and `git fsck` is clean.
  3. `bin/bao-github-credential` was removed in one commit, then the
     submodule was replaced by the manifest row in the next.
  4. A bare mirror of decider-pong was made and `main` was pushed to it.
  5. Two rows were added to `default.xml` beside the other interactors,
     committed and pushed to the manifest mirror.
  6. A scoped `repo sync` of the two paths placed both checkouts. A full
     sync was not run, because three projects sit on `dev1` branches
     that the preflight would park.
  :: details Gates run
  `check_manifest_comments.py`, `check_manifest_xml.py --offline`,
  `check_manifest_dupes.exs` and `check_manifest_root.py` passed, each
  after its self-test. `check_offline.exs` lists 19 projects with 0
  failures, both decider rows at their pins, and its self-test fails
  as planted. One run reported 1 failure while a push to the mirror was
  in flight; three runs after it reported 0.
  :: details GitHub and the mirror
  decider-pong's GitHub `main` fast-forwards to the mirror's and is
  pushed there too. The manifest was pushed to the mirror only. GitHub's
  manifest carries one commit the mirror lacks, which adds a row for a
  repo not yet mirrored. Reconciling the two needs that repo mirrored
  first, and is the user's call.
  :: details Open questions, parked in dev.next
  The languages rule forbids project Python. decider-pong is an
  evaluation harness. It is either ported to Elixir or the engine, or
  given a named exemption. The org names repos by hexagon side; the repo
  should carry the interactor prefix. Only the user renames repos on
  GitHub. After the rename the manifest row changes by one line. The
  removed helper stays in history from the commit that added it;
  dropping it means rewriting a published branch.
  """
end
