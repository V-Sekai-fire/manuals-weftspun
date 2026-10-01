# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2291. `mix rfd.render` renders
# rfd/2291-capability-rebac-is-a-dsl-feature/README.md and DETAILS.md from this
# file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2291 do
  use RFD.DSL

  rfd 2291, "capability ReBAC is a DSL feature" do
    state :committed

    flight_level :l2

    feature "verbs, tuples and capabilities are declarations in a `rebac` block,
and the tables and the fenced block render from them"

    scope "`RFD.DSL`, `RFD.Doc`, the new `RFD.ReBAC`, `mix rfd.rebac`,
`scripts/check_rebac.exs`, and RFDs 2200, 2202 and 2288"

    decision ~S"""
    Capability ReBAC is declared, not written twice. A `rebac` block inside
    an `rfd` block carries `verb`, `relate`, `deny` and `capability` lines;
    `RFD.ReBAC` holds the model and every rule; the verb table, the
    capability table and the fenced `rebac` block render from the
    declarations. `verbs_from` states tuples over another RFD's vocabulary,
    which `mix rfd.rebac` resolves across the corpus, and `renders_into`
    gives an RFD the fenced block of a document outside `rfd/`.
    """

    problem ~S"""
    `scripts/check_rebac.exs` read its verb vocabulary by matching pipes in
    RFD 2200's rendered Markdown table, and RFD 2232 (the RFD DSL) makes
    that Markdown a build artifact, so the authority for what verbs exist
    was a table layout in a generated file. A second copy of the rows sat in
    `CLAUDE.md` by hand. Two RFDs use verbs RFD 2200 never named and nothing
    reports it, because the rows the gate reads avoid them.
    """

    related ~S"""
    RFD 2200 (the verbs and the tuples) declares them here; RFD 2232 (RFD
    authoring as an Elixir DSL) gives the build-artifact rule this follows;
    RFD 2288 (guest capabilities as macaroons) and RFD 2202 (role tuples
    through Bao groups) carry their capabilities and role rows as
    declarations.
    """

    drafted_by :ai

    details_title "capability ReBAC is a DSL feature"

    details "The surface", ~S"""
    One block per RFD, inside the `rfd` block:

        rebac do
          verb :owns, "the subject holds and operates the object as hardware"

          relate "cuda-a63415", :owns, "desktop-3090"
          deny "hailo-552dfa", :owns, "desktop-3090", "CUDA holds the cards"

          capability :transfer, object: "vm", caveats: [:vm, :expires, :epoch]

          verbs_from 2200
          renders_into "CLAUDE.md", subject: "desk-agent"
        end

    A verb is an atom and its row text is kebab, so `:may_use` reads as
    `may-use` in a row and in a table. `capability` defaults its verb to its
    own name and takes `object:` and `caveats:`. `relate` takes an optional
    note, which renders after `#` the way a denial's reason does.
    """

    details "What is checked, and when", ~S"""
    `RFD.ReBAC.problems/2` is the one implementation of every rule, and both
    the DSL and the gate call it. A block's shape is checked while its
    source compiles, so a bad declaration is a compile error that names the
    rule:

    - each segment is lowercase kebab, and each verb is declared once with a
      meaning
    - a denial carries its reason
    - no row repeats, and no relation is both granted and denied
    - a capability names one verb on one object and states its caveats once

    The vocabulary is the exception. A `verbs_from` resolves only once every
    source is loaded, so `mix rfd.rebac` holds every block and every fenced
    document block against the verbs the corpus declares. The two halves
    together are what the regex read before.
    """

    details "The rendering is the evidence", ~S"""
    The fenced block rendered into `CLAUDE.md` from RFD 2200's nine rows
    came out byte for byte the block that was there, reasons aligned in
    their column included. A rendering that differs from the prose it
    replaces means the declarations are wrong, not the prose, and that is
    the check worth running on each further migration.
    """

    details "What the migration found", ~S"""
    Two verbs are used by RFDs that RFD 2200 never named, which a vocabulary
    read out of one table could not report:

    - `trusts`, which RFD 2239 (traits and one binary) states as an
      amendment to RFD 2200.
    - `role` and `may-use`, which RFD 2202 and `rectgtn/fleet.jsonld` both
      use. `CLAUDE.md` happens to use neither, so the gate never looked at
      a row carrying one.

    All three are `verb` lines in RFD 2200 now, which is what RFD 2200's own
    rule asks for: a new verb is an amendment to that RFD before it is a row
    anywhere.
    """

    details "What this does not do", ~S"""
    Enforcement is unchanged. RFD 2200's tuples are still data, Bao identity
    groups still enforce the role rows (RFD 2202), and the macaroons of RFD
    2288 are still a design. The live tuples are Bao KV rows under
    `relationships/`, and an RFD declares only the rows it states itself.

    The planner's own ReBAC engine is untouched: `tw_rebac.hpp`'s relation
    types, the Lean specification over them and `capabilities` in a RECTGTN
    domain are a separate vocabulary with a separate check.
    """
  end
end
