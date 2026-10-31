# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2360, "The campus as a beta", :discussion do
  flight_level :l1
  scope "the stages, the one beta, and the nongoals."

  prose ~S"""
  :: hook
  What ships in the campus beta? Four features.
  :: intrigue
  Dev is development: features land and change, and a feature that misses the one beta is
  abandoned rather than deferred.
  :: exit
  Read below for the four features. Refuse a new idea that matches a nongoal. Cut the beta when
  every gate passes with its control.
  :: decision
  - One beta, a feature-complete freeze after dev, holds the features the details list. Every
    nongoal is abandoned (operator, 2026-10-30).
  - The four are: see each other, hear each other, draw and wear, and the party and the shop.
  :: problem
  After the beta is cut, only fixes land.
  :: related
  - RFD66606-2340, the campus; RFD66606-2358, the party; RFD66606-2359, the shop.
  - RFD66606-2312, the form of the release tag.
  """

  details_title "The campus ships one beta"

  prose ~S"""
  :: details The stages and the one beta
  The campus has two stages before release (operator, 2026-10-30). Dev is development: features
  land and change. Beta is a traditional feature-complete freeze: after the beta is cut, only
  fixes land, and a feature that is not in it is abandoned. There is one beta.
  The tag stays in RFD66606-2312's form, and the stage goes in the release title.

  The beta has these features:

  - You can see each other: two people in the campus zone, one in the Steam Frame on a PC VR stream and
    one on the desktop, each sees the other's avatar.
  - You can hear each other: voice between the two, played at the speaker's avatar.
  - You can draw and wear: the pen's first rung, RFD66606-2287, in the campus zone; the drawn outfit is
    worn and the other person sees it.
  - You have a party and a shop: one player and the three seats, each filled by a friend or an persona,
    the takeover, the walk from the shop to a room and back, and the shopkeeper persona with its
    saved world.

  The beta is cut when every gate in RFD66606-2340, RFD66606-2358 and RFD66606-2359 passes
  with its control.

  :: details Nongoals
  Everything outside the beta is cut, and every nongoal is abandoned rather than deferred
  (operator, 2026-10-30). A new idea that matches a nongoal is refused, and the list is not argued
  again before the beta ships. The nongoals named so far:

  - a hidden director that plans the day
  - friendships and romance
  - a shared limit gauge with a team finisher
  - shop prices and a loan
  - an end-of-day report
  - a job board where each seat accepts or refuses a job
  - campuses built by players
  - the Steam Frame's standalone mode
  - the Steam Deck
  - the Hyper-V machine with its emulated TPM
  """
end
