\ ttester-ext.4th — extensions for ttester.
\
\ ttester.4th itself is kept identical to the Hayes / Anton Ertl upstream so
\ this fork can track future revisions.  All additions live in this separate
\ file.
\
\ Adds:
\   expect-true           ( f -- )            assert f <> 0
\   expect-false          ( f -- )            assert f = 0
\   expect-eq             ( a b -- )          assert a = b
\   expect-not-eq         ( a b -- )          assert a <> b
\   expect-depth          ( n -- )            assert depth (below n) = n
\   expect-stack-clean    ( -- )              assert depth = 0
\   expect-stack-balanced ( -- )              assert depth = START-DEPTH
\   expect-str-eq         ( a1 u1 a2 u2 -- )  assert COMPARE = 0
\
\ Fixture hooks for repetitive setup/teardown (e.g. project-new / project-drop):
\   DEFER test-setup
\   DEFER test-teardown
\   TS{ ... }ST        like T{ ... }T but runs test-setup before and
\                      test-teardown after the block
\
\ All assertions route through ttester's vectored ERROR, so the existing
\ #ERRORS counter and ERROR-XT hook keep working unchanged.
\
\ Usage:
\   require ttester.4th
\   require ttester-ext.4th
\
\   T{ true  expect-true  -> }T
\   T{ 1 2 + 3 expect-eq -> }T
\   T{ s" abc" s" abc" expect-str-eq -> }T
\
\   :noname project-new ; is test-setup
\   :noname project-drop ; is test-teardown
\   TS{ project.name@ s" foo" expect-str-eq -> }ST

BASE @
DECIMAL

[IFUNDEF] expect-true

: expect-true  ( f -- )
    0= IF s" EXPECTED TRUE BUT GOT FALSE: " ERROR THEN ;

: expect-false ( f -- )
       IF s" EXPECTED FALSE BUT GOT TRUE: " ERROR THEN ;

: expect-eq    ( a b -- )
    <> IF s" EXPECTED EQUAL CELLS: " ERROR THEN ;

: expect-not-eq ( a b -- )
    =  IF s" EXPECTED CELLS TO DIFFER: " ERROR THEN ;

\ ( n -- )
\ Asserts that the stack BELOW n has exactly n cells.  DEPTH at entry
\ counts n itself, so we subtract one before comparing.  After the
\ assertion n is consumed and the original stack is preserved.
: expect-depth ( n -- )
    DEPTH 1- <> IF s" UNEXPECTED STACK DEPTH: " ERROR THEN ;

: expect-stack-clean ( -- )
    DEPTH IF s" STACK NOT EMPTY: " ERROR THEN ;

: expect-stack-balanced ( -- )
    DEPTH START-DEPTH @ <> IF
        s" STACK NOT BALANCED (DEPTH /= START-DEPTH): " ERROR
    THEN ;

: expect-str-eq ( a1 u1 a2 u2 -- )
    COMPARE 0<> IF s" STRINGS NOT EQUAL: " ERROR THEN ;

\ --- fixture hooks --------------------------------------------------------

DEFER test-setup
DEFER test-teardown
' noop IS test-setup
' noop IS test-teardown

: TS{ test-setup T{ ;
: }ST }T test-teardown ;

[THEN]

BASE !
\ end of ttester-ext.4th
