# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT
# Rewrite rfd/NNNN-slug.exs from the `defmodule RFDNNNN` form into the compact top-level form.
#
#     elixir scripts/compact_rfd.exs [rfd/NNNN-slug.exs ...]   # every source when none given
#     elixir scripts/compact_rfd.exs --self-test

defmodule CompactRFD do
  @note ~r/^RFD \d{4}\. `mix rfd\.render` renders .*build artifact \(RFD 2232\)\.$/s

  def convert(text) do
    with false <- String.contains?(text, "\nuse RFD.DSL\n") and {:error, "already compact"},
         [copy, spdx | rest] <- String.split(text, "\n"),
         true <- String.starts_with?(spdx, "# SPDX-License-Identifier:"),
         {note, [mod, "  use RFD.DSL" | rest]} <-
           Enum.split_while(rest, &String.starts_with?(&1, "#")),
         {:ok, serial} <- module_serial(mod),
         {:ok, kept} <- note_ok(note),
         {head, body} <- split_head(Enum.drop_while(rest, &(&1 == ""))),
         ["", "end", "  end" | inner] <- Enum.reverse(body),
         {:ok, lines, state} <- walk(Enum.reverse(inner)),
         {:ok, call} <- call(head, serial, state) do
      {:ok,
       Enum.join(
         [copy, spdx | kept] ++ ["use RFD.DSL", "", call <> " do"] ++ merge(lines) ++ ["end", ""],
         "\n"
       )}
    else
      {:error, why} -> {:error, why}
      _ -> {:error, "not the defmodule RFDNNNN / use RFD.DSL / rfd shape"}
    end
  end

  defp module_serial(line) do
    case Regex.run(~r/^defmodule RFD(\d{4}) do$/, line) do
      [_, s] -> {:ok, String.to_integer(s)}
      _ -> {:error, "module line #{inspect(line)}"}
    end
  end

  defp note_ok(note) do
    joined =
      note |> Enum.map(&String.replace(&1, ~r/^# ?/, "")) |> Enum.join(" ") |> String.trim()

    if note == [] or Regex.match?(@note, joined), do: {:ok, []}, else: {:ok, note}
  end

  defp split_head(lines) do
    case Enum.split_while(lines, &(not String.ends_with?(&1, " do"))) do
      {pre, [last | body]} -> {Enum.map_join(pre ++ [last], " ", &String.trim/1), body}
      _ -> :no_head
    end
  end

  defp call(head, serial, state) do
    with {:ok, {:rfd, _, [^serial, title]}} <-
           Code.string_to_quoted(String.replace_suffix(head, " do", "")),
         true <- is_binary(title) and state != nil do
      {:ok, "rfd #{serial}, #{inspect(title)}, #{state}"}
    else
      _ -> {:error, "rfd call #{inspect(head)} or no state field"}
    end
  end

  # Outside strings: blank lines and the default `drafted_by :ai` go; `state` moves to the call.
  defp walk(lines), do: walk(lines, :code, [], nil)
  defp walk([], :code, acc, state), do: {:ok, Enum.reverse(acc), state}
  defp walk([], _, _, _), do: {:error, "an unclosed string"}

  defp walk([line | rest], :plain, acc, state) do
    walk(rest, if(odd_quotes?(line), do: :code, else: :plain), [line | acc], state)
  end

  defp walk([line | rest], mode, acc, state) do
    trimmed = String.trim(line)

    cond do
      line != "" and not String.starts_with?(line, "  ") ->
        {:error, "a line indented less than the block: #{inspect(line)}"}

      mode == :heredoc ->
        next = if String.starts_with?(trimmed, ~s(""")), do: :code, else: :heredoc
        walk(rest, next, [dedent(line) | acc], state)

      trimmed == "" or line == "    drafted_by :ai" ->
        walk(rest, :code, acc, state)

      state == nil and Regex.match?(~r/^    state :[a-z]+$/, line) ->
        walk(rest, :code, acc, String.trim_leading(line, "    state "))

      String.ends_with?(trimmed, ~s(""")) and trimmed != ~s(""") ->
        walk(rest, :heredoc, [dedent(line) | acc], state)

      true ->
        walk(rest, if(odd_quotes?(line), do: :plain, else: :code), [dedent(line) | acc], state)
    end
  end

  defp odd_quotes?(line) do
    line
    |> String.replace(~S(\\), "")
    |> String.replace(~S(\"), "")
    |> String.graphemes()
    |> Enum.count(&(&1 == ~s(")))
    |> rem(2) == 1
  end

  # Runs of two or more `~S` heredoc fields become one `prose` heredoc.
  defp merge(lines) do
    lines
    |> group([])
    |> Enum.chunk_by(&match?({:prose, _}, &1))
    |> Enum.flat_map(fn
      [{:prose, _}, {:prose, _} | _] = run ->
        [~s(  prose ~S""")] ++
          Enum.flat_map(run, fn {:prose, {_, marked}} -> marked end) ++ [~s(  """)]

      run ->
        Enum.flat_map(run, fn
          {:prose, {orig, _}} -> orig
          {:line, l} -> [l]
        end)
    end)
  end

  defp group([], acc), do: Enum.reverse(acc)

  defp group([line | rest], acc) do
    with {:ok, marker} <- opener(line),
         {body, [~s(  """) | after_]} <- Enum.split_while(rest, &(&1 != ~s(  """))),
         false <- Enum.any?(body, &String.starts_with?(&1, "  :: ")) do
      group(after_, [{:prose, {[line | body] ++ [~s(  """)], ["  :: " <> marker | body]}} | acc])
    else
      _ -> group(rest, [{:line, line} | acc])
    end
  end

  defp opener(line) do
    {one, two} =
      {~w(decision problem references related preamble details_preamble), ~w(details section)}

    case Regex.run(~r/^  ([a-z_]+) (?:(".*"), )?~S"""$/, line) do
      [_, name] -> if name in one, do: {:ok, name}, else: :no
      [_, name, lit] -> if name in two, do: heading(name, lit), else: :no
      _ -> :no
    end
  end

  defp heading(name, lit) do
    case Code.string_to_quoted(lit) do
      {:ok, h} when is_binary(h) and h != "" ->
        if h == String.trim(h) and not String.contains?(h, "\n"),
          do: {:ok, "#{name} #{h}"},
          else: :no

      _ ->
        :no
    end
  end

  defp dedent(""), do: ""
  defp dedent("  " <> line), do: line

  def main(["--self-test"]) do
    good = """
    # Copyright (c) 2026 X
    # SPDX-License-Identifier: MIT
    #
    # RFD 1001. `mix rfd.render` renders rfd/1001-a/README.md and
    # DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
    defmodule RFD1001 do
      use RFD.DSL

      rfd 1001, "A" do
        state :discussion

        decision ~S\"""
        One.

        Two.
        \"""

        drafted_by :ai
      end
    end
    """

    want = """
    # Copyright (c) 2026 X
    # SPDX-License-Identifier: MIT
    use RFD.DSL

    rfd 1001, "A", :discussion do
      decision ~S\"""
      One.

      Two.
      \"""
    end
    """

    two =
      String.replace(
        good,
        "    drafted_by",
        "    details \"How\", ~S\"\"\"\n    Three.\n    \"\"\"\n\n    drafted_by"
      )

    clash = String.replace(two, "Three.", ":: problem")

    cases = [
      {"consecutive heredoc fields merge into one prose block",
       elem(convert(two), 1) =~
         "  prose ~S\"\"\"\n  :: decision\n  One.\n\n  Two.\n" <>
           "  :: details How\n  Three.\n  \"\"\"\n"},
      {"a body line that reads as a marker blocks the merge",
       not (elem(convert(clash), 1) =~ "prose ~S")},
      {"the standard shape converts", convert(good) == {:ok, want}},
      {"a header comment other than the render note is kept",
       match?(
         {:ok, "# Copyright (c) 2026 X\n# SPDX-License-Identifier: MIT\n# keep me\n" <> _},
         convert(String.replace(good, ~r/#\n.*2232\)\.\n/s, "# keep me\n"))
       )},
      {"a multi-line plain string keeps its continuation lines verbatim",
       match?(
         {:ok, _},
         convert(
           String.replace(
             good,
             "    state :discussion\n",
             "    state :discussion\n    feature \"a\n  b\n\nc\"\n"
           )
         )
       ) and
         elem(
           convert(
             String.replace(
               good,
               "    state :discussion\n",
               "    state :discussion\n    feature \"a\n  b\n\nc\"\n"
             )
           ),
           1
         ) =~ "  feature \"a\n  b\n\nc\"\n"},
      {"a source with no state is refused",
       match?({:error, _}, convert(String.replace(good, "    state :discussion\n", "")))},
      {"a module name that disagrees with the serial is refused",
       match?({:error, _}, convert(String.replace(good, "RFD1001 do", "RFD1002 do")))}
    ]

    for {name, ok} <- cases, do: IO.puts("#{if ok, do: "ok  ", else: "FAIL"} #{name}")
    if Enum.all?(cases, &elem(&1, 1)), do: :ok, else: System.halt(1)
  end

  def main(paths) do
    paths = if paths == [], do: Path.wildcard("rfd/[0-9][0-9][0-9][0-9]-*.exs"), else: paths

    for path <- Enum.sort(paths) do
      case convert(File.read!(path)) do
        {:ok, text} -> IO.puts("ok    #{path}") && File.write!(path, text)
        {:error, why} -> IO.puts("kept  #{path}: #{why}")
      end
    end
  end
end

CompactRFD.main(System.argv())

