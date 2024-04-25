variable arg-command
variable arg-command-size
variable arg-param
variable arg-param-size

: get_command arg-command @ arg-command-size @ ;
: get_param arg-param @ arg-param-size @ ;

include fmix_utils.fs
include fmix_new.fs
include fmix_deps_get.fs

: read_args
    next-arg drop drop \ drop -e
    next-arg arg-command-size ! arg-command !
    next-arg arg-param-size ! arg-param !
;

: fmix_help
    s" ** (fmix) fmix with no arguments must be executed in a directory with a fproject.fs file" type cr cr
    s" Usage: fmix [task]" type cr cr
    s" mix new PATH    - Creates a new Forth project at the given path" type cr
;

: fmix ( -- )
    read_args

    get_command s" new"      COMPARE 0= IF fmix.new THEN
    get_command s" deps.get" COMPARE 0= IF fmix.deps.get THEN

    \ get_command 0= swap 0= = IF fmix_help THEN
;

fmix cr bye
\ fmix cr
