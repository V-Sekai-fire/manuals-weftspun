# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2345, "Video intermediate: CineForm and FLAC in Matroska", :committed do
  feature "one intermediate format for every rendered video"
  scope "every tool in the workspace that writes a video file, first the decider-pong
interactor"

  prose ~S"""
  :: decision
  Every rendered video is written as CineForm video and FLAC audio
  in a Matroska (`.mkv`) file. CineForm runs at `gbrp12le`, so RGB frames
  keep full chroma. MP4 is blocklisted as a container, and H.264 and AAC
  are not written as outputs. A tool that writes video refuses an output
  path that does not end in `.mkv`. Uncompressed PCM audio is accepted in
  place of FLAC (operator, 2026-10-23); both are lossless.
  :: problem
  The decider-pong recorders wrote H.264 and AAC in MP4. That is a lossy
  delivery format, and a second encode loses more. An intermediate must
  survive re-encoding and keep sharp synthetic edges. The workspace had
  no written format, so each recorder picked its own.
  :: related
  - RFD66606-2349, which replaces the encoder, the live recorder and the
    file check below. The format here stands.
  - RFD66606-2346, decider-pong in the workspace; RFD66606-2347, the
    decider-pong review.
  - The private blocklist, which lists MP4.
  - The decider-pong skill carries the same rule for agents.
  """

  details_title "The format, how fast it encodes, and how a file is checked"

  prose ~S"""
  :: details Encoder settings
  The homebrew ffmpeg ships the `cfhd` encoder. It takes `yuv422p10le`,
  `gbrp12le` and `gbrap12le`. The recorders use `gbrp12le`, because
  their frames are RGB and Pong's edges are one colour against another.
  Audio is FLAC, or uncompressed PCM, at 48 kHz, stereo.

  A live recorder pipes raw RGB to one ffmpeg process that writes
  CineForm in Matroska, then a second pass copies that video and adds
  the FLAC track. Nothing is held in memory past the pipe.
  :: details Cost
  On the Mac mini, `cfhd` encodes a 1080p test source at about 170
  frames a second, so a 30 fps live render keeps up with room to spare.
  A file grows by about 20 MB a second at 1080p. A 2-minute render is
  about 2.4 GB and a 5-minute render about 6 GB. The Desktop filled to
  43 GB in one session, so superseded renders are listed for deletion
  and deleted only on request.
  :: details How a file is checked
  `ffprobe` must report `cfhd`, `gbrp12le`, 1920x1080, `flac` or a
  `pcm_s16le`/`pcm_s24le` stream at 48000 Hz
  and the `matroska` format, with the duration the run asked for. A
  frame is then pulled with `ffmpeg -ss` and looked at. That report and
  that frame are the check, whatever exit code the recorder returns.
  :: details The guard and its control
  `recorder_second_opinion.py` exits with an error on any `--out` that
  does not end in `.mkv`. The planted control asked for
  `planted.mp4`: the run exited 1 and wrote no file.
  :: details What changed in decider-pong
  `recorder_pong_v.py` and `recorder_second_opinion.py` now write
  CineForm and FLAC. Four superseded recorders that only wrote MP4 were
  deleted: `recorder_live.py`, `recorder_pong_live.py`,
  `recorder_pong_vector.py` and `recorder_realtime.py`. Every MP4 the
  session had made was removed and re-rendered.
  """
end
