: deps-directory s" deps" ;

-529 constant error-exists

variable project-name
variable project-name-size
: save_project_name over over project-name-size ! project-name ! ;
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

0 Value fd-out
: open-output ( addr u -- )  w/o create-file throw to fd-out ;

: fwrite fd-out write-file drop ;
: fwriteln fd-out write-line drop ;

: create_readme
    get_project_name filename 0 s+ 
    s" /README.md" s+
   
\     filename count open-output
    open-output

    s" # " fwrite
    get_project_name fwriteln
    s" " fwriteln
    s" **TODO: Add description**" fwriteln
    s" " fwriteln
    s" ## Installation" fwriteln
    s" " fwriteln
    s" For install dependecies" fwriteln
    s" " fwriteln
    s" ```forth" fwriteln
    s"    fmix deps.get" fwriteln
    s" ```" fwriteln

    fd-out flush-file drop
    fd-out close-file drop
;

: create_project_file 
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

: create_main_file
    get_project_name filename 0 s+ 
    s" /" s+
    get_project_name s+
    s" .fs" s+
    open-output
    s" / main file" fwriteln
    fd-out flush-file drop
    fd-out close-file drop
;

: copy_license
    s" cp "
    s" HOME" getenv s+
    s" /fmix/LICENSE ./" s+
    get_project_name s+

    system
;

: fmix.new
    get_param
    save_project_name    
    type_message1
    create_project_directory
    create_readme
    create_project_file
    create_main_file
    copy_license
 
;
