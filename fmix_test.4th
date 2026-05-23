\ fmix_test.4th
\ Этот файл должен лежать рядом с fmix.4th
require fmix_utils.4th

: ttester-project-path ( -- addr u )
    fmix.project-path s" forth-packages/ttester/1.1.0/ttester.4th" fmix.fs-join ;

: ttester-fmix-path ( -- addr u )
    fmix.home-path s" forth-packages/ttester/1.1.0/ttester.4th" fmix.fs-join ;

: load-ttester ( -- )
    ttester-project-path
    2dup file-status nip 0= IF
        required
    ELSE
        2drop ttester-fmix-path required
    THEN ;

load-ttester

2VARIABLE test-path
variable wdirid
create test-buff 255 allot
VARIABLE fmix.ERRORS 0 fmix.ERRORS !
VARIABLE fmix.ERROR 0 fmix.ERROR !

\ --- isolated/shared mode ---------------------------------------------------
\ Default is isolated: every *_test.4th file runs in a fresh gforth process,
\ so a failure (or stack leak, or global-state mutation) in one file cannot
\ mask problems in another.  Shared mode (--shared) keeps the legacy behaviour
\ of loading every test into a single gforth session — useful for catching
\ cross-test memory or global-state leaks (e.g. project-drop forgets to free
\ a list), but unsafe as the default.
\
\ The bash launcher (bin/fmix) parses --isolated / --shared and sets
\ FMIX_TEST_ISOLATED to "1" or "0".  Absent variable means isolated.
variable fmix.test-isolated?
true fmix.test-isolated? !

: fmix.read-isolated-mode ( -- )
    s" FMIX_TEST_ISOLATED" getenv 2dup nip 0= IF
        2drop true fmix.test-isolated? ! EXIT
    THEN
    s" 0" compare 0= IF
        false fmix.test-isolated? !
    ELSE
        true fmix.test-isolated? !
    THEN ;

fmix.read-isolated-mode

: fail-fast-error ( addr u -- )
    s" ERROR" type cr
    type cr
    SOURCE TYPE CR

    1 fmix.ERRORS +!
    1 fmix.ERROR !
    ;

' fail-fast-error ERROR-XT !


: get-test-path
    test-path 2@ ;

\ Build a shell command that runs one test file in a fresh gforth process.
\ Result: TERM=dumb gforth -e 's" <abs-path>" included bye' </dev/null
\
\ - </dev/null  : the subprocess has no tty stdin, so gforth/readline cannot
\                 issue OSC 11 (background-colour query) and similar; any
\                 terminal reply would otherwise leak into the parent shell's
\                 input buffer between subprocesses.
\ - TERM=dumb   : extra belt-and-braces — disables terminal escape sequences
\                 from gforth's startup banner / readline init on WSL/xterm.
: fmix.build-isolated-cmd ( file-a file-u -- cmd-a cmd-u )
    s\" TERM=dumb gforth -e 's\" "
    2swap fmix.str-concat
    s\" \" included bye' </dev/null"
    fmix.str-concat ;

\ Run one test file in a fresh gforth subprocess; update ERROR/ERRORS.
: fmix.run-isolated ( file-a file-u -- )
    fmix.build-isolated-cmd
    2dup system
    drop free throw                \ free the command buffer allocated by str-concat
    $? 0<> IF
        1 fmix.ERRORS +!
        1 fmix.ERROR !
    THEN ;

: test-file-operate
    get-test-path 2swap fmix.fs-join
    2dup type
    s"  - " type

    0 fmix.ERROR !

    fmix.test-isolated? @ IF
        cr fmix.run-isolated
    ELSE
        included
    THEN

    fmix.ERROR @ 0= IF
        s" OK" type cr
    THEN
;

: test-file-filter

    2dup s" _test.4th" search
    IF
        2drop
        s" * Test file: " type
        test-file-operate
    ELSE
        2drop 2drop
    THEN ;

: test-read-dir
    get-test-path open-dir

    0= IF
        wdirid !
        BEGIN
            test-buff 255 wdirid @ read-dir throw
        WHILE
            test-buff swap
            test-file-filter
        REPEAT
        wdirid @ close-dir throw
    ELSE
        s" [ERROR] Cannot open ./tests directory" type cr
    THEN ;

: fmix.test
    fmix.assert-min-version
    fmix.param-arg 2@

    0= IF
        drop

        cr s" * Start Tests" type cr
        fmix.project-path s" tests" fmix.fs-join test-path 2!
        test-read-dir
    ELSE
        drop
        cr s" * Start Tests for one file: " type
        fmix.project-path test-path 2!
        fmix.param-arg 2@ test-file-operate
    THEN 
    
    fmix.ERRORS @ 0= IF
        cr s" * All tests passed successfully." type cr
    ELSE
        cr s" * Some tests failed. Total errors: " type
        fmix.ERRORS @ . cr
        fmix.exit
    THEN
;
