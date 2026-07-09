# Telegram Desktop Mod — Andranik Future Labs

![Andranik Future Labs](mod.png)

<div align="center">

**Модификация Telegram Desktop для снятия ограничений на контент в защищённых каналах и группах.**

[![Release](https://img.shields.io/github/v/release/AndranikFutureLabs/tdesktop-mod?style=flat-square&label=Релиз)](https://github.com/AndranikFutureLabs/tdesktop-mod/releases)
[![Build](https://img.shields.io/github/actions/workflow/status/AndranikFutureLabs/tdesktop-mod/build-mod.yml?style=flat-square&label=CI)](https://github.com/AndranikFutureLabs/tdesktop-mod/actions)
[![Platform](https://img.shields.io/badge/платформы-Windows%20%7C%20macOS%20%7C%20Linux-blue?style=flat-square)](https://github.com/AndranikFutureLabs/tdesktop-mod/releases)
[![Node.js](https://img.shields.io/badge/Node.js-24-green?style=flat-square)](https://github.com/AndranikFutureLabs/tdesktop-mod)

[📥 Скачать](https://github.com/AndranikFutureLabs/tdesktop-mod/releases) · [📖 Инструкция по изменениям](docs/telegramdestop_mod_AndranikFutureLabs_V2.md) · [🔧 Проблемы сборки](docs/telegramdestop_mod_AndranikFutureLabs_AssemblyProblemsAndSolutions_V2.md)

</div>

---

## 📋 Возможности

| # | Функция | Описание |
|---|---------|----------|
| 1 | **Пересылка сообщений** | Кнопка "Переслать" доступна всегда — для одного и нескольких сообщений |
| 2 | **Сохранение медиа** | Видео, изображения и документы из защищённых каналов |
| 3 | **Копирование текста** | Выделение и копирование текста из защищённых каналов |
| 4 | **Без автообновления** | Мод не затирается официальным обновлением Telegram |

## 📥 Скачать

Готовые сборки доступны в [**GitHub Releases**](https://github.com/AndranikFutureLabs/tdesktop-mod/releases):

| Платформа | Файл | Размер |
|-----------|------|--------|
| Windows x64 | `Telegram-Windows-x64-Qt6.zip` | ~114 MB |
| macOS | `Telegram-macOS.zip` | ~376 MB |
| Linux | `Telegram-Linux.zip` | ~174 MB |

## 📂 Изменённые файлы

Исходный код изменений — в папке [`src_changes/`](src_changes/). Все патчи помечены `// Mod:`.

| # | Файл | Что патчено |
|---|------|-------------|
| 1 | `history/history_item.cpp` | `allowsForward()` — убраны проверки `forbidsForward()` и `peer->allowsForwarding()` |
| 2 | `history/view/history_view_context_menu.cpp` | Обход `allowsForward` для пересылки одного и выбранных сообщений |
| 3 | `history/history_inner_widget.cpp` | `hasSelectRestriction()`, `hasCopyRestriction()`, `hasCopyMediaRestriction()`, `hasCopyRestrictionForSelected()` → `return false` |
| 4 | `history/view/history_view_list_widget.cpp` | Те же функции в `ListWidget` + `showCopyRestriction()` → `return false` + `CopyRestrictionTypeFor()` → `return None` |
| 5 | `history/view/media/history_view_save_document_action.cpp` | Без изменений — работает через обход `hasCopyMediaRestriction` |

### Как это работает

- **`HistoryItem::allowsForward()`** — корневая проверка на уровне данных. Игнорирует флаги `noforwards` и `forbidsForward()`, возвращает `true` для всех регулярных сообщений → кнопка "Переслать" всегда доступна
- **`ListWidget` + `HistoryInner`** — все restriction-функции возвращают `false`. UI считает, что чат не имеет ограничений → доступны выделение, копирование, сохранение
- **`showCopyRestriction()`** → `return false` — тост "Копирование запрещено" не показывается

## 🔧 Сборка

Базируется на `dev` ветке [telegramdesktop/tdesktop](https://github.com/telegramdesktop/tdesktop).

**Требования:** Visual Studio 2022+, Qt 6, CMake 3.25+, Python 3.11+, Node.js 24+

```cmd
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
python Telegram/build/prepare/prepare.py qt6
cmake -B out -G "Visual Studio 17 2022" -A x64 -DCMAKE_BUILD_TYPE=Debug ^
  -D TDESKTOP_API_TEST=ON ^
  -D DESKTOP_APP_DISABLE_AUTOUPDATE=ON
cmake --build out --config Debug --target Telegram
```

Подробности: [📖 Инструкция по изменениям](docs/telegramdestop_mod_AndranikFutureLabs_V2.md) · [🔧 Проблемы сборки](docs/telegramdestop_mod_AndranikFutureLabs_AssemblyProblemsAndSolutions_V2.md)

## ⚙️ CI/CD

| Workflow | Описание |
|----------|----------|
| **Build Mod** | Сборка на Windows/macOS/Linux (Qt6, Node 24), автообновление отключено |
| **Release** | Автопубликация GitHub Release с артефактами при пуше тега `v*` |
| **Waiting for answer** | Автоуправление issues с меткой "waiting for answer" |

Сборка запускается автоматически при пуше в `main` или при создании тега `v*`.

## 📖 Документация

- [Инструкция по изменениям (MD)](docs/telegramdestop_mod_AndranikFutureLabs_V2.md) — подробное описание всех патчей
- [Решение проблем при сборке (MD)](docs/telegramdestop_mod_AndranikFutureLabs_AssemblyProblemsAndSolutions_V2.md) — CI/CD проблемы и решения

---

<div align="center">

*Модификация подготовлена [@AndranikFutureLabs](https://t.me/AndranikFutureLabs). Версия V3.1.0.*

</div>
