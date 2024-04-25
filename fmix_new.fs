: deps-directory s" deps" ;

-529 constant error-exists

variable project-name
variable project-name-size
: save_project_name project-name-size ! project-name ! ;
: get_project_name project-name @ project-name-size @ ;

create filename 70 allot

\ directories
: create-directories ( c-addr n -- ior )
    $1FF mkdir-parents      \ add mask
    dup error-exists = if   \ ignore error-exists
        drop 0
    then ;

\ deps-directory create-directories создаст ./deps

: type_message1 get_project_name s" * Creating new project: " type type cr ;
: create_project_directory get_project_name create-directories ;

: copy_readme
    s" cp ~/fmix/priv/README.md "
    get_project_name s+
    s" /README.md" s+
    system

    s" sed -i 's/<name>/"
    get_project_name s+
    s" /g' " s+
    get_project_name s+
    s" /README.md" s+
    system
;

: copy_project_file 
    s" cp ~/fmix/priv/fproject.fs "
    get_project_name s+
    s" /fproject.fs" s+
    system

    s" sed -i 's/<name>/"
    get_project_name s+
    s" /g' " s+
    get_project_name s+
    s" /fproject.fs" s+
    system
;

: copy_main_file
    s" cp ~/fmix/priv/main.fs "
    get_project_name s+
    s" /" s+
    get_project_name s+
    s" .fs" s+
    system
;

: copy_license
    s" cp "
    s" HOME" getenv s+
    s" /fmix/LICENSE ./" s+
    get_project_name s+

    system
;

: fmix_priv_path
    s" HOME" getenv
    s" /fmix/priv/" s+ ;


: new_path
    get_project_name ;

: prepend 2swap s+ ;

: copy_file ( src target -- )
    s"  " prepend s+ s" cp " prepend
    system
;

: copy_license2
    fmix_priv_path s" LICENSE" s+
    new_path s" /" s+
    copy_file
;

: fmix.new
    get_param
    save_project_name    
    \ type_message1
    \ create_project_directory
    \ copy_readme
    \ copy_project_file
    \ copy_main_file
    \ copy_license
    copy_license2
    \ type
    .s
;
