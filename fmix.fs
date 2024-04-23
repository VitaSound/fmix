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

: new ( <project-name> --  )
    get_param fmix.new
;

: deps.get
    \ deps get
    s" Deps.get" type cr
;

: fmix_help
    s" ** (fmix) fmix with no arguments must be executed in a directory with a fproject.fs file" type cr cr
    s" Usage: fmix [task]" type cr cr
    s" mix new PATH    - Creates a new Forth project at the given path" type cr
;

: fmix ( -- )
    read_args

    get_command s" new"      COMPARE 0= IF new      THEN
    get_command s" deps.get" COMPARE 0= IF deps.get THEN

    \ get_command 0= swap 0= = IF fmix_help THEN
;

fmix cr bye
\ fmix cr
