\ fmix_test.4th
\ Этот файл должен лежать рядом с fmix.4th
require fmix_utils.4th

2VARIABLE test-path
variable wdirid
create test-buff 255 allot

: get-test-path
    test-path 2@ ;

: test-file-operate 
    get-test-path 2swap fmix.fs-join 
    2dup type cr
    included 
    ;

: test-file-filter

    2dup s" _test." search 
    IF
        2drop
        s" * Test file: " type
        test-file-operate
    ELSE
        2drop 2drop
    THEN ;

: test-read-dir
    get-test-path open-dir

    0= IF
        wdirid !
        BEGIN
            test-buff 255 wdirid @ read-dir throw
        WHILE
            test-buff swap
            test-file-filter
        REPEAT
        wdirid @ close-dir throw
    ELSE
        s" [ERROR] Cannot open ./tests directory" type cr
    THEN ;

: fmix.test
    cr s" * Start Tests" type cr
    s" PWD" getenv s" /tests" s+ test-path 2!
    test-read-dir ;
