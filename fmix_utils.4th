: str_prepend 2swap s+ ;

: touch_file ( filename -- )
    s" touch " str_prepend system
;

: delete_file ( filename -- )
    s" rm " str_prepend system
;

: copy_file ( src target -- )
    s"  " str_prepend s+ s" cp " str_prepend
    system
;

: sed ( path from to -- )
    s" sed -i 's/" 2rot s+ s" /" s+ str_prepend s" /g' " s+ str_prepend
    system
;

\ directories
-529 constant dirs-error-exists
: fmix-create-directories ( c-addr n -- ior )
    $1FF mkdir-parents      \ add mask
    dup dirs-error-exists = if   \ ignore error-exists
        drop 0
    then ;