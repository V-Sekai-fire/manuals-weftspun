# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
#
# RFD 2267. `mix rfd.render` renders rfd/2267-persona-npcs-in-ported-scenes/README.md and
# DETAILS.md from this file; the Markdown is a build artifact (RFD 2232).
defmodule RFD2267 do
  use RFD.DSL

  rfd 2267, "Persona NPCs in ported scenes" do
    state :discussion

    feature "a person walks a ready-made scene in the shared world and meets
NPCs that hold a persona and a script"

    scope "the shared world's client, as an experiment behind the RFD 2262
vehicles rather than one of them"

    decision ~S"""
    Record the signal and gate it, do not schedule it. A capable model now
    authors a whole playable scene in an afternoon, so a licence-clean scene
    ported in with persona-driven NPC scripts is a cheap way to populate the
    world with both things the RFD 2262 survey asked for, something to see and
    someone to be with. It sits behind the vehicles, kept here so it is not
    lost. Any ported scene clears the licence gate first, and target platforms
    are named by role, not by brand. Detail and parked status in DETAILS.md.
    """

    problem ~S"""
    The RFD 2262 survey asked to create and share what others see and to be with
    people, and it asked for neither rendered clips nor faces. Scripted personas
    and ready-made scenes answer both asks cheaply, now that a scene is
    something a model can author rather than a studio. The open question is
    whether ported content and scripted NPCs add to the loop the vehicles
    already test or divert from it, and nothing here answers that yet.
    """

    related ~S"""
    - RFD 2262 (make it with the pen and wear it together) holds the vehicles
      and the survey this reads against.
    - RFD 2229 (interchangeable parts) is the rule an imported scene answers to.
    """

    drafted_by :ai

    details_title "Persona NPCs in ported scenes"

    details "The licence gate", ~S"""
    A scene from outside is a source under default deny. It is usable only when
    it carries a readable licence permitting commercial use and derivatives,
    with a CITATION.cff beside it naming the licence and the source record, the
    same bar an image or a pose set meets. A scene behind a registration form,
    or one that states no licence, is not portable whatever it contains.

    The candidate that prompted this reads clean. `Kenton-GMI/sakuragaoka-station`
    is a walkable first-person anime cel-shaded station town generated
    procedurally in three.js, and it carries an MIT licence, so it clears the
    gate. It is procedural web code rather than an asset dump, so a port to the
    Godot-based world reimplements its generation rather than importing its
    meshes. An AI-authored scene carries the provenance of its generation the
    same way generated training data does.
    """

    details "Parked", ~S"""
    Shelved 2026-09-26. This is community signal, not a vehicle, and it is
    recorded so a later session does not rediscover it from scratch. Unpark it
    when a vehicle in motion needs a populated scene or a scripted NPC, and only
    with a licence-clean source. Until then it stays off the board.
    """
  end
end
