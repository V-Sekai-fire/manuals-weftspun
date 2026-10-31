# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2172, "Prose speaks in the tenseless continuous present", :committed do
  front_matter ~S"""
  ---
  name: rfd-2172-tenseless-continuous-present-voice
  description: When writing prose (code comment, RFD, changelog, README, PR description) in this workspace, state what is currently true of the system. Rule out past-tense edit narration, future or imperative planning, and aging temporal qualifiers.
  tools: Read, Write, Edit
  ---
  """

  feature "prose voice for code comments, RFDs, and changelog entries"
  scope "every `.md`, `.qmd`, and code-comment file in the workspace"

  prose ~S"""
  :: decision
  **Every sentence of prose in this workspace states what is true of the system now.**

  Every sentence describes behaviour a reader can check against the code in front of them.
  Reject a sentence in review when it breaks one of the three habits below.
  :: problem
  A reader opens a comment and cannot tell whether it still holds. RFD66606-2025 (sinew
  voice ADR, migrated) settled the rule; this RFD promotes it to a workspace convention
  and folds that ADR in, so one RFD owns the rule.
  :: section Three habits ruled out
  - Past-tense edit narration ("removed the legacy path"). Git holds history.
  - Future or imperative planning ("will add", "TODO"). RFDs and issues hold plans.
  - Aging temporal qualifiers ("now", "currently", "previously"). They go stale on the
    next edit, so the sentence should have described a truth.
  :: related
  Promotes RFD66606-2025, folded in. Companion to RFD66606-1125 and the trope-density check.
  """

  details_title "Prose speaks in the tenseless continuous present"

  prose ~S"""
  :: details The drift
  Comments and prose drift out of sync with code as the system changes. A comment written as
  history ("added a cache", "we removed the old path") or as a plan ("will solve this", "TODO:
  wire X") describes a moment that has passed or has not yet arrived; a reader cannot check it
  against the code in front of them. Unfinished areas read as present gaps ("the parser
  handles no Unicode escapes yet"), not as tasks. A stale sentence signals a real divergence
  from the code, which makes review catch it. Review checks that new comments and prose state
  present truths, with no past-tense edit narration, no future or imperative planning, and no
  aging temporal qualifiers.
  :: details Why this voice
  - A reader trusts a comment when it matches the code as it stands.
  - History lives in git; plans live in issues and decision records.
  - The rule stays mechanical enough to apply in review without debate.

  A sentence that states a present truth stays correct as long as the code it describes
  stays the same, and goes stale visibly the moment the code changes. Prose describes
  behaviour ("the parser streams tokens"), and an unfinished area reads as a present gap
  ("the parser handles no Unicode escapes yet") rather than as a task or a past edit. The
  voice covers code comments, doc pages, and decision records alike.
  :: details Options weighed
  - Free choice of tense per author.
  - Past-tense changelog voice inside code comments.
  - A tenseless continuous-present voice where every sentence states what is currently
    true of the system. This option is chosen.
  :: details Consequences
  - Good, because a stale sentence signals a real divergence from the code, which makes
    review catch it.
  - Good, because one voice covers code comments, doc pages, and decision records.
  - Bad, because a present-gap phrasing reads less naturally than an imperative TODO,
    and authors need practice to phrase work that way.
  :: details Where the rule came from
  This generalizes the house rule applied across the sinew Lean spec and its native
  viewer prose, where comments describe current behaviour and `todo.md` lists each open
  item as a present gap. A TODO document states each open item as a present gap, so the
  file reads as a description of where the system stands rather than a logbook of
  intentions. The existing decision records in this repo already read this way.
  """
end
