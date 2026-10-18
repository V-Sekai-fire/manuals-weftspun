# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2321, "the autobattler fields Frames that wear", :committed do
  feature "each fighter in the SolidCraft autobattler is a Frame put together from guest
solids, rolled on survey tables, and it carries wear from round to round"
  scope "the SolidCraft autobattler game Space: its game script and its page"

  prose ~S"""
  :: decision
  Each squad in the SolidCraft autobattler fields five Frames. A Frame's body is
  put together from solids the guest kernel builds, and its species, presentation
  and age come from three d100 rolls on the population survey tables of our
  appendix-E dataset. A Frame that survives a round stays with wear and leaves
  after five rounds, and each side earns scrip per round, as in the Gyre setting.
  The operator asked for more Frames, game feel, the Gyre flavour and readability
  on 2026-10-17.

  Each Frame also has one of three roles, melee, range or cyber, that beat each
  other as in rock, paper, scissors. The operator requested the roles on
  2026-10-18.
  :: problem
  Each unit was one solid: a box, a cylinder, a sphere or a torus. Units had no
  identity, every round started from zero, and nothing on screen said which unit
  was hurt or why a round ended.
  :: related
  - RFD 2294, where the desktop builds ship: the release that carries this game.
  - RFDs 2085, 2091 and 2120, the Gyre setting (abandoned): the source of Frames,
    wear and scrip.
  """

  details_title "the autobattler fields Frames that wear"

  prose ~S"""
  :: details Sources
  Drafted on 2026-10-17 from the game script as shipped, its self-test logs on
  each system and the operator's requests of the same day.

  :: details What a Frame is
  The guest builds 18 solids while the game loads: 12 whole solids and six parts
  (a head, a limb, a torso, a ring, a cube and a base). A Frame places parts by
  species and merges them into one mesh, so a Frame is one draw call; the parts
  become separate pieces only when it breaks. The bounds of the parts set health,
  damage, speed and reach, as the single solid did before.

  - Species: humanoid 1-50, semi-humanoid 51-88, synthetic 89-94, uplifted
    animal 95-96, plant 97-98, exotic 99-100.
  - Presentation: feminine 1-71, masculine 72-89, other 90-100.
  - Age: youth 1-58, juvenile 59-75, adult 76-87, no age 88-99, infant 100.

  The bands are the raw survey distribution, tables E.8 to E.10. Age scales the
  body and the head. Each species but humanoid adds one trait: semi-humanoid is
  fast, uplifted animal is very fast with less health, synthetic is plated and
  slower, plant regrows and is slow, and exotic is one bare whole solid that hits
  hard.

  :: details Wear and scrip
  A Frame that survives a round gains one point of wear, and its maximum health
  drops by a tenth of its base for each point. At five points it leaves. New
  drafts fill the empty places. Each side earns two scrip per round plus one per
  Frame left, and the winner three more.

  :: details Feel and readability
  A hit flashes the Frame and plays a short generated sound. A Frame that breaks
  throws its parts and shakes the camera. Each Frame has a health bar and a name
  tag, a little of its side's colour shows even in shade, and the end of a round
  shows the Frames left and the scrip earned.

  :: details Roles
  Melee beats range, range beats cyber and cyber beats melee. A hit on the role
  the attacker beats does 1.6 times its damage, a hit on the role that beats it
  does 0.6 times, and a hit on the same role does its normal damage. Reach puts
  the roles in order: melee hits at the reach of its body, cyber at 3.8 m and
  range at 7 m, so a range Frame shoots a cyber Frame before the cyber Frame can
  answer, and a melee Frame has to close the gap to a range Frame.

  - Melee: 1.25 times the health, 1.15 times the speed, an attack every 0.8 s,
    and a shield in front. Its hits push the target back.
  - Range: 0.75 times the health, 0.8 times the damage, 0.9 times the speed, an
    attack every 1.1 s, and a barrel at the shoulder. Each shot is a small
    sphere that flies to the target.
  - Cyber: 0.95 times the health, 0.7 times the damage, an attack every 1.0 s,
    and a dish on top. Each hit adds 0.7 s to the target's next attack and shows
    a ring that spreads over the target.

  The role's parts come from the same catalog of guest solids and merge into the
  Frame's one mesh, but they do not count toward its health, damage or reach.
  Each squad's draft holds every role at least once, so every round shows the
  triangle; the other two places draw a role at random from the round's seed.
  The name tag shows the role before the species.

  :: details What was measured
  The change is in the game script only, so the guest and every translation hash
  stayed valid. On 2026-10-17 the web build and the macOS, Windows and Linux zips
  each started translated, built 18 solids and printed `RESULT PASS`. The script
  cost per physics frame rose from about 0.23 ms to about 0.3 ms on the Mac. The
  web game's slowest frame in the first round read 139 to 145 ms before and
  after. Native frame times on the Mac were not compared: other jobs on the same
  machine made them vary more than the change.

  On 2026-10-18 the roles changed the game script only, again. The self-test
  first checks the triangle: every role beats exactly one other and loses to
  exactly one. A control table in which melee loses to both others must fail
  the same check, and it does. The macOS, Windows and Linux zips and the web
  build in a desktop browser then printed the same two rounds, with the same
  winners and the same damage per pair of roles, and `RESULT PASS`. In round 1,
  range did 303 damage to cyber and cyber did 57 to range. The web game's
  slowest frame in round 1 read 150 ms with the roles and 134 ms without them,
  one run each in the same browser, so the difference is not measured past
  noise. The release kept its tag, because the guest did not change; its zips
  and SHA256SUMS were replaced.
  """
end
