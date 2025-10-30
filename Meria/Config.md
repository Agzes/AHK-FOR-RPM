# JSON Config для AFR Editor - использует функции | AFR v.2.2b

```json
{
  "name": "Meria",
  "revName": "Meria",
  "ahkVersion": "30.10.25 • Основан на отыгровках от Mirml",
  "codeVersion": 1,
  "font": "Segoe UI",
  "fontSize": 11,
  "configPath": "HKEY_CURRENT_USER\\Software\\AHK-FOR-RPM\\Meria",
  "bindsBgHeight": 400,
  "binds": [
    {
      "name": "ForceStop",
      "key": "Insert",
      "desc": "[ForceStop] - Остановка отыгровок"
    },
    {
      "name": "UI_Main",
      "key": "F4",
      "desc": "[UI] Основное"
    },
    {
      "name": "UI_Menu",
      "key": "F9",
      "desc": "[UI] Меню"
    },
    {
      "name": "Restart",
      "key": "!r",
      "desc": "Перезагрузка"
    },
    {
      "name": "AskPassport",
      "key": "!2",
      "desc": "Попросить паспорт (ФБК/ДКП)"
    },
    {
      "name": "AskToNotDisturb",
      "key": "!y",
      "desc": "Попросить не нарушать"
    },
    {
      "name": "ChangePassport",
      "key": "!c",
      "desc": "Изменить паспорт"
    },
    {
      "name": "GivePassport",
      "key": "!p",
      "desc": "Выдать паспорт новичку"
    },
    {
      "name": "GoToMeeting",
      "key": "!5",
      "desc": "Суд: Уйти на совещание"
    },
    {
      "name": "Greetings",
      "key": "!q",
      "desc": "Приветствие"
    },
    {
      "name": "PresentOfficially",
      "key": "!1",
      "desc": "Представиться официально"
    },
    {
      "name": "RulesTrial",
      "key": "!4",
      "desc": "Суд: Правила"
    },
    {
      "name": "StartTrial",
      "key": "!3",
      "desc": "Суд: Начало"
    },
    {
      "name": "TakePassportAndStar",
      "key": "!k",
      "desc": "Взять паспорт и спросить о задержании"
    },
    {
      "name": "UDO_Give",
      "key": "!d",
      "desc": "Выдать УДО"
    },
    {
      "name": "UDO_Price",
      "key": "!n",
      "desc": "Цены на УДО"
    },
    {
      "name": "UpBillboard",
      "key": "!b",
      "desc": "Развесить биллборд"
    },
    {
      "name": "UseForce",
      "key": "!h",
      "desc": "Применить силу"
    }
  ],
  "params": [
    {
      "type": "Input",
      "name": "G_Department",
      "value": "Отсутствует",
      "displayName": "Отдел",
      "desc": "Выберите ваш отдел: ФБК / ДКП / Отсутствует"
    },
    {
      "type": "Input",
      "name": "G_CertificateDate",
      "value": "30.10.2025",
      "displayName": "Дата выдачи удостоверения",
      "desc": "Дата, которая будет отображаться в удостоверении."
    },
    {
      "type": "Input",
      "name": "G_DepartmentRole",
      "value": "",
      "displayName": "Роль в отдел",
      "desc": "Ваша должность в отделе (если применимо)."
    }
  ],
  "actions": [
    {
      "name": "Greetings",
      "bind": "Greetings",
      "type": "RPAction",
      "content": "[ [\"Chat\", \"Здравствуйте, меня зовут \\\" Name \\\". Чем могу помочь?{ENTER}\", S300, S300] ]"
    },
    {
      "name": "PresentOfficially",
      "bind": "PresentOfficially",
      "type": "Func",
      "content": "present_officially(Element?, *) {\n    Department := G_Binds_cfg[\"G_Department\"]\n    CertDate := G_Binds_cfg[\"G_CertificateDate\"]\n    L_Gender := Gender = 1 ? \"Мужской\" : \"Женский\"\n    DepartmentRole := G_Binds_cfg[\"G_DepartmentRole\"]\n\n    if (L_Gender = \"Женский\") {\n        if (Department = \"Отсутствует\") {\n            RPAction([\n                [\"Chat\", \"Здравствуйте, я сотрудник Правительства, \" Name \".{ENTER}\", S100, S100],\n                [\"Chat\", \"/me достала удостоверение из нагрудного кармана рубашки и продемонстрировала его человеку напротив.{ENTER}\", S100, S100],\n                [\"Chat\", \"/do Удостоверение: ИФ: \" Name \" | Фото 3x4 | Организация: Правительство | Должность: \" Role \" | Дата выдачи: \" CertDate \" | Отдел: \" Department \" | Подпись губернатора | Штамп MERIA{ENTER}\", S100, S100],\n                [\"Chat\", \"/me убедившись, что человек напротив изучил информацию, убрала удостоверение обратно в нагрудный карман.{ENTER}\", S100, S100]\n            ])\n        } else if (Department = \"ФБК\" or Department = \"ДКП\") {\n            RPAction([\n                [\"Chat\", \"Здравствуйте, я сотрудник отдела \" Department \", \" Name \".{ENTER}\", S100, S100],\n                [\"Chat\", \"/me достала удостоверение из нагрудного кармана рубашки и продемонстрировала его человеку напротив.{ENTER}\", S100, S100],\n                [\"Chat\", \"/do Удостоверение: ИФ: \" Name \" | Фото 3x4 | Организация: Правительство | Должность: \" Role \" | Дата выдачи: \" CertDate \" | Отдел: \" Department \" | Должность в отделе: \" DepartmentRole \" | Подпись главы отдела \" Department \" | Подпись губернатора | Штамп MERIA{ENTER}\", S100, S100],\n                [\"Chat\", \"/me убедившись, что человек напротив изучил информацию, убрала удостоверение обратно в нагрудный карман.{ENTER}\", S100, S100]\n            ])\n        }\n    } else if (L_Gender = \"Мужской\") {\n        if (Department = \"Отсутствует\") {\n            RPAction([\n                [\"Chat\", \"Здравствуйте, я сотрудник Правительства, \" Name \".{ENTER}\", S100, S100],\n                [\"Chat\", \"/me достав удостоверение из внутреннего кармана пиджака, продемонстрировал его человеку напротив.{ENTER}\", S100, S100],\n                [\"Chat\", \"/do Удостоверение: ИФ: \" Name \" | Фото 3x4 | Организация: Правительство | Должность: \" Role \" | Дата выдачи: \" CertDate \" | Отдел: \" Department \" | Подпись губернатора | Штамп MERIA{ENTER}\", S100, S100],\n                [\"Chat\", \"/me убедившись, что человек напротив изучил информацию, убрал удостоверение обратно во внутренний карман.{ENTER}\", S100, S100]\n            ])\n        } else if (Department = \"ФБК\" or Department = \"ДКП\") {\n            RPAction([\n                [\"Chat\", \"Здравствуйте, я сотрудник отдела \" Department \", \" Name \".{ENTER}\", S100, S100],\n                [\"Chat\", \"/me достав удостоверение из внутреннего кармана пиджака, продемонстрировал его человеку напротив.{ENTER}\", S100, S100],\n                [\"Chat\", \"/do Удостоверение: ИФ: \" Name \" | Фото 3x4 | Организация: Правительство | Должность: \" Role \" | Дата выдачи: \" CertDate \" | Отдел: \" Department \" | Должность в отделе: \" DepartmentRole \" | Подпись главы отдела \" Department \" | Подпись губернатора | Штамп MERIA{ENTER}\", S100, S100],\n                [\"Chat\", \"/me убедившись, что человек напротив изучил информацию, убрал удостоверение обратно во внутренний карман.{ENTER}\", S100, S100]\n            ])\n        }\n    }\n}"
    },
    {
      "name": "AskToNotDisturb",
      "bind": "AskToNotDisturb",
      "type": "Func",
      "content": "ask_to_not_disturb(Element?, *) {\n    L_Gender := Gender = 1 ? \"Мужской\" : \"Женский\"\n    if (L_Gender = \"Женский\") {\n        RPAction([\n            [\"Chat\", \"Гражданин, прошу вас не нарушать порядок в мэрии и покинуть здание.{ENTER}\", S300, S300],\n            [\"Chat\", \"/me смотря на человека приготовилась выводить его силой.{ENTER}\", S250, S250]\n        ])\n    } else if (L_Gender = \"Мужской\") {\n        RPAction([\n            [\"Chat\", \"Гражданин, прошу вас не нарушать порядок в мэрии и покинуть здание.{ENTER}\", S300, S300],\n            [\"Chat\", \"/me смотря на человека приготовился выводить его силой.{ENTER}\", S250, S250]\n        ])\n    }\n}"
    },
    {
      "name": "UseForce",
      "bind": "UseForce",
      "type": "Func",
      "content": "use_force(Element?, *) {\n    L_Gender := Gender = 1 ? \"Мужской\" : \"Женский\"\n    if (L_Gender = \"Женский\") {\n        RPAction([\n            [\"Chat\", \"Извините, но я обязана применить силу.{ENTER}\", S100, S1000],\n            [\"Chat\", \"/me быстро подойдя к человеку, начала его захват. Быстрыми и тактичными действиями скручивает его.{ENTER}\", S500, S1000],\n            [\"Chat\", \"/do Человек на полу. Руки гражданина зафиксированы за спиной{ENTER}\", S500, S100]\n        ])\n    } else if (L_Gender = \"Мужской\") {\n        RPAction([\n            [\"Chat\", \"Извините, но я обязан применить силу.{ENTER}\", S100, S1000],\n            [\"Chat\", \"/me быстро подойдя к человеку, начал его захват. Быстрыми и тактичными действиями скручивает его.{ENTER}\", S500, S1000],\n            [\"Chat\", \"/do Человек на полу. Руки гражданина зафиксированы за спиной{ENTER}\", S500, S100]\n        ])\n    }\n}"
    },
    {
      "name": "GivePassport",
      "bind": "GivePassport",
      "type": "Func",
      "content": "give_passport(Element?, *) {\n    \n    allowed_positions := \"|Секретарь|Председатель|Адвокат|Судья|Вице-Губернатор|Губернатор|\"\n    if InStr(allowed_positions, \"|\" . Role . \"|\") {\n        RPAction([\n            [\"Chat\", \"Здравствуйте. Меня зовут \" Name \". Сейчас я вам выдам бланк. Заполните в полях имя и фамилию с заглавной буквы.{ENTER}\", S300, S500],\n            [\"Chat\", \"/n Имя и фамилия должны быть на русском языке, без матов, оскорблений и нижних подчёркиваний. Имя и Фамилия начинаются с заглавной буквы.{ENTER}\", S300, S5000],\n            [\"Chat\", \"/todo Забрав бланк из ящика и положив его на стол : заполните все поля{ENTER}\", S700, S500],\n            [\"Chat\", \"/pass give \", S300, S500]\n        ])\n    } else {\n        MsgBox(\"Извините, вы не можете выдавать или менять паспорт.\")\n    }\n}"
    },
    {
      "name": "ChangePassport",
      "bind": "ChangePassport",
      "type": "Func",
      "content": "change_passport(Element?, *) {\n    L_Gender := Gender = 1 ? \"Мужской\" : \"Женский\"\n    allowed_positions := \"|Секретарь|Председатель|Адвокат|Судья|Вице-Губернатор|Губернатор|\"\n    if InStr(allowed_positions, \"|\" . Role . \"|\") {\n        if (L_Gender = \"Женский\") {\n            RPAction([\n                [\"Chat\", \"/me взяла документы из рук гражданина, положила в тумбочку старый паспорт, после чего изменила данные в базе на планшете, а затем распечатала и передала новый паспорт гражданину, предварительно поставив печать.{ENTER}\", S300, S500],\n                [\"Chat\", \"/pass changepass \", S500, S100]\n            ])\n        } else if (L_Gender = \"Мужской\") {\n            RPAction([\n                [\"Chat\", \"/me взял документы из рук гражданина, положил в тумбочку старый паспорт, после чего изменил данные в базе на планшете, а затем распечатал и передал новый паспорт гражданину, предварительно поставив печать.{ENTER}\", S300, S500],\n                [\"Chat\", \"/pass changepass \", S500, S100]\n            ])\n        }\n    } else {\n        MsgBox(\"Извините, вы не можете выдавать или менять паспорт.\")\n    }\n}"
    },
    {
      "name": "UpBillboard",
      "bind": "UpBillboard",
      "type": "Func",
      "content": "up_billboard(Element?, *) {\n    L_Gender := Gender = 1 ? \"Мужской\" : \"Женский\"\n    allowed_positions := \"|Председатель|Вице-Губернатор|Губернатор|\"\n    if InStr(allowed_positions, \"|\" . Role . \"|\") {\n        if (L_Gender = \"Женский\") {\n            RPAction([\n                [\"Chat\", \"/me достала плакат из сумки и начала вешать его на пустой билборд.{ENTER}\", S250, S250],\n                [\"Chat\", \"/billboard {ENTER}\", S250, S500],\n                [\"Chat\", \"/do Рекламный плакат висит ровно{ENTER}\", S300, S250]\n            ])\n        } else if (L_Gender = \"Мужской\") {\n            RPAction([\n                [\"Chat\", \"/me достал плакат из сумки и начал вешать его на пустой билборд.{ENTER}\", S250, S250],\n                [\"Chat\", \"/billboard {ENTER}\", S250, S500],\n                [\"Chat\", \"/do Рекламный плакат висит ровно{ENTER}\", S300, S250]\n            ])\n        }\n    } else {\n        MsgBox(\"Извините, вы не имеете права развешивать биллборд.\")\n    }\n}"
    },
    {
      "name": "UDO_Price",
      "bind": "UDO_Price",
      "type": "Func",
      "content": "udo_price(Element?, *) {\n    allowed_positions := \"|Адвокат|Судья|Вице-Губернатор|Губернатор|\"\n    if InStr(allowed_positions, \"|\" . Role . \"|\") {\n        RPAction([\n            [\"Chat\", \"Цена условно-досрочного освобождения зависит от уровня розыска, с которым вы попали в КПЗ, и количества вашей законопослушности.{ENTER}\", S500, S250],\n            [\"Chat\", \"Первый уровень розыска -> 7.000$.{ENTER}\", S1000, S500],\n            [\"Chat\", \"Второй уровень розыска -> 14.000$.{ENTER}\", S700, S500],\n            [\"Chat\", \"Третий уровень розыска -> 42.000$.{ENTER}\", S500, S300],\n            [\"Chat\", \"Четвертый уровень розыска -> 84.000$.{ENTER}\", S250, S500],\n            [\"Chat\", \"Пятый уровень розыска -> 105.000$.{ENTER}\", S250, S300],\n            [\"Chat\", \"Каждую минуту сумма уменьшается на 350$ {ENTER}\", S1000, S250]\n        ])\n    } else {\n        MsgBox(\"Извините, вы не Адвокат, Судья, или Вице-Губернатор, а также тем более Губернатор.\")\n    }\n}"
    },
    {
      "name": "UDO_Give",
      "bind": "UDO_Give",
      "type": "Func",
      "content": "udo_give(Element?, *) {\n    L_Gender := Gender = 1 ? \"Мужской\" : \"Женский\"\n    if (Role = \"Адвокат\") {\n        if (L_Gender = \"Женский\") {\n            RPAction([\n                [\"Chat\", \"/me вынула из дипломата подготовленные бланки на УДО, затем положила их на стол.{ENTER}\", S500, S100],\n                [\"Chat\", \"/me вынув из кармана пиджака ручку, начала заполнение документа, после чего протянула документ о соглашении на УДО задержанному гражданину, положив на него ручку.{ENTER}\", S700, S1000],\n                [\"Chat\", \"/do Документ протянут человеку в КПЗ, на нём лежит чёрная гелевая ручка{ENTER}\", S1000, S1000],\n                [\"Chat\", \"/advocate \", S100, S100]\n            ])\n        } else if (L_Gender = \"Мужской\") {\n            RPAction([\n                [\"Chat\", \"/me вынул из дипломата подготовленные бланки на УДО, затем положил их на стол.{ENTER}\", S500, S100],\n                [\"Chat\", \"/me вынув из кармана пиджака ручку, начал заполнение документа, после чего протянул документ о соглашении на УДО задержанному гражданину, положив на него ручку.{ENTER}\", S700, S1000],\n                [\"Chat\", \"/do Документ протянут человеку в КПЗ, на нём лежит чёрная гелевая ручка{ENTER}\", S1000, S1000],\n                [\"Chat\", \"/advocate \", S1000, S100]\n            ])\n        }\n    } else {\n        MsgBox(\"Извините, вы не Адвокат.\")\n    }\n}"
    },
    {
      "name": "TakePassportAndStar",
      "bind": "TakePassportAndStar",
      "type": "Func",
      "content": "take_passport_and_star(Element?, *) {\n    allowed_positions := \"|Адвокат|Судья|\"\n    if InStr(allowed_positions, \"|\" . Role . \"|\") {\n        RPAction([\n            [\"Chat\", \"Пожалуйста, скажите, по какой причине вы были задержаны и доставлены в КПЗ? На какой срок вы были задержаны?{ENTER}\", S100, S100],\n            [\"Chat\", \"Также предъявите ваш паспорт для подтверждения личности и проверки вашей законопослушности.{ENTER}\", S100, S100],\n            [\"Chat\", \"/pass \", S100, S100]\n        ])\n    } else {\n        MsgBox(\"Извините, вы не Адвокат, Судья.\")\n    }\n}"
    },
    {
      "name": "StartTrial",
      "bind": "StartTrial",
      "type": "Func",
      "content": "start_trial(Element?, *) {\n    L_Gender := Gender = 1 ? \"Мужской\" : \"Женский\"\n    allowed_positions := \"|Судья|Вице-Губернатор|Губернатор|\"\n    if InStr(allowed_positions, \"|\" . Role . \"|\") {\n        if (L_Gender = \"Женский\") {\n            RPAction([\n                [\"Chat\", \"Суд объявляется открытым.{ENTER}\", S1000, S1000],\n                [\"Chat\", \"Итак, дамы и господа, начинается заседание суда. Проводит его судья \" Name \".{ENTER}\", S1000, S1000],\n                [\"Chat\", \"/me открыв папку, лежавшую на столе перед собой, начала читать информацию по делу.{ENTER}\", S1000, S1000],\n                [\"Chat\", \"/me прочитав содержимое папки с делом, закрыла её и положила на стол перед собой.{ENTER}\", S1000, S1000],\n                [\"Chat\", \"Теперь, когда дело повторно изучено, можно приступать к заседанию.{ENTER}\", S1000, S1000],\n                [\"Chat\", \"Слушается исковое дело от гражданина [Имя Истца], обвиняемый(ая) [Имя Обвиняемого].{ENTER}\", S1000, S100]\n            ])\n        } else if (L_Gender = \"Мужской\") {\n            RPAction([\n                [\"Chat\", \"Суд объявляется открытым.{ENTER}\", S1000, S1000],\n                [\"Chat\", \"Итак, дамы и господа, начинается заседание суда. Проводит его судья \" Name \".{ENTER}\", S1000, S1000],\n                [\"Chat\", \"/me открыв папку, лежавшую на столе перед собой, начал читать информацию по делу.{ENTER}\", S1000, S1000],\n                [\"Chat\", \"/me прочитав содержимое папки с делом, закрыл её и положил на стол перед собой.{ENTER}\", S1000, S1000],\n                [\"Chat\", \"Теперь, когда дело повторно изучено, можно приступать к заседанию.{ENTER}\", S1000, S1000],\n                [\"Chat\", \"Слушается исковое дело от гражданина [Имя Истца], обвиняемый(ая) [Имя Обвиняемого].{ENTER}\", S1000, S100]\n            ])\n        }\n    } else {\n        MsgBox(\"Извините, вы не можете начинать судебное заседание.`nВы должны быть судьёй или выше.\")\n    }\n}"
    },
    {
      "name": "GoToMeeting",
      "bind": "GoToMeeting",
      "type": "Func",
      "content": "go_to_meeting(Element?, *) {\n    L_Gender := Gender = 1 ? \"Мужской\" : \"Женский\"\n    allowed_positions := \"|Судья|Вице-Губернатор|Губернатор|\"\n    if InStr(allowed_positions, \"|\" . Role . \"|\") {\n        if (L_Gender = \"Женский\") {\n            RPAction([\n                [\"Chat\", \"Итак, выслушав все претензии со стороны истца и ответчика, комиссия решила удалиться на совещание.{ENTER}\", S1000, S1000],\n                [\"Chat\", \"/me встав с места забирает с собой папки с досье по делу и доказательствами с обеих сторон.{ENTER}\", S1000, S1000],\n                [\"Chat\", \"/do Все папки сложены в единую стопку и находятся в руках судьи.{ENTER}\", S1000, S1000],\n                [\"Chat\", \"/me поправив стопку у себя в руках, удалилась в зал совещаний.{ENTER}\", S1000, S100]\n            ])\n        } else if (L_Gender = \"Мужской\") {\n            RPAction([\n                [\"Chat\", \"Итак, выслушав все претензии со стороны истца и ответчика, комиссия решила удалиться на совещание.{ENTER}\", S1000, S1000],\n                [\"Chat\", \"/me встав с места забирает с собой папки с досье по делу и доказательствами с обеих сторон.{ENTER}\", S1000, S1000],\n                [\"Chat\", \"/do Все папки сложены в единую стопку и находятся в руках судьи.{ENTER}\", S1000, S1000],\n                [\"Chat\", \"/me поправив стопку у себя в руках, удалился в зал совещаний.{ENTER}\", S1000, S100]\n            ])\n        }\n    } else {\n        MsgBox(\"Извините, вы не можете уходить на совещание.`nВы должны быть судьёй или выше.\")\n    }\n}"
    },
    {
      "name": "RulesTrial",
      "bind": "RulesTrial",
      "type": "Func",
      "content": "rules_trial(Element?, *) {\n    allowed_positions := \"|Судья|Вице-Губернатор|Губернатор|\"\n    if InStr(allowed_positions, \"|\" . Role . \"|\") {\n        RPAction([\n            [\"Chat\", \"В течение всего судебного заседания запрещается разговаривать, издавать шумы или двигаться по залу суда без разрешения судьи. Аудио- и видеозапись разрешена только в открытом заседании, если судья не запретил съемку.{ENTER}\", S1000, S1000],\n            [\"Chat\", \"Присутствующие на суде обязаны обращаться друг к другу с уважением. Запрещено использование нецензурных выражений, физическое воздействие, повышение голоса или перебивание (исключение — протест).{ENTER}\", S1000, S1000],\n            [\"Chat\",\"Обращение друг к другу осуществляется формально, на `\"Вы`\". Слушатели не имеют права вмешиваться в ход судебного разбирательства и нарушать порядок заседания.{ENTER}\",S1000,S1000],\n            [\"Chat\",\"К суду все обязаны обращаться `\"Ваша Честь`\" или `\"Уважаемый суд`\", избегая упоминания личных данных судьи. В начале заседания все встают.{ENTER}\",S1000,S1000],\n            [\"Chat\", \"Все участники суда выступают, давая показания, делая заявления и принимая решения суда, стоя. Исключения могут быть по разрешению судьи.{ENTER}\", S1000, S1000],\n            [\"Chat\", \"Участники должны прибыть на судебное разбирательство вовремя. Исключение составляют случаи, когда суд решает, что их присутствие необязательно.{ENTER}\", S1000, S1000],\n            [\"Chat\", \"Нарушение правил поведения в суде может быть расценено как неуважение к суду. Нарушители могут быть заключены под стражу в СИЗО до конца судебного разбирательства по решению судьи.{ENTER}\", S1000, S1000],\n            [\"Chat\", \"Судья также может наложить административное или уголовное взыскание на лиц, нарушивших правила.{ENTER}\", S1000, S1000],\n            [\"Chat\",\"Перед началом заседания судья должен произнести следующую клятву, а затем все участники суда должны повторить ее: `\"Клянетесь ли вы говорить правду и только правду?`\" — `\"Клянусь говорить правду и только правду`\".{ENTER}\",S1000,S1000],\n            [\"Chat\", \"При проведении судебного заседания все обязаны соблюдать спокойствие и учтивость. Участники не могут обсуждать дело или вести диалоги без разрешения судьи.{ENTER}\", S1000, S1000],\n            [\"Chat\", \"Прерывать выступление других участников запрещено. Лица, имеющие право выступления, должны дождаться своей очереди и не мешать друг другу.{ENTER}\", S1000, S1000],\n            [\"Chat\", \"В случае необходимости судья может дать указания по порядку поведения в зале судебного заседания. Все присутствующие обязаны следовать указаниям судьи без возражений.{ENTER}\", S1000, S1000],\n            [\"Chat\", \"Публичные высказывания о ходе разбирательства запрещены до завершения судебного процесса. Это включает обсуждение дела в СМИ, публичных местах и т. д.{ENTER}\", S1000, S1000],\n            [\"Chat\", \"Перед началом судебного процесса судебный секретарь, судебный советник или судья обязаны ясно изложить все установленные правила судопроизводства, включая возможность заключения мирового соглашения.{ENTER}\", S1000, S1000],\n            [\"Chat\", \"В случае отклонения хотя бы одной из сторон от предложения о мировом соглашении, судебное разбирательство продолжается.{ENTER}\", S1000, S100]\n        ])\n    } else {\n        MsgBox(\"Извините, вы не можете зачитывать правила суда.`nВы должны быть судьёй или выше.\")\n    }\n}"
    },
    {
      "name": "HelpFunc_OpenWindow",
      "bind": "UI_Main",
      "type": "Func",
      "content": "open_role_window(Element?, *) {\n    roleWindows := Map(\"Секретарь\", \"Secretary\", \"Председатель\", \"Chairman\", \"Адвокат\", \"Lawyer\", \"Судья\", \"Judge\", \"Вице-Губернатор\", \"ViceGovernor\", \"Губернатор\", \"Governor\")\n    \n    if roleWindows.Has(Role) {\n        windowName := roleWindows[Role]\n        G_WindowData[windowName][1].Show(\"w260 h\" G_WindowData[windowName][2])\n    } else {\n        G_WindowData[\"Default\"][1].Show(\"w260 h\" G_WindowData[\"Default\"][2])\n    }\n}"
    }
  ],
  "bindsSortedArrayForSet": "AskPassport, AskToNotDisturb, ChangePassport, ForceStop, GivePassport, GoToMeeting, Greetings, PresentOfficially, Restart, RulesTrial, StartTrial, TakePassportAndStar, UDO_Give, UDO_Price, UI_Main, UI_Menu, UpBillboard, UseForce",
  "bindsSortedArray": "AskPassport, AskToNotDisturb, ChangePassport, GivePassport, GoToMeeting, Greetings, PresentOfficially, RulesTrial, StartTrial, TakePassportAndStar, UDO_Give, UDO_Price, UI_Main, UpBillboard, UseForce",
  "windows": [
    {
      "type": "Custom",
      "name": "Secretary",
      "label": "Секретарь",
      "bind": "None",
      "elements": "Greetings,PresentOfficially,AskPassport,UseForce,AskToNotDisturb,GivePassport,ChangePassport"
    },
    {
      "type": "Custom",
      "name": "Chairman",
      "label": "Председатель",
      "bind": "None",
      "elements": "Greetings,PresentOfficially,AskPassport,UseForce,AskToNotDisturb,GivePassport,ChangePassport,UpBillboard"
    },
    {
      "type": "Custom",
      "name": "Lawyer",
      "label": "Адвокат",
      "bind": "None",
      "elements": "Greetings,PresentOfficially,AskPassport,UseForce,AskToNotDisturb,GivePassport,ChangePassport,UDO_Price,UDO_Give,TakePassportAndStar"
    },
    {
      "type": "Custom",
      "name": "Judge",
      "label": "Судья",
      "bind": "None",
      "elements": "Greetings,PresentOfficially,AskPassport,UseForce,AskToNotDisturb,GivePassport,ChangePassport,UDO_Price,TakePassportAndStar,StartTrial,RulesTrial,GoToMeeting"
    },
    {
      "type": "Custom",
      "name": "ViceGovernor",
      "label": "Вице-Губернатор",
      "bind": "None",
      "elements": "Greetings,PresentOfficially,AskPassport,UseForce,AskToNotDisturb,GivePassport,ChangePassport,UpBillboard,UDO_Price"
    },
    {
      "type": "Custom",
      "name": "Governor",
      "label": "Губернатор",
      "bind": "None",
      "elements": "Greetings,PresentOfficially,AskPassport,UseForce,AskToNotDisturb,GivePassport,ChangePassport,UpBillboard,UDO_Price"
    },
    {
      "type": "Custom",
      "name": "Default",
      "label": "Водитель",
      "bind": "None",
      "elements": "Greetings,PresentOfficially,UseForce,AskToNotDisturb"
    }
  ],
  "afrSettings": [
    {
      "type": "AFR",
      "name": "Menu",
      "bind": "UI_Menu"
    },
    {
      "type": "AFR",
      "name": "ForceStop",
      "bind": "ForceStop"
    },
    {
      "type": "SYS",
      "name": "Restart",
      "bind": "Restart"
    }
  ]
}
```
