# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 1020, "SQLite persistence for catalog facts", :committed do
  scope "`weftspun_studio/`"
  attest_in :none

  prose ~S"""
  :: decision
  **Use SQLite for storage, and Ecto for the mapping.** The service owns one
  file. `Ecto.Adapters.SQLite3` drives it through `ecto_sqlite3`, and the
  `facts` table keys each row by its natural key, the model id.

  This RFD covers `weftspun_studio/`. `character_taxonomy/` runs under RFD
  1065 on the same store.

  See `DETAILS.md` for the schema, the seed, the modules, the settings and
  the open risk.
  :: problem
  RFD 1019 builds an API server. An API server must keep its data.

  The fact store in `WeftspunStudio.FactStore` holds facts in memory.
  An Agent rebuilds the store from the RFD 1016 inventory at every
  boot. A trust change dies when the node stops, and a retracted fact
  comes back.

  RFD 1016 records that catalog facts change fast. A license gate
  vetoes a model, a benchmark moves a recommendation, and a backend
  drops a model. The store must keep those changes.
  :: related
  RFD 1016 (the inventory the seed reads), RFD 1019 (the API server),
  RFD 1021 (the vector encoding), RFD 1065 (`character_taxonomy/`).
  """

  details_title "SQLite persistence for catalog facts"

  prose ~S"""
  :: details The facts table
  `priv/repo/migrations/20260804000000_create_facts.exs` creates it, with
  Ecto's migration types:

  | Column        | Type                 | Holds                                            |
  | ------------- | -------------------- | ------------------------------------------------ |
  | `fact_id`     | `string`             | The model id. Primary key.                       |
  | `content`     | `text`               | The label or the task text.                      |
  | `category`    | `string`             | The client feature, such as `image_to_raw_mesh`. |
  | `tags`        | `{:array, :string}`  | Type, host, and status.                          |
  | `trust_score` | `float`              | Zero to one. Feedback moves it.                  |
  | `hrr_vector`  | `binary`             | The packed float64 phase vector.                 |
  | `inserted_at` | `utc_datetime_usec`  | Row creation time.                               |
  | `updated_at`  | `utc_datetime_usec`  | Last change time.                                |

  `ecto_sqlite3` stores `tags` as JSON, and it round-trips and queries
  through `json_each`. The category and trust indexes serve the catalog's
  two reads. The shape follows the hermes-agent holographic memory store,
  as RFD 1019 records.

  `hrr_vector` holds the output of `WeftspunStudio.FactVector.encode/2` as
  a packed binary. `@default_dim` in `WeftspunStudio.FactVector` fixes the
  width at 1024 float64 phase angles, so a row takes 8 kilobytes. The
  changeset derives the vector from the other columns. No caller supplies
  it. A row therefore cannot hold a vector that disagrees with its fields.
  RFD 1021 records the encoding.

  Search reads the candidate rows and scores them in Nx. The database
  applies the trust floor first. A phase similarity over a packed tensor
  has no SQL form, so the algebra stays in Elixir.
  :: details The seed database
  The RFD 1016 inventory is the seed, not a fixed table.
  `WeftspunStudio.Adapters.EctoFactStore.seed/0` writes it once. A
  second run refreshes the same rows and adds no duplicate, because the
  model id is the primary key.

  After the seed the database is the record. Feedback moves a trust
  score. A retraction deletes a row. The seed never overwrites those
  later changes for a fact it does not name.
  :: details Modules
  | Module                                  | Role                                      |
  | --------------------------------------- | ----------------------------------------- |
  | `WeftspunStudio.Repo`                   | The connection pool.                      |
  | `WeftspunStudio.Facts.Fact`             | The schema and the changeset.             |
  | `WeftspunStudio.Adapters.EctoFactStore` | A `Ports.FactSink` adapter.               |
  | `WeftspunStudio.Release`                | Migration and seed for a packaged binary. |

  `EctoFactStore` is the durable twin of `FactStore`. Both implement
  `WeftspunStudio.Ports.FactSink`, so a caller can take either one. The
  port keeps the choice out of the caller.

  A Burrito binary carries no Mix, so `mix ecto.migrate` cannot run
  against it. `WeftspunStudio.Release` does the same work. The command
  line offers `weftspun db migrate`, `weftspun db seed`, and
  `weftspun db status`.
  :: details Local setup and settings
  The database is a file created on demand, so `mix ecto.migrate` is the
  whole instruction and `mix test` needs nothing before it. Each
  environment names its own file in `config/`.

  | Variable           | Default         | Holds                                        |
  | ------------------ | --------------- | -------------------------------------------- |
  | `WEFTSPUN_DB`      | `1`             | Set to `0` to start with no connection pool. |
  | `WEFTSPUN_DB_PATH` | per environment | The database file.                           |
  | `WEFTSPUN_DB_POOL` | `5`             | Pool size in a release.                      |

  The inventory commands need no database. `WEFTSPUN_DB=0` therefore
  lets `weftspun models list` run on a host with no database file.
  :: details The open risk
  A second store is a second source of truth. The HTTP surface reads the
  in-memory `FactStore` (`router.ex`), so the two can drift. Pointing the
  router at `EctoFactStore` and deleting the Agent closes it.

  The column types, the settings and their defaults are read from the
  migration and `config/`; they hold by agreement, and no gate compares
  this page with them.
  """
end
