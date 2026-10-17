# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2259, "how a session shapes its work", :committed do
  feature "A coding session names branches, commits RFDs, spends its
budget and parks work the same way every time"
  scope "every repository in the goal manifest and every agent session\nthat works in them"

  prose ~S"""
  :: decision
  - Branches start with a stage: `dev/`, `beta/`, `rc/`, `release/` or
    `archived/` (operator, 2026-10-12). A pushed branch is renamed
    through the code host's rename call, which keeps its pull request.
  - After the stage, a name says what the work is: no `module-`,
    `godot-` or `vendor-` (operator, 2026-10-13).
  - `dev/` becomes `beta/` once every latest check on the tip passed,
    the minimum bar (operator, 2026-10-13).
  - A `dev/` branch ends as a pull request or in `archived/`; a fork keeps its
    `dev/`, `beta/`, `rc/` and `release/` branches (operator, 2026-10-17).
  - Each RFD lands as one commit; a revision amends it before merge.
  - Maintenance takes at most a tenth of a session's budget.
  - Parked work is committed and pushed with its known defects
    named in the message, and the checkout is detached so
    `repo sync` cannot rebase it.
  :: problem
  `head/*` and bare branch names, RFDs spread over three commits,
  and a feature branch left checked out that `repo sync` rebased
  into conflict markers all happened in one session.
  :: related
  - RFD 2026 (commit messages), the subject line these commits use.
  - RFD 2258, the gates each pushed branch runs.
  """

  details_title "how a session shapes its work"

  details "Why the checkout is detached", ~S"""
  `repo sync` rebases a local branch that tracks the manifest's
  revision. A pushed branch loses nothing by being detached, and the
  next sync then leaves the project alone.
  """

  details "When two names collide", ~S"""
  Dropping a prefix can land on a name that is already taken. Compare
  the two branches with `git cherry` both ways and `git diff --stat`.
  If one branch holds every patch of the other, keep it and delete the
  other; record the deleted tip in the report so it can be restored. If
  each holds work the other lacks, ask the operator: they may move the
  missing commits onto one branch and archive the other. A consumer
  that names branches, such as the assembly config, is updated in the
  same session, because the code host redirects a renamed branch's
  web links but not a `git fetch` of the old name.
  """

  details "How a dev branch ends", ~S"""
  Sort each `dev/` branch by what it holds that the default branch
  lacks: `git cherry -v` against the default branch, and a trial merge
  with `git merge-tree --write-tree`.

  - Work the default branch lacks that merges cleanly goes to a pull
    request as it stands.
  - A branch whose commits the default branch mostly holds keeps only
    its `+` commits. They are cherry-picked onto a new `dev/<x>` off the
    default branch for a pull request, and the old branch is renamed to
    `archived/`, since a merge from a stale base conflicts.
  - Work in progress that was never built is renamed to `archived/`.
    A pull request would ask CI to judge code its author has not run.

  A fork keeps every `dev/`, `beta/`, `rc/` and `release/` branch: its
  work still goes to a pull request, but the branch is neither renamed
  to `archived/` nor deleted when the pull request merges.

  Before renaming, check that the `archived/` name is free and that no
  pull request has the branch as its head. After a pull request merges,
  cancel the merged branch's queued runs: they hold runners that the
  default branch's own run needs.
  """

  details "How a branch is promoted", ~S"""
  Read the check runs of the branch tip with only the latest run of each
  check kept, so a superseded or cancelled run does not count against
  it. Promote only when nothing is queued or running, nothing failed,
  and the set of check names equals the default branch's. A run that
  passed on a base far behind the default branch passed against code
  that is no longer there, so the operator decides those case by case.
  A branch whose checks are still queued is promoted by a bounded
  watcher that re-reads the tip first and skips it if the tip moved.
  """
end
