# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2278. `mix rfd.render` renders this file's README.md and DETAILS.md under
# rfd/2278-voxel-remeshing-for-cages-and-solids/; the Markdown is a build
# artifact (RFD 2232).
defmodule RFD2278 do
  use RFD.DSL

  rfd 2278, "voxel remeshing for cages and solids" do
    state :ideation

    flight_level :l1

    feature "meshoptimizer 1.3's experimental voxel remesher, inside the
`cage.elf` guest, makes the closed cage a cage fit needs and the closed body
solid an inside test needs"

    scope "meshoptimizer 1.3 `meshopt_remesh` with `meshopt_RemeshShell` and
`meshopt_RemeshSolve`, vendored into dress-on's guest build; RFD 2277's cage
source and body solid"

    decision ~S"""
    Parked. The idea: build RFD 2277's cage and body solid inside the guest.
    `meshopt_remesh` produces a closed mesh with every edge matched, which
    is the property a biharmonic cage and a winding-number inside test both
    need. The cage comes from a low-resolution shell remesh of the region,
    then `meshopt_simplifyWithUpdate` with the fold-preserving and sparse
    options. The body solid comes from a solid remesh at a resolution whose
    voxel is below the margin. It would replace a hand-authored cage and the
    `mesh_cap` + `mesh_union` chain. Unparking waits on RFD 2277's phase A
    gates, and on the API leaving experimental status.
    """

    problem ~S"""
    RFD 2277 needs a closed cage per garment region, authored by hand
    today, and a closed body. Miroir-Re's body has 220 boundary edges, and
    closing it takes a Python cap step, which RFD 2277 rules out.
    """

    references ["zeux/meshoptimizer v1.3, src/remesher.cpp"]

    related "RFD 2277 (curvenet-cage refit and unified expressions), the consumer."

    drafted_by :ai

    details_title "voxel remeshing for cages and solids"

    details "What the remesher is", ~S"""
    - **Source:** meshoptimizer v1.3 (`MESHOPTIMIZER_VERSION 1030`),
      `src/remesher.cpp` (782 lines, first commit 2026-07-16), MIT, by
      Arseny Kapoulkine.
    - **Call:** `meshopt_remesh(dst, max_tris, indices, index_count,
      positions, vertex_count, stride, resolution, options)`, where
      `resolution` is in [4, 256].
      - It returns an unindexed triangle soup.
      - With a null or undersized `dst`, it returns an upper bound, so it is
        called twice.
    - **Algorithm:** a corner-connecting marching cubes, with octant and
      quadric deciders.
      - `RemeshSolve` places each vertex at the quadric-optimal point, so the
        output tracks the surface.
      - `RemeshShell` wraps surfaces in a two-sided shell instead of filling
        a solid.
      - Features closer than a voxel merge, and gaps smaller than a voxel
        close.
      - Thin sheets survive (unlike SDF methods); strands may vanish.
    - The API is marked `MESHOPTIMIZER_EXPERIMENTAL`.
    - The local copies (Godot entities at 1.0 to 1.2) do not have it.
    """

    details "Where it would sit", ~S"""
    - **Build:** compiled into the guest with the riscv64 sysroot, next to
      L-BFGS-B.
    - **Language:** it is plain C++, not a Lean kernel, so rule 2 needs a
      ruling for vendored C++, the same one fit.elf's PolyFEM needed.
    - **Resolution:** at avatar scale (about 1.6 m), resolution 256 gives
      6.3 mm voxels. That is coarser than the 2 mm margin, so the body
      solid would be remeshed per region box (a 0.3 m neck box gives about
      1.2 mm voxels).
    - **Cage:** resolution 16 to 32 over the garment region, shell, then
      simplify to about 100 vertices.
    - **Gates to write when unparked:**
      - the cage is closed and manifold, with positive signed volume;
      - every garment vertex is strictly inside the cage;
      - the body solid has genus 0 and 0 boundary edges;
      - its volume is within tolerance of the capped solid's 0.120876 m³;
      - a negative control: an open input with remesh disabled must fail
        the closed check.
    """
  end
end
