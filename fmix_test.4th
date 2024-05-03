create test_buff 255 allot
create test_path 255 allot
variable wdirid

: test_get_path
    test_path $@
;

: test_file_operate
    test_get_path 2swap s+
    \ 2dup
    type cr
    \ included
;

: test_file_filter
    2dup
    s" _test." search 
    0= invert IF
        2DROP
        s" * Test file: " type
        test_file_operate
    ELSE
        2DROP
        2DROP
    THEN
;

: test_read_dir
    test_get_path open-dir

    0= IF
        wdirid !

        begin
            test_buff 255 wdirid @ read-dir 

            rot test_buff swap test_file_filter
            drop
        0= until
    ELSE
        s" ERROR of read ./tests directory" type cr
    THEN
;

: fmix.test
    cr
    s" * Start Tests" type cr

    s" PWD" getenv
    s" /tests/" s+ test_path $!
    test_read_dir


;
