# manuals-weftspun

The workspace's design record: its RFDs, logbook and working agreements, with the Elixir project that renders and gates them.

## What it is for

Each RFD and each serial register is an Elixir source that checks its own shape while it compiles, and the Mix project renders the sources to Markdown and USD. The working agreements every project in the workspace follows are in `CLAUDE.md`. RFD 1000 owns the conventions and RFD 2232 owns the authoring format.

## Build and run

    mix rfd.render
    mix test

The remaining gates run as prek hooks.

## Licence

Apache-2.0 OR MIT; see `LICENSE-APACHE` and `LICENSE-MIT`.
