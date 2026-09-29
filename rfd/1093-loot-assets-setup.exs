# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 1093. `mix rfd.render` renders rfd/1093-loot-assets-setup/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD1093 do
  use RFD.DSL

  rfd 1093, "Loot assets, fetched, never committed" do
    state :abandoned

    scope "`public/loot-assets/`, `scripts/loot-assets-paths.mjs`, `scripts/ensure-loot-assets.mjs`"

    attest_in :none

    decision ~S"""
    Never commit the binaries. `npm run get-assets` clones
    `m3-org/loot-assets`, and links or inlines it depending on
    environment: a sibling clone linked into `public/loot-assets` for
    local development, a shallow clone straight into `public/loot-assets`
    for Vercel and CI (`npm run build` runs `get-assets` first). `git
    push` carries only app code; `public/loot-assets/` stays gitignored.
    App code reads `/loot-assets/…` with no import-path change
    (`src/library/lootAssetsConfig.js`).

    See `DETAILS.md` for the local layout, the quick-start commands, and
    the CDN alternative for a bundle-free Vercel build.
    """

    problem ~S"""
    Loot asset binaries have no place in this project's own git
    history. `github.com/m3-org/loot-assets` already holds them as the
    source of truth; committing a second copy here would duplicate that
    data and drift from it.
    """

    related ~S"""
    RFD 1103 gives the CDN-manifest alternative
    (`VITE_ASSET_PATH=https://m3-org.github.io/loot-assets/`) this
    RFD's `vercel.json` sets by default.
    """

    drafted_by :ai
  end
end
