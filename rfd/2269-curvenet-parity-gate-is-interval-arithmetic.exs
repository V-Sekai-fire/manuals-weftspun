# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2269, "The curvenet parity gate is interval arithmetic", :discussion do
  flight_level :l1
  feature "the curvenet GPU port is certified against the CPU oracle on any
conformant driver, by bracketing each output in a proven interval instead of
demanding identical bits"
  scope "the parity gate in `interactor-curvenet` and its check harness in
`entities-cassie-flow-project/checks`, and the determinism contract every
Lean-authored curvenet kernel meets"

  prose ~S"""
  :: decision
  The parity gate brackets. Its oracle computes each output as a rounded-outward
  float32 interval that provably contains the real result, and the gate passes
  when the GPU result lies inside. This is driver-independent and it is not a
  tolerance: the interval width is computed from the algorithm, not chosen, so a
  passing result is a proof that the true answer sits there and every conformant
  driver agrees. Byte-identical output across drivers is not the contract, because
  it cannot be met. Detail is in DETAILS.md.
  :: problem
  RFD 2265 assumed the gate could require byte-identical output from the CPU
  oracle and the GPU kernel. It cannot. Byte-exactness across implementations
  holds only for a fixed pair of a compiler and a driver, and no single driver
  matches the CPU emit for every kernel. The `sqrt`-bearing kernels diverge on
  the D3D12 translation whose square root is not correctly rounded; the plain
  arithmetic kernels diverge on the software driver that contracts a multiply-add
  into a fused one against the shader's own no-contraction request. A gate keyed
  to one driver's bits certifies that driver, not the port.
  :: related
  - RFD 2265 (curvenet on compute-rd) states the gate as byte-parity; this RFD
    replaces that premise. The staging, the dispatch shape and the canonical
    ordering it describes are unchanged.
  - RFD 2263 (the first testable release's simulator gate) is the loop the port keeps at 90Hz.
  """

  details_title "The curvenet parity gate is interval arithmetic"

  prose ~S"""
  :: details Why byte-exactness is not the contract
  IEEE-754 makes addition, subtraction, multiplication, division, square root
  and the fused multiply-add correctly rounded: for given inputs and
  round-to-nearest they have one result,
  bit-identical on any conformant implementation, the CPU included. A kernel
  built only from those, with no contraction and no transcendental, is therefore
  byte-identical everywhere that is conformant. The obstacle is that the drivers
  on hand are not, each in its own place. The D3D12-to-Vulkan translation used on
  the workstation does not round `sqrt` correctly, so a df32 square root that is
  bit-exact against the CPU on the software rasteriser is one unit in the last
  place off on it. The software rasteriser contracts a multiply-add into a fused
  one even though the shader carries the decoration that forbids it, so a curve
  fit that is bit-exact on the translation is 512 units off on it at a value near
  a cancellation. The result is that byte-exactness is real but per-pair: it holds
  for one compiler against one driver, and which pair holds varies by kernel.
  :: details The interval is a proof, not a tolerance
  The oracle carries every value as a pair of float32 bounds that enclose the
  real result, widening one place outward on each operation so a
  round-to-nearest evaluation on any conformant device stays inside. The gate
  reads the GPU result and asserts it lies between the bounds. The width is a
  theorem about the computation rather than a number picked to make a test pass,
  and it is tight where the computation is well conditioned and wide only where
  the algorithm itself is ill conditioned, so a wrong answer is still caught. The
  oracle reimplements each kernel's algorithm in interval form including its
  branches: a curve fit whose least-squares solve falls back to a chord-third
  when a coefficient goes negative must take that same branch, or the interval
  brackets the wrong expression. Validated so far on the linear-combination and
  curve-fit kernels, passing on both the translation and the software rasteriser
  from the same interval.
  :: details Where byte-exactness still earns its keep
  Two kernel-level fixes remove the divergence that is the emitter's own rather
  than a driver's, and they are worth keeping under the interval gate because
  they narrow the bracket and make a single fixed driver bit-reproducible for
  debugging. First, the Slang `dot` and `lerp` intrinsics lower to a fused
  reduction on the GPU and to scalar multiply-adds on the CPU; expanding them to
  explicit scalar operations in the Lean source makes both targets emit the same
  sequence. Second, the curve kernels compile with the compiler's precise
  floating-point mode, which forbids contraction and reassociation. With both,
  the four curve-fit kernels are bit-identical against the CPU emit on a fixed
  conformant driver.
  :: details Double precision without a double type
  The polar decomposition behind per-knot orientation runs in double precision
  and calls `acos` and `cos`, and neither survives a float32 SPIR-V port: the
  precision is gone and the library transcendentals lower differently on the two
  targets. The port carries values as a df32 pair, a high and a low float32 whose
  unevaluated sum is the number, using the error-free transformations the solver
  kernels already ship. Every df32 operation reduces to correctly rounded float32
  arithmetic, so the pair is byte-reproducible on a conformant driver and holds
  about double precision. The transcendentals are authored in df32 from
  polynomials, never the divergent intrinsic, or bounded by the monotonic
  interval the gate already provides. A df32 square root measured 1.8e-15
  relative error, near the pair's floor.
  """
end
