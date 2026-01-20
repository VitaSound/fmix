\ fmix_packages_get.4th
\ Координатор зависимостей

\ --- Глобальные переменные контекста ---
\ Они должны быть определены ДО подключения sub-модулей
variable dep-base-path-a  variable dep-base-path-u
variable cur-pkg-name-a   variable cur-pkg-name-u
variable cur-pkg-ver-a    variable cur-pkg-ver-u

\ --- Подключение модулей ---
require fmix_deps_git.4th
require fmix_deps_net.4th

\ --- Утилиты настройки ---

: set-default-dep-path
    s" ./forth-packages" str-dup 
    dep-base-path-u ! dep-base-path-a ! ;

: set-cur-pkg ( addr u -- )
    str-dup cur-pkg-name-u ! cur-pkg-name-a ! ;

\ --- Парсер package.4th ---

: fmix-skip-line 10 parse 2drop ;
: forth-package ; 
: end-forth-package ;

: key-value ( -- )
    parse-name 
    2dup s" dependencies_path_fmix" compare 0= IF
        2drop
        get-home-path s" fmix/forth-packages" str-concat
        dep-base-path-u ! dep-base-path-a !
    ELSE
        2drop fmix-skip-line
    THEN ;

: key-list ( -- )
    parse-name s" dependencies" compare 0<> IF fmix-skip-line EXIT THEN
    
    parse-name set-cur-pkg
    
    parse-name 2dup s" git" compare 0= IF
        2drop parse-git-args  \ Вызов из fmix_deps_git.4th
    ELSE
        process-theforth-dep  \ Вызов из fmix_deps_net.4th
    THEN ;

: fmix.packages.get
    set-default-dep-path
    
    s" PWD" getenv s" /" str-concat s" package.4th" str-concat
    
    s" * Reading: " type 2dup type cr
    
    2dup file-status 0<> IF
        s" [ERROR] package.4th not found!" type cr 
        2drop EXIT
    THEN
    drop
    
    included 
;
