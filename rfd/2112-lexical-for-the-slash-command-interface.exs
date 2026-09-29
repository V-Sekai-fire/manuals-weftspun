# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2112. `mix rfd.render` renders rfd/2112-lexical-for-the-slash-command-interface/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2112 do
  use RFD.DSL

  rfd 2112, "Lexical for the slash command interface" do
    state :abandoned

    decision ~S"""
    The slash command field is a Lexical editor, with its versions pinned
    exactly, so a parameter shows as an inline block the player cannot edit.
    """

    problem ~S"""
    `fabric-store-domain/src/queen.c` is the Queen of the Gyre. Its
    `main()` takes `play|check <cycles> [seed] [sparks]`, founds a ward,
    runs the cycles, prints a chronicle, and exits. There is no socket, no
    server, and no instance that outlives the run. The README says the
    same thing from the other side: the game has no renderer, no client,
    and no engine, and what you can see of it is what you can `SELECT`.
    """

    related ~S"""
    `fabric-store-domain/src/queen.c` is the game the field would drive.
    """

    drafted_by :ai
  end
end
