\ tests/fmix_integration_test.4th
\
\ Integration checks (system + $?) — FMIX_HOME must be exported by caller.

: fmix.test-setup
    s" FMIX_HOME" getenv 2dup nip 0= IF
        cr ." [SKIP] fmix_integration_test needs FMIX_HOME" cr
        2drop 0 ( bye )
    THEN
    fpath also-path ;
fmix.test-setup

s" forth-packages/ttester/1.2.1/ttester.4th" included

0 #ERRORS !

: fmix.test-sh ( cmd-a cmd-u -- status )
    system $? ;

T{ s" cd $FMIX_HOME/tests/fixtures/needs_future_fmix && $FMIX_HOME/bin/fmix test"
    fmix.test-sh 0<> -> true }T
T{ s" cd $FMIX_HOME/tests/fixtures/legacy_fmix_dep && $FMIX_HOME/bin/fmix test"
    fmix.test-sh 0<> -> true }T
T{ s" cd $FMIX_HOME/tests/fixtures/invalid_fmix_req && $FMIX_HOME/bin/fmix test"
    fmix.test-sh 0<> -> true }T
T{ s" cd $FMIX_HOME/tests/fixtures/bare_fmix_req && $FMIX_HOME/bin/fmix test"
    fmix.test-sh -> 0 }T
T{ s" cd $FMIX_HOME/tests/fixtures/self_dep_only && $FMIX_HOME/bin/fmix packages.get"
    fmix.test-sh -> 0 }T
T{ s" $FMIX_HOME/bin/fmix version" fmix.test-sh -> 0 }T
T{ s" rm -rf /tmp/fmixinttest && mkdir /tmp/fmixinttest && cd /tmp/fmixinttest && $FMIX_HOME/bin/fmix new fmixintpkg && test -f fmixintpkg/package.4th"
    fmix.test-sh -> 0 }T

: report
    #ERRORS @ 0= IF
        cr ." fmix_integration_test ok" cr
    ELSE
        cr ." fmix_integration_test FAILED: " #ERRORS @ . ." errors" cr
        1 ( bye )
    THEN ;
report
bye
