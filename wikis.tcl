namespace eval ::wikis:: {

# rikki ainakin https://fi.wikipedia.org/w/index.php?title=Live_(Alice_in_Chains)&printable=yes

package require http
package require tls

setudef flag wikis

set wikisVersion 0.1

bind pubm -|- "*" ::wikis::handler

set escapes { &#160; " " }
set reContent {^(([A-ZÄÖÅ0-9]\S*\s?){1,4})(\s.*\.?)}
set reStrip {lähde\?|\[\d+\]|<([^<])*>|Koordinaatit:\s?}

proc handler { nick mask hand channel args} {
        if {[channel get $channel wikis] && [onchan $nick $channel]} {
		set args [join $args]
		if {[llength $args] > 1} { set target [lindex $args 1]} else { set target $nick }
		switch -nocase [lindex $args 0] {
			"!wikis"	{ putquick "PRIVMSG $channel :[getParagraph [getWiki] [string trim $target]]" }
}	}	}

proc replaceContent {args nick} {
	variable reContent
	set args [join $args]
	regexp $reContent $args -> fullname shortname text
	if {![info exists fullname]} {return [errorMsgs]}
	set args [regsub $fullname $args [subst -nocommands -nobackslashes {$nick\3}]]
	set args [regsub -all [subst -nocommands -nobackslashes {${shortname}(|ssa|n|oon|on|en|an|lta|sen|in|:n)}] $args [subst -nocommands -nobackslashes {$nick\1}]]
	return $args
}

proc getParagraph {file nick} {
	variable escapes
	variable reContent
	variable reStrip
	set text {}
	foreach line $file {
		set result [regexp -inline {<p>(.*)<\/p>} $line]
		if {[string length [regsub -all $reStrip [join $result] {}]] > 25} { putlog "läpi meni tää [string length [regsub -all $reStrip [join $result] {}]], $result"; set text [lindex $result 1]; break }
	}
	set text [regsub -all $reStrip $text {}]
	putlog "textlen [string length $text], $text"
	return [encoding convertto utf-8 [replaceContent [string map $escapes $text] $nick]]
}

proc getWiki {} {
	set url "https://fi.wikipedia.org/w/index.php?title=Toiminnot:Satunnainen_sivu&printable=yes"
        set userAgent "Chrome 45.0.2454.101"
        ::http::config -useragent $userAgent
	::http::register https 443 ::tls::socket
	::tls::init -tls1 1
        set httpHandler [::http::geturl $url]
	set meta [::http::meta $httpHandler]
	set url "[dict get $meta Location]"
	set url "[regsub {\/wiki\/} $url {/w/index.php?title=}]"
	putlog "url $url"
        set httpHandler [::http::geturl $url]
        set html [split [::http::data $httpHandler] "\n"]
        set code [::http::code $httpHandler]
        ::http::cleanup $httpHandler
	return $html
}

proc readFile {} {
	set fileHandler [open nemetz.html r]
	set text [split [read $fileHandler] "\n"]
	close $fileHandler
	return $text
}

proc errorMsgs {} {
	variable wikisVersion
	set errors {
		"One does not simply regex tätä paskaa"
		"Selitykset on kuin persreiät, jokainen saanu niitä suuntäydeltä"
		"Oi sitä aikaa ku ei osattu koodata"
		"No hei vittu TCL"
		"Oliskohan norpalla vaikka ruokaa nälkäselle"
		"I'll be back"
		"Alarm! Soittakaa kirkolle!"
		"Tätä ei osaa korjata ees brite"
		"In the midnight hour..."
		"Saatoin vahingossa kirjoittaa näitä selityksiä enemmän ku itse koodia"
		"When in doubt - jekku"
		"Game over, man. Game over!"
		"Selkeesti tarttis lisää kuppii"
		"Kappas, kellokin on vasta 04:30"
		"Tää on silti kivempaa ku lähettinä"
		"Vittu"
		"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA *tsih*"
		"ALLAHU AKBAR!"
		"Joko kohta on kesä"
		"Vittu jos mun hautakivessä lukee \"Hän rakasti TCL:ää\" niin kostan alamaailmoista"
		"Tulevaisuuteni: \"You want fries with that?\""
		"Polka on muuten musagenrenä kauheen aliarvostettu"
	}
	return "ERROR! (v${wikisVersion}) [lindex $errors [expr round(rand() * [llength $errors])]]"
}

putlog "Wiki shit $wikisVersion by T-101 / Primitive loaded!"

}
