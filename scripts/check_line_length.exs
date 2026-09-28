# SPDX-License-Identifier: Apache-2.0 OR MIT
# Gate: a line added to an .ex or .exs file stays within .formatter.exs's line_length.
#
# Usage:
#     elixir scripts/check_line_length.exs [--base HEAD] [--fix]
#     elixir scripts/check_line_length.exs --self-test
#
# Exit codes: 0 within the limit, 1 a line over it or no limit stated, 2 bad usage.

defmodule LineLength do
  @exts [".ex", ".exs"]
  @string_with_newlines ~r/^(\s*[a-z_]+ )"((?:[^"\\]|\\.)*\\n(?:[^"\\]|\\.)*)"$/u
  # A hook's GIT_DIR and friends override -C, so they are dropped from every git call.
  @git_env Enum.map(
             ~w(GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY
                GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_PREFIX GIT_COMMON_DIR),
             &{&1, nil}
           )

  def git(repo, args) do
    case System.cmd("git", ["-C", repo | args], env: @git_env, stderr_to_stdout: true) do
      {out, 0} -> out
      _ -> ""
    end
  end

  defp len(s), do: length(String.codepoints(s))
  defp read(path), do: path |> File.read!() |> String.replace(~r/\r\n?/, "\n")
  defp lead(s), do: len(s) - len(String.trim_leading(s))

  def limit_of(repo) do
    path = Path.join(repo, ".formatter.exs")

    with true <- File.exists?(path),
         [_, n] <- Regex.run(~r/line_length:\s*(\d+)/, read(path)) do
      String.to_integer(n)
    else
      _ -> nil
    end
  end

  def added_lines(repo, base) do
    against = if base == "HEAD", do: ["--cached"], else: [base]

    git(repo, ["diff", "-U0", "--no-color" | against])
    |> String.split("\n")
    |> Enum.reduce({%{}, nil, 0}, fn row, {added, path, line} ->
      cond do
        String.starts_with?(row, "+++ ") ->
          p = if String.starts_with?(row, "+++ b/"), do: String.slice(row, 6..-1//1)
          {added, p, line}

        String.starts_with?(row, "@@") and path != nil ->
          [_, n] = Regex.run(~r/@@ -\S+ \+(\d+)/, row)
          {added, path, String.to_integer(n)}

        String.starts_with?(row, "+") and path != nil and String.ends_with?(path, @exts) ->
          {Map.update(added, path, MapSet.new([line]), &MapSet.put(&1, line)), path, line + 1}

        true ->
          {added, path, line}
      end
    end)
    |> elem(0)
  end

  def heredoc_indent(lines) do
    lines
    |> Enum.with_index()
    |> Enum.reduce({false, false, 0, %{}}, fn {text, i}, {inside, sigil, start, spans} = acc ->
      quotes = length(String.split(text, ~s("""))) - 1
      r = String.trim_trailing(text)

      cond do
        not inside and quotes == 1 and String.ends_with?(r, ~s(""")) ->
          {true, String.ends_with?(r, ~s(~S""")), i + 1, spans}

        inside and String.starts_with?(String.trim(text), ~s(""")) ->
          spans =
            if sigil and start < i,
              do: Enum.reduce(start..(i - 1), spans, &Map.put(&2, &1, lead(text))),
              else: spans

          {false, sigil, start, spans}

        true ->
          acc
      end
    end)
    |> elem(3)
  end

  defp fixable(text, indent) do
    s = String.trim(text)
    s != "" and not String.starts_with?(s, "|") and lead(text) == indent
  end

  # textwrap.wrap with break_long_words and break_on_hyphens off.
  def wrap(text, width, pad) do
    chunks =
      text
      |> expand_tabs()
      |> String.replace(~r/\s/u, " ")
      |> then(&Regex.split(~r/( +)/, &1, include_captures: true, trim: true))

    wrap_lines(chunks, width - len(pad), pad, [])
  end

  defp wrap_lines([], _w, _pad, acc), do: Enum.reverse(acc)

  defp wrap_lines(chunks, w, pad, acc) do
    chunks = if acc != [] and String.trim(hd(chunks)) == "", do: tl(chunks), else: chunks
    {cur, rest} = fill(chunks, w, [], 0)

    {cur, rest} =
      if rest != [] and cur == [] and len(hd(rest)) > w,
        do: {[hd(rest)], tl(rest)},
        else: {cur, rest}

    cur = if cur != [] and String.trim(hd(cur)) == "", do: tl(cur), else: cur
    acc = if cur != [], do: [pad <> Enum.join(Enum.reverse(cur)) | acc], else: acc
    wrap_lines(rest, w, pad, acc)
  end

  defp fill([c | rest] = all, w, cur, n) do
    if n + len(c) <= w, do: fill(rest, w, [c | cur], n + len(c)), else: {cur, all}
  end

  defp fill([], _w, cur, _n), do: {cur, []}

  defp expand_tabs(s) do
    s
    |> String.codepoints()
    |> Enum.reduce({"", 0}, fn
      "\t", {out, col} -> {out <> String.duplicate(" ", 8 - rem(col, 8)), col + 8 - rem(col, 8)}
      c, {out, _} when c in ["\n", "\r"] -> {out <> c, 0}
      c, {out, col} -> {out <> c, col + 1}
    end)
    |> elem(0)
  end

  def fix(repo, path, nums, limit) do
    full = Path.join(repo, path)
    lines = String.split(read(full), "\n")
    spans = heredoc_indent(lines)

    out =
      lines
      |> Enum.with_index()
      |> Enum.flat_map(fn {text, i} ->
        long = MapSet.member?(nums, i + 1) and len(text) > limit
        escaped = Regex.run(@string_with_newlines, text)

        cond do
          long and escaped != nil and not Map.has_key?(spans, i) ->
            [_, g1, g2] = escaped
            String.split(g1 <> ~s(") <> g2 <> ~s("), "\\n")

          long and Map.has_key?(spans, i) and fixable(text, spans[i]) ->
            wrapped = wrap(String.trim(text), limit, String.duplicate(" ", spans[i]))
            if Enum.max(Enum.map(wrapped, &len/1)) <= limit, do: wrapped, else: [text]

          true ->
            [text]
        end
      end)

    File.write!(full, Enum.join(out, "\n"))
  end

  def check(repo, base, do_fix \\ false, verbose \\ true) do
    case limit_of(repo) do
      nil ->
        if verbose,
          do: IO.puts("FAIL: .formatter.exs states no line_length, so there is no limit to check")

        1

      limit ->
        added = added_lines(repo, base)

        added =
          if do_fix do
            for {p, nums} <- added,
                File.exists?(Path.join(repo, p)),
                do: fix(repo, p, nums, limit)

            added_lines(repo, base)
          else
            added
          end

        bad =
          for {p, nums} <- Enum.sort(added),
              full = Path.join(repo, p),
              File.exists?(full),
              lines = String.split(read(full), "\n"),
              n <- Enum.sort(nums),
              n <= length(lines),
              len(Enum.at(lines, n - 1)) > limit do
            "#{p}:#{n} is #{len(Enum.at(lines, n - 1))} columns, over #{limit}"
          end

        if verbose do
          Enum.each(bad, &IO.puts("  " <> &1))
          tag = if bad == [], do: "ok  ", else: "FAIL"

          IO.puts(
            "#{tag} #{map_size(added)} changed Elixir file(s), " <>
              "#{length(bad)} added line(s) over #{limit}"
          )
        end

        if bad == [], do: 0, else: 1
    end
  end

  defp scratch do
    dir = Path.join(System.tmp_dir!(), "line-length-#{System.unique_integer([:positive])}")
    File.mkdir_p!(dir)
    dir
  end

  defp w(repo, name, body), do: File.write!(Path.join(repo, name), body)

  def controls do
    long_prose = "    " <> Enum.join(List.duplicate("word", 30), " ")
    long_code = "  def f, do: " <> String.duplicate("x + ", 30) <> "x"
    escaped = Enum.join(List.duplicate("short words here", 5), "\\n")

    cases = [
      {"a short added line passes", [{"a.exs", "short = 1"}], nil, 0, false},
      {"a long added line fails", [{"a.exs", long_code}], nil, 1, false},
      {"a long line already on the base is not asked for", [], {"a.exs", long_code}, 0, false},
      {"no line_length in .formatter.exs fails", [{"a.exs", "short = 1"}], nil, 1, :nolimit},
      {"--fix rewraps long heredoc prose and then passes",
       [{"a.exs", ~s(  x ~S"""\n) <> long_prose <> ~s(\n    """)}], nil, 0, :fix},
      {"--fix leaves a long code line failing", [{"a.exs", long_code}], nil, 1, :fix},
      {"--fix leaves an interpolating heredoc alone",
       [{"a.exs", ~s(  x """\n) <> long_prose <> ~S( #{a}) <> ~s(\n    """)}], nil, 1, :fix},
      {"--fix turns \\n escapes in a long string into line breaks and then passes",
       [{"a.exs", ~s(    feature ") <> escaped <> ~s(")}], nil, 0, :fix}
    ]

    for {label, staged, committed, want, mode} <- cases do
      repo = scratch()
      git(repo, ["init", "-q"])
      git(repo, ["config", "user.email", "t@t"])
      git(repo, ["config", "user.name", "t"])

      w(
        repo,
        ".formatter.exs",
        if(mode == :nolimit, do: "[inputs: []]", else: "[line_length: 40]") <> "\n"
      )

      if committed, do: w(repo, elem(committed, 0), elem(committed, 1) <> "\n")
      git(repo, ["add", "-A"])
      git(repo, ["commit", "-q", "-m", "base"])
      if committed, do: File.write!(Path.join(repo, elem(committed, 0)), "short = 1\n", [:append])
      Enum.each(staged, fn {name, body} -> w(repo, name, body <> "\n") end)
      git(repo, ["add", "-A"])
      got = check(repo, "HEAD", mode == :fix, false)

      got =
        if mode == :fix do
          git(repo, ["add", "-A"])
          check(repo, "HEAD", false, false)
        else
          got
        end

      File.rm_rf!(repo)
      {label, got == want}
    end
  end

  def commits(repo), do: git(repo, ["rev-list", "--all", "--count"]) |> String.trim()

  def self_test do
    results = controls()
    outer = scratch()
    git(outer, ["init", "-q"])

    git(outer, [
      "-c",
      "user.email=t@t",
      "-c",
      "user.name=t",
      "commit",
      "-q",
      "--allow-empty",
      "-m",
      "o"
    ])

    before = commits(outer)
    System.put_env("GIT_DIR", Path.join(outer, ".git"))
    inner = controls()
    System.delete_env("GIT_DIR")
    kept = commits(outer) == before and Enum.all?(inner, &elem(&1, 1))
    File.rm_rf!(outer)
    results = results ++ [{"an inherited GIT_DIR gains no scratch commits", kept}]

    Enum.each(results, fn {label, ok} ->
      IO.puts("  #{if ok, do: "ok  ", else: "FAIL"} #{label}")
    end)

    bad = Enum.count(results, &(not elem(&1, 1)))
    IO.puts("\n#{bad} control(s) wrong")
    if bad == 0, do: 0, else: 1
  end
end

case OptionParser.parse(System.argv(),
       strict: [base: :string, fix: :boolean, self_test: :boolean]
     ) do
  {opts, [], []} ->
    if opts[:self_test] do
      System.halt(LineLength.self_test())
    else
      top = String.trim(LineLength.git(".", ["rev-parse", "--show-toplevel"]))
      repo = if top == "", do: ".", else: top
      System.halt(LineLength.check(repo, opts[:base] || "HEAD", opts[:fix] || false))
    end

  _ ->
    IO.puts(:stderr, "usage: check_line_length.exs [--base BASE] [--fix] [--self-test]")
    System.halt(2)
end
