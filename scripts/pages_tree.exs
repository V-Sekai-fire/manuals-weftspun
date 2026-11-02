# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT
# The prerequisite tree behind one goal RFD: nodes, links, token spends, skipped-ahead links.
defmodule PagesTree do
  @max_depth 4
  @advanced ~w(published committed)
  @unsettled ~w(prediscussion ideation discussion)

  @tokens [
    {1, "Guest ELFs on the pinned double engine", ~r/guest ELF|riscv64|libriscv|godot-sandbox/,
     ~r/guest|riscv/},
    {2, "SQLite on FoundationDB pages", ~r/FoundationDB|fdb-sqlite/, ~r/FoundationDB|fdb/},
    {3, "Bao", ~r/\bBao\b|OpenBao/, ~r/\bBao\b|OpenBao/},
    {4, "Fly", ~r/\bFly\b|Fly\.io/, ~r/\bFly\b/},
    {5, "Tailscale", ~r/Tailscale/, ~r/Tailscale/},
    {6, "FEX", ~r/\bFEX\b/, ~r/\bFEX\b/},
    {7, "Proton", ~r/\bProton\b/, ~r/\bProton\b/}
  ]

  @boring [
    {"B1", "Elixir", ~r/Elixir|BEAM/, ~r/Elixir|BEAM/},
    {"B2", "pixi", ~r/\bpixi\b/, ~r/\bpixi\b/},
    {"B3", "prek", ~r/\bprek\b/, ~r/\bprek\b/},
    {"B4", "cross-build image", ~r/llvm-mingw|osxcross/, ~r/cross-build|llvm-mingw|osxcross/}
  ]

  def build(docs, logs, goal, repos, asof) do
    live = Enum.reject(docs, &(&1.state == "abandoned"))
    known = MapSet.new(live, & &1.serial)
    by = Map.new(live, &{&1.serial, &1})
    links = Map.new(live, &{&1.serial, cites(&1, known)})
    depth = depths(links, goal)

    nodes =
      for {serial, d} <- Enum.sort(depth), d <= @max_depth do
        doc = by[serial]

        %{
          n: serial,
          t: String.replace(doc.label, ~r/^RFD66606-\d+: /, ""),
          s: doc.state,
          id: doc.id,
          d: d,
          u: doc.date,
          l: evidence(logs, serial),
          k: for({i, _, re, _} <- @tokens, Regex.match?(re, doc.text), do: i),
          b: for({i, _, re, _} <- @boring, Regex.match?(re, doc.text), do: i),
          c: links[serial] |> Enum.filter(&Map.has_key?(depth, &1)) |> Enum.sort()
        }
      end

    shown = MapSet.new(nodes, & &1.n)

    skips =
      for n <- nodes,
          m <- n.c,
          n.s in @advanced,
          by[m].state in @unsettled,
          m in shown,
          depth[m] > n.d,
          do: [n.n, m]

    %{
      goal: goal,
      asof: asof,
      nodes: nodes,
      skips: skips,
      tokens: tokens(live, nodes),
      boring: boring(live, nodes),
      repos: repos,
      all: depth |> Map.keys() |> length()
    }
  end

  def json(data) do
    data |> JSON.encode!() |> String.replace("</", "<\\/")
  end

  def markdown(data) do
    by = Map.new(data.nodes, &{&1.n, &1})
    link = fn n -> "[RFD66606-#{n}](##{by[n].id})" end

    [
      "### 1.1. How to read the map {#s1-1}\n\n" <> reading(data),
      "### 1.2. Innovation tokens and boring technology {#s1-2}\n\n" <> ledger(data, link),
      "### 1.3. Progress to the goal {#s1-3}\n\n" <> progress(data, by, link),
      "### 1.4. Skipped ahead {#s1-4}\n\n" <> skipped(data, by, link),
      "### 1.5. Technologies with no link {#s1-5}\n\n" <> unlinked(data, link),
      "### 1.6. Repositories on the map {#s1-6}\n\n" <> repos(data, link)
    ]
    |> Enum.join("\n\n")
  end

  defp needs(by, n), do: for(m <- n.c, by[m] && by[m].d > n.d, do: by[m])
  defp done?(n), do: n.s in @advanced

  def status(by, n) do
    cond do
      done?(n) -> :done
      Enum.all?(needs(by, n), &done?/1) -> :ready
      true -> :blocked
    end
  end

  defp progress(data, by, link) do
    goal = by[data.goal]
    path = path(by, data.goal)
    stat = Enum.frequencies(for n <- path, do: status(by, n))
    ready = for n <- path, status(by, n) == :ready, do: link.(n.n)

    "As of #{data.asof}, #{Map.get(stat, :done, 0)} of the #{length(path)} skills on the " <>
      "goal's path are settled (committed or published), #{Map.get(stat, :ready, 0)} are " <>
      "ready and #{Map.get(stat, :blocked, 0)} are blocked by a skill that is open. " <>
      "The goal, #{link.(goal.n)}, is #{goal.s}.\n\n" <>
      "A skill is ready when it is open and every skill it cites at a deeper ring is settled. " <>
      "Ready now: #{cap(ready, 12)}."
  end

  def path(by, goal) do
    walk = fn walk, todo, seen ->
      case todo do
        [] ->
          seen

        [n | rest] ->
          fresh = for m <- needs(by, by[n]), not MapSet.member?(seen, m.n), do: m.n
          walk.(walk, rest ++ fresh, Enum.reduce(fresh, seen, &MapSet.put(&2, &1)))
      end
    end

    for n <- MapSet.to_list(walk.(walk, [goal], MapSet.new([goal]))), do: by[n]
  end

  defp reading(data) do
    "The goal sits in the middle. A ring is one step further from the goal, and a line joins " <>
      "a skill to a skill it cites. A skill needs the skills it cites at a deeper ring. " <>
      "#{length(data.nodes)} of the #{data.all} skills reachable from the goal are on the " <>
      "map, " <>
      "read as of #{data.asof}.\n\n" <>
      "- A filled node is settled: its RFD is committed or published. An orange outline is " <>
      "ready: open, with everything it needs settled. A grey outline is blocked by a skill " <>
      "that is open. The arc around a node is the share of its path that is settled.\n" <>
      "- A dot on a node is a token it spends: a square for an innovation token, a circle " <>
      "for a boring one.\n" <>
      "- A red dashed line is a skill that is settled while a skill it needs is open: " <>
      "skipped ahead.\n" <>
      "- A hexagon on the outer ring is a token sphere. Select it to travel down it: the " <>
      "persona planner, compiled to WebAssembly, orders the skills still to settle and the " <>
      "map numbers them. A dashed hexagon is a token no RFD title names, and its red lines " <>
      "run to the skills that spend it.\n" <>
      "- Selecting a skill shows its logbook evidence, when its RFD last changed and the " <>
      "route to it.\n\nWithout a script, the tables below carry the same facts."
  end

  defp ledger(data, link) do
    rows =
      for t <- data.tokens ++ data.boring do
        owners = t.owners |> Enum.map(&"RFD66606-#{&1}") |> cap()
        settled = Enum.count(data.nodes, &(&1.n in t.users and done?(&1)))

        "| #{t.i} | #{t.name} | #{owners} | #{settled} of #{length(t.users)} | " <>
          "#{cap(Enum.map(t.users, link), 6)} |"
      end

    "An innovation token is a substrate: delete it and the stack crashes (RFD66606-2351). " <>
      "A boring token is a technology that spends no innovation token: its failure stops a " <>
      "tool or a gate, and nothing ships into the app. Both kinds are counted. Each " <>
      "technology below is tagged from the RFD text, " <>
      "as RFD66606-2351 tagged repositories from their metadata, so a mention counts as a " <>
      "use.\n\n" <>
      "| token | technology | RFDs whose title names it | settled | skills on the map |\n" <>
      "| --- | --- | --- | --- | --- |\n#{Enum.join(rows, "\n")}\n\n" <>
      "The map holds #{length(data.tokens)} innovation tokens and #{length(data.boring)} " <>
      "boring tokens."
  end

  defp cap(items, max \\ 4)
  defp cap([], _max), do: "none"
  defp cap(items, max) when length(items) <= max, do: Enum.join(items, ", ")

  defp cap(items, max) do
    Enum.join(Enum.take(items, max), ", ") <> ", and #{length(items) - max} more"
  end

  defp skipped(data, by, link) do
    items =
      for [a, b] <- data.skips do
        "- #{link.(a)} is #{by[a].s} and cites #{link.(b)}, which is #{by[b].s}."
      end

    "#{length(items)} skills on the map are settled while a skill they need is still open. " <>
      "Each is a technology switched on before its prerequisite.\n\n#{Enum.join(items, "\n")}"
  end

  defp unlinked(data, link) do
    open = Enum.filter(data.tokens ++ data.boring, &(&1.owners == []))

    items =
      for t <- open do
        users =
          if t.users == [],
            do: "no node on the map",
            else: Enum.map_join(t.users, ", ", &link.(&1))

        "- Token #{t.i}, #{t.name}, is spent by #{users}. No RFD title names it."
      end

    "A token the goal spends, with no RFD title naming it, is a technology skipped ahead " <>
      "without a link.\n\n#{Enum.join(items, "\n")}"
  end

  defp repos(data, link) do
    rows =
      for r <- data.repos do
        "- [#{r.repo}](https://github.com/#{r.repo}) holds the code of #{link.(r.n)}. " <> r.note
      end

    Enum.join(rows, "\n")
  end

  defp evidence(logs, serial) do
    hits = for l <- logs, cited?(l.text, serial), do: [l.date, l.label, l.id]
    hits |> Enum.sort(:desc) |> then(&%{total: length(&1), latest: Enum.take(&1, 3)})
  end

  defp cited?(text, serial) do
    tag = "RFD66606-#{serial}"
    String.contains?(text, tag) or Enum.any?(ranges(text), &(serial in &1))
  end

  defp ranges(text) do
    for [_, a, b] <- Regex.scan(~r/RFD66606-(\d{4}) to RFD66606-(\d{4})/, text),
        do: String.to_integer(a)..String.to_integer(b)//1
  end

  defp cites(doc, known) do
    singles = for [_, n] <- Regex.scan(~r/RFD66606-(\d{4})/, doc.text), do: String.to_integer(n)

    ranges =
      for [_, a, b] <- Regex.scan(~r/RFD66606-(\d{4}) to RFD66606-(\d{4})/, doc.text),
          n <- String.to_integer(a)..String.to_integer(b)//1,
          do: n

    (singles ++ ranges) |> Enum.uniq() |> Enum.filter(&(&1 != doc.serial and &1 in known))
  end

  defp depths(links, goal), do: walk([goal], links, %{goal => 0})

  defp walk([], _links, seen), do: seen

  defp walk([n | queue], links, seen) do
    fresh = for m <- Map.get(links, n, []), not Map.has_key?(seen, m), do: m
    seen = Enum.reduce(fresh, seen, &Map.put(&2, &1, seen[n] + 1))
    walk(queue ++ fresh, links, seen)
  end

  defp boring(live, nodes) do
    for {i, name, _, title_re} <- @boring do
      owners = for d <- live, Regex.match?(title_re, d.label), do: d.serial
      users = for n <- nodes, i in n.b, do: n.n
      %{i: i, name: name, owners: owners, users: users}
    end
  end

  defp tokens(live, nodes) do
    for {i, name, _, title_re} <- @tokens do
      owners = for d <- live, Regex.match?(title_re, d.label), do: d.serial
      users = for n <- nodes, i in n.k, do: n.n
      %{i: i, name: name, owners: owners, users: users}
    end
  end
end
