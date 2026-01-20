\ tests/internal_test.4th
require ../fmix_utils.4th

: assert-equal ( addr1 u1 addr2 u2 -- )
    2over 2over compare 0= invert IF
        s" [FAIL]" type cr
        s"   Expected: '" type type s" '" type cr
        s"   Got:      '" type type s" '" type cr
        bye
    ELSE
        2drop 2drop \ Удаляем строки из стека, если всё ок
        s" [PASS]" type cr
    THEN ;

: test-fs-join
    s" Test fs-join: " type
    s" /home/user" s" project" fs-join
    s" /home/user/project" assert-equal ;

: run-internal-tests
    cr s" --- Running Internal Tests ---" type cr
    test-fs-join 
    cr ;

run-internal-tests
bye
