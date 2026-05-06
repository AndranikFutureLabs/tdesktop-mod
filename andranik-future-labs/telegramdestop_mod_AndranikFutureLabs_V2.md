# Telegram Desktop Mod: Andranik Future Labs (V2)

## Описание проекта
Данная модификация Telegram Desktop (@AndranikFutureLabs) направлена на снятие ограничений, накладываемых владельцами каналов и групп на контент. Основная цель — обеспечить пользователю полный контроль над данными, включая возможность сохранения медиафайлов и пересылки сообщений из защищенных чатов.

## Изменения в исходном коде

### 1. Обход ограничений контекстного меню
**Файл:** [`Telegram/SourceFiles/history/view/history_view_context_menu.cpp`](Telegram/SourceFiles/history/view/history_view_context_menu.cpp)

В этом файле была изменена логика проверки разрешений на пересылку сообщений.

**Фрагмент 1 (Пересылка одного сообщения):**
Было (строки ~409-411):
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

**Фрагмент 2 (Пересылка группы сообщений):**
Было (строки ~415-417):
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

**Фрагмент 3 (Пересылка выделенных сообщений):**
Было (строки ~383-385):
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

### 2. Снятие ограничений на копирование и выделение в интерфейсе
**Файл:** [`Telegram/SourceFiles/history/history_inner_widget.cpp`](Telegram/SourceFiles/history/history_inner_widget.cpp)

Здесь была отключена проверка `hasSelectRestriction`, которая блокирует выделение текста и вызов контекстного меню в защищенных чатах.

**Фрагмент 1 (Метод hasSelectRestriction):**
Было (строки ~737-748):
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

### 3. Принудительное включение кнопки "Сохранить как" для документов
**Файл:** [`Telegram/SourceFiles/history/view/media/history_view_save_document_action.cpp`](Telegram/SourceFiles/history/view/media/history_view_save_document_action.cpp)

Удалена проверка `ItemHasTtl(item)`, которая скрывает опцию сохранения для исчезающих сообщений или сообщений с ограничениями.

**Фрагмент 1 (Метод AddSaveDocumentAction):**
Было (строки ~116-118):
```cpp
	if (!item || ItemHasTtl(item)) {
		return;
	}
```
Стало:
```cpp
	if (!item) {
		return;
	}
```

## Логика обхода ограничений

### allowsForwarding
В Telegram API и внутреннем коде `allowsForward` проверяет флаг `noforwards` у чата. Модификация игнорирует этот флаг в функциях построения контекстного меню, позволяя вызывать диалог пересылки (`Window::ShowForwardMessagesBox`) для любого сообщения.

### hasCopyMediaRestriction
Ограничение на копирование медиа и текста (`hasCopyRestriction`) завязано на метод `hasSelectRestriction`. Возвращая всегда `false` в этом методе, мы обманываем UI-логику, заставляя её считать, что текущий чат не имеет ограничений на взаимодействие с контентом. Это автоматически включает возможность выделения текста, копирования ссылок и вызова стандартных действий сохранения.

---
*Документация подготовлена @AndranikFutureLabs. Версия V2.*
