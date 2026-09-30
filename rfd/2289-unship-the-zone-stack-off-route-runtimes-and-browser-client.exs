# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2289. `mix rfd.render` renders this file's README.md and DETAILS.md under
# rfd/2289-unship-the-zone-stack-off-route-runtimes-and-browser-client/; the
# Markdown is a build artifact (RFD 2232).
defmodule RFD2289 do
  use RFD.DSL

  rfd 2289, "Unship the zone stack, the off-route runtimes and the browser client" do
    state :published

    feature "documentation retraction"

    scope "the 42 RFDs this document retracts"

    decision ~S"""
    Abandon 42 RFDs off RFD 2287's critical path that no placed code
    implements. Each moves to `abandoned` with this document. Its details
    go, and its full text stays in git at `a6eb679`.

    - The zone stack: zone-server-h2o, the MUD shell, the slot-map and FDB
      benchmark, and godot-loop-slice. RFD 2287 puts zones in `zone.elf`
      guests, and RFD 2288 carries 2092's guest gate.
    - Runtimes off the godot-sandbox, ggml-rd and compute-rd route.
      Diffusion reaches the GPU through that route, because it is
      EditScore's basis and EditScore becomes a decision model (RFD 2268).
    - The browser studio client, its dev setup and its asset edge.
    """

    problem ~S"""
    RFD 2287 is the active rung. No project on this desk cites these 42 in
    code or commits, and a search of the placed tree finds no implementation,
    or one on a runtime the workspace does not use.
    """

    related ~S"""
    - Retracts: urn:oid:1.3.6.1.4.1.66606.1.1.{1006,1008,1022,1023,1031,1042,1043,1056,1061,1077}
    - Retracts: urn:oid:1.3.6.1.4.1.66606.1.1.{1148,1169,1172}
    - Retracts: urn:oid:1.3.6.1.4.1.66606.1.2.{2002,2004,2005,2010,2014,2066,2070,2072,2073,2074}
    - Retracts: urn:oid:1.3.6.1.4.1.66606.1.2.{2076,2077,2078,2079,2080,2081,2082,2083,2084,2085}
    - Retracts: urn:oid:1.3.6.1.4.1.66606.1.2.{2086,2091,2092,2108,2110,2116,2120,2163,2214}
    - RFD 2285, the same walk-back; RFD 2242, the retracted native ggml modules.
    """

    drafted_by :ai

    details_title "Unship the zone stack, the off-route runtimes and the browser client"

    details "The groups", ~S"""
    - Zone stack: 2002, 2004, 2005, 2010, 2014, 2066, 2070, 2072, 2073,
      2074, 2076 to 2086, 2091, 2092, 2108, 2110, 2116, 2120. The manifest
      places none of zone-server-h2o, the MUD shell or godot-loop-slice.
    - Off-route runtimes: 1031 (a standalone trellis2cpp binary), 1042 and
      1043 (standalone model images), 1148 (LiteRT), 1169 and 2163
      (llama-mtmd-cli), 1172 (an NPU or a desk GPU outside the sandbox),
      2214 (a GDExtension `Ggml.load_model()`).
    - Browser studio client: 1006, 1008, 1022, 1023, 1056, 1061, 1077. The
      JavaScript client the first four and 1061 extend is not placed.
    """

    details "How the 42 were chosen", ~S"""
    Of 249 open RFDs, 226 sit outside RFD 2287, its eight citations and
    their fifteen, and the curvenet RFDs 2265, 2266, 2269 and 2274. Code
    files and commit messages across every checked-out project except this
    one cite 52 of the 226 by number, and those stay open.

    Each of the other 174 had its named artifacts searched for in the
    placed tree: 62 found nothing, 9 found a runtime off the route, 38 found
    code, 32 found stubs, 26 are process rules, and 7 live in a checkout
    absent from this desk. The operator kept 2213, 2244 and 2268 as
    dress-on's planned work and picked the three groups above from the
    rest. The negative controls are RFDs 1010, 1013, 1095 and 1103,
    abandoned by RFD 2285 for having no code: each scores zero cites.

    The 26 manifest paths absent from this desk, most of them engine
    branches, are unchecked.
    """
  end
end
