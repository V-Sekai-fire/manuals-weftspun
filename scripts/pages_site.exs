# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: Apache-2.0 OR MIT
# Gathers the rendered RFDs into a Jekyll source tree with an index, one row per RFD.
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

rows =
  for dir <- Path.wildcard(Path.join(root, "rfd/*/")) |> Enum.filter(&File.dir?/1) |> Enum.sort(),
      readme = Path.join(dir, "README.md"),
      File.exists?(readme) do
    slug = Path.basename(dir)
    File.mkdir_p!(Path.join([out, "rfd", slug]))

    for f <- ["README.md", "DETAILS.md"],
        File.exists?(Path.join(dir, f)),
        do: File.cp!(Path.join(dir, f), Path.join([out, "rfd", slug, f]))

    title =
      readme
      |> File.read!()
      |> String.split("\n")
      |> Enum.find("", &String.starts_with?(&1, "# "))
      |> String.trim_leading("# ")

    link = "[#{String.slice(slug, 0, 4)}](rfd/#{slug}/README.html)"
    "| #{link} | #{String.replace(title, "|", "\\|")} |"
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

| RFD | title |
| --- | --- |
#{Enum.join(rows, "\n")}

## Logbook

#{Enum.join(logs, "\n")}
"""

File.write!(Path.join(out, "index.md"), index)
IO.puts("pages: #{length(rows)} RFDs in #{out}")
