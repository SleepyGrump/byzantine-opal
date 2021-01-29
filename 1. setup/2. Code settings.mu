@@ You probably shouldn't change these unless you know what you're doing.

&d.max-shortdesc-length [v(d.bd)]=200

@@ Make sure these match the defaults in your SQL Commands install if you change those:
&d.default-row-delimeter [v(d.bd)]=|

&d.default-column-delimeter [v(d.bd)]=~

&d.dangerous_in_sql [v(d.bd)]=%*_`\

&d.sanitize-where [v(d.bd)]=%\

&d.allowed_with_escapes_in_sql [v(d.bd)]=' "

@@ Title case functions
&d.words-to-leave-uncapitalized [v(d.bd)]=a an and as at but by for in it nor of on or the to up von

&d.punctuation [v(d.bd)]=. , ? ! ; : ( ) < > { } * / - + " '

&ooc [v(d.orp)]=1

@adesc [v(d.pp)]=think [moniker(%#)] looked at you.[if(not(hasattr(me, desc)), %b@desc me=[lit(%%R%%T<Description>%%R)] to set your description.)]

@desc [v(d.ep)]=A path leading off to...

@descformat [v(d.ep)]=alert(name(me)) %0

@desc [v(d.qr)]=%R%TThis is the quiet room. No talking!%R

&d.travel-categories [v(d.qr)]=OOC

&d.travel-key [v(d.qr)]=QUIET

&d.travel-key [v(d.ooc)]=OOCROOM

&d.travel-categories [v(d.ooc)]=OOC

&d.travel-key [v(d.ic)]=IC

&layout.conformat [v(d.rp)]=strcat(divider(People, %1), %r, whofields(%0, %1, room))

&layout.objects [v(d.rp)]=strcat(divider(Objects, %1), %r, whofields(%0, %1, object))

&layout.commercial-exits [v(d.rp)]=ulocal(layout.exits, filter(filter.is-exit-commercial, %1), Commercial, %0)

&layout.residential-exits [v(d.rp)]=ulocal(layout.exits, filter(filter.is-exit-residential, %1), Residential, %0)

&layout.remaining-exits [v(d.rp)]=ulocal(layout.exits, filter(filter.is-exit-neither-commercial-nor-residential, %1), General, %0)

&layout.exits [v(d.rp)]=if(t(%0), strcat(divider(%1 exits, %2), %r, formatcolumns(iter(%0, name(itext(0)),, |), |, %2), %r))

&layout.exitformat [v(d.rp)]=strcat(if(t(setr(0, filter(filter.visible-exit, lexits(me),,, %0))), strcat(ulocal(layout.commercial-exits, %0, %q0), ulocal(layout.residential-exits, %0, %q0), ulocal(layout.remaining-exits, %0, %q0))), footer(if(t(%q0), words(%q0), No) exit[if(neq(words(%q0), 1), s)]))

&layout.exitformat [v(d.orp)]=strcat(if(t(setr(0, filter(filter.visible-exit, lexits(me),,, %0))), ulocal(layout.exits, %q0, General, %0)), footer(if(t(%q0), words(%q0), No) exit[if(neq(words(%q0), 1), s)]))

@desc [v(d.rp)]=%R%TThis is the default room description.%R

@descformat [v(d.rp)]=formattext(%0, 1, %#)

@nameformat [v(d.rp)]=header(name(me), %#)

@conformat [v(d.rp)]=strcat(if(t(setr(0, filter(filter.not_dark, lcon(me),,, %#))), ulocal(layout.conformat, whosort(%q0, %#, room), %#)), if(t(setr(1, filter(filter.visible-objects, lcon(me),,, %#))), ulocal(layout.objects, whosort(%q1, %#, object), %#)), if(not(t(words(lexits(me)))), strcat(%r, footer(No exits, %#))))

@exitformat [v(d.rp)]=ulocal(layout.exitformat, %#)

&d.allowed-who-fields [v(d.bd)]=Alias|Apparent Age|Connection Info|Connection Time|DBref|Doing|Gender|IC Full Name|IC Handle|IC Occupation|IC Pronouns|Idle|Last IP|Location|Mail Stats|Name|Note|OOC Pronouns|Played-by|Position|Private Alts|Public Alts|Quote|RP Prefs|Short-desc|Staff Notes|Status|Themesong|Timezone|Wiki

&d.who-field-widths [v(d.bd)]=10 15 15 15 5 * 10 20 10 15 12 4 15 * 10 12 * 12 20 * 12 12 * 10 * * 8 * 10 *

&d.staff-only-who-fields [v(d.bd)]=Connection Info|Private Alts|Last IP|Staff Notes

&d.default-who-fields [v(d.bd)]=Status|Idle|Name|Location|Doing|Position

&d.default-watch-fields [v(d.bd)]=Status|Idle|Name|Location|Doing|Note

&d.default-notes-fields [v(d.bd)]=Status|Idle|Name|Note

&d.default-staff-fields [v(d.bd)]=Status|Idle|Name|Alias|Position|Doing

&d.3who-columns [v(d.bd)]=Status|Name|Idle

&d.2who-columns [v(d.bd)]=Status|Name|Idle|Doing

@@ Sort order rolls left to right, so the last search is the most recent and will dominate the output.
&d.who-sort-order [v(d.bd)]=Idle

&d.default-room-fields [v(d.bd)]=Name|Idle|Short-desc

&d.default-object-fields [v(d.bd)]=Name|Short-desc

@@ +finger layout
&d.finger-sections [v(d.bd)]=OOC Info|IC Info|Staff Info

&d.section.ooc_info [v(d.bd)]=Name|Alias|Location|Doing|Idle|Position|Note|OOC Pronouns|Connection Time|Mail Stats|RP Prefs|Timezone|Public Alts|Note

&d.section.ic_info [v(d.bd)]=Apparent Age|Gender|IC Full Name|IC Handle|IC Occupation|IC Pronouns|Played-by|Short-desc|Wiki|Themesong|Quote

&d.section.staff_info [v(d.bd)]=Private Alts|Connection Info|Last IP|Staff Notes

&d.finger-settable-fields [v(d.bd)]=Apparent Age|Gender|IC Full Name|IC Handle|IC Occupation|IC Pronouns|OOC Pronouns|Played-by|Position|Public Alts|Quote|RP Prefs|Short-desc|Themesong|Timezone|Wiki

