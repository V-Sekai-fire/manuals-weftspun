# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule RFDHideTest do
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
          hook: "Do the thing.",
          intrigue: "The thing was not done.",
          exit: "Run the steps.",
          decision: "It is done in steps.",
          problem: "It waits.",
          related: "RFD 1000.",
          drafted_by: :ai
        ],
        overrides
      )
    )
  end

  test "an RFD that declares all three beats has no HIDE problem" do
    assert RFD.Hide.missing(doc()) == []
    assert RFD.Hide.problems(doc()) == []
  end

  test "the README prints the Hook in bold, the Delivery, the Exit, and the Intrigue first" do
    readme = RFD.Doc.readme(doc())

    assert readme =~
             "## Decision\n\n**Do the thing.**\n\nIt is done in steps.\n\nRun the steps.\n"

    assert readme =~ "## Problem\n\nThe thing was not done.\n\nIt waits.\n"
  end

  # Negative controls: each beat removed on its own must be named, or the rule is decoration.
  test "a missing hook, intrigue or exit is refused by name" do
    assert RFD.Hide.missing(doc(hook: nil)) == [:hook]
    assert RFD.Hide.missing(doc(intrigue: nil)) == [:intrigue]
    assert RFD.Hide.missing(doc(exit: nil)) == [:exit]
    assert [reason] = RFD.Hide.problems(doc(hook: nil))
    assert reason =~ "lacks the HIDE beats [:hook]"
  end

  test "a hook that carries its own bold marks, or two paragraphs, is refused" do
    assert RFD.Hide.missing(doc(hook: "**Do the thing.**")) == [:hook]
    assert RFD.Hide.missing(doc(hook: "Do it.\n\nThen more.")) == [:hook]
  end

  test "an intrigue that is not a finished sentence is refused" do
    assert RFD.Hide.missing(doc(intrigue: "the thing was not done")) == [:intrigue]
  end

  test "an exit that is a list item, a table row or has no period is refused" do
    assert RFD.Hide.missing(doc(exit: "- run the steps.")) == [:exit]
    assert RFD.Hide.missing(doc(exit: "| a | b |")) == [:exit]
    assert RFD.Hide.missing(doc(exit: "Run the steps")) == [:exit]
  end

  test "an abandoned stub and a missing decision are outside the rule" do
    bare = [hook: nil, intrigue: nil, exit: nil]
    assert RFD.Hide.problems(doc([state: :abandoned, decision: nil] ++ bare)) == []
    assert RFD.Hide.problems(doc([decision: nil] ++ bare)) == []
  end

  test "validate! refuses a new RFD without the beats" do
    bare = [hook: nil, intrigue: nil, exit: nil]

    assert_raise ArgumentError, ~r/lacks the HIDE beats/, fn ->
      RFD.Doc.validate!(doc(bare))
    end
  end

  test "the DSL takes hook, intrigue and exit as keywords and as prose fields" do
    code = """
    use RFD.DSL
    rfd 2995, "beats", :discussion do
      prose ~S\"""
      :: hook
      Do it.
      :: intrigue
      It was not done.
      :: exit
      Run it.
      :: decision
      It runs.
      :: problem
      It waits.
      \"""
    end
    """

    [{mod, _}] = Code.compile_string(code)
    d = mod.__rfd__()
    assert %RFD.Doc{hook: "Do it.\n", intrigue: "It was not done.\n", exit: "Run it.\n"} = d
    assert RFD.Hide.problems(d) == []
  end
end
