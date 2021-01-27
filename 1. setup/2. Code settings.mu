@@ You probably shouldn't change these unless you know what you're doing.

&d.max-shortdesc-length [v(d.bd)]=200

@@ Make sure these match the defaults in your SQL Commands install if you change those:
&d.default-row-delimeter [v(d.bd)]=|

&d.default-column-delimeter [v(d.bd)]=~

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

&layout.conformat [v(d.rp)]=strcat(divider(People, %1), %r, ulocal(layout.who-list, %0, %1, room))

&layout.objects [v(d.rp)]=strcat(divider(Objects, %1), %r, ulocal(layout.who-list, %0, %1, object))

&layout.commercial-exits [v(d.rp)]=ulocal(layout.exits, filter(filter.is-exit-commercial, %1), Commercial, %0)

&layout.residential-exits [v(d.rp)]=ulocal(layout.exits, filter(filter.is-exit-residential, %1), Residential, %0)

&layout.remaining-exits [v(d.rp)]=ulocal(layout.exits, filter(filter.is-exit-neither-commercial-nor-residential, %1), General, %0)

&layout.exits [v(d.rp)]=if(t(%0), strcat(divider(%1 exits, %2), %r, formatcolumns(iter(%0, name(itext(0)),, |), |, %2), %r))

&layout.exitformat [v(d.rp)]=strcat(if(t(setr(0, filter(filter.visible-exit, lexits(me),,, %0))), strcat(ulocal(layout.commercial-exits, %0, %q0), ulocal(layout.residential-exits, %0, %q0), ulocal(layout.remaining-exits, %0, %q0))), footer(if(t(%q0), words(%q0), No) exit[if(neq(words(%q0), 1), s)]))

&layout.exitformat [v(d.orp)]=strcat(if(t(setr(0, filter(filter.visible-exit, lexits(me),,, %0))), ulocal(layout.exits, %q0, General, %0)), footer(if(t(%q0), words(%q0), No) exit[if(neq(words(%q0), 1), s)]))

@desc [v(d.rp)]=%R%TThis is the default room description.%R

@descformat [v(d.rp)]=formattext(edit(%0, %T, indent()), %#)

@nameformat [v(d.rp)]=header(name(me), %#)

@conformat [v(d.rp)]=strcat(if(t(setr(0, filter(filter.not_dark, lcon(me),,, %#))), ulocal(layout.conformat, %q0, %#)), if(t(setr(1, filter(filter.visible-objects, lcon(me),,, %#))), ulocal(layout.objects, %q1, %#)), if(not(t(words(lexits(me)))), strcat(%r, footer(No exits, %#))))

@exitformat [v(d.rp)]=ulocal(layout.exitformat, %#)

&d.allowed-who-fields [v(d.bd)]=Status|Name|Alias|Location|Doing|Idle|Gender|DBref|Position|Note|Short-desc

&d.who-field-widths [v(d.bd)]=8 12 10 * * 4 10 5 * * *

&d.default-who-fields [v(d.bd)]=Status|Idle|Name|Location|Doing|Position

&d.default-watch-fields [v(d.bd)]=Status|Idle|Name|Location|Doing|Note

&d.default-notes-fields [v(d.bd)]=Status|Idle|Name|Note

&d.default-staff-fields [v(d.bd)]=Status|Idle|Name|Alias|Position|Doing

&d.3who-columns [v(d.bd)]=Status|Name|Idle

&d.2who-columns [v(d.bd)]=Status|Name|Idle|Doing

&d.who-sort-order [v(d.bd)]=Idle|Status

&d.default-room-fields [v(d.bd)]=Name|Idle|Short-desc

&d.default-object-fields [v(d.bd)]=Name|Short-desc

