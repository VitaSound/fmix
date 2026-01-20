\ fmix_version.4th
\ Чтение версии fmix из package.4th

require fmix_utils.4th

\ Глобальная переменная для версии (останется после очистки)
2VARIABLE fmix-ver-data
s" unknown" fmix-ver-data 2!

\ --- Временная логика парсинга ---
\ Используем MARKER, чтобы удалить эти слова после отработки
\ и не конфликтовать с модулем fmix_packages_get.4th
MARKER discard-parser-words

: forth-package ; 
: end-forth-package ;

: key-list ( -- )
    \ Игнорируем списки (dependencies и т.д.)
    0 parse 2drop ;

: key-value ( -- )
    parse-name 
    s" version" compare 0= IF
        \ Если ключ "version", сохраняем значение
        parse-name str-dup fmix-ver-data 2!
    ELSE
        \ Иначе пропускаем строку
        0 parse 2drop
    THEN ;

: load-self-version
    \ Читаем ~/fmix/package.4th
    get-home-path s" fmix/package.4th" str-concat
    
    2dup file-status nip 0= IF
        included
    ELSE
        2drop
        s" [WARNING] Could not read fmix version." type cr
    THEN ;

\ Выполняем чтение прямо сейчас
load-self-version

\ Удаляем временные слова (key-value, key-list и т.д.) из словаря
discard-parser-words
