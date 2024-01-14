ZX-Uno for MEGA65 on different MEGA65 models
============================================

Choose the right core variant for your hardware
-----------------------------------------------

### TL;DR

If your MEGA65 was manufactured before 2024, then choose
`@zxuno-V1.2-R3.cor` otherwise choose `zxuno-V1.2-R6.cor`.

### Details

We are supporting these MEGA65 models: R3/R3A, R4, R5 and R6. Use
the following table to ensure that you select and flash the correct `.cor`
from the [ZIP file](https://files.mega65.org?id=bdaeb7e0-9fc8-4185-99de-104d01229f27).

| MEGA65 model   |   Years   | File name         | Comment
|:--------------:|:---------:|:-----------------:|-------------------------
| R2             | 2019-2020 | <Use V0.8>        | R2 is a very rare pre-series model, only 20 of them were built. We are not supporting the R2 any more, but you can still use Version 0.8 of the ZX-Uno core on R2: https://github.com/sy2002/zxuno4mega65/tree/master/bin/Version%200.8/R2
| R3/R3A         | 2020-2023 | zxuno-v1.2-r3.cor | R3 is the "DevKit" (100 were built) and R3A are batches 1 and 2. If your MEGA65 was manufactured before 2024 then you have an R3 or R3A machine.
| R4             | 2023      | zxuni-v1.2-r4.cor | Development board on our way to the R6. Only 10 of them were manufactured (board only, no complete machines).
| R5             | 2023      | zxuno-v1.2-r6.cor | Upgraded version of R4 that contains new circuits for the expansion port. Only 10 of them were manufactured (board only, no complete machines). R6 bitstreams can be used on R5 boards.
| R6             | 2024+     | zxuno-v1.2-r6.cor | Latest and greatest MEGA65. Manufactured from 2024 on.

Only use `*.bit` files if you know what you are doing.
