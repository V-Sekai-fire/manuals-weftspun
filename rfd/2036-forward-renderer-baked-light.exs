# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2036, "Forward renderer baked light", :prediscussion do
  prose ~S"""
  :: decision
  See `DETAILS.md` for the full argument.
  :: problem
  The mobile tile renderer rations bandwidth across file, memory, and
  network IO, and deferred rendering competes for it. The slice needs
  predictable frame cost regardless of light count.
  :: related
  See `DETAILS.md` for the full argument.
  """

  details_title "Forward renderer baked light"

  madr do
    context ~S"""
    The mobile tile renderer rations bandwidth across file, memory, and
    network IO, and deferred rendering competes for it. The slice needs
    predictable frame cost regardless of light count.
    """

    options ~S"""
    - Deferred rendering.
    - A simple forward renderer with baked global illumination.
    """

    outcome ~S"""
    Chosen option: a simple forward renderer with baked global
    illumination and light probes for static geometry, a dedicated shadow
    pass for avatars, and probe lighting for dynamic entities, because the
    frame cost stays predictable regardless of light count. Deferred
    rendering pressures the bandwidth the mobile tile renderer rations.
    """

    consequences ~S"""
    - Frame cost stays predictable, so artists place many lights without
      watching the budget.
    - Dynamic entities take lower-fidelity probe lighting.
    - The renderer removes one axis the small team otherwise tunes by
      hand.
    """

    confirmation ~S"""
    The Field room holds the frame floor on the standalone VR build with
    many lights placed.
    """
  end
end
