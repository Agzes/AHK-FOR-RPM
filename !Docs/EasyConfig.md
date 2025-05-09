<img src="https://github.com/Agzes/AHK-FOR-RPM/blob/main/!ReadMe/Header.png?raw=true" alt="image" width="1000">

<div align="center">
    <h2>
    Документация к версии "Custom" [EasyConfig]
    </h2>

    DOCS BETA v.1.0 | v.2.2.0 AFR

</div>

> [!caution]
> EasyConfig версия находится в бете 

> [!warning]
> Документация находится в бете

---

## 1 • Подготовка
### 1.1 • Копирование файлов репозитория
> 1. Скопируйте папки !Libs и Custom с репозитория в любое удобное для вас место
> 2. Переименуйте папку Custom на название вашего АХК (не обязательно)
> 3. Запустите файл Main.ahk, если не запустился смотрите `Q&A.md`

---

## 2 • Изменение конфига
> Примечание -> в данном разделе почти всё будет показано в фрагментах кода

### 2.1 Изменение переменных
> ```AutoHotKey
> AHK_version := "1.0" ; Версия вашего АХК (Только для интерфейса)
> code_version := 405 ; Кодовая версия (Для работы авто-обновлений) (405 - откл.*)
> Font := "Segoe UI" ; Шрифт программы (не рекомендуется к изменению)
> FontSize := 11 ; Размер шрифта (для корректного отображения собственного шрифта)
> ConfigPath := "HKEY_CURRENT_USER\Software\Author\AFR\Custom" ; Основной путь настроек 
> RevName := "Custom" ; Название ревизии (АХК)
> BindsBGHeight := 400 ; Высота фона в Конфигураторе биндов (Подбирайте в самом конце)
>
> global GBinds := Map()            ; Не изменять
> global GBinds_cfg := Map()        ; Не изменять
> global GBindsAction_cfg := Map()  ; Не изменять
> ```

### 2.2 Конфиг биндов
> ```AutoHotKey
> ; i["НазваниеБинда"] := ["Бинд по умолчанию", "Описание"]
> InitGBinds(i) {
>     i["ForceStop"] := ['Insert', "[ForceStop] - Остановка отыгровок"]
>     i["UI_Main"] := ['F4', "[UI] Основное"]
>     i["UI_Menu"] := ['F9', "[UI] Меню"]
>     i["Restart"] := ['F10', "Перезагрузка"]
>     i["Greetings"] := ['!q', "Приветствие"]
>     i["ID"] := ['!f', "Удостоверение"]
> } 
> ```
> [[AHK v2 Docs | Горячие клавиши (бинды)]](https://www.autohotkey.com/docs/v2/Hotkeys.htm#Symbols)

### 2.3 Конфиг параметров
> ```AutoHotKey
> ; i["НазваниеПараметра"] := [Значение()]
> InitGBindsCfg(i) {
>     i["Global_HealCommand"] := true
>     i["Global_HealPrice"] := 111
>     i["Greetings_UseName"] := false
>     i["Greetings_UseRole"] := false
> } 
>
> ; RpSetUIGen(RpSetUI, "Тип [CheckBox/Input]", "Название", "НазваниеПараметра", "Описание")
> InitGBindsCfgUI() {
>     RpSetUIGen(RpSetUI, "CheckBox", "Авто-Написание команд", "Global_HealCommand", "Определяет будет ли автоматически вводиться команды")
>     RpSetUIGen(RpSetUI, "Input", "Цена на лечения (Число)", "Global_HealPrice", "Определяет цену которая будет писаться при лечении")
>     RpSetUIGen(RpSetUI, "CheckBox", "[Приветствие] + Имя Фамилия", "Greetings_UseName", "Определяет будет ли использоваться РП ИмяФамилия в приветствии")
>     RpSetUIGen(RpSetUI, "CheckBox", "[Приветствие] + Ранг", "Greetings_UseRole", "Определяет будет ли использоваться РП Ранг в приветствии")
> }
> ```

### 2.4 Конфиг отыгровок
> Отыгровки можно делать 2 способами: 
> 1. Используя RPAction [функция AFR] (бета)
> 2. Используя отдельно написанную функцию [если вы знаете AutoHotKey v2]
>
> ```AutoHotKey
> ; i["НазОтыгровки"] := ["НазваниеБинда", "Тип [RPAction/Func]", "[["Chat", "...", S100, S300]] {если тип - RPAction} или function {если тип - Func}"]
> InitRPActions(i) {
>     i["SellMed"] := ["SellMed", "RPAction", [
>         ["Chat", "/do " . ["Красная аптечка", "Аптечка с красным крестом", "Аптечка"][RandomNew(1, 3)] . " в руках у мед. работника" . " {Enter}", S100, S300],
>         ["Chat", "/mee открыв " . ["красную аптечку", "аптечку с красным крестом", "аптечку"][RandomLast()] . " и найдя нужное лекарство передаёт человеку напротив, затем подписывает листок c датой выдачи и своими данными {Enter}", S300, S300],
>         ["Chat", "/med sell ", S100, S250]]
>     ] ; RPAction
>     i["Greetings"] := ["Greetings", "Func", greetings] ; Пример с функцией
> } 
> 
> ; НазваниеФункции(Element?, *) { 'А тут уже пишем логику' } 
> greetings(Element?, *) {
>     gt := "Здравствуйте, чем я могу вам помочь? {ENTER}"
>     if G_Binds_cfg["Greetings_UseName"] and G_Binds_cfg["Greetings_UseRole"] {
>         gt := "Здравствуйте, меня зовут " Name ", моя должность " Role ". Чем я могу помочь? {ENTER}"
>     } else if G_Binds_cfg["Greetings_UseName"] {
>         gt := gt := "Здравствуйте, меня зовут " Name ", чем я могу помочь? {ENTER}"
>     } else if G_Binds_cfg["Greetings_UseRole"] {
>         gt := "Здравствуйте, я " Role ", чем я могу помочь? {ENTER}"
>     }
> 
> 
>     RPAction([
>         ["Chat", gt, S100, S100]
>     ])
> }
> ```
> [[RPAction Docs]](RPAction.md)

### 2.5 Создание списков
> ```AutoHotKey
> GBindsSortedArrayForSet := ["ForceStop", "UI_Main", "UI_Menu", "Restart", "Greetings", "ID"] ; Отсортированный список для конфигуратора биндов [Сюда нужно добавить все элементы с InitGBinds / исключение: бинды которые вы не хотите делать доступными для изменения]
> GBindsSortedArray := ["Greetings", "ID"] ; Список для биндов, [не добавляйте сюда UI, Restart, ForceStop]
> ```

### 2.6 Создание списков
> ```AutoHotKey
> ; ["Тип окна [Custom]", "НазваниеОкна", "Label в окне", "НазваниеБинда", ["Элементы"...]]
> GWindows := [
>     ["Custom", "Main", "\^o^/", "UI_Main", ["Greetings", "ID"]]
> ]
> ```

### 2.7 Настройки AFR (Меню, ForceStop, Restart)
> ```AutoHotKey
> ; ["Тип [AFR/SYS]", "Название Настройки [Menu, ForceStop / Restart]", "НазваниеБинда"]
> G_AFRSettings := [
>     ["AFR", "Menu", "UI_Menu"],
>     ["AFR", "ForceStop", "ForceStop"],
>     ["SYS", "Restart", "Restart"],
> ]
> ```

---

## 3 • Сборка AFR
### 3.1 Ahk2Exe
> 1. Откройте Ahk2Exe (по умолчанию устанавливается с AutoHotKey)
> 2. Выберите путь до файла скрипта
> 3. Укажите `Base File` на любую версию выше v.2.0 (и ниже v.2.1)
> 4. [Не обязательно] Добавьте иконку приложения (можно свою, можно AFR [в папке Assets в репозитории])
> 5. Нажмите на Convert и `Main.exe` появится у вас в папке со скриптом


---
### Пример -> [Examples.md](Examples.md)
