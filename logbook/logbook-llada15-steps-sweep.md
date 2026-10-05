# Logbook: LLaDA-1.5 denoising steps against speed and coherence (2026-08-31)

**Related:** RFD 2198 (LLaDA-o speed work). The measurement was first kept in the
`interactor-llada-diffusion-lm` README at `fb75914` and moved here when that README was cut
back to what the repository is.

## Question

How far can LLaDA-1.5's denoising steps be cut, at a fixed output length, before the text
stops being coherent?

## Apparatus

- Model: `GSAI-ML/LLaDA-1.5`, 8B parameters, bf16, on one 24 GB desktop GPU, loaded through
  `patch_llada.apply()` for the current transformers API.
- Script: `sweep_steps.py` in `interactor-llada-diffusion-lm` at `fb75914`. One fixed chat
  prompt, `gen_length` 128, `block_length` `min(32, steps)`, steps 128, 64, 32 and 16. Wall
  time is taken between `torch.cuda.synchronize()` calls.
- Floor: steps 128 is one token per forward pass, the autoregressive pass count.

## Result

| steps | tokens per pass | wall s | tok/s |
|------:|----------------:|-------:|------:|
|   128 |               1 |    9.5 |  13.5 |
|    64 |               2 |    4.5 |  28.6 |
|    32 |               4 |    2.3 |  56.6 |
|    16 |               8 |    1.1 | 113.8 |

The text is coherent through 64 steps. At 32 steps trailing repetition appears, and at 16
steps the output collapses. Coherence was read by eye on one prompt, so 64 steps (about 2.1
times the floor's speed) is the usable point for that prompt and not a measured distribution.

Unchecked: more than one prompt, any seed other than the script's default, and any scored
quality metric.
