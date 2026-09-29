# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 1005. `mix rfd.render` renders rfd/1005-avatar-and-vrm-pipeline/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD1005 do
  use RFD.DSL

  rfd 1005, "Avatar and VRM pipeline" do
    state :abandoned

    feature "avatar pipeline"

    attest_in :none

    decision ~S"""
    Support two avatar creation paths.

    - Avatar from image chains mesh generation and a template rig.
    - Avatar from photo uses AvatarSDK, not the AIGC backend.

    The base body VRM stays soulbound. Clothing, hair, and accessories
    act as equippable layers. The client validates the rig against the
    API contract. The viewport loads the rigged GLB. The user can
    download a VRM after the pipeline.

    Export paths include GLB download, VRM build, avatar pipeline VRM,
    and GLB compression with gltf-transform.

    See `DETAILS.md` for file references.
    """

    problem ~S"""
    A user wants an animated avatar from a photo or a trait selection.
    The result must meet the rig contract and export as VRM.
    """

    related ~S"""
    RFD 1004 catalogs the avatar tasks. RFD 1008 defines trait remix.
    The wallet minting link (old RFD 1012) is abandoned. The project
    does not do NFTs.
    """

    drafted_by :ai
  end
end
