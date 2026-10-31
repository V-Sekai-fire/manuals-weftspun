# Copyright (c) 2026 K. S. Ernest (iFire) Lee
# SPDX-License-Identifier: MIT
use RFD.DSL

rfd 1025, "Model memory arithmetic", :published do
  feature "capacity planning"
  attest_in :none

  prose ~S"""
  :: hook
  Size a machine from a model's parameter count.
  :: intrigue
  RFD66606-1016 says what each model is. It does not say what each model costs.
  :: exit
  Look up the model in `DETAILS.md`, then apply the safe rule for one resident model.
  :: decision
  Compute the memory from the parameter count. Apply the rule to each catalog model, and
  treat the estimated rows as an upper bound for planning.
  :: problem
  A reader cannot size a machine from the inventory alone. The backend must decide which
  models stay resident, and that decision needs a number per model.
  :: section The rule
  bf16 holds one parameter in 2 bytes. The weight bytes are therefore
  the parameter count multiplied by 2.

  ```
  weight bytes = parameters x 2
  weight GB    = parameters in billions x 2
  ```

  This document counts 1 GB as 1,000,000,000 bytes. The GiB figure is
  smaller by 7 percent.
  :: related
  RFD66606-1016 lists the models. RFD66606-1027 gives the totals and the consequence.
  RFD66606-1030 breaks down the See-Through row. RFD66606-1034 checks the rule against a
  measured model.
  """

  details_title "Model memory arithmetic"

  prose ~S"""
  :: details_preamble
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
  :: details bf16 memory per model
  Prefer `measured` over every other source, and prefer bf16 over fp16 where a checkpoint
  offers both. The two formats cost the same memory, and bf16 carries the wider exponent
  range.

  RFD66606-1027 permits two formats. bf16 holds one parameter in 2 bytes, and
  Q4_K_M holds one in about 0.55 bytes. The table gives both, per model.

  The Source column says where each number comes from. `published` means
  the model card states the count. `measured` means this document read
  the checkpoint sizes. `estimated` means this document derives the
  count from the architecture. `unknown` means no count is available
  yet.

  | Model id                        | Parameters |     bf16 |   Q4_K_M | Source    |
  | ------------------------------- | ---------: | -------: | -------: | --------- |
  | qwen_q4_k_m_image_edit          |     27.0 B |  54.0 GB | 14.85 GB | published |
  | krea2_turbo_text_to_image       |     16.9 B |  33.8 GB |  9.30 GB | estimated |
  | pixal3d_image_to_textured_mesh  |    12.02 B | 24.05 GB |  6.61 GB | measured  |
  | seethrough_layer_decomposition  |      4.9 B |   9.8 GB |  2.70 GB | estimated |
  | trellis2_image_to_textured_mesh |      4.0 B |   8.0 GB |  2.20 GB | estimated |
  | trellis_image_to_textured_mesh  |      1.8 B |   3.6 GB |  0.99 GB | estimated |
  | worldmirror2_reconstruct        |      1.2 B |   2.4 GB |  0.66 GB | estimated |
  | triposplat_image_to_splat       |      1.1 B |   2.2 GB |  0.61 GB | estimated |
  | skintokens_auto_rig             |      0.5 B |   1.0 GB |  0.28 GB | estimated |
  | p3sam_mesh_segmentation         |      0.4 B |   0.8 GB |  0.22 GB | estimated |
  | kimodo_text_to_motion           |      0.3 B |   0.6 GB |  0.17 GB | estimated |
  | unirig_auto_rig                 |    0.125 B |  0.25 GB |  0.07 GB | estimated |
  | lingbot_map_environment_scan    |    unknown |  unknown |  unknown | unknown   |
  | voxhammer_text_mesh_editing     |          0 |        0 |        0 | published |
  | voxhammer_image_mesh_editing    |          0 |        0 |        0 | published |
  | weftspun_image_to_world         |          0 |        0 |        0 | composite |

  VoxHammer carries no weights of its own. It edits with the TRELLIS.2
  backbone, thus its cost is the TRELLIS.2 cost.
  `weftspun_image_to_world` runs TripoSplat and then TRELLIS.2. Its cost
  is the sum of those two. RFD66606-1033 covers the geometric algorithms,
  which hold no weights at all.

  The blocklisted Hunyuan models add 9.2 GB. The shape model holds
  3.3 B parameters, which is 6.6 GB. The paint model holds 1.3 B
  parameters, which is 2.6 GB.
  """
end
