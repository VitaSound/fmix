\ tests/fmix_utils_test.4th
\ Тестирование базовых функций fmix_utils.4th
require ../fmix_utils.4th
fmix.home-path s" forth-packages/ttester/1.2.1/ttester.4th" fmix.fs-join required

\ test fmix.str-concat
T{ s" abc" s" def" fmix.str-concat s" abcdef" compare -> 0 }T

\ test fmix.str-dup 
T{ s" abc" fmix.str-dup s" abc" compare -> 0 }T

\ test fmix.fs-join
\ Тест 1: базовый случай
T{ s" /home/user" s" project" fmix.fs-join s" /home/user/project" compare -> 0 }T

\ Тест 2: путь без завершающего слэша
T{ s" /a" s" b" fmix.fs-join s" /a/b" compare -> 0 }T

\ Тест 3: пустое имя (крайний случай)
T{ s" /dir" s" " fmix.fs-join s" /dir/" compare -> 0 }T

\ Тест 4: пустой путь
T{ s" " s" file" fmix.fs-join s" /file" compare -> 0 }T

T{  s" part1" s" part2" s" part3" fmix.str-concat fmix.str-concat s" part1part2part3" compare -> 0 }T

\ validation helpers (positive cases only; ttester mishandles some negative T{ tests)
T{ s" fmix_pkg" fmix.package-name-ok? 0<> -> true }T
T{ s" ./forth-packages/f/0.2.4" fmix.path-ok? 0<> -> true }T
T{ s" https://github.com/VitaSound/f.git" fmix.url-ok? 0<> -> true }T

