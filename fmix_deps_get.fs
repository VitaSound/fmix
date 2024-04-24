include string.fs

create dep_name 70 allot
create git_url 255 allot
create git_branch 70 allot
create git_tag 70 allot
create git_command 255 allot
create deps_path 255 allot

: set_default_deps_path
    s" HOME" getenv
    s" /fmix/deps/" s+
    deps_path $!
;

: get-dep-git-url-branch
    s" * Deps get. Name: " type
    dep_name $@ type cr
    s" * Deps get. URL: " type
    git_url $@ type cr
    s" * Deps get. Branch: " type
    git_branch $@ type cr

    \ git clone -b main https://github.com/UA3MQJ/ftest.git ./deps/ftest/main

    s" git clone -b "
    git_branch $@ s+
    s"  " s+
    git_url $@ s+
    s"  " s+
    deps_path $@ s+
    dep_name $@ s+
    s" /" s+
    git_branch $@ s+

    2dup type cr

    system $? 0= if
        s" * Clone OK" type cr
    else
        s" * Clone ERROR. Already cloned. Pull Update" type cr

        s" cd "
        deps_path $@ s+
        dep_name $@ s+
        s" /" s+
        git_branch $@ s+
        s"  ; git reset --hard ; git pull origin " s+
        git_branch $@ s+
        s"  --force" s+
        system
    then
;

: get-dep-git-url-tag
    s" * Deps get. Name: " type
    dep_name $@ type cr
    s" * Deps get. URL: " type
    git_url $@ type cr
    s" * Deps get. TAG: " type
    git_tag $@ type cr

    \ git clone -b main https://github.com/UA3MQJ/ftest.git ./deps/ftest/main

    s" git clone -b "
    git_tag $@ s+
    s"  " s+
    git_url $@ s+
    s"  " s+
    deps_path $@ s+
    dep_name $@ s+
    s" /" s+
    git_tag $@ s+

    2dup type cr

    system $? 0= if
        s" * Clone OK" type cr
    else
        s" * Clone ERROR. Already cloned. Pull Update" type cr

        s" cd "
        deps_path $@ s+
        dep_name $@ s+
        s" /" s+
        git_tag $@ s+
        s"  ; git reset --hard ; git pull origin " s+
        git_tag $@ s+
        s"  --force" s+
        system
    then
;

\ parse name and immediately drop it
: parse-drop ( <parse-name> -- )
    parse-name 2drop ;
: parse-line ( <parse-line> -- c-addr n )
    10 parse ;
: parse-line-drop ( <parse-line> -- )
    parse-line 2drop ;

: parse-dep 
    parse-name dep_name $!
    parse-name s" git" compare 0= if
        parse-name git_url $!
        parse-name 2dup s" branch" compare 0= if
            parse-name git_branch $!
            get-dep-git-url-branch
        else
            s" tag" compare 0= if
                parse-name git_tag $!
                get-dep-git-url-tag
            else
                parse-line-drop
            then
        then
    else
        parse-line-drop
    then
;

\ finclude project.fs handling
: forth-project ( -- f )
    ;
: key-value ( <parse-name> <parse-line> -- )
    parse-name s" deps_path" compare 0= if
        s" * Change default deps path to: " type
        parse-name 2dup type cr s" /" s+ deps_path $!
    else
        parse-line-drop
    then ;
: key-list ( <parse-name> <parse-line> -- )
    parse-name s" deps" compare 0= if
        parse-dep
    else
        parse-line-drop
    then ;
: end-forth-project ; ( -- )



: fmix.deps.get
    s" * deps.get" type cr
    set_default_deps_path

    s" PWD" getenv
    s" /fproject.fs" s+
    included
;