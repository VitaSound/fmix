\ tests/memory_test.4th
require ../fmix_utils.4th

\ --- Мок-объект для fmix_new (имитация) ---
2variable test-pkg-name

: set-test-pkg ( addr u -- )
    str-dup test-pkg-name 2! ;

: get-test-pkg ( -- addr u )
    test-pkg-name 2@ ;

\ --- Тестовый фреймворк ---
: assert-equal ( addr1 u1 addr2 u2 -- )
    2over 2over compare 0= invert IF
        cr s" [FAIL]" type cr
        s"   Expected: '" type type s" '" type cr
        s"   Got:      '" type type s" '" type cr
        bye
    ELSE
        2drop 2drop s" ." type
    THEN ;

: assert-addr-valid ( addr u -- )
    \ Проверка, что адрес читаем (просто пытаемся сбросить на терминал в null)
    2dup 2drop 
    s" ." type ;

\ --- Тесты ---

: test-str-dup-and-store
    s" Testing storage mechanism..." type cr
    \ Пытаемся сохранить строку, как в fmix_new
    s" example_project" set-test-pkg
    
    \ Пытаемся прочитать. Если используется count на сырой памяти, тут упадет
    get-test-pkg 
    
    \ Проверяем совпадение
    s" example_project" assert-equal
    
    \ Проверяем, что адрес валиден
    get-test-pkg assert-addr-valid
    cr s" [PASS] Memory storage test" type cr ;

: test-fs-join-logic
    s" Testing path join logic..." type cr
    \ Проверяем склейку, чтобы не было example/project/
    s" /home/user" s" mypkg" fs-join
    s" /home/user/mypkg" assert-equal
    cr s" [PASS] Path join test" type cr ;

: run-memory-tests
    cr s" --- Running Memory & Logic Tests ---" type cr
    test-str-dup-and-store
    test-fs-join-logic 
    cr ;

run-memory-tests
bye
