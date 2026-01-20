\ fmix_utils.4th
\ Базовые утилиты. Исправлена логика системных вызовов.

\ --- Работа со строками ---

: str-concat { a1 u1 a2 u2 -- a3 u3 }
    u1 u2 + allocate throw { mem }
    a1 mem u1 move
    a2 mem u1 + u2 move
    mem u1 u2 + 
;

: str-dup { a u -- a-new u }
    u allocate throw { mem }
    a mem u move
    mem u
;

: fs-join { path-a path-u name-a name-u -- full-a full-u }
    path-u 1 + name-u + allocate throw { mem }
    path-a mem path-u move
    s" /" drop mem path-u + 1 move
    name-a mem path-u + 1 + name-u move
    mem path-u 1 + name-u +
;

\ --- Системные утилиты ---

: system-checked ( addr u -- )
    system $? 0<> IF
        s" [ERROR] Command failed" type cr
        bye
    THEN ;

: get-home-path ( -- addr u )
    s" HOME" getenv s" /" str-concat ;

: ensure-dir ( path u -- )
    2dup type cr
    $1FF mkdir-parents drop ;

\ Исправлено: порядок склейки строки для sed
: replace-in-file { file-a file-u from-a from-u to-a to-u -- }
    \ Строим команду: sed -i 's#FROM#TO#g' FILE
    s" sed -i 's#" 
    from-a from-u str-concat
    s" #" str-concat
    to-a to-u str-concat
    s" #g' " str-concat
    file-a file-u str-concat
    
    system-checked 
;

\ Исправлено: прямой порядок аргументов для cp
: cp-file { src-a src-u dst-a dst-u -- }
    s" cp " 
    src-a src-u str-concat
    s"  " str-concat
    dst-a dst-u str-concat
    
    system-checked
;

\ Исправлено: прямой порядок аргументов для cp -r
: cp-dir { src-a src-u dst-a dst-u -- }
    s" cp -r " 
    src-a src-u str-concat
    s"  " str-concat
    dst-a dst-u str-concat
    
    system-checked
;
