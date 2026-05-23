\ fmix.4th
\ FMix - Forth Build Tool

require fmix_utils.4th
require fmix_version.4th
require fmix_new.4th
require fmix_packages_get.4th
require fmix_test.4th

: fmix.help
    cr 
    s" FMix v" type fmix-ver-data 2@ type
    s"  is a build tool that provides tasks for creating, and testing Forth packages, managing its dependencies." type cr
    s" Usage: fmix <command> [args]" type cr
    s" Commands:" type cr
    s"    new <name>                                - Create new package" type cr
    s"    packages.get                              - Install dependencies" type cr
    s"    test [--isolated|--shared] [<test_file>]  - Run all *_test.4th in" type cr
    s"                                                ./tests, or one given file." type cr
    s"                                                --isolated (default): each test" type cr
    s"                                                in a fresh gforth process." type cr
    s"                                                --shared: single session for all." type cr
    s"    version                                   - Show version" type cr cr
;

: fmix.version
    cr s" ** (fmix) v" type fmix-ver-data 2@ type cr cr
;

: fmix.newproject
    fmix.param-arg 2@ nip 0= IF
        cr s" Error: 'new' command requires a package name." type cr
        fmix.exit
    THEN
    fmix.param-arg 2@ set-pkg-name fmix.new
;

: fmix-dispatch ( -- )
    fmix.read_args
    fmix.cmd-arg 2@ nip 0= IF
        fmix.help
    ELSE
        fmix.cmd-arg 2@ s" new" compare 0= IF
            fmix.newproject
        ELSE fmix.cmd-arg 2@ s" packages.get" compare 0= IF
            fmix.packages.get
        ELSE fmix.cmd-arg 2@ s" test" compare 0= IF
            fmix.test
        ELSE fmix.cmd-arg 2@ s" version" compare 0= IF
            fmix.version
        ELSE fmix.cmd-arg 2@ s" help" compare 0= IF
            fmix.help
        ELSE
            s" Unknown command: " type fmix.cmd-arg 2@ type cr
            fmix.help
        THEN THEN THEN THEN THEN
    THEN
    fmix.restore-terminal
    0 bye ;

fmix-dispatch
