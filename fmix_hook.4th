\ fmix_hook.4th — install / uninstall git hooks calling fmix check

require fmix_utils.4th

: fmix.hook-marker? { a u -- f }
    a u s" vitasound-fmix-hook" search nip nip 0<> ;

: fmix.hook-path ( name-a name-u -- path-a path-u )
    s" .git/hooks/" 2swap fmix.str-concat ;

: fmix.is-git-repo? ( -- f )
    fmix.project-path s" .git" fmix.fs-join
    file-status nip 0= ;

: fmix.hook-install-one { name-a name-u -- }
    fmix.home-path s" /priv/hooks/" fmix.str-concat name-a name-u fmix.str-concat
    { src-a src-u }
    src-a src-u file-status nip 0= 0= IF
        cr s" [ERROR] Missing hook template: " type name-a name-u type cr
        fmix.exit
    THEN
    name-a name-u fmix.hook-path { dst-a dst-u }
    src-a src-u dst-a dst-u cp-file
    s" chmod +x '" dst-a dst-u fmix.str-concat s" '" fmix.str-concat system-checked
    cr s" [INFO] hook installed: " type name-a name-u type cr ;

: fmix.hook-uninstall-one { name-a name-u -- }
    name-a name-u fmix.hook-path 2dup file-status nip 0= IF
        2dup slurp-file { body-a body-u }
        2drop
        body-a body-u fmix.hook-marker? IF
            s" rm -f '" name-a name-u fmix.hook-path fmix.str-concat
            s" '" fmix.str-concat system-checked
            cr s" [INFO] hook removed: " type name-a name-u type cr
        ELSE
            cr s" [INFO] hook skipped (not ours): " type name-a name-u type cr
        THEN
        body-a body-u drop free throw
    ELSE
        2drop
    THEN ;

: fmix.hook-install-stage { stage-a stage-u -- }
    stage-a stage-u s" pre-commit" compare 0= IF
        s" pre-commit" s" pre-commit" fmix.hook-install-one EXIT THEN
    stage-a stage-u s" pre-push" compare 0= IF
        s" pre-push" s" pre-push" fmix.hook-install-one EXIT THEN
    stage-a stage-u s" all" compare 0= IF
        s" pre-commit" s" pre-commit" fmix.hook-install-one
        s" pre-push" s" pre-push" fmix.hook-install-one EXIT THEN
    cr s" [ERROR] Unknown hook stage: " type stage-a stage-u type cr
    fmix.exit ;

: fmix.hook-uninstall-stage { stage-a stage-u -- }
    stage-a stage-u s" pre-commit" compare 0= IF
        s" pre-commit" s" pre-commit" fmix.hook-uninstall-one EXIT THEN
    stage-a stage-u s" pre-push" compare 0= IF
        s" pre-push" s" pre-push" fmix.hook-uninstall-one EXIT THEN
    stage-a stage-u s" all" compare 0= IF
        s" pre-commit" s" pre-commit" fmix.hook-uninstall-one
        s" pre-push" s" pre-push" fmix.hook-uninstall-one EXIT THEN
    cr s" [ERROR] Unknown hook stage: " type stage-a stage-u type cr
    fmix.exit ;

: fmix.hook-stage-arg ( -- a u )
    s" FMIX_HOOK_STAGE" getenv 2dup nip IF EXIT THEN
    2drop
    fmix.param-arg 2@ nip IF fmix.param-arg 2@ EXIT THEN
    s" pre-commit" ;

: fmix.hook-install ( -- )
    fmix.is-git-repo? 0= IF
        cr s" [ERROR] Not a git repository (.git missing)" type cr
        fmix.exit
    THEN
    fmix.hook-stage-arg fmix.hook-install-stage ;

: fmix.hook-uninstall ( -- )
    fmix.hook-stage-arg s" all" compare 0= IF
        s" all" s" all" fmix.hook-uninstall-stage EXIT
    THEN
    fmix.hook-stage-arg fmix.hook-uninstall-stage ;

: fmix.hook ( -- )
    fmix.param-arg 2@ s" install" compare 0= IF fmix.hook-install EXIT THEN
    fmix.param-arg 2@ s" uninstall" compare 0= IF fmix.hook-uninstall EXIT THEN
    cr s" [ERROR] Unknown hook command: " type fmix.param-arg 2@ type cr
    s" Usage: fmix hook install|uninstall [--stage pre-commit|pre-push|all]" type cr
    fmix.exit ;
