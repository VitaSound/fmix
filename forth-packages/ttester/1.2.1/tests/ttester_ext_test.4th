\ tests/ttester_ext_test.4th
\ Exercises every predicate and fixture hook added by ttester-ext.4th.
\ Run with: fmix test  (must pick this up from ./tests/).

require ../ttester.4th
require ../ttester-ext.4th

\ -------------------------------------------------------------------------
\ Reset error counter so we count only our own assertions.
\ -------------------------------------------------------------------------
0 #ERRORS !

\ --- expect-true / expect-false ------------------------------------------

T{ true  expect-true  -> }T
T{ -1    expect-true  -> }T
T{ 42    expect-true  -> }T
T{ false expect-false -> }T
T{ 0     expect-false -> }T

\ --- expect-eq / expect-not-eq -------------------------------------------

T{ 1 1     expect-eq      -> }T
T{ -7 -7   expect-eq      -> }T
T{ 1 2     expect-not-eq  -> }T
T{ 0 1     expect-not-eq  -> }T

\ --- expect-depth --------------------------------------------------------

T{ 0 expect-depth         -> }T
T{ 1 1 expect-depth       -> 1 }T
T{ 1 2 3 3 expect-depth   -> 1 2 3 }T

\ --- expect-str-eq -------------------------------------------------------

T{ s" abc" s" abc"        expect-str-eq -> }T
T{ s" "    s" "           expect-str-eq -> }T
T{ s" hello world" s" hello world" expect-str-eq -> }T

\ --- expect-stack-balanced (inside T{) -----------------------------------

T{ 1 2 3 drop drop drop expect-stack-balanced -> }T

\ Sanity: by this point all the above assertions were supposed to pass.
\ If #ERRORS is non-zero, something in ttester-ext is broken.
T{ #ERRORS @ -> 0 }T

\ -------------------------------------------------------------------------
\ Negative tests: each block intentionally triggers exactly one ERROR.
\ Re-zero #ERRORS, then check the count grows as expected.
\ -------------------------------------------------------------------------

0 #ERRORS !

\ Silence the error report so test output stays clean.  Stash the original
\ ERROR-XT on the return stack, replace it with a silent 2drop noname.
ERROR-XT @ >r
:noname 2drop ; ERROR-XT !

T{ false expect-true   -> }T
T{ true  expect-false  -> }T
T{ 1 2   expect-eq     -> }T
T{ 7 7   expect-not-eq -> }T
T{ 5 expect-depth      -> }T       \ depth = 0, expected 5
T{ s" abc" s" xyz" expect-str-eq -> }T

\ Restore the original error reporter before checking the count.
r> ERROR-XT !

T{ #ERRORS @ -> 6 }T

\ Re-zero so the rest of the file starts clean.
0 #ERRORS !

\ --- fixture hooks: TS{ ... }ST ------------------------------------------

variable setup-count    0 setup-count !
variable teardown-count 0 teardown-count !

:noname 1 setup-count    +! ; is test-setup
:noname 1 teardown-count +! ; is test-teardown

TS{                 -> }ST
TS{ 1 2 +           -> 3 }ST
TS{ s" hi"  drop drop -> }ST

T{ setup-count    @ -> 3 }T
T{ teardown-count @ -> 3 }T

\ Reset hooks so they don't leak into the next test file (in --shared mode).
' noop is test-setup
' noop is test-teardown

T{ #ERRORS @ -> 0 }T

: report-results
    #ERRORS @ 0= IF
        cr ." ttester_ext_test ok" cr
    ELSE
        cr ." ttester_ext_test FAILED: " #ERRORS @ . ." errors" cr
        1 (bye)
    THEN ;
report-results

bye
