\ fmix.4th
\ FMix - Forth Build Tool

require fmix_utils.4th
require fmix_new.4th
require fmix_packages_get.4th
require fmix_test.4th

2VARIABLE cmd-arg
2VARIABLE param-arg

: read_args
    \ Пропускаем имя скрипта
    next-arg 2drop 

    \ Читаем команду (или -e от старого алиаса)
    next-arg 
    2dup s" -e" compare 0= IF
        2drop next-arg \ Игнорируем -e, берем следующую
    THEN
    str-dup cmd-arg 2!

    \ Читаем параметр (имя пакета)
    next-arg str-dup param-arg 2!
;

: fmix.help
    cr s" Usage: fmix <command> [args]" type cr
    s" Commands:" type cr
    s"    new <name>       - Create new package" type cr 
    s"    packages.get     - Install dependencies" type cr
    s"    test             - Run project tests" type cr
    s"    version          - Show version" type cr cr
;

: fmix.version
    cr s" ** (fmix) v0.3.6" type cr cr
;

: run-new
    param-arg 2@ nip 0= IF
        cr s" Error: 'new' command requires a package name." type cr
        EXIT
    THEN
    param-arg 2@ set-pkg-name fmix.new
;

: fmix ( -- )
    read_args

    cmd-arg 2@ nip 0= IF fmix.help EXIT THEN

    cmd-arg 2@ s" new"          COMPARE 0= IF run-new            EXIT THEN
    cmd-arg 2@ s" packages.get" COMPARE 0= IF fmix.packages.get  EXIT THEN
    cmd-arg 2@ s" test"         COMPARE 0= IF fmix.test          EXIT THEN
    cmd-arg 2@ s" version"      COMPARE 0= IF fmix.version       EXIT THEN
    
    s" Unknown command: " type cmd-arg 2@ type cr 
    fmix.help
;

fmix bye
