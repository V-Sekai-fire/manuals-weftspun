# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT
# Builds the Pages source as one flow: sources -> records -> groups -> expanders -> files.
# The logbook (what was measured) comes first and the RFDs (what was decided) second.
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
  @pages ~w(README.md CLAUDE.md BLOCKLIST.md PITFALLS.md KEYPOINTS.md)

  def main([out]) do
    root = Path.expand("..", __DIR__)
    File.rm_rf!(out)

    logs = logbook(root)
    rfds = rfds()

    Enum.each(logs ++ rfds, &copy(&1, out))

    for f <- @pages,
        File.exists?(Path.join(root, f)),
        do: File.cp!(Path.join(root, f), Path.join(out, "page-" <> f))

    File.write!(Path.join(out, "_config.yml"), config())
    File.write!(Path.join(out, "index.md"), index(logs, rfds))
    IO.puts("pages: #{length(logs)} logbook entries and #{length(rfds)} RFDs in #{out}")
  end

  # Sources become records: what the index shows and which files the site carries.
  defp logbook(root) do
    for f <- Path.wildcard(Path.join(root, "logbook/*.md")) |> Enum.sort() do
      slug = Path.basename(f, ".md")
      words = slug |> String.replace_prefix("logbook-", "") |> String.split("-")

      %{
        kind: :log,
        group: hd(words),
        label: Enum.join(words, " "),
        href: "logbook/#{slug}.html",
        files: [{f, "logbook/#{slug}.md"}]
      }
    end
  end

  defp rfds do
    for path <- RFD.Source.all(),
        dir = RFD.Source.dir_of(path),
        File.exists?(Path.join(dir, "README.md")) do
      d = RFD.Source.load(path)
      slug = Path.basename(dir)
      drafted = d.attest_in != :none && %{ai: "🤖", human: "✍️"}[d.drafted_by]
      status = [Map.get(@emoji, to_string(d.state), "❔"), drafted, RFD.Doc.details(d) && "📎"]

      %{
        kind: :rfd,
        group: to_string(d.state),
        serial: d.serial,
        label: "RFD #{d.serial}: #{d.title}",
        status: status |> Enum.reject(&(&1 in [nil, false])) |> Enum.join(" "),
        href: "rfd/#{slug}/",
        files:
          for(
            f <- ["README.md", "DETAILS.md"],
            File.exists?(Path.join(dir, f)),
            do: {Path.join(dir, f), "rfd/#{slug}/#{f}"}
          )
      }
    end
  end

  defp copy(%{files: files}, out) do
    for {from, to} <- files do
      File.mkdir_p!(Path.dirname(Path.join(out, to)))
      text = File.read!(from) |> String.replace("`DETAILS.md`", "[`DETAILS.md`](DETAILS.html)")
      File.write!(Path.join(out, to), text)
    end
  end

  # Records become groups, and groups become expanders.
  defp index(logs, rfds) do
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

    """
    # manuals-weftspun

    The workspace's logbook and its RFDs (also called requests for discussion, design docs or
    architecture decision records). The logbook records what was measured; the RFDs record what
    was decided from it. Both are rendered from this repository, with the
    [working agreements](page-CLAUDE.html) alongside.

    #{expander("Logbook (#{length(logs)} entries)", log_body, true)}

    #{expander("RFDs (#{length(rfds)})", legend() <> "\n\n" <> rfd_body, true)}
    """
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
        &"| [#{&1.serial}](#{&1.href}) | #{&1.status} | #{String.replace(&1.label, "|", "\\|")} |"
      )

    "| RFD | status | title |\n| --- | --- | --- |\n" <> rows
  end

  defp legend do
    "Status: 📝 prediscussion, 💡 ideation, 💬 discussion, 📢 published, " <>
      "✅ committed, ➡️ moved, 🪦 abandoned; 🤖 drafted by an AI and read by a human, " <>
      "✍️ drafted by a human; 📎 has details."
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
