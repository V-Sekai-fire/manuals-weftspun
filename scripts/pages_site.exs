# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT
# Builds the Pages source as one flow: sources -> records -> groups -> expanders -> files.
# A masthead and the newest RFDs lead; the logbook and RFD archives follow, dated from git.
#   mix run scripts/pages_site.exs <out-dir>
defmodule PagesSite do
  @states ~w(prediscussion ideation discussion published committed moved abandoned)
  @emoji %{
    "prediscussion" => "📝",
    "ideation" => "💡",
    "discussion" => "💬",
    "published" => "📢",
    "committed" => "✅",
    "abandoned" => "🪦",
    "moved" => "➡️"
  }
  @pages ~w(README.md AGENTS.md BLOCKLIST.md PITFALLS.md KEYPOINTS.md)

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

    File.write!(Path.join(out, "_config.yml"), config())
    File.mkdir_p!(Path.join(out, "_layouts"))
    File.write!(Path.join(out, "_layouts/default.html"), layout())
    File.write!(Path.join(out, "index.md"), index(logs, rfds, edition(root)))
    IO.puts("pages: #{length(logs)} logbook entries and #{length(rfds)} RFDs in #{out}")
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
        File.read!(from)
        |> String.replace("`DETAILS.md`", "[`DETAILS.md`](DETAILS.html)")
        |> linked(up, slugs, Map.get(e, :serial))

      text = if paired, do: nav(Path.basename(to), text), else: text
      File.write!(Path.join(out, to), edit_from(e.source, index_of(to)) <> text)
    end
  end

  defp nav("README.md", text), do: under_title(text, "> **[Read the details →](DETAILS.html)**")
  defp nav("DETAILS.md", text), do: under_title(text, "> **[← Back to the RFD](./)**")
  defp nav(_, text), do: text

  defp under_title(text, line) do
    [title | rest] = String.split(text, "\n", parts: 2)
    Enum.join([title, "", line, "", String.trim_leading(hd(rest ++ [""]))], "\n")
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
      Enum.map_join(log_groups, "\n", fn {g, es} ->
        expander("#{g} (#{length(es)})", log_list(es), false)
      end)

    rfd_body =
      Enum.map_join(rfd_groups, "\n", fn {s, es} ->
        expander("#{@emoji[s]} #{s} (#{length(es)})", rfd_table(es), false)
      end)

    tally = Enum.map_join(rfd_groups, " · ", fn {s, es} -> "#{@emoji[s]} #{length(es)} #{s}" end)
    latest_rfds = rfds |> Enum.sort_by(&{&1.date, &1.serial}, :desc) |> Enum.take(10)

    [
      "# manuals-weftspun",
      "**Edition of #{ed.date}** · built from `#{ed.sha}` · " <>
        "#{length(logs)} logbook entries · #{length(rfds)} RFDs · " <>
        "[working agreements](page-CLAUDE.html) · [blocklist](page-BLOCKLIST.html)",
      "What the workspace measured (the logbook) and what it decided from that (the RFDs, " <>
        "also called requests for discussion, design docs or architecture decision records).",
      tally,
      "## Recently changed RFDs",
      dated_table(latest_rfds),
      "## Archive",
      expander("Logbook (#{length(logs)} entries)", log_body, false),
      expander("RFDs (#{length(rfds)})", legend() <> "\n\n" <> rfd_body, false)
    ]
    |> Enum.join("\n\n")
  end

  defp expander(summary, body, open?) do
    """
    <details#{if open?, do: " open", else: ""} markdown="1">
    <summary>#{summary}</summary>

    #{body}

    </details>
    """
  end

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

  @cited ~r/(?<![\[\w\/-])RFDs? (\d{4}(?:(?:,| and| or|, and) \d{4})*)(?![\]\w])/

  defp shorten(text, to) do
    Regex.replace(@cited, text, fn _, ns ->
      Regex.replace(~r/\d{4}/, ns, &to.(String.to_integer(&1)))
    end)
  end

  defp legend do
    "Status: 📝 prediscussion, 💡 ideation, 💬 discussion, 📢 published, " <>
      "✅ committed, ➡️ moved, 🪦 abandoned; " <>
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
