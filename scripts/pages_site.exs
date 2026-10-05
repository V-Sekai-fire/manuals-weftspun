# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT
# Gathers the rendered RFDs into a Jekyll source tree with an index, one row per RFD.
# The status column carries emoji for state, drafting and details; titles stay plain text.
#   elixir scripts/pages_site.exs <out-dir>
[out] = System.argv()
root = Path.expand("..", __DIR__)
File.rm_rf!(out)
File.mkdir_p!(Path.join(out, "rfd"))

config = """
title: manuals-weftspun
description: RFDs, logbook and working agreements
theme: jekyll-theme-primer
"""

File.write!(Path.join(out, "_config.yml"), config)

states = %{
  "prediscussion" => "📝", "ideation" => "💡", "discussion" => "💬", "published" => "📢",
  "committed" => "✅", "abandoned" => "🪦", "moved" => "➡️"
}

status = fn readme_text, dir ->
  state =
    case Regex.run(~r/^\*\*State:\*\* (\w+)/m, readme_text) do
      [_, s] -> Map.get(states, s, "❔")
      _ -> "❔"
    end

  details = Path.join(dir, "DETAILS.md")
  both = String.replace(readme_text <> " " <> if(File.exists?(details), do: File.read!(details), else: ""), ~r/\s+/, " ")

  drafted =
    cond do
      String.contains?(both, "This RFD was drafted by an AI and read by a human before it shipped.") -> "🤖"
      String.contains?(both, "This RFD was drafted by a human without AI help.") -> "✍️"
      true -> ""
    end

  [state, drafted, if(File.exists?(details), do: "📎", else: "")] |> Enum.reject(&(&1 == "")) |> Enum.join(" ")
end

rows =
  for dir <- Path.wildcard(Path.join(root, "rfd/*/")) |> Enum.filter(&File.dir?/1) |> Enum.sort(),
      readme = Path.join(dir, "README.md"),
      File.exists?(readme) do
    slug = Path.basename(dir)
    File.mkdir_p!(Path.join([out, "rfd", slug]))

    for f <- ["README.md", "DETAILS.md"], File.exists?(Path.join(dir, f)) do
      text =
        String.replace(
          File.read!(Path.join(dir, f)),
          "`DETAILS.md`",
          "[`DETAILS.md`](DETAILS.html)"
        )

      File.write!(Path.join([out, "rfd", slug, f]), text)
    end

    readme_text = File.read!(readme)

    title =
      readme_text
      |> String.split("\n")
      |> Enum.find("", &String.starts_with?(&1, "# "))
      |> String.trim_leading("# ")

    link = "[#{String.slice(slug, 0, 4)}](rfd/#{slug}/)"
    "| #{link} | #{status.(readme_text, dir)} | #{String.replace(title, "|", "\\|")} |"
  end

File.mkdir_p!(Path.join(out, "logbook"))

logs =
  for f <- Path.wildcard(Path.join(root, "logbook/*.md")) |> Enum.sort() do
    File.cp!(f, Path.join([out, "logbook", Path.basename(f)]))
    "- [#{Path.basename(f, ".md")}](logbook/#{Path.basename(f, ".md")}.html)"
  end

for f <- ~w(README.md CLAUDE.md BLOCKLIST.md PITFALLS.md KEYPOINTS.md),
    File.exists?(Path.join(root, f)),
    do: File.cp!(Path.join(root, f), Path.join(out, "page-" <> f))

index = """
# manuals-weftspun

The workspace's RFDs (also called requests for discussion, design docs or
architecture decision records), rendered from their Elixir sources, with the
logbook below and the [working agreements](page-CLAUDE.html).

Status: 📝 prediscussion, 💡 ideation, 💬 discussion, 📢 published, ✅ committed,
🪦 abandoned, ➡️ moved; 🤖 drafted by an AI and read by a human, ✍️ drafted by a
human; 📎 has details.

| RFD | status | title |
| --- | --- | --- |
#{Enum.join(rows, "\n")}

## Logbook

#{Enum.join(logs, "\n")}
"""

File.write!(Path.join(out, "index.md"), index)
IO.puts("pages: #{length(rows)} RFDs in #{out}")
