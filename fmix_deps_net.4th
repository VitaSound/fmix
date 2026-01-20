\ fmix_deps_net.4th
\ Логика работы с TheForth.net через библиотеку f.4th

variable f-lib-path-a variable f-lib-path-u

\ Переменные для текущей операции (чтобы не хранить на стеке)
variable net-ver-a    variable net-ver-u

\ --- 1. Инициализация ---

: prepare-f-lib-path
    get-home-path s" fmix/forth-packages/f/0.2.4/" str-concat
    f-lib-path-u ! f-lib-path-a ! ;

: load-f-lib-now
    prepare-f-lib-path
    
    s" * [System] Loading f.4th from " type f-lib-path-a @ f-lib-path-u @ type cr

    f-lib-path-a @ f-lib-path-u @ 
    s" compat-gforth.4th" str-concat
    2dup file-status 0<> IF
        s" [ERROR] compat-gforth.4th not found." type cr bye
    THEN
    drop included

    f-lib-path-a @ f-lib-path-u @ 
    s" f.4th" str-concat
    included
;

load-f-lib-now

\ --- 2. Логика ---

: process-theforth-dep ( version u -- )
    \ 1. СРАЗУ сохраняем версию в память и убираем со стека
    str-dup net-ver-u ! net-ver-a !

    s" * [NET] " type 
    cur-pkg-name-a @ cur-pkg-name-u @ type 
    s"  v" type net-ver-a @ net-ver-u @ type 
    s"  -> " type dep-base-path-a @ dep-base-path-u @ type cr

    \ 2. Настраиваем f.4th
    dep-base-path-a @ dep-base-path-u @ fdirectory 2!

    \ 3. Формируем URL, используя переменные (стек чист)
    s" /api/packages/content/forth/"
    cur-pkg-name-a @ cur-pkg-name-u @ str-concat
    s" /" str-concat
    net-ver-a @ net-ver-u @ str-concat

    \ 4. Выполняем (на стеке сейчас только URL)
    api-get-eval
    
    s"   Install OK" type cr
;
