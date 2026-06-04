require ../fmix_utils.4th
fmix.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmix.fs-join required

\ see examples:
\ https://forth-standard.org/standard/testsuite

T{ 1 2 3 SWAP -> 1 3 2 }T
