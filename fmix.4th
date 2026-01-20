\ fmix.4th
\ FMix - Forth Build Tool

require fmix_utils.4th
require fmix_version.4th
require fmix_new.4th
require fmix_packages_get.4th
require fmix_test.4th

2VARIABLE cmd-arg
2VARIABLE param-arg

: read_args
    next-arg 2drop 
    next-arg 
    2dup s" -e" compare 0= IF 2drop next-arg THEN
    str-dup cmd-arg 2!
    next-arg str-dup param-arg 2!
;

: fmix.help
    cr 
    s" FMix v" type fmix-ver-data 2@ type
    s"  is a build tool that provides tasks for creating, and testing Forth packages, managing its dependencies." type cr
    s" Usage: fmix <command> [args]" type cr
    s" Commands:" type cr
    s"    new <name>       - Create new package" type cr 
    s"    packages.get     - Install dependencies" type cr
    s"    test             - Run project tests" type cr
    s"    version          - Show version" type cr cr
;

: fmix.version
    \ Используем версию, прочитанную из файла
    cr s" ** (fmix) v" type fmix-ver-data 2@ type cr cr
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
    cmd-arg 2@ s" help"         COMPARE 0= IF fmix.help          EXIT THEN
    
    s" Unknown command: " type cmd-arg 2@ type cr 
    fmix.help
;

fmix bye
