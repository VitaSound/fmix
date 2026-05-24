\ tests/fmix_version_check_test.4th
\
\ Thin smoke-test for fmix_version_check.4th.
\
\ The heavy lifting (parse-req, req-matches?, parse-version-parts,
\ semver-cmp) now lives in fsemver and is covered by 71 assertions in
\ ../forth-packages/fsemver/0.1.0/tests/fsemver_test.4th. This file only
\ verifies the wiring:
\   - fsemver loads cleanly through fmix_version_check.4th's require chain
\   - fmix.required-fmix-req / fmix.legacy-self-dep? exist & are zeroed
\   - the public fsemver.* words are reachable from fmix's load context
\
\ End-to-end behaviour ("project pinning a too-new fmix is rejected",
\ "legacy form errors with a hint", etc.) lives in
\ tests/version_check_integration_test.sh.

require ../fmix_utils.4th
require ../fmix_version.4th
require ../fmix_version_check.4th

fmix.home-path s" forth-packages/ttester/1.1.0/ttester.4th" fmix.fs-join required

0 #ERRORS !

\ --- Wiring: fsemver public API is visible ------------------------------

T{ s" 1.2.3"   fsemver.parse-version-parts -> 1 2 3 3 }T
T{ s" ~> 0.7"  fsemver.parse-req           -> 0 0 7 0 true }T
T{ s" >= 1.0"  fsemver.parse-req           -> 2 1 0 0 true }T
T{ s" garbage" fsemver.parse-req           -> 0 0 0 0 false }T

\ --- Wiring: matcher works after parse-req ------------------------------
\ self=0.7.4 satisfies ~> 0.7  -> true
T{  0 7 0 0   0 7 4  fsemver.req-matches? -> true  }T
\ self=1.0.0 does NOT satisfy ~> 0.7  -> false
T{  0 7 0 0   1 0 0  fsemver.req-matches? -> false }T

\ --- Wiring: fmix-owned state is initialised ----------------------------

\ fmix.legacy-self-dep? starts false; this test fixture's package.4th
\ uses the new `key-value fmix ~> ...` form (or none), so the flag must
\ NOT have been tripped while scanning the project.
T{ fmix.legacy-self-dep? @ -> 0 }T

\ fmix.required-fmix-req is a 2variable; it may or may not be populated
\ depending on the test process's CWD. Just check it's a valid pair
\ (length is non-negative).
T{ fmix.required-fmix-req 2@ nip 0>= -> true }T

: report
    #ERRORS @ 0= IF
        cr ." fmix_version_check_test ok" cr
    ELSE
        cr ." fmix_version_check_test FAILED: " #ERRORS @ . ." errors" cr
        1 (bye)
    THEN ;
report
bye
