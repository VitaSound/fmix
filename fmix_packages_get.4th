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
    \ f.4th concatenates name directly to fdirectory; trailing slash is required
    s" ./forth-packages/" fmix.str-dup 
    dep-base-path-u ! dep-base-path-a ! ;

: set-cur-pkg ( addr u -- )
    fmix.validate-package-name
    fmix.str-dup cur-pkg-name-u ! cur-pkg-name-a ! ;

\ --- Парсер package.4th ---

: fmix-skip-line 10 parse 2drop ;
: forth-package ; 
: end-forth-package ;

: key-value ( -- )
    parse-name 2drop fmix-skip-line ;

\ Tool self-dependencies (`fmix`, `flint`, `fcov`) used to be expressed
\ as `key-list dependencies fmix <ver>` in pre-0.7.0 projects. The
\ canonical form is now `key-value fmix ~> <X.Y>` (see
\ fmix_version_check.4th) and that path errors out with a migration
\ hint before we ever get here. We keep this skip as a belt-and-braces
\ safety net so that, even if version_check is bypassed somehow, we
\ never try to fetch `fmix` (and friends) from theforth.net — that
\ endpoint doesn't exist and returns HTTP 500.
: fmix.is-tool-dep? ( a u -- f )
    2dup s" fmix"  compare 0= IF 2drop true EXIT THEN
    2dup s" flint" compare 0= IF 2drop true EXIT THEN
    2dup s" fcov"  compare 0= IF 2drop true EXIT THEN
    2drop false ;

: key-list ( -- )
    parse-name s" dependencies" compare 0<> IF fmix-skip-line EXIT THEN

    parse-name 2dup fmix.is-tool-dep? IF
        2drop fmix-skip-line EXIT
    THEN

    set-cur-pkg

    parse-name 2dup s" git" compare 0= IF
        2drop parse-git-args  \ Вызов из fmix_deps_git.4th
    ELSE
        process-theforth-dep  \ Вызов из fmix_deps_net.4th
    THEN ;

: fmix.packages.get
    fmix.assert-min-version
    set-default-dep-path

    fmix.project-path s" package.4th" fmix.fs-join
    
    s" * Reading: " type 2dup type cr
    
    2dup file-status 0<> IF
        s" [ERROR] package.4th not found!" type cr 
        2drop fmix.exit
    THEN
    drop
    
    included
;
