create dep_name 70 allot
create git_url 255 allot
create git_branch 70 allot
create git_command 255 allot

: get-dep-git-url-branch
    s" * Deps get. Name: " type
    dep_name $@ type cr
    s" * Deps get. URL: " type
    git_url $@ type cr
    s" * Deps get. Branch: " type
    git_branch $@ type cr

    \ git clone -b main https://github.com/UA3MQJ/ftest.git ./deps/ftest/main

    \ s" git clone -b "
    \ git_branch $@ s+
    \ s"  " s+
    \ git_url $@ s+
    \ s"  " s+
    \ s" PWD" getenv s+
    \ s" /deps/" s+
    \ dep_name $@ s+
    \ s" /" s+
    \ git_branch $@ s+

    s" sudo pamac -Yu git" system
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
        parse-name s" branch" compare 0= if
            parse-name git_branch $!
            get-dep-git-url-branch
        else
            parse-line-drop
        then
    else
        parse-line-drop
    then
;

\ finclude project.fs handling
: forth-project ( -- f )
    ;
: key-value ( <parse-name> <parse-line> -- )
    parse-name s" main" compare 0= if
        s" Main file name: " type
        parse-name type cr
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

    s" PWD" getenv
    s" /fproject.fs" s+
    included
;