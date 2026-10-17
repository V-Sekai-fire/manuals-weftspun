# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2311, "serving bonsai 2 with ninfer-all and dflash2", :committed do
  flight_level :l1
  feature "the 4090 serves Ternary Bonsai 2 27B through ninfer-all with a DFlash2 drafter of five
tokens, and this RFD is how to set that up again from nothing"
  scope "the Linux host's RTX 4090, the V-Sekai-fire/ninfer-all fork, the t2 `.ninfer` artifact,
the systemd unit, the mTLS front and the Hermes provider; the Windows desk's sections are kept as
the record"

  prose ~S"""
  :: decision
  The 4090 language server is ninfer-all serving the t2
  `bonsai2-27b-heretic.ninfer` artifact with `--spec dflash2 --draft-tokens 5`,
  on the Linux host since the Windows desk was decommissioned on 2026-10-16.
  The server binds loopback only, takes an API key, and is reached off the
  box through stunnel with mutual TLS. The Linux host met none of those three
  when read on 2026-10-16, and all three by the end of that day. The operator
  chose the engine and drafter on 2026-10-12 ("The ninfer with dflash won")
  after the A-B-A run in the details.
  :: problem
  No RFD decided how the 4090 serves Bonsai 2, and the setup lived in one
  agent's notes. The desk this RFD first described is gone, and the Linux
  host that replaced it served without a key to anyone on the LAN.
  :: related
  - BLOCKLIST.md, "Speculative decoders other than MTP-3" and "1-bit
    PTQ1_0 bodies", both for the ggml language server on the 3090.
  - RFD 2308 (Mac ninfer port), which uses this server as its reference.
  - RFD 2319 (endpoint certificates), where the front's certificate comes
    from.
  - RFD 2310 (eye-landmark scorer), which calls this server.
  """

  details_title "serving bonsai 2 with ninfer-all and dflash2"

  prose ~S"""
  :: details Sources
  Drafted on 2026-10-12 from the desk's A-B-A run, the live launcher and
  process read the same day, and the Linux host's spec sweep of 2026-10-11.
  The choice of engine and drafter is the operator's. Amended on 2026-10-16
  when the operator decommissioned the Windows desk: the Linux host was read
  over SSH that day, and the sections from "Building the engine" to "Rolling
  back" describe the desk and stay as the record.

  :: details The Linux host, read 2026-10-16
  Fedora 44, an RTX 3090 and an RTX 4090, both capped at 275 W. Tailnet name
  `fedora.stonecat-ratio.ts.net`, address 100.112.127.19, agent identity
  `fedora-9a6c28.agents.weftspun`. The host was reimaged before this read,
  and the `fedora-108f7b` identity the Mac's stunnel client still names is
  gone.

  The systemd unit `ninfer-serve.service`, enabled, runs as user
  `ninference`:

      /usr/local/bin/ninfer-serve
        /home/setup/Desktop/models/bonsai2-27b-heretic.ninfer
        --host 0.0.0.0 --model-id bonsai2-27b --max-context 262144
        --kv-capacity 262144 --kv-dtype rk8v4 --gdn-state-fp16
        --spec dflash2 --draft-tokens 5

  It holds about 16 GB of the 4090. The artifact is the same 9,520,051,456
  bytes. The read found three gaps against the decision:

  - It listens on `0.0.0.0:8080` with no `--api-key`. `GET /v1/models`
    answers 200 without a key over the tailnet and over the LAN.
  - It runs without `--vision`, so the vision witness cannot pass.
  - No stunnel runs and the package is not installed. Hermes on the Mac
    calls `http://100.112.127.19:8080/v1` in plain HTTP.

  :: details The Linux front, built 2026-10-16
  Everything the server needs now lives under `/opt/ninfer`, so it no
  longer depends on a checkout or the Desktop:

  - `/opt/ninfer/models/bonsai2-27b-heretic.ninfer`, the same
    9,520,051,456 bytes.
  - `/opt/ninfer/lib`, 76 libraries (717 MB) the binary resolves: ffmpeg 7.1
    and CUDA 13 from the pixi environment it was built in. The binary's
    RPATH still names that environment's old path, which no longer exists,
    so the unit sets `LD_LIBRARY_PATH=/opt/ninfer/lib`. The binary reports
    `ninfer-serve 0.12.0-rtx3090+v0.6.0-rtx3090-1686-g305cd8bb`.
  - Drop-ins under `/etc/systemd/system/ninfer-serve.service.d/`:
    `10-libs.conf` sets the library path, `20-front.conf` sets
    `CUDA_DEVICE_ORDER=PCI_BUS_ID`, reads `/etc/ninfer/env` (root, 0400)
    and runs with `--host 127.0.0.1 --device 1 --api-key ${NINFER_API_KEY}
    --vision`. The binary takes the key only on its command line, so it is
    visible in `/proc` to a shell on the host; the network sees only the
    front.
  - `stunnel-ninfer.service` runs `/etc/stunnel/ninfer.conf` as a system
    user `stunnel`, which the Fedora package does not create. It accepts on
    100.112.127.19:8443 with the RFD 2319 certificate, and its `CAfile`
    holds the Root and agent CA v2. With the Root alone it refused a client
    that sends only its leaf.
  - The key is also in Bao at
    `secret/agents-own/mac-mini-fire-041138.agents.weftspun/bonsai-fedora-api-key`
    and in the Mac's `~/.hermes/.env` as `BONSAI_FEDORA_API_KEY`.
  - The Mac's `[ninfer]` client connects to `fedora.stonecat-ratio.ts.net`
    and checks that name. The desk sections are removed, kept in
    `stunnel.conf.bak-desk-20261016`.

  Witnesses, read 2026-10-16 from the Mac:

  | check | result | control | result |
  | --- | --- | --- | --- |
  | ready, with key, via 18080 | 200 | without key | 401 |
  | bind | `127.0.0.1:8080` | `100.112.127.19:8080` from the Mac | refused |
  | mTLS, `mac-mini-fire-01b8f5` | accepted, forwarded | no client cert | refused |
  |  |  | `mac-mini-fire-041138`, same CA | refused, subject check |
  | completion via 18080 | answered | | |

  The vision and speed witnesses are not yet run on this host.

  :: details What went wrong building it
  The first read that day found `~/Desktop` cleared at 06:36: the
  `ninfer-all` checkout and the `models` directory were in the Trash. The
  server kept serving because the running process held both open. The first
  restart into the new unit failed with `startup failed | inspecting
  artifact` because the model path no longer existed, and the fallback came
  up on the 3090 because `CUDA_DEVICE_ORDER=PCI_BUS_ID` made device 0 the
  3090. A second attempt reran an unedited script. The 4090 served nothing
  from 09:51:51 to 09:53:35 PDT, about a minute and three quarters, until the
  artifact was copied out of the Trash to `/opt/ninfer/models`.

  The unit, drop-ins and stunnel files exist only on the host. A reimage
  removes them, as it removed the podman quadlet before; placing them in a
  repository is an open item.

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

  :: details The Linux host before 2026-10-16
  The second 4090 host ran the same engine from the upstream container
  image, binary `/opt/ninfer/sm86/ninfer-serve`, under the podman quadlet
  `ninfer-bonsai` with `--spec dflash2 --draft-tokens 5 --vision --kv-dtype
  rk8v4 --max-context 262144` on 127.0.0.1:8080. Its own stunnel listened on
  8443 for the same Mac, where it appeared as 18080 and Hermes provider
  `bonsai-fedora`. The artifact cannot take `--lm-head-q6`; with it the
  server crash-loops. The reimage removed the quadlet, the container and
  stunnel; the 2026-10-16 read above is the host as it stands.

  :: details Open questions
  - The decider benchmark behind the MTP-3 blocklist row has not been run on
    ninfer-all. Until it is, the row and this RFD measure different
    workloads, and neither says which drafter makes better decisions.
  - MTP's upstream advantage is a second request lane
    (`--max-concurrency 2`). Every arm here served one request at a time.
  - DFlash2 at six and seven draft tokens is unmeasured.
  - The MSVC fixes are on a fork branch, not on the fork's `main`. With the
    desk gone, no Windows build is needed for this RFD.
  - The desk and the Mac served the earlier private conversion, whose
    provenance carries the converting host's path. Whether the Linux
    host's copy is that one or the published artifact is unread; a
    temperature-0 text witness decides it.
  - Which commit `/usr/local/bin/ninfer-serve` was built from is unread.
  """
end
