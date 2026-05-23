# fmix

[English version](README.md)

[![License](https://img.shields.io/badge/License-COPL-red.svg)](https://raw.githubusercontent.com/VitaSound/fmix/refs/heads/master/LICENSE)
[![Ver](https://img.shields.io/badge/Ver-0.6.0-green.svg)](https://github.com/VitaSound/fmix/releases/tag/0.6.0)

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

В `~/.bashrc` (или `~/.zshrc`):

```bash
# Инструменты VitaSound для Forth
export PATH="$HOME/fmix/bin:$HOME/flint/bin:$PATH"
```

Если fmix лежит не в `$HOME/fmix`, экспортируйте `$FMIX_HOME` перед
вызовом.

Проверка:

```bash
source ~/.bashrc
fmix version
```

## Привязка минимальной версии (version pinning)

В `package.4th` проекта можно зафиксировать минимально требуемую версию
fmix через самозависимость:

```forth
forth-package
    key-value name myproj
    key-value version 0.0.1
    key-value main myproj.4th
    key-list dependencies fmix 0.6.0
end-forth-package
```

Если зайти в такой проект и попытаться запустить более старый fmix,
команды уровня проекта (`fmix test`, `fmix packages.get`) откажутся
работать и скажут:

```
[ERROR] This project requires fmix 0.6.0 or higher, but you have 0.5.1
        Update fmix (https://github.com/VitaSound/fmix) and retry.
```

Команды `fmix version` и `fmix help` намеренно работают всегда — чтобы
вы могли посмотреть, какая у вас версия, даже когда инструмент
отказывается выполнять работу.

## Режимы `fmix test`

По умолчанию `fmix test` запускает каждый `*_test.4th` в **отдельном**
процессе Gforth (`--isolated`). Это закрывает большой класс багов
«утечка стека/глобального состояния в одном тесте маскирует проблему в
следующем», которая раньше регулярно стреляла.

Старое поведение (один процесс на все тесты) доступно как
`fmix test --shared` — полезно когда нужно специально ловить
кросс-тестовые утечки (например, `project-drop` забывает освободить
список).

## Лицензия

[COPL](LICENSE) — Communist Public License.
