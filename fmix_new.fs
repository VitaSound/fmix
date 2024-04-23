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

: create_readme 
   get_project_name filename place_str
    
    s" /README.md" filename append_str

    filename count open-output

    s" # " fd-out write-file drop
    get_project_name fd-out write-line drop
    s" " fd-out write-line drop
    s" **TODO: Add description**" fd-out write-line drop
    s" " fd-out write-line drop
    s" ## Installation" fd-out write-line drop
    s" " fd-out write-line drop
    s" For install dependecies" fd-out write-line drop
    s" " fd-out write-line drop
    s" ```forth" fd-out write-line drop
    s"    fmix deps.get" fd-out write-line drop
    s" ```" fd-out write-line drop

    fd-out flush-file drop
    fd-out close-file drop
;

: create_project_file 
   get_project_name filename place_str
    
    s" /fproject.fs" filename append_str

    filename count open-output

    s" # " fd-out write-file drop
    get_project_name fd-out write-line drop
    s" " fd-out write-line drop
    s" **TODO: Add description**" fd-out write-line drop
    s" " fd-out write-line drop
    s" ## Installation" fd-out write-line drop
    s" " fd-out write-line drop
    s" For install dependecies" fd-out write-line drop
    s" " fd-out write-line drop
    s" ```forth" fd-out write-line drop
    s"    fmix deps.get" fd-out write-line drop
    s" ```" fd-out write-line drop

    fd-out flush-file drop
    fd-out close-file drop
;

: fmix.new ( name-str name-str-size )
    save_project_name    
    type_message1
    create_project_directory
    create_readme
    create_project_file
 
;