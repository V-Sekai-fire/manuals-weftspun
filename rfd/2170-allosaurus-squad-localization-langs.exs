# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2170, "allosaurus runs universal + a 27-language commercial localization set", :committed do
  feature "phone-inventory controls for the ASR panel"

  scope "`6-datasource/anny-render-corpus/emit_10track_panel.py`, `6-datasource/anny-render-corpus/add_allosaurus_control.py`"

  prose ~S"""
  :: decision
  allosaurus runs at `universal` plus the 27-language commercial localization set commonly
  shipped by an actively-maintained AAA multiplayer game (captured 2018-12-15, unchanged through
  2026), giving 28 tracks.
  :: problem
  RFD 2164 (Rung 1 corpus) shipped allosaurus at three inventories: `universal`, `eng`, `rus`,
  picked because the first speaker was Kazakh L2 English. Per-corpus priors make runs
  incomparable.
  :: section The set
    universal, eng, fra, ita, deu, pol, rus, cmn, cmn-Hant, tur, spa,
    ara, ces, kor, bul, dan, nld, fin, ell, hun, jpn, nor, por, por-BR,
    ron, swe, tha, ukr

  Codes are ISO 639-3 with a script or region suffix where the source distinguishes
  (cmn/cmn-Hant, por/por-BR). The set is the tightest actively-maintained AAA-game localization
  set spanning every top game market.

  A clip whose L1 is out-of-set scores under `universal` alone; language-specific rows return
  empty (real signal, not silent skip). Where allosaurus shares one phone inventory across a
  pair (cmn/cmn-Hant, por/por-BR), rows share weights; labels survive.
  :: related
  Spine: urn:oid:1.3.6.1.4.1.66606.1.1.1173 (edit-reward corpus).
  Applies to: urn:oid:1.3.6.1.4.1.66606.1.2.2164 (Speech stub).
  """
end
