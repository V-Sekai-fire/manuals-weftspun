# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2305, "one credit system with ports and adapters", :discussion do
  flight_level :l2
  feature "every bounded resource in the workspace admits work through one credit ledger"
  scope "desk jobs, the work-stealing issue queue, the CI runner pool, the OXRSys video sender,
the datasource-store dirty-page buffer and the WebTransport stream budget"

  prose ~S"""
  :: decision
  One credit system admits work to every bounded resource. Its core is one
  rule: a request for `n` credits from a pool is granted `min(n, free)`, where
  `free` is `cap` less `held`, and the grant comes back when the work ends. `bp_bounded` in
  `spec/CacheBackpressure.lean` proves the rule keeps `held` at or below `cap`.
  The core exposes one port. Each resource is an adapter that sets its pool's
  cap from a measurement and chooses what a short grant means: wait, drop the
  oldest, or refuse. Work stealing stays, as the adapter that moves claims
  between agent pools; the ledger bounds each pool (operator, 2026-10-09).
  :: problem
  The workspace bounds load in five places, and each one does it its own way.
  RFD 2294's queue is full at three open issues. RFD 2030 runs two or three CI
  matrices by habit. The OXRSys runtime drops stale frames from a bounded sender
  queue. datasource-store#16 modelled credit admission for dirty pages and was
  retracted for that workload. WebTransport has its own stream credit. Nothing
  bounds the Windows desk: on 2026-10-09 an agent build on every core, a stream
  recorder, two chat clients and a VR game held the CPU at 100% and the VR GPU at
  95%, and the VR runtime's compositor watchdog killed the compositor twice.
  :: related
  - RFD 2294, the work-stealing queue and its depth of three.
  - RFD 2030, CI runners as a queueing system.
  - RFD 2058, WebTransport stream credit.
  - RFD 2302, guest work in frame slices: a frame's time is a pool.
  """

  details_title "one credit system with ports and adapters"

  prose ~S"""
  :: details The core
  A pool is `(name, cap, held)`. Three operations change it:

  - `acquire(pool, n)` returns a grant `g = min(n, free)` and adds `g`
    to `held`. A grant of 0 is a shortfall, never an error.
  - `release(grant)` subtracts the grant from `held`. A grant is released
    once; a second release is refused by grant id.
  - `set_cap(pool, cap)` replaces the cap from a measurement. A lower cap
    takes no grant back. New grants wait until `held` falls under it.

  The ledger never measures anything and never schedules anything. It holds
  integers and the proof. The Lean model in `spec/CacheBackpressure.lean`
  becomes the reference, and each implementation checks its grants against the
  model's witness vectors. A grant that the model refuses is a failed test.

  :: details The port
  An adapter talks to the core through four calls: `acquire`, `release`,
  `set_cap`, and `observe(pool)`, which returns `cap`, `held`, the number of
  waiting requests and the oldest wait in milliseconds. `observe` is what
  monitoring reads, the same way `systemctl status` reads a unit.

  The adapter owns two decisions the core does not:

  - **The cap**, from a probe of the resource it guards.
  - **The shortfall policy**: `wait` (queue the request, first in first out),
    `drop_oldest` (for real-time data, where an old item has no value), or
    `refuse` (return at once and let the caller decide).

  :: details The adapters
  - **Desk jobs.** One pool per resource on a host: `cpu` in hardware threads,
    `gpu<i>` in percent of utilisation, `vram<i>` in MiB. The cap comes from a
    probe every 5 s: threads minus the threads in use by processes outside the
    ledger, `nvidia-smi` for each GPU. A GPU that drives a VR runtime has a cap
    of 0 for batch work while the runtime runs. Policy `wait`. Each one-shot job
    (a systemd oneshot, or a named scheduled task on Windows) declares its cost
    before it starts and releases on exit; a recurrent service holds its grant
    for as long as it runs. A build passes its CPU grant to its compiler as the
    job count.
  - **The work-stealing queue.** One pool per agent, cap 3: RFD 2294's depth,
    written as credits. Filing an issue acquires 1; closing it releases 1. A
    steal is a release from the victim's pool and an acquire in the thief's, in
    that order. Policy `refuse`, so a full queue reports its depth to the
    operator, as RFD 2294 already says.
  - **The CI runner pool.** One pool for the organisation, cap 3, in full
    matrices: RFD 2030's habit, enforced. A push that triggers a matrix
    acquires 1 before its workflow dispatches; the workflow's last job releases
    it. Policy `wait`, with zero-information runs cancelled before they queue,
    as RFD 2030 says.
  - **The OXRSys video sender.** One pool per client, cap the sender queue's
    length. Policy `drop_oldest`, which is what the runtime does today; the
    adapter makes it observable.
  - **The datasource-store dirty buffer.** Cap `DIRTY_SOFT_CAP`. Policy `wait`.
    The retraction in datasource-store#19 stands for YCSB F, where the cap never
    triggered; the adapter costs nothing until a workload reaches the cap.
  - **WebTransport streams.** The transport's own credit is the cap, set from
    the peer's limit. Policy `wait`. The ledger observes it and does not replace
    it.

  :: details Why credits and not work stealing
  Credits bound load by construction, with a proof, and they price each
  resource on its own unit, which a shared desk needs: threads, GPU time and
  video memory run out separately. Work stealing balances tasks between workers
  and keeps idle workers busy, but it bounds a queue's length, not what runs on
  a host. The 2026-10-09 overload came from work pinned to one desk, which RFD
  2294 never steals. The two compose: an agent steals an issue, then its jobs
  wait for the desk's credits.

  :: details Milestones
  - **M1, the core and the desk adapter.** The ledger as an Elixir module with
    the four port calls, checked against the Lean model's witness vectors; the
    desk adapter with its probe; `windows_build.ps1 -Jobs` fed from the CPU
    grant. Exit: the self-test admits a job set that fits, makes a job wait
    when it does not, and its control, a job that skips the ledger, is seen by
    the probe as outside load and lowers the cap.
  - **M2, the queue and CI adapters.** RFD 2294's depth and RFD 2030's matrix
    count read their caps from the ledger. Exit: a fourth issue is refused with
    the depth reported; a fourth matrix waits.
  - **M3, the streaming adapters.** The OXRSys sender and WebTransport report
    through `observe`. Exit: a client that stops reading shows `drop_oldest`
    counts in `observe`, and the runtime's frame time does not change.

  :: details Open questions
  - Where the core lives: its own repository on the interactor side, or in
    `V-Sekai-fire/nif` beside the RECTGTN library of RFD 2304.
  - Whether a pool spans hosts. The desk adapter is per host; the CI pool is
    organisation-wide. A cross-host pool needs one owner of `held`.
  """
end
