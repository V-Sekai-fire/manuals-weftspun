# SPDX-License-Identifier: Apache-2.0 OR MIT
# Gate: every rebac block in CLAUDE.md is RFD 2200 tuples over the verbs RFD 2200's table names.
#
# Usage:
#     elixir scripts/check_rebac.exs [--doc CLAUDE.md] [--rfd rfd/2200-rebac-agent-roles.exs]
#     elixir scripts/check_rebac.exs --self-test
#
# Exit codes: 0 every row is well formed, 1 a row is not or a precondition is unmet, 2 bad usage.

defmodule ReBACGate do
  @rfd "rfd/2200-rebac-agent-roles.exs"
  @table "| verb | meaning |\n|---|---|\n| `owns` | x |\n| `reaches` | y |\n"
  @seg "[a-z0-9]+(?:-[a-z0-9]+)*"

  defp row_re, do: Regex.compile!("^(#{@seg})--(!?)(#{@seg})--(#{@seg})(?:\\s+#\\s*(\\S.*))?$")

  def verbs(rfd_text) do
    ~r/^\s*\|\s*`([a-z][a-z-]*)`\s*\|/m
    |> Regex.scan(rfd_text, capture: :all_but_first)
    |> List.flatten()
    |> MapSet.new()
  end

  def rows(doc_text) do
    {rows, open?, found?} =
      doc_text
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

  def check(doc_text, verbs) do
    case {MapSet.size(verbs), rows(doc_text)} do
      {0, _} -> ["RFD 2200's verb table is missing or empty"]
      {_, :no_block} -> ["no rebac block in the document"]
      {_, :unclosed} -> ["a rebac block is never closed"]
      {_, rows} -> row_errors(rows, verbs)
    end
  end

  defp row_errors(rows, verbs) do
    parsed = Enum.map(rows, fn {n, t} -> {n, t, Regex.run(row_re(), t)} end)

    shape =
      Enum.flat_map(parsed, fn
        {n, t, nil} -> ["line #{n}: not <subject>--<verb>--<object> in lowercase kebab: #{t}"]
        {n, _, [_, _, neg, v, _ | rest]} -> row_rules(n, neg, v, List.first(rest), verbs)
      end)

    tuples = for {n, _, [_, s, neg, v, o | _]} <- parsed, do: {n, {s, neg, v, o}}

    repeats =
      tuples
      |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))
      |> Enum.filter(fn {_, ns} -> length(ns) > 1 end)
      |> Enum.map(fn {{s, neg, v, o}, ns} ->
        "lines #{Enum.join(ns, ", ")}: #{s}--#{neg}#{v}--#{o} repeats"
      end)

    both =
      tuples
      |> Enum.group_by(fn {_, {s, _, v, o}} -> {s, v, o} end, fn {_, {_, neg, _, _}} -> neg end)
      |> Enum.filter(fn {_, negs} -> "" in negs and "!" in negs end)
      |> Enum.map(fn {{s, v, o}, _} -> "#{s}--#{v}--#{o} is both granted and denied" end)

    shape ++ Enum.sort(repeats) ++ Enum.sort(both)
  end

  defp row_rules(n, neg, v, reason, verbs) do
    unknown =
      if MapSet.member?(verbs, v), do: [], else: ["line #{n}: `#{v}` is not in RFD 2200's table"]

    bare =
      if neg == "!" and reason in [nil, ""],
        do: ["line #{n}: a denial carries its reason after #"],
        else: []

    unknown ++ bare
  end

  def run(argv) do
    case OptionParser.parse(argv, strict: [doc: :string, rfd: :string, self_test: :boolean]) do
      {[self_test: true], [], []} -> self_test()
      {opts, [], []} -> gate(opts[:doc] || "CLAUDE.md", opts[:rfd] || @rfd)
      _ -> usage()
    end
  end

  defp usage do
    IO.puts(:stderr, "usage: elixir scripts/check_rebac.exs [--doc F] [--rfd F] | --self-test")
    System.halt(2)
  end

  defp gate(doc, rfd) do
    with {:ok, d} <- File.read(doc), {:ok, r} <- File.read(rfd) do
      case check(d, verbs(r)) do
        [] ->
          tuples = rows(d)
          denials = Enum.count(tuples, fn {_, t} -> String.contains?(t, "--!") end)
          grants = length(tuples) - denials

          IO.puts(
            "check_rebac: #{length(tuples)} rows in #{doc} (#{grants} grants, " <>
              "#{denials} denials) over #{MapSet.size(verbs(r))} verbs from #{rfd}: PASS"
          )

        errors ->
          Enum.each(errors, &IO.puts("check_rebac: #{doc}: #{&1}"))
          System.halt(1)
      end
    else
      {:error, why} ->
        IO.puts("check_rebac: cannot read #{doc} or #{rfd}: #{:file.format_error(why)}")
        System.halt(1)
    end
  end

  defp doc(rows), do: "Intro.\n\n```rebac\n" <> Enum.join(rows, "\n") <> "\n```\n"

  defp self_test do
    v = verbs(@table)

    controls = [
      {"a well-formed block passes",
       doc(["# grants", "", "a--owns--card", "a--!reaches--box  # no key"]), v, true},
      {"an unknown verb fails", doc(["a--drives--card"]), v, false},
      {"a denial without its reason fails", doc(["a--!owns--card"]), v, false},
      {"an uppercase segment fails", doc(["A--owns--card"]), v, false},
      {"a repeated row fails", doc(["a--owns--card", "a--owns--card"]), v, false},
      {"a relation granted and denied fails",
       doc(["a--owns--card", "a--!owns--card # no"]), v, false},
      {"a document with no rebac block fails", "Nothing here.\n", v, false},
      {"an unclosed rebac block fails", "```rebac\na--owns--card\n", v, false},
      {"an RFD with no verb table fails", doc(["a--owns--card"]), verbs("no table"), false}
    ]

    results =
      for {name, text, vs, want} <- controls do
        got = check(text, vs) == []
        IO.puts("  #{if got == want, do: "ok  ", else: "FAIL"} #{name}")
        got == want
      end

    passed = Enum.count(results, & &1)
    IO.puts("check_rebac self-test: #{passed}/#{length(results)} controls behave")
    if passed != length(results), do: System.halt(1)
  end
end

ReBACGate.run(System.argv())
