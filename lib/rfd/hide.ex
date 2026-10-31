# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule RFD.Hide do
  @moduledoc """
  The HIDE beats every live RFD declares: `hook`, `intrigue`, `exit`, and the decision as
  the Delivery.

  - `hook`: one paragraph, the promise. The README prints it in bold above the decision.
  - `intrigue`: one paragraph that ends in a sentence. The README prints it first in the
    problem.
  - `exit`: one paragraph that ends in a period and is not a list item, a table row or a
    code fence. The README prints it last in the decision.
  """

  @list_marker ~r/^\s*(?:[-*|]|\d+[.)]|```|:)/
  @sentence_end ~r/[.?]$/

  @doc "The beats a document lacks, as the keywords that declare them."
  def missing(%{} = d) do
    []
    |> add(:hook, not one_paragraph?(d.hook))
    |> add(:intrigue, not (one_paragraph?(d.intrigue) and d.intrigue =~ @sentence_end))
    |> add(:exit, not exit?(d.exit))
    |> Enum.reverse()
  end

  def problems(%{state: :abandoned}), do: []
  def problems(%{decision: nil}), do: []

  def problems(d) do
    case missing(d) do
      [] -> []
      lacking -> ["lacks the HIDE beats #{inspect(lacking)}: declare hook, intrigue and exit"]
    end
  end

  defp add(acc, _beat, false), do: acc
  defp add(acc, beat, true), do: [beat | acc]

  defp one_paragraph?(text) when is_binary(text) do
    t = String.trim(text)
    t != "" and not Regex.match?(~r/\n[ \t]*\n/, t) and not String.starts_with?(t, "**")
  end

  defp one_paragraph?(_), do: false

  defp exit?(text) do
    one_paragraph?(text) and not (String.trim(text) =~ @list_marker) and
      String.trim(text) =~ ~r/\.$/
  end
end
