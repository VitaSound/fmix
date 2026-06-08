# fmix

[English version](README.md)

[![License](https://img.shields.io/badge/License-COPL-red.svg)](https://raw.githubusercontent.com/VitaSound/fmix/refs/heads/master/LICENSE)
[![Ver](https://img.shields.io/badge/Ver-0.7.3-green.svg)](https://github.com/VitaSound/fmix/releases/tag/0.7.3)
[![Cov](https://img.shields.io/badge/Cov-75%25-green.svg)](https://github.com/VitaSound/fmix/actions/workflows/ci.yml)

FMix — это сборочный инструмент, который умеет создавать пакеты,
устанавливать зависимости, запускать тесты и проверять минимальную
версию tooling-а.

```bash
$ fmix

FMix v0.6.0 — Forth package/build tool.
Usage: fmix <command> [args]
Commands:
   new <name>                                - Создать новый пакет
   packages.get                              - Установить зависимости
   test [--isolated|--shared] [<test_file>]  - Запустить все *_test.4th в
                                               ./tests или конкретный файл.
                                               --isolated (по умолчанию):
                                               каждый тест в отдельном
                                               процессе gforth.
                                               --shared: всё в одной сессии.
   version                                   - Версия
```

Часть [семейства инструментов VitaSound для
Forth](https://github.com/VitaSound): fmix (этот инструмент),
[flint](https://github.com/VitaSound/flint) (линтер),
[ttester](https://github.com/VitaSound/ttester) (тестовая утилита),
[fenum](https://github.com/VitaSound/fenum) (универсальные контейнеры).

## Установка

```bash
cd ~ && git clone git@github.com:VitaSound/fmix.git
```

## Настройка shell

В `~/.bashrc` (или `~/.zshrc`) — **две строки только для этого инструмента** (конвенция VitaSound: один инструмент — одна пара строк PATH; не объединять с соседями):

```bash
export FMIX_HOME="<install-dir>/fmix"
export PATH="$FMIX_HOME/bin:$PATH"
```

`<install-dir>` — родитель клонов (`$HOME` при feco в `~/feco`, или например `/opt/vitasound` для изолированного окружения). Массовая установка и готовый snippet: [VitaSound/feco](https://github.com/VitaSound/feco) — `./scripts/clone-ecosystem.sh`. Канон: [feco shell setup](https://github.com/VitaSound/feco/blob/main/docs/shell-setup.ru.md).

Затем `source ~/.bashrc` и `fmix version`.

**Не** используйте `alias fmix='gforth "$FMIX_HOME/fmix.4th" -e'` — только лаунчер `bin/fmix`.

Соседние CLI (flint, fcov, fmcp, fhdlgen) — свои пары строк: [feco shell setup](https://github.com/VitaSound/feco/blob/main/docs/shell-setup.ru.md).

## Привязка версии fmix (`key-value fmix ~> X.Y`)

fmix — это runtime-инструмент, а не библиотека. Поэтому проект
объявляет требование к версии fmix как top-level `key-value` (в духе
`elixir: "~> 1.15"` в `mix.exs`), а не как `key-list dependencies`:

```forth
forth-package
    key-value name myproj
    key-value version 0.0.1
    key-value main myproj.4th
    key-value fmix ~> 0.7
end-forth-package
```

| Запись | Что означает |
|--------|--------------|
| `key-value fmix ~> 0.7` | `>= 0.7.0` и `< 1.0.0` (MAJOR зафиксирован — pessimistic operator) |
| `key-value fmix ~> 0.7.2` | `>= 0.7.2` и `< 0.8.0` (MAJOR+MINOR зафиксированы) |
| `key-value fmix >= 0.7.0` | минимум, без верхней границы |
| `key-value fmix == 0.7.0` | ровно эта версия |
| `key-value fmix >  0.7.0` | строго больше |
| `key-value fmix <  1.0.0` | строго меньше |
| `key-value fmix <= 0.7.5` | меньше-или-равно |
| `key-value fmix 0.7.0`    | голая версия = `>= 0.7.0` |

Парсинг и матчинг делегированы отдельной библиотеке
[fsemver](https://github.com/VitaSound/fsemver) (вендорится в
`forth-packages/fsemver/0.1.0/`). flint и любой будущий инструмент
(fcov, …) используют тот же движок — никакого расхождения поведения
между линтерами и раннерами.

Если установленный fmix не подходит, команды уровня проекта (`fmix test`,
`fmix packages.get`) отказываются работать и пишут что-то вроде:

```
[ERROR] This project requires fmix ~> 0.7, but you have 0.6.5
        Update fmix (https://github.com/VitaSound/fmix) and retry.
```

Команды `fmix version` и `fmix help` намеренно работают всегда —
чтобы можно было посмотреть текущую версию, даже когда инструмент
отказывается выполнять работу.

**Миграция с 0.6.x.** Старый формат
```forth
key-list dependencies fmix 0.6.0
```
больше не поддерживается (fmix не лежит на theforth.net, и `packages.get`
получал бы HTTP 500). При загрузке такого `package.4th` fmix даёт
понятную ошибку с подсказкой — исправление в одну строку.

## Режимы `fmix test`

По умолчанию `fmix test` запускает каждый `*_test.4th` в **отдельном**
процессе Gforth (`--isolated`). Это закрывает большой класс багов
«утечка стека/глобального состояния в одном тесте маскирует проблему в
следующем», которая раньше регулярно стреляла.

Старое поведение (один процесс на все тесты) доступно как
`fmix test --shared` — полезно когда нужно специально ловить
кросс-тестовые утечки (например, `project-drop` забывает освободить
список).

## Публикация на theforth.net

[theforth.net](https://theforth.net/) — официальный реестр
Forth-пакетов. fmix умеет тянуть оттуда зависимости (`key-list
dependencies <name> <ver>`), но и сам fmix тоже не помешает туда
выложить — чтобы соседние проекты могли его прописать в `package.4th`.

Краткая инструкция (по [guidelines](https://theforth.net/guidelines)):

1. Создай аккаунт: <https://theforth.net/profile>.

2. Проверь свой `package.4th` — он должен соответствовать формату из
   guidelines:
   - обязательные поля: `name` (только `[a-z][-a-z0-9]*`), `version`
     в формате `MAJOR.MINOR.PATCH`, `license`, `main`,
   - желательные: `description`, `key-list tags …`,
   - `key-list dependencies <name> <version>` для зависимостей.

3. Собери архив. **Корневая папка в архиве должна точно совпадать с
   полем `name`** в `package.4th`, и сам `package.4th` лежит в её
   корне. Из `fmix`-репозитория это удобно делать так:

   ```bash
   cd ~                                          # на уровень выше fmix/
   tar czf fmix-0.6.0.tar.gz \
       --exclude='fmix/.git' \
       --exclude='fmix/forth-packages' \
       --exclude='fmix/build' \
       fmix
   ```

   (Аналогично для других проектов — поменять имя и версию.)

4. Залогинься на theforth.net, перейди в [Profile](https://theforth.net/profile)
   и загрузи архив через форму upload.

5. После публикации НЕ меняй `version` для уже загруженного слота —
   повышай его по SemVer:
   - **PATCH** — обратно-совместимый багфикс,
   - **MINOR** — обратно-совместимое добавление функциональности,
   - **MAJOR** — несовместимое изменение API.

   То же требование зашито в guidelines theforth.net.

## Лицензия

[COPL](LICENSE) — Communist Public License.
