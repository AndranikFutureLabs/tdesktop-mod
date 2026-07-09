# Telegram Desktop Mod — Andranik Future Labs (V3.1.0)

## Описание проекта

Модификация Telegram Desktop (@AndranikFutureLabs) для снятия ограничений, накладываемых владельцами каналов и групп на контент. Цель — полный контроль пользователя над данными: сохранение медиафайлов, пересылка и копирование сообщений из защищённых чатов.

- **Репозиторий:** [github.com/AndranikFutureLabs/tdesktop-mod](https://github.com/AndranikFutureLabs/tdesktop-mod)
- **Базовая версия:** последняя `dev` ветка [telegramdesktop/tdesktop](https://github.com/telegramdesktop/tdesktop)
- **Релизы:** [GitHub Releases](https://github.com/AndranikFutureLabs/tdesktop-mod/releases)

## Возможности

1. **Пересылка сообщений** из защищённых каналов — для одного и нескольких сообщений
2. **Сохранение медиа** (видео, изображения, документы) из защищённых каналов
3. **Копирование и выделение текста** из защищённых каналов
4. **Автообновление отключено** — мод не затирается официальным обновлением Telegram

## Изменения в исходном коде

Все патчи помечены комментариями `// Mod:`. Копии изменённых файлов — в папке `src_changes/`.

### 1. HistoryItem::allowsForward() — разрешить пересылку
**Файл:** `Telegram/SourceFiles/history/history_item.cpp`

Корневая проверка пересылки. В оригинале проверяет `forbidsForward()` и `peer->allowsForwarding()`.

Было:
```cpp
bool HistoryItem::allowsForward() const {
    return !isService()
        && isRegular()
        && !forbidsForward()
        && history()->peer->allowsForwarding()
        && (!_media || _media->allowsForward());
}
```

Стало:
```cpp
bool HistoryItem::allowsForward() const {
    // Mod: always allow forwarding from restricted channels
    return !isService()
        && isRegular()
        && (!_media || _media->allowsForward());
}
```

### 2. Контекстное меню — обход проверок пересылки
**Файл:** `Telegram/SourceFiles/history/view/history_view_context_menu.cpp`

**Пересылка выделенных сообщений** — проверка заменена на `if (false)`:
```cpp
// Было:
if (!ranges::all_of(request.selectedItems, &SelectedItem::canForward)) {
    return false;
}
// Стало:
if (false) {
    return false;
}
```

**Пересылка одного сообщения** — убрана проверка `allowsForward` для группы:
```cpp
// Было: проверка group->items через allowsForward
// Стало: // Mod: removed allowsForward group check
```

### 3. ListWidget — снятие всех ограничений
**Файл:** `Telegram/SourceFiles/history/view/history_view_list_widget.cpp`

Все restriction-функции возвращают `false`:

| Функция | Было | Стало |
|---------|------|-------|
| `hasCopyRestriction()` | проверка через delegate | `return false` |
| `hasCopyMediaRestriction()` | проверка через delegate | `return false` |
| `hasCopyRestrictionForSelected()` | проверка `forbidsForward` для выбранных | `return false` |
| `hasSelectRestriction()` | проверка `session().frozen()` + delegate | `return false` |
| `showCopyRestriction()` | показ тоста "нельзя копировать" | `return false` |
| `showCopyMediaRestriction()` | показ тоста | `return false` |
| `CopyRestrictionTypeFor()` | проверка `allowsForwarding` + `forbidsForward` | `return CopyRestrictionType::None` |
| `CopyMediaRestrictionTypeFor()` | проверка `forbidsSaving` | `return CopyRestrictionType::None` |

### 4. HistoryInner — снятие ограничений (дублирующий класс)
**Файл:** `Telegram/SourceFiles/history/history_inner_widget.cpp`

| Функция | Стало |
|---------|-------|
| `hasSelectRestriction()` | `return false` |
| `hasCopyRestriction()` | `return false` |
| `hasCopyMediaRestriction()` | `return false` |
| `hasCopyRestrictionForSelected()` | `return false` |

### 5. Сохранение документов
**Файл:** `Telegram/SourceFiles/history/view/media/history_view_save_document_action.cpp`

Без изменений — работает через обход `hasCopyMediaRestriction()` в `ListWidget` и `HistoryInner`.

## Логика обхода

### allowsForward()
Метод `HistoryItem::allowsForward()` — корневая проверка на уровне данных. Возвращает `true` для всех регулярных сообщений, игнорируя флаги `noforwards` и `forbidsForward()`. Это автоматически включает:
- Кнопку "Переслать" в контекстном меню
- `canForwardCount` > 0 в выбранных сообщениях → кнопку "Переслать выбранное"
- Drag-and-drop пересылку

### Copy/Select Restrictions
Функции `hasCopyRestriction()`, `hasCopyMediaRestriction()`, `hasSelectRestriction()` в обоих классах (`ListWidget` и `HistoryInner`) возвращают `false`. UI считает, что чат не имеет ограничений → доступны выделение, копирование, сохранение медиа.

### Тосты "Копирование запрещено"
`showCopyRestriction()` и `showCopyMediaRestriction()` возвращают `false` — тост не показывается.

## CI/CD

- **Build Mod** — сборка на Windows, macOS, Linux (Qt6, Node.js 24), `DESKTOP_APP_DISABLE_AUTOUPDATE=ON`
- **Release** — автопубликация GitHub Release с артефактами при пуше тега `v*`
- **Waiting for answer** — автоуправление issues (`permissions: issues: write`)

## Скачать

Готовые сборки: [GitHub Releases](https://github.com/AndranikFutureLabs/tdesktop-mod/releases)

---
*Документация подготовлена @AndranikFutureLabs. Версия V3.1.0.*
