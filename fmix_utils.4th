\ fmix_utils.4th
\ Базовые утилиты. Исправлена логика системных вызовов.

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

\ --- Системные утилиты ---

\ выполняет команду и проверяет код возврата
: system-checked ( addr u -- )
    system        \ выполняет команду (строка в формате Forth: addr u)
    $? 0<> IF     \ $? — системное слово, возвращает код возврата последней команды
                  \ если код ≠ 0 (ошибка) → заходим в тело IF
        s" [ERROR] Command failed" type cr
        bye       \ немедленно завершаем интерпретатор
    THEN ;

: get-home-path ( -- addr u )
    s" HOME" getenv s" /" fmix.str-concat ;

\ создать директорию с родительскими папками
: ensure-dir ( path u -- )
    2dup type cr
    $1FF mkdir-parents drop ;

\ заменить в файле вхождения строки FROM на TO
: replace-in-file { file-a file-u from-a from-u to-a to-u -- }
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
    s" cp " 
    src-a src-u fmix.str-concat
    s"  " fmix.str-concat
    dst-a dst-u fmix.str-concat
    
    system-checked
;

\ копировать директорию рекурсивно из src в dst
: cp-dir { src-a src-u dst-a dst-u -- }
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
