# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT
# Builds the Pages source as one flow: sources -> records -> groups -> sections -> files.
# A masthead and the newest RFDs lead; the logbook and RFD archives follow, dated from git.
#   mix run scripts/pages_site.exs <out-dir>
defmodule PagesSite do
  @states ~w(prediscussion ideation discussion published committed abandoned)
  @emoji %{
    "prediscussion" => "📝",
    "ideation" => "💡",
    "discussion" => "💬",
    "published" => "📢",
    "committed" => "✅",
    "abandoned" => "🪦"
  }
  @pages ~w(README.md AGENTS.md BLOCKLIST.md PITFALLS.md KEYPOINTS.md)
  @pinned [2360]

  def main([out]) do
    root = Path.expand("..", __DIR__)
    File.rm_rf!(out)

    dates = last_changed(root)
    logs = logbook(root, dates)
    rfds = rfds(dates)

    slugs = Map.new(rfds, &{&1.serial, &1.href})
    Enum.each(logs ++ rfds, &copy(&1, out, slugs))

    for f <- @pages, File.exists?(Path.join(root, f)) do
      text = edit_from(f) <> linked(File.read!(Path.join(root, f)), "", slugs, nil)
      File.write!(Path.join(out, "page-" <> f), text)
    end

    docs = Enum.flat_map(logs ++ rfds, &found/1) ++ Enum.flat_map(@pages, &page_found(root, &1))
    File.mkdir_p!(Path.join(out, "assets"))
    File.write!(Path.join(out, "search.json"), JSON.encode!(docs))
    File.cp!(Path.join(__DIR__, "pages_search.js"), Path.join(out, "assets/search.js"))

    File.write!(Path.join(out, "_config.yml"), config())
    File.mkdir_p!(Path.join(out, "_layouts"))
    File.write!(Path.join(out, "_layouts/default.html"), layout())
    File.write!(Path.join(out, "index.md"), index(logs, rfds, edition(root)))
    File.write!(Path.join(out, "page-SERIALS.md"), serials(root, rfds))
    IO.puts("pages: #{length(logs)} logbook entries, #{length(rfds)} RFDs, #{length(docs)} found")
  end

  defp last_changed(root) do
    {out, 0} = System.cmd("git", ["-C", root, "log", "--format=%x00%cs", "--name-only"])

    out
    |> String.split(<<0>>, trim: true)
    |> Enum.reduce(%{}, fn chunk, acc ->
      [date | files] = String.split(chunk, "\n", trim: true)
      Enum.reduce(files, acc, &Map.put_new(&2, &1, date))
    end)
  end

  defp edition(root) do
    {out, 0} = System.cmd("git", ["-C", root, "log", "-1", "--format=%cs %h"])
    [date, sha] = String.split(String.trim(out), " ")
    %{date: date, sha: sha}
  end

  # Sources become records: what the index shows and which files the site carries.
  defp logbook(root, dates) do
    for f <- Path.wildcard(Path.join(root, "logbook/*.md")) |> Enum.sort() do
      slug = Path.basename(f, ".md")
      words = slug |> String.replace_prefix("logbook-", "") |> String.split("-")

      %{
        kind: :log,
        group: hd(words),
        label: Enum.join(words, " "),
        href: "logbook/#{slug}.html",
        date: Map.get(dates, "logbook/#{slug}.md", ""),
        source: "logbook/#{slug}.md",
        files: [{f, "logbook/#{slug}.md"}]
      }
    end
  end

  defp rfds(dates) do
    for path <- RFD.Source.all(),
        dir = RFD.Source.dir_of(path),
        File.exists?(Path.join(dir, "README.md")) do
      d = RFD.Source.load(path)
      slug = Path.basename(dir)
      drafted = d.attest_in != :none && %{ai: "🧑‍🦰", human: "✍️"}[d.drafted_by]
      status = [Map.get(@emoji, to_string(d.state), "❔"), drafted, RFD.Doc.details(d) && "📎"]

      %{
        kind: :rfd,
        source: "rfd/#{slug}.exs",
        group: to_string(d.state),
        serial: d.serial,
        hook: d.hook && d.hook |> String.split() |> Enum.join(" "),
        nongoals: nongoals(d),
        label: shorten(d.title, &short/1),
        status: status |> Enum.reject(&(&1 in [nil, false])) |> Enum.join(" "),
        href: "rfd/#{slug}/",
        date: Map.get(dates, "rfd/#{slug}.exs", ""),
        files:
          for(
            f <- ["README.md", "DETAILS.md"],
            File.exists?(Path.join(dir, f)),
            do: {Path.join(dir, f), "rfd/#{slug}/#{f}"}
          )
      }
    end
  end

  defp copy(%{files: files} = e, out, slugs) do
    paired = length(files) == 2
    up = String.duplicate("../", length(Path.split(hd(files) |> elem(1))) - 1)

    for {from, to} <- files do
      File.mkdir_p!(Path.dirname(Path.join(out, to)))

      text =
        cond do
          not paired ->
            File.read!(from) |> linked(up, slugs, Map.get(e, :serial))

          Path.basename(to) == "README.md" ->
            merged(files) |> linked(up, slugs, Map.get(e, :serial))

          true ->
            details_moved()
        end

      File.write!(Path.join(out, to), edit_from(e.source, index_of(to)) <> text)
    end
  end

  defp details_moved do
    refresh = ~s(<meta http-equiv="refresh" content="0; url=./">)
    refresh <> "\n\nThe details moved to [the RFD page](./).\n"
  end

  defp merged([{readme, _}, {details, _}]) do
    top =
      File.read!(readme)
      |> String.replace("\n\n`DETAILS.md` carries the rest of this RFD.", "")
      |> then(&Regex.replace(~r/(^|[.!?]\s+|

)`DETAILS\.md`/, &1, fn _, pre -> pre <> "The details section" end))
      |> String.replace("`DETAILS.md`", "the details section")

    [_title, body] = String.split(File.read!(details), "\n", parts: 2)
    seen = String.split(top, ~r/\n\s*\n/) |> Enum.map(&String.trim/1)

    rest =
      body
      |> String.split(~r/\n\s*\n/)
      |> Enum.reject(&(String.trim(&1) in seen))
      |> Enum.join("\n\n")

    case String.split(top, "\n## Related", parts: 2) do
      [head, tail] ->
        String.trim_trailing(head) <> "\n\n" <> String.trim(rest) <> "\n\n## Related" <> tail

      [_] ->
        String.trim_trailing(top) <> "\n\n" <> String.trim(rest) <> "\n"
    end
  end

  # Names a reader would click become links: RFD serials, the blocklist, org repositories.
  @repo ~r{^(V-Sekai-fire|chibifire-smoke-water|chibifire-stages)/[A-Za-z0-9_.-]*[A-Za-z0-9_]$}

  defp linked(text, up, slugs, own) do
    {lines, _} =
      text
      |> String.split("\n")
      |> Enum.map_reduce(false, fn line, fenced ->
        cond do
          String.starts_with?(String.trim_leading(line), "```") -> {line, not fenced}
          fenced -> {line, fenced}
          String.starts_with?(line, "# ") -> {shorten(line, &short/1), fenced}
          true -> {link_line(line, up, slugs, own), fenced}
        end
      end)

    Enum.join(lines, "\n")
  end

  defp link_line(line, up, slugs, own) do
    line
    |> String.split(~r/(`[^`]*`)/, include_captures: true)
    |> Enum.map_join(fn
      "`" <> _ = code ->
        name = String.trim(code, "`")
        if Regex.match?(@repo, name), do: "[#{code}](https://github.com/#{name})", else: code

      prose ->
        prose
        |> shorten(&cite(&1, up, slugs, own))
        |> then(
          &Regex.replace(
            ~r/(?<![\[\w\/`-])BLOCKLIST\.md(?![\]\w])/,
            &1,
            "[BLOCKLIST.md](#{up}page-BLOCKLIST.html)"
          )
        )
    end)
  end

  defp found(%{files: [{_, to}, {_, _}]} = e) do
    [doc(merged(e.files), url_of(to), e.kind, Map.get(e, :status, ""), e.date)]
  end

  defp found(e) do
    for {from, to} <- e.files do
      kind = if Path.basename(to) == "DETAILS.md", do: :details, else: e.kind
      doc(File.read!(from), url_of(to), kind, Map.get(e, :status, ""), e.date)
    end
  end

  defp page_found(root, f) do
    path = Path.join(root, f)

    if File.exists?(path),
      do: [doc(File.read!(path), url_of("page-" <> f), :page, "", "")],
      else: []
  end

  defp doc(text, url, kind, status, date) do
    [title | body] = String.split(text, "\n", parts: 2)
    %{u: url, k: kind, s: status, d: date, t: plain(title), b: plain(Enum.join(body))}
  end

  defp url_of(to) do
    if Path.basename(to) == "README.md" and String.starts_with?(to, "rfd/"),
      do: Path.dirname(to) <> "/",
      else: String.replace_suffix(to, ".md", ".html")
  end

  defp plain(md) do
    md
    |> shorten(&short/1)
    |> String.replace(~r/<[^>]+>/, " ")
    |> String.replace(~r/!?\[([^\]]*)\]\([^)]*\)/, "\\1")
    |> String.replace(~r/[`*#>|]+|-{3,}/, " ")
    |> String.replace(~r/\s+/u, " ")
    |> String.trim()
  end

  # Records become groups, and groups become expanders.
  defp index(logs, rfds, ed) do
    {topics, single} =
      logs |> Enum.group_by(& &1.group) |> Enum.split_with(fn {_, es} -> length(es) > 1 end)

    log_groups =
      Enum.sort(topics) ++
        if(single == [], do: [], else: [{"other", single |> Enum.flat_map(&elem(&1, 1))}])

    rfd_groups =
      for s <- @states,
          es = Enum.filter(rfds, &(&1.group == s)),
          es != [],
          do: {s, Enum.sort_by(es, & &1.serial)}

    log_body =
      Enum.map_join(log_groups, "\n\n", fn {g, es} ->
        "### #{g} (#{length(es)})\n\n" <> log_list(es)
      end)

    rfd_body =
      Enum.map_join(rfd_groups, "\n\n", fn {s, es} ->
        "### #{@emoji[s]} #{s} (#{length(es)})\n\n" <> rfd_table(es)
      end)

    tally = Enum.map_join(rfd_groups, " · ", fn {s, es} -> "#{@emoji[s]} #{length(es)} #{s}" end)
    latest_rfds = rfds |> Enum.sort_by(&{&1.date, &1.serial}, :desc) |> Enum.take(10)

    [
      "# manuals-weftspun",
      "**Edition of #{ed.date}** · built from `#{ed.sha}` · " <>
        "#{length(logs)} logbook entries · #{length(rfds)} RFDs · " <>
        "[working agreements](page-AGENTS.html) · [blocklist](page-BLOCKLIST.html) · " <>
        "[serials](page-SERIALS.html)",
      "What the workspace measured (the logbook) and what it decided from that (the RFDs, " <>
        "also called requests for discussion, design docs or architecture decision records).",
      tally,
      pin_cards(rfds),
      nongoal_card(rfds),
      "## Recently changed RFDs",
      dated_table(latest_rfds),
      "## Logbook (#{length(logs)} entries)",
      log_body,
      "## RFDs (#{length(rfds)})",
      legend(),
      rfd_body
    ]
    |> Enum.join("\n\n")
  end

  defp nongoals(d) do
    case List.keyfind(d.details, "Nongoals", 0) do
      {_, body} ->
        lines = body |> String.split("\n") |> Enum.map(&String.trim/1)
        for "- " <> item <- lines, do: item

      nil ->
        []
    end
  end

  defp nongoal_card(rfds) do
    for e <- rfds, e.serial in @pinned, e.nongoals != [] do
      esc = fn x -> x |> String.replace("&", "&amp;") |> String.replace("<", "&lt;") end
      style = "border:1px solid #d0d7de;border-radius:6px;padding:12px 16px;margin:16px 0"
      items = Enum.map_join(e.nongoals, "\n", fn x -> "<li>" <> esc.(x) <> "</li>" end)
      link = ~s(<a href="#{e.href}">RFD66606-#{e.serial}</a>)
      head = "<div>🚫 Not in the beta · abandoned, not deferred · " <> link <> "</div>"

      ~s(<div style="#{style}">\n) <> head <> "\n<ul>\n" <> items <> "\n</ul>\n</div>"
    end
    |> Enum.join("\n\n")
  end

  defp pin_cards(rfds) do
    for e <- rfds, e.serial in @pinned, e.hook do
      esc = fn x -> x |> String.replace("&", "&amp;") |> String.replace("<", "&lt;") end
      style = "border:1px solid #d0d7de;border-radius:6px;padding:12px 16px;margin:16px 0"

      ~s(<div style="#{style}">
) <>
        ~s(<div>📌 Pinned · RFD66606-#{e.serial} · #{e.status}</div>
) <>
        ~s(<div><a href="#{e.href}"><strong>#{esc.(e.label)}</strong></a></div>
) <>
        ~s(<div>#{esc.(e.hook)}</div>
</div>)
    end
    |> Enum.join("

")
  end

  defp serials(root, rfds) do
    docs = Map.new(rfds, &{&1.serial, &1})

    sites =
      for path <- Path.wildcard(Path.join(root, "SERIALS*.exs")) |> Enum.sort() do
        r = RFD.Source.load(path)

        rows =
          r.rows
          |> Enum.sort_by(&elem(&1, 1))
          |> Enum.map_join("\n", fn {table, serial, slug, opts} ->
            state = row_state(table, opts, docs, serial)
            "| #{serial_cell(serial, docs)} | #{slug || ""} | #{state} |"
          end)

        "## #{r.name} (site #{r.layer[:site]})\n\n#{r.thesis}\n\n" <>
          "| serial | slug | state |\n| --- | --- | --- |\n" <> rows
      end

    [
      edit_from("SERIALS.exs") <> "# Serials",
      "Every serial each register holds, allocated or deleted. A deleted serial keeps its " <>
        "row, so a citation of it still names one document."
      | sites
    ]
    |> Enum.join("\n\n")
  end

  defp serial_cell(serial, docs) do
    case docs[serial] do
      nil -> short(serial)
      e -> link(e)
    end
  end

  defp row_state(:allocated, _opts, docs, serial),
    do: if(docs[serial], do: docs[serial].group, else: "allocated")

  defp row_state(:retired, opts, _docs, _serial),
    do: "retired, recorded in #{short(opts[:recorded_in])}"

  defp row_state(table, _opts, _docs, _serial), do: String.replace(to_string(table), "_", " ")

  defp log_list(es), do: Enum.map_join(es, "\n", &"- [#{&1.label}](#{&1.href})")

  defp rfd_table(es) do
    rows =
      Enum.map_join(
        es,
        "\n",
        &"| #{link(&1)} | #{&1.status} | #{String.replace(&1.label, "|", "\\|")} |"
      )

    "| RFD | status | title |\n| --- | --- | --- |\n" <> rows
  end

  defp dated_table(es) do
    rows =
      Enum.map_join(
        es,
        "\n",
        &"| #{&1.date} | #{link(&1)} | #{&1.status} | #{escape(&1.label)} |"
      )

    "| changed | RFD | status | title |\n| --- | --- | --- | --- |\n" <> rows
  end

  defp escape(text), do: String.replace(text, "|", "\\|")
  defp link(e), do: "[#{short(e.serial)}](#{e.href})"
  defp short(serial), do: "RFD66606-#{serial}"

  defp cite(n, up, slugs, own) do
    href = Map.get(slugs, n)
    if href && n != own, do: "[#{short(n)}](#{up}#{href})", else: short(n)
  end

  @serial "(?:RFD66606-)?\\d{4}"
  @cited ~r/(?<![\[\w\/-])(?:RFDs? |RFD66606-)(\d{4}(?:(?:,? and|,| or) #{@serial})*)(?![\]\w])/

  defp shorten(text, to) do
    Regex.replace(@cited, text, fn _, ns ->
      Regex.replace(~r/(?:RFD66606-)?(\d{4})/, ns, fn _, n -> to.(String.to_integer(n)) end)
    end)
  end

  defp legend do
    "Status: 📝 prediscussion, 💡 ideation, 💬 discussion, 📢 published, " <>
      "✅ committed, 🪦 abandoned; " <>
      "🧑‍🦰 drafted by aria-fire-persona and read by a human, " <>
      "✍️ drafted by a human; 📎 has details."
  end

  # The theme's edit link points at the generated copy; this one points at the tracked source.
  defp edit_from(source, permalink \\ nil) do
    at = if permalink, do: "permalink: #{permalink}\n", else: ""
    "---\nedit_source: #{source}\n#{at}---\n"
  end

  defp index_of("rfd/" <> _ = to),
    do: if(Path.basename(to) == "README.md", do: "/#{Path.dirname(to)}/")

  defp index_of(_), do: nil

  defp layout do
    ~S"""
    <!DOCTYPE html>
    <html lang="{{ page.lang | default: site.lang | default: "en-US" }}">
      <head>
        <meta charset="UTF-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
    {% seo %}
        {% assign css = "/assets/css/style.css?v=" | append: site.github.build_revision %}
        <link rel="stylesheet" href="{{ css | relative_url }}">
        {% include head-custom.html %}
      </head>
      <body>
        <div class="container-lg px-3 my-5 markdown-body">
          {% if site.title and site.title != page.title %}
          <h1><a href="{{ "/" | absolute_url }}">{{ site.title }}</a></h1>
          {% endif %}
          <div id="site-search" role="search" data-base="{{ "/" | relative_url }}">
            <input type="search"
              placeholder="Search RFDs, the logbook and the agreements (press /)"
              aria-label="Search the site" autocomplete="off" spellcheck="false">
            <p hidden></p>
            <ol hidden></ol>
          </div>

          {{ content }}

          {% if page.edit_source %}
          <div class="footer border-top border-gray-light mt-5 pt-3 text-right text-gray">
            This site is open source.
            <a href="{{ site.github.repository_url }}/edit/main/{{ page.edit_source }}">
              Improve this page</a>.
          </div>
          {% endif %}
        </div>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/anchor-js/4.1.0/anchor.min.js"
          integrity="sha256-lZaRhKri35AyJSypXXs4o6OPFTbTmUoltBbDCbdzegg="
          crossorigin="anonymous"></script>
        <script>anchors.add();</script>
        <script src="{{ "/assets/search.js" | relative_url }}" defer></script>
      </body>
    </html>
    """
  end

  defp config do
    """
    title: manuals-weftspun
    description: Logbook, RFDs and working agreements
    theme: jekyll-theme-primer
    """
  end
end

PagesSite.main(System.argv())
