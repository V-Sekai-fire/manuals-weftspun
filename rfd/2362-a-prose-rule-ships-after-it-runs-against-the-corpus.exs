# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2362, "A prose rule ships after it runs against the corpus", :discussion do
  feature "measuring the AI-trope table before it gates"
  scope "`tropes-removal-model`, `seeds/ai_trope.parquet`, and the 119 RFD READMEs."

  prose ~S"""
  :: hook
  A prose rule ships only after it has run against the corpus.
  :: intrigue
  Twelve detectors report zero on the corpus, and three of those zeros come from detectors that
  cannot fire, so a broken detector reads exactly like a clean corpus.
  :: exit
  Run `--audit` first, before you trust any zero; it exits non-zero while any detector is
  broken.
  :: decision
  **A rule ships only after it runs against the corpus**, the bar RFD66606-1124 set.
  Three of the table's fifteen detectors cannot fire, so they wait on repair.
  :: related
  RFD66606-1125 assigns the AI-trope table to essays. RFD66606-2361 marks each section with
  its gate. RFD66606-1124 gives the measure-first rule.
  """

  details_title "A prose rule ships after it runs against the corpus"

  prose ~S"""
  :: details What already exists
  <!-- gate: ste100 -->

  This RFD proposes less than it first appears. The `tropes-removal-model` project
  holds most of the parts:

  | part                       | state                                                    |
  | -------------------------- | -------------------------------------------------------- |
  | `seeds/trope.parquet`      | 28 ASD-STE100 violation categories                       |
  | `seeds/ai_trope.parquet`   | 20 AI-writing tropes, seeded from tropes.fyi             |
  | `runtime/prose_nodes.py`   | CommonMark prose extraction, so a gate reads no syntax   |
  | `gate.py`                  | the ASD-STE100 gate; it runs the STE table only          |
  | a runner for the AI tropes | **absent**                                               |

  `scripts/seed_ai_tropes.py` reached the same conclusion as this RFD before this
  RFD did. Its own docstring states that ASD-STE100 "gates the wrong things" in an
  essay. Two facts remain to settle, and this RFD settles them.

  `gate.py` does not import `prose_nodes`, and nothing reads `ai_trope.parquet`.
  The catalog and the parser exist and are not connected.

  `runtime/prose_nodes.py` imports `markdown_it`. `pixi.toml` does not declare it.
  The RFD gates pin `markdown-it-py==3.0.0`, so the two projects must agree on a
  version once both depend on it.

  :: details The measurement
  <!-- gate: ste100 -->

  `scripts/measure_ai_tropes.py` in `tropes-removal-model` reads
  `seeds/ai_trope.parquet` and `runtime/prose_nodes.py`. It owns no patterns and
  no parser, because a second copy of either would drift from the first.

  It reads all 119 RFD `README.md` files. The counts are exact: the population is
  fixed and the script reads every member, which is what CLAUDE.md rule 5 asks for.

  The table holds 20 tropes: 15 regex, 3 classifier, 2 manual. Three of the 15
  find anything:

  | trope               | documents | share | hits |
  | ------------------- | --------- | ----- | ---- |
  | Compulsive Counting | 6         | 5%    | 7    |
  | Overused Adverb     | 2         | 2%    | 2    |
  | Em-Dash Addiction   | 2         | 2%    | 2    |

  :: details Three detectors cannot fire
  <!-- gate: ste100 -->

  Twelve detectors report zero. Nine of those zeros are real. Three are not.

  `--audit` feeds each pattern its own recorded `example_phrase`, passes it through
  `prose_nodes`, and asserts the pattern still matches. A detector that cannot
  match its own example is BROKEN, and its zero on a corpus means nothing.

  | detector              | fault                                                |
  | --------------------- | ---------------------------------------------------- |
  | Bolded Lead Clause    | matches `**...**`; `prose_nodes` removes the markers |
  | Where/What/Why Header | matches `#{1,6}`; `prose_nodes` removes the hashes   |
  | Negative Parallelism  | spells `it'?s`; its own example says "it is"         |

  The first two are one fault twice. Both patterns were written against raw
  markdown, and the extractor hands over the text a reader sees. Measured on one
  file: `Bolded Lead Clause` finds 5 in the source and 0 after extraction.

  Each repair is small. Move the two formatting rules to run before extraction, or
  rewrite them against the extracted text. Add `it is` to the third alternation.

  A zero from a broken detector reads exactly like a clean corpus. That is the
  failure CLAUDE.md rule 3 names, and it is why `--audit` runs first.

  :: details Every hit is a false positive
  <!-- gate: ste100 -->

  Run `--inspect` to see each hit in context. The inspection changes the result,
  so the count alone is not the measurement.

  | trope               | what the hits are                                      |
  | ------------------- | ------------------------------------------------------ |
  | Compulsive Counting | exact counts of items the document then enumerates     |
  | Overused Adverb     | "silently", describing a check that skipped in silence |
  | Em-Dash Addiction   | two parenthetical dashes across 119 documents          |

  `seed_ai_tropes.py` predicted this. Its docstring records that a regex is "a
  screen, not a verdict", and that Compulsive Counting "fires on the phrase 'three
  things', which is sometimes just three things". The corpus agrees: all seven hits
  count things the document goes on to list.

  No hit in the corpus is a true positive. Against the mechanical subset, the
  corpus is clean, and every firing rule needs narrowing before it gates anything.

  :: details What no mechanical detector reaches
  <!-- gate: ste100 -->

  tropes.fyi lists 49 tropes. The table seeds 20, and records that limit per row in
  its `coverage` column rather than in a README.

  Five of the 20 have no regex. `Invented Concept Label`, `Premise Stacking` and
  `Enumeration As Prose` need the classifier. `Circular Fractal` and
  `Symmetric Paragraph Length` have no automatic detector at all.

  The ASD-STE100 half splits the same way: about 18 mechanical rules as regular
  expressions, about 8 semantic rules through a SetFit classifier, and 2 more
  through a whole-document pass in `runtime/cross_sentence.py`. An essay gate needs
  the same second half, and this RFD does not build it.

  :: details How to re-run
  <!-- gate: ste100 -->

  ```
  cd .tropes_removal_model
  python3 scripts/measure_ai_tropes.py --audit    # check each detector can fire
  python3 scripts/measure_ai_tropes.py            # the AI-trope table
  python3 scripts/measure_ai_tropes.py --inspect  # every hit, in context
  python3 scripts/measure_ai_tropes.py --compare  # both tables, same extractor
  ```

  `--audit` exits non-zero while any detector is broken. Run it before you trust a
  zero from the other modes.

  The default path is `../.request_for_discussion`, which holds when both projects
  sit at the workspace root. `default.xml` places them there.
  :: details The problem
  The catalog and the parser exist and are not connected.
  """
end
