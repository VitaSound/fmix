
variable project-name
variable project-name-size

: save_project_name project-name-size ! project-name ! ;
: get_project_name project-name @ project-name-size @ ;


: fmix_priv_path
    s" HOME" getenv
    s" /fmix/priv/" s+ ;

: new_path
    get_project_name s" /" s+ ;

: type_message1 get_project_name s" * Creating new project: " type type cr ;
: create_project_directory get_project_name create-directories ;

: copy_readme
    fmix_priv_path s" README.md" s+
    new_path
    copy_file

    new_path s" README.md" s+
    s" <name>"
    get_project_name
        sed
;

: copy_project_file 
    fmix_priv_path s" fproject.fs" s+
    new_path
        copy_file

    new_path s" fproject.fs" s+
    s" <name>"
    get_project_name
        sed
;

: copy_main_file
    fmix_priv_path s" main.fs" s+
    new_path get_project_name s+ s" .fs" s+
        copy_file
;


: copy_license
    fmix_priv_path s" LICENSE" s+
    new_path
        copy_file
;

: fmix.new
    get_param
    save_project_name    
    type_message1
    create_project_directory drop
    copy_readme
    copy_project_file
    copy_main_file
    copy_license
;
