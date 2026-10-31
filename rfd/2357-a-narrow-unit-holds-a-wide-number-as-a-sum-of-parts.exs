# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 2357, "A narrow unit holds a wide number as a sum of parts", :discussion do
  feature "numeric precision for kernels on float32 and bf16 units"
  scope "df32 guest geometry, and f32 matrix products on bf16 units such as a TPU."
  attest_in :details

  prose ~S"""
  :: hook
  A narrow unit gives wide precision when each number is split into parts it can hold.
  :: intrigue
  A float32 coordinate 3.8e8 m from the origin cannot hold a 1 mm step, and a bf16 unit holds 8
  bits of mantissa.
  :: exit
  Record the measured error of a kernel before it claims float32 or df32 accuracy.
  :: decision
  A TPU computes a float32 product as 3 or 6 bf16 passes. A df32 pair computes a wide
  coordinate as a high and a low float32. Both split a number into a sum of narrow parts.

  1. A kernel that needs more precision than its unit holds splits the operands into parts
     and sums the products of the parts, smallest first.
  2. A kernel states its part count: 1, 2 or 3 bf16 parts, or one df32 pair.
  3. Each part count carries a measured error against a float64 reference, and a control
     that fails when the count drops by one.
  :: problem
  RFD66606-2392 chose df32 for the first. This RFD adds the second and puts both under one rule
  with one set of measured bounds.
  :: related
  RFD66606-2392 chooses df32 for guest geometry. RFD66606-1025 gives the bf16 memory
  arithmetic. The BLOCKLIST row on XLA and PJRT keeps the Cloud TPU route open.
  """

  details_title "A narrow unit holds a wide number as a sum of parts"

  prose ~S"""
  :: details What the TPU library states
  The array library that drives Cloud TPU documents its matrix precision setting in its
  source, read from the main branch at the time of writing. The setting changes
  float32 computations only and leaves the input and output types alone.

  - `DEFAULT`: on TPU, float32 computations run in bfloat16.
  - `HIGH`: on TPU, float32 computations run in 3 bfloat16 passes.
  - `HIGHEST`: on TPU, float32 computations run in 6 bfloat16 passes.

  The dot algorithm presets name the same idea: `BF16_BF16_F32_X3`, `BF16_BF16_F32_X6` and
  `BF16_BF16_F32_X9` use 3, 6 and 9 operations to emulate higher precision, and a float8
  preset decomposes each operand into an initial term and a residual term.

  The source does not state which products the 3 and 6 pass modes keep, and no TPU ran
  for this RFD. The host measurement below chooses the usual split: 2 parts keep the 3
  products whose part indexes sum to at most 1, 3 parts keep the 6 whose indexes sum to at
  most 2, and 9 keeps all products of 3 parts.
  :: details The split rule
  A part is the operand rounded to bf16. The residual is the operand minus the part, exact in
  float32. The next part is the residual rounded to bf16, and so on. Three bf16 parts hold
  3 times 8 bits, which covers the 24 bit float32 mantissa.

  A product of two bf16 values is exact in float32. The sum of the kept products runs in
  float32, smallest products first, so the large products do not drown the small ones.

  df32 is the same split one level up. The high part is the float32 value and the low part
  is the float32 residual of a float64. `two_sum`, `quick_two_sum` and `two_prod` carry the
  rounding error of each operation into the low part, as RFD66606-2392 lists.
  :: details Measured on the host
  A host emulation, not a TPU. Matrices 64 by K times K by 64, standard normal entries, 8
  seeds. Error is the norm of the difference from a float64 product, over the norm of that
  product. Median over the seeds, with the maximum in brackets.

  | product                    | K = 256              | K = 4096             |
  | -------------------------- | -------------------- | -------------------- |
  | 1 bf16 part                | 2.3e-3 (2.4e-3)      | 2.4e-3 (2.4e-3)      |
  | 3 products, 2 parts (X3)   | 4.4e-6 (4.6e-6)      | 4.4e-6 (4.6e-6)      |
  | 6 products, 3 parts (X6)   | 9.6e-8 (9.9e-8)      | 1.2e-7 (1.2e-7)      |
  | 9 products, 3 parts (X9)   | 9.6e-8 (9.9e-8)      | 1.2e-7 (1.2e-7)      |
  | float32 host product       | 2.5e-7 (2.6e-7)      | 2.4e-7 (2.4e-7)      |

  Each step up the table lowers the error, from 2.3e-3 to 1.2e-7 over three steps. The 3 part
  products sit at the float32 rounding floor of 1.2e-7 (the float32 epsilon), and the ninth
  product adds nothing over the sixth here. The host float32 product is a blocked product with
  its own rounding, so a TPU accumulator can differ from every row.

  Control: the 1 bf16 part row is 520 times above the 2 part row, so a bound of 1e-5 fails a
  kernel that dropped to 1 part and passes the X3 row.
  :: details df32 at the Moon distance
  A position 3.8e8 m from the origin, moved 1000 times by 1 mm. Float32 spacing there is
  32 m, some 480 soda cans.

  - float32: 1.0 m after 1000 steps, about 15 soda cans. Placing 20000 random positions
    errs by 16 m at most.
  - df32: 9.3e-6 m after 1000 steps, 1/80 of a credit card. Placing the same positions
    errs by 4.8e-7 m at most.

  The float32 position did not move at all: each 1 mm step rounds away. The df32 position
  kept the steps. The placement error ratio is about 3.4e7 to 1.
  :: details Method
  The bf16 round is round to nearest even on the upper 16 bits of a float32. Parts come from
  the residual rule above. Products and sums ran in float32 on the host with numpy. The df32
  steps use `two_sum` and `quick_two_sum` on float32 scalars. The numbers above are the output
  of a short script that is not committed; the kernels that RFD66606-2392 lists are the place
  for a permanent gate.
  :: details What is not known
  - The error of a real TPU product at each precision setting. The first step is one run on a
    Cloud TPU with the same shapes and seeds, compared with the host table.
  - Which products the 3 and 6 pass modes keep. The first step is the compiler's own text for
    the dot, read from a lowered program.
  - Whether the part count a kernel needs follows its inputs' range as well as its size. The
    first step is the same table over inputs with a wide exponent spread.
  - The cost of each part count in time. No timing ran.
  """
end
