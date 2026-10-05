# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule Mix.Tasks.Rfd.Refs.Update do
  @shortdoc "Resolve every &{...} in rfd/*.exs, write RFD.lock.exs, render"
  @moduledoc """
      mix rfd.refs.update [--workspace DIR]

  DIR holds `.repo/manifests/default.xml`; it defaults to the nearest `.repo` above here.
  """
  use Mix.Task

  @impl true
  def run(args) do
    {opts, _, _} = OptionParser.parse(args, strict: [workspace: :string])
    ws = opts[:workspace] || find_workspace!(File.cwd!())
    manifests = Path.join(ws, ".repo/manifests")
    xml = File.read!(Path.join(manifests, "default.xml"))

    commit =
      RFD.Ref.git(manifests, ["rev-parse", "HEAD"]) ||
        Mix.raise("#{manifests} is not a git checkout")

    calls = Enum.flat_map(RFD.Source.all(), &RFD.Ref.calls(File.read!(&1))) |> Enum.uniq()

    world = %{
      manifest: xml,
      commit: String.trim(commit),
      archived: if(calls == [], do: [], else: archived!()),
      tip: &tip!/1,
      blob: &blob/3
    }

    lock = RFD.Ref.Snapshot.lock(calls, world)

    File.write!(
      RFD.Ref.lock_path(),
      "# Written by `mix rfd.refs.update`; RFD prose resolves &{...} against it.\n" <>
        inspect(lock, pretty: true, limit: :infinity, printable_limit: :infinity) <> "\n"
    )

    Mix.shell().info("#{length(calls)} reference(s), #{map_size(lock.repos)} repo(s) locked")
    Mix.Task.run("rfd.render", [])
  end

  defp find_workspace!(dir) do
    cond do
      File.dir?(Path.join(dir, ".repo")) -> dir
      Path.dirname(dir) == dir -> Mix.raise("no .repo above here; pass --workspace")
      true -> find_workspace!(Path.dirname(dir))
    end
  end

  defp archived! do
    case System.cmd(
           "gh",
           ~w(repo list V-Sekai-fire --archived --limit 2000 --json name --jq .[].name)
         ) do
      {out, 0} -> String.split(out)
      {out, _} -> Mix.raise("gh repo list failed: #{out}")
    end
  end

  defp tip!(url) do
    case System.cmd("git", ["ls-remote", "--symref", url, "HEAD"], stderr_to_stdout: true) do
      {out, 0} ->
        [_, branch] = Regex.run(~r{ref: refs/heads/(\S+)\s+HEAD}, out)
        [_, sha] = Regex.run(~r/^([0-9a-f]{40})\s+HEAD$/m, out)
        {branch, sha}

      {out, _} ->
        Mix.raise("git ls-remote #{url}: #{out}")
    end
  end

  defp blob(url, sha, path) do
    repo = url |> URI.parse() |> Map.fetch!(:path) |> String.trim("/")

    case System.cmd(
           "gh",
           ["api", "repos/#{repo}/contents/#{path}?ref=#{sha}"] ++
             ~w(-H Accept:application/vnd.github.raw),
           stderr_to_stdout: true
         ) do
      {out, 0} -> {:ok, out}
      _ -> :error
    end
  end
end

defmodule Mix.Tasks.Rfd.Restore do
  @shortdoc "Bring an abandoned RFD's last full source back from its abandoned_at commit"
  @moduledoc "    mix rfd.restore NNNN"
  use Mix.Task

  @impl true
  def run([serial]) do
    path =
      Path.wildcard(Path.join(RFD.Source.rfd_root(), "#{serial}-*.exs")) |> List.first() ||
        Mix.raise("no rfd/#{serial}-*.exs")

    sha = RFD.Source.load(path).abandoned_at || Mix.raise("RFD #{serial} has no abandoned_at")
    root = RFD.Source.repo_root()

    case Enum.filter(RFD.Ref.sources_at(root, serial, sha), &String.ends_with?(&1, ".exs")) do
      [old | _] ->
        File.write!(path, RFD.Ref.git(root, ["show", "#{sha}:#{old}"]))
        Mix.shell().info("#{path} restored from #{sha}:#{old}")

      [] ->
        Mix.raise(
          "#{sha} predates the .exs sources; its Markdown is " <>
            Enum.join(RFD.Ref.sources_at(root, serial, sha), ", ")
        )
    end
  end

  def run(_), do: Mix.raise("usage: mix rfd.restore NNNN")
end
