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

## 4. Известные ограничения

- **Локальная сборка** может быть заблокирована нестабильной сетью (libvpx clone hang) — используйте CI
- **Автообновление отключено** — пользователи не получат обновления, нужно обновлять вручную через Releases
- **Updater не входит в архив** — только `Telegram` (или `Telegram.exe` / `Telegram.app`)

## 5. Структура репозитория

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
