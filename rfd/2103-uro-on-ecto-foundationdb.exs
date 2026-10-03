# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2103, "Uro on Ecto over FoundationDB", :discussion do
  feature "Uro's Ecto repo on SQLite whose pages live in FoundationDB"
  scope "`contract-zone-backend` (Uro), `datasource-store` (the `weft_fdb` VFS), and
`apparatus/2103-uro-on-ecto-foundationdb/pointget.c`"

  prose ~S"""
  :: decision
  Uro's `Uro.Repo` runs `Ecto.Adapters.SQLite3` (`ecto_sqlite3`) against a
  SQLite database opened on the `weft_fdb` VFS, `file:uro.v1?vfs=weft_fdb`,
  so every page lives in FoundationDB and no local file holds the data.
  Uro keeps Ecto, its schemas and SQL with joins; FoundationDB is the page
  store RFD 2109 chose. Each open of a `weft_fdb` database takes its fence,
  so the repo runs one connection, with an exclusive lock and an in-memory
  journal.
  :: problem
  RFD 2109 makes FoundationDB the store, and Uro is an Ecto application.
  An Ecto adapter over FoundationDB's key-value API answers a query only
  when one Get or one GetRange satisfies it, with no joins and no
  aggregates, which Uro's schemas do not fit. SQLite keeps the relational
  form, and the VFS moves its pages into FoundationDB beneath it.
  :: related
  - RFD 2109, the two tiers with FoundationDB as the store.
  - RFD 2140, OpenBao on FoundationDB.
  - RFD 2143, the FoundationDB backup to R2.
  """

  details_title "Uro on Ecto over FoundationDB"

  prose ~S"""
  :: details Where it lives
  - `contract-zone-backend`: `lib/uro/repo.ex` (the adapter),
    `config/runtime.exs` (the database URL and the one connection),
    `config/test.exs`, `.github/workflows/ci.yml`
  - `datasource-store`: the `weft_fdb` VFS and its loadable `weftfdb`
    extension
  - `apparatus/2103-uro-on-ecto-foundationdb/pointget.c`: FoundationDB point
    reads, one transaction each and in one shared transaction
  :: details What checks it
  The `mix test` job of `contract-zone-backend`'s CI starts a single-node
  FoundationDB, builds `datasource-store`'s `weftfdb` extension at a pinned
  commit, and runs the migrations, the seeds and the suite against
  `file:uro_test.v1?vfs=weft_fdb`. It then checks that the rows are
  FoundationDB keys under `weft/db/uro_test.v1/` with no local file. Its
  control runs the suite without the extension loaded, and the database
  must fail to open.

  The one connection is configuration, set in `config/runtime.exs`, and
  holds by agreement with `datasource-store`'s fence; no gate counts
  connections.
  """
end
