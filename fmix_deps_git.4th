\ fmix_deps_git.4th
\ Логика работы с Git-зависимостями.
\ Исправлен Stack Underflow (убраны лишние drop).

\ Локальные переменные модуля
variable git-url-a        variable git-url-u
variable git-ref-a        variable git-ref-u
variable git-type-a       variable git-type-u
variable git-path-a       variable git-path-u

: git-calc-path ( -- )
    dep-base-path-a @ dep-base-path-u @
    cur-pkg-name-a @ cur-pkg-name-u @
    fs-join
    
    git-ref-a @ git-ref-u @
    fs-join
    
    git-path-u ! git-path-a ! 
;

\ --- Проверки ---

: target-exists? ( -- f )
    git-path-a @ git-path-u @ file-status nip 0= ;

: is-git-repo? ( -- f )
    git-path-a @ git-path-u @ s" /.git" str-concat
    file-status nip 0= ;

: remove-target-dir ( -- )
    s" rm -rf " git-path-a @ git-path-u @ str-concat system-checked ;

\ --- Git команды ---

: is-branch? ( -- f )
    git-type-a @ git-type-u @ s" branch" compare 0= ;

: git-pull-branch ( -- )
    s" git -C " git-path-a @ git-path-u @ str-concat
    s"  checkout " str-concat 
    git-ref-a @ git-ref-u @ str-concat
    s"  ; git -C " str-concat
    git-path-a @ git-path-u @ str-concat
    s"  pull origin " str-concat
    git-ref-a @ git-ref-u @ str-concat
    s"  --force" str-concat
    system-checked ;

: git-pull-tag ( -- )
    s" git -C " git-path-a @ git-path-u @ str-concat
    s"  fetch origin --tags --force" str-concat
    
    s"  ; git -C " str-concat
    git-path-a @ git-path-u @ str-concat
    s"  -c advice.detachedHead=false checkout --force " str-concat
    git-ref-a @ git-ref-u @ str-concat
    system-checked ;

: git-update-logic ( -- )
    is-branch? IF git-pull-branch ELSE git-pull-tag THEN ;

: git-clone ( -- )
    s" git -c advice.detachedHead=false clone -b " 
    git-ref-a @ git-ref-u @ str-concat
    s"  " str-concat
    git-url-a @ git-url-u @ str-concat
    s"  " str-concat
    git-path-a @ git-path-u @ str-concat
    system ; \ system ничего не возвращает на стек!

\ --- Основной процесс ---

: process-git-dep ( -- )
    git-calc-path
    
    s" * [GIT] " type cur-pkg-name-a @ cur-pkg-name-u @ type 
    s"  (" type git-type-a @ git-type-u @ type s" ) -> " type 
    git-path-a @ git-path-u @ type cr

    target-exists? IF
        is-git-repo? IF
            s"   Checking updates..." type cr
            git-update-logic
            s"   Update OK" type cr
        ELSE
            s"   Folder exists but not a Git repo. Re-cloning..." type cr
            remove-target-dir
            
            \ ИСПРАВЛЕНО: убран drop. git-clone ничего не кладет на стек.
            git-clone 
            
            s"   Clone OK" type cr
        THEN
    ELSE
        \ ИСПРАВЛЕНО: убран drop.
        git-clone 
        
        s"   Clone OK" type cr
    THEN
;

: parse-git-args ( -- )
    parse-name str-dup git-url-u ! git-url-a !
    parse-name str-dup git-type-u ! git-type-a !
    parse-name str-dup git-ref-u ! git-ref-a !
    process-git-dep ;
