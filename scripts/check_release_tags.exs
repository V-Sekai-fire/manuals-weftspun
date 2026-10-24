# SPDX-License-Identifier: Apache-2.0 OR MIT
# Gate: a release tag is the Go pseudo-version of the commit it points at (RFD66606-2312).
#
# Usage:
#     elixir scripts/check_release_tags.exs [<repo>]
#     elixir scripts/check_release_tags.exs --self-test

defmodule ReleaseTags do
  @cutover "20261013000000"
  @form ~r/^v0\.0\.0-(\d{14})-([0-9a-f]{12})$/

  def expected(repo, rev) do
    {out, 0} =
      System.cmd(
        "git",
        ["-C", repo, "log", "-1", "--format=%cd %H", "--date=format-local:%Y%m%d%H%M%S", rev],
        env: [{"TZ", "UTC"}]
      )

    [time, sha] = String.split(String.trim(out))
    {time, "v0.0.0-#{time}-#{String.slice(sha, 0, 12)}"}
  end

  def tags(repo) do
    {out, 0} = System.cmd("git", ["-C", repo, "tag", "--list"])
    String.split(out, "\n", trim: true)
  end

  def verdict(repo, tag) do
    {time, want} = expected(repo, tag <> "^{commit}")

    cond do
      time < @cutover -> {:legacy, tag}
      tag == want -> {:ok, tag}
      not Regex.match?(@form, tag) -> {:fail, tag, "not the form v0.0.0-YYYYMMDDhhmmss-<12 hex>"}
      true -> {:fail, tag, "the tagged commit's pseudo-version is #{want}"}
    end
  end

  def check(repo) do
    results = Enum.map(tags(repo), &verdict(repo, &1))
    for {:fail, t, why} <- results, do: IO.puts("FAIL #{t}: #{why}")
    legacy = for {:legacy, t} <- results, do: t
    ok = Enum.count(results, &match?({:ok, _}, &1))
    fails = Enum.count(results, &match?({:fail, _, _}, &1))

    IO.puts(
      "#{ok} tag(s) match, #{fails} fail, #{length(legacy)} legacy before the cutover" <>
        if(legacy == [], do: "", else: ": " <> Enum.join(legacy, " "))
    )

    if fails == 0, do: 0, else: 1
  end

  @git_env Enum.map(
             ~w(GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY
                GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_PREFIX GIT_COMMON_DIR),
             &{&1, nil}
           )

  defp git!(dir, args, env \\ []) do
    {_, 0} = System.cmd("git", ["-C", dir | args], env: @git_env ++ env, stderr_to_stdout: true)
  end

  defp commit(dir, iso) do
    env = [{"GIT_COMMITTER_DATE", iso}, {"GIT_AUTHOR_DATE", iso}]
    git!(dir, ["commit", "-q", "--allow-empty", "-m", iso], env)
    {_, want} = expected(dir, "HEAD")
    want
  end

  def self_test do
    dir = Path.join(System.tmp_dir!(), "release-tags-#{System.unique_integer([:positive])}")
    File.mkdir_p!(dir)
    git!(dir, ["init", "-q"])
    git!(dir, ["config", "user.email", "t@example.invalid"])
    git!(dir, ["config", "user.name", "t"])

    _old = commit(dir, "2026-10-01T12:00:00Z")
    git!(dir, ["tag", "v20261001-dev.1"])
    good = commit(dir, "2026-10-14T09:05:07-07:00")
    [_, time, hash] = Regex.run(@form, good)

    cases = [
      {"the commit's own pseudo-version passes", good, :ok},
      {"a seven-hex hash fails", "v0.0.0-#{time}-#{String.slice(hash, 0, 7)}", :fail},
      {"a local-time stamp fails", "v0.0.0-20261014090507-#{hash}", :fail},
      {"a core other than v0.0.0 fails", "v1.0.0-#{time}-#{hash}", :fail},
      {"a padded calendar date fails", "v2026.10.14", :fail},
      {"a stage-suffixed date fails", "v20261014-dev.3", :fail},
      {"a tag before the cutover is legacy", "v20261001-dev.1", :legacy}
    ]

    for {_, tag, _} <- cases, tag != "v20261001-dev.1", do: git!(dir, ["tag", tag])

    results =
      for {name, tag, want} <- cases do
        got = elem(verdict(dir, tag), 0)
        IO.puts("#{if got == want, do: "ok  ", else: "BAD "} #{name} (#{got})")
        got == want
      end

    whole = check(dir)
    File.rm_rf!(dir)
    whole_ok = whole == 1
    IO.puts("#{if whole_ok, do: "ok  ", else: "BAD "} the repo with planted tags exits 1")
    if Enum.all?(results) and whole_ok, do: 0, else: 1
  end
end

code =
  case System.argv() do
    ["--self-test"] -> ReleaseTags.self_test()
    [] -> ReleaseTags.check(".")
    [repo] -> ReleaseTags.check(repo)
    _ -> 2
  end

System.halt(code)
