# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2015, "Bounded llm steering queue", :prediscussion do
  prose ~S"""
  :: decision
  See `DETAILS.md` for the full argument.
  :: problem
  We steer an LLM by appending tasks to a queue as we go. This manuals
  session is the canonical example, with dozens of incremental requests.
  An unbounded queue overflows two scarce resources: the operator's
  personal context (you lose track of what is pending versus done) and
  the model's context window. How do we keep steering open-ended without
  overflowing either?
  :: related
  See `DETAILS.md` for the full argument.
  """

  details_title "Bounded llm steering queue"

  prose ~S"""
  :: details Context and Problem Statement
  We steer an LLM by appending tasks to a queue as we go, this manuals
  session is the canonical example, with dozens of incremental requests.
  An unbounded queue overflows two scarce resources: the operator's
  personal context (you lose track of what is pending versus done) and the
  model's context window. How do we keep steering open-ended without
  overflowing either?
  :: details Decision Drivers
  - Keep adding tasks freely as ideas arrive.
  - Bound what is held in volatile conversation context.
  - Never lose the record of what was decided or done.
  :: details Considered Options
  - Unbounded queue held in the conversation (status quo).
  - A hard task cap that drops tasks past a limit.
  - Externalize the queue, bound work in progress, and compact finished
    work.
  :: details Consequences
  - Good: the backlog and the record live in durable docs, not working
    memory, so the operator's attention and the model's context window
    both stay bounded.
  - Good: each finished item is findable later in the manuals.
  - Bad: it takes discipline to externalize and compact instead of holding
    everything in the conversation.
  :: details Confirmation
  At any time the conversation holds roughly one active task; completed
  work is found in the manuals (decisions and changelog) rather than the
  transcript; and the number of open PRs stays small.
  :: details More Information
  The one-concern-per-PR rule is the work-in-progress bound; the changelog and MADR practice is
  the compaction step.
  """
end
