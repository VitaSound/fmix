\ fmix_new.4th
\ Создание нового пакета

2VARIABLE pkg-name-data

: set-pkg-name ( addr u -- )
    str-dup pkg-name-data 2! ;

: get-pkg-name ( -- addr u )
    pkg-name-data 2@ ;

: get-priv-path ( -- addr u )
    get-home-path s" fmix/priv/" str-concat ;

: get-target-path ( -- addr u )
    \ Используем "." для текущей директории
    s" ." s" /" str-concat get-pkg-name str-concat ;

\ --- Операции ---

: install-file { name-a name-u -- }
    name-a name-u s"   > Copying file: " type type cr
    
    \ Source: priv/name
    get-priv-path name-a name-u str-concat { src-a src-u }
    
    \ Dest: target/name
    get-target-path name-a name-u fs-join { dst-a dst-u }
    
    src-a src-u dst-a dst-u cp-file
;

: install-dir { name-a name-u -- }
    name-a name-u s"   > Copying dir:  " type type cr
    
    \ Source
    get-priv-path name-a name-u str-concat { src-a src-u }
    
    \ Dest (cp -r требует папку назначения, внутрь которой копируем)
    get-target-path s" /" str-concat { dst-a dst-u }
    
    src-a src-u dst-a dst-u cp-dir
;

: install-main-file ( -- )
    s"   > Copying main.4th..." type cr
    
    \ Source: main.4th
    get-priv-path s" main.4th" str-concat { src-a src-u }
    
    \ Dest: target/<pkgname>.4th
    get-target-path
    get-pkg-name s" .4th" str-concat
    fs-join { dst-a dst-u }
    
    src-a src-u dst-a dst-u cp-file
;

: fmix.new ( -- )
    cr s" * Creating package: " type get-pkg-name type cr

    get-target-path ensure-dir

    s" LICENSE"     install-file
    s" package.4th" install-file
    s" README.md"   install-file
    
    install-main-file

    s" tests"          install-dir
    s" forth-packages" install-dir

    \ --- Шаблоны (Исправлен порядок аргументов fs-join) ---
    
    \ Было: s" package.4th" get-target-path fs-join (ОШИБКА)
    \ Стало: get-target-path s" package.4th" fs-join (OK: папка + файл)
    
    get-target-path s" package.4th" fs-join 
    s" <name>" get-pkg-name replace-in-file

    get-target-path s" README.md"   fs-join
    s" <name>" get-pkg-name replace-in-file

    s" * Done." type cr 
;
