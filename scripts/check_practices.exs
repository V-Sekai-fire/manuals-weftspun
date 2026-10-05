#!/usr/bin/env elixir
# SPDX-License-Identifier: Apache-2.0 OR MIT
# Gate: the practices RFD 2294 ("Interchangeable sessions") states that a file or an API can show.
# Other repositories run it as the `practices` prek hook from `.pre-commit-hooks.yaml`.
#
# Usage:
#     scripts/check_practices.exs [--base <ref>] [--exclude <ref>]... [--repo <path>]
#     scripts/check_practices.exs --pr <owner>/<name>#<n>          # PR text, needs GH_TOKEN
#     scripts/check_practices.exs --self-test
#
# Without --base the base is GATE_BASE, then PRE_COMMIT_FROM_REF, then @{upstream}; with
# none of them the commits are a FAIL, not a skip. --exclude drops commits a fork's upstream
# holds. GATE_PR adds the --pr check. GATE_BRANCH, else pre-push's PRE_COMMIT_REMOTE_BRANCH,
# names the branch, which must be feat/* or archived/*.
#
# Exit codes: 0 every practice holds, 1 one does not or a source was unreadable, 2 bad usage.

defmodule Practices do
  @credit [
    {~r/^\s*Co-Authored-By:.*(claude|anthropic\.com)/im, "an agent Co-Authored-By trailer"},
    {~r/^\s*Claude-Session:/im, "a Claude-Session trailer"},
    {~r/Generated (with|by) \[?Claude Code/i, "a Generated-by-Claude-Code footer"},
    {~r/claude\.ai\/code\/session_/i, "an agent session link"}
  ]
  @agent_identity ~r/(^claude$|noreply@anthropic\.com)/i
  @subject [
    {~r/^[a-z][a-z0-9-]*(\([^)]+\))?!?:/, "a Conventional-Commits prefix", true},
    {~r/^([A-Z]|\d|\[|`)/, "no capital, digit, bracket or backtick first", false},
    {~r/\.$/, "a trailing period", true}
  ]
  @emulators ~r/lavapipe|llvmpipe|swiftshader|mesa-vulkan-drivers|LIBGL_ALWAYS_SOFTWARE|
                lvp_icd|--angle[=\ ]+warp/ix
  @sheet ~r/contact[_-]sheet|contact[_-]video|\bsheet\.gd\b/i
  @upload ~r/actions\/upload-artifact@/
  @git_env Enum.map(
             ~w(GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY
                GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_PREFIX GIT_COMMON_DIR),
             &{&1, nil}
           )

  def credit_problems(where, text) do
    plain = text |> String.replace(~r/```.*?```/s, "") |> String.replace(~r/`[^`\n]*`/, "")
    for {re, what} <- @credit, Regex.match?(re, plain), do: "#{where}: carries #{what}"
  end

  def subject_problems(where, subject) do
    for {re, what, bad?} <- @subject,
        Regex.match?(re, subject) == bad?,
        do: "#{where}: subject #{inspect(subject)} has #{what} (RFD 2026)"
  end

  def git(root, args),
    do: System.cmd("git", ["-C", root | args], env: @git_env, stderr_to_stdout: true)

  def commits(root, base, excludes) do
    fmt = "%H%x1f%an%x1f%ae%x1f%cn%x1f%ce%x1f%s%x1f%B%x1e"
    revs = ["HEAD" | Enum.map([base | excludes], &"^#{&1}")]

    case git(root, ["log", "--no-merges", "--format=#{fmt}" | revs] ++ ["--"]) do
      {out, 0} ->
        out
        |> String.split("\x1e", trim: true)
        |> Enum.map(&String.split(String.trim_leading(&1), "\x1f"))
        |> Enum.filter(&(length(&1) == 7))

      {out, code} ->
        {:error, "git log #{Enum.join(revs, " ")} exited #{code}: #{String.trim(out)}"}
    end
  end

  def commit_problems(root, base, excludes \\ []) do
    case commits(root, base, excludes) do
      {:error, msg} ->
        {0, [msg]}

      list ->
        bad =
          Enum.flat_map(list, fn [sha, an, ae, cn, ce, subject, body] ->
            short = String.slice(sha, 0, 8)

            ids =
              for {who, name, mail} <- [{"author", an, ae}, {"committer", cn, ce}],
                  Regex.match?(@agent_identity, name) or Regex.match?(@agent_identity, mail),
                  do: "commit #{short}: #{who} is the agent identity #{name} <#{mail}>"

            ids ++
              subject_problems("commit #{short}", subject) ++
              credit_problems("commit #{short}", body)
          end)

        {length(list), bad}
    end
  end

  def strip_comment(line), do: String.replace(line, ~r/(^|\s)#.*$/, "")

  def workflow_problems(root) do
    files = Path.wildcard(Path.join(root, ".github/workflows/*.{yml,yaml}")) |> Enum.sort()

    bad =
      Enum.flat_map(files, fn f ->
        rel = Path.relative_to(f, root)
        code = f |> File.read!() |> String.split("\n") |> Enum.map(&strip_comment/1)

        emu =
          code
          |> Enum.with_index(1)
          |> Enum.filter(fn {l, _} -> Regex.match?(@emulators, l) end)
          |> Enum.map(fn {l, n} ->
            "#{rel}:#{n}: software GPU emulator #{inspect(String.trim(l))} is blocklisted"
          end)

        text = Enum.join(code, "\n")

        sheet =
          if Regex.match?(@sheet, text) and not Regex.match?(@upload, text),
            do: ["#{rel}: renders a contact sheet but uploads no artifact"],
            else: []

        emu ++ sheet
      end)

    {length(files), bad}
  end

  def gh_json(path) do
    case System.cmd("gh", ["api", "--paginate", "--slurp", path], stderr_to_stdout: true) do
      {out, 0} -> {:ok, out |> JSON.decode!() |> List.flatten()}
      {out, code} -> {:error, "gh api #{path} exited #{code}: #{String.trim(out)}"}
    end
  end

  def pr_problems(spec) do
    [repo, n] = String.split(spec, "#")

    sources = [
      {"pull request body", "repos/#{repo}/pulls/#{n}"},
      {"comment", "repos/#{repo}/issues/#{n}/comments"},
      {"review", "repos/#{repo}/pulls/#{n}/reviews"},
      {"review comment", "repos/#{repo}/pulls/#{n}/comments"}
    ]

    Enum.reduce(sources, {0, []}, fn {what, path}, {seen, bad} ->
      case gh_json(path) do
        {:error, msg} ->
          {seen, bad ++ [msg]}

        {:ok, items} ->
          found =
            Enum.flat_map(items, fn i ->
              where = if what == "pull request body", do: what, else: "#{what} #{i["html_url"]}"
              credit_problems(where, i["body"] || "")
            end)

          {seen + length(items), bad ++ found}
      end
    end)
  end

  def report(label, {seen, bad}) do
    Enum.each(bad, &IO.puts("FAIL #{&1}"))
    IO.puts("#{label}: #{seen} read, #{length(bad)} problem(s)")
    bad == []
  end

  def branch_problems(name) do
    name = String.replace_prefix(name, "refs/heads/", "")

    if String.starts_with?(name, ["feat/", "archived/"]),
      do: [],
      else: ["branch #{name} is neither feat/* nor archived/*"]
  end

  def branch do
    Enum.find_value(["GATE_BRANCH", "PRE_COMMIT_REMOTE_BRANCH"], fn k ->
      v = System.get_env(k, "")
      if v != "", do: v
    end)
  end

  def base(root, given) do
    env = Enum.find(["GATE_BASE", "PRE_COMMIT_FROM_REF"], &(System.get_env(&1, "") != ""))

    cond do
      given -> given
      env -> System.get_env(env)
      elem(git(root, ["rev-parse", "--verify", "-q", "@{upstream}"]), 1) == 0 -> "@{upstream}"
      true -> nil
    end
  end

  def main(["--self-test"]), do: SelfTest.run()

  def main(["--pr", spec]) do
    if report("pull request text", pr_problems(spec)), do: 0, else: 1
  end

  def main(args) do
    {opts, rest, bad} =
      OptionParser.parse(args, strict: [base: :string, exclude: :keep, repo: :string])

    if rest != [] or bad != [] do
      IO.puts(
        :stderr,
        "usage: check_practices.exs [--base <ref>] [--exclude <ref>]... [--repo <path>]" <>
          " | --pr <o>/<r>#<n> | --self-test"
      )

      2
    else
      root = opts[:repo] || "."

      c =
        case base(root, opts[:base]) do
          nil ->
            report(
              "commits",
              {0, ["no base: set GATE_BASE or --base, or give the branch an upstream"]}
            )

          b ->
            report("commits", commit_problems(root, b, Keyword.get_values(opts, :exclude)))
        end

      w = report("workflows", workflow_problems(root))

      b =
        case branch() do
          nil ->
            IO.puts("branch: none named (GATE_BRANCH unset, not a push), 1 unchecked")
            true

          name ->
            report("branch", {1, branch_problems(name)})
        end

      pr = System.get_env("GATE_PR", "")
      p = pr == "" or report("pull request text", pr_problems(pr))
      if c and w and b and p, do: 0, else: 1
    end
  end
end

defmodule SelfTest do
  def run do
    tmp = Path.join(System.tmp_dir!(), "practices-#{System.unique_integer([:positive])}")
    File.mkdir_p!(Path.join(tmp, ".github/workflows"))
    g = fn args -> {_, 0} = Practices.git(tmp, args) end
    g.(["init", "-q", "-b", "work"])

    fire = [
      "-c",
      "user.name=K. S. Ernest (iFire) Lee",
      "-c",
      "user.email=32321+fire@users.noreply.github.com"
    ]

    g.(fire ++ ["commit", "-q", "--allow-empty", "-m", "Base"])
    g.(["tag", "base"])

    commit = fn who, msg ->
      g.(who ++ ["commit", "-q", "--allow-empty", "-m", msg])
      {_, bad} = Practices.commit_problems(tmp, "base")
      g.(["reset", "-q", "--hard", "base"])
      bad
    end

    g.(["checkout", "-q", "-b", "upstream"])
    g.(fire ++ ["commit", "-q", "--allow-empty", "-m", "core: fix the scene loader"])
    g.(["checkout", "-q", "work"])
    g.(fire ++ ["merge", "-q", "--no-ff", "-m", "Merge the upstream", "upstream"])

    upstream = fn excludes ->
      {_, bad} = Practices.commit_problems(tmp, "base", excludes)
      bad
    end

    merged = {upstream.([]), upstream.(["upstream"])}
    g.(["reset", "-q", "--hard", "base"])

    workflow = fn body ->
      f = Path.join(tmp, ".github/workflows/w.yml")
      File.write!(f, body)
      {_, bad} = Practices.workflow_problems(tmp)
      File.rm!(f)
      bad
    end

    agent = ["-c", "user.name=Claude", "-c", "user.email=noreply@anthropic.com"]

    controls = [
      {"a clean commit by the operator passes", commit.(fire, "Add the gate") == []},
      {"an agent Co-Authored-By trailer is rejected",
       commit.(fire, "Add\n\nCo-Authored-By: Claude Opus <noreply@anthropic.com>") != []},
      {"a Claude-Session trailer is rejected",
       commit.(fire, "Add\n\nClaude-Session: https://claude.ai/code/session_01X") != []},
      {"a commit authored by the agent identity is rejected", commit.(agent, "Add") != []},
      {"a feat: subject is rejected", commit.(fire, "feat: add the gate") != []},
      {"a fix(scope): subject is rejected", commit.(fire, "fix(gate): read forks") != []},
      {"a lower-case subject is rejected", commit.(fire, "add the gate") != []},
      {"a trailing period is rejected", commit.(fire, "Add the gate.") != []},
      {"an RFD-numbered subject passes", commit.(fire, "RFD 2026: Hold forks to it") == []},
      {"a merged upstream prefixed commit is rejected",
       Enum.any?(elem(merged, 0), &(&1 =~ "core: fix the scene loader"))},
      {"a merged upstream prefixed commit passes once its ref is excluded",
       elem(merged, 1) == []},
      {"a human co-author trailer passes",
       commit.(fire, "Add\n\nCo-Authored-By: Hana <hana@example.org>") == []},
      {"a footer in a PR body is rejected",
       Practices.credit_problems(
         "b",
         "Text\n\n🤖 Generated with [Claude Code](https://claude.com/claude-code)"
       ) != []},
      {"a footer quoted in code passes",
       Practices.credit_problems("b", "The hook strips `Generated by Claude Code`.") == []},
      {"a clean workflow passes",
       workflow.("jobs:\n  a:\n    steps:\n      - run: godot --headless\n") == []},
      {"lavapipe in a workflow is rejected",
       workflow.("jobs:\n  a:\n    steps:\n      - run: apt-get install mesa-vulkan-drivers\n") !=
         []},
      {"WARP in a workflow is rejected",
       workflow.("      - run: node shot.mjs --angle warp\n") != []},
      {"an emulator named in a comment passes",
       workflow.("# headless with no GPU/lavapipe\n") == []},
      {"a contact sheet with no upload is rejected",
       workflow.("      - run: elixir contact_sheet.exs\n") != []},
      {"a contact sheet with an upload passes",
       workflow.(
         "      - run: elixir contact_sheet.exs\n      - uses: actions/upload-artifact@v4\n"
       ) == []}
    ]

    controls =
      controls ++
        [
          {"a feat/ branch passes", Practices.branch_problems("feat/x") == []},
          {"an archived/ branch passes",
           Practices.branch_problems("refs/heads/archived/x") == []},
          {"a claude/ branch is rejected", Practices.branch_problems("claude/thread-x") != []},
          {"a fix/ branch is rejected", Practices.branch_problems("fix/x") != []}
        ]

    saved = Map.new(["GATE_BASE", "PRE_COMMIT_FROM_REF"], &{&1, System.get_env(&1)})
    Enum.each(saved, fn {k, _} -> System.delete_env(k) end)

    controls =
      controls ++ [{"a branch with no base is not skipped", Practices.base(tmp, nil) == nil}]

    Enum.each(saved, fn {k, v} -> if v, do: System.put_env(k, v) end)

    File.rm_rf!(tmp)
    failed = for {name, false} <- controls, do: name
    Enum.each(failed, &IO.puts("FAIL control: #{&1}"))

    if failed == [] do
      IO.puts("ok   #{length(controls)} controls, both directions")
      0
    else
      1
    end
  end
end

System.halt(Practices.main(System.argv()))
