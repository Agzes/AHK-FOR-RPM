<h2 align="center">
Как изменить отыгровки в AHK Hospital v.2.2 ?
</h2>
<h4 align="center"><a href="https://github.com/Agzes/AHK-FOR-RPM/blob/main/!Docs/Editor.md">[документация AFR Editor]</a> <a href="https://github.com/Agzes/AHK-FOR-RPM/blob/main/Hospital/Config.md">[конфиг Hospital]</a></h4>

### 1 • Импорт конфига
> 1. Откройте [файл с конфигом](https://github.com/Agzes/AHK-FOR-RPM/blob/main/Hospital/Config.md) и скопируйте конфиг
> 2. Зайдите на [AFR Editor](https://agzes.netlify.app/ahk-for-rpm/editor/) и нажмите кнопку "Импорт"
> 3. В открывшимся окне вставьте конфиг и нажмите "Импортировать"
> 4. У вас откроется "Редактор конфига", в нём перейдите в "Отыгровки"
> 5. Здесь у вас будут все отыгровки предоставленные в последней версии AHK Hospital

### 2 • Изменение отыгровок
> 1. Найдя нужную для изменения отыгровку нажмите на "✏️" сверху карточки
> 2. У вас откроется меню с содержимым отыгровки
> 3. Тут может быть 2 варианта, либо это Func (Функция) либо RPAction (карточки)
> ###  1 • Изменение RPAction
>> В данном случае просто меняем текст на свой (по необходимости добавляем больше действий и меняем время). Время меняется в последних 2 списках (число в элементе и будет временем в мс.) Так-же можно воспользоваться AutoChat вместо Chat, в данном случаи не нужно будет заполнять время между отыгровками (но тут могут возникнуть другие проблемы)
> ### 2 • Изменение Func (функций)
>> Тут уже будет сложнее, но концепция такая же как и в RPAction только с элементами AutoHotKey v.2.0, вероятно там просто будет условие и тот-же самый RPAction только в виде кода. В общем вы можете просто поменять текст который написан между "кавычек" и на этом закончить

### 3 • Изменение файла 
> 1. После сохранение всех отыгрвок перейдите в "Экспорт & Импорт"
> 2. Скопируйте конфиг в формате AHK Script (настроен по умолчанию)
> 3. Откройте .ahk файл AHK Hospital в блокноте или любом другом редакторе
> 4. Замените **весь** конфиг AHK Hospital на ваш изменённый конфиг
> 5. Сохраните файл и откройте его с помощью AutoHotKey!

<br>

### ⁉️ • Полезные ссылки
> [Wiki AFR Editor](https://github.com/Agzes/AHK-FOR-RPM/blob/main/!Docs/Editor.md) - Полная документация для AFR Editor \
> [Q&A AFR Editor](https://github.com/Agzes/AHK-FOR-RPM/blob/main/!Docs/Q%26A.md) - ответы на вопросы по AFR Editor \
> [Build AFR Editor](https://github.com/Agzes/AHK-FOR-RPM/blob/main/!Docs/Build.md) - более подробное описание для сборки (изменения файла .ahk) 
