# project_bias

A high-performance, bias-free cryptographic stream engine written in Ada and formally verified with SPARK.
The engine guarantees zero statistical bias when mapping raw entropy into custom alphabets by discarding modulo-biased values,
drawing security bytes directly from native OS kernel pools.

## Verification Level
* **SPARK Level 4 (Formal Verification):** Fully proven to ensure absence of run-time errors (AoRTE) and compliance with functional contracts.
* **Toolchain Compatibility:** Validated using both GNAT/SPARK Pro 2021 and the latest community SPARK toolchains available via Alire.

## Core Architecture & Entropy Pools
The engine interfaces directly with low-level OS APIs via `Interfaces.C` to eliminate abstraction layers and latency:
* **ProcessPrng (Primary):** Utilizes the modern User-Mode OS Entropy Provider (`ProcessPrng`) as the main source of raw security bytes.
* **BCryptGenRandom (Fallback):** Implements a robust secondary fallback layer using the Windows CNG API (`bcrypt.dll`).

## Mathematical Bound For Truncation
```ada
-- Formula applied to enforce uniform distribution without modulo bias:
-- Formul = Charset'Length * (256 / Charset'Length) - 1
-- Any extracted byte > Formula'result = it is ruled out
```

## Structure
* `src/ProcessPrng_Wrapper.ad[s|b]`: Binding for the primary modern Windows Kernel PRNG.
* `src/BcryptGenRandom_Wrapper.ad[s|b]`: Secondary cryptographic fallback binding.
* `src/Chain_Generator.ad[s|b]`: Main state machine orchestrating bias-free extraction.
* `src/Math_Functions.ad[s|b]`: Formal pre/postconditions for mapping operations.

## Build and Run
```bash
alr run
```
