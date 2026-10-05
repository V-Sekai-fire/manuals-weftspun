# SPDX-License-Identifier: Apache-2.0 OR MIT
# Gate: churny literals in RFD prose do not rise; write them as &{repo/file/pin/measured}.
#
#     elixir scripts/check_rfd_literals.exs --base <ref>
#     elixir scripts/check_rfd_literals.exs --self-test

defmodule Literals do
  @side "transport|contract|interactor|entities|repository|datasource|service"
  @kinds [
    side_path: ~r/\b[1-7]-(?:#{@side})\/[\w.-]+/,
    own_org: ~r/\b(?:V-Sekai-fire|chibifire-stages)\/[\w.-]+/i,
    project: ~r/`(?:#{@side}|manuals|frame)-[\w.-]+`/,
    sha: ~r/`(?=[0-9a-f]*\d)(?=[0-9a-f]*[a-f])[0-9a-f]{7,40}`/,
    file_line: ~r/\b[\w.\/-]+\.[A-Za-z]\w{0,5}:\d+(?:-\d+)?\b/,
    branch: ~r/\b(?:feat|fix|archived)\/[\w.-]+/,
    pr: ~r/\bPR #\d+|(?<![\w&#])#\d+\b|\bpull\/\d+/
  ]
  @strict [:file_line, :branch, :pr]
  @span ~r/&\{(?:[^{}"]|"(?:\\.|[^"\\])*"|\{[^{}]*\})*\}/
  @stub ~r/^\s*abandoned_at\s+"[0-9a-f]+"\s*$/m

  def count(nil), do: {%{}, 0}

  def count(text) do
    {prose, fenced} =
      text
      |> String.replace(@span, " ")
      |> String.replace(@stub, "")
      |> String.split("\n")
      |> Enum.reduce({[], [], false}, fn line, {p, f, inside} ->
        cond do
          String.starts_with?(String.trim_leading(line), "```") -> {p, f, not inside}
          inside -> {p, [line | f], inside}
          true -> {[line | p], f, inside}
        end
      end)
      |> then(fn {p, f, _} -> {Enum.join(p, "\n"), Enum.join(f, "\n")} end)

    {tally(prose), tally(fenced) |> Map.values() |> Enum.sum()}
  end

  defp tally(text), do: Map.new(@kinds, fn {k, re} -> {k, length(Regex.scan(re, text))} end)

  @doc "{:pass | :fail, reasons, fenced} for one file, before (nil when new) and after."
  def judge(before, after_text) do
    {was, _} = count(before)
    {now, fenced} = count(after_text)
    total = fn m -> m |> Map.values() |> Enum.sum() end

    reasons =
      if(total.(now) > total.(was),
        do: ["literals #{total.(was)} -> #{total.(now)}"],
        else: []
      ) ++
        for k <- @strict, Map.get(now, k, 0) > Map.get(was, k, 0), do: "adds a #{k}"

    {if(reasons == [], do: :pass, else: :fail), reasons, fenced}
  end

  def git(repo, args) do
    case System.cmd("git", ["-C", repo | args], stderr_to_stdout: true) do
      {out, 0} -> {:ok, out}
      {out, _} -> {:error, out}
    end
  end

  def check(repo, base) do
    with {:ok, _} <- git(repo, ["rev-parse", "--verify", "--quiet", base <> "^{commit}"]),
         {:ok, mb} <- git(repo, ["merge-base", base, "HEAD"]),
         diff = ["diff", "--name-only", "--diff-filter=AMR", String.trim(mb)],
         {:ok, names} <- git(repo, diff) do
      mb = String.trim(mb)

      files =
        names
        |> String.split("\n", trim: true)
        |> Enum.filter(&(&1 =~ ~r"^rfd/[0-9]{4}-[^/]+[.]exs$"))

      bad =
        for path <- files, reduce: 0 do
          acc ->
            before =
              with {:ok, t} <- git(repo, ["show", "#{mb}:#{path}"]), do: t, else: (_ -> nil)

            {verdict, reasons, fenced} = judge(before, File.read!(Path.join(repo, path)))
            if fenced > 0, do: IO.puts("  #{path}: #{fenced} in fences, unchecked")

            if verdict == :fail do
              IO.puts("  FAIL #{path}: #{Enum.join(reasons, "; ")}")
              acc + 1
            else
              acc
            end
        end

      IO.puts("#{bad} of #{length(files)} changed RFD source(s) add churny literals")
      if bad == 0, do: 0, else: 1
    else
      {:error, out} ->
        IO.puts("FAIL: base #{inspect(base)} is unreadable: #{String.trim(out)}")
        1
    end
  end

  def self_test do
    base = "rfd 2999, \"t\", :discussion do\n  prose ~S\"\"\"\n  :: decision\n  Text.\n"
    sha = "`392beb7`"

    controls = [
      {"a bare side path added", base, base <> "See 3-interactor/foo.\n", :fail},
      {"the same as &{repo(..)}", base, base <> ~S|See &{repo("3-interactor/foo")}.| <> "\n",
       :pass},
      {"a file:line added", base, base <> "In tools/build.exs:27.\n", :fail},
      {"a branch added", base, base <> "On feat/x.\n", :fail},
      {"a PR number added", base, base <> "Landed in PR #12.\n", :fail},
      {"a bare SHA added", base, base <> "At #{sha}.\n", :fail},
      {"the SHA under abandoned_at", base, base <> "  abandoned_at \"392beb7\"\n", :pass},
      {"a literal moved, count unchanged", base <> "A feat/x.\nB.\n", base <> "B.\nA feat/x.\n",
       :pass},
      {"a literal inside a fence", base, base <> "```\n3-interactor/foo:12\n```\n", :pass},
      {"a new file with one literal", nil, base <> "See 3-interactor/foo.\n", :fail}
    ]

    fails =
      for {label, before, after_text, want} <- controls,
          {got, _, _} = judge(before, after_text),
          got != want do
        IO.puts("  FAIL #{label}: got #{got}, expected #{want}")
      end

    {_, _, fenced} = judge(base, base <> "```\n3-interactor/foo\n```\n")
    fails = if fenced == 1, do: fails, else: ["fenced count" | fails]

    tmp = Path.join(System.tmp_dir!(), "rfd-literals-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    git(tmp, ["init", "-q"])

    git(tmp, [
      "-c",
      "user.email=t@t",
      "-c",
      "user.name=t",
      "commit",
      "-q",
      "--allow-empty",
      "-m",
      "t"
    ])

    bad_base = ExUnit.CaptureIO.capture_io(fn -> send(self(), check(tmp, "no-such-ref")) end)
    File.rm_rf!(tmp)

    fails =
      receive do: (
                1 -> fails
                _ -> ["a bad --base: #{bad_base}" | fails]
              )

    n = length(controls) + 2

    if fails == [] do
      IO.puts("ok   #{n} of #{n} controls fired in both directions")
      0
    else
      IO.puts("#{length(fails)} of #{n} controls failed")
      1
    end
  end
end

ExUnit.start(autorun: false)

code =
  case OptionParser.parse(System.argv(), strict: [base: :string, self_test: :boolean]) do
    {[self_test: true], _, _} -> Literals.self_test()
    {[base: base], [], _} -> Literals.check(File.cwd!(), base)
    {[base: base], [repo], _} -> Literals.check(repo, base)
    _ -> IO.puts("usage: check_rfd_literals.exs --base <ref> [<repo>] | --self-test") && 2
  end

System.halt(code)
