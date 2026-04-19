# Ping-Pong Fused Tile Sanity

Targeted 128-chunk ping-pong fused tile confirmation after a short cooldown. This is not a replacement publication artifact.

| Size | Mode | Median GiB/s | Min GiB/s | P95 GiB/s | Max GiB/s | Correct |
| --- | --- | ---: | ---: | ---: | ---: | --- |
| 512.0 MiB | resident-gpu | 75.08059414385893 | 69.87103623358223 | 80.19138154353654 | 80.19138154353654 | ok |
| 512.0 MiB | staged-gpu | 23.794945795783505 | 23.176224642139392 | 24.67450259780566 | 24.67450259780566 | ok |
| 512.0 MiB | wrapped-gpu | 47.770061496573256 | 44.77428165261873 | 51.93725979017347 | 51.93725979017347 | ok |
| 1.0 GiB | resident-gpu | 71.24879944167424 | 69.8183849262107 | 84.5260951496729 | 84.5260951496729 | ok |
| 1.0 GiB | staged-gpu | 23.67888598792659 | 23.15960732885774 | 24.315394594235517 | 24.315394594235517 | ok |
| 1.0 GiB | wrapped-gpu | 43.28137945671646 | 42.374601477466754 | 49.11631401316926 | 49.11631401316926 | ok |

jsonValidation=ok path=benchmarks/results/20260419T105700Z-pingpong-rested-sanity/pingpong-rested.json
