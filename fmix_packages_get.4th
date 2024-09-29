include ~/fmix/forth-packages/f/0.2.4/compat-gforth.4th
include ~/fmix/forth-packages/f/0.2.4/f.4th

create package_name 70 allot
create git_url 255 allot
create git_branch 70 allot
create git_tag 70 allot
create package_version 70 allot
create git_command 255 allot
create forth_packages_path 255 allot
create url_path 255 allot

: set_default_forth_packages_path
    s" ./forth-packages/"
    forth_packages_path $!
;

: get-dep-theforth
    s" * Packages get. From https://theforth.net Name: " type
    package_name $@ type cr
    s" * Packages get. Version: " type
    package_version $@ type cr


    \ change default f.4th directory
    forth_packages_path $@ fdirectory 2!

    s" /api/packages/content/forth/" package_name $@ s+
    s" /" package_version $@ s+ s+
    api-get-eval
;

: get-dep-git-url-branch
    s" * Packages get. from GIT. Name: " type
    package_name $@ type cr
    s" * Packages get. URL: " type
    git_url $@ type cr
    s" * Packages get. Branch: " type
    git_branch $@ type cr

    \ git clone -b main https://github.com/UA3MQJ/ftest.git ./forth-packages/ftest/main

    s" git clone -b "
    git_branch $@ s+
    s"  " s+
    git_url $@ s+
    s"  " s+
    forth_packages_path $@ s+
    package_name $@ s+
    s" /" s+
    git_branch $@ s+

    2dup type cr

    system $? 0= if
        s" * Clone OK" type cr
    else
        s" * Clone ERROR. Already cloned. Pull Update" type cr

        s" cd "
        forth_packages_path $@ s+
        package_name $@ s+
        s" /" s+
        git_branch $@ s+
        s"  ; git reset --hard ; git pull origin " s+
        git_branch $@ s+
        s"  --force" s+
        system
    then
;

: get-dep-git-url-tag
    s" * Packages get. from GIT. Name: " type
    package_name $@ type cr
    s" * Packages get. URL: " type
    git_url $@ type cr
    s" * Packages get. TAG: " type
    git_tag $@ type cr

    \ git clone -b main https://github.com/UA3MQJ/ftest.git ./forth-packages/ftest/main

    s" git clone -b "
    git_tag $@ s+
    s"  " s+
    git_url $@ s+
    s"  " s+
    forth_packages_path $@ s+
    package_name $@ s+
    s" /" s+
    git_tag $@ s+

    2dup type cr

    system $? 0= if
        s" * Clone OK" type cr
    else
        s" * Clone ERROR. Already cloned. Pull Update" type cr

        s" cd "
        forth_packages_path $@ s+
        package_name $@ s+
        s" /" s+
        git_tag $@ s+
        s"  ; git reset --hard ; git pull origin " s+
        git_tag $@ s+
        s"  --force" s+
        system
    then
;



\ parse name and immediately drop it
: fmix-parse-drop ( <parse-name> -- )
    parse-name 2drop ;
: fmix-parse-line ( <parse-line> -- c-addr n )
    10 parse ;
: fmix-parse-line-drop ( <parse-line> -- )
    fmix-parse-line 2drop ;

: parse-dep 
    parse-name package_name $!
    parse-name 2dup s" git" compare 0= if
        parse-name git_url $!
        parse-name 2dup s" branch" compare 0= if
            parse-name git_branch $!
            get-dep-git-url-branch
        else
            s" tag" compare 0= if
                parse-name git_tag $!
                get-dep-git-url-tag
            else
                fmix-parse-line-drop
            then
        then
    else
        package_version $!
        get-dep-theforth
    then
;

\ finclude package.4th handling
: forth-package ( -- f )
    ;
: key-value ( <parse-name> <parse-line> -- )
    parse-name s" dependencies_path_fmix" compare 0= if
        s" * Change default packages path to ~/fmix/forth-packages/ " type
        
        s" HOME" getenv
        s" /fmix/forth-packages/" s+
        forth_packages_path $!
    else
        fmix-parse-line-drop
    then ;
: key-list ( <parse-name> <parse-line> -- )
    parse-name s" dependencies" compare 0= if
        parse-dep
    else
        fmix-parse-line-drop
    then ;
: end-forth-package ; ( -- )



: fmix.packages.get
    s" * packages.get" type cr
    set_default_forth_packages_path

    s" PWD" getenv
    s" /package.4th" s+
    included
;