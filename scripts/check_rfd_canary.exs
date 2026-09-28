# SPDX-License-Identifier: Apache-2.0 OR MIT
# Gate: every new RFD carries a canary sentence saying who drafted it.
# Only RFD directories absent on the base branch are checked, so existing RFDs stay outside.
#
# Usage:
#     elixir scripts/check_rfd_canary.exs [--base <ref>]
#     elixir scripts/check_rfd_canary.exs --self-test
#
# Exit codes: 0 every new RFD carries a canary, 1 one does not or git failed.

defmodule Canary do
  @ai "This RFD was drafted by an AI and read by a human before it shipped."
  @human "This RFD was drafted by a human without AI help."
  @root "rfd"
  @git_env Enum.map(
             ~w(GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY
                GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_PREFIX GIT_COMMON_DIR),
             &{&1, nil}
           )

  def git(root, args),
    do: System.cmd("git", ["-C", root | args], env: @git_env, stderr_to_stdout: true)

  def git!(root, args) do
    case git(root, args) do
      {out, 0} ->
        out

      {out, code} ->
        IO.puts(:stderr, "git #{Enum.join(args, " ")} exited #{code}\n#{out}")
        System.halt(1)
    end
  end

  def new_rfd_dirs(root, base) do
    git!(root, ["diff", "--diff-filter=A", "--name-only", "#{base}...HEAD"])
    |> String.split("\n", trim: true)
    |> Enum.flat_map(fn line ->
      case String.split(line, "/") do
        [@root, slug, "README.md"] ->
          ["#{@root}/#{slug}"]

        [@root, file] ->
          slug = String.replace_suffix(file, ".exs", "")
          readme = "#{base}:#{@root}/#{slug}/README.md"

          if slug != file and elem(git(root, ["cat-file", "-e", readme]), 1) != 0,
            do: ["#{@root}/#{slug}"],
            else: []

        _ ->
          []
      end
    end)
    |> Enum.sort()
  end

  def carries_canary?(root, rel_dir) do
    Enum.any?(["README.md", "DETAILS.md"], fn name ->
      p = Path.join([root | String.split(rel_dir, "/")] ++ [name])
      File.regular?(p) and String.contains?(File.read!(p), [@ai, @human])
    end)
  end

  def run(root, base) do
    news = new_rfd_dirs(root, base)

    case Enum.reject(news, &carries_canary?(root, &1)) do
      [] ->
        IO.puts("ok   #{length(news)} new RFD(s), canary in each.")
        0

      missing ->
        IO.puts("FAIL #{length(missing)} new RFD(s) missing the canary:")
        Enum.each(missing, &IO.puts("       #{&1}"))
        IO.puts("")
        IO.puts("     add one of these sentences to the RFD's README.md or DETAILS.md:")
        IO.puts("     AI-drafted:    '#{@ai}'")
        IO.puts("     human-drafted: '#{@human}'")
        1
    end
  end

  defp plant(root, slug, readme, details \\ nil) do
    d = Path.join([root, @root, slug])
    File.mkdir_p!(d)
    File.write!(Path.join(d, "README.md"), readme)
    if details, do: File.write!(Path.join(d, "DETAILS.md"), details)
  end

  defp scratch_repo do
    t = Path.join(System.tmp_dir!(), "canary-#{System.unique_integer([:positive])}")
    File.mkdir_p!(t)
    git!(t, ~w(init -q -b main))
    git!(t, ~w(config user.email t@t))
    git!(t, ~w(config user.name t))
    plant(t, "1000-baseline", "# baseline\n")
    git!(t, ~w(add .))
    git!(t, ~w(commit -q -m base))
    git!(t, ~w(checkout -q -b feature))
    t
  end

  def controls do
    t = scratch_repo()
    plant(t, "1001-ai-canary-in-readme", "# a\n\n#{@ai}\n")
    plant(t, "1002-ai-canary-in-details", "# b\n", "# b details\n\n#{@ai}\n")
    plant(t, "1003-no-canary", "# c\n", "# c details\n")

    plant(
      t,
      "1004-canary-misspelled",
      "# d\n\nThis RFD was drafted by AI and read by a human before it shipped.\n"
    )

    plant(t, "1005-human-canary", "# e\n\n#{@human}\n")
    plant(t, "1006-human-canary-in-details", "# f\n", "# f details\n\n#{@human}\n")
    git!(t, ~w(add .))
    git!(t, ~w(commit -q -m new))
    news = new_rfd_dirs(t, "main")
    missing = Enum.reject(news, &carries_canary?(t, &1))
    File.rm_rf!(t)

    [
      {"AI canary in README passes", "rfd/1001-ai-canary-in-readme" not in missing},
      {"AI canary in DETAILS passes", "rfd/1002-ai-canary-in-details" not in missing},
      {"no canary is rejected", "rfd/1003-no-canary" in missing},
      {"a misspelled canary is rejected", "rfd/1004-canary-misspelled" in missing},
      {"human canary in README passes", "rfd/1005-human-canary" not in missing},
      {"human canary in DETAILS passes", "rfd/1006-human-canary-in-details" not in missing},
      {"the baseline RFD is not rescanned", "rfd/1000-baseline" not in news}
    ]
  end

  def self_test do
    outer = Path.join(System.tmp_dir!(), "canary-outer-#{System.unique_integer([:positive])}")
    File.mkdir_p!(outer)
    git!(outer, ~w(init -q))
    git!(outer, ~w(-c user.email=t@t -c user.name=t commit -q --allow-empty -m o))
    count = fn -> git!(outer, ~w(rev-list --all --count)) end
    before = count.()
    System.put_env("GIT_DIR", Path.join(outer, ".git"))
    inner = controls()
    System.delete_env("GIT_DIR")
    kept = count.() == before and Enum.all?(inner, &elem(&1, 1))
    File.rm_rf!(outer)

    checks = controls() ++ [{"an inherited GIT_DIR gains no scratch commits", kept}]
    IO.puts("")

    for {name, ok} <- checks,
        do:
          IO.puts("  #{String.pad_trailing(if(ok, do: "ok", else: "FAIL"), 4)} control: #{name}")

    bad = Enum.count(checks, &(not elem(&1, 1)))
    IO.puts("  #{length(checks) - bad} of #{length(checks)} controls fired.")
    if bad == 0, do: 0, else: 1
  end

  def default_base(root) do
    resolves = fn ref -> elem(git(root, ["rev-parse", "--verify", "--quiet", ref]), 1) == 0 end

    remote_heads =
      for ref <- ~w(refs/remotes/origin/HEAD refs/remotes/v-sekai-fire/HEAD),
          {out, 0} <- [git(root, ["symbolic-ref", "--short", ref])],
          cand = String.trim(out),
          cand != "",
          do: cand

    Enum.find(
      remote_heads ++ ~w(origin/main/main v-sekai-fire/main/main origin/main v-sekai-fire/main),
      resolves
    ) ||
      (
        IO.puts(:stderr, "cannot resolve a base branch; pass --base explicitly")
        System.halt(1)
      )
  end
end

argv = System.argv()

if "--self-test" in argv do
  System.halt(Canary.self_test())
else
  root = __ENV__.file |> Path.expand() |> Path.dirname() |> Path.dirname()

  base =
    case Enum.drop_while(argv, &(&1 != "--base")) do
      ["--base", b | _] -> b
      ["--base"] -> System.halt(1)
      _ -> Canary.default_base(root)
    end

  System.halt(Canary.run(root, base))
end
