# Verified runtime — CombatHUD, Steam 1.09/build12996889

**Current evidence, 2026-10-29:**0.4.0 is visually accepted and explicitly authorized for stable publication. Exact installed hashes/source, loaded0.4.0,17 targets/native pressed hook and a finite6-second injured hold followed by1-second fade are confirmed in a live log snapshot without CombatHUD errors. [Owning0.4.0 report](CANDIDATE-0.4.0.md) separates user observations from logged events and records the live-session limitation.0.3.1 contextual reveal remains game-tested and is included in0.4.0 without a separate release. Historical observer evidence retains its original limits; crystals and optional live-rebind/focus-loss remain deferred/unverified.

## История: принятая стабильная 0.2.0 — runtime PASS, 2026-10-27

Пользователь подтвердил ожидаемое поведение урона, лечения, боя и меню. Лог UE4SS с маркером 0.2.0 и совпавшие installed hashes подтверждают точный кандидат ca342e33442a11b46a9ab30ed8e8cd796c9a8d60. Записаны внебоевой damage reveal 1/1, независимый idle 0.2/1 и full-heal hold при уже приглушённой ordinary-группе; ошибок CombatHUD нет. Точные события, log SHA-256 и пределы доказательств — [CANDIDATE-0.2.0.md](CANDIDATE-0.2.0.md). Чаровиты/input switching остаются отложены; все экраны и lifecycle-сценарии не объявляются проверенными. Пользователь отдельно принял 0.2.0 для main и стабильного выпуска; payload не меняется. Откат 0.1.0 сохранён. Далее сохранены исторические исследовательские gate и результаты; их формулировки о ещё не реализованной automatic policy относятся к тому этапу.

## История исследования: HP/items opacity и меню, 2026-10-27

HP и три QuickItem0/1/2 доступны как независимая яркая группа; наблюдённый split/full визуально соответствует ожиданию пользователя. Native меню сохраняют управление общим HUD_Panel, а отдельные цели не перезаписывались в sampled monitoring. В финальной сессии 5848 сравнений без конфликтов, прямой split→cleanup восстановил все 17 целей. Эксперимент удалён при закрытой игре; loader list восстановлен побайтно, production Lua/VERSION не менялись.

**Визуальный gate наблюдённого layout/меню — PASS.** Не объявлять универсальную production readiness: видимый keyboard CrystalList_Panel/F1-F2-F3 и input-layout switching не упражнялись (ветка нативно скрыта alpha0/Visibility2); автоматическая HP/combat/timer policy и её lifecycle acceptance не реализованы этим экспериментом. Следующий этап — разрешить эту границу при выборе production targets, затем отдельно реализовывать и проверять согласованную policy. Не повторять закрытые HP getters, QuickItem ownership или menu-parent проверки без нового основания.

Последующие разделы сохраняют историю доказательств. Их прежние HP-binding, item-binding, active-menu и rollback пробелы обновлены итоговыми сессиями в конце; исторические READY/BLOCKED относятся к своим этапам, а не переопределяют текущие ограничения.
## Историческая runtime-база 0.1.0

`GameGlobal:GetIsBattleState` (`/Script/Genesis`), CDO `Default__GameGlobal`, принимает `GenesisCharacter` из `hud:GetOwningPlayerPawn()`. Ранние попытки без аргумента или с виджетом были неверны. Принятые цели: `LeftBottom_Panel`, `HUDSkillUMG_BP`, `HUDActiveSkillUMG_BP`; обращения к Unreal только в game thread, ограниченный поиск и обработка невалидных объектов. `UEHelpers` — внешняя зависимость.

Поведение 0.1.0 принято пользователем 25.10.2026: вне боя 0.20, задержка 1.5 с, переходы по 1.0 с. В текущем `policy.lua` вход в бой тоже плавный; требование немедленного показа **при потере HP** нельзя реализовать одним включением существующей ветки `battle=true`: она оставит секундный переход. Новых runtime-результатов ниже нет.

## Узкое исследование HP, 2026-10-27

### Область, восстановление и доказательства

Задача: определить источник current/max HP и разделить HP-полоску с остальным управляемым HUD для [согласованных требований](REQUIREMENTS.md). Это исследование, без production-правок, изменения VERSION, сборок, установки, hot reload, запуска или завершения игры.

Исследовательская база: `6c01236dd9fdde6b4548d646d9af1587f92d721d`, ветка `research/combathud-hp-visibility`. Основной checkout на момент начала был чистым, но принадлежал `feature/boss-aphes-name` (`c85b3525a351fe00fd992a975665b9dbd7c185cb`); работа изолирована отдельным worktree. Новые требования присутствуют в исследовательской базе, отсутствовали в старом checkout. Актуальные DevRules прочитаны с `origin/main`, `a0c12f7ee7671a225465e73efb99ae6965e38b7f`, включая `User-mediated research handoff from ChatGPT`.

Публичный `NikichMods/Asterigos-Research` уже инициализирован: прямая проверка refs показывает `main=1f1407d38c09324c793e7d14749fe2e5e6f04677` (`docs: establish Asterigos shared research knowledge base`). GitHub connector metadata по-прежнему возвращала size=0; это не доказательство пустого репозитория. Прочитаны его контракт и технический раздел `docs/MODDING_EVIDENCE.md`: там прямо отмечено отсутствие подтверждённых игровых объектов/хуков, а HP final writer остаётся открытым вопросом. Дополнительного готового HP/HUD API этот источник не дал. Старые корневые записи «отдельного репозитория нет» и исходная предпосылка «он пуст» устарели. Его наполнение не входит в задачу; выводы CombatHUD принадлежат этому документу.

Использованы прежние `hud-auto-hide-audit/Findings.md`, JSON виджетов и `script-objects.txt`; ранее полученный bytecode `NormalHUDBP`; действующий Lua и архив принятой версии. Старое исследование по заполненности ресурсов содержало иной UX и не является текущим требованием.

Для вопроса о финальном writer дополнительно прочитаны bytecode нужных HUD Blueprint и `hilda_BP` из установленного контейнера существующим CUE4Parse reader 1.2.2 (`ReadScriptData=true`, `GAME_UE4_27`). Новый probe/reader не писался. Дампы, ключи, инструменты и машинные пути остались локально под ignored `.local` и в историческом архиве. SHA JSON зависит от режима экспорта; старые и новые JSON нельзя считать одинаковыми только по имени.

Steam manifest непосредственно сообщает buildid `12996889`. Контрольные SHA256 входов:

| Вход | SHA256 |
| --- | --- |
| `Genesis-Win64-Shipping.exe` | `ddea6b5ca5d34836f01702993d20209c2595367287e6cd5a135a7ace1958b1c0` |
| `pakchunk0-WindowsNoEditor.utoc` | `0e9d27f84b97f24651ae1ca0ed38facad171e620702cab08198b14b56e52513e` |
| `NormalHUDBP--BloodHeavyUpdate.bytecode.json` (существующая выгрузка) | `9235d4d012ff443c3364f694ee4b8f464037665e44f90bae148ef13c0f1242c3` |
| `HUDMainUMG_BP.json` (новый экспорт с bytecode) | `6c26eb0e427490bf9e55b2d27d2bb81d5bc2dbb1353c2a9645585c99d1f3aeaa` |
| `HUDStatusBarUMG_BP.json` (новый экспорт с bytecode) | `a9031c8e824c3cf3c584a7c432da355639fac989b6d20b02569cb5f453cd174e` |
| `HUDProgressBarUMG_BP.json` (новый экспорт с bytecode) | `ea99468230b3e85adfd2e705ef2248cc6a5e6e3498e8457043f5d51cb472fba7` |
| `hilda_BP--ExecuteUbergraph_hilda_BP.bytecode.json` | `b6d56df1d77940724f0422c73d96dd03049f6fd5f5bf7dd6ffea06b72d8bc9f4` |

Этот hash контейнерного индекса не заменяет hash всех игровых данных и не доказывает совместимость с другими сборками. Установленные `CombatHUD/Scripts/main.lua` и `policy.lua` побайтно совпадают с исследовательской базой по SHA256: соответственно `63f4de5a4a59a4dd263a782d46ed194ccf1f89683cabfd45b7ba68445e8e8c30` и `d47eb701863875bfebee249d4514abaf06d004489b4e467a649bb2daea33a095`.

### A. Здоровье: статически установленные API и владелец

Подтверждённый штатный **путь чтения**, а не догадка по имени:

| Точный идентификатор | Подтверждённый контракт |
| --- | --- |
| `/Script/Genesis.GameGlobal:GetHP` | Один входной объект `GenesisCharacter`, результат `FloatProperty` (4 байта) |
| `/Script/Genesis.GameGlobal:GetMaxHP` | Один входной объект `GenesisCharacter`, результат `FloatProperty` (4 байта) |
| `/Script/Genesis.GenesisCharacter:CharAttrComponent` | Поле персонажа, передаваемое штатным HUD как объект атрибутов; точный native-класс компонента и layout числовых полей здесь не установлены |

Доказательство сигнатур: `/Game/uiresources/NormalHUDBP.NormalHUDBP_C:BloodHeavyUpdate`. На offset 0 штатно вызывается `GameGlobal:GetPlayerCharacter`; offset 20 проверяет `IsValid`, offset 49 пропускает невалидного. Offset 83 вызывает `GameGlobal:GetHP` с этим объектом; offset 120 — `GameGlobal:GetMaxHP` с тем же объектом; оба результата записываются в float. `EX_CallMath` подтверждает статический Blueprint-вызов, без дополнительного world/widget аргумента. Это **не** getter без аргументов на pawn. Имена native Parm и FunctionFlags в живой UE4SS reflection ещё не сняты.

В `NormalHUDBP_C:UpdateCharStat`, offset 215, `CoherentUIGTJSEvent:AddObject` получает `GenesisCharacter.CharAttrComponent`. Это подтверждает связь персонаж → объект атрибутов для штатного HUD. Тело C++ getters и точный внутренний final writer HP не исследованы; нельзя утверждать, что getters всегда читают конкретное предположенное поле `.HP`/`.MaxHP` или обходить их угадыванием layout. `script-objects.txt` также содержит `BaseGameObject:GetHP/GetMaxHP` и `BaseCharacterAnimInstance:GetHP`; это другие владельцы, не взаимозаменяемые варианты вызова.

**Рекомендуемый UE4SS-путь, ещё требующий binding-проверки:** тот же CDO/объект `GameGlobal`, который уже используется CombatHUD, и вызовы `global:GetHP(character)`, `global:GetMaxHP(character)` после проверки UFunction. Передавать существующий проверенный `hud:GetOwningPlayerPawn()`, а не искать первый `hilda_BP_C` в мире и не менять принятый источник владельца.

Перед будущим использованием: живой HUD в viewport; валидный owning pawn с цепочкой до `GenesisCharacter`; функции найдены по точному пути и имеют ожидаемые Parm/return/статичность; валидный объект вызова. Результаты — конечные числа, max > 0; невозможное/переходное состояние не трактовать как урон или полное здоровье. Чтение обоих значений в одном game-thread callback; адреса HUD/pawn должны принадлежать текущему поколению. На смене HUD/pawn, пропаже данных и сбросе игрового времени сбрасывать сравнение и таймеры. Первый замер неполного HP должен включать HP-исключение, но не создавать вымышленное событие урона.

Произвольный epsilon, округление до целых и сравнение по проценту полоски не доказаны. Сравнивать именно current HP; изменение max само по себе не равно потере current HP. Если нужен допуск из-за наблюдаемого float-шума, сначала измерить его и проверить, что он не скрывает малый фактический урон.

### B. Обнаружение урона: что найдено и чего это не доказывает

Имена и владельцы из таблицы native script objects:

- `/Script/Genesis.GenesisCharacter:BuffDamageEvent`;
- `/Script/Genesis.GenesisCharacter:FallEvent` и `FallOverHeightEvent`;
- `/Script/Genesis.BaseGameScriptObject:EventCharacterDamage`;
- `/Script/Genesis.BaseGameEventObject:HitEventPhysicCollisionDamage`;
- `/Script/Genesis.GameGlobal:DamageCharacter_Cpp`;
- стандартные `/Script/Engine.Actor:ReceiveAnyDamage`, `ReceivePointDamage`, `ReceiveRadialDamage`.

Это **наличие имён**, не доказательство порядка вызовов, UE4SS hookability, покрытия всех источников или уже совершённой потери HP. Нельзя по ним утверждать, что яд/огонь/падение проходят через `ReceiveAnyDamage`, либо что положительный входной Damage равен уменьшению HP после защиты/неуязвимости. `DamageCharacter_Cpp` нельзя вызывать для проверки: это потенциально изменение игры.

Дополнительная статическая проверка `/Game/MainContent/Act/Character_BP/hilda_BP`:

- Blueprint `FallEvent` переопределяет `GenesisCharacter:FallEvent`, единственный входной Parm — float `fallHeight`.
- Соответствующая ветка ubergraph, offsets 16723–16966, проверяет высоту >= 600 и `GameGlobal:IsAlive`, затем играет `hilda_falling_hurt`. Здесь не читается и не сравнивается HP. Звук/высота падения не являются детектором фактически применённого урона; native падение осталось за границей этого Blueprint.
- Литерал `OnDamage` на offset 13664 — аргумент `GameObjectExecuteAction` для `Ult_Shd02_VFX`, а не доказанный универсальный HP callback Хильды. Не регистрировать выдуманный `hilda_BP_C:OnDamage` на основании этого литерала.

| Механизм | Покрытие и корректность | Цена и ограничения |
| --- | --- | --- |
| Сравнение current HP в существующем 50-мс update | Отрицательная разница у одного pawn не зависит от источника: потенциально удар, падение, DoT, среда. Не реагирует на удар без потери HP | Два getter-вызова на update (номинально около 40/с), без новых world scans. Стоимость не измерялась. Потеря и лечение между замерами могут компенсироваться; несколько потерь сливаются. Задержка до следующего выполненного update; 50 мс не жёсткая верхняя граница при нагрузке |
| События урона + проверка фактического HP | Потенциально меньшая задержка и видимость отдельных изменений, если событие действительно окружает/следует HP commit | Нужны точные подписи, pre/post-порядок, охват каждого источника и lifecycle cleanup. Событие намерения или анимации не годится само по себе |
| Единый verified HP-change/commit hook | Лучший кандидат для строгого «любое уменьшение», включая компенсацию лечением между poll | Такой seam пока не установлен; низкоуровневые перехваты/замена расчёта HP не обоснованы |
| События как ускоритель + редкий/существующий опрос | Можно совместить быстрый показ и проверку загруженного неполного здоровья | Больше движущихся частей; polling fallback не доказывает полноту пропущенных событий |

**Вывод исследования:** sampled delta — самый простой кандидат, независимый от типа урона, но ещё не доказанная реализация всех согласованных требований. Нельзя молча заменить «любое уменьшение немедленно» на «чистое уменьшение раз в 50 мс». Если строгая событийная полнота обязательна, потребуется подтверждённый HP-commit seam; возможное принятие дискретного опроса — отдельное UX-решение пользователя. Боевой флаг, анимация удара, звук, изменение max и сглаженная длина полоски не заменяют фактическую потерю HP.

Новые runtime-наблюдения по ударам, падению, яду, огню и прочим опасностям **не проводились**. Их универсальное покрытие не объявляется проверенным.

**Принятое решение, 2026-10-27:** пользователь выбрал sampled delta в существующем номинально 50-мс цикле и явно принял возможность пропуска потери с полным восстановлением HP между соседними замерами, а также зависимость задержки от фактического update. Поэтому поиск универсального damage-hook больше не является блокером. Runtime-корректность штатных getters, смены pawn и fallback всё ещё нуждаются в проверке. Это выбор механизма, не приёмка работающего мода.

### C. Иерархия HUD: статически подтверждено

Пакеты находятся под `/Game/MainContent/Template/UMG/HUD/`. `HUDMainUMG_BP_C` наследует `/Script/Genesis.HUDMainUMG`, `HUDStatusBarUMG_BP_C` — `HUDStatusBarUMG`, `HUDProgressBarUMG_BP_C` — `HUDProgressBarUMG`.

Связи восстановлены по `WidgetTree.RootWidget`, `Slots`, `Parent` и `Content`, а не только по UObject Outer:

```text
HUDMainUMG_BP_C
  Main_Panel
    CurrencyGetUMG_BP
    HUD_Panel
      IndicateTip_UMG
      HUDSkillUMG_BP                 [прежняя правая цель]
      HUDActiveSkillUMG_BP           [прежняя правая цель]
      LeftBottom_Panel               [прежняя общая левая цель]
        HUDUseItemUMG_BP             [быстрые предметы]
        HUDStatusBarUMG_BP
          CanvasPanel_0
            Main_Panel
              HPDamageBar           [HUDProgressBarUMG_BP_C]
              HPBar                 [HUDProgressBarUMG_BP_C]
              WarningBar            [ProgressBar]
              HPArrow_Image         [Image]
              HPFrameLine0_Img .. HPFrameLine3_Img [Image]
              APBar                 [выносливость]
              ExpBar                [опыт]
              UnUsePoint_Image      [неиспользованные очки]
              DamageTipList_Panel
                TipItem_0           [HUDDamageTip_BP_C]
```

Порядок списка — логическая группировка, не утверждение о z-order. `hud.HUDStatusBarUMG_BP` и перечисленные HPBar/HPDamageBar/HPArrow/HPFrameLine/WarningBar/APBar/ExpBar/UnUsePoint/TipItem_0 подтверждены как reflected ObjectProperty. Внутренние `Main_Panel`, `CanvasPanel_0` и `DamageTipList_Panel` **не** перечислены среди новых Blueprint ChildProperties: нельзя обещать доступ `status.Main_Panel`/`status.DamageTipList_Panel` как проверенное Lua-поле. Родителя можно исследовать от `status.HPBar:GetParent()`; точное bounded перечисление детей и identity-match необходимо подтвердить в UE4SS. В script objects подтверждены `Widget:GetParent`, `Widget:GetRenderOpacity`, `PanelWidget:GetChildrenCount`, `PanelWidget:GetChildAt`; их использование для этой новой цепочки ещё не проверено.

`HPBar` использует `Hp_bar`, `Hp_frame`, `Hp_bartip`, `HudHpBarMask`, `TickPercentSpeed=0.3`. `HPDamageBar` занимает тот же прямоугольник (Left=16, Top=14, 350×16), использует `Hp_base`, `Hp_barRed`, `Hp_frame`, `TickPercentSpeed=0.6`. Предупреждение `WarningBar` также лежит поверх области HP и управляется анимацией `Warning`: `FillColorAndOpacity`, включая её alpha. Поэтому отдельно оставить ярким только foreground HPBar — недостаточный кандидат для целостной нативной полоски.

Внутри `HUDProgressBarUMG_BP_C`: `CanvasPanel_0` содержит `Bg_Imgage` (именно это написание), `Bar_ProgressBar`, `Frame_Image`, `Mak_RetainerBox`; в retainer находится `CanvasPanel_1` с `Head_Img`. Эти внутренние эффекты/материалы не следует переписывать ради независимого внешнего RenderOpacity.

**Кандидат границы «полоска HP»:** HPBar + HPDamageBar + HPArrow_Image + четыре HPFrameLine + WarningBar, с сохранением native Visibility и внутренних цветовых alpha. Это техническая рекомендация по слоям полоски, а не результат визуальной приёмки. APBar, ExpBar, UnUsePoint_Image, DamageTipList_Panel и HUDUseItemUMG_BP относятся к остальному левому HUD и должны приглушаться независимо от неполного HP.

### Наследование прозрачности и финальный writer

При alpha родителя 0.20 и alpha ребёнка 1.0 эффективный вклад остаётся 0.20. Поэтому оставить `LeftBottom_Panel` на 0.20 и выставить HPBar=1.0 нельзя. Обратная компенсация alpha, перенос виджетов/создание дубликата полоски, смена Visibility, правка материалов или .pak расширяют вмешательство и не нужны по найденной структуре.

Минимальный кандидат: убрать **собственное** приглушение общих левых предков; задавать отдельные множители HP-группе и остальным непосредственным детям статусного Main_Panel, плюс `HUDUseItemUMG_BP`. Правые цели сохраняются. Общие предки остаются под управлением игры: меню/кат-сцены могут скрывать или приглушать весь HUD. «Полностью видимая HP» означает отсутствие дополнительного приглушения CombatHUD, не отмену нативного скрытия. Не умножать alpha одновременно у родителя и его потомков (иначе 0.20×0.20).

Статический final-writer анализ: `HUDStatusBarUMG_BP_C:Tick` входит в ubergraph на 10, прыгает на 15 и возвращается; Construct сразу возвращается на 15. Blueprint не содержит здесь обновления HP или RenderOpacity. `HUDProgressBarUMG_BP_C:Tick` входит на 1010 и завершает ветку; его Construct/PreConstruct настраивают brushes/style/Visibility, а не доказанный новый opacity-контроллер. `HUDMainUMG_BP` Construct вызывает SteamDeckUpdate; тот меняет scale/translation. Native классы и `Warning`-анимация продолжают участвовать в финальном рендеринге. Отсутствие opacity-write в этих Blueprint **не доказывает** отсутствие записи из C++ или других систем.

Следовательно, восстановление прежнего parent-множителя и независимые leaf-множители логически решают наследование, но отсутствие конкурирующего native writer и реальный рендеринг новых целей ещё требуют runtime-проверки. Не записывать 1.0 в общие предки каждый update: это может переопределить игру. При переходе со старой схемы учитывать ранее записанный модом parent alpha; способ cleanup/rollback должен быть проверен до установки нового кандидата.

### D. Рекомендация и граница готовности

Предпочтительная архитектура после закрытия пробелов: сохранить owning-pawn/battle/time/discovery/error path CombatHUD; читать штатные HP getters; разделить внешний opacity на `otherAlpha` и `hpAlpha`; не перехватывать расчёт урона и не менять характеристики. Для обнаружения потери HP принят sampled delta в существующем цикле, с указанным пользовательским ограничением. Независимые leaf-цели проще и уже, чем reparenting/дублирование/native patch, однако ещё не прошли runtime gate.

Семантика будущей policy, вытекающая из REQUIREMENTS:

1. Подтверждённая потеря HP немедленно ставит оба собственных множителя в 1.0 и обновляет время последнего урона, даже в середине fade. Обход плавного reveal нужен именно для этого события; обычный вход в бой сохраняет принятую политику перехода.
2. Вне боя `otherAlpha` ждёт 1.5 с после последнего урона/обычного выхода из боя, затем за 1.0 с идёт к 0.20; повторный урон перезапускает hold.
3. При current < max `hpAlpha=1.0` независимо от таймера и при загрузке уже раненого pawn. Это не удерживает яркость остальных элементов.
4. Переход из неполного в полное HP запускает **отдельный HP hold** на 1.5 с от восстановления, затем fade 1.0 с. Не перезапускать таймер остальных панелей одним лечением. Возвращение в бой подчиняется действующей боевой логике.
5. Игровое время сохраняет паузу; смена HUD/pawn, время назад, невалидные данные/ошибка сбрасывают сравнение, восстанавливают все реально затронутые цели и не генерируют ложный урон. Не восстанавливать посторонние native цвета/Visibility.

На момент статического исследования production readiness: **BLOCKED**. Статические владельцы getters и widget slots установлены; реальный UE4SS binding, фактическое чтение двух getters и окончательное владение opacity новых leaf-целей не доказаны; допустимость sampled detection согласована, но его runtime корректность ещё не испытана. Исследование достаточно, чтобы перейти к ограниченной проверке этих конкретных неизвестных, но не чтобы объявить новую production-логику готовой.

### План runtime-probe на момент статического исследования

Сначала отдельное разрешённое **наблюдение данных**, без изменения gameplay/opacity и без вызова событий урона:

- На проверенном HUD/pawn получить reflection ровно двух getters: точные Parm, float return и flags; проверить CDO. Прочитать пару HP/max, проверить значения при полном/неполном HP и лечении. Логировать только identity и изменения, с game time и bounded sampling; не делать полный object dump.
- Один раз на поколение HUD снять parent-chain от HPBar/HPDamageBar/HPArrow/WarningBar, имена/классы/адреса непосредственных соседей и их RenderOpacity/Visibility; проверить доступность GetParent/GetChildrenCount/GetChildAt. Подтвердить возможность привязать DamageTipList_Panel по точному имени и связи, без глобального поиска.
- На естественных пользовательских примерах удара, падения, яда/DoT и огня/среды сопоставить current HP с точным временем и доступными reflected damage events. Сначала снять их подписи и порядок; только затем рассматривать наблюдающие hooks без замены аргументов/результатов. Падение без урона/блок/неуязвимость нужны как отрицательные примеры, если доступны естественно. Не вызывать damage setters, не создавать урон искусственно. Наблюдение обычных сценариев само по себе не доказывает отсутствие потерь между samples.

Результат наблюдения должен подтвердить работоспособность выбранного чтения HP и границы отслеживания; пользователь уже принял sampling как практический компромисс. Инвентаризация всех damage events больше не нужна. Достаточно естественного примера реальной потери HP, если это потребуется для проверки сравнения; не создавать урон синтетически.

После данных, отдельным обратимым **визуальным экспериментом** по правилам runtime harness проверить предложенные leaf-группы, native writer и rollback. Простое read-only чтение opacity не докажет, что C++ не перезаписывает установленный модом множитель. До такой проверки подготовить сохранение/восстановление только своих прежних значений и проверенный cleanup; не hot reload принятого мода. Проверить HP отдельно от выносливости/опыта/предметов, Warning/damage trail, меню/кат-сцены, паузу и смену HUD. Не совмещать непроверенную data-source и opacity-архитектуру в production-кандидат.

Проверка handoff: существующие `tools/test.py CombatHUD` (policy и mock adapter) пройдены на неизменённом Lua; `git diff --check` пройден. Это проверка сохранённой базы, не новой HP-функции. Изменяются только этот документ и STATUS.md.

На этапе статического исследования probe, визуальный эксперимент и runtime-тест новой функции не создавались и не запускались. Исторические raw evidence остаются в ignored `.local` и исходном архиве; публичный handoff содержит только производные факты и ограничения.

## Runtime binding/structure probe — подготовка 2026-10-27

На базе `471cd4c81df6677a4cf7a04c3806b813be95dfc9` подготовлен отдельный read-only [probe](../research/hp-readonly-probe/README.md), identity `combathud-hp-readonly-01`. Исследовательский Lua находится вне production Scripts; VERSION и принятый CombatHUD не изменены. Метод выбран потому, что оставшиеся вопросы — реальный UE4SS binding getters и live ownership widgets — не решаются повторной статической выгрузкой или mock-тестом.

Проверены Lua syntax и три отрицательных mock-сценария (функция отсутствует, неверная сигнатура, отсутствует static flag): probe отключается до вызова HP; очередь не накапливает второй game-thread callback. Эти проверки не доказывают реальные привязки. Probe ограничен известными объектами, не меняет opacity/Visibility/HP, не вызывает damage events и не пишет save-state. Процедура и минимальная матрица принадлежат README probe.

**Статус на момент подготовки: runtime результат ожидается.** Подготовка/установка не означают работоспособность getters или подтверждение структуры. После пользовательского запуска нужно сохранить свежий лог, сопоставить source/installed SHA256 и наблюдения; после закрытия игры убрать только отдельный probe. Переход к визуальному эксперименту пока не подтверждён.

### Первая runtime-сессия: 2026-10-27, 17:16–17:17 МСК

Точная исходная идентичность probe-01: `ea8d36e6ca679fcd682313e664bfbdb9e6ac8035`, SHA256 Lua `a0463e067688d86a0c36d663bd57cb633b8f865da5ea1142cb95451b1d0466ae`. Loader подтвердил запуск через enabled.txt. Установленный hash после сессии совпал. Исходный лог сохранён локально вне loader paths: SHA256 `c2bf574f315186014a6fbdd64ee1bbec6fa515d81c8d9f97918f335b4c417246`. Хеши production CombatHUD и SoulsEnemyHUD остались прежними; процесс игры после пользовательского выхода отсутствует.

**Подтверждено reflection в живом UE4SS:** обе функции имеют `ObjectProperty ...:Character` и `FloatProperty ...:ReturnValue`; flags каждой `335684609`, включая static bit `0x2000`. Объект предполагаемого вызова найден как `GameGlobal /Script/Genesis.Default__GameGlobal`.

**Не подтверждено:** сами getter-вызовы и числовые результаты, различение полного/неполного HP, live связи HP-виджетов. В 17:16:31 probe остановился на ancestry-check owning pawn, `samples=0`. Он не дошёл до OWNER/структуры или BEFORE_READ. Полное имя неподходящего pawn первая попытка не записывала — его конкретный класс неизвестен. В той же сессии принятый CombatHUD в 17:16:40 подтвердил `hilda_BP_C`; это показывает, что первая проверка observer была слишком ранней и ошибочно фатальной. Сообщение пользователя о потере/восстановлении HP не заменяет отсутствующие числовые samples.

Исправление только исследовательское: [probe-02](../research/hp-readonly-probe-02/README.md) пропускает отсутствующий/неподходящий owning pawn и повторяет bounded HUD acquisition, как production adapter. Он пишет WAIT_OWNER с фактическим именем, не вызывает getters на неподходящем объекте; неоднозначный HUD также ожидается. Reflection выполняется один раз, не при каждом ожидании. Проверены синтаксис и отрицательный mock startup-owner: ожидание без STOP/HP-вызовов и не чаще одного discovery в секунду. Probe-01 и его evidence сохранены без изменения. Production Lua/VERSION не изменены; следующая попытка требует нового пользовательского запуска. **Визуальный эксперимент всё ещё не готов: data/structure gate открыт.**

## Успешная runtime-сессия probe-02: 2026-10-27, 17:24–17:26 МСК

### Идентичность и сохранность окружения

- Игра: принятый Steam 1.09/build12996889, UE4.27, Windows x64; свежий лог loader сообщает `UE4SS v3.0.1`, Git SHA `83330635`. Окружение DX11/Smooth Motion — принятая проектная база, новый FPS/графический benchmark не проводился.
- Source: `9f1514058029aa77928faf03daf3f94ea9c7fed0`, `CombatHUD/research/hp-readonly-probe-02/main.lua`, ID `combathud-hp-readonly-02`.
- SHA256 установленного и сохранённого Lua: `a4407110e1aeb95f12ba04cf906d860228b149401aafbfbfcebb1db9d0381ab6`. Он совпал с installation manifest после сессии; production CombatHUD и SoulsEnemyHUD совпали с pre-install hashes.
- SHA256 полного свежего UE4SS log snapshot: `cb62a34b09212c75f26146dfd3e33b744c7decad0a77d2fdf5a2337ba8aa1694`. Raw log, manifests и frozen installed source сохранены локально в ignored evidence вне loader paths; в Git не публикуются приватные пути или полный лог.
- Loader запустил отдельный probe в 17:24:30. В 17:25:27 он остановился сам: `reason=full-partial-recovered-observed samples=577 full_seen=true partial_seen=true recovery_seen=true`. Строк REJECT этой попытки нет. `Event loop end` — 17:26:14, после пользовательского выхода. Probe не пишет host data и не регистрирует hooks.
- При cleanup подтверждено отсутствие процесса игры. Удалены только известные `CombatHUDHPProbe/enabled.txt`, `Scripts/main.lua` и опустевшие каталоги, без recursive delete; отдельной папки probe больше нет. `mods.txt`, production Lua обоих модов и VERSION не менялись. Игру запускал/закрывал пользователь; автоматического запуска/завершения и hot reload не было.

### 1. Реальный HP binding и значения

В 17:24:47 обе UFunction найдены по точным путям `/Script/Genesis.GameGlobal:GetHP` и `:GetMaxHP`. Для каждой `ForEachProperty` вернул ровно:

- `ObjectProperty /Script/Genesis.GameGlobal:<method>:Character`;
- `FloatProperty /Script/Genesis.GameGlobal:<method>:ReturnValue`.

`GetFunctionFlags()` обеих = `335684609`, static bit `0x2000` установлен. Объект вызова — `GameGlobal /Script/Genesis.Default__GameGlobal`. В 17:24:57 проверена ancestry owning pawn до `GenesisCharacter`, конкретный класс `hilda_BP_C`. Источник pawn — именно `hud:GetOwningPlayerPawn()`, как в принятом CombatHUD; глобальный поиск Хильды не использовался. `global:GetHP(pawn)` и `global:GetMaxHP(pawn)` оба успешно завершились с Lua `type=number`.

| Событие | МСК | Game time, с | Current HP | Max HP | Проверка |
| --- | --- | --- | --- | --- | --- |
| Первый валидный sample | 17:24:57 | 7.4113392829895 | 680.0 | 680.0 | `full=true`, baseline; не событие урона |
| Наблюдённая потеря | 17:25:19 | 30.002870559692 | 532.07415771484 | 680.0 | `full=false`, delta `-147.92584228516` |
| Начало зарегистрированного роста | 17:25:24 | 35.302646636963 | 534.79418945312 | 680.0 | Положительная delta; всё ещё неполное HP |
| Полное восстановление | 17:25:27 | 37.98588180542 | 680.0 | 680.0 | `full=true`, последняя delta `5.5846557617188` |

В течение наблюдения max оставался 680; HP после урона дробное и затем постепенно возрастало до точного равенства max. Таким образом `hp < max` и `hp == max` различают проверенные состояния без округления отображаемой полоски и без произвольного epsilon. Это не доказательство целочисленности HP, универсального float-допуска или поведения при buffs/max changes. Не округлять current HP до целого перед sampled delta.

577 samples относятся примерно к 30.6 секунды game time в одном поколении pawn/HUD. Это sanity-check adopted 50-мс пути, не гарантия realtime-латентности, не измерение стоимости getters и не доказательство всех случаев урона/лечения между samples. Выбранное пользователем ограничение sampling остаётся в силе.

### 2. Реальная доступность и parent identity

Одна и та же live структура подтверждена через reflected ObjectProperty, `Widget:GetParent`, `PanelWidget:GetChildrenCount/GetChildAt`, `GetRenderOpacity`, `GetVisibility`:

- `hud.HUDStatusBarUMG_BP` (`HUDStatusBarUMG_BP_C`) и `hud.HUDUseItemUMG_BP` (`HUDUseItemUMG_BP_C`) имеют родителя, совпадающего по адресу с `hud.LeftBottom_Panel` (`CanvasPanel`). Родитель LeftBottom — `HUD_Panel`.
- `status.HPBar:GetParent()` даёт `CanvasPanel Main_Panel`; его родитель — `CanvasPanel_0`. У `CanvasPanel_0:GetParent()` результат nil: это корень вложенного UserWidget. Нельзя восстанавливать весь owner path одним непрерывным GetParent через границу UserWidget; связь к status берётся через проверенную reflected owner-ссылку.
- Все восемь HP-целей доступны как `status[key]` и имеют тот же parent address `Main_Panel`: `HPBar`, `HPDamageBar` (`HUDProgressBarUMG_BP_C`), `HPArrow_Image` (`Image`), `WarningBar` (`ProgressBar`), `HPFrameLine0_Img`…`HPFrameLine3_Img` (`Image`).
- Соседи `APBar`, `ExpBar`, `UnUsePoint_Image` доступны reflected-ссылками и имеют того же родителя.
- `Main_Panel:GetChildrenCount()` = 12. Zero-based children enumeration вернула уникальные имена: `UnUsePoint_Image`, `ExpBar`, `HPDamageBar`, `HPBar`, `WarningBar`, `APBar`, `HPArrow_Image`, `HPFrameLine0_Img`, `HPFrameLine1_Img`, `HPFrameLine2_Img`, `HPFrameLine3_Img`, `DamageTipList_Panel` (порядок именно наблюдённой enumeration, не утверждение о z-order).
- Для всех HP-слоёв и трёх reflected соседей адрес найденного по точному имени child совпал с reflected-ссылкой. `DamageTipList_Panel` — `CanvasPanel`, найден в этом bounded наборе; адрес `status.TipItem_0:GetParent()` совпал с ним. Для этой задачи не нужен глобальный поиск или недоказанное прямое поле `status.Main_Panel`/`status.DamageTipList_Panel`.
- Итоговая строка: `STRUCTURE_OK generation=1 child_count=12 hp_layers=8 sibling_lookup=exact-name-and-parent`.

Однократное чтение в 17:24:57: RenderOpacity всех 18 записанных WIDGET = 1.0. Raw Visibility: status/left/items/status-main/status-root/HPBar/HPDamageBar/APBar/ExpBar/DamageTipList_Panel = 4; HUD_Panel/WarningBar = 3; HPArrow и четыре HPFrameLine = 0; UnUsePoint_Image = 2. Сохраняются именно raw значения UE4SS enum, не предполагается, что все эти слои визуально одинаково активны. Native Warning цветовая alpha и видимость не переопределялись. Snapshot opacity в момент acquisition не доказывает отсутствие другого writer позже, включая действующий CombatHUD, который затем приглушает общий LeftBottom.

### 3. Загрузка, пределы и следующий gate

Probe-02 в 17:24:47 увидел `DefaultPawn` в `UIOnlyMap`, вывел `WAIT_OWNER` и не вызвал HP на нём. В 17:24:57 появился другой HUD и owning `hilda_BP_C`; только тогда выполнены структура и getter reads. Это непосредственно подтверждает необходимость пропускать startup UI pawn, не подбирать альтернативного персонажа и сбрасывать sampled baseline при приобретении рабочего владельца. Первая попытка была ошибкой observer, не доказательством неисправности HP API.

**Gate этого шага: PASS** — реальные calls/signatures/finite values/full vs partial, HP targets, parents и bounded sibling identity проверены в одной сессии. **Готовность отдельного визуального эксперимента: READY**, без production-реализации в этой задаче.

Осталось для отдельного opacity-этапа: подтвердить видимый состав HP-группы (рамка, damage trail, warning), независимое приглушение AP/опыта/предметов/подсказок, отсутствие конкурирующей C++/анимационной записи RenderOpacity, сохранение native меню/кат-сцен и точный cleanup/rollback собственных множителей без hot reload. Read-only evidence не закрывает эти вопросы.

Не проверялись этой сессией: смена playable pawn/respawn или HUD после начала HP samples, max HP changes, пауза/возврат времени, новые failure/fallback ветки production, все типы урона, другие билды/UE4SS и FPS. Для реализации сохранить принятую lifecycle/fallback политику и тестировать изменяемое поведение отдельно; уже подтверждённые static extraction и HP/структуру не повторять без нового основания.

## Визуальный эксперимент HP + предметы: подготовка 2026-10-27

Новая исходная точка требований `e0cd8ddc77147b95341296c13ffb7c83d466eea6` добавляет постоянную яркость всех трёх предметов при неполном HP. Закрытые HP-getter/HP-layer исследования повторно не выполняются.

Статическое новое evidence из прежних локальных JSON: `HUDUseItemUMG_BP_C` имеет reflected `QuickItem0/1/2` (`HUDItemSlotUMG_BP_C`) под `QuickItem_Panel`. Внутри того же item root отдельно находятся `CrystalList_Panel` с `KBCrystalSlot0..3` и `HUDCrystalUMG_Pad_BP`. У каждого HUDItemSlot под MainPanel пять составляющих: `Bg_Image`, `Icon_Image`, `ValueBg_Image`, `Value_Text`, `Key_Image`; первые четыре Image-ссылки отражены (Value_Text ищется среди bounded children). SlotIndex 1 и 2 явно записаны; нулевой использует defaults. Это static ownership, не live proof клавиш 1/2/3 или корректного рендеринга.

Минимальный метод — [отдельная ручная визуальная проекция](../research/opacity-experiment-01/README.md), ID `combathud-opacity-01`: passive bind → split/full → native menus → rollback. Он не реализует новую policy и не требует повторного урона/лечения: проверяется независимая прозрачность, а не уже известный источник HP. Автоматика раскрытия при уроне/восстановления HP останется отдельной production-проверкой. Общие родители не изменяются; 17 неперекрывающихся целей меняются один раз при выборе режима, затем читаются на предмет native overwrite. Установка предусматривает временное отключение writer CombatHUD только в mods.txt, с точным backup/restore и неизменными production Lua.

Offline safety checks пройдены: passive/no writes, split/full, отсутствие постоянной перезаписи opacity, сохранение native parent hiding, rollback, conflict containment без стирания нового native значения, startup pawn wait. **Live item ownership, визуальный результат, sampled native writer и runtime rollback пока ожидаются**; эта подготовка не закрывает production readiness.

### Opacity-01 session: binding failure before writes, 2026-10-27 20:25–20:26 МСК

Source `e7e0037e244024b9513cff3854f194d7bb2304fc`, installed Lua SHA256 `eff54561ed5fe37e0e127cd2baffb0cda3147ce63e685d0e3037a262e5e9da49` matched after session. Raw session snapshot SHA256 `b3178f1aa816938a584e15f3ffdbb7d0909fd7c4d5ed4a93e31ff7e3edaac248`, retained locally outside loader paths. The game was closed by the user; production payload hashes and temporary mods.txt matched their deployment identities.

Live binding reached all 12 status children and `QuickItem0` (`HUDItemSlotUMG_BP_C`, SlotIndex=0), whose parent was the `QuickItem_Panel` address under the current `HUDUseItemUMG_BP`. It then stopped at `item reflected leaf mismatch`, before READY, MODE or WRITE. The content MainPanel and child-count checks preceding that assertion passed, but individual internal child names/addresses were not yet logged. The exact failing field and mismatch cause remain unknown. User observation: HUD remained bright and Ctrl+F8/F9/F10 had no effect. The dead observer explains the absent mode changes; no conclusion about working keyboard callbacks or independent rendering can be drawn.

Failure cleanup logged `restored=0 expired=0 native_changed=0 failures=0`, `cleanup=true checks=0 conflicts=0`: no experiment opacity mutation occurred. It does not prove restoration after actual visual writes. Startup DefaultPawn was skipped as intended. No new HP research was needed.

The parent-group mechanism remains appropriate: none of its 17 opacity targets depends on the redundant internal child-name/reflected-alias comparison. [Attempt 02](../research/opacity-experiment-02/README.md) therefore logs actual bounded content children, validates four Images + one TextBlock under the verified panel, and reports reflected alias/address matches separately. Matching by displayed FName spelling is not a precondition for mutating the enclosing item panel. All outer ownership checks and rollback/native-writer guards remain. A display-spelling difference is a test fixture/hypothesis, not the established live cause. New CONTROL markers separate key receipt from mode application. Offline safety tests and the spelling-variation fixture passed. **Actual item rendering, native writer and rollback after writes remain unverified; production readiness unchanged.**

### Opacity-02: split/full и rollback подтверждены; active-menu gate ещё открыт

Сессия 2026-10-27 20:31–20:33 МСК. Source `4445482eaed5ddc4f67d21509c00c61930f561fe`, installed/frozen Lua SHA256 `aeaf1caf747c08358d70fbd93b93bc3b03064590322361a60f80e1469f3c0a2a`; SHA256 полного локального log snapshot `76ff9e5dfa3daa43b0ce2f5b05113372f1b03cbf879bfdddd9ed249fa375fcc3`. Deployment и source совпали, production CombatHUD не загружался: он был отключён только временным loader list, при сохранённых Lua bytes. Второй writer по тем же свойствам не включался.

**Live items PASS:** QuickItem0/1/2 имеют SlotIndex=0/1/2, один и тот же QuickItem_Panel parent address и текущий HUDUseItemUMG_BP owner. У каждого под своим MainPanel ровно четыре Image (`BG_Image`, `Icon_Image`, `ValueBg_Image`, `Key_Image`) и один TextBlock (`Value_Text`). Все 12 внутренних reflected field/address сопоставлений дали matches_child=true. В частности, поле `slot.Bg_Image` указывает на объект с display FName `BG_Image`: это конкретно воспроизводит ошибочность прежнего name-key сравнения; первая попытка не логировала эти имена, поэтому её исторический failing alias отдельно не снят.

READY: 17 целей и 18 item/part records. QuickItem_Panel, CrystalList_Panel и HUDCrystalUMG_Pad_BP — три siblings под item CanvasPanel_0. CrystalList — HorizontalBox с четырьмя KBCrystalSlot0..3; альтернативный pad crystal widget совпал по reflected identity. Каждый слот целиком наследует QuickItem_Panel; отдельные внутренние icon/count/key/frame opacity не перезаписывались.

Важное ограничение: CrystalList_Panel уже имел native original RenderOpacity=0.0 и Visibility=2 при bind. Поэтому в этой сессии его split/full target был 0.0 в обоих режимах; это сохранение нативного скрытия, а не доказательство видимого keyboard F1/F2/F3 panel на alpha 0.20. Alternative HUDCrystalUMG_Pad_BP был 1.0/Visibility3 и получал 0.20/1.0. Native hidden content у пустых/неактивных слотов также не включался принудительно. Нельзя переносить этот результат на все input layouts без соответствующего наблюдения.

20:32:49.679 Ctrl+F8 применил split: восемь HP-слоёв и QuickItem_Panel=1.0; прочие status targets и обе правые панели=0.20; pad crystals=0.20; скрытый keyboard crystal list остался 0.0. 20:32:57.429 Ctrl+F9 вернул original values. Итого две MODE записи, 34 WRITE записи; постоянной повторной записи по Tick нет. Монитор выполнил 2839 отдельных сравнений target alpha, conflicts=0; NATIVE_WRITE и REJECT отсутствуют. Это доказывает сохранение записей в наблюдённом коротком интервале, не отсутствие всех transient/native writers между 50-мс samples и не другие состояния.

20:32:58.529 Ctrl+F10: ROLLBACK restored=17, expired=0, native_changed=0, failures=0; STOP cleanup=true. После STOP ни MODE, ни WRITE больше нет, дальнейшие Ctrl+F8/F9 по контракту inert. Stop был после full-mode: runtime readback возврата к original подтверждён, но непосредственный split→cleanup этим порядком не упражнялся (проверен offline).

**Пользовательская визуальная оценка:** «Выглядело всё прям как ожидалось, как и должно быть» в ответ на вопрос о ярких HP/трёх предметах со всеми составляющими, приглушённых остальных группах и мерцании. Это положительное наблюдение в проверенном layout, без отдельного FPS measurement. Пользователь уточнил: меню открывал уже после Ctrl+F10. Поэтому native menu hiding **при активном split не проверено**; NATIVE_CONTEXT до STOP также не содержит изменившихся ancestor opacity/Visibility, которые могли бы доказывать такой тест.

**Closed-game cleanup PASS:** после пользовательского выхода процесс отсутствовал; отдельный эксперимент удалён; mods.txt восстановлен побайтно, SHA256 `f2767ae132bcef02016de1c019c43b71d5d79121429ea27a71d7986de9276adf`; все pre-install hashes CombatHUD и SoulsEnemyHUD совпали. Production Lua/VERSION не менялись. До следующей установки снова активна принятая конфигурация CombatHUD.

Для закрытия оставшегося узкого gate достаточно повторно использовать **те же замороженные байты opacity-02**, без нового кода: Ctrl+F8 → доступные меню при активном split → Ctrl+F10 напрямую из split → закрыть игру. Это проверяет native ancestors в меню и runtime restore непосредственно после dim, не повторяет HP или весь split/full тест. Общая production readiness пока PARTIAL/BLOCKED этими границами и будущей проверкой автоматической policy.

### Финальный active-menu/direct-split-cleanup сценарий: PASS

Сессия 2026-10-27 22:30 МСК, те же неизменённые байты opacity-02: source `4445482eaed5ddc4f67d21509c00c61930f561fe`, SHA256 Lua `aeaf1caf747c08358d70fbd93b93bc3b03064590322361a60f80e1469f3c0a2a`. Повторный запуск потребовался только потому, что ранее меню открывались после остановки observer; новый controller/версия не создавались. SHA256 финального полного raw log snapshot `877bf17e6ae64554ee0f19e802f9432d557441201783a176b3600f1f2fc318a2`; лог, manifests и frozen installed source сохранены локально в ignored evidence вне loader paths.

- 22:30:35 READY: 17 целей, 18 item/part records, generation1.
- 22:30:37.544 Ctrl+F8 установил split и выполнил 17 one-time opacity writes с readback. Ни full-mode, ни повторных mode writes до cleanup в этой сессии нет.
- При активном split untouched `HUD_Panel` в 22:30:39.494 получил native alpha0.5, затем 22:30:40.177 вернулся к1.0. В 22:30:40.850 его raw Visibility сменился с3 на2, в 22:30:48.230 вернулся к3. Остальные наблюдаемые ancestor alpha оставались1.0. Таким образом меню действительно меняли native общего предка, пока split был активен; эксперимент не принуждал этого предка к1/visible. Имена конкретных экранов из raw ancestor значений не выводятся.
- Пользователь явно подтвердил: после Ctrl+F8 открыл/закрыл меню, HUD скрывался и возвращался нормально; затем Ctrl+F10 и закрытие игры. Конкретные названия меню не перечислены, поэтому приёмка ограничена проверенными доступными экранами, не всеми меню/диалогами/кат-сценами игры.
- 22:30:56.130 Ctrl+F10 непосредственно из split: ROLLBACK restored17, expired0, native_changed0, failures0; STOP cleanup=true, checks5848, conflicts0. NATIVE_WRITE/REJECT/RESTORE_ERROR/RESTORE_SKIPPED отсутствуют. Все значения после write/restore прочитаны обратно. Монитор работал примерно18.6с между split и stop; это sampled evidence, не глобальное доказательство отсутствия transient writes между callbacks.
- 22:30:58.919 `Event loop end` после пользовательского выхода. После stop observer и key handlers inert; новый запуск нужен только для нового эксперимента, не для cleanup текущего.

Closed-game cleanup подтверждён: process count0; installed source hash совпал; отдельный CombatHUDOpacityExperiment удалён (только известные marker/main.lua и опустевшие каталоги). Временный mods.txt перед восстановлением совпал с deployment SHA256 `4a760bd8bdd1d2ef8eeecbe76020f2ae9492d311f77a28bb02df238f8256d13d`; оригинальный список восстановлен побайтно, SHA256 `f2767ae132bcef02016de1c019c43b71d5d79121429ea27a71d7986de9276adf`. Все pre-install hashes CombatHUD и SoulsEnemyHUD совпали. Принятый CombatHUD снова включён в loader list. Не утверждается новый runtime-запуск принятого мода после cleanup: возврат установки доказан bytes/config, запускать игру автоматически запрещено.

**Итог механизма:** HP восемь layers + весь QuickItem_Panel можно сохранять без дополнительного приглушения, отдельно задавая alpha остальным status children, active crystal sibling и двум правым skill widgets. Иконки/количество/клавиши/фон остаются внутри native item slot, без записи их Visibility и brushes. Применённый метод не переопределяет LeftBottom_Panel, status/item roots, HUD_Panel и глобальное скрытие. Runtime и пользовательская оценка подтверждают эту схему в наблюдённой среде. Нативное изменение target-alpha не обнаружено, native ancestor writer явно наблюдался и сохранялся.

**Оставшиеся границы для production:** keyboard CrystalList_Panel в обеих визуальных сессиях original alpha0, Visibility2; alternative HUDCrystalUMG_Pad_BP был активен и приглушался до0.20. Поэтому не захватывать нулевую alpha неактивной ветки как универсальную постоянную production baseline и не объявлять проверенными visible keyboard layout, переключение input mode или writer этих переходов. Не включать скрытую ветку принудительно ради теста. Если production остаётся зависим от неё, требуется отдельно подтвердить соответствующий native boundary на реально видимом layout либо обосновать более узкий target. Кроме того, ручной visual projection не проверяет автоматическую реакцию на damage, HP-full hold, battle smoothstep, respawn/HUD replacement и паузу новой policy. Это gate последующего изменения, не разрешение реализовать его в этом исследовательском шаге. Production Lua и VERSION остались без изменений, main AsterigosMods не обновлялся.

## Контекстные игровые действия и skill targets — статический этап, 2026-10-29

Scope: самостоятельный CombatHUD, `feature/contextual-hud-reveal`, исходная опубликованная база `7f6e0502d03df309fb5357ead469510a4b6fd7df`. Steam 1.09/build12996889 / UE4.27 / UE4SS 83330635. Прочитаны актуальные DevRules `0f4888bb9501afa42e3b9492c5794c98bf58537f` и Asterigos-Research `bea384a6ba5cfb6ca19f50ac29987107538bb107`, в частности R-005/R-006/R-008/R-010. Это исследование; Scripts/ и VERSION 0.2.0 не менялись. Установленные production SHA-256 совпали с записью принятого кандидата; опубликованный архив не менялся.

### Что доказано статически

| Вопрос | Установленный контракт | Что ещё не доказано |
| --- | --- | --- |
| Семантика взаимодействия | `EGenesisInputCommandType::Interact` = 25; это отдельная команда от UI_Enter. `EGenesisInputEventType` задаёт Pressed=0/Released=1. | Реальная доставка события без доступного объекта, в меню и после remapping. |
| Привязки | `/Game/MainContent/Tables/DefaultInputMapping` и `DefaultInputMappingTypeB`, RowStruct `FInputMappingData`: ContextType, Command, Input(FKey), IsModifier, AllowExecuteWhenPaused и флаги сочетаний. Для Interact — Scene, AllowExecuteWhenPaused=false. | Это defaults, не текущий пользовательский mapping. Физический файл/владелец хранения настроек не установлен. |
| Сохранённое представление и remapping | Native `FSavedInputMappingData` содержит TableRowName, Command, ContextType, Input и modifier-флаги. `GenesisPlayerController:ConfigureAndApply(TArray<FName>,TArray<FKey>)` — объявленная точка изменения; `GameGlobal:GetInputMapping(ContextType, outCommands, outButtons, outFKeys)` и `GetInputRemappingData(...)` — объявленные readers. | Тело native mapping manager и round-trip сохранения не исследованы; setter не вызывался. Массивные getters ещё не вызываются probe из-за отдельной ABI/array границы. |
| Модификатор навыков | `SpecialSkill_Switch` = 14, IsModifier=true в обеих default-таблицах. У `GenesisPlayerController` объявлен zero-input bool `GetModifier_SpecialSkill()`. | Getter не был вызван в этой задаче. Сброс на UI, focus loss и смену устройства неизвестен. Для keyboard в этих defaults отдельной SpecialSkill_Switch строки не обнаружено; нельзя обещать несуществующее удержание на этом layout. |
| Action edge seam | `GenesisPlayerController:NotifyActionInput(Command,EventType)` объявлен BlueprintImplementableEvent; `onActionInputEvent` — dynamic multicast с двумя enum. Native `OnActionInputPressed/Released(Target:ActionInputMappingListener*)` — callable callbacks. | У выгруженного `MainPlayerController_BP` нет override NotifyActionInput. Декларация не доказывает пригодность RegisterHook или фактический dispatch. У отражённого listener не видны command/key fields; один Target pointer ещё не идентифицирует действие. |
| Gameplay/UI gate | `GameGlobal:GetInputMode(bool getAction,bool getAxis)` возвращает `EGenesisInputContextType` (Scene=0, UI=1, QuestTimeEvent=2). Есть `GetNowInputControllerType()` и controller-connection event. | Сам GetInputMode не является доказательством фокуса окна или видимого gameplay. Сочетание с owning GenesisCharacter, HUD viewport и native menu visibility требует live проверки. |

Default-таблицы показывают, почему нельзя кодировать физическую кнопку: Interact в preset A использует нижнюю face button, в B — правую; SpecialSkill_Switch в обеих — верхнюю. Это примеры shipped defaults, не текущий пресет пользователя. Принятая концепция по-прежнему опирается на действия.

У существующего Blueprint `MainPlayerController_BP:NotifyCoherentHudInput` найдены input-параметры `cmd:FString`/`IsPressed:bool`; stub 36 вызывает ubergraph entry814. В ubergraph ветви913/927/979 направляют строку в `GTGameHUDBPLocal:UI_Input` / `UI_InputReleased`. Это подтверждает маршрут Coherent/UI, а не универсальный gameplay Interact. Не выбирать его молчаливой заменой action-source. Ни один callback этой задачи ещё не наблюдался в игре.

### Skill panel: установленные assets и границы независимой opacity

- `HUDMainUMG_BP` владеет отдельными `HUDSkillUMG_BP` и `HUDActiveSkillUMG_BP`; это уже две правые цели принятого CombatHUD 0.2.0. Общий `HUD_Panel`/menu ancestors нельзя принуждать к яркости или visible.
- `/Game/MainContent/Template/UMG/HUD/HUDSkillUMG_BP`: `SkillSlotList_Panel` имеет четыре `HUDSkillSlotUMG_KeyBoard_BP_C` (`SkillSlotIKB0..3`). В том же root есть SPBar, SpellOrb0..2, линии и числовые значения. Поэтому root означает всю функциональную SP/skill группу, не только четыре иконки. UpdateSkillSlotList использует `GetIconByInputCommand` для SpecialSkill_1..4 (19..22), а не фиксированные Z/X/C/V glyphs.
- `HUDActiveSkillUMG_BP`: `CanvasPanel_0 → Main_Panel`, внутри четыре `HUDSkillSlotUMG_Pad_BP_C` (`SkillSlot0..3`) и `baseBg_Image`, `Key_Image`. Шесть детей не равны шести skill-иконкам. Соответствие пользовательскому описанию шести иконок **OPEN**; не переименовывать картинки в навыки и не считать весь gamepad layout проверенным по asset names.
- Минимальные **кандидатные** targets — две уже используемые правые root-группы; не расширять до общего HUD, HP, предметов или чаровитов. При будущем независимом управлении учитывать текущую parent opacity, native visibility, активный layout и native animations/child writers. Чтение структуры не доказывает отсутствие конфликтов в ещё не наблюдённых состояниях. Эта задача не выполняет opacity writes.

### Выбор механизма и готовность реализации

Самый узкий предпочтительный путь: реально доставляемое семантическое Interact Pressed + проверенный native held getter/edge SpecialSkill_Switch, с Scene/owner/viewport/native-menu gate. События взаимодействия не должны потребляться/подавляться; возвращать из наблюдателей nil, не менять параметры. Нативное выполнение сохраняется. Если semantic callback не доставляется, альтернативу с runtime-resolved mapping/FKey можно рассматривать только после отдельного ABI/mapping proof, а не заменять её hardcoded keys.

При потере controller/pawn/HUD, выходе из Scene и смене input state будущая policy должна сбрасывать свой latch и не ждать потерянного Released. Одного elapsed timeout нельзя выдавать за настоящее отпускание. После возврата допустимая resync с native held требует проверки, что getter сам не застревает при отпускании вне окна. Сейчас это исследовательские критерии к уже принятому требованию, а не реализованная policy.

- **Interact — OPEN:** декларации/action mapping установлены; фактический observer, empty-space press, remapping и menu isolation ещё не проверены.
- **Skill modifier — OPEN:** semantic identity/default flag и getter объявлены; held/release/device/focus semantics требуют live evidence.
- **Skill targets — OPEN:** статическая topology установлена; обе правые root-группы известны по прежнему CombatHUD, но соответствие текущему gamepad виду и независимая skill-only граница в новых состояниях ещё не доказаны.
- **READY только для ограниченного read-only observer.** Ни один из этих OPEN не означает доказанную невозможность (BLOCKED) или разрешение production-реализации. Чаровиты остаются за границей исследования.

### Подготовленная приватная диагностика и следующий достаточный тест

В ignored local evidence подготовлен `contextual-input-observer-01`, Lua SHA-256 `7263446d88adc42e55ea2b834681cda0949d2fabae7ed6fac7418a91e9e0e2b2`, base source `7f6e0502d03df309fb5357ead469510a4b6fd7df`. Исходники диагностик, дампы и машинные пути не опубликованы. Lupa Lua54 offline PASS: parse, audit отсутствия setter/input mutation, nil callback returns, enum/wrapper handling, журналирование изменённых state, time bound и malformed argument containment. Это проверка безопасности собственного observer, не engine/ABI proof.

Observer пробует только указанные три action seams, читает native modifier, input mode и input-device state через game-thread dispatcher с периодом100мс; discovery ограничен разом в секунду, 5 минут/240 строк. Callback phase отмечается явно: native-pre или script-post; события и getters нельзя автоматически считать одновременным snapshot. Невозможная регистрация фиксируется HOOK_UNAVAILABLE, отсутствие callback не подменяется physical key hook. Он только читает две skill roots, их детей и HUD_Panel; не изменяет opacity/Visibility, bindings, gameplay или save. Ошибка делает observer inert.

**Установка observer01 — историческая запись; после прогона он снят (см. результат ниже).** После явного разрешения пользователя отдельный CombatHUDContextProbe установлен при закрытой игре; installed Lua SHA-256 `7263446d88adc42e55ea2b834681cda0949d2fabae7ed6fac7418a91e9e0e2b2` совпал с подготовленным. Добавлены только Scripts/main.lua и enabled.txt отдельного observer; mods.txt и все20 существовавших loader-файлов сохранили хеши. Принятая 0.2.0 дополнительно сохранена вне loader paths, pre-test UE4SS.log скопирован в ignored evidence. Игра не запускалась и не завершалась, hot reload не использовался. Точная установка и baseline hashes находятся в приватном deployment.json. Это доказательство установки, не успешного исполнения hook/getters. После пользовательского прогона сохранить новый лог и убрать только этот observer при закрытом host.

После разрешённой установки нужен один короткий прогон в пределах5минут: несколько нажатий текущего действия взаимодействия в пустом месте; текущее удержание/отпускание выбора навыков; открыть/закрыть обычное меню и нажать подтверждение; сменить keyboard/gamepad и повторить доступные действия; один раз, удерживая модификатор, уйти из окна, отпустить его вне игры и вернуться. Не переназначать управление/не менять настройки ради теста. Попросить пользователя сопоставить видимую панель с описанием шести иконок. Затем штатно закрыть игру. Из нового лога проверить HOOK/edge delivery и соответствие nativeHeld/context/device/tree; сохранить snapshot, убрать только отдельный observer при закрытом host и сверить baseline hashes. Если семантическая точка не доставляется, это конкретный input gate, а не доказательство невозможности функции.

### Точная воспроизводимая evidence identity (raw остаётся локально)

CUE4Parse1.2.2 reader с GAME_UE4_27/ReadScriptData=true повторно извлёк только MainPlayerController_BP из установленного baseline. Остальные mapping/skill exports и UHT декларации переиспользованы из существующего исследования, без нового dump или запуска игры.

| Evidence | SHA-256 |
| --- | --- |
| MainPlayerController_BP.json | `46e49c1a1d0f08e5c7566beae2e4381b27d72f805b1c9d91eff9ab39d4678a1b` |
| MainPlayerController_BP--NotifyCoherentHudInput.bytecode.json | `707249c92b46d82fef46af30b5ecfa19f2da4ada2d17cb64dda7361d46414f42` |
| GenesisPlayerController.h (UHT) | `c675fcf6c6014cf838bc95c50f957f1d34f9fa03e5d74ee01f9df5d2a2552cf8` |
| GameGlobal.h (UHT) | `a6d1b5c0828e0bcc188f05fa8e29e5e58d618c08731d4bc9fd0ba8b3c4925023` |
| InputMappingData.h (UHT) | `7efca2bf957caac5fe3457aa6febbb317edd69c7cd92569a0ec263ae4d456477` |
| SavedInputMappingData.h (UHT) | `15b7b9715f3c02db48b632fb935a7bc69582b4c1da5021daa4ef6868521cf08d` |
| EGenesisInputCommandType.h (UHT) | `3e3db1836371060534d9d884bde1d2b9b50c74fd340e1fb807c4c247e5f11a94` |
| EGenesisInputContextType.h (UHT) | `988a5fb10ea8224bda3157ca179112b148f518336679e578bb94167c5c77e3bd` |
| DefaultInputMapping.json | `d6cc2a26d8a6337a43c44e3016b98c4417135ca3bbd835b5b86de8f7976bb9f1` |
| DefaultInputMappingTypeB.json | `2c9a64b39ff77ac7b1e884863d09a9a1c506cb4b1f31a9223d52fde3d64a069b` |
| HUDSkillUMG_BP.json | `becafbaadd2a9ac9c4c868188f3237f58277370d5ecea88cd777a772b0a01ab6` |
| HUDActiveSkillUMG_BP.json | `5353be9c22f3a5a23cb5dd45012a74d5c00d627efe034a5cef2de421e1a1ee3f` |


Переиспользуемые статические контракты и отрицательные границы промотированы в [Asterigos-Research/main, commit 85263998dfd751e6351d03366fc66f99ecd7c6f8](https://github.com/NikichMods/Asterigos-Research/commit/85263998dfd751e6351d03366fc66f99ecd7c6f8), раздел R-014 и RESEARCH_INDEX. Runtime-доказательства туда не добавлялись.

## Context observer01 — stopped before gameplay; observer02 installed (2026-10-29)

**Result: partial startup evidence only; Interact/held/gameplay target gates remain OPEN.** User completed the requested scenario and closed the game. The captured UE4SS session spans 02:35:40–02:37:31 MSK, SHA-256 `2e0c91a27b6f0eee98833c80443d05741cc58dd0024dbad07e3c9f8fa75e791f`; installed observer01 matched frozen Lua `7263446d88adc42e55ea2b834681cda0949d2fabae7ed6fac7418a91e9e0e2b2`.

- All three hooks registered (semantic-action, pressed, released). Registration is not invocation proof. Two released listener callbacks ran at 02:35:49 with valid controller/listener addresses; no semantic ACTION, pressed edge or WIDGET records are present. After STOP no observer callbacks are recorded by design, so absence cannot establish that gameplay input is unavailable.
- Native polling succeeded during startup: GetInputMode yielded Scene0 then UI1, GetModifier_SpecialSkill yielded false, GetNowInputControllerType changed4→1; viewport=false/gameplayPawn=false in the three completed snapshots. This establishes those primitive getter calls on that early controller, not held/release or gameplay/focus/remapping behavior.
- At 02:35:57.397 observer01 stopped on `missing widget HUD_Panel` (main.lua:110), before any completed gameplay-pawn snapshot. The pawn type at that exact failed read was not logged and remains unknown. That assertion says the fetched value did not pass the Widget contract; it does not separately prove nil versus another invalid/non-widget value. Source review establishes two observer defects: the optional widget sampling ran on any viewport before requiring a GenesisCharacter owner, and it assumed the asset name HUD_Panel was a direct Lua field. Previous live opacity experiment02 instead reached that ancestor via `LeftBottom_Panel:GetParent()`; export spelling alone did not justify the new alias.
- At 02:36:08.628, after the observer had already stopped, accepted CombatHUD0.2.0 bound17 targets and validated hilda_BP_C. Its normal full-HP hold→fade→idle transitions completed without CombatHUD fail-safe/restore warnings. The new contextual controls are still not implemented.
- Closed-game cleanup removed only observer01 main.lua/empty enabled.txt and its empty directories, after checking its exact hash. CombatHUD0.2.0 and mods.txt matched the pre-test hashes. One unrelated ImmersiveInteractionPromptsViewportProbe marker was absent compared with the old snapshot; it was not restored or changed by this task, and its cause is not attributed. The other pre-existing files matched; raw comparison stays private. No automatic game launch/termination or hot reload.

**Corrected observer02:** local Lua SHA-256 `284e0f56039593061f0262f13ed100a11ef07dfe3bca047e09c0b73958c7c54d`. It defers widget reads until a GenesisCharacter-owned viewport HUD, uses the previously verified left-parent route and makes the optional widget lane independent of action observation. Unknown/missing targets emit WIDGET_UNAVAILABLE rather than disabling input; there is no guessed fallback target and still no opacity/visibility/input/save writes. Native menu-parent opacity and both skill roots are sampled only in the valid gameplay-owner lane; context/held/device sampling continues separately.

Offline Lua54 safety tests PASS. A regression fixture now covers the observed startup viewport/non-character state, later missing optional widgets and continuing nil-return action observation. This repairs the diagnostic, not production, and does not establish a successful live panel lookup or semantic hook invocation.

Under the user's standing authorization for the separate read-only probe, observer02 was installed at closed-game state. Its installed SHA-256 matched; all19 pre-existing loader files in the new snapshot retained their hashes. Both accepted CombatHUD0.2.0 files are unchanged. Source/dumps/logs remain private; observer01 evidence is preserved. That installation is historical: observer02 has now completed its run and been removed; the result and capture limit are recorded below. Its START marker must identify observer=02; registration, gameplay snapshots and actual ACTION/EDGE/WIDGET delivery must be evaluated independently. After that run snapshot the new log, remove only observer02 with the game closed and verify baseline hashes again. No new mod version, candidate or release is created.

## Observer02 result — live held getter and skill binding; Interact OPEN (2026-10-29)

**Bounded research result, no production implementation.** User reports completing the scenario and closing the game. User clarified that their current gamepad world Interact is **Y**, menu confirmation is **A**, and a real interaction used the respawn/rest point. These are user-reported current bindings/context examples, not constants to encode and not timestamped action identities supplied by this log. World interaction and menu confirmation must remain separate semantic commands even when other presets might reuse a physical button.

Identity: private observer02 Lua SHA-256 `284e0f56039593061f0262f13ed100a11ef07dfe3bca047e09c0b73958c7c54d` matched installed bytes. Preserved UE4SS session 02:46:49–02:48:42 MSK, log SHA-256 `03cfc94085f8422018181f0b7cd5bcbbbb941fdf7eb20d6e55a441258455e0aa`. It contains exactly240 observer lines: HOOK3, START1, STATE40, EDGE181, WIDGET13, CHILDREN2, ACTION0. No WIDGET_UNAVAILABLE, exception STOP or CombatHUD fail-safe is recorded.

### What this run proves

- The corrected observer reached a GenesisCharacter-owned viewport HUD at 02:47:39.318. Controller identity changed on loading; discovery reacquired the controller/HUD. The previous direct-HUD_Panel assertion was not used.
- On device4 (Xbox controller enum), `GetModifier_SpecialSkill()` changed false→true at 02:47:47.334 and true→false at 02:47:50.076, then true at 02:47:50.892 and false at 02:47:52.726. Further shorter true/false intervals are logged. This is live native held-state evidence on the user's current preset, consistent with their performed hold/release scenario. The observer does not hardcode the physical modifier button. Exact physical key names and a before/after remapping round-trip were not read or tested.
- Both owned roots were read live: HUDSkillUMG_BP_C and HUDActiveSkillUMG_BP_C, sharing the same CanvasPanel parent obtained via LeftBottom_Panel:GetParent(). Keyboard SkillSlotList_Panel has four HUDSkillSlotUMG_KeyBoard_BP_C children. Pad Main_Panel has SkillSlot0..3 of HUDSkillSlotUMG_Pad_BP_C plus baseBg_Image and Key_Image. At the initial tree snapshot, baseBg_Image alpha0/Visibility0 and Key_Image alpha1/Visibility2 were native values; no child was forced visible. Six children still do not establish six visible skill icons. The snapshot was taken with device1 before changing to device4, so it is not a second active-pad-layout tree capture.
- At 02:47:57.001 input mode is UI1 and the common native ancestor Visibility becomes2 (Hidden); both skill roots retain alpha0.20/Visibility4. At 02:48:01.460 Scene0 and ancestor Visibility3 return. These are direct observations of native ancestor hiding with the accepted CombatHUD active; they are not new independent-opacity writes. The modifier was already false before menu entry, so this does **not** prove clearing a held modifier on entering menus.
- Device1↔4 transitions are observed, including gameplay switch to keyboard at 02:48:06.844 with nativeHeld=false. No held-through-device-change or focus-loss reset is established by that alone.

### What remains open and why

- `NotifyActionInput` registered but produced **zero ACTION callbacks** in the recorded active interval. Native OnActionInputPressed/Released ran and emitted181 EDGE records; many arrive in closely spaced listener groups. A listener address has no proven command field. They cannot be relabelled Interact, modifier, Y or A from timing alone, and the edge count is not a count of user actions. The tested semantic hook is not yet a usable proven Interact source; this does not prove that observing Interact is impossible.
- `emit` reaches a shared240-line budget and sets the observer inert on its next attempted record. The final observer line is at02:48:09.527, while the host exits at02:48:42.878. No terminal budget marker is emitted by this implementation. Source plus exact line count establishes truncation by the observer's budget, not a host crash or five-minute timeout. Treat the interval after the last record as unobserved; focus/window activity was not independently marked or measured. A later diagnostic must reserve independent budgets for action summaries/state and explicitly record why capture ended, rather than disabling all lanes on repetitive raw edges.
- User's respawn-point interaction and menu A confirmation are valid reported scenarios, but cannot be associated with named ACTION records because none were delivered. The lack of a world Interact record is not evidence that the user pressed the wrong button. No new request to change key bindings or saves follows from this result.

### Engineering readiness after this run

| Boundary | Status | Meaning |
| --- | --- | --- |
| Modifier getter ABI/basic held read on current controller preset | READY for using this getter as a demonstrated read contract | Normal live true/false and scalar return established; no physical-button dependency in observation. |
| Complete modifier behavior | OPEN | Held-through-menu/device change and lost-release/focus resync remain unverified. This run does not authorize production changes. |
| Right-root and slot bindings, native ancestor route | READY for the observed hierarchy | Root identity, parent sharing and4+4 skill slots established live; common parent remains native. |
| Final functional skill-only group / six visible icons / alternate layout ownership | OPEN | Do not equate two Image children with extra skills or promise active-layout rendering from the initial tree. |
| Remappable Interact observer, including empty-space press and menu isolation | OPEN | No delivered semantic callback; listener pointers are insufficient. The next input mechanism needs its own evidence. |

Recommended narrow continuation, **not executed here**: retain the demonstrated native modifier getter and investigate whether `GameGlobal:GetInputMapping(Scene,...)` exposes the complete current semantic Interact binding safely. If it does, a native key-state query driven by that current mapping may satisfy remapping without fixed keys; if not, another native dispatch seam is needed. Array/FKey marshalling and chord/context semantics must be established before choosing that path. Repeating the same generic scenario cannot by itself fix a hook that emits no semantic action. No production implementation, version bump, new numbered candidate or release is part of this result; crystals remain deferred.

### Closed-game cleanup and stop state

Observer02 was removed after matching its installed hash and checking process count0. Only its known main.lua/empty enabled.txt and empty directories were removed. All19 pre-existing loader files match the observer02 deployment snapshot, including mods.txt and both CombatHUD0.2.0 Lua files. The log, immutable observer sources and private result remain in ignored evidence. No new probe is installed, no game was launched/terminated by the agent and no hot reload was used. That bounded stage ended at the readiness assessment above. The user subsequently authorized the narrow current-Interact-binding continuation recorded below.

## Current Interact binding — scalar resolver investigation, 2026-10-29

**Historical preparation-stage status (superseded by the Observer03 result below): static read contract selected; current-value and action-delivery proof was OPEN.** The user authorized continuing only the narrow Interact/remapping investigation. Production Scripts/, VERSION0.2.0, settings and saved mappings are unchanged. Previous observers are preserved privately and removed from the loader.

### New static evidence and mechanism choice

A bounded primary-source lookup and exact installed-version review were performed before choosing another probe. Relevant upstream references are [UE4SS LuaUObject.cpp at8333063595fa3c49ad307f3b0f732accbb760d25](https://github.com/UE4SS-RE/RE-UE4SS/blob/8333063595fa3c49ad307f3b0f732accbb760d25/UE4SS/src/LuaType/LuaUObject.cpp) and [UE4.27 WasInputKeyJustPressed](https://dev.epicgames.com/documentation/en-us/unreal-engine/API/Runtime/Engine/GameFramework/APlayerController/WasInputKeyJustPressed?application_version=4.27). Current UE4SS docs/issues are precedent only; the83330635 source and local UHT declarations govern this baseline.

- `GameGlobal:GetInputMapping(ContextType, outCommands, outButtons, outFKeys)` is a reflected candidate, but it adds three out arrays. The pinned call wrapper fills Lua out tables via GetNonTrivialLocal, while array elements are pushed with GetParam; this can leave wrappers pointing at native storage. An outer Lua table is not proof that its elements are deep-owned. The same source supports a simpler scalar path, so no array mapping getter was invoked and no unsafe TArray indexing is introduced.
- `GameGlobal:GetKeyByVirtualKey(FName VirtualKeyName) -> FKey` is declared separately from GetDefaultInputKeyOfVirtualKey. Scalar StructProperty return conversion recursively builds a Lua table; its NameProperty is a local value-copy FName. The probe retains only that owned name inside a plain `{KeyName=...}` argument table, with no native FKey/array wrapper cache. A returned value must match the expected shape or observation stops; no default physical button is substituted. Whether the resolver returns the current stored binding and whether the reconstructed FKey suffices for actual native key getters still require live proof.
- Native `FKeyBindingData` links Key, VirtualKey, ControllerType, GroupType, conflict list, ActionName and CanNotModify. Reused reader1.2.2 exports of the five KeyBinding tables establish these exact Interact virtual IDs: `K-Interact`, `PC-Joystick-Interact`, `DS4-Interact`, `DS5-Interact`, `X-Interact`. Each belongs to Game/Game_Normal, is modifiable and points to the UI action localization key `SystemOption.Controller.Interact`. These are semantic configuration IDs, not fixed physical keys. They match Scene/Interact rows of the already inspected default input tables.
- The PC device namespace must not be guessed: EGenesisInputControllerType and EKeyBindingControllerType are different enums, and a PC Xbox-style device does not by itself prove that X-Interact rather than PC-Joystick-Interact is active. The probe resolves all five declared virtual IDs and logs device, input-platform and default-preset metadata. It records candidates without silently choosing an active one.
- WasInputKeyJustPressed is a current-frame up→down query. A50/100ms timer cannot establish reliable coverage of that flag. This experiment queries both native IsInputKeyDown and WasInputKeyJustPressed in the already demonstrated OnActionInputPressed **native post-hook**, retaining pre/post input contexts. The callback is a wake-up seam, not itself an identified Interact command. Correct native timing, candidate selection, same-frame deduplication, chords and full action equivalence remain part of the evidence gate. A native getter that only reports held is not automatically a reliable press event.

The exported table named Remapping proved to contain skill/projectile/attribute/VFX remapping rather than input binding; it is not used for this mechanism. No broader gameplay investigation followed.

### Private observer03 and bounded runtime question

Prepared private `interact-scalar-resolver-03`, Lua SHA-256 `14b4ef7d998312166857b1d78affafbab7c9331c5b11408322bd9411cd03db05`. No diagnostic source or raw export is published. Offline Lua54 safety/regression checks PASS: startup owner deferral, owned key shape, runtime-resolved key arguments, native pre/post modes, nil-return callbacks, listener fan-out deduplication, independent sample cap, explicit STOP marker and malformed resolver result containment. These mocks are not native ABI/current-binding proof.

The observer uses no HUD writes and no input/configuration setter. It waits for GenesisCharacter-owned gameplay HUD, calls only the scalar resolver for the five proven virtual IDs, logs BEFORE_KEY/RESOLVED and first key-query before/after markers, and records native key flags from actual pressed callbacks. It refreshes on controller/device/preset or UI→Scene changes, with at most six resolver generations. It does not hook the undelivered NotifyActionInput again. Repetitive raw edges are counted rather than printed. Key-sample log limit64 does not disable context/resolver observation; STATE and key-sample budgets are separate. There are explicit counters/STOP markers, a180-second-after-ready observation bound and600-second absolute startup bound.

After the existing authorization for a separate read-only research probe, observer03 was installed with process count0. Installed hash matched; all19 pre-existing loader files, mods.txt and both accepted CombatHUD0.2.0 files retained their hashes. Game launch/termination and hot reload were not performed. Exact deployment/baseline and source remain in ignored `.local` evidence. That installation is historical: observer03 has now completed the short current-binding test and was removed. The live result, precise readiness boundary and cleanup are recorded below.

Sufficient next scenario: load the normal save, wait a few seconds; press the currently assigned world Interact several times in empty space (user's current Y); if convenient perform one ordinary existing interaction; open a normal menu and confirm with the user's current A; return and exercise the current keyboard Interact once. Do not change bindings/settings for this run. Close the game normally. Compare resolved key names with the user's current preset, default-table differences and native query samples across Scene/UI. If names/namespace or native edge timing are wrong, retain that specific gap rather than accepting a guessed mapping. Then snapshot the log and remove only observer03 with closed-game baseline verification.

### Evidence identity

- Exact fetched upstream LuaUObject.cpp SHA-256 `cccf1e63b26fb5a2f009666cf469f19f8eaa655388be462219f3b22b19ae6a0b`. The older local copy differs only in a trailing blank line; no different implementation was adopted.
- KeyBinding_KeyboardMouse.json SHA-256 `5b91709cf157d0e9adb543a820ea6e12cd2425b069a54ab0bd52d009eac0ef81`.
- KeyBinding_Joystick.json SHA-256 `9991cfb5cd48e4eaffa425853f018674c05413170cf7538c18040aa34f1cd9f9`.
- KeyBinding_XboxController.json SHA-256 `754c6289218503c90d9d7b7116e36bcd17494265323104a875f5932124d59bac`.
- GameGlobal/PlayerController/FKey UHT declarations, the other two controller tables, exact toolchain and all raw sources remain local and are included in the private audit inputs. No game asset, setting/save data, key material or machine path is added to public Git.

**READY only for the bounded resolver experiment; Interact implementation remains OPEN.** No version, candidate or release is created. The already agreed reveal behavior and deferred crystals do not change.

## Observer03 result — current Interact resolver and native key queries PASS (2026-10-29)

**Result: a usable remapping-aware Interact read route is demonstrated on the tested PC preset.** The user completed the short empty-space gamepad/menu-confirm/keyboard scenario and closed the game. No binding/settings changes were requested or made. Installed private observer03 matched Lua SHA-256 `14b4ef7d998312166857b1d78affafbab7c9331c5b11408322bd9411cd03db05`. Preserved session03:15:19–03:16:09 MSK, log SHA-256 `e8445de9325cc20c294454f520040b9e96902ed43e3fdddaa8f493a593862cc0`.

### Actual current binding, not a default-button substitution

| Virtual Interact identity | Runtime GetKeyByVirtualKey result |
| --- | --- |
| K-Interact | F |
| PC-Joystick-Interact | Gamepad_FaceButton_Top (the user's reported Y) |
| DS4-Interact | None |
| DS5-Interact | None |
| X-Interact | None |

All three resolver generations returned the same values: initial ready gameplay; UI→Scene return at03:16:01.702; gamepad→keyboard change at03:16:03.535. Metadata reported platform0(PC), device4 then1, preset0. In particular, device4 does not select X-Interact: that virtual ID returned None while PC-Joystick-Interact returned the actual key. Use the platform/mapping namespace, not an assumed equality between controller enums.

The returned Top key agrees with the user's explicitly reported current Y binding and differs from the Bottom/Right keys in the two inspected shipped PC-Joystick default tables. This supports the resolver reading the configured mapping rather than a hardcoded/default physical key. It does not establish a before/after live remapping round-trip or every platform namespace. None is an inactive/unresolved binding in this observation, not permission to substitute a default key.

### Delivered key-state evidence and gameplay/UI distinction

- Scalar return decoding worked: the FKey return was a plain Lua table with a local-copy KeyName. Passing the derived plain FKey argument to native IsInputKeyDown and WasInputKeyJustPressed succeeded, with before/after markers; no borrowed array/FKey wrappers were retained. The source-reviewed argument route now has live ABI evidence for this baseline.
- At03:15:49.419, the gamepad resolved-key queries returned down=true and edge=true in native OnActionInputPressed post-hook, preMode=0/postMode=0. Seven gamepad-positive KEY_SAMPLE records are present overall. Raw listener fan-out was summarized; sample count is not asserted to equal physical user-press count.
- At03:16:03.952 and03:16:05.335, keyboard F returned down=true/edge=true, also Scene0→Scene0. Combined with the user's empty-space scenario, this demonstrates a source that is not contingent on an available interactable actor or successful interaction execution.
- Recorded menu-associated samples have matches=none, with native contexts0→1,1→1 and1→0. The user's A confirmations were performed as requested; the source did not report a matching current Interact key in those samples. Same-physical-key-in-UI, every menu and all native input-block states were not exercised. The future adapter must gate from the captured press context and preserve native UI hiding, rather than equating a key match with a universally allowed gameplay action.
-22 KEY_SAMPLE records:7 gamepad-positive,2 keyboard-positive,13 none.15 resolver rows across3 generations,7 metadata STATE records and one periodic COUNTS summary. No observer STOP error/TRUNCATED or CombatHUD fail-safe is recorded. The host ends normally at03:16:09.578, after the last key sample03:16:08.819. Unlike observer02, no capture budget ended observation early; the host closed before the planned lifetime bound.

### Recommended mechanism and readiness boundary

Use a validated semantic virtual Interact ID to resolve the actual FKey through GetKeyByVirtualKey, retain only the copied KeyName, and observe native key-edge state from the demonstrated pressed-callback route. Require the current valid local controller/GenesisCharacter HUD and appropriate pre-press Scene/native-UI context. A raw listener Target is only a wake-up, not the Interact identity; IsInputKeyDown alone is held state, not a press trigger. No fixed Y/F/VK/XInput fallback and no need to revive the undelivered NotifyActionInput path or invoke the three-array mapping getter for this tested case.

- **READY — current binding reader and scalar FKey argument ABI** on Steam1.09/build12996889/UE4SS83330635, tested PC gamepad and keyboard preset.
- **READY for a bounded Interact-source implementation** under that contract: actual empty-space native edge queries and the observed Scene/UI separation are available. Production integration still must implement lifecycle/cache invalidation, per-press/same-frame deduplication of listener fan-out and the already agreed reveal policy, with focused offline tests and an exact new runtime candidate. These are implementation/acceptance duties, not proof that new HUD behavior already exists.
- **Explicitly UNVERIFIED:** changing and restoring bindings within one session, chords beyond the tested single-key bindings, other platform/controller namespaces, every input-block/menu/cutscene, focus/lost-release behavior and the complete skill-only feature. Refreshing after UI exit/device change returned stable current values here; it does not prove a changed mapping was refreshed.

No production changes, version bump, numbered candidate, release or further observer are created automatically. This narrow Interact-source investigation stops at the evidence/readiness conclusion; implementation requires the user's next instruction. The separate remaining skill-modifier/focus/layout questions and deferred crystals are unchanged.

### Cleanup and preservation

With process count0 and installed observer hash verified, only observer03's main.lua/empty enabled.txt and empty folders were removed. All19 pre-existing loader files retained their deployment hashes, including mods.txt and both accepted CombatHUD0.2.0 Lua files. Raw log, resolver source and private result are preserved outside the loader. No game launch/termination, input/settings/save changes or hot reload by the agent. **No CombatHUDContextProbe remains installed.**

## Contextual candidate 0.3.0 — integration failure, 2026-10-29

Exact candidate `d442efd05ec33f4a144648c664b8f8a9949dbb14` loaded; all three installed SHA-256 values match. User reports preserved old behavior but neither Interact nor skill-modifier reveal works. Log session03:43:32–03:46:14 MSK (SHA-256 `534b90ce2765548ca278be3d35aca22c68a3ed11860d629bede601795f9f1da2`) records a handled `TrivialObject` call error at main.lua:333: production calls `GetNowInputControllerType` on GameGlobal, while the demonstrated observer02/03 contract calls it on GenesisPlayerController. This precedes binding/hook setup and modifier sampling, leaving automatic HP/combat policy active. Mock GameGlobal incorrectly implements the same getter, explaining why the available offline check missed this owner mismatch.

[Owning candidate report](CANDIDATE-0.3.0.md#игровой-результат--2026-10-29-новые-функции-fail) preserves exact identity, log snapshot, observations, error flow, old-state transitions, warnings and unverified cases. This is a mod adapter defect, not a revocation of the bounded observer evidence or proof of wrong user input. No live rebind/new-menu-isolation success is established. Candidate remains unaccepted and unchanged; further production changes require agreement, a new immutable identity and another runtime test. Stable0.2.0, rollback and deferred crystals remain preserved.

## Contextual candidate 0.3.1 — successful repeat run, 2026-10-29

User reports the exercised0.3.1 works as intended. Exact installed payload matches production commit `1879276371c7495bd971003161383b6c45ff39e4` and all three candidate hashes. UE4SS83330635 session04:09:34–04:21:43 MSK (91099 bytes; SHA-256 `b34576c24d996b54990984b8b127ca1aa28e45fa224d14da0ed3e2e58a911649`) identifies Loaded0.3.1,17 bound targets/owning hilda_BP_C and native OnActionInputPressed hook(8,9). Prior GetNowInputControllerType owner error, contextual observer/binding failures and CombatHUD fail-safe/tracebacks are absent. Baseline combat/damage/partial-HP transitions are logged. Existing ConsoleManagerSingleton/FObjectPtrProperty loader warnings also occur in pretest evidence.

[Owning0.3.1 result](CANDIDATE-0.3.1.md#повторный-игровой-прогон--2026-10-29-успешен) separates user visual confirmation from technical proof: production state logs omit contextual overlay events/final skill opacity. Do not claim independent log proof of each Interact/modifier effect, optional live-rebind/focus-loss completion or healing in this session. Crystals remain deferred. Payload/install unchanged, backups preserved; no main/release permission supplied by this runtime report.


## Stable0.4.0 — accepted and published,2026-10-29

User explicitly accepted the visual game test and authorized main/release while the game was running. Live snapshot SHA-256 `19ed52589932f113374035ae7c9dfe6072bb8f7381f059009d585a78aad39971` confirms loaded0.4.0,17 targets/owning hilda_BP_C, native pressed hook, outside-combat damage at13:13:58.037949, vital fading after6.050s and idle0.2 after7.016s with HP still476.775/680. No CombatHUD errors/fail-safe/input failures in the available prefix. User observations cover the exercised scenario; the prefix contains no shutdown marker and does not prove unlogged later events.

PR#2 merged at `57bfa51e507c44c313f564ab9f8153f6ee765f9c`; `CombatHUD-v0.4.0` tags that integration commit with unchanged production source bytes from `56631469ec8888f41bc82f0d5d02684aa44c0e9b`. [Published original-code ZIP and SHA-256](https://github.com/NikichMods/CombatHUD/releases/tag/CombatHUD-v0.4.0) were downloaded publicly without authentication and matched exactly, including all three runtime hashes. [Owning acceptance/package report](CANDIDATE-0.4.0.md). Historical0.3.1/0.2.0 preserved; deferred crystals/live remap/focus limits remain.
