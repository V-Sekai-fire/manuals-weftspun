# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule RFDTest do
  use ExUnit.Case, async: true

  defp doc(overrides \\ []) do
    struct!(
      RFD.Doc,
      Keyword.merge(
        [
          serial: 2999,
          title: "a test RFD",
          state: :discussion,
          feature: "the feature",
          scope: "the scope",
          decision: "Do the thing.",
          problem: "The thing was not done.",
          references: ["RFD 1000"],
          related: "RFD 1000.",
          drafted_by: :ai
        ],
        overrides
      )
    )
  end

  test "a well-formed RFD renders README in RFD 1000's shape" do
    readme = RFD.Doc.readme(doc())

    assert String.starts_with?(
             readme,
             "# RFD 2999: a test RFD\n\n**State:** discussion\n**Feature:**"
           )

    assert readme =~ "\n## Decision\n\nDo the thing.\n\n## Problem\n"
    assert readme =~ "\n## References\n\n- RFD 1000\n\n## Related\n"
    assert String.ends_with?(readme, RFD.Doc.canary(:ai) <> "\n")
    assert length(String.split(readme, "\n")) <= RFD.Doc.readme_limit()
    assert RFD.Doc.problems(doc()) == []
  end

  test "details render to DETAILS.md and the README names it" do
    d = doc(details: [{"How it was checked", "Every number came from a run."}])
    assert RFD.Doc.details(d) =~ "# RFD 2999 details: a test RFD\n\n"
    assert RFD.Doc.details(d) =~ "## How it was checked\n\nEvery number came from a run."
    assert RFD.Doc.readme(d) =~ "`DETAILS.md` carries the rest of this RFD."
    assert RFD.Doc.details(doc()) == nil
  end

  # Negative controls: each must be refused, or the DSL certifies the defect.
  test "an unknown state is refused" do
    assert ["state :draft is not one of" <> _] = RFD.Doc.problems(doc(state: :draft))
  end

  test "a missing Decision is refused unless the state is moved" do
    assert ["a Decision is required" <> _] = RFD.Doc.problems(doc(decision: nil))
    assert RFD.Doc.problems(doc(decision: nil, state: :moved)) == []
  end

  test "a README over 40 lines is refused" do
    long = Enum.map_join(1..40, "\n", &"line #{&1}")
    assert ["README renders to " <> _] = RFD.Doc.problems(doc(problem: long))
  end

  test "an em-dash join, a pompous copula and an exact on a soft noun are named as tropes" do
    assert [_] = RFD.Doc.tropes(doc(decision: "Do the thing — it matters."))
    assert [_] = RFD.Doc.tropes(doc(problem: "This is what makes it work."))
    assert [_] = RFD.Doc.tropes(doc(related: "the exact moment it failed"))
    assert RFD.Doc.tropes(doc()) == []
  end

  test "a tell fails validation wherever a reader sees text" do
    for bad <- [
          doc(decision: "Do the thing — it matters."),
          doc(decision: "Do the thing --\nit matters."),
          doc(decision: "Do the thing\n— it matters."),
          doc(problem: "Stages run in order – each one checked."),
          doc(feature: "a feature — with an aside"),
          doc(details: [{"Staging is what makes the tier", "Body."}])
        ] do
      assert_raise ArgumentError, ~r/prose carries/, fn -> RFD.Doc.validate!(bad) end
    end
  end

  test "list markers, Lean comments, hyphens and ranges are not tells" do
    ok = "- a list item\n  - a nested item\n\n    -- a Lean comment\n\nA well-known 1–3 range."
    assert RFD.Doc.tropes(doc(decision: ok)) == []
    assert %RFD.Doc{} = RFD.Doc.validate!(doc(decision: ok))
  end

  test "front matter and a preamble render in place and the pointer is not doubled" do
    d =
      doc(
        front_matter: "---\nname: x\n---",
        preamble: "Shelved 2026-09-02: waiting.",
        related: "See `DETAILS.md`.",
        details: [{"More", "body"}]
      )

    r = RFD.Doc.readme(d)
    assert String.starts_with?(r, "---\nname: x\n---\n\n# RFD 2999: a test RFD\n\n**State:**")
    assert r =~ "**Scope:** the scope\n\nShelved 2026-09-02: waiting.\n\n## Decision\n"
    assert length(Regex.scan(~r/DETAILS\.md/, r)) == 1
  end

  test "validate! raises with every reason at once" do
    assert_raise ArgumentError, ~r/outside RFD 1000's shape.*state.*Decision/s, fn ->
      RFD.Doc.validate!(doc(state: :draft, decision: nil))
    end
  end

  test "the DSL compiles a source into the same struct and refuses a broken one at compile time" do
    code = """
    defmodule RFDTestGood do
      use RFD.DSL
      rfd 2998, "good" do
        state :discussion
        decision "Do it."
        drafted_by :human
      end
    end
    """

    [{mod, _}] = Code.compile_string(code)
    assert %RFD.Doc{serial: 2998, state: :discussion, drafted_by: :human} = mod.__rfd__()

    broken =
      String.replace(code, "state :discussion", "state :whatever")
      |> String.replace("RFDTestGood", "RFDTestBad")

    assert_raise ArgumentError, ~r/state :whatever/, fn -> Code.compile_string(broken) end
  end

  defp compile!(name, body) do
    code = """
    defmodule #{name} do
      use RFD.DSL
      rfd 2997, "madr" do
        state :discussion
        decision "Do it."
    #{body}
        drafted_by :ai
      end
    end
    """

    [{mod, _}] = Code.compile_string(code)
    mod.__rfd__()
  end

  test "a madr block names the MADR headings and keeps its place among details" do
    d =
      compile!("RFDMadrGood", """
          details "Up front", "before the block"
          madr do
            context "The thing was not done."
            drivers ["cheap", "recorded"]
            options ["leave it", "do it"]
            outcome "Chosen option: do it."
            consequences good: ["it is done"], bad: ["it costs a run"]
            confirmation "The gate reads it."
            more_information "RFD 1000."
          end
          details "After", "after the block"
      """)

    assert Enum.map(d.details, &elem(&1, 0)) == [
             "Up front",
             "Context and problem statement",
             "Decision drivers",
             "Considered options",
             "Decision outcome",
             "Consequences",
             "Confirmation",
             "More information",
             "After"
           ]

    details = RFD.Doc.details(d)
    assert details =~ "## Decision drivers\n\n- cheap\n- recorded\n"
    assert details =~ "## Consequences\n\n- Good: it is done\n- Bad: it costs a run\n"
    assert details =~ "## Confirmation\n\nThe gate reads it."
  end

  test "a madr section given twice is refused" do
    assert_raise ArgumentError, ~r/section given twice: \[:context\]/, fn ->
      compile!("RFDMadrDup", """
          madr do
            context "a"
            context "b"
            outcome "c"
          end
      """)
    end
  end

  test "madr sections out of the template's order are refused" do
    assert_raise ArgumentError, ~r/sections run context, drivers/, fn ->
      compile!("RFDMadrOrder", """
          madr do
            context "a"
            consequences "b"
            outcome "c"
          end
      """)
    end
  end

  test "a madr block without a context or an outcome is refused" do
    assert_raise ArgumentError, ~r/states its outcome/, fn ->
      compile!("RFDMadrNoOutcome", """
          madr do
            context "a"
          end
      """)
    end

    assert_raise ArgumentError, ~r/states its context/, fn ->
      compile!("RFDMadrNoContext", """
          madr do
            outcome "a"
          end
      """)
    end
  end

  test "an empty madr block and a second one are refused" do
    assert_raise ArgumentError, ~r/declares no section/, fn ->
      compile!("RFDMadrEmpty", """
          madr do
          end
      """)
    end

    assert_raise ArgumentError, ~r/one block carries the template/, fn ->
      compile!("RFDMadrTwice", """
          madr do
            context "a"
            outcome "b"
          end

          madr do
            context "c"
            outcome "d"
          end
      """)
    end
  end

  test "a madr body that is neither a string nor a list of strings is refused" do
    assert_raise ArgumentError, ~r/options takes a non-empty list of strings/, fn ->
      compile!("RFDMadrBadList", """
          madr do
            context "a"
            options []
            outcome "b"
          end
      """)
    end

    assert_raise ArgumentError, ~r/takes a string or a list of strings/, fn ->
      compile!("RFDMadrBadBody", """
          madr do
            context "a"
            outcome :nope
          end
      """)
    end

    assert_raise ArgumentError, ~r/consequences takes good: and bad: only/, fn ->
      compile!("RFDMadrBadSide", """
          madr do
            context "a"
            outcome "b"
            consequences good: ["x"], ugly: ["y"]
          end
      """)
    end
  end

  defp rebac_source(name, rows) do
    head = """
    defmodule #{name} do
      use RFD.DSL
      rfd 2997, "rebac" do
        state :discussion
        decision "Do it."
        rebac do
          verb :owns, "holds the object as hardware"
    """

    head <> rows <> "\n    end\n    drafted_by :human\n  end\nend\n"
  end

  test "a rebac block becomes the doc's model and renders into DETAILS" do
    code = rebac_source("RFDTestReBAC", ~s|      relate "a", :owns, "card"|)
    [{mod, _}] = Code.compile_string(code)
    doc = mod.__rfd__()

    assert %RFD.ReBAC{tuples: [%{subject: "a", verb: :owns}]} = doc.rebac
    assert RFD.Doc.details(doc) =~ "## The verbs\n\n| verb | meaning |"
    assert RFD.Doc.details(doc) =~ "## The tuples\n\n```rebac\na--owns--card\n```"
    assert RFD.Doc.readme(doc) =~ "`DETAILS.md` carries the rest of this RFD."
  end

  test "a tuple over an undeclared verb is refused at compile time" do
    code = rebac_source("RFDTestReBACVerb", ~s|      relate "a", :drives, "card"|)

    assert_raise ArgumentError, ~r/`drives` is not a declared verb/, fn ->
      Code.compile_string(code)
    end
  end

  test "a denial without its reason is refused at compile time" do
    code = rebac_source("RFDTestReBACDeny", ~s|      deny "a", :owns, "card", ""|)

    assert_raise ArgumentError, ~r/a denial carries its reason/, fn ->
      Code.compile_string(code)
    end
  end

  test "two rebac blocks in one RFD are refused" do
    second = ~s|        end\n        rebac do\n          verb :hosts, "hosts it"|
    code = rebac_source("RFDTestReBACTwice", ~s|      relate "a", :owns, "card"\n| <> second)

    assert_raise ArgumentError, ~r/one block carries the model/, fn ->
      Code.compile_string(code)
    end
  end

  test "a capability with an unknown field is refused" do
    code = rebac_source("RFDTestReBACCap", ~s|      capability :send, objekt: "relay"|)

    assert_raise ArgumentError, ~r/unknown fields \[:objekt\]/, fn ->
      Code.compile_string(code)
    end
  end
end
