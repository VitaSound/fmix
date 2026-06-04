# ttester (форк VitaSound)

[English version](README.md)

Утилита для тестирования слов Forth, исходно написанная Джоном Хейзом
(1995, JHU/APL), с последующими правками от Антона Эртла, Дэвида Уильямса,
Кришны Миньяни и К. Г. Монтгомери.

Этот форк живёт на https://github.com/VitaSound/ttester.

Часть [семейства инструментов VitaSound для
Forth](https://github.com/VitaSound):
[fmix](https://github.com/VitaSound/fmix) (сборка / пакетный менеджер /
тест-раннер), [flint](https://github.com/VitaSound/flint) (линтер),
ttester (этот форк), [fenum](https://github.com/VitaSound/fenum)
(универсальные контейнеры).

## Что наверху, что внизу

Оригинальный `ttester.4th` сохранён **байт-в-байт**, чтобы форк мог
тянуть будущие апстримовые правки. Все наши добавки лежат отдельно в
`ttester-ext.4th`. Апстрим:
http://www.complang.tuwien.ac.at/cvsweb/cgi-bin/cvsweb/gforth/test/ttester.fs

## Структура

| Файл | Что |
|------|-----|
| `ttester.4th` | Hayes/Ertl-овский `T{ ... -> ... }T` — без изменений |
| `ttester-ext.4th` | расширения VitaSound (только в этом форке), см. ниже |
| `tests/ttester_ext_test.4th` | тесты на каждое расширение |

## Базовое использование (апстрим)

```forth
require ttester.4th

T{ 1 2 + -> 3 }T
T{ 1 2 3 SWAP -> 1 3 2 }T
```

Плавающую точку (`R}T`, `XR}T`, `RXR}T` и т. п.) — см. в шапке
`ttester.4th`.

## Расширения (`ttester-ext.4th`)

```forth
require ttester.4th
require ttester-ext.4th
```

### Предикаты

| Слово | Стек | Проверяет |
|-------|------|-----------|
| `expect-true`  | `f --` | `f <> 0` |
| `expect-false` | `f --` | `f = 0` |
| `expect-eq`    | `a b --` | `a = b` |
| `expect-not-eq` | `a b --` | `a <> b` |
| `expect-depth` | `n --` | глубина стека под `n` равна `n` |
| `expect-stack-clean` | `--` | `DEPTH = 0` |
| `expect-stack-balanced` | `--` | `DEPTH = START-DEPTH` (использовать внутри `T{`) |
| `expect-str-eq` | `a1 u1 a2 u2 --` | `COMPARE = 0` |

Все ошибки идут через стандартный `ERROR` ttester'а, так что счётчик
`#ERRORS` и хук `ERROR-XT` продолжают работать как раньше.

### Фикстуры

```forth
DEFER test-setup        ( по умолчанию: noop )
DEFER test-teardown     ( по умолчанию: noop )

TS{ ... }ST             \ как T{ ... }T, но вокруг тела вызовутся
                        \ test-setup до и test-teardown после
```

Пример — убрать копипасту `project-new` / `project-drop` из каждого
теста:

```forth
:noname project-new ; is test-setup
:noname project-drop ; is test-teardown

TS{ project.name@ s" foo" expect-str-eq -> }ST
TS{ project.modules@ ulist-len 0 expect-eq -> }ST
```

В режиме `fmix test --shared` не забудьте сбросить хуки в конце файла
(`' noop is test-setup ...`), иначе они утекут в следующий тест.

## Публикация на theforth.net

[theforth.net](https://theforth.net/) — официальный реестр
Forth-пакетов. ttester отлично туда ложится, потому что не требует
никакой инфраструктуры — обычный одиночный `.4th`-файл.

Краткая инструкция (по [guidelines](https://theforth.net/guidelines)):

1. Создай аккаунт: <https://theforth.net/profile>.

2. Проверь `package.4th` — у ttester он уже под guidelines:
   обязательные поля (`name`, `version` `MAJOR.MINOR.PATCH`,
   `license`, `main`) и желательные (`description`, `tags`).

3. Собери архив. **Корневая папка в архиве должна точно совпадать с
   полем `name`** (`ttester`), и `package.4th` лежит в её корне:

   ```bash
   cd ~                                              # на уровень выше ttester/
   tar czf ttester-1.2.0.tar.gz \
       --exclude='ttester/.git' \
       --exclude='ttester/forth-packages' \
       --exclude='ttester/build' \
       ttester
   ```

4. Залогинься на theforth.net, перейди в
   [Profile](https://theforth.net/profile) и загрузи архив через форму
   upload.

5. После публикации НЕ меняй `version` для уже выложенного слота —
   повышай его по SemVer:
   - **PATCH** — обратно-совместимый багфикс,
   - **MINOR** — обратно-совместимое добавление функциональности,
   - **MAJOR** — несовместимое изменение API.

## Лицензия

`ttester.4th` — public domain (по шапке апстрима).
`ttester-ext.4th` и остальной код форка — public domain.
