# Telegram Desktop Mod: Проблемы сборки и решения (V3.1.0)
## Проект: @AndranikFutureLabs

Документ описывает технические сложности при сборке модифицированного Telegram Desktop и методы их решения.

## 1. CI/CD (GitHub Actions)

### Сборка на 3 платформах
Мод собирается через GitHub Actions на Windows, macOS и Linux с использованием Qt6 и Node.js 24.

**Файл:** `.github/workflows/build-mod.yml`

Ключевые параметры сборки:
```yaml
- TDESKTOP_API_TEST=ON
- DESKTOP_APP_DISABLE_AUTOUPDATE=ON   # мод не затирается официальным обновлением
- DESKTOP_APP_DISABLE_CRASH_REPORTS=OFF
```

### Автопубликация релизов
При пуше тега `v*` автоматически запускается job `release`, который:
1. Скачивает артефакты всех 3 платформ (по pattern `Telegram-*`, минуя Docker cache)
2. Запаковывает каждый в ZIP
3. Создаёт GitHub Release с автогенерированными notes

```yaml
release:
  needs: [windows, macos, linux]
  if: startsWith(github.ref, 'refs/tags/v')
  steps:
    - uses: actions/download-artifact@v4
      with:
        pattern: Telegram-*
    - uses: softprops/action-gh-release@v2
```

### Waiting for answer
Workflow для автоуправления issues с меткой "waiting for answer". Требует `permissions: issues: write` для создания лейблов через GITHUB_TOKEN.

## 2. Решённые проблемы CI

### Проблема: "Resource not accessible by integration"
**Причина:** `waiting-for-answer` workflow не имел прав на создание лейблов.
**Решение:** Добавить `permissions: issues: write` в job.

### Проблема: "Artifact download failed after 5 retries"
**Причина:** Job `release` пытался скачать ALL артефакты, включая Docker build cache (`AndranikFutureLabs~tdesktop-mod~*.dockerbuild`), который не скачивается.
**Решение:** Использовать `pattern: Telegram-*` в `download-artifact`.

### Проблема: "Move artifact" failed — Updater not found
**Причина:** При `DESKTOP_APP_DISABLE_AUTOUPDATE=ON` бинарник `Updater` не собирается, но шаг "Move artifact" пытался его переместить.
**Решение:** Убрать `Updater` из всех шагов Move artifact (Windows, macOS, Linux).

### Проблема: macOS `-Wunused-but-set-variable`
**Причина:** После удаления проверки `allowsForward` в context_menu, переменная `group` осталась неиспользованной в пустом `if(group){}` блоке.
**Решение:** Удалить весь блок `if(asGroup) { if(const auto group=...) {} }`.

## 3. Локальная сборка (Windows)

### Требования
- Visual Studio 2022+, Qt 6, CMake 3.25+, Python 3.11+, Node.js 24+
- Windows SDK 10.0.26100.0+

### Команды
```cmd
:: Установка переменных окружения Visual Studio
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"

:: Запуск скрипта подготовки
python Telegram/build/prepare/prepare.py qt6

:: Генерация и сборка
cmake -B out -G "Visual Studio 17 2022" -A x64 -DCMAKE_BUILD_TYPE=Debug ^
  -D TDESKTOP_API_TEST=ON ^
  -D DESKTOP_APP_DISABLE_AUTOUPDATE=ON

cmake --build out --config Debug --target Telegram
```

### Модификация prepare.py (для VS 2026 Insiders)

При сборке на Visual Studio 2026 (v18) Insiders потребовались правки `prepare.py`:

**Исправление кодировки (UTF-8):**
```python
currentCodePage = subprocess.run('chcp', capture_output=True, shell=True, text=True, env=modifiedEnv).stdout.strip().split()[-1]
subprocess.run('chcp 65001 > nul', shell=True, env=modifiedEnv)
runStages()
subprocess.run('chcp ' + currentCodePage + ' > nul', shell=True, env=modifiedEnv)
```

**Автозамена Toolset:**
```python
commands = commands.replace('v140', 'v143').replace('v141', 'v143').replace('v142', 'v143')
commands = commands.replace('Visual Studio 17 2022', 'Visual Studio 18 2026')
```

**Патчинг Breakpad:**
```python
if stage['name'] == 'breakpad':
    patch_cmd = 'python -c "import glob; [open(f, \'wb\').write(open(f, \'rb\').read().replace(b\'v140\', b\'v143\').replace(b\'v141\', b\'v143\').replace(b\'v142\', b\'v143\')) for f in glob.glob(\'**/*.vcxproj\', recursive=True)]"'
```

## 4. Подмена exe-файлов из сборки CI

После скачивания артефактов из [GitHub Releases](https://github.com/AndranikFutureLabs/tdesktop-mod/releases) или GitHub Actions, бинарники нужно подставить в установленную копию Telegram Desktop.

### Windows x64

1. Скачайте `Telegram-Windows-x64-Qt6.zip` и распакуйте
2. В архиве: `Telegram.exe` (мод)
3. Закройте Telegram Desktop если он запущен
4. Путь установки по умолчанию:
   ```
   %LOCALAPPDATA%\Programs\Telegram Desktop\
   ```
   либо туда, куда вы установили Telegram
5. Сделайте резервную копию оригинального `Telegram.exe`:
   ```cmd
   copy "%LOCALAPPDATA%\Programs\Telegram Desktop\Telegram.exe" "%LOCALAPPDATA%\Programs\Telegram Desktop\Telegram_original.exe"
   ```
6. Скопируйте модифицированный `Telegram.exe` в папку установки с заменой
7. Запустите Telegram — мод активен

> **Примечание:** `Updater.exe` в архиве отсутствует (автообновление отключено). Удалите `Updater.exe` из папки установки, чтобы Telegram не пытался обновиться.

### macOS

1. Скачайте `Telegram-macOS.zip` и распакуйте
2. В архиве: `Telegram.app` (мод)
3. Закройте Telegram если он запущен
4. Путь установки по умолчанию:
   ```
   /Applications/Telegram.app
   ```
5. Сделайте резервную копию:
   ```bash
   cp -R /Applications/Telegram.app /Applications/Telegram_original.app
   ```
6. Замените `Telegram.app`:
   ```bash
   # Если скачан в ~/Downloads
   cp -R ~/Downloads/Telegram.app /Applications/Telegram.app
   ```
   Если был скачан из Quarantine (атрибут `com.apple.quarantine`):
   ```bash
   xattr -cr /Applications/Telegram.app
   ```
7. Запустите Telegram — мод активен

> **Примечание:** `Updater` в архиве отсутствует. Если в `/Applications/Telegram.app/Contents/MacOS/` есть `Updater` — удалите его.

### Linux

1. Скачайте `Telegram-Linux.zip` и распакуйте
2. В архиве: `Telegram` (мод, ELF-бинарник)
3. Закройте Telegram если он запущен
4. Путь установки зависит от дистрибутива:
   - **Ручная установка:** `~/Downloads/Telegram/Telegram` или `~/Telegram/Telegram`
   - **Flatpak:** `/var/lib/flatpak/app/org.telegram.desktop/`
   - **Snap:** `/snap/telegram-desktop/current/`
   - **Официальный .AppImage:** путь к `.AppImage` файлу
5. Сделайте резервную копию:
   ```bash
   cp ~/Telegram/Telegram ~/Telegram/Telegram_original
   ```
6. Скопируйте модифицированный бинарник:
   ```bash
   cp ~/Downloads/Telegram ~/Telegram/Telegram
   chmod +x ~/Telegram/Telegram
   ```
7. Запустите Telegram — мод активен

> **Примечание:** `Updater` в архиве отсутствует. Если в папке установки есть `Updater` — удалите его.

### Проверка работы мода

1. Откройте любой защищённый канал (с иконкой 🔒 или где запрещено пересылать)
2. Правый клик на сообщение → должна быть кнопка **"Переслать"**
3. Правый клик на фото/видео → должна быть кнопка **"Сохранить"**
4. Текст можно выделить и скопировать
5. Тост "Копирование запрещено" не появляется

### Возврат к оригиналу

Если нужно вернуть оригинальный Telegram:

| OS | Действие |
|----|----------|
| Windows | Переименовать `Telegram_original.exe` → `Telegram.exe` |
| macOS | Удалить мод, переименовать `Telegram_original.app` → `Telegram.app` |
| Linux | Скопировать `Telegram_original` → `Telegram` |

## 5. Известные ограничения

- **Локальная сборка** может быть заблокирована нестабильной сетью (libvpx clone hang) — используйте CI
- **Автообновление отключено** — пользователи не получат обновления, нужно обновлять вручную через Releases
- **Updater не входит в архив** — только `Telegram` (или `Telegram.exe` / `Telegram.app`)

## 6. Структура репозитория

```
tdesktop-mod/
├── Telegram/              # исходный код (с патчами)
├── docs/                  # документация
│   ├── telegramdestop_mod_AndranikFutureLabs_V2.md          # инструкция по изменениям
│   └── telegramdestop_mod_AndranikFutureLabs_AssemblyProblemsAndSolutions_V2.md  # проблемы и решения
├── src_changes/           # копии изменённых файлов
│   ├── history_item.cpp
│   ├── history_inner_widget.cpp
│   ├── history_view_context_menu.cpp
│   ├── history_view_list_widget.cpp
│   └── history_view_save_document_action.cpp
├── .github/workflows/
│   ├── build-mod.yml      # сборка + релиз
│   └── waiting-for-answer.yml
└── README.md
```

---
*Документация подготовлена @AndranikFutureLabs. Версия V3.1.0.*
