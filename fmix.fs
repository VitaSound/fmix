include str.fs
include fmix_new.fs


\ : fmix ( -- )
\    begin
\    next-arg 2dup 0 0 d<> while
\    type space
\    repeat
\    2drop ;

variable arg-command
variable arg-command-size
variable arg-param
variable arg-param-size

: get_command arg-command @ arg-command-size @ ;
: get_param arg-param @ arg-param-size @ ;

: read_args
    next-arg drop drop \ drop -e
    next-arg arg-command-size ! arg-command !
    next-arg arg-param-size ! arg-param !
;

: new
    get_param fmix.new
;

: deps.get ( <project-name> -- )
    \ deps get
    s" Deps.get" type cr
;

: fmix ( -- )
    read_args

    get_command s" new"      COMPARE 0= IF new      THEN
    get_command s" deps.get" COMPARE 0= IF deps.get THEN
;

fmix cr bye
\ fmix cr
