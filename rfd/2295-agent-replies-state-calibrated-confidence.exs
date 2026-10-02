# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2295. `mix rfd.render` renders
# rfd/2295-agent-replies-state-calibrated-confidence/README.md and DETAILS.md from
# this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2295 do
  use RFD.DSL

  rfd 2295, "agent replies state calibrated confidence" do
    state :committed

    flight_level :l2

    feature "an agent tags every unverified claim with a word and a probability,
`(likely, p=0.80)`, from one fixed scale"

    scope "agent replies to the operator, logbook entries, and
`scripts/check_confidence_tags.py`"

    decision ~S"""
    A claim an agent has not verified carries its confidence as a word and a
    probability in one tag: `(likely, p=0.80)`. The word comes from a fixed
    scale of five, and the number must fall inside that word's band. A
    verified fact (a command's output, a merged pull request, a passing gate)
    carries no tag. `scripts/check_confidence_tags.py` reads the bands from
    this RFD's source and fails any tag whose word and number
    disagree, so the scale and the gate cannot drift apart.
    """

    problem ~S"""
    Agent replies stated forecasts and diagnoses in the same voice as checked
    facts. On 2026-10-02 a reply described a Metal shader port as "Slang-to-MSL"
    when the shaders were hand-written, and the operator caught it. A reader
    cannot weigh a claim that does not say how sure it is, and a bare
    percentage reads as code rather than as language.
    """

    related ~S"""
    Lin, Hilton and Evans, "Teaching Models to Express Their Uncertainty in
    Words" (2022, DOI 10.48550/arXiv.2205.14334, registered with DataCite)
    is the method: a model states its confidence in words and numbers, and
    the statement is scored for calibration. RFD 2294 (agent knowledge lives
    in RFDs) is why the rule is here and not in a desk's memory. `CLAUDE.md`'s
    "How Work Is Verified" rule 3 (a silent skip reads like a pass) is why a
    verified fact and a guess must look different.
    """

    drafted_by :ai

    details_title "agent replies state calibrated confidence"

    details "The scale", ~S"""
    The gate reads this table. A tag's number must lie inside its word's
    band, lower bound inclusive and upper bound exclusive, except that
    `almost certain` includes 1.00.

    | word | lower | upper |
    | --- | --- | --- |
    | remote | 0.00 | 0.10 |
    | unlikely | 0.10 | 0.40 |
    | even | 0.40 | 0.60 |
    | likely | 0.60 | 0.90 |
    | almost certain | 0.90 | 1.00 |
    """

    details "The tag", ~S"""
    The form is `(word, p=0.NN)`: the word, a comma, `p=` and the probability
    with two decimals. It follows the claim it qualifies:

        The walker stays bit-deterministic (likely, p=0.75).
        The 12 modules finish today (unlikely, p=0.25).

    Only unverified claims carry a tag. A claim the agent checked in the same
    turn states the check instead of a probability, because a probability on
    a checked fact would hide that it was checked.
    """

    details "Calibration", ~S"""
    The numbers mean something only if they are calibrated: of the claims
    tagged `p=0.80`, about four in five should turn out true. A logbook entry
    that records tagged forecasts also records how they resolved, so the
    tags can be scored. No such score exists yet; the first logbook entry to
    carry tagged forecasts starts it.
    """

    details "Times", ~S"""
    A time in a reply, a logbook entry, an issue comment or a pull request
    is written in ISO 8601 with its date and UTC offset:
    `2026-10-02T09:51-07:00`, not `09:51` or `11am`. A forecast's deadline
    is the same kind of time, so `tagged by 2026-10-02T11:00-07:00` is
    scorable by a reader in another zone or on another day. Durations stay
    plain (`20 minutes`). No gate checks this yet; it holds by agreement.
    """

    details "What is checked", ~S"""
    `scripts/check_confidence_tags.py` scans `logbook/*.md` and every RFD
    source for tags, and fails a tag whose word is not on
    the scale or whose number falls outside the word's band. Its self-test
    plants one tag of each kind, a correct one, an unknown word and a number
    outside its band, and asserts the gate passes the first and fails the
    other two. Replies are not files, so the gate cannot see them; the rule
    holds there by agreement.
    """
  end
end
