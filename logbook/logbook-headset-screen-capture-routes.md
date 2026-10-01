# Getting the headset's view to the desk: three routes measured

Measured on 2026-09-30 over SSH from the Windows desk, while looking for a way to put the
wearer's view into the desk's broadcast software.

## scrcpy cannot run

scrcpy's server needs Android's `app_process`. The headset's `adbd` is the Linux build from
`/usr/lib/android-sdk/platform-tools`, started by `adbd.service`, with no Android `/system`
and no `app_process`. The route ends there.

## The compositor's PipeWire node: plugin loads, node not found

- `gst-plugin-pipewire 1:1.6.8-1.2` matches the headset's PipeWire 1.6.8 and GStreamer 1.24.2.
- The package manager needs root, so the package was fetched with curl from the OS's hotfix
  repository and unpacked to `~/obs-frame/root`. Its SHA-256 was checked against the sync
  database in `/usr/lib/holo/pacmandb/sync`.
- `tar --force-local` is needed, because the file name holds a colon.
- `GST_PLUGIN_PATH=~/obs-frame/root/usr/lib/gstreamer-1.0` makes `pipewiresrc` load.
- `pipewiresrc target-object=gamescope` then fails with `target not found`. A probe the same
  morning had listed a `gamescope` Video/Source node; on recheck it was absent. The compositor
  runs with its VR backend.

The encode leg planned after it, H.264 through `v4l2h264enc` into MPEG-TS over the SSH key, is
withdrawn. Recordings are CineForm, and the live view is PyroWave, per `BLOCKLIST.md` and
RFD 2294.

## The compositor mirror: works

The runtime exposes the wearer's view as V4L2 `/dev/video99`, RGB24 1920×1080 at 30 Hz, once
`vrcmd --mailboxcmd vrcompositor_systemlayer 'set_local_video_record?enabled=true'` turns it
on. It is read with `v4l2-ctl -d /dev/video99 --stream-mmap --stream-to=-`. On the stable OS
`--mailboxcmd` is refused, yet `/dev/video99` still streams when screen sharing is on in the
headset's settings (the operator turned it on 2026-10-01).

This is the route the headset capture took: the Mac desk's xr-cua capture encodes it with
PyroWave or CineForm (contract-zone-backend #65).
