\ tests/step1_strings.4th
require ../fmix_utils.4th

: test-concat
    cr s" Test 1: Concatenation... " type
    s" Hello" s"  World" str-concat
    
    2dup s" Hello World" compare 0= IF
        s" OK" type cr
        drop free throw
    ELSE
        s" FAIL" type cr bye
    THEN
;

: test-join
    s" Test 2: Path Join... " type
    s" /home/user" s" project" fs-join
    
    2dup s" /home/user/project" compare 0= IF
        s" OK" type cr
        drop free throw
    ELSE
        s" FAIL" type cr 
        \ Вывод того, что получили, для отладки
        s" Got: '" type type s" '" type cr
        bye
    THEN
;

test-concat
test-join
bye
