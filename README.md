# Telegram Desktop - mod AndranikFutureLabs

![Andranik Future Labs](mod.png)

Данная модификация Telegram Desktop (@AndranikFutureLabs) направлена на снятие ограничений, накладываемых владельцами каналов и групп на контент. Основная цель — обеспечить пользователю полный контроль над данными, включая возможность сохранения медиафайлов и пересылки сообщений из защищенных чатов.

## Возможности
1. **Сохранение видео и изображений из защищённых каналов** — обход ограничения `noforwards`
2. **Пересылка сообщений из защищённых каналов** — кнопка "Переслать" доступна всегда
3. **Сохранение документов** — обход проверки TTL и `hasCopyMediaRestriction`
4. **Копирование и выделение текста** — `hasSelectRestriction` всегда возвращает `false`

## Документация V2
- [Инструкция по сборке и изменениям (MD)](docs/telegramdestop_mod_AndranikFutureLabs_V2.md)
- [Решение проблем при сборке (MD)](docs/telegramdestop_mod_AndranikFutureLabs_AssemblyProblemsAndSolutions_V2.md)
- [Инструкция по сборке и изменениям (PDF)](docs/telegramdestop_mod_AndranikFutureLabs_V2.pdf)
- [Решение проблем при сборке (PDF)](docs/telegramdestop_mod_AndranikFutureLabs_AssemblyProblemsAndSolutions_V2.pdf)

## Измененные файлы
Исходный код изменений доступен в папке `src_changes/`.

### Список изменённых файлов:
1. `Telegram/SourceFiles/history/view/history_view_context_menu.cpp` — обход ограничений на пересылку
2. `Telegram/SourceFiles/history/history_inner_widget.cpp` — снятие ограничений на копирование и выделение
3. `Telegram/SourceFiles/history/view/media/history_view_save_document_action.cpp` — принудительное включение "Сохранить как"

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
GitHub Actions настроен на использование Node.js 24 (последняя LTS).

---
*Модификация подготовлена @AndranikFutureLabs. Версия V3.*
