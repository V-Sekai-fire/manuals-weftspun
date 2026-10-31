# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2361, "A section names its own gate", :discussion do
  feature "which rule reads which section"
  scope "the HTML comment under a section heading, in every RFD README and DETAILS file."

  prose ~S"""
  :: hook
  A section names its own gate, in an HTML comment under its heading.
  :: intrigue
  Neither kind of writing owns a whole file.
  :: exit
  Put `<!-- gate: tropes -->` or `<!-- gate: ste100 -->` under each heading.
  :: decision
  **A section names its own gate, in an HTML comment under its heading.** These
  gates read a CommonMark AST, so the mark is a block token they see already.

  **An unmarked section fails.** A silent skip reads exactly like a pass.
  :: problem
  A `DETAILS.md` carries a measurement beside the reasoning that motivates it.
  :: related
  RFD66606-1125 splits the two gates by kind of writing. RFD66606-2362 measures the
  AI-trope table. RFD66606-1124 gives the reason these gates read an AST.
  """

  details_title "A section names its own gate"

  prose ~S"""
  :: details How a section names its gate
  <!-- gate: tropes -->

  Every section below names its gate in an HTML comment under its heading. That
  mark is the mechanism this RFD adds, so this file is also its first example.

  :: details Why the mark is per section
  <!-- gate: tropes -->

  The per-section mark follows from a fact about this repository rather than a
  preference. A `DETAILS.md` is where a measurement lands, and it is also where
  the reasoning that motivates the measurement lands. Those are two kinds of
  writing in one file, and any file-level rule has to be wrong about one of them.
  """
end
