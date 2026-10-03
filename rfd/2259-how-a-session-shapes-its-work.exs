# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2259, "how a session shapes its work", :committed do
  feature "A coding session names branches, commits RFDs, spends its
budget and parks work the same way every time"
  scope "every repository in the goal manifest and every agent session\nthat works in them"

  prose ~S"""
  :: decision
  - Branches are `main/*`, `feat/*` or `archived/*`. A pushed
    branch is renamed through the code host's rename call, which
    keeps its pull request.
  - Each RFD lands as one commit; a revision amends that commit
    before merge.
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
end
