# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT

defmodule RFD.Ref do
  @moduledoc """
  `&{repo(..)}`, `&{file(..)}`, `&{pin(..)}` and `&{measured(..)}` in RFD prose, resolved
  against `RFD.lock.exs` and `MEASUREMENTS.exs` so a fact that moves is a lock line, not prose.
  """

  @arity %{repo: [1, 2], file: [2, 3], pin: [1], measured: [1]}
  @lock "RFD.lock.exs"
  @register "MEASUREMENTS.exs"
  @mm %{"mm" => 1.0, "cm" => 10.0, "m" => 1000.0}

  def lock_path(root \\ File.cwd!()), do: Path.join(root, @lock)

  def spans(text), do: spans(text, 0, [])

  defp spans(text, from, acc) do
    case :binary.match(text, "&{", scope: {from, byte_size(text) - from}) do
      :nomatch ->
        Enum.reverse(acc)

      {at, 2} ->
        stop = close!(text, at + 2, 1, false)
        inner = binary_part(text, at + 2, stop - at - 2)
        spans(text, stop + 1, [{binary_part(text, at, stop - at + 1), inner} | acc])
    end
  end

  defp close!(text, i, depth, quoted) when i < byte_size(text) do
    case {:binary.at(text, i), quoted} do
      {?\\, true} -> close!(text, i + 2, depth, true)
      {?", q} -> close!(text, i + 1, depth, not q)
      {_, true} -> close!(text, i + 1, depth, true)
      {?{, _} -> close!(text, i + 1, depth + 1, false)
      {?}, _} when depth == 1 -> i
      {?}, _} -> close!(text, i + 1, depth - 1, false)
      _ -> close!(text, i + 1, depth, false)
    end
  end

  defp close!(text, _, _, _), do: raise(ArgumentError, "unclosed &{ in #{inspect(text)}")

  @doc "The call inside one span, as `{fun, args}`; anything outside the four functions raises."
  def parse!(inner) do
    case Code.string_to_quoted!(inner) do
      {fun, _, args} when is_atom(fun) and is_list(args) ->
        if length(args) in Map.get(@arity, fun, []) and Enum.all?(args, &literal?/1),
          do: {fun, args},
          else: raise(ArgumentError, "&{#{inner}}: not a call RFD.Ref resolves")

      _ ->
        raise ArgumentError, "&{#{inner}}: not a call RFD.Ref resolves"
    end
  end

  defp literal?(v) when is_binary(v) or is_number(v) or is_atom(v), do: true
  defp literal?({k, v}), do: literal?(k) and literal?(v)
  defp literal?(l) when is_list(l), do: Enum.all?(l, &literal?/1)
  defp literal?(_), do: false

  def calls(text), do: for({_, inner} <- spans(text), do: parse!(inner))

  def expand!(text, ctx \\ nil)

  def expand!(text, ctx) when is_binary(text) do
    case spans(text) do
      [] ->
        text

      found ->
        ctx = ctx || context()

        Enum.reduce(found, text, fn {span, inner}, acc ->
          String.replace(acc, span, render!(parse!(inner), ctx), global: false)
        end)
    end
  end

  def expand!(other, _), do: other

  def context(root \\ File.cwd!()) do
    %{
      lock: read_lock!(root),
      measurements: measurements!(root),
      anchors: anchors!(root),
      root: root
    }
  end

  def read_lock!(root) do
    path = lock_path(root)

    unless File.regular?(path),
      do: raise(ArgumentError, "#{@lock} is missing; `mix rfd.refs.update` writes it")

    {lock, _} = Code.eval_file(path)
    lock
  end

  def render!({:repo, [name | opts]}, ctx) do
    opts = List.flatten(opts)
    {key, entry} = entry!(ctx.lock, name)

    case {entry, opts[:planned]} do
      {%{state: :planned, side: side}, side} ->
        "`#{key}` (planned on `#{side}`)"

      {%{state: :planned}, _} ->
        raise ArgumentError, "repo #{inspect(name)} is unplaced; say `planned: \"<side>\"`"

      {_, side} when side != nil ->
        raise ArgumentError, "repo #{inspect(name)} is placed now; drop `planned:`"

      {%{state: :archived, url: url}, nil} ->
        "[`#{key}`](#{url}) (archived)"

      {%{state: :placed, url: url, path: path}, nil} ->
        "[`#{key}`](#{url}) (`#{path}`)"
    end
  end

  def render!({:file, [repo, path | opts]}, ctx) do
    {key, entry} = entry!(ctx.lock, repo)
    contains = opts |> List.flatten() |> Keyword.get_values(:contains)
    seen = Map.get(ctx.lock.files, {key, path})

    cond do
      entry.state == :planned ->
        raise ArgumentError, "file #{path}: #{key} is not placed"

      seen == nil ->
        raise ArgumentError, "file #{key}/#{path} is not in #{@lock}; run `mix rfd.refs.update`"

      (missing = contains -- seen.contains) != [] ->
        raise ArgumentError, "file #{key}/#{path} was not seen to contain #{inspect(missing)}"

      true ->
        "[`#{path}`](#{entry.url}/blob/#{entry.default}/#{path})"
    end
  end

  def render!({:pin, [repo]}, ctx) do
    case entry!(ctx.lock, repo) do
      {_, %{state: :placed, revision: rev}} when is_binary(rev) -> "`#{rev}`"
      {key, _} -> raise ArgumentError, "pin #{key}: placed with no revision"
    end
  end

  def render!({:measured, [key]}, ctx) do
    case Map.fetch(ctx.measurements, key) do
      {:ok, m} -> "#{num(m.value)} #{m.unit}" <> anchor(m, ctx.anchors)
      :error -> raise ArgumentError, "measured #{inspect(key)} is not in #{@register}"
    end
  end

  defp entry!(lock, name) do
    hit =
      (Map.get(lock.repos, name) && {name, lock.repos[name]}) ||
        Enum.find(lock.repos, fn {_, e} -> Map.get(e, :path) == name end)

    hit ||
      raise ArgumentError, "repo #{inspect(name)} is not in #{@lock}; run `mix rfd.refs.update`"
  end

  defp num(v) when is_float(v), do: :erlang.float_to_binary(v, [:short])
  defp num(v), do: to_string(v)

  defp anchor(%{value: v, unit: unit}, anchors) when is_map_key(@mm, unit) and anchors != [] do
    mm = v * @mm[unit]
    {name, size} = Enum.filter(anchors, fn {_, s} -> s <= mm end) |> List.last() || hd(anchors)
    n = mm / size

    cond do
      n < 1 -> " (about 1/#{round(size / mm)} of a #{name})"
      n < 10 -> " (about #{Float.round(n, 1)} × #{name})"
      true -> " (about #{round(n)} × #{name})"
    end
  end

  defp anchor(_, _), do: ""

  @doc "CLAUDE.md's household anchors, smallest first, read from its `Useful anchors:` sentence."
  def anchors!(root) do
    text = File.read!(Path.join(root, "CLAUDE.md"))

    case String.split(text, "Useful anchors:", parts: 2) do
      [_, rest] ->
        sentence = rest |> String.split(".\n", parts: 2) |> hd()

        for [_, name, mm] <-
              Regex.scan(~r/([A-Za-z][A-Za-z ]*?)\s+(\d+(?:\.\d+)?)\s+mm/, sentence),
            do: {String.trim(name), String.to_float(if(mm =~ ".", do: mm, else: mm <> ".0"))}

      _ ->
        raise ArgumentError, "CLAUDE.md states no `Useful anchors:`"
    end
    |> Enum.sort_by(&elem(&1, 1))
  end

  @doc "MEASUREMENTS.exs, each value checked against the logbook entry it names."
  def measurements!(root) do
    path = Path.join(root, @register)
    if File.regular?(path), do: check_register!(RFD.Measure.load!(path), root), else: %{}
  end

  def check_register!(rows, root) do
    for {key, m} <- rows, into: %{} do
      log = Path.join([root, "logbook", m.logbook])

      case File.read(log) do
        {:ok, body} ->
          unless String.contains?(body, num(m.value)),
            do:
              raise(
                ArgumentError,
                "measured #{inspect(key)}: #{m.logbook} never states #{num(m.value)}"
              )

        _ ->
          raise ArgumentError, "measured #{inspect(key)}: no logbook/#{m.logbook}"
      end

      {key, m}
    end
  end

  @doc "The decision an `abandoned_at` stub renders, once the SHA holds a source with a Decision."
  def abandoned!(serial, sha, root \\ File.cwd!()) do
    unless is_binary(sha) and git(root, ["rev-parse", "--verify", "--quiet", sha <> "^{commit}"]),
      do: raise(ArgumentError, "RFD #{serial}: abandoned_at #{inspect(sha)} is not a commit here")

    unless Enum.any?(sources_at(root, serial, sha), &decision?(root, sha, &1)),
      do: raise(ArgumentError, "RFD #{serial}: no source with a Decision at #{sha}")

    "The full argument is in git at `#{sha}`; `mix rfd.restore #{serial}` brings it back."
  end

  @doc "The paths that held RFD `serial` at `sha`."
  def sources_at(root, serial, sha) do
    re = ~r{(^|/)#{serial}-[^/]+(\.exs$|/(README|DETAILS|index)\.md$)}

    (git(root, ["ls-tree", "-r", "--name-only", sha]) || "")
    |> String.split("\n", trim: true)
    |> Enum.filter(&Regex.match?(re, &1))
  end

  defp decision?(root, sha, path) do
    body = git(root, ["show", "#{sha}:#{path}"]) || ""
    body =~ ~r/^## Decision|^\s*:: decision$|^\s*decision\s+(~S)?"/m
  end

  def git(root, args) do
    case System.cmd("git", ["-C", root | args], stderr_to_stdout: true) do
      {out, 0} -> out
      _ -> nil
    end
  end
end

defmodule RFD.Measure do
  @moduledoc false

  defmacro measurements(do: block) do
    calls =
      case block do
        {:__block__, _, cs} -> cs
        c -> [c]
      end

    for {:measure, _, [key, value, unit, opts]} <- calls do
      quote do: RFD.Measure.row(unquote(key), unquote(value), unquote(unit), unquote(opts))
    end
  end

  def row(key, value, unit, opts) when is_atom(key) and is_number(value) and is_binary(unit),
    do: {key, %{value: value, unit: unit, logbook: Keyword.fetch!(opts, :logbook)}}

  def load!(path) do
    {rows, _} = Code.eval_file(path)
    keys = Enum.map(rows, &elem(&1, 0))
    dup = keys -- Enum.uniq(keys)
    if dup != [], do: raise(ArgumentError, "#{path}: measured twice: #{inspect(dup)}")
    rows
  end
end

defmodule RFD.Ref.Snapshot do
  @moduledoc false

  @doc """
  The lock for `calls` against a world: `manifest` (default.xml text), `commit`, `archived`
  (names), `tip.(url) -> {branch, sha}` and `blob.(url, sha, path) -> {:ok, text} | :error`.
  """
  def lock(calls, w) do
    placed = projects(w.manifest)

    repos =
      for {fun, [name | rest]} <- calls, fun in [:repo, :file, :pin], into: %{} do
        planned = if fun == :repo, do: rest |> List.flatten() |> Keyword.get(:planned)
        entry(name, planned, placed, w)
      end

    files =
      for {:file, [name, path | opts]} <- calls, reduce: %{} do
        acc ->
          {key, e} = Enum.find(repos, fn {k, e} -> k == name or Map.get(e, :path) == name end)

          text =
            case e.state != :planned && w.blob.(e.url, e.tip, path) do
              {:ok, t} -> t
              _ -> raise ArgumentError, "file #{key}/#{path} is absent at #{e[:tip]}"
            end

          wanted = opts |> List.flatten() |> Keyword.get_values(:contains)

          for s <- wanted,
              not String.contains?(text, s),
              do: raise(ArgumentError, "file #{key}/#{path} does not contain #{inspect(s)}")

          Map.update(acc, {key, path}, %{contains: wanted}, fn f ->
            %{contains: Enum.uniq(f.contains ++ wanted)}
          end)
      end

    for {_, %{state: :placed, revision: nil}} = {k, _} <- repos,
        {:pin, [n]} <- calls,
        n == k or n == repos[k].path,
        do: raise(ArgumentError, "pin #{k}: the manifest gives no revision")

    %{
      manifest: %{repo: "V-Sekai-fire/contract-manifest-taskweft", commit: w.commit},
      repos: repos,
      files: files
    }
  end

  defp entry(name, planned, placed, w) do
    by_path = Enum.find(placed, fn {_, p} -> p.path == name end)
    hit = (Map.has_key?(placed, name) && {name, placed[name]}) || by_path

    cond do
      hit && planned ->
        raise ArgumentError, "repo #{inspect(name)} is placed; drop `planned:`"

      hit ->
        {key, p} = hit
        {branch, tip} = w.tip.(p.url)
        {key, Map.merge(p, %{state: :placed, default: branch, tip: tip})}

      name in w.archived ->
        url = "https://github.com/V-Sekai-fire/#{name}"
        {branch, tip} = w.tip.(url)
        {name, %{state: :archived, url: url, default: branch, tip: tip}}

      planned ->
        {name, %{state: :planned, side: planned}}

      true ->
        raise ArgumentError, "repo #{inspect(name)} is neither in default.xml nor archived"
    end
  end

  @doc "name => %{path, url, revision} for every project default.xml places."
  def projects(xml) do
    {doc, _} = xml |> String.to_charlist() |> :xmerl_scan.string(quiet: true)

    attrs = fn el ->
      for {:xmlAttribute, k, _, _, _, _, _, _, v, _} <- elem(el, 7),
          into: %{},
          do: {k, to_string(v)}
    end

    els = fn tag -> :xmerl_xpath.string(~c"//#{tag}", doc) |> Enum.map(attrs) end
    remotes = Map.new(els.("remote"), &{&1[:name], &1[:fetch]})
    default = List.first(els.("default")) || %{}

    for p <- els.("project"), into: %{} do
      remote = p[:remote] || default[:remote]

      {p[:name],
       %{
         path: p[:path] || p[:name],
         url: "#{String.trim_trailing(remotes[remote] || "", "/")}/#{p[:name]}",
         revision: p[:revision] || default[:revision]
       }}
    end
  end
end
