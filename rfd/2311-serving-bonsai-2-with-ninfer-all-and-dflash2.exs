# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2311, "serving bonsai 2 with ninfer-all and dflash2", :discussion do
  flight_level :l1
  feature "the 4090 serves Ternary Bonsai 2 27B through ninfer-all with a DFlash2 drafter of five
tokens, and this RFD is how to set that up again from nothing"
  scope "the desk's RTX 4090, the V-Sekai-fire/ninfer-all fork, the t2 `.ninfer` artifact, the
launcher task, the mTLS front and the Hermes provider; the Linux 4090 host runs the same engine"

  prose ~S"""
  :: decision
  The 4090 language server is ninfer-all, built from the fork's
  `dev/msvc-f16c-convert` branch, serving the t2 `bonsai2-27b-heretic.ninfer`
  artifact with `--spec dflash2 --draft-tokens 5`. It replaces the prebuilt
  sm_89 engine on MTP-3 that the desk ran before 2026-10-12. The server binds
  loopback only, takes an API key, and is reached off the box through stunnel
  with mutual TLS. The operator settled it on 2026-10-12 ("The ninfer with
  dflash won"), after the A-B-A run in the details.
  :: problem
  No RFD decides how the 4090 serves Bonsai 2. The setup lived in one agent's
  notes. The blocklist row that keeps MTP-3 is scoped to the ggml language
  server, and it was measured on decider latency, so it neither covers nor
  contradicts this engine. A rebuilt desk had nothing to follow.
  :: related
  - BLOCKLIST.md, "Speculative decoders other than MTP-3" and "1-bit
    PTQ1_0 bodies", both for the ggml language server on the 3090.
  - RFD 2308, the Mac port of the same engine, which uses this server as
    its parity reference.
  - RFD 2306, operating the shared Windows VR desk; RFD 2310, the scorer
    that calls this server.
  """

  details_title "serving bonsai 2 with ninfer-all and dflash2"

  prose ~S"""
  :: details This RFD was drafted by an AI and read by a human before it shipped.
  Drafted on 2026-10-12 from the desk's A-B-A run, the live launcher and
  process read the same day, and the Linux host's spec sweep of 2026-10-11.
  The choice of engine and drafter is the operator's.

  :: details The measurement
  One RTX 4090, the same launcher flags on every arm (`--max-context 262144`,
  `--kv-dtype rk8v4`, `--vision`, one request at a time), three repetitions,
  temperature 0, 512 generated tokens, speeds read from the server's own
  `timings`. Arms ran A-B-A so the repeated arm shows drift. Decode in tokens
  per second:

  | Arm | chat | code | story |
  | --- | --- | --- | --- |
  | ninfer-all, DFlash2 K=5 | 218-232 | 314-360 | 176-187 |
  | prebuilt engine, MTP-3 | 206-226 | 279-282 | 176-184 |
  | ninfer-all, MTP-3 | 193-206 | 239-267 | 164-172 |

  - Prefill on ninfer-all is about 10% faster: 5.7k to 5.9k against 5.3k
    tokens per second at 3k prompt tokens.
  - Story is a tie inside the spread. ninfer-all with MTP-3 is the slowest
    arm, so the gain needs both the engine and the drafter.
  - Temperature-0 text differs between the two engines and between the two
    drafters inside ninfer-all. The prebuilt engine's two A passes matched on
    11 of 12 requests.
  - The prebuilt engine cannot run DFlash2 on this artifact without
    `--lm-head-draft`, and with it DFlash2 was slower than its MTP-3 on every
    workload.

  The baseline taken after the switch, the same day: decode chat 251, code
  305, story 184, and 325 after a 1.8k-token prompt; draft acceptance 40, 52,
  24 and 63%; prefill 5.7k tokens per second at 1,845 tokens. On 2026-10-11
  the Linux host's 4090 ran the same engine in its container, and DFlash2 K=5
  beat MTP-3 there on every workload as well.

  :: details Building the engine
  The fork is `V-Sekai-fire/ninfer-all`. Its branch `dev/msvc-f16c-convert`
  sits on upstream `72e071e1` with three commits MSVC needs, at `fdce07bb`:

  - half-float conversion through `_mm_cvtph_ps` instead of `_cvtsh_ss`;
  - `::ReadFile` and `_mm_pause` named explicitly in the expert-miss reader;
  - `build.nu` globbing the dist tree from inside it.

  The build runs on the desk as the named scheduled task `ninfer-build`
  (`C:\ninfer-scratch\build-job.nu`, log beside it), through
  `pixi run --locked -e build nu v-sekai/build.nu`. It takes about an hour on
  sm_89. The output is `C:\ninfer-all\dist\windows\bin\ninfer-serve.exe`.

  :: details The artifact
  `bonsai2-27b-heretic.ninfer`, 9,520,051,456 bytes, format `t2_g128_fp16`,
  with the vision tower, the MTP head and the DFlash2 head inside it. The
  converter is pure Python and runs on the CPU; the Mac produced this copy
  with recipe `bonsai2_27b_ternary` from the Heretic PQ2_0 body and the
  Bonsai-trained MTP and DFlash2 heads. The four sources and the artifact
  are published in the public dataset `chibifire/ninfer-bonsai2-heretic`
  (operator, 2026-10-12). On the desk it lives at `C:\ninfer-all-models\`,
  next to its `.conversion.json`.

  Every input is Apache-2.0: Qwen3.8-27B, Ternary Bonsai 2 27B, the Heretic
  v2 modification, the MTP and DFlash2 heads and the weights they adapt. The
  dataset carries their licence and notice files, a root `NOTICE` that names
  each author and states the conversion, and an Apache-2.0 card.

  A published artifact names no host path. The converter records the
  frequency ranking it reads by its repository-relative path, and a
  workflow in the fork converts on a clean runner and fails on any of the
  runner's directories in the artifact or its report, after a planted path
  is caught. Before this, the ranking's absolute path sat in both files.

  The prebuilt engine reads only `t5_g128_fp16`, and ninfer-all reads only
  `t2_g128_fp16`. An artifact from one family does not load in the other.

  :: details The launcher
  `%LOCALAPPDATA%\V-Sekai\llm\serve-ninfer-4090.cmd` sets
  `CUDA_DEVICE_ORDER=PCI_BUS_ID`, reads the key from `api-key.txt` in the same
  directory, and starts:

      ninfer-serve.exe C:\ninfer-all-models\bonsai2-27b-heretic.ninfer
        --device 1 --host 127.0.0.1 --port 8091 --api-key %KEY%
        --model-id bonsai-27b --max-context 262144 --kv-capacity 262144
        --kv-dtype rk8v4 --vision --max-concurrency 1
        --spec dflash2 --draft-tokens 5 --no-thinking

  Output appends to `logs\ninfer-4090.log`. It holds about 16.9 GB of the
  4090's 24 GB. The task `\V-Sekai\llm-ninfer-4090` runs it through
  `conhost --headless cmd /c` at logon and again every minute, so a dead
  server returns within a minute. Ending the process alone does not keep the
  card free; disable the task first.

  - The key file allows the operator read only. Rotating it means saving its
    ACL, granting modify, writing the key, and restoring the saved ACL.
  - The server's command line holds the key. Mask `--api-key` whenever
    processes are listed.

  :: details Reaching it
  stunnel on the desk (logon task `ninfer-stunnel`) accepts on the tailnet
  address, port 8443, and forwards to 127.0.0.1:8091. It requires a client
  certificate under the chibifire Root and checks the client's host name
  against one allowlisted Mac. A program-scoped firewall rule admits only
  100.64.0.0/10. The Mac's launchd stunnel client exposes the server as
  http://127.0.0.1:18091, and Hermes calls it as provider `bonsai-desk`, with
  `api_mode chat_completions` and the key in `BONSAI_DESK_API_KEY`.

  :: details Witnesses
  Each one carries a control that must fail.

  - **Ready.** `GET /v1/models` returns 200 with the key and 401 without it.
  - **Spec.** The live command line, key masked, carries `--spec dflash2
    --draft-tokens 5`, and the server log reports draft acceptance above zero.
    The same check against the kept MTP-3 launcher fails.
  - **Vision.** `vision_zero_shot_probe.py` against 18091 names the red
    circle, the blue square and the text 42. The 3090's text-only server
    returns 500 on the same request.
  - **mTLS.** The allowlisted identity gets an HTTP answer. No certificate,
    and a certificate for a second Mac, are both refused.
  - **Speed.** `bonsai-bench.nu` (three reps of chat, code and story at 512
    tokens, plus a 1.8k prompt) lands inside the baseline above. A number
    without that baseline is not reported. The MTP-3 launcher's code
    workload, 279-282, falls below it.

  :: details Rolling back
  The prebuilt engine's launcher is kept as
  `serve-ninfer-4090.cmd.bak-jgamboa-mtp3`. Copy it over the launcher, then
  end and run the task. Any A/B that swaps `--spec` restores the launcher in
  the same script on failure: on 2026-10-12 the prebuilt engine died at
  startup on `--spec dflash2` and left the 4090 down until someone restored
  it by hand.

  :: details The Linux host
  The second 4090 host runs the same engine from the upstream container
  image, binary `/opt/ninfer/sm86/ninfer-serve`, under the podman quadlet
  `ninfer-bonsai` with `--spec dflash2 --draft-tokens 5 --vision --kv-dtype
  rk8v4 --max-context 262144` on 127.0.0.1:8080. Its own stunnel listens on
  8443 for the same Mac, where it appears as 18080 and Hermes provider
  `bonsai-fedora`. The artifact cannot take `--lm-head-q6`; with it the
  server crash-loops.

  :: details Open questions
  - The decider benchmark behind the MTP-3 blocklist row has not been run on
    ninfer-all. Until it is, the row and this RFD measure different
    workloads, and neither says which drafter makes better decisions.
  - MTP's upstream advantage is a second request lane
    (`--max-concurrency 2`). Every arm here served one request at a time.
  - DFlash2 at six and seven draft tokens is unmeasured.
  - The MSVC fixes are on a fork branch, not on the fork's `main`, and the
    Windows installer that would ship this build is not merged.
  - The desk and the Mac still serve the earlier private conversion, whose
    provenance carries the converting host's path. Swapping in the published
    artifact needs a witness that it serves the same text at temperature 0.
  """
end
