# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule ReBACTest do
  use ExUnit.Case, async: true

  alias RFD.ReBAC

  defp verbs, do: [%{name: :owns, meaning: "holds the object as hardware"}]

  defp block(overrides \\ []) do
    struct!(
      ReBAC,
      Keyword.merge(
        [
          verbs: verbs(),
          tuples: [%{subject: "a", verb: :owns, object: "card", deny: false, reason: nil}]
        ],
        overrides
      )
    )
  end

  defp known(block), do: MapSet.new(ReBAC.verb_names(block))

  defp problems(block), do: ReBAC.problems(block, known(block))

  test "a well-formed block has no problems and renders its three tables" do
    b = block()
    assert problems(b) == []

    assert ReBAC.verb_table(b) ==
             "| verb | meaning |\n|---|---|\n| `owns` | holds the object as hardware |"

    assert ReBAC.tuple_block(b) == "```rebac\na--owns--card\n```"
    assert ReBAC.capability_table(b) == nil
  end

  test "a verb atom and its row text convert both ways" do
    assert ReBAC.verb_text(:may_use) == "may-use"
    assert ReBAC.verb_atom("may-use") == :may_use
    assert ReBAC.verb_atom(ReBAC.verb_text(:runs_on)) == :runs_on
  end

  test "a row round-trips through text" do
    t = %{subject: "a", verb: :runs_on, object: "box", deny: true, reason: "no key"}
    assert ReBAC.row(t) == "a--!runs-on--box  # no key"
    assert ReBAC.parse_row(ReBAC.row(t)) == {:ok, t}
    assert ReBAC.parse_row("not a row") == :error
  end

  test "capabilities render with their caveats" do
    b =
      block(
        verbs: [%{name: :transfer, meaning: "moves the object between zones"}],
        tuples: [],
        capabilities: [%{name: :transfer, verb: :transfer, object: "vm", caveats: [:vm, :epoch]}]
      )

    assert problems(b) == []

    assert ReBAC.capability_table(b) ==
             "| capability | verb | object | caveats |\n|---|---|---|---|\n" <>
               "| `transfer` | `transfer` | `vm` | `vm`, `epoch` |"
  end

  test "rows_for narrows to one subject" do
    b =
      block(
        tuples: [
          %{subject: "a", verb: :owns, object: "card", deny: false, reason: nil},
          %{subject: "b", verb: :owns, object: "box", deny: false, reason: nil}
        ]
      )

    assert ReBAC.rows_for(b, "a") == ["a--owns--card"]
    assert length(ReBAC.rows_for(b, nil)) == 2
  end

  test "a document's fenced block is read, replaced and checked" do
    text = "Intro.\n\n```rebac\n# a note\na--owns--card\n```\n\nTail.\n"
    assert ReBAC.block_rows(text) == [{5, "a--owns--card"}]
    assert ReBAC.document_problems(text, known(block())) == []
    assert ReBAC.put_block(text, ["b--owns--box"]) =~ "```rebac\nb--owns--box\n```"
    refute ReBAC.put_block(text, ["b--owns--box"]) =~ "a--owns--card"
  end

  # Negative controls: each must be refused, or the model certifies the defect.
  test "a verb with no meaning is refused" do
    assert ["verb :owns states no meaning"] =
             problems(block(verbs: [%{name: :owns, meaning: " "}]))
  end

  test "a verb declared twice is refused" do
    b = block(verbs: verbs() ++ verbs())
    assert "verb :owns is declared 2 times" in problems(b)
  end

  test "an uppercase segment is refused" do
    b = block(tuples: [%{subject: "A", verb: :owns, object: "card", deny: false, reason: nil}])
    assert ["A--owns--card: subject \"A\" is not lowercase kebab"] = problems(b)
  end

  test "a verb no block declares is refused" do
    b = block(tuples: [%{subject: "a", verb: :drives, object: "card", deny: false, reason: nil}])
    assert ["a--drives--card: `drives` is not a declared verb"] = problems(b)
  end

  test "a denial without its reason is refused" do
    b = block(tuples: [%{subject: "a", verb: :owns, object: "card", deny: true, reason: nil}])
    assert ["a--!owns--card: a denial carries its reason"] = problems(b)
  end

  test "a repeated row is refused" do
    row = %{subject: "a", verb: :owns, object: "card", deny: false, reason: nil}
    assert ["a--owns--card repeats"] = problems(block(tuples: [row, row]))
  end

  test "a relation granted and denied is refused" do
    b =
      block(
        tuples: [
          %{subject: "a", verb: :owns, object: "card", deny: false, reason: nil},
          %{subject: "a", verb: :owns, object: "card", deny: true, reason: "no"}
        ]
      )

    assert "a--owns--card is both granted and denied" in problems(b)
  end

  test "a capability with no caveat is refused" do
    b = block(capabilities: [%{name: :send, verb: :owns, object: "relay", caveats: []}])
    assert ["capability :send states no caveats"] = problems(b)
  end

  test "a capability repeating a caveat is refused" do
    b = block(capabilities: [%{name: :send, verb: :owns, object: "relay", caveats: [:vm, :vm]}])
    assert ["capability :send repeats a caveat"] = problems(b)
  end

  test "a capability over an undeclared verb is refused" do
    b = block(capabilities: [%{name: :send, verb: :emits, object: "relay", caveats: [:vm]}])
    assert ["capability :send: `emits` is not a declared verb"] = problems(b)
  end

  test "verbs_from and renders_into are checked" do
    assert ["verbs_from 99 is not a four-digit serial"] = problems(block(verbs_from: [99]))

    assert ["renders_into \"\" names no document" <> _] =
             problems(block(renders_into: [{"", nil}]))
  end

  test "a document with no block, or an unclosed one, is a reason rather than a pass" do
    assert ["no rebac block in the document"] =
             ReBAC.document_problems("Nothing.\n", MapSet.new())

    assert ["a rebac block is never closed"] =
             ReBAC.document_problems("```rebac\na--owns--b\n", MapSet.new())

    assert ReBAC.block_rows("Nothing.\n") == :no_block
    assert ReBAC.put_block("Nothing.\n", ["a--owns--b"]) == :no_block
  end

  test "a document row that is not a row is refused" do
    text = "```rebac\nnot a row\n```\n"

    assert ["line 2: not <subject>--<verb>--<object>" <> _] =
             ReBAC.document_problems(text, MapSet.new())
  end
end
