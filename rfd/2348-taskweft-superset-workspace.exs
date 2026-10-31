# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2348, "the taskweft superset workspace", :committed do
  feature "the workspace manifest places every taskweft path, opt-in, and the bootstrap
opts in"
  scope "the private manifest's `default.xml` and `README.md`, the private bootstrap's
`bootstrap.sh` and `bootstrap.ps1`, and the private working agreements"

  prose ~S"""
  :: hook
  One workspace checkout holds both the taskweft rows and this workspace's own.
  :: intrigue
  The taskweft workspace and this one were two clients of two manifests. Work that needed
  both had no single checkout.
  :: exit
  Read the details for the checks that passed and the work still open.
  :: decision
  The workspace manifest is a superset of the taskweft manifest, by path.
  Where both place a path, this workspace's row wins, so rung pins never
  move through the merge. Every other taskweft row is added with
  `groups="notdefault,taskweft"`, pinned to the commit its branch or tag
  had on the day it was added, with `upstream` naming that ref. The
  bootstrap runs `repo init -g default,taskweft`, so a new workspace
  syncs both sets. A plain `repo init` still syncs the workspace's own
  rows only.
  :: related
  - RFD66606-2346, the last change that added manifest rows;
    RFD66606-2341, dev.next.
  - The private working agreements' languages section, which now names
    the bootstrap's group change; the private blocklist.
  """

  details_title "What was decided, how it was checked, and what is still open"

  prose ~S"""
  :: details The operator's decisions
  1. The taskweft rows the blocklist names (the OpenBao service and the
     Bao on SQLite and FoundationDB service) and `iceoryx2` are added as
     they are. They are placed for study. No workspace repo depends on
     them.
  2. New rows are pinned to a commit, as every upstream row here is.
  3. The rows are an opt-in group. The bootstrap opts in.
     `WEFTSPUN_GROUPS=default` gives the workspace's own rows alone.
  :: details Why a plain copy fails
  Taskweft rows track
  branches and include rows this org blocks, so a plain copy would have
  broken the pin rule and put blocked repos in every default sync.
  :: details The merge rules
  The comparison is by path, because a path is what `repo` collides on.
  11 paths are in both manifests. At the bootstrap path the two rows
  name different repos, and the private fork stays. The datasource
  store keeps this workspace's row, so taskweft's two linkfiles into
  the Bao on SQLite and FoundationDB service are not placed. GitHub
  rows use the one `origin` remote with an org-qualified name. The nine
  Hugging Face rows need two absolute remotes, `huggingface` and
  `huggingface-datasets`.
  :: details Numbers and checks
  taskweft had 180 rows: 169 added, 21 of them already pinned by commit.
  The manifest went from 20 to 189 rows. Every branch and tag resolved
  with `git ls-remote`, with 0 failures. The four manifest gates passed
  locally, each after its self-test, and the five CI jobs passed on the
  pull request and on `main` after the merge. A scratch `repo init`
  listed 189 rows with the group and 20 with `-g default`, which is the
  control. `repo list` without `-a` shows 0 rows before a sync, so it
  proves nothing about a fresh client.
  :: details Still open
  Nothing keeps the superset true as taskweft moves: a new taskweft row
  is absent here until someone adds it. The bootstrap repo's workflow is
  active but has never run, and this repo has no workflow, so neither
  change was checked in CI. No `pwsh` was available, so the PowerShell
  change was not parsed. The private org is invisible to the `gh`
  wrapper; its pull requests go through the REST API with a
  `bao-mint-github` token, which prints the token and its expiry on one
  line.
  """
end
