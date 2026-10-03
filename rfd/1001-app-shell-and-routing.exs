# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 1001, "App shell and routing", :abandoned do
  feature "app shell"
  attest_in :none

  prose ~S"""
  :: decision
  Use React Router with three routes.

  - `/` is the main app.
  - `/studio` is the Studio pipeline page.
  - `/xr` is the IWSDK lab.

  The main app mounts SceneManager, TaskManager, and the avatar
  panels. The Studio page and the XR lab load lazily.

  The shell inits the native face bridge and the remote log client.
  Init errors do not block the viewport.
  :: problem
  The app ships one viewport and many tools. Tools need separate
  routes. The shell must keep one scene session.
  :: references
  - Routes: `src/main.jsx`
  - Main app: `src/App.jsx`
  - Studio page: `src/pages/StudioPage.jsx`
  - XR lab: `src/pages/IwsdkImmersive.jsx`
  :: related
  RFD 1002 defines the Studio pipeline. RFD 1010 defines the XR lab.
  """
end
