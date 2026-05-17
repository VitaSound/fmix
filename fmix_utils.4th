\ fmix_utils.4th
\ Базовые утилиты. Исправлена логика системных вызовов.

[IFUNDEF] fmix.str-concat

\ --- Работа со строками ---

\ соединить две строки в одну новую
: fmix.str-concat { a1 u1 a2 u2 -- a3 u3 }
    u1 u2 + allocate throw { mem }
    a1 mem u1 move
    a2 mem u1 + u2 move
    mem u1 u2 + 
;

\ создать дубликат строки
: fmix.str-dup { a u -- a-new u }
    u allocate throw { mem }
    a mem u move
    mem u
;

: fmix.fs-join { path-a path-u name-a name-u -- full-a full-u }
    path-u 1 + name-u + allocate throw { mem }
    path-a mem path-u move
    s" /" drop mem path-u + 1 move
    name-a mem path-u + 1 + name-u move
    mem path-u 1 + name-u +
;

\ --- Валидация строк для shell ---

: fmix.all-chars? { addr u xt -- f }
    true u 0 ?do
        addr i + c@ xt execute 0= IF false unloop THEN
    loop ;

: fmix.validation-error-value { value-a value-u label-a label-u -- }
    cr s" [ERROR] Invalid " label-a label-u type type
    s" : " type value-a value-u type cr
    1 (bye) ;

: fmix.pkg-char-ok? { c -- f }
    c [char] _ = IF true EXIT THEN
    c [char] - = IF true EXIT THEN
    c [char] . = IF true EXIT THEN
    c bl = IF false EXIT THEN
    c 127 u> IF false EXIT THEN
    c '0 '9 1+ within IF true EXIT THEN
    c 'a 'z 1+ within IF true EXIT THEN
    c 'A 'Z 1+ within ;

: fmix.path-char-ok? { c -- f }
    c fmix.pkg-char-ok? IF true EXIT THEN
    c [char] / = ;

: fmix.url-char-ok? { c -- f }
    c fmix.pkg-char-ok? IF true EXIT THEN
    c [char] : = IF true EXIT THEN
    c [char] / = IF true EXIT THEN
    c [char] ? = IF true EXIT THEN
    c [char] = = IF true EXIT THEN
    c [char] % = IF true EXIT THEN
    c [char] @ = IF true EXIT THEN
    false ;

: fmix.sed-text-char-ok? { c -- f }
    c fmix.pkg-char-ok? IF true EXIT THEN
    c [char] / = IF true EXIT THEN
    false ;

: fmix.package-name-ok? { addr u -- f }
    true u 0 ?do
        addr i + c@ fmix.pkg-char-ok? 0= IF false unloop THEN
    loop ;

: fmix.path-ok? { addr u -- f }
    addr u 2dup s" .." search >r 2drop 2drop r> IF false EXIT THEN
    true u 0 ?do
        addr i + c@ fmix.path-char-ok? 0= IF false unloop THEN
    loop ;

: fmix.url-ok? { addr u -- f }
    true u 0 ?do
        addr i + c@ fmix.url-char-ok? 0= IF false unloop THEN
    loop ;

: fmix.validate-package-name ( addr u -- addr u )
    dup 0= IF 2drop s" (empty)" s" package name" fmix.validation-error-value THEN
    2dup fmix.package-name-ok? 0= IF s" package name" fmix.validation-error-value THEN ;

: fmix.validate-version ( addr u -- addr u )
    dup 0= IF 2drop s" (empty)" s" version" fmix.validation-error-value THEN
    2dup fmix.package-name-ok? 0= IF s" version" fmix.validation-error-value THEN ;

: fmix.validate-git-ref ( addr u -- addr u )
    dup 0= IF 2drop s" (empty)" s" git ref" fmix.validation-error-value THEN
    2dup fmix.path-ok? 0= IF s" git ref" fmix.validation-error-value THEN ;

: fmix.validate-git-url ( addr u -- addr u )
    dup 0= IF 2drop s" (empty)" s" git url" fmix.validation-error-value THEN
    2dup fmix.url-ok? 0= IF s" git url" fmix.validation-error-value THEN ;

: fmix.validate-path ( addr u -- addr u )
    dup 0= IF 2drop s" (empty)" s" path" fmix.validation-error-value THEN
    2dup fmix.path-ok? 0= IF s" path" fmix.validation-error-value THEN ;

: fmix.validate-sed-text { addr u -- addr u }
    true u 0 ?do
        addr i + c@ fmix.sed-text-char-ok? 0= IF
            s" sed replacement text" fmix.validation-error-value
        THEN
    loop ;

\ --- Системные утилиты ---

\ выполняет команду и проверяет код возврата
: system-checked ( addr u -- )
    system        \ выполняет команду (строка в формате Forth: addr u)
    $? 0<> IF     \ $? — системное слово, возвращает код возврата последней команды
                  \ если код ≠ 0 (ошибка) → заходим в тело IF
        s" [ERROR] Command failed" type cr
        1 (bye)   \ немедленно завершаем интерпретатор с кодом ошибки
    THEN ;

: get-home-path ( -- addr u )
    s" HOME" getenv s" /" fmix.str-concat ;

: fmix.home-path ( -- addr u )
    s" FMIX_HOME" getenv
    2dup nip 0= IF
        2drop s" HOME" getenv s" /fmix" fmix.str-concat
    THEN ;

: fmix.project-path ( -- addr u )
    pad 4096 get-dir fmix.str-dup ;

\ создать директорию с родительскими папками
: ensure-dir ( path u -- )
    2dup type cr
    $1FF mkdir-parents drop ;

\ заменить в файле вхождения строки FROM на TO
: replace-in-file { file-a file-u from-a from-u to-a to-u -- }
    file-a file-u fmix.validate-path drop drop
    from-a from-u fmix.validate-sed-text drop drop
    to-a to-u fmix.validate-sed-text drop drop
    \ Строим команду: sed -i 's#FROM#TO#g' FILE
    s" sed -i 's#" 
    from-a from-u fmix.str-concat
    s" #" fmix.str-concat
    to-a to-u fmix.str-concat
    s" #g' " fmix.str-concat
    file-a file-u fmix.str-concat
    
    system-checked 
;

\ копировать файл из src в dst
: cp-file { src-a src-u dst-a dst-u -- }
    src-a src-u fmix.validate-path drop drop
    dst-a dst-u fmix.validate-path drop drop
    s" cp " 
    src-a src-u fmix.str-concat
    s"  " fmix.str-concat
    dst-a dst-u fmix.str-concat
    
    system-checked
;

\ копировать директорию рекурсивно из src в dst
: cp-dir { src-a src-u dst-a dst-u -- }
    src-a src-u fmix.validate-path drop drop
    dst-a dst-u fmix.validate-path drop drop
    s" cp -r " 
    src-a src-u fmix.str-concat
    s"  " fmix.str-concat
    dst-a dst-u fmix.str-concat
    
    system-checked
;

2VARIABLE fmix.cmd-arg
2VARIABLE fmix.param-arg

: fmix.read_args
    next-arg 2drop 
    next-arg 
    2dup s" -e" compare 0= IF 2drop next-arg THEN
    fmix.str-dup fmix.cmd-arg 2!
    next-arg fmix.str-dup fmix.param-arg 2!
;

[THEN]
