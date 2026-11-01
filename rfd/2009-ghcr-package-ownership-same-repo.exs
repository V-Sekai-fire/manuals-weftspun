# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2009, "Ghcr package ownership same repo", :prediscussion do
  prose ~S"""
  :: hook
  Why a zone deploy could not pull an image from another repo's package.
  :: intrigue
  The zone deploy workflow tried to pull the zone server image and received 403 Forbidden.
  :: exit
  Check that a package and the workflow that pulls it share one repository before you rely on the
  pull. The sections below list the consequences.
  :: decision
  See `DETAILS.md` for the full argument.
  :: related
  See `DETAILS.md` for the full argument.
  """

  details_title "Ghcr package ownership same repo"

  prose ~S"""
  :: details Context
  The zone server binary was built by `multiplayer-fabric-baker` and
  pushed to `ghcr.io/v-sekai-fire/godot-zone-double`. The zone deploy
  workflow (in `multiplayer-fabric-zone`) used `--local-only` with
  `docker/login-action` to pull that image, but received 403 Forbidden.

  GitHub Container Registry ties package write access to the repository
  whose `GITHUB_TOKEN` created it. The zone repo's token could not push to
  a package owned by the baker repo, and could not pull a private package
  owned by another repo without package-scoped access.
  :: details Consequences
  - Package names must reflect the owning repo to avoid confusion.
  - Moving a package between repos requires deleting it (needs
    `delete:packages` API scope) and rebuilding, or renaming.
  - Cross-repo GHCR access requires either a PAT with `read:packages`
    scope or making the package public.
  :: details The problem
  The zone server binary was built by `multiplayer-fabric-baker` and
  pushed to `ghcr.io/v-sekai-fire/godot-zone-double`. The zone deploy
  workflow (in `multiplayer-fabric-zone`) used `--local-only` with
  `docker/login-action` to pull that image, but received 403 Forbidden.
  """
end
