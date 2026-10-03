# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2181, "Drop the allosaurus-rus phone-inventory control", :published do
  feature "documentation retraction"
  scope "RFDs 2164, 2170; `emit_10track_panel.py`;\n`add_allosaurus_control.py`; `CITATION.cff`"

  prose ~S"""
  :: decision
  Drop the `allosaurus-rus` phone-inventory control; the panel drops from 8 tracks to 7, keeping
  `universal` as the language-inventory-free default and `eng` as the English control.
  :: problem
  RFD 2164 (Rung 1 corpus) shipped allosaurus at three inventories: `universal`, `eng`, `rus`.
  The `rus` inventory was picked as a plausible L1 transfer partner for the first SpeakingFaces
  subject (Kazakh L2 English speaker); RFD 2170 (allosaurus language set) then generalised the
  set. The panel's implementation still carries `rus` as a per-clip inventory and runs it on
  every clip regardless of the speaker's L1.
  :: section Panel after the drop
    text-track   Parakeet TDT 0.6B v3, Voxtral Mini 3B, wav2vec2
    IPA-track    Voxtral-IPA, Gemma-4-12B GBNF-IPA
    phone-track  allosaurus universal + eng

  Per-clip language inventories can be added back keyed to the speaker's L1 if a future corpus
  documents it, rather than one hard-coded language for everyone.

  Follow-ups: `emit_10track_panel.py` and `add_allosaurus_control.py` drop the `rus` inventory;
  downstream RFDs lose their `rus` mentions; `CITATION.cff` unaffected (allosaurus itself
  stays).
  :: related
  Extends RFD 2179 (Whisper drop) and RFD 2180 (gemma-auto drop). Amends the panel row in RFD
  2170 (allosaurus language set)'s decision that named `universal + eng + rus`.
  """
end
