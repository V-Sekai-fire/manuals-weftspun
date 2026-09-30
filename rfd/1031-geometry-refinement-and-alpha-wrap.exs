# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 1031. `mix rfd.render` renders rfd/1031-geometry-refinement-and-alpha-wrap/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD1031 do
  use RFD.DSL

  rfd 1031, "Geometry refinement and alpha wrap" do
    state :abandoned

    feature "mesh geometry"

    attest_in :none

    decision ~S"""
    Do not make CGAL a required dependency. Keep it optional, or drop the
    alpha wrap step from the build. The fork still produces GLBs without
    CGAL.
    """

    problem ~S"""
    trellis2cpp (rms80/trellis2cpp) is an MIT C++/ggml port of the
    TRELLIS.2 stage-1 geometry pipeline. The richiejp pbr-textures fork
    adds geometry refinement and PBR textures under the same license. It
    runs on GPU backends through ggml, and it exports textured GLB
    without CUDA.

    The fork adds CGAL as an optional build dependency. CGAL uses the GPL
    license, and RFD 1028 excludes GPL on license grounds.
    """

    related ~S"""
    RFD 1028 records the license gate. The alpha wrap step stays
    optional, or absent, until a real need justifies a rebuild.
    """

    drafted_by :ai
  end
end
