# Telegram Desktop - mod AndranikFutureLabs

![Andranik Future Labs](mod.png)

Данная модификация Telegram Desktop (@AndranikFutureLabs) направлена на снятие ограничений, накладываемых владельцами каналов и групп на контент. Основная цель — обеспечить пользователю полный контроль над данными, включая возможность сохранения медиафайлов и пересылки сообщений из защищенных чатов.

## Возможности

1. **Сохранение видео и изображений из защищённых каналов** — обход ограничения `noforwards` и `forbidsSaving`
2. **Пересылка сообщений из защищённых каналов** — кнопка "Переслать" доступна всегда, для одного и нескольких сообщений
3. **Копирование и выделение текста** — `hasSelectRestriction`, `hasCopyRestriction`, `hasCopyMediaRestriction` всегда возвращают `false`
4. **Сохранение документов** — принудительное включение "Сохранить как" для всех медиафайлов
5. **Автообновление отключено** — мод не будет затёрт официальным обновлением Telegram

## Изменённые файлы

Исходный код изменений доступен в папке `src_changes/`.

| # | Файл | Что патчено |
|---|------|-------------|
| 1 | `history/history_item.cpp` | `allowsForward()` — убраны проверки `forbidsForward()` и `peer->allowsForwarding()` |
| 2 | `history/view/history_view_context_menu.cpp` | Обход `allowsForward` для пересылки单个 и выбранных сообщений |
| 3 | `history/history_inner_widget.cpp` | `hasSelectRestriction()`, `hasCopyRestriction()`, `hasCopyMediaRestriction()`, `hasCopyRestrictionForSelected()` → `return false` |
| 4 | `history/view/history_view_list_widget.cpp` | Те же функции в `ListWidget` + `showCopyRestriction()` → `return false` + `CopyRestrictionTypeFor()` и `CopyMediaRestrictionTypeFor()` → `return None` |
| 5 | `history/view/media/history_view_save_document_action.cpp` | Без изменений — работает через обход `hasCopyMediaRestriction` |

Все патчи помечены комментариями `// Mod:` для удобства поиска.

## Сборка

Базируется на последней версии `dev` ветки [telegramdesktop/tdesktop](https://github.com/telegramdesktop/tdesktop).

Требования: Visual Studio 2022+, Qt 6, CMake 3.25+, Python 3.11+, Node.js 24+.

```cmd
:: Установка переменных окружения Visual Studio
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"

:: Запуск скрипта подготовки
python Telegram/build/prepare/prepare.py qt6

:: Генерация и сборка
cmake -B out -G "Visual Studio 17 2022" -A x64 -DCMAKE_BUILD_TYPE=Debug
cmake --build out --config Debug --target Telegram
```

## CI/CD

- **Build Mod** — сборка на Windows, macOS, Linux (Qt6, Node.js 24), автообновление отключено
- **Release** — автоматическая публикация GitHub Release с артефактами при пуше тега `v*`
- **Waiting for answer** — автоуправление issues с меткой "waiting for answer"

Сборка запускается автоматически при пуше в `main` или при создании тега `v*`.

## Скачать

Готовые сборки доступны в [GitHub Releases](https://github.com/AndranikFutureLabs/tdesktop-mod/releases).

---
*Модификация подготовлена @AndranikFutureLabs. Версия V3.1.0.*
