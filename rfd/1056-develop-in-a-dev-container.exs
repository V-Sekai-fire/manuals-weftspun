# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 1056, "Develop in a dev container", :abandoned do
  scope "`.devcontainer/`"
  attest_in :none

  prose ~S"""
  :: decision
  Develop in a dev container. It runs Debian, thus EXLA builds and the
  Linux CockroachDB build runs.

  This box's own Quadlets run Linux, and RFD 1055 selects them first,
  so the container is the same system production uses. Torchx goes:
  EXLA is the only backend this project builds against, and a second
  one only existed to work around the host.

  VSCodium carries no Dev Containers support. The Microsoft extension
  is proprietary, and Open VSX does not carry it. Enter the container
  by CLI instead, through `podman exec` or the `devcontainer` CLI, and
  not through editor integration. The editor still edits the source
  through the bind mount this RFD already sets.
  :: problem
  Two dependencies do not build on Windows, and both are required. XLA
  publishes no Windows archive, so EXLA can never resolve there. The
  V-Sekai CockroachDB release does ship a Windows zip, and the
  database tests need a running node either way.

  Work on Windows therefore either skips those parts or replaces them.
  This branch already did both, and neither workaround is the answer.
  :: related
  RFD 1019 selects EXLA. RFD 1020 selects the CockroachDB build.
  RFD 1036 packages the model images. RFD 1055 selects the local
  worker first.
  """
end
