# Правила вклада

## Вступление
Данный файл - гид по вкладку в наш билд. Он поделен на несколько категорий:
 - [Правила комментирования](#Commenting)
 - [Баг-Репорты|Запросы фич](#Issues).
 - [Запросы на включение изменений](#Pull-requests).
 - [Персонал](Maintainers).

## Commenting
Если вы комментируете pull-request, issue или что-либо еще, то удостоверьтесь, что ваш комментарий относится к теме. Комментарии не должны содержать оскорблений.

## Issues
Раздел Issues предназначен как для багрепортов, так и для запросов фич. Оформлены репорты должны быт в соответствии с [шаблоном](ISSUE_TEMPLATE.md).
Запросы должны быть максимально информативными, а также содержать инструкцию по воспроизведению бага (в случае багрепортов).

## Pull requests
Если вы хотите предложить свою работу для включения в наш билд, то вы можете спокойно открывать Pull-Request. Однако, у нас есть строгие правила относительно работы с кодом, картой и спрайтами, а также правила относительно оформления реквестов.

#### Оформление:
 - Pull request'ы должны, по возможности, менять всего 1 аспект игры за 1 запрос. Не стоит мешать кучу изменений.
 - Хорошо документируйте запросы, при изменениях спрайтов или на карте - прилагайте скрины изменений.
 - В запросах НЕ должно быть сообщений о merge'ах, за исключением случаев, когда необходимо решить конфликты. Для обновления используйте `git rebase` или `git reset`, не `git pull`.
 - Вы не должны выкладывать изменения baystation12.int, коммиты с такими изменениями просто не пройдут CI.

#### Специфика карт
 - Любые изменения в картах должны проходить через mapmerger

#### Специфика кода (не переведено в надежде на то, что кодеры знают английский):
 - Any `type` or `proc` paths **must** use absolute pathing unless the file you are
 working in primarily utilizes relative pathing.
 - Paths must begin with `/`. It should be `/obj/machinery/fancy_robot`,
 not `obj/machinery/fancy_robot`.
 - New bases of datum must begin with `/datum/`. `/datum/arbitrary_datum`,
 not `/arbitrary_datum`.
 - Don't use strings in combination with `text2path()` unless the paths are being
  dynamically created. Variables can contain normal paths just fine.
 - Don't duplicate code. If you have identical code in two places, it should probably
  be a  new proc that they both can use.
 - No magic numbers/strings. If you have a number or text that is important and used in
  your code, make a `#DEFINE` statement with a name that clearly indicates it's use.
 - `if(condition)` must be used over `if (condition)` or any other variation.
  - The same applies for `while` and `for` loops, they must have no space between the
  keyword and condition brackets. `while(condition)`, `for(condition)`
 - If you want to output a message to a player's chat
  (this includes text sent to `world`), use `to_chat(mob/client/world, "message")`.
  Do not use `mob/client/world << "message"`.
 - Do not use one-line control statements (if, else, for, while, etc). The space saved
  is not worth the decreased readability.
 - Control statements comparing a variable to a constant should be formatted `variable`,
  `operator`, `constant`. This means `if(count <= 10)` is preferred over
  `if(10 >= count)`.
 - **Never** use a colon `:` operator to bypass type safety checks, unless you are doing
 something where the tiny performance increase is incredibly noticeable (eg, a loop for
   a huge list). You should properly typecast everything and use the period `.`
   operator.
 - Use early returns, and avoid far-indented if blocks. This means that you should not
  do this:
  ```
  /datum/datum1/proc/proc1()
    if (thing1)
        if (!thing2)
            if (thing3 == 30)
                do stuff
  ```
  Instead, you should do this:
  ```
  /datum/datum1/proc/proc1()
    if (!thing1)
        return
    if (thing2)
        return
    if (thing3 != 30)
        return
    do stuff
  ```
 - The following examples of code are present in the code, but are no longer acceptable:
  - To display messages to all mobs that can view `src`, you should use
  `visible_message()`.
     - Bad:
     ```
     for (var/mob/M in viewers(src))
             M.show_message("<span class='warning'>Arbitrary text</span>")
     ```
     - Good:
     ```
     visible_message("<span class='warning'>Arbitrary text</span>")
     ```
  - You should not use color macros (`\red, \blue, \green, \black`) to color text,
  instead, you should use span classes. `<span class='warning'>red text</span>`,
  `<span class='notice'>blue text</span>`.
    - Bad:
    ```
    usr << "\red Red Text \black black text"
    ```
    - Good:
    ```
    usr << "<span class='warning'>Red Text</span>black text"
    ```
  - To use variables in strings, you should **never** use the `text()` operator, use
   embedded expressions directly in the string.
     - Bad:
     ```
     usr << text("\The [] is leaking []!", src.name, src.liquid_type)
     ```
     - Good:
     ```
     usr << "\The [src] is leaking [liquid_type]"
     ```
  - To reference a variable/proc on the src object, you should **not** use
   `src.var`/`src.proc()`. The `src.` in these cases is implied, so you should just use
   `var`/`proc()`.
     - Bad:
     ```
     var/user = src.interactor
     src.fillReserves(user)
     ```
     - Good:
     ```
     var/user = interactor
     fillReserves(user)
     ```


## Maintainers
Это люди, которые занимаются обеспечением работы репозитория. Они принимают решения о принятии или отклонении PR'ов, а также расставляют теги у запросов.

#### Maintainer List
 - [FireFlashie](https://github.com/FireFlashie)
 - [SpeedCrash100](https://github.com/SpeedCrash100)

#### Maintainer instructions
 - Никогда не выкладывайте код напрямую в репозиторий, используйте PR!
 - Мэинтнеры могут нарушать правила, описанные выше.
 - Дождитесь, пока отработает CI перед тем, как сливать изменения. Однако, в крайних уважительных случаях - можно проигнорировать проверки (пример: фикс для настроекр Travis'а).