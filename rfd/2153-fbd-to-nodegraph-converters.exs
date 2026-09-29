# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2153. `mix rfd.render` renders rfd/2153-fbd-to-nodegraph-converters/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2153 do
  use RFD.DSL

  rfd 2153, "PLCopen FBD to a social VR world-scripting assembly" do
    compact_head true

    state :prediscussion

    feature "convert taskweft's PLCopen FBD (RFD 2150) directly into
the assembly of a social VR platform's world-scripting VM"

    scope "taskweft (`Taskweft.OpenPLC.WorldVm`)"

    decision ~S"""
    The world-scripting VM is the only node-graph target.

    `DETAILS.md` carries the full text of this RFD.
    """

    problem ~S"""
    RFD 2150 makes PLCopen FBD the one runtime target. The two platforms
    taskweft ships to are **godot-sandbox** (RFD 2154, C++ + Rust ELFs
    via RFD 2159) and a **social VR platform's world-scripting VM**. The
    VM has its own native assembly language; FBD needs a direct compiler
    into it.
    """

    references ~S"""
    1. `sigs/world_vm_asm.sigs`; the target instruction set
    2. RFD 2150 FBD target, RFD 2160 USD intermediate
    3. The platform's MIT-licensed C#-to-VM compiler, the source of truth
       for the opcode set
    """

    details_title "PLCopen FBD to a social VR world-scripting assembly"

    details "Decision", ~S"""
    The world-scripting VM is the only node-graph target.

    **Ship FBD -> VM assembly, direct.** **C# as an intermediate is
    blocklisted**; the platform's C# compiler adds Roslyn as a dep for one
    output format and duplicates verification outside RFD 2159's C++/Rust
    cross-check. Direct mirrors godot-sandbox's SafeGDScript pattern
    (source language -> target ISA, no C++ intermediate). The platform's
    creator loop demos in-world without a compile-and-flash cycle.

    **Dropped (were parked previously):**
    1. A game engine's visual scripting graph; out of scope for taskweft.
    2. Another social VR platform's node graph; out of scope.
    3. glTF Interactivity; out of scope.

    The VM assembly's opcode and directive surface lives at
    `taskweft-fbd-compiler/sigs/world_vm_asm.sigs`, extracted from the
    platform's own MIT-licensed assembler. The FBD emitter walks each
    block and writes the corresponding opcodes into the RFD 2160 USD
    plan's `/Deliveries/WorldVmAsm` string.

    `DETAILS.md` carries the block-to-opcode mapping and the round-trip
    against the `blocks_get_or` fixture.
    """

    details "Problem", ~S"""
    RFD 2150 makes PLCopen FBD the one runtime target. The two platforms
    taskweft ships to are **godot-sandbox** (RFD 2154, C++ + Rust ELFs
    via RFD 2159) and a **social VR platform's world-scripting VM**. The
    VM has its own native assembly language; FBD needs a direct compiler
    into it.
    """

    details "References", ~S"""
    1. `sigs/world_vm_asm.sigs`; the target instruction set
    2. RFD 2150 FBD target, RFD 2160 USD intermediate
    3. The platform's MIT-licensed C#-to-VM compiler, the source of truth
       for the opcode set
    """

    drafted_by :ai
  end
end
