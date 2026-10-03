# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 1031, "Geometry refinement and alpha wrap", :abandoned do
  feature "mesh geometry"
  attest_in :none

  prose ~S"""
  :: decision
  Do not make CGAL a required dependency. Keep it optional, or drop the
  alpha wrap step from the build. The fork still produces GLBs without
  CGAL.
  :: problem
  trellis2cpp (rms80/trellis2cpp) is an MIT C++/ggml port of the
  TRELLIS.2 stage-1 geometry pipeline. The richiejp pbr-textures fork
  adds geometry refinement and PBR textures under the same license. It
  runs on GPU backends through ggml, and it exports textured GLB
  without CUDA.

  The fork adds CGAL as an optional build dependency. CGAL uses the GPL
  license, and RFD 1028 excludes GPL on license grounds.
  :: related
  RFD 1028 records the license gate. The alpha wrap step stays
  optional, or absent, until a real need justifies a rebuild.
  """
end
