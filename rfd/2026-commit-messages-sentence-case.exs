# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2026, "Commit messages sentence case", :committed do
  prose ~S"""
  :: decision
  See `DETAILS.md` for the full argument.
  :: problem
  A commit subject is the first line a reader meets in `git log`, a
  blame, or a release note. Two conventions compete for how it reads.
  Conventional Commits prefixes each subject with a machine-readable
  type and optional scope, such as `feat:` or `fix(parser):`, and
  lower-cases the summary that follows. Plain prose writes the subject
  as an ordinary capitalised sentence. How should a commit subject in
  this repo read?
  :: related
  See `DETAILS.md` for the full argument.
  """

  details_title "Commit messages sentence case"

  prose ~S"""
  :: details Context and problem statement
  A commit subject is the first line a reader meets in `git log`, a
  blame, or a release note. Two conventions compete for how it reads.
  Conventional Commits prefixes each subject with a machine-readable
  type and optional scope, such as `feat:` or `fix(parser):`, and
  lower-cases the summary that follows. Plain prose writes the subject
  as an ordinary capitalised sentence. How should a commit subject in
  this repo read?
  :: details Decision drivers
  - A reader scans the subject as a sentence first, and the meaning sits
    at the front rather than after a colon.
  - The repos here run no tooling that consumes a commit type: no
    semantic-release, no changelog keyed on `feat` or `fix`.
  - One rule covers every commit, so review needs no judgement about
    which type applies.
  :: details Considered options
  - Conventional Commits, with a `type(scope):` prefix on every subject.
  - Sentence-case prose subjects with no prefix.
  - Free choice of style per author.
  :: details Decision outcome
  Chosen option: sentence-case prose with no prefix, because the
  subject stays a sentence a reader understands on sight, and the repos
  gain nothing from a commit type that no tool reads.

  A commit subject opens with a capital letter and reads as a plain
  sentence, such as `Add the macOS and Windows release workflows`. It
  carries no `feat:`, `fix:`, `chore:`, or `type(scope):` prefix, and no
  trailing period. The body, where present, states what the change
  makes true of the system and why.
  :: details Consequences
  - Good, because the subject reads as a summary on its own, with
    nothing to strip before the meaning.
  - Good, because the rule holds for every commit, so no author weighs
    whether a change counts as a `feat` or a `fix`.
  - Bad, because a changelog tool that groups commits by type finds no
    signal here, so adopting one later needs a different marker or a
    history rewrite.
  :: details Scope
  The rule holds on every repository this workspace commits to, forks
  included. A fix to a fork lands in our fork and nothing is sent
  upstream (RFD 2294, "Where a session posts"), so a fork's history
  past the upstream commit is ours and reads like the rest. A fork of
  a Conventional-Commits upstream carries sentence-case subjects on top
  of the upstream's prefixed ones.
  :: details Confirmation
  The rule is machine-checked by `scripts/check_commit_style.py`. It
  gates commits reachable in `<base>..HEAD` for three properties:

  1. No Conventional-Commits `type:` or `type(scope):` prefix on the
     subject.
  2. Subject opens with an uppercase letter, digit, or bracket.
  3. Subject does not end with a trailing period.

  The gate reads no remote, so a fork is held to the same three
  properties. Its self-test carries six subject controls (three that
  pass, three that fail) plus four that commit a prefixed subject and a
  sentence-case subject in a scratch repository, once behind a
  V-Sekai-fire remote and once behind a fork remote, and assert the
  first fails and the second passes.

      python scripts/check_commit_style.py --base origin/main
      python scripts/check_commit_style.py --self-test

  Review reads each subject as a capitalised sentence with no type
  prefix and no trailing period. The history after this decision shows
  subjects in that form.
  :: details More information
  This pairs with the tenseless continuous-present voice
  (`rfd/2025-tenseless-continuous-present-voice`): a commit body states
  what the change makes true of the system, the same way comments and
  docs do.
  """
end
