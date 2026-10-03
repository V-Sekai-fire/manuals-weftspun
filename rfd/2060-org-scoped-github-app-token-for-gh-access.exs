# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2060, "Org scoped github app token for gh access", :prediscussion do
  prose ~S"""
  :: decision
  See `DETAILS.md` for the full argument.
  :: problem
  Repository operations against
  [`v-sekai-multiplayer-fabric`](https://github.com/v-sekai-multiplayer-fabric)
  (archiving, renaming, pushing, editing settings) run through `gh`
  from a working environment. `gh` was authenticated with a personal
  OAuth token (`gho_`, scopes `gist, read:org, repo, workflow`). The
  `repo` scope is not org-scoped: it grants read/write/**admin/delete**
  on every repository the personal account can reach, across every org
  and every private repo. A mistyped owner in a destructive command, or
  :: related
  - RFD 2146 (Bao is the secret store), where the App key lives.
  - RFD 2260 (credentials shared by path in Bao), the policy model.
  - RFD 2255 (an SSH tunnel to Bao), one way to reach it.
  """

  details_title "Org scoped github app token for gh access"

  madr do
    context ~S"""
    Repository operations against
    [`v-sekai-multiplayer-fabric`](https://github.com/v-sekai-multiplayer-fabric)
    (archiving, renaming, pushing, editing settings) run through `gh` from
    a working environment. `gh` was authenticated with a personal OAuth
    token (`gho_`, scopes `gist, read:org, repo, workflow`). The `repo`
    scope is not org-scoped: it grants read/write/**admin/delete** on
    every repository the personal account can reach, across every org and
    every private repo. A mistyped owner in a destructive command, or a
    leak of that single token, could damage anything the account touches
    anywhere on GitHub, far beyond the one org being worked on. `gh`
    authenticates per host, not per org, so the limit cannot live in `gh`
    config; it has to live in the token.
    """

    drivers ~S"""
    - Confine write/admin reach to the one org, so blast radius stops at
      its boundary.
    - Short-lived credentials, so a leak expires on its own rather than
      living until revoked.
    - Decouple automation from the personal account, so its cross-org
      access never rides along.
    - Least privilege, only the permissions the repo work actually needs.
    - Still usable from the CLI and from CI.
    """

    options ~S"""
    - Keep the broad personal OAuth token (`repo` scope).
    - A fine-grained Personal Access Token with resource owner set to the
      org.
    - A GitHub App installed on the org, minting installation access
      tokens.
    """

    outcome ~S"""
    Chosen option: "a GitHub App installed on the org". Bao mints the
    token. Its image carries the GitHub App secrets engine
    (`vault-plugin-secrets-github`, `service-openbao/Dockerfile.fdb`),
    configured once with the App id and private key. An enrolled agent
    whose policy reaches `github/token` reads

        bao read -field=token github/token org_name=<org>

    and gets an installation access token. The engine signs the RS256 JWT
    and exchanges it, so the private key never leaves Bao. The token goes
    to `gh` as `GH_TOKEN` and to git through a credential helper, with no
    `gh auth login` and nothing written to disk.

    An installation token is org-scoped by construction, expires ~1 hour
    after minting, and acts as the App rather than the personal account,
    covering all three of the top drivers in one mechanism, where a
    fine-grained PAT covers org-scoping but stays long-lived and a
    human-account secret. The cost is a reachable Bao at minting time and
    guarding the App private key, which Bao holds.

    The everyday installation is granted `administration: write`,
    `contents: write`, `workflows: write`, `actions: read`, `metadata:
    read` on all repositories in the org, the set the repo work (push,
    edit workflows, archive/rename) needs.
    """

    consequences ~S"""
    - Good: cross-org private access is impossible, the token cannot read
      or write any private repo outside the org, and cannot act as the
      personal account.
    - Good: a leaked token is dead within ~1 hour, with no manual
      revocation step.
    - Good: the App is its own identity, so audit-log entries and access
      are decoupled from the personal account's lifecycle.
    - Good: a session that loses its `gh` login keeps working, since the
      token comes from Bao and not from a shared login on the desk.
    - Bad: minting needs Bao reachable, over the tailnet or the SSH
      tunnel (RFD 2255).
    - Bad: the App private key is itself high-value (it can mint tokens
      for every install of the App); Bao's policy on `github/token` is
      what guards it.
    - Bad: `administration: write` on all repos means the token can still
      archive / rename / delete / transfer any repo _within_ the org, the
      in-org fat-finger case is not mitigated by scoping alone.
    """

    confirmation ~S"""
    A minted token was probed against the live API. `GET
    /installation/repositories` reports 49 repos, `repository_selection:
    all`. Org repos are reachable; `GET /user` returns `403 Resource not
    accessible by integration` (the token is not the personal account);
    private repos in other orgs are unreachable. Public repos elsewhere
    stay readable, which is public-is-public and not a private exposure.
    The minted token's permissions read back as
    `administration/contents/workflows: write, actions/metadata: read`.

    Minted through Bao on 2026-09-28 for `V-Sekai-fire`: the token is a
    `ghs_` installation token, `git ls-remote` and `gh api` both work with
    it, and `GET /installation/repositories` reports 796 repositories.
    """

    more_information ~S"""
    In-org blast radius, every repo, with `administration: write`, is
    narrowed further by installing on selected repositories instead of
    all, and by splitting off a separate, rarely-used admin App so the
    everyday token drops `administration: write`. The accidental
    destructive command _within_ the org is caught only by an
    out-of-band confirmation step, not by token scoping. This pairs with
    the move to podman quadlets on Fedora 44
    (`rfd/203d-quadlets-on-fedora-44-instead-of-harvester`), where `gh`
    drives the same org's repos that carry the quadlet sources.
    """
  end
end
