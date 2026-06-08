\ fmix_check.4th — quality gate: fmix test, flint, fcov by stage

require fmix_utils.4th
require fmix_version_check.4th
require fmix_test.4th
require fmix_check_config.4th

variable fmix.check-no-flint
variable fmix.check-no-fcov
variable fmix.check-fail-under-cli
0 fmix.check-no-flint !
0 fmix.check-no-fcov !
-1 fmix.check-fail-under-cli !

: fmix.int>str ( n -- a u )
    dup abs 0 <# #s #> 2dup nip IF EXIT THEN
    drop s" 0" ;

: fmix.tool-home { env-a env-u sub-a sub-u -- a u }
    env-a env-u getenv 2dup nip IF EXIT THEN
    2drop
    s" HOME" getenv sub-a sub-u fmix.str-concat ;

: fmix.build-bin-cmd { home-a home-u tool-a tool-u args-a args-u -- cmd-a cmd-u }
    home-a home-u s" /bin/" fmix.str-concat tool-a tool-u fmix.str-concat
    s" " fmix.str-concat args-a args-u fmix.str-concat ;

: fmix.check-read-flags
    0 fmix.check-no-flint !
    0 fmix.check-no-fcov !
    -1 fmix.check-fail-under-cli !
    s" FMIX_CHECK_NO_FLINT" getenv 2dup nip IF
        2dup s" 1" compare 0= IF -1 fmix.check-no-flint ! THEN
        2drop
    ELSE 2drop THEN
    s" FMIX_CHECK_NO_FCOV" getenv 2dup nip IF
        2dup s" 1" compare 0= IF -1 fmix.check-no-fcov ! THEN
        2drop
    ELSE 2drop THEN
    s" FMIX_CHECK_FAIL_UNDER" getenv 2dup nip IF
        2dup evaluate fmix.check-fail-under-cli !
        2drop
    ELSE 2drop THEN ;

: fmix.check-fail-under-threshold ( -- n )
    fmix.check-fail-under-cli @ 0>= IF fmix.check-fail-under-cli @ EXIT THEN
    fmix.check-fcov-fail-under @ ;

: fmix.check-run-flint ( -- )
    fmix.check-no-flint @ IF EXIT THEN
    s" FLINT_HOME" s" /flint" fmix.tool-home
    s" /bin/flint lint . --strict --project-only" fmix.str-concat
    system-checked ;

: fmix.check-run-fcov ( -- )
    fmix.check-no-fcov @ IF EXIT THEN
    s" FCOV_HOME" s" /fcov" fmix.tool-home
    s" /bin/fcov run fmix test --strict" fmix.str-concat
    system-checked
    fmix.check-fail-under-threshold 0< IF
        s" FCOV_HOME" s" /fcov" fmix.tool-home
        s" /bin/fcov report" fmix.str-concat
        system-checked EXIT
    THEN
    s" FCOV_HOME" s" /fcov" fmix.tool-home
    s" /bin/fcov report --fail-under " fmix.str-concat
    fmix.check-fail-under-threshold fmix.int>str fmix.str-concat
    system-checked ;

: fmix.check-run-test ( -- )
    fmix.test ;

: fmix.check-stage-pre-commit ( -- )
    cr s" * fmix check: stage pre-commit" type cr
    fmix.check-run-test
    fmix.check-run-flint ;

: fmix.check-stage-pre-push ( -- )
    cr s" * fmix check: stage pre-push" type cr
    fmix.check-run-test
    fmix.check-run-flint
    fmix.check-run-fcov ;

: fmix.check-stage-all ( -- )
    fmix.check-stage-pre-push ;

: fmix.check-stage-arg ( -- a u )
    s" FMIX_CHECK_STAGE" getenv 2dup nip IF EXIT THEN
    2drop
    fmix.param-arg 2@ nip IF fmix.param-arg 2@ EXIT THEN
    s" pre-commit" ;

: fmix.check ( -- )
    fmix.check-read-flags
    fmix.scan-check-config
    fmix.check-stage-arg { st-a st-u }
    st-a st-u s" pre-commit" compare 0= IF fmix.check-stage-pre-commit EXIT THEN
    st-a st-u s" pre-push" compare 0= IF fmix.check-stage-pre-push EXIT THEN
    st-a st-u s" all" compare 0= IF fmix.check-stage-all EXIT THEN
    cr s" [ERROR] Unknown check stage: " type st-a st-u type
    s"  (use pre-commit, pre-push, or all)" type cr
    fmix.exit ;
