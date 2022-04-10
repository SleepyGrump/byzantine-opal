@@ You probably shouldn't change these settings unless you know what you're doing. These are separated out for ease of experimentation by the author.

&d.max-shortdesc-length [v(d.bd)]=200

&d.max-possible-player-width [v(d.bd)]=200

&d.min-possible-player-width [v(d.bd)]=48

@@ The maximum number of travel categories a player can set on a location.
&d.max-travel-categories [v(d.bd)]=3

@@ Make sure these match the defaults in your SQL Commands install if you change those. Note that these are used for other things beyond SQL so consider carefully before changing them.
&d.default-row-delimiter [v(d.bd)]=@@ROW@@

&d.default-column-delimiter [v(d.bd)]=@@COLUMN@@

&d.dangerous_in_sql [v(d.bd)]=%*_`\

&d.sanitize-where [v(d.bd)]=%\

&d.allowed_with_escapes_in_sql [v(d.bd)]=' "

@@ Title case functions
&d.words-to-leave-uncapitalized [v(d.bd)]=a an and as at but by for in it nor of on or the to up von

&d.punctuation [v(d.bd)]=. , ? ! ; : ( ) < > { } [ ] * / - + " '

&d.banned-characters [v(d.bd)]=. , ? ! ; : ( ) < > { } * / - + " ' % # @ + = $ ^ & _ | \ [ ]

&ooc [v(d.orp)]=1

@adesc [v(d.pp)]=think [moniker(%#)] looked at you.[if(not(hasattr(me, desc)), %b%ch+desc me=[lit(%%R%%T<Description>%%R)]%cn to set your description.)]

@desc [v(d.ep)]=if(hasflag(me, transparent), An exit leading to..., An ordinary exit.)

@osucc [v(d.ep)]=if(not(hasflag(where(me), BLIND)), cat(heads into, trim(first(name(me), <)).))

@odrop [v(d.ep)]=if(not(hasflag(loc(me), BLIND)), cat(emerges from, trim(first(name(where(me)), <)).))

@succ [v(d.ep)]=You head into...

@ofail [v(d.ep)]=if(not(hasflag(where(me), BLIND)), strcat(tries to go into, %b, trim(first(name(me), <)), %, but the door is locked.))

@fail [v(d.ep)]=strcat(alert(), %b, trim(first(name(me), <)) is locked.)

@descformat [v(d.ep)]=alert(name(me)) %0

@desc [v(d.qr)]=%R%TThis is the quiet room. No talking!%R

&d.travel-categories [v(d.qr)]=OOC Rooms

&d.travel-key [v(d.qr)]=QUIET

&d.travel-key [v(d.ooc)]=OOC

@force me=&d.default-ooc-room [v(d.bd)]=[v(d.ooc)]

@force me=&d.default-ic-room [v(d.bd)]=[v(d.ic)]

&d.travel-categories [v(d.ooc)]=OOC Rooms

&d.travel-key [v(d.ic)]=IC

&layout.conformat [v(d.rp)]=strcat(divider(People, %1), %r, whofields(%0, %1, ic-room))

&layout.conformat [v(d.orp)]=strcat(divider(People, %1), %r, whofields(%0, %1, room))

&layout.objects [v(d.rp)]=strcat(divider(Objects, %1), %r, whofields(%0, %1, object))

&layout.private-exits [v(d.rp)]=ulocal(layout.exits, filter(filter.is-exit-private, %1), Private, %0)

&layout.remaining-exits [v(d.rp)]=ulocal(layout.exits, filter(filter.is-exit-general, %1), General, %0)

&layout.exits [v(d.rp)]=if(t(%0), strcat(divider(%1 exits, %2), %r, formatcolumns(iter(%0, name(itext(0)),, |), |, %2), %r))

&layout.exitformat [v(d.rp)]=strcat(if(t(setr(0, filter(filter.visible-exit, lexits(me),,, %0))), strcat(ulocal(layout.remaining-exits, %0, %q0), ulocal(layout.private-exits, %0, %q0))), footer(if(t(%q0), words(%q0), No) exit[if(neq(words(%q0), 1), s)], %0))

@desc [v(d.rp)]=%R%TThis is the default room description.%R

&layout.views [v(d.rp)]=strcat(%r, divider(+views, %2), %r, formatcolumns(iter(%1, rest(itext(0), v(d.default-column-delimiter)), v(d.default-row-delimiter), v(d.default-row-delimiter)), v(d.default-row-delimiter), %2))

&layout.notes [v(d.rp)]=strcat(%r, divider(+notes, %2), %r, formatcolumns(iter(%1, rest(itext(0), v(d.default-column-delimiter)), v(d.default-row-delimiter), v(d.default-row-delimiter)), v(d.default-row-delimiter), %2))

@descformat [v(d.rp)]=strcat(formattext(%0, 1, %#), if(t(setr(V, lviews(num(me)))), ulocal(layout.views, num(me), %qV, %#)), if(t(setr(N, lnotes(num(me)))), ulocal(layout.notes, num(me), %qN, %#)))

&layout.room-name [v(d.rp)]=if(strmatch(%0, * - *), revwords(after(revwords(%0, %b-%b), %b-%b), %b-%b), %0)

&layout.room-header [v(d.rp)]=strcat(header(strcat(if(hasflag(me, TEMPROOM), TEMPROOM:%b), ulocal(layout.room-name, name(me))), %#), strcat(%r, multicol(strcat(if(isstaff(%#), ansi(xh, num(me))), |, ansi(first(themecolors()), last(name(me), %b-%b)), |, ansi(xh, setr(Y, strcat(case(parent(me), %vR, IC, OOC), %,%b, if(hasflag(me, UNFINDABLE), Private, Public))))), cat(strlen(%qY), *c, strlen(%qY)r), 0, |, %#)))

@nameformat [v(d.rp)]=ulocal(layout.room-header)

@conformat [v(d.rp)]=strcat(if(t(setr(0, if(hasflag(me, BLIND),, filter(filter.not_dark, lcon(me),,, %#)))), ulocal(layout.conformat, whosort(%q0, %#, room), %#)), if(t(setr(1, filter(filter.visible-objects, lcon(me),,, %#))), ulocal(layout.objects, whosort(%q1, %#, object), %#)), if(not(t(words(lexits(me)))), strcat(%r, footer(No exits, %#))))

@exitformat [v(d.rp)]=ulocal(layout.exitformat, %#)

&d.allowed-who-fields [v(d.bd)]=Alias|Apparent Age|Connection Info|Connected|DBref|Doing|Gender|IC Full Name|IC Handle|IC Occupation|IC Pronouns|Idle|Last IP|Location|Mail Stats|Name|Note|OOC Pronouns|Played-by|Position|Private Alts|Public Alts|Quote|RP Prefs|Short-desc|Staff Notes|Status|Themesong|Timezone|Wiki

&d.who-field-widths [v(d.bd)]=10 15 15 9 5 * 10 20 10 15 12 4 15 * 10 12 * 12 20 * 12 12 * 10 * * 8 * 10 *

&d.staff-only-who-fields [v(d.bd)]=Connection Info|Private Alts|Last IP|Staff Notes

&d.default-who-fields [v(d.bd)]=Status|Idle|Name|Position|Doing

&d.default-watch-fields [v(d.bd)]=Status|Idle|Name|Location|Doing|Note

&d.default-notes-fields [v(d.bd)]=Status|Idle|Name|Note

&d.default-staff-fields [v(d.bd)]=Status|Idle|Name|Alias|Position|Doing

&d.3who-columns [v(d.bd)]=Status|Name|Idle

&d.2who-columns [v(d.bd)]=Status|Name|Idle

@@ Sort order rolls left to right, so the last search is the most recent and will dominate the output.
&d.who-sort-order [v(d.bd)]=Connected

&d.default-room-fields [v(d.bd)]=Name|Idle|Short-desc

&d.default-ic-room-fields [v(d.bd)]=Name|Idle|Short-desc

&d.default-object-fields [v(d.bd)]=Name|Short-desc

@@ +finger layout
&d.finger-sections [v(d.bd)]=OOC Info|IC Info|Staff Info

&d.section.ooc_info [v(d.bd)]=Location|Doing|Position|OOC Pronouns|Connection Time|Mail Stats|RP Prefs|Timezone|Public Alts|Note

&d.section.ic_info [v(d.bd)]=Apparent Age|Gender|IC Full Name|IC Handle|IC Occupation|IC Pronouns|Played-by|Short-desc|Wiki|Themesong|Quote

&d.section.staff_info [v(d.bd)]=Private Alts|Connection Info|Last IP|Staff Notes

&d.finger-settable-fields [v(d.bd)]=Apparent Age|Gender|IC Full Name|IC Handle|IC Occupation|IC Pronouns|OOC Pronouns|Played-by|Position|Public Alts|Quote|RP Prefs|Short-desc|Themesong|Timezone|Wiki

@@ TODO: Connection_Time display bug when it shows up on +who - it should show something different for +finger than +who. Should be duration connected or just last login for +who.
