\ tests/test_utils.4th
\ Тестирование базовых функций fmix_utils.4th

require ../fmix_utils.4th

: assert-equal ( addr1 u1 addr2 u2 -- )
    2over 2over compare 0= invert IF
        cr s" [FAIL]" type cr
        s"   Expected: '" type type s" '" type cr
        s"   Got:      '" type type s" '" type cr
        bye
    ELSE
        2drop 2drop s" ." type
    THEN ;

: test-concat
    cr s" Test 1: str-concat... " type
    s" Hello" s"  World" str-concat
    s" Hello World" assert-equal
    
    \ Проверка на пустые строки
    s" A" s" " str-concat s" A" assert-equal
    s" " s" B" str-concat s" B" assert-equal
;

: test-fs-join
    cr s" Test 2: fs-join... " type
    s" path" s" file" fs-join
    s" path/file" assert-equal
    
    s" /abs/path" s" file.txt" fs-join
    s" /abs/path/file.txt" assert-equal
;

: test-vars-safety
    cr s" Test 3: Variables safety... " type
    \ Проверяем, что вложенные вызовы не ломают глобальные переменные конкатенации
    s" part1" 
    s" part2" s" part3" str-concat 
    str-concat
    s" part1part2part3" assert-equal
;

test-concat
test-fs-join
test-vars-safety
cr s" [ALL PASS] Utils are safe." type cr
bye
