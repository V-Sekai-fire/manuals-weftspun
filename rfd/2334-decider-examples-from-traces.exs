# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2334, "Decider examples from traces", :discussion do
  feature "a traced action becomes a decider example: a state, a question with options, gold only
where the action measured it, and the views before and after"

  scope "the trace stores of the cua-driver fork and XR Pilot, and every dataset made from them"

  prose ~S"""
  :: decision
  - This RFD's URN, urn:oid:1.3.6.1.4.1.66606.1.2.2334, names the decider example: a record
    of one traced action. A dataset of them cites it in its card and on every row.
  - An example holds the state (the tool and its arguments), one or more Choice questions with
    their options, the views before and after as lossless JPEG XL (ISO/IEC 18181), and
    real-valued measures. Gold is stored only where the actor measured the answer; an action
    it could not verify keeps the question and no gold.
  - Every example, span, session and view carries a UUIDv7 (RFC 9562) whose time is the
    moment the row describes, so examples from many stores and machines merge without
    collisions and sort by time (operator, 2026-10-25). Vocabularies (tools, roles, questions,
    metrics) are keyed by their names.
  - A delivered dataset is ETNF tables plus one denormalized table for the dataset viewer,
    all Parquet with zstd (operator, 2026-10-25).
  :: problem
  The trace stores key rows by local integers. Two stores, or one store opened twice, reuse the
  same numbers, so examples gathered on several machines cannot be merged or cited row by row.
  :: related
  - RFD66606-2294, the practices the stores' changes followed.
  """
end
