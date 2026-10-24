# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2330, "Elixir on a guest through a small BEAM", :discussion do
  feature "an Elixir program runs inside a godot-sandbox guest ELF, sliced per frame"
  scope "a new guest repository, the sysroot toolchain, the host-call table of RFD66606-2288"

  prose ~S"""
  :: decision
  An Elixir program reaches a guest as BEAM bytecode run by a small BEAM
  written in C (the tiny Erlang VM built for microcontrollers, Apache-2.0),
  cross-compiled with the sysroot toolchain as one static riscv64 ELF that
  embeds the bytecode pack. No full OTP runtime goes into a guest. Rung 0
  is the interpreter alone: SMP, task driver, JIT and TLS off. Rung 1 adds
  the host bridge: one vmcall runs the VM's scheduler for a slice under
  RFD66606-2302's budget, and the program reaches the engine through NIFs over
  the sandbox API, each a capability of RFD66606-2288. Rung 2, gated, loads the
  VM's ahead-of-time riscv64 native chunk and is kept only if the measured
  instruction count per solve falls. New guest code is Lean 4 or a BEAM
  program on this route (operator, 2026-10-20); C++ stays legacy only.
  The first program to take the route is not yet named.
  :: problem
  Elixir owns the coordinators, the gate runners and the release tools, and
  every guest today is C++ or Lean 4. When a coordinator's logic has to run
  inside the sandbox, the choice is a rewrite in Lean or a BEAM in the
  guest. Which BEAM, what it needs from the sandbox and what it cannot do
  had not been studied. The LLVM compiler for BEAM languages is archived,
  and the full OTP runtime needs fork, exec and dlopen, which a guest lacks.
  :: related
  - RFD66606-2154 (Elixir embeds the engine from the host), RFD66606-2288 (host calls as
    capabilities), RFD66606-2302 (frame slices), RFD66606-2293 and RFD66606-2294 (compute).
  - RFD66606-1054: the same small VM in a browser, and why that could not ship.
  """

  details_title "Elixir on a guest through a small BEAM"

  prose ~S"""
  :: details Sources
  Read on 2026-10-20: the small VM's build instructions, release notes,
  changelog, JIT guide, top-level and generic UNIX build files, its
  generic UNIX platform layer (`sys.c`, `smp.c`, `main.c`) and `avmpack.h`;
  the archived AOT compiler's README; the browser port's README; libriscv's
  Linux system-call files (`system_calls.cpp`, `syscalls_mman.cpp`,
  `syscalls_poll.cpp`, `syscalls_epoll.cpp`). The guest facts come from
  &{repo("contract-guest-runtime")}, &{repo("repository-riscv64-sysroot")}
  and the Lean guest driver. Nothing was built or run for this RFD.

  :: details What a guest is today
  A guest is a static riscv64 Linux ELF, glibc, linked with clang and lld
  from &{repo("repository-riscv64-sysroot")}, built through the cmake
  include of &{repo("contract-guest-runtime")}. Its entry must sit inside
  an executable load segment, `main` never returns but calls `fast_exit`
  so the VM keeps its state, and the host reaches it by `vmcall` with at
  most seven arguments. Everything is binary-translated (RFD66606-2293). A guest
  has no fork, no exec, no sockets, no DNS, no epoll and no pipes; async
  timers are unusable; `IO.appPath` fails in Lean. Memory is a power-of-two
  arena the host sets. The Lean guests (built by the Lean guest driver)
  and the C++ guests (MuJoCo, curvenet, the ggml-rd guests) all fit this.

  :: details The routes considered
  - The full OTP runtime, cross-compiled static for riscv64. Rejected: its
    runtime starts a child-setup process with fork and exec, loads NIFs and
    port drivers with dlopen, and polls with epoll. A guest has none of
    those, and the runtime is tens of megabytes before any program.
  - An ahead-of-time compiler from Erlang and Elixir to native code through
    LLVM. Rejected: the project is archived, its toolchain packaging never
    landed, and it had no riscv64 target.
  - The small VM's WebAssembly port, which runs Elixir in a browser.
    Rejected for a guest: it is web only and needs cross-origin isolation,
    which RFD66606-1054 measured as the reason its editor panel could not ship.
    It stays the reference for a web demo, not for a riscv64 guest.
  - Keep Elixir on the host and embed the engine from the BEAM through a
    NIF (RFD66606-2154). This is the route when the program is a coordinator
    that drives the engine, and it stays the default for coordinators.
  - A rewrite in Lean 4. The other permitted language for new guest code,
    and the route when the program is compute.
  - The small VM, generic UNIX platform, static riscv64. Chosen as the
    route for an Elixir program that must run inside the sandbox.

  :: details The small VM, what it is and what it needs
  It is a BEAM written from scratch in C11 that runs unmodified `.beam`
  files compiled by OTP 21 through 28 (Elixir 1.7 through 1.17 are the
  tested pairs). Its core libraries are Erlang and Elixir, packed with the
  program into one `.avm` file by a mix task. Its stated limits: a minimal
  standard library, no `on_load`, no tracing, and features that need an
  operating system (files, OS processes) missing or different. Its last
  stable release is v0.6.6; the riscv64 native chunk is on its main
  branch only, as 0.7.0-dev.

  The build needs cmake, gperf, a C compiler, `erlc`, `elixirc` and
  rebar3; mbedtls is optional for TLS and zlib is listed as required by the
  README. Configure options that matter here: `AVM_DISABLE_SMP`,
  `AVM_DISABLE_TASK_DRIVER`, `AVM_DISABLE_JIT` (the default),
  `AVM_ENABLE_PRECOMPILED`, `AVM_PRECOMPILED_TARGETS` (which lists riscv64
  and riscv32) and `AVM_BUILD_RUNTIME_ONLY`.

  What the generic UNIX layer asks of the kernel, read from its source:
  - With SMP or the task driver on, a signalling descriptor from eventfd or
    a pipe, and pthreads for schedulers, mutexes and condition variables.
    With both off, none of these.
  - `poll` over its listener descriptors, which with no sockets and no
    signalling descriptor is a `poll` on zero descriptors with a timeout,
    the VM's sleep.
  - `mmap` of a file to read an `.avm` from disk. Not needed: `main.c`
    already reads a pack embedded in the executable, and the pack type for
    constant memory exists.
  - With the JIT or precompiled code on, anonymous `mmap` followed by
    `mprotect` to executable, so native code lives in heap pages.
  libriscv implements `ppoll`, anonymous `mmap`, `munmap`, `mremap` and
  `mprotect` (which sets the page's exec attribute), plus eventfd, epoll
  and pipe handlers, in its Linux layer. The godot-sandbox host installs
  its own subset; which of these it carries is not known (below).

  :: details Rung 0: hello under the emulator
  Build the VM runtime only, SMP, task driver, JIT and mbedtls off, with
  the sysroot `toolchain.cmake`, static, gc-sections, stripped. Pack a
  one-module Elixir program with the mix task and embed the pack the way
  `main.c` already reads an embedded pack. Check the ELF entry sits in an
  executable load segment, run it under rvlinux with `-I`, and judge by
  the printed `Program exited, exit code = 0` and the program's own line,
  never by the emulator's exit code.

  :: details Rung 1: the host bridge
  Replace the UNIX `main` with the guest entry. At start the guest makes
  the global context, loads the embedded pack, starts the program's
  module and calls `fast_exit`. It registers two host-callable functions:
  one that runs the scheduler for a slice and returns whether work
  remains, and one that delivers bytes to a named process. The program
  reaches the engine through NIFs, each one C function over the sandbox
  API and each a capability of RFD66606-2288 checked once at the host call.
  RFD66606-2302's slice holds without help from the VM: the host suspends the
  guest by instruction limit and resumes it next frame, and the VM's own
  scheduler loop is the safe point for the yield request. The mesh wire
  rules of RFD66606-2294 (the common mesh header, at most seven arguments)
  apply to any NIF that moves geometry.

  :: details Rung 2, gated: the native riscv64 chunk
  The VM's main branch compiles BEAM to native code at build time and
  stores it in each `.beam` as an extra chunk; at load the VM runs that
  chunk and skips the interpreter. The target list names riscv64, so a
  pack built with it carries native riscv64 code for every module. This
  rung turns `AVM_ENABLE_PRECOMPILED` on and keeps the JIT off. It is kept
  only if the instruction count per solve falls against rung 1 on the same
  program. It needs the host to execute pages the guest made executable
  with `mprotect`, which binary translation may not cover: that is the
  first thing the rung measures.

  :: details Gates and controls
  - G0, the ELF boots: the entry lies inside an executable `PT_LOAD`.
    Control: the same link without `-static -no-pie` yields entry zero
    and fails by name.
  - G1, hello: rung 0 prints its line under rvlinux and the emulator
    reports exit code 0 with no exception. Control: the pack with its
    start module removed fails with the VM's own "no start module" error.
  - G2, round trip: the host's vmcall delivers bytes to the program and
    the program's NIF reply reaches the host unchanged. Control: a NIF
    called without its capability is refused, as RFD66606-2288 requires.
  - G3, the slice: no vmcall exceeds 6.94 ms at the host. Control: a
    module that spins forever trips the instruction limit and the next
    frame resumes it where it stopped.
  - G4, the native chunk: rung 2's instruction count per solve is below
    rung 1's on the same program and inputs. Control: the rung 1 build
    reports no native chunk in use for the same pack.
  Each gate is reported as passing only after it ran and was seen to
  pass; a precondition unmet is a FAIL, not a skip.

  :: details Where the code lands
  A new interactor repository, interactor-beam-guest, holding the VM as
  a vendored tree at a pinned commit with its licence file beside it, the
  cmake include of &{repo("contract-guest-runtime")}, the guest entry and
  NIF sources, and a mix project for the program. It is placed in the goal
  manifest the day it is created (the Sides rule). Its CI builds the ELF
  with the sysroot repository cloned beside it and runs G0 and G1 under
  rvlinux. The Elixir program's own tests run on the host BEAM with mix,
  as every other Elixir project here does.

  :: details What is not known
  - Which Elixir program is first. Naming it also settles whether it is
    compute or coordination; a coordinator that only drives the engine
    still has the host route of RFD66606-2154.
  - Whether the godot-sandbox host carries `ppoll` (or `poll`) and
    anonymous `mmap` with `mremap`. rvlinux does; the host installs its
    own table. First step: run rung 0 inside the pinned engine, not only
    under rvlinux, and read the host's refusal by name if it refuses.
  - Whether binary translation executes heap pages made executable by
    `mprotect`, or whether such pages fall back to the interpreter inside
    the VM. Rung 2's G4 is the measurement; until then rung 1 is the
    design.
  - Whether zlib is a hard link dependency of the runtime-only build. If
    it is, it comes from the sysroot like every other guest library.
  - How much of Elixir 1.17's standard library the program needs beyond
    what the VM ships, and which of the VM's own patched OTP modules (the
    browser port carries a patch set) a guest needs. First step: compile
    the program's module list against the VM's library pack and list what
    is missing.
  - Memory: the VM's default heaps are sized for microcontrollers, and a
    guest arena is a power of two the host sets. The first run reports
    both.
  - The web slide: the web sandbox build is interpreter only, so a BEAM
    interpreter in it is an interpreter inside an interpreter. Measure or
    exclude the web target per program; do not assume it.
  - Speed is unmeasured. Nothing in this RFD claims a rate.
  """
end
