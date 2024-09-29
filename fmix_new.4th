
variable package-name
variable package-name-size

: save_package_name package-name-size ! package-name ! ;
: get_package_name package-name @ package-name-size @ ;

\ TODO not working with gforth from snap
: get_home s" HOME" getenv ;

: fmix_priv_path
    get_home
    s" /fmix/priv/" s+ ;

: new_path
    get_package_name s" /" s+ ;

: type_message1 get_package_name s" * Creating new package: " type type cr ;
: create_package_directory get_package_name fmix-create-directories ;

: copy_readme
    fmix_priv_path s" README.md" s+
    new_path
    copy_file

    new_path s" README.md" s+
    s" <name>"
    get_package_name
        sed
;

: copy_package_file 
    fmix_priv_path s" package.4th" s+
    new_path
        copy_file

    new_path s" package.4th" s+
    s" <name>"
    get_package_name
        sed
;

: copy_main_file
    fmix_priv_path s" main.4th" s+
    new_path get_package_name s+ s" .4th" s+
        copy_file
;

: copy_license
    fmix_priv_path s" LICENSE" s+
    new_path
        copy_file
;

: copy_tests
    s" -r " fmix_priv_path s+ s" tests" s+
    new_path s" tests" s+
        copy_file
;

: copy_packages
    s" -r " fmix_priv_path s+ s" forth-packages" s+
    new_path s" forth-packages" s+
        copy_file
;

: fmix.new
    cr
    get_param
    save_package_name    
    type_message1
    create_package_directory drop
    copy_readme
    copy_package_file
    copy_main_file
    copy_license
    copy_packages
    copy_tests
;
