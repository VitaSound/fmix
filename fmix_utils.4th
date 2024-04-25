: prepend 2swap s+ ;

: copy_file ( src target -- )
    s"  " prepend s+ s" cp " prepend
    system
;

: sed ( path from to -- )
    s" sed -i 's/" 2rot s+ s" /" s+ prepend s" /g' " s+ prepend
    system
;

\ directories
-529 constant error-exists
: create-directories ( c-addr n -- ior )
    $1FF mkdir-parents      \ add mask
    dup error-exists = if   \ ignore error-exists
        drop 0
    then ;