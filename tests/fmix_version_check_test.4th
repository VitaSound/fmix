\ tests/fmix_version_check_test.4th
\ Unit tests for the semver parser/comparator in fmix_version_check.4th.
\ The integration test (a fixture project that requires fmix 99.0.0 and
\ must be rejected by `fmix test` / `fmix packages.get`) lives in
\ tests/fixtures/version_check/ and is exercised by
\ tests/version_check_integration_test.sh.

require ../fmix_utils.4th
require ../fmix_version.4th
require ../fmix_version_check.4th

fmix.home-path s" forth-packages/ttester/1.1.0/ttester.4th" fmix.fs-join required

0 #ERRORS !

\ --- parse-semver --------------------------------------------------------

T{ s" 0.0.0"   fmix.parse-semver -> 0 0 0 }T
T{ s" 1.2.3"   fmix.parse-semver -> 1 2 3 }T
T{ s" 0.5.1"   fmix.parse-semver -> 0 5 1 }T
T{ s" 10.0.0"  fmix.parse-semver -> 10 0 0 }T
T{ s" 0.20.7"  fmix.parse-semver -> 0 20 7 }T

\ Tolerant of missing components — pad with 0.
T{ s" 1"       fmix.parse-semver -> 1 0 0 }T
T{ s" 1.2"     fmix.parse-semver -> 1 2 0 }T

\ Tolerant of garbage — never crashes, just yields some best-effort value.
T{ s" "        fmix.parse-semver -> 0 0 0 }T
T{ s" abc"     fmix.parse-semver -> 0 0 0 }T

\ --- semver-cmp ----------------------------------------------------------

T{ 0 0 0  0 0 0  fmix.semver-cmp ->  0 }T
T{ 1 2 3  1 2 3  fmix.semver-cmp ->  0 }T

T{ 1 0 0  1 0 1  fmix.semver-cmp -> -1 }T
T{ 1 0 1  1 0 0  fmix.semver-cmp ->  1 }T

T{ 0 5 0  0 5 1  fmix.semver-cmp -> -1 }T
T{ 0 5 1  0 5 0  fmix.semver-cmp ->  1 }T

T{ 0 9 9  1 0 0  fmix.semver-cmp -> -1 }T
T{ 1 0 0  0 9 9  fmix.semver-cmp ->  1 }T

T{ 0 4 0  0 10 0  fmix.semver-cmp -> -1 }T
T{ 0 10 0  0 4 0  fmix.semver-cmp ->  1 }T

\ Composing parse + cmp for real-world strings.
T{ s" 0.5.1" fmix.parse-semver s" 0.5.1" fmix.parse-semver fmix.semver-cmp ->  0 }T
T{ s" 0.5.0" fmix.parse-semver s" 0.5.1" fmix.parse-semver fmix.semver-cmp -> -1 }T
T{ s" 0.6.0" fmix.parse-semver s" 0.5.1" fmix.parse-semver fmix.semver-cmp ->  1 }T
T{ s" 1.0.0" fmix.parse-semver s" 0.99.99" fmix.parse-semver fmix.semver-cmp -> 1 }T

: report
    #ERRORS @ 0= IF
        cr ." fmix_version_check_test ok" cr
    ELSE
        cr ." fmix_version_check_test FAILED: " #ERRORS @ . ." errors" cr
        1 (bye)
    THEN ;
report
bye
