# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 1025, "Model memory arithmetic", :published do
  feature "capacity planning"
  attest_in :none

  prose ~S"""
  :: decision
  Compute the memory from the parameter count. RFD 1026 records the
  result per model.
  :: problem
  RFD 1016 says what each model is. It does not say what each model
  costs. A reader cannot size a machine from the inventory alone.
  :: section The rule
  bf16 holds one parameter in 2 bytes. The weight bytes are therefore
  the parameter count multiplied by 2.

  ```
  weight bytes = parameters x 2
  weight GB    = parameters in billions x 2
  ```

  This document counts 1 GB as 1,000,000,000 bytes. The GiB figure is
  smaller by 7 percent.

  See `DETAILS.md` for the three costs that come after the weights,
  and the safe rule for one resident model.
  :: related
  RFD 1016 lists the models. RFD 1026 applies this rule to each one.
  RFD 1034 checks the rule against a measured model.
  """

  details_title "Model memory arithmetic"

  details_preamble ~S"""
  - The load transient. A loader that reads the file into host memory,
    and then copies to the device, holds two copies. A loader that maps
    the file, and copies direct to the device, holds one copy.
  - The runtime overhead. A CUDA context, the allocator, and the
    fragmentation add about 10 percent above the weights.
  - The activation peak. This depends on the batch size, the resolution,
    and the step count. It does not depend on the parameter count.

  The safe rule for one resident model is below.

  ```
  device memory = weight GB x 1.1 + activation peak
  ```
  """
end
