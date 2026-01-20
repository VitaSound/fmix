require ~/fmix/forth-packages/ttester/1.1.0/ttester.4th

\ see examples:
\ https://forth-standard.org/standard/testsuite


T{ 1 2 3 SWAP -> 1 3 22 }T
T{ 1 2 3 SWAP -> 1 3 223 }T
