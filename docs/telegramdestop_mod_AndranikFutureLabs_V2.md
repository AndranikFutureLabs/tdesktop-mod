# Telegram Desktop Mod: Andranik Future Labs (V3)

## Описание проекта
Данная модификация Telegram Desktop (@AndranikFutureLabs) направлена на снятие ограничений, накладываемых владельцами каналов и групп на контент. Основная цель — обеспечить пользователю полный контроль над данными, включая возможность сохранения медиафайлов и пересылки сообщений из защищенных чатов.

## Базовая версия
Мод построен на последней версии `dev` ветки [telegramdesktop/tdesktop](https://github.com/telegramdesktop/tdesktop).

## Изменения в исходном коде

### 1. Обход ограничений контекстного меню (пересылка сообщений)
**Файл:** `Telegram/SourceFiles/history/view/history_view_context_menu.cpp`

**Фрагмент 1 (Пересылка выделенных сообщений):**
Было:
```cpp
	if (!ranges::all_of(request.selectedItems, &SelectedItem::canForward)) {
		return false;
	}
```
Стало:
```cpp
	if (false) {
		return false;
	}
```

**Фрагмент 2 (Пересылка одного сообщения):**
Было:
```cpp
	} else if (!item || !item->allowsForward()) {
		return false;
	}
```
Стало:
```cpp
	} else if (!item) {
		return false;
	}
```

**Фрагмент 3 (Пересылка группы сообщений):**
Было:
```cpp
		if (const auto group = owner->groups().find(item)) {
			if (!ranges::all_of(group->items, &HistoryItem::allowsForward)) {
				return false;
			}
		}
```
Стало:
```cpp
		if (const auto group = owner->groups().find(item)) {
		}
```

### 2. Снятие ограничений на копирование и выделение
**Файл:** `Telegram/SourceFiles/history/history_inner_widget.cpp`

Было:
```cpp
bool HistoryInner::hasSelectRestriction() const {
	if (session().frozen()) {
		return true;
	} else if (!_sharingDisallowed.current()) {
		return false;
	} else if (const auto chat = _peer->asChat()) {
		return !chat->canDeleteMessages();
	} else if (const auto channel = _peer->asChannel()) {
		return !channel->canDeleteMessages();
	}
	return true;
}
```
Стало:
```cpp
bool HistoryInner::hasSelectRestriction() const {
	return false;
}
```

### 3. Принудительное включение "Сохранить как" для документов
**Файл:** `Telegram/SourceFiles/history/view/media/history_view_save_document_action.cpp`

Было:
```cpp
	if (!item || list->hasCopyMediaRestriction(item) || ItemHasTtl(item)) {
		return;
	}
```
Стало:
```cpp
	if (!item) {
		return;
	}
```

**Примечание:** В новой версии tdesktop также добавлена проверка `list->hasCopyMediaRestriction(item)`, которая также удалена — это позволяет сохранять документы (включая видео и изображения) из защищённых каналов.

## Логика обхода ограничений

### allowsForwarding
В Telegram API `allowsForward` проверяет флаг `noforwards` у чата. Модификация игнорирует этот флаг в функциях построения контекстного меню, позволяя вызывать диалог пересылки (`Window::ShowForwardMessagesBox`) для любого сообщения.

### hasCopyMediaRestriction
Ограничение на копирование медиа и текста завязано на метод `hasSelectRestriction`. Возвращая всегда `false`, мод обманывает UI-логику, заставляя её считать, что чат не имеет ограничений. Это автоматически включает выделение текста, копирование ссылок и стандартные действия сохранения.

### ItemHasTtl + hasCopyMediaRestriction
Удаление этих проверок в `AddSaveDocumentAction` позволяет сохранять документы из сообщений с TTL и из чатов с ограничением на копирование медиа.

## CI/CD

### Node.js 24
GitHub Actions настроен на использование Node.js 24 — последней LTS версии.

**Файл:** `.github/workflows/waiting-for-answer.yml`

```yaml
env:
  FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: 'true'
  ACTIONS_ALLOW_USE_UNSECURE_NODE_VERSION: 'true'
```

Также добавлен шаг `actions/setup-node@v4` с `node-version: 24`.

## Сборка

```cmd
:: Установка переменных окружения Visual Studio
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"

:: Запуск скрипта подготовки
python Telegram/build/prepare/prepare.py qt6

:: Генерация и сборка
cmake -B out -G "Visual Studio 17 2022" -A x64 -DCMAKE_BUILD_TYPE=Debug
cmake --build out --config Debug --target Telegram
```

---
*Документация подготовлена @AndranikFutureLabs. Версия V3.*
