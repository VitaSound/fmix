variable arg-command
variable arg-command-size
variable arg-param
variable arg-param-size

: get_command arg-command @ arg-command-size @ ;
: get_param arg-param @ arg-param-size @ ;

include fmix_utils.4th
include fmix_new.4th
include fmix_packages_get.4th
include fmix_test.4th

: read_args
    next-arg drop drop \ drop -e
    next-arg arg-command-size ! arg-command !
    next-arg arg-param-size ! arg-param !
;

: fmix_help
    s" ** (fmix) fmix v.0.3.3 with no arguments must be executed in a directory with a package.4th file" type cr cr
    s" Usage: fmix [task]" type cr cr
    s" fmix new PATH     - Creates a new Forth package at the given path" type cr
    s" fmix packages.get - Get dependency packages" type cr
    s" fmix test         - Start project tests" type cr
    s" fmix version      - Get fmix version" type cr
;

: fmix.version
    s" ** (fmix) fmix v.0.3.3" type cr cr
;

: fmix ( -- )
    read_args

    get_command s" new"          COMPARE 0= IF fmix.new          THEN
    get_command s" packages.get" COMPARE 0= IF fmix.packages.get THEN
    get_command s" test"         COMPARE 0= IF fmix.test         THEN
    get_command s" version"      COMPARE 0= IF fmix.version      THEN

    get_command = IF fmix_help THEN
;

fmix cr bye
\ fmix cr
