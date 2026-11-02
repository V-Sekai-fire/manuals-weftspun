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
    {"Elixir", ~r/Elixir|BEAM/},
    {"pixi", ~r/\bpixi\b/},
    {"prek", ~r/\bprek\b/},
    {"cross-build image", ~r/llvm-mingw|osxcross/}
  ]

  def build(docs, goal, repos) do
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
          k: for({i, _, re, _} <- @tokens, Regex.match?(re, doc.text), do: i),
          b: for({name, re} <- @boring, Regex.match?(re, doc.text), do: name),
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
          do: [n.n, m]

    %{
      goal: goal,
      nodes: nodes,
      skips: skips,
      tokens: tokens(live, nodes),
      boring: for({name, _} <- @boring, do: name),
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
      "### 1.3. Skipped ahead {#s1-3}\n\n" <> skipped(data, by, link),
      "### 1.4. Technologies with no link {#s1-4}\n\n" <> unlinked(data, link),
      "### 1.5. Repositories on the map {#s1-5}\n\n" <> repos(data, link)
    ]
    |> Enum.join("\n\n")
  end

  defp reading(data) do
    "Tokens buy skills. A skill is an RFD, and acquiring it spends the technologies it names: " <>
      "an innovation token for a substrate the stack cannot run without, a boring token for " <>
      "technology whose failure stops only a tool or a gate. The goal sits in the middle. " <>
      "A ring is one step further from the goal, and a line joins a skill to a skill it " <>
      "cites. #{length(data.nodes)} of the #{data.all} skills reachable from the goal are on " <>
      "the map.\n\n" <>
      "- A filled node is acquired: its RFD is committed or published. Select a skill to " <>
      "acquire it, or acquire its whole path, and the token wallet above the map shows what " <>
      "that spends.\n" <>
      "- A dot on a node is a token it spends: a square for an innovation token, a circle " <>
      "for a boring one.\n" <>
      "- A red dashed line is a skill acquired while a skill it cites is not: skipped ahead.\n" <>
      "- A dashed hexagon is an innovation token no RFD title names. Its lines run to the " <>
      "skills that spend it.\n\nWithout a script, the tables below carry the same facts."
  end

  defp ledger(data, link) do
    rows =
      for t <- data.tokens do
        owners =
          if t.owners == [], do: "none", else: Enum.map_join(t.owners, ", ", &"RFD66606-#{&1}")

        users = if t.users == [], do: "none", else: Enum.map_join(t.users, ", ", &link.(&1))
        "| #{t.i} | #{t.name} | #{owners} | #{users} |"
      end

    "An innovation token is a substrate: delete it and the stack crashes (RFD66606-2351). " <>
      "A boring token is technology that spends none: its failure stops a tool or a gate, " <>
      "and nothing ships into the app. Each technology below is tagged from the RFD text, " <>
      "as RFD66606-2351 " <>
      "tagged repositories from their metadata, so a mention counts as a use.\n\n" <>
      "| token | technology | RFDs whose title names it | skills on the map |\n" <>
      "| --- | --- | --- | --- |\n#{Enum.join(rows, "\n")}\n\n" <>
      "Boring tokens on the map: #{Enum.join(data.boring, ", ")}."
  end

  defp cap(items, max \\ 4)
  defp cap([], _max), do: "none"
  defp cap(items, max) when length(items) <= max, do: Enum.join(items, ", ")

  defp cap(items, max),
    do: Enum.join(Enum.take(items, max), ", ") <> ", and #{length(items) - max} more"

  defp skipped(data, by, link) do
    items =
      for [a, b] <- data.skips do
        "- #{link.(a)} is #{by[a].s} and cites #{link.(b)}, which is #{by[b].s}."
      end

    "#{length(items)} skills on the map are acquired while a skill they cite is still open. " <>
      "Each is a technology switched on before its prerequisite.\n\n#{Enum.join(items, "\n")}"
  end

  defp unlinked(data, link) do
    open = Enum.filter(data.tokens, &(&1.owners == []))

    items =
      for t <- open do
        users =
          if t.users == [],
            do: "no node on the map",
            else: Enum.map_join(t.users, ", ", &link.(&1))

        "- Token #{t.i}, #{t.name}, is used by #{users}. No RFD title names it."
      end

    "A token the goal spends, with no RFD of its own, is a skill acquired without a link to " <>
      "the technology that pays for it.\n\n#{Enum.join(items, "\n")}"
  end

  defp repos(data, link) do
    rows =
      for r <- data.repos do
        "- [#{r.repo}](https://github.com/#{r.repo}) holds the code of #{link.(r.n)}. " <> r.note
      end

    Enum.join(rows, "\n")
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

  defp tokens(live, nodes) do
    for {i, name, _, title_re} <- @tokens do
      owners = for d <- live, Regex.match?(title_re, d.label), do: d.serial
      users = for n <- nodes, i in n.k, do: n.n
      %{i: i, name: name, owners: owners, users: users}
    end
  end
end
