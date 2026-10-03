# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2023, "Webtransport http3 transport", :prediscussion do
  prose ~S"""
  :: decision
  See `DETAILS.md` for the full argument.
  :: problem
  The stack needs a client/server transport that carries reliable
  control messages and high-rate unreliable state over one connection,
  on both native and web clients. Which transport does the engine
  provide?
  :: related
  See `DETAILS.md` for the full argument.
  """

  details_title "Webtransport http3 transport"

  madr do
    context ~S"""
    The stack needs a client/server transport that carries reliable
    control messages and high-rate unreliable state over one connection,
    on both native and web clients. Which transport does the engine
    provide?
    """

    drivers ~S"""
    - Unreliable datagrams for high-rate state, plus reliable streams for
      control.
    - One connection for both, with native and browser support.
    """

    options ~S"""
    - Standard `MultiplayerPeer` transports (ENet, WebSocket, WebRTC).
    - WebTransport over HTTP/3 / QUIC.
    """

    outcome ~S"""
    Chosen option: WebTransport over HTTP/3, provided by the engine's
    `modules/http3` (on `feat/module-http3`):

    - `quic_picoquic_backend.{cpp,h}`, native QUIC via picoquic.
    - `quic_web_backend.cpp` + `quic_web_glue.js`, the web/wasm backend.
    - `http3_client.{cpp,h}`, `quic_client.{cpp,h}`, `quic_server.h`.
    - Classes `HTTP3Client`, `QUICClient`, `QUICServer`, `WebTransportPeer`.
    - Demos: `modules/http3/demo/wt_client_test.gd`, `wt_server_demo.gd`,
      `wt_browser_test.html`.
    - `lean/http3/PollingTermination.lean` proves the poll loop
      terminates.

    One QUIC connection carries reliable streams and unreliable datagrams,
    so control messages and high-rate state share a connection.
    """

    consequences ~S"""
    - Good: datagrams suit high-rate state; one connection serves native
      and browser.
    - Bad: the fork carries a picoquic backend and a QUIC stack to
      maintain.
    """

    confirmation ~S"""
    The `modules/http3` demos open a WebTransport client and server over
    QUIC.
    """

    more_information ~S"""
    Pose streaming for the presence demo rides this transport; see
    presence demo pose networking. The engine is pinned to a frozen Godot
    4.7 commit.
    """
  end
end
