# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2285. `mix rfd.render` renders this file's README.md and DETAILS.md under
# rfd/2285-unship-the-web-demo-and-xr-paths/; the Markdown is a build artifact
# (RFD 2232).
defmodule RFD2285 do
  use RFD.DSL

  rfd 2285, "Unship the web demo and the XR paths" do
    state :published

    feature "documentation retraction"

    scope "RFDs 1010, 1013, 1095, 1103"

    decision ~S"""
    Abandon four RFDs whose subject has no code in the placed workspace:
    the public web demo on a hosted static front end (1013), its asset
    loading from a CDN (1103), the browser WebXR and IWSDK lab (1010), and
    the voice XR path through a vendor XR stack on a remote GPU host
    (1095). Each moves to `abandoned` alongside this document landing.
    """

    problem ~S"""
    The allowlist is default deny: a runtime or service is usable only if
    it is named there or placed by the live manifest. None of the four
    subjects is either, and a search of every placed project outside the
    RFDs finds no deploy configuration, no public-demo build flag, no
    IWSDK use and no vendor XR stack. The runtime is the native Godot 4
    binary, and the manifest already dropped the web platform's tooling.
    Each of the four states its path as current with no code behind it.
    """

    related ~S"""
    - Retracts: urn:oid:1.3.6.1.4.1.66606.1.1.{1010,1013,1095,1103}
    - RFD 2175 (abandon RFDs whose decision uses blocklisted rented
      compute), the same class of walk-back.
    - RFD 1075 (GitHub OAuth login), abandoned when its service was archived.
    """

    drafted_by :ai
  end
end
