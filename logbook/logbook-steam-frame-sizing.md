# The Steam Frame, sized for RFD 2287's first rung

The headset's display, runtime, compute, network and codec budget, measured on 2026-09-30 over
SSH from the desk (an M2 Pro Mac) so the rung is sized against numbers rather than a spec
sheet.

## Access

The devkit client pairs by POSTing an SSH public key, followed by a fixed token the client
appends (`900b919520e4cf601998a71eec318fec`), to `http://<host>:32000/register` while the
headset is in Settings, Developer, Pair new host. The headset advertises
`_steamos-devkit._tcp` over mDNS with `login=steamos`. The service allows one pairing prompt
at a time. A request without the token, or one sent while an earlier prompt is still open,
is refused with 403.

## Display and runtime

| Quantity | Value | Read from |
| --- | --- | --- |
| Panels | 2 × 2160×2160, modes at 108, 120 and 144 Hz | `/sys/class/drm/card0-DSI-1/modes` |
| OpenXR runtime | SteamVR/OpenXR 2.17.10, arm64 | `xrGetInstanceProperties` |
| Recommended eye target | 1728×1728, max 8192×8192, 1 sample | `xrEnumerateViewConfigurationViews` |
| Extensions of note | `XR_EXT_local_floor`, `XR_EXT_hand_tracking`, `XR_FB_foveation_vulkan`, `XR_META_foveation_eye_tracked`, `XR_FB_space_warp` | `vrclient.so` |
| Memory | 15.3 GiB, 10.9 GiB available idle, 7.8 GiB swap | `free -m` |
| Battery | 2.73 Ah design at 7.76 V, about 21 Wh | `max1720x` power supply |
| Compatibility layer | Proton 11.0 (ARM64), FEX-Emu | `steamapps/common` |

## Compute

One Slang kernel (`fma.slang`: eight independent vec4 FMA chains, 512 iterations, 2^20
threads) compiled with Slang 2026.13 to SPIR-V on the headset, Metal on the desk, and a CPU
shared library on both. The CPU host splits groups across every core. Each figure is the
best of five runs of 20 dispatches.

| | Desk (M2 Pro) | Headset (SM8650) | Headset ÷ desk |
| --- | --- | --- | --- |
| GPU FP32 | 2.88 TFLOPS | 1.28 TFLOPS | 0.44 |
| GPU FP16 | 5.33 TFLOPS | 2.57 TFLOPS | 0.48 |
| CPU FP32, 1 thread | 31.6 GFLOPS | 16.0 GFLOPS | 0.51 |
| CPU FP32, all cores | 275 GFLOPS (12) | 107 GFLOPS (8) | 0.39 |

The kernel reaches about 42% of the M2 Pro's 6.8 TFLOPS peak and about 46% of the Adreno
750's 2.77 TFLOPS at its 903 MHz top clock, so the ratios hold and the absolutes are a floor.
The GPU idles at 366 MHz and was at 903 MHz after the run. The Slang CPU target does not
compile `half` vectors in 2026.13, so the CPU rows are FP32 only.

The Hexagon NPU is `/dev/cdsp`, driven by `dsp-sm8650` and held by SteamVR's root
`dsp_service`. Opening it as `steamos` returns EPERM although the user is in the `cdsp`
group. The image has no FastRPC node and no QNN or `libcdsprpc` libraries, so the GPU is the
only accelerator available to the rung.

## Network

| Quantity | Value |
| --- | --- |
| Link | 5 GHz, 80 MHz, HE-MCS 9, rx 458.8 / tx 413.0 Mbit/s, −42 dBm |
| TCP, desk to headset, 8 s | 317 Mbit/s |
| RTT, idle at 5 pings a second | mean 65.4 ms, max 166.9 ms |
| RTT, busy at 50 pings a second | mean 5.2 ms, max 7.4 ms |

Wi-Fi power save is on. Idle round trips are over twelve times the busy ones, a gap that
pose and voice datagrams sent at 50 to 90 Hz sit inside.

## Codec

PyroWave `89f7e47`, built natively on the headset in 24 s, its `pyrowave-c-test` passing.
`pwbench.cpp` encodes and decodes one 4:2:0 frame 30 times through the CPU-buffer API,
packetised at a 1200-byte MTU, and reports medians of the last 25. The content is a frame
from the rung recording (flat-shaded), with 1728² per eye placed side by side. The control is
uniform random noise at the same size.

| Frame | Mbit/s at 72 Hz | Bytes/frame | Encode ms | Decode ms | PSNR-Y dB |
| --- | --- | --- | --- | --- | --- |
| 1920×1080 | 100 | 173,604 | 5.50 | 1.61 | 49.28 |
| 3456×1728 | 200 | 347,216 | 12.38 | 9.41 | 50.48 |
| 3456×1728 | 300 | 520,804 | 12.38 | 8.62 | 51.15 |
| noise 3456×1728 | 200 | 347,120 | 19.02 | 8.47 | 11.47 |

The noise control holds its byte budget, within 96 bytes of it, while PSNR collapses. The
cap is exact rate control, not a property of easy content. The times include the CPU
upload and readback of 9 MB a frame. They are not the GPU-only times the codec is built
for. Those need `pyrowave-bench` from the devel build, which stops at SDL3's missing
XScrnSaver on the headset. The rung recording itself is CineForm 4:2:2 10-bit at 90.5 Mbit/s
for 1920×1080 at 30 fps.

## The double-precision build in the headset

Engine `entities-godot` master `97dab7a63`, godot-sandbox `b1118e5`, both at double,
cross-built on the desk with llvm-mingw 20260922. The Windows double editor build runs the pen
scene through Proton. The OpenXR session begins at 3.67 s, the garment comes out 940
vertices and 1748 faces, and 4308 frames average 13.92 ms (p95 13.89 ms), or 72.0 fps. The
earlier build, run the same day, also holds 72.0 fps. The exported `template_release` build
page-faults reading `0x25` inside a `StringName` copy, in XR and flat mode, only while the
sandbox addon is loaded.
