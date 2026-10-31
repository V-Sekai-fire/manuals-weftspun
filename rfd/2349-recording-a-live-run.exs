# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2349, "Recording a live run: house recorder at 4K, CineForm, no FFmpeg tool", :committed do
  feature "one way to record a run where a live model plays"
  scope "every recording of a live run in the workspace, first the decider games"

  prose ~S"""
  :: decision
  A live run is recorded with the house recorder on the Mac at a
  3840x2160 canvas. The recorder writes CineForm video and FLAC audio in
  Matroska through its custom output. The game runs on the wall clock
  and never waits for the model. Godot Movie Maker is blocklisted.
  FFmpeg never runs as a tool. RFD66606-2345's format stands; this RFD
  replaces its encoder, its live recorder and its file check.
  :: problem
  RFD66606-2345 encodes with the homebrew `ffmpeg` and checks files with
  `ffprobe`. FFmpeg as a tool is now banned. Movie Maker renders at a
  fixed frame rate, so the game waits for the model and the video hides
  its latency. A video of a live model must show the latency it has.
  :: related
  - RFD66606-2345, the video format, which this RFD amends;
    RFD66606-2347, the decider-pong review.
  - The private blocklist, which lists Movie Maker and FFmpeg as a tool.
  - The private manifest's issue on the parked Snake video, which
    records the rulings and the house recorder test.
  """

  details_title "The recorder, the codec, the check and what is open"

  prose ~S"""
  :: details The operator's rulings, 2026-10-09 and 2026-10-10
  - The recorder is the house recorder. Movie Maker is blocklisted.
  - The video is 3840x2160. 2K is denied.
  - A video holds at least 2 minutes of real run time. A short run is
    made longer by running longer, never by holding or repeating frames.
  - The game ticks on the wall clock. A late reply applies at the next
    tick. With no reply the game takes its default move.
  - CineForm everywhere. No ProRes is written and converted to CineForm.
  - FFmpeg never runs as a tool, and headless Godot never runs.
  :: details How the house recorder writes CineForm
  The house recorder's current release ships the `cfhd` CineForm
  encoder. Its custom output, built on FFmpeg, is set to Matroska with
  `cfhd` video and FLAC audio. In a still-frame test every frame decoded
  through the CineForm SDK at 39.4 dB against the input. The control,
  the same input shifted 40 px, scored 16.3 dB.
  :: details Encoding outside the house recorder
  A render that is not a live capture encodes with the CineForm SDK
  through the engine's CineForm module or the CineForm interactor.
  Delivery uses the AV1-in-Matroska interactor's `deliver.exs`. It
  rewraps the frames byte for byte and checks every frame and sample.
  - A render reel records through the engine's movie writer straight to
    CineForm. It writes no PNG frames to encode later (operator,
    2026-10-17).
  - Large media and videos are kept on the Windows desk, not on the
    Mac mini, which sits on a remote network (operator, 2026-10-17). A
    render made on the Mac is copied to the desk, its size is read back
    there, and only then is the Mac copy deleted.
  :: details How a file is checked
  `deliver.exs` checks every frame and every sample. `av1mkv dump-frame`
  pulls frames, and a person looks at them. The run's length is gated
  from the frames' own timestamps, and a short frame set is the control
  that must fail. The frames and samples are the check, whatever exit
  code the recorder returns.
  :: details Still open
  - The house recorder's custom output uses FFmpeg's encoder inside the
    recorder. The ruling bans FFmpeg as a tool, and the Snake video
    issue records the house recorder as the route. The operator has not
    ruled on whether the licence reason reaches the house recorder.
  - The decider-pong recorders named in RFD66606-2345 still call
    `ffmpeg`. They move to the house recorder or the SDK route when that
    project is next worked on.
  """
end
