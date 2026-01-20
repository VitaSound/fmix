\ fmix_test.4th
\ Этот файл должен лежать рядом с fmix.4th
require fmix_utils.4th
require ~/fmix/forth-packages/ttester/1.1.0/ttester.4th

2VARIABLE test-path
variable wdirid
create test-buff 255 allot
VARIABLE fmix.ERRORS 0 fmix.ERRORS !
VARIABLE fmix.ERROR 0 fmix.ERROR !

: fail-fast-error ( addr u -- )
    s" ERROR" type cr
    type cr
    SOURCE TYPE CR

    1 fmix.ERRORS +!
    1 fmix.ERROR !
    ;

' fail-fast-error ERROR-XT !


: get-test-path
    test-path 2@ ;

: test-file-operate 
    get-test-path 2swap fmix.fs-join 
    2dup type
    s"  - " type

    0 fmix.ERROR !

    included 

    fmix.ERROR @ 0= IF
        s" OK" type cr
    THEN
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
    fmix.param-arg 2@

    0= IF
        drop

        cr s" * Start Tests" type cr
        s" PWD" getenv s" /tests" s+ test-path 2!
        test-read-dir
    ELSE
        drop
        cr s" * Start Tests for one file: " type
        s" PWD" getenv test-path 2!
        fmix.param-arg 2@ test-file-operate
    THEN 
    
    fmix.ERRORS @ 0= IF
        cr s" * All tests passed successfully." type cr
    ELSE
        cr s" * Some tests failed. Total errors: " type
        fmix.ERRORS @ . cr
    THEN

    ;
