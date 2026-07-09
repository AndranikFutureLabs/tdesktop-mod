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

## 🔄 Подмена exe-файлов из сборки CI

После скачивания архива из [Releases](https://github.com/AndranikFutureLabs/tdesktop-mod/releases) замените оригинальный бинарник Telegram на модифицированный.

### Windows x64

1. Скачайте `Telegram-Windows-x64-Qt6.zip` и распакуйте
2. Закройте Telegram Desktop если он запущен
3. Путь установки по умолчанию:
   ```
   %LOCALAPPDATA%\Programs\Telegram Desktop\
   ```
4. Сделайте резервную копию оригинального `Telegram.exe`:
   ```cmd
   copy "%LOCALAPPDATA%\Programs\Telegram Desktop\Telegram.exe" "%LOCALAPPDATA%\Programs\Telegram Desktop\Telegram_original.exe"
   ```
5. Скопируйте модифицированный `Telegram.exe` в папку установки с заменой
6. Удалите `Updater.exe` из папки установки (автообновление отключено)
7. Запустите Telegram — мод активен

### macOS

1. Скачайте `Telegram-macOS.zip` и распакуйте
2. Закройте Telegram если он запущен
3. Путь установки: `/Applications/Telegram.app`
4. Сделайте резервную копию:
   ```bash
   cp -R /Applications/Telegram.app /Applications/Telegram_original.app
   ```
5. Замените `Telegram.app`:
   ```bash
   cp -R ~/Downloads/Telegram.app /Applications/Telegram.app
   ```
6. Снимите quarantine (если macOS блокирует запуск):
   ```bash
   xattr -cr /Applications/Telegram.app
   ```
7. Если в `/Applications/Telegram.app/Contents/MacOS/` есть `Updater` — удалите его
8. Запустите Telegram — мод активен

### Linux

1. Скачайте `Telegram-Linux.zip` и распакуйте
2. Закройте Telegram если он запущен
3. Путь установки зависит от дистрибутива:

   | Способ установки | Путь |
   |-----------------|------|
   | Ручная установка | `~/Telegram/Telegram` или `~/Downloads/Telegram/Telegram` |
   | Flatpak | `/var/lib/flatpak/app/org.telegram.desktop/` |
   | Snap | `/snap/telegram-desktop/current/` |
   | .AppImage | путь к `.AppImage` файлу |

4. Сделайте резервную копию:
   ```bash
   cp ~/Telegram/Telegram ~/Telegram/Telegram_original
   ```
5. Скопируйте модифицированный бинарник:
   ```bash
   cp ~/Downloads/Telegram ~/Telegram/Telegram
   chmod +x ~/Telegram/Telegram
   ```
6. Если в папке установки есть `Updater` — удалите его
7. Запустите Telegram — мод активен

### ✅ Проверка работы мода

1. Откройте любой защищённый канал (с иконкой 🔒 или где запрещено пересылать)
2. Правый клик на сообщение → должна быть кнопка **"Переслать"**
3. Правый клик на фото/видео → должна быть кнопка **"Сохранить"**
4. Текст можно выделить и скопировать
5. Тост "Копирование запрещено" не появляется

### ↩️ Возврат к оригиналу

| OS | Действие |
|----|----------|
| Windows | Переименовать `Telegram_original.exe` → `Telegram.exe` |
| macOS | Удалить мод, переименовать `Telegram_original.app` → `Telegram.app` |
| Linux | Скопировать `Telegram_original` → `Telegram` |

---

<div align="center">

*Модификация подготовлена [@AndranikFutureLabs](https://t.me/AndranikFutureLabs). Версия V3.1.0.*

</div>
