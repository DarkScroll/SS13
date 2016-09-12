//Runs byond's sanitization proc along-side sanitize_simple
/proc/sanitize(var/input, var/max_length = MAX_MESSAGE_LEN, var/encode = 1, var/trim = 1, var/extra = 1, var/mode = SANITIZE_CHAT)
	if(!input)
		return

	if(max_length)
		input = copytext(input,1,max_length)

	//code in modules/l10n/localisation.dm
	input = sanitize_local(input, mode)

	if(extra)
		input = replace_characters(input, list("\n"=" ","\t"=" "))

	if(encode)
		// The below \ escapes have a space inserted to attempt to enable Travis auto-checking of span class usage. Please do not remove the space.
		//In addition to processing html, html_encode removes byond formatting codes like "\ red", "\ i" and other.
		//It is important to avoid double-encode text, it can "break" quotes and some other characters.
		//Also, keep in mind that escaped characters don't work in the interface (window titles, lower left corner of the main window, etc.)
		input = lhtml_encode(input)
	else
		//If not need encode text, simply remove < and >
		//note: we can also remove here byond formatting codes: 0xFF + next byte
		input = replace_characters(input, list("<"=" ", ">"=" "))

	if(trim)
		//Maybe, we need trim text twice? Here and before copytext?
		input = trim(input)
	return input

/*
	This should be in code/setup.dm

#define SANITIZE_CHAT 1
#define SANITIZE_BROWSER 2
#define SANITIZE_LOG 3
#define SANITIZE_TEMP 4

*/
/*
	The most used output way is text chat. So fatal letters by default should be transformed into chat version.
	Also, it`s easier to fix all browser() calls than search all possible "[src|usr|mob|any other var] <<" calls.
	Logs need a special letter, because watch normal text with ascii code insertions is weird.
	And sometimes we need special unique temp letter for input windows whitch allows to edit text.
	Like in custom event message, admin memo and VV.
*/

var/global/list/localisation = list()

/datum/letter
	var/letter = ""			//weird letter
	var/chat = ""			//chat letter
	var/browser = ""		//letter in browser windows
	var/log = ""			//letter for logs
	var/temp = ""			//temporatory letter for filled input windows
							//!!!temp must be unique for every letter!!!

	autofix_proper
		letter = "\proper"
		chat = ""
		browser = ""
		log = ""
		temp = ""

	autofix_improper
		letter = "\improper"
		chat = ""
		browser = ""
		log = ""
		temp = ""

	cyrillic_ya
		letter = "ÿ"
		chat = "&#255;"
		browser = "&#1103;"
		log = "ß"
		temp = "¶"

proc/sanitize_local(var/text, var/mode = SANITIZE_CHAT)
	if(!istext(text))
		return text
	for(var/datum/letter/L in localisation)
		switch(mode)
			if(SANITIZE_CHAT)		//only basic input goes to chat
				text = replace_characters(text, list(L.letter=L.chat, L.temp=L.chat))

			if(SANITIZE_BROWSER)	//browser takes everything
				text = replace_characters(text, list(L.letter=L.browser, L.temp=L.browser, L.chat=L.browser))

			if(SANITIZE_LOG)		//logs can get raw or prepared text
				text = replace_characters(text, list(L.letter=L.log, L.chat=L.log))

			if(SANITIZE_TEMP)		//same for input windows
				text = replace_characters(text, list(L.letter=L.temp, L.chat=L.temp))
	return text

/*
	Both encode and decode can break special symbol codes, so we need to replace them.
	Text letters always tuning into chat mode, and browser sanitization should be before every browser() call.
	I dunno, should every call be replaced, because maybe there some calls that isn`t used with users input.
*/

/proc/lhtml_encode(var/text)
	text = sanitize_local(text, SANITIZE_TEMP)
	text = html_encode(text)
	text = sanitize_local(text)
	return text

/proc/lhtml_decode(var/text)
	text = sanitize_local(text, SANITIZE_TEMP)
	text = html_decode(text)
	text = sanitize_local(text)
	return text

//From Rubay
/proc/lowertext_alt(var/text)
	var/lenght = length(text)
	var/new_text = null
	var/lcase_letter
	var/letter_ascii

	var/p = 1
	while(p <= lenght)
		lcase_letter = copytext(text, p, p + 1)
		letter_ascii = text2ascii(lcase_letter)

		if((letter_ascii >= 65 && letter_ascii <= 90) || (letter_ascii >= 192 && letter_ascii < 223))
			lcase_letter = ascii2text(letter_ascii + 32)
		else if(letter_ascii == 223)
			lcase_letter = "¶"

		new_text += lcase_letter
		p++

	return new_text

/proc/uppertext_alt(var/text)
	var/lenght = length(text)
	var/new_text = null
	var/ucase_letter
	var/letter_ascii

	var/p = 1
	while(p <= lenght)
		ucase_letter = copytext(text, p, p + 1)
		letter_ascii = text2ascii(ucase_letter)

		if((letter_ascii >= 97 && letter_ascii <= 122) || (letter_ascii >= 224 && letter_ascii < 255))
			ucase_letter = ascii2text(letter_ascii - 32)
		else if(letter_ascii == text2ascii("¶"))
			ucase_letter = "ß"

		new_text += ucase_letter
		p++

	return new_text

/proc/pointization(text as text)
	if(!text)
		return
	if(copytext(text,1,2) == "*") //Emotes allowed.
		return text
	if(copytext(text,-1) in list("!", "?", "."))
		return text
	text += "."
	return text


/proc/ruscapitalize(var/t as text)
	var/s = 2
	if(copytext(t,1,2) == ";")
		s += 1
	else if(copytext(t,1,2) == ":")
		if(copytext(t,3,4) == " ")
			s+=3
		else
			s+=2
	return upperrustext(copytext(t, 1, s)) + copytext(t, s)

/proc/upperrustext(text as text)
	var/t = ""
	for(var/i = 1, i <= length(text), i++)
		var/a = text2ascii(text, i)
		if(a > 223)
			t += ascii2text(a - 32)
		else if(a == 184)
			t += ascii2text(168)
		else t += ascii2text(a)
	t = replacetext(t,"&#1103;","ÿ")
	t = replacetext(t, "ÿ", "ß")
	return t


/proc/lowerrustext(text as text)
	var/t = ""
	for(var/i = 1, i <= length(text), i++)
		var/a = text2ascii(text, i)
		if(a > 191 && a < 224)
			t += ascii2text(a + 32)
		else if(a == 168)
			t += ascii2text(184)
		else t += ascii2text(a)
	t = replacetext(t,"ÿ","&#1103;")
	return t
