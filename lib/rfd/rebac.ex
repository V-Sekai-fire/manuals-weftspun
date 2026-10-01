# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule RFD.ReBAC do
  @moduledoc """
  Capability-ReBAC as data (RFD 2291): the verb vocabulary, the tuples over it and
  the capabilities a tuple mints. The DSL and `scripts/check_rebac.exs` both apply
  the rules here, and the tables and fenced blocks render from the declarations.

  A verb is an atom and its text form is kebab: `:runs_on` is `runs-on` in a row.
  """

  @segment ~r/^[a-z0-9]+(?:-[a-z0-9]+)*$/
  @seg "[a-z0-9]+(?:-[a-z0-9]+)*"

  defstruct verbs: [], tuples: [], capabilities: [], verbs_from: [], renders_into: []

  @type verb :: %{name: atom(), meaning: String.t()}
  @type tuple_row :: %{
          subject: String.t(),
          verb: atom(),
          object: String.t(),
          deny: boolean(),
          reason: String.t() | nil
        }
  @type capability :: %{name: atom(), verb: atom(), object: String.t(), caveats: [atom()]}
  @type t :: %__MODULE__{}

  def row_re, do: Regex.compile!("^(#{@seg})--(!?)(#{@seg})--(#{@seg})(?:\\s+#\\s*(\\S.*))?$")

  def verb_text(name), do: name |> Atom.to_string() |> String.replace("_", "-")

  def verb_atom(text), do: text |> String.replace("-", "_") |> String.to_atom()

  def verb_names(%__MODULE__{verbs: verbs}), do: Enum.map(verbs, & &1.name)

  @doc "One row of text as a tuple, or `:error` when it is not a row."
  def parse_row(text) do
    case Regex.run(row_re(), String.trim(text)) do
      nil ->
        :error

      [_, subject, neg, verb, object | rest] ->
        {:ok,
         %{
           subject: subject,
           verb: verb_atom(verb),
           object: object,
           deny: neg == "!",
           reason: List.first(rest)
         }}
    end
  end

  def row(%{} = t) do
    if t.reason in [nil, ""], do: head(t), else: head(t) <> "  # " <> t.reason
  end

  defp head(t), do: "#{t.subject}--#{if t.deny, do: "!"}#{verb_text(t.verb)}--#{t.object}"

  # Reasons line up in a column, because a block is read down its reasons.
  defp aligned(tuples) do
    width =
      tuples
      |> Enum.reject(&(&1.reason in [nil, ""]))
      |> Enum.map(&String.length(head(&1)))
      |> Enum.max(fn -> 0 end)

    for t <- tuples do
      if t.reason in [nil, ""],
        do: head(t),
        else: String.pad_trailing(head(t), width) <> "  # " <> t.reason
    end
  end

  @doc """
  Every reason the block is not well formed. `known` is the vocabulary a tuple may
  use, or `nil` to skip that check until `verbs_from` resolves over the corpus.
  """
  def problems(%__MODULE__{} = r, known \\ nil) do
    verb_problems(r) ++
      tuple_problems(r, known) ++
      capability_problems(r, known) ++
      pointer_problems(r)
  end

  defp verb_problems(%{verbs: verbs}) do
    shape =
      Enum.flat_map(verbs, fn v ->
        name =
          if is_atom(v.name) and Regex.match?(@segment, verb_text(v.name)),
            do: [],
            else: ["verb #{inspect(v.name)} is not a lowercase-kebab atom"]

        meaning =
          if is_binary(v.meaning) and String.trim(v.meaning) != "",
            do: [],
            else: ["verb #{inspect(v.name)} states no meaning"]

        name ++ meaning
      end)

    shape ++
      for {n, c} <- Enum.frequencies(Enum.map(verbs, & &1.name)),
          c > 1,
          do: "verb #{inspect(n)} is declared #{c} times"
  end

  defp tuple_problems(%{tuples: tuples}, known) do
    shape =
      Enum.flat_map(tuples, fn t ->
        segments =
          for {field, value} <- [subject: t.subject, object: t.object],
              not (is_binary(value) and Regex.match?(@segment, value)),
              do: "#{row(t)}: #{field} #{inspect(value)} is not lowercase kebab"

        unknown =
          if known == nil or MapSet.member?(known, t.verb),
            do: [],
            else: ["#{row(t)}: `#{verb_text(t.verb)}` is not a declared verb"]

        bare =
          if t.deny and String.trim(t.reason || "") == "",
            do: ["#{row(t)}: a denial carries its reason"],
            else: []

        segments ++ unknown ++ bare
      end)

    repeats =
      for {{s, d, v, o}, c} <-
            Enum.frequencies(for t <- tuples, do: {t.subject, t.deny, t.verb, t.object}),
          c > 1,
          do: "#{s}--#{if d, do: "!", else: ""}#{verb_text(v)}--#{o} repeats"

    both =
      tuples
      |> Enum.group_by(&{&1.subject, &1.verb, &1.object}, & &1.deny)
      |> Enum.filter(fn {_, denies} -> true in denies and false in denies end)
      |> Enum.map(fn {{s, v, o}, _} ->
        "#{s}--#{verb_text(v)}--#{o} is both granted and denied"
      end)

    shape ++ Enum.sort(repeats) ++ Enum.sort(both)
  end

  # RFD 2288: a capability names one verb on one object, and its caveats bound it.
  defp capability_problems(%{capabilities: caps}, known) do
    shape =
      Enum.flat_map(caps, fn c ->
        object =
          if is_binary(c.object) and Regex.match?(@segment, c.object),
            do: [],
            else: [
              "capability #{inspect(c.name)}: object #{inspect(c.object)} is not lowercase kebab"
            ]

        verb =
          if known == nil or MapSet.member?(known, c.verb),
            do: [],
            else: ["capability #{inspect(c.name)}: `#{verb_text(c.verb)}` is not a declared verb"]

        caveats =
          cond do
            not (is_list(c.caveats) and c.caveats != []) ->
              ["capability #{inspect(c.name)} states no caveats"]

            not Enum.all?(c.caveats, &is_atom/1) ->
              ["capability #{inspect(c.name)}: each caveat is an atom"]

            length(Enum.uniq(c.caveats)) != length(c.caveats) ->
              ["capability #{inspect(c.name)} repeats a caveat"]

            true ->
              []
          end

        object ++ verb ++ caveats
      end)

    shape ++
      for {n, c} <- Enum.frequencies(Enum.map(caps, & &1.name)),
          c > 1,
          do: "capability #{inspect(n)} is declared #{c} times"
  end

  defp pointer_problems(%{verbs_from: from, renders_into: into}) do
    serials =
      for s <- from,
          not (is_integer(s) and s in 1000..9999),
          do: "verbs_from #{inspect(s)} is not a four-digit serial"

    docs =
      for {path, subject} <- into,
          not (is_binary(path) and path != "" and
                 (subject == nil or Regex.match?(@segment, subject))),
          do: "renders_into #{inspect(path)} names no document or no kebab subject"

    serials ++ docs
  end

  @doc "The rows this block renders into `path`, which is every row when no subject narrows it."
  def rows_for(%__MODULE__{tuples: tuples}, nil), do: aligned(tuples)

  def rows_for(%__MODULE__{tuples: tuples}, subject) do
    aligned(for t <- tuples, t.subject == subject, do: t)
  end

  def verb_table(%__MODULE__{verbs: []}), do: nil

  def verb_table(%__MODULE__{verbs: verbs}) do
    rows = for v <- verbs, do: "| `#{verb_text(v.name)}` | #{v.meaning} |"
    Enum.join(["| verb | meaning |", "|---|---|" | rows], "\n")
  end

  def tuple_block(%__MODULE__{tuples: []}), do: nil

  def tuple_block(%__MODULE__{} = r) do
    "```rebac\n" <> Enum.join(rows_for(r, nil), "\n") <> "\n```"
  end

  def capability_table(%__MODULE__{capabilities: []}), do: nil

  def capability_table(%__MODULE__{capabilities: caps}) do
    rows =
      for c <- caps do
        caveats = Enum.map_join(c.caveats, ", ", &"`#{&1}`")
        "| `#{c.name}` | `#{verb_text(c.verb)}` | `#{c.object}` | #{caveats} |"
      end

    Enum.join(["| capability | verb | object | caveats |", "|---|---|---|---|" | rows], "\n")
  end

  @doc "Every reason the fenced block in `text` is not well formed; no block is one."
  def document_problems(text, known) do
    case block_rows(text) do
      :no_block ->
        ["no rebac block in the document"]

      :unclosed ->
        ["a rebac block is never closed"]

      rows ->
        {bad, parsed} =
          Enum.split_with(rows, fn {_, line} -> parse_row(line) == :error end)

        shape =
          for {n, line} <- bad,
              do: "line #{n}: not <subject>--<verb>--<object> in lowercase kebab: #{line}"

        tuples = for {_, line} <- parsed, {:ok, t} <- [parse_row(line)], do: t
        shape ++ problems(%__MODULE__{tuples: tuples}, known)
    end
  end

  def block_rows(text) do
    {rows, open?, found?} =
      text
      |> String.split("\n")
      |> Enum.with_index(1)
      |> Enum.reduce({[], false, false}, fn {line, n}, {acc, inside, found} ->
        t = String.trim(line)

        cond do
          not inside and t == "```rebac" -> {acc, true, true}
          inside and t == "```" -> {acc, false, found}
          inside and (t == "" or String.starts_with?(t, "#")) -> {acc, inside, found}
          inside -> {[{n, t} | acc], inside, found}
          true -> {acc, inside, found}
        end
      end)

    cond do
      not found? -> :no_block
      open? -> :unclosed
      true -> Enum.reverse(rows)
    end
  end

  @doc "`text` with its fenced `rebac` block replaced by `rows`, or `:no_block`."
  def put_block(text, rows) do
    lines = String.split(text, "\n")

    with open when is_integer(open) <- Enum.find_index(lines, &(String.trim(&1) == "```rebac")),
         close when is_integer(close) <-
           Enum.find_index(Enum.drop(lines, open + 1), &(String.trim(&1) == "```")) do
      head = Enum.take(lines, open + 1)
      tail = Enum.drop(lines, open + 1 + close)
      Enum.join(head ++ rows ++ tail, "\n")
    else
      nil -> :no_block
    end
  end
end
