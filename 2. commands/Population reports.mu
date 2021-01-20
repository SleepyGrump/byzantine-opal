@@ +who, +watch, +where, +staff - anything related to showing lists of people.

@@ =============================================================================
@@ +who, +3who, +2who, etc.
@@ =============================================================================

&d.allowed-who-fields [v(d.bd)]=Status|Name|Alias|Location|Doing|Idle|Gender|DBref|Position|Note

&d.who-field-widths [v(d.bd)]=8 12 10 * * 4 10 5 * *

&d.default-who-fields [v(d.bd)]=Status|Idle|Name|Location|Doing|Position

&d.default-watch-fields [v(d.bd)]=Status|Idle|Name|Location|Doing|Note

&d.default-notes-fields [v(d.bd)]=Status|Idle|Name|Note

&d.default-staff-fields [v(d.bd)]=Status|Idle|Name|Alias|Position|Doing

&d.3who-columns [v(d.bd)]=Status|Name|Idle

&d.2who-columns [v(d.bd)]=Status|Name|Idle|Doing

&d.who-sort-order [v(d.bd)]=Idle|Status

&f.hilite-text [v(d.bf)]=ansi(if(ulocal(filter.watched, %0, %1), first(themecolors())), %2)

&f.sort-players [v(d.bf)]=strcat(setq(P,), null(iter(ulocal(f.get-sort-order, %0), setq(P, ulocal(f.sort.by_[itext(0)], edit(%0, %b, |), %1)), |, |)), edit(%qP, |, %b))

&f.get-players [v(d.bf)]=strcat(setq(P, filter(filter.not_dark, lwho(),,, %0)), ulocal(f.sort-players, %qP, %0))

&f.get-fields [v(d.bf)]=strcat(setq(F,), null(iter(default(%0/who-fields, %1), if(member(v(d.allowed-who-fields), itext(0), |), setq(F, strcat(%qF, |, itext(0)))), |)), trim(squish(%qF, |), b, |))

&f.get-field-widths [v(d.bf)]=iter(%0, extract(v(d.who-field-widths), member(v(d.allowed-who-fields), itext(0), |), 1), |)

&f.get-sort-order [v(d.bf)]=strcat(setq(S,), null(iter(default(%0/who-sort, v(d.who-sort-order)), if(member(v(d.allowed-who-fields), itext(0), |), setq(S, %qS|[itext(0)])), |)), setq(S, trim(%qS, b, |)), %qS)

&f.get-unique-count [v(d.bf)]=strcat(setq(0, 0), setq(1,), null(iter(%0, if(member(%q1, setr(2, xget(itext(0), lastip)), |),, strcat(setq(0, add(%q0, 1)), setq(1, setunion(%q1, %q2, |)))))), %q0)

&layout.who_data [v(d.bf)]=iter(%2, ulocal(f.get-[itext(0)], %0, %1), |, |)

&layout.who_footer [v(d.bf)]=cat(words(%0), connected, /, ulocal(f.get-unique-count, %0), unique, /, connrecord(), record)

&layout.who [v(d.bf)]=strcat(header(Who's online, %0), %r,multicol(strcat(edit(setr(F, ulocal(f.get-fields, %0, v(d.default-[if(t(%2), %2, who)]-fields))), Doing, poll()), |, iter(%1, ulocal(layout.who_data, itext(0), %0, %qF),, |)), ulocal(f.get-field-widths, %qF), 1, |, %0), %r, footer(ulocal(layout.who_footer, %1), %0))

&layout.3who [v(d.bf)]=strcat(setq(C, edit(setr(F, v(d.3who-columns)), Doing, poll())), header(Who's online - 3who, %0), %r, multicol(strcat(%qC|%qC|%qC, |, iter(setr(P, ulocal(f.get-players, %0)), ulocal(layout.who_data, itext(0), %0, %qF),, |)), setr(W, ulocal(f.get-field-widths, %qF)) %qW %qW, 1, |, %0), %r, footer(ulocal(layout.who_footer, %qP), %0))

&layout.2who [v(d.bf)]=strcat(setq(C, edit(setr(F, v(d.2who-columns)), Doing, poll())), header(Who's online - 2who, %0), %r, multicol(strcat(%qC|%qC, |, iter(setr(P, ulocal(f.get-players, %0)), ulocal(layout.who_data, itext(0), %0, %qF),, |)), setr(W, ulocal(f.get-field-widths, %qF)) %qW, 1, |, %0), %r, footer(ulocal(layout.who_footer, %qP), %0))

&c.+who [v(d.bc)]=$+who:@pemit %#=ulocal(layout.who, %#, ulocal(f.get-players, %#));

&c.+who_name [v(d.bc)]=$+who *:@pemit %#=ulocal(layout.who, %#, filter(filter.name, ulocal(f.get-players, %#),,, %0));

&c.+who/notes [v(d.bc)]=$+who/n*:@break strmatch(%0, *=*); @pemit %#=ulocal(layout.who, %#,  ulocal(f.get-players, %#), notes);

&c.+who/sort [v(d.bc)]=$+who/sort *:@break t(setr(N, setdiff(edit(title(rest(%0)), %b, |), v(d.allowed-who-fields), |)))={ @trigger me/tr.error=%#, strcat(The field, if(gt(%qN, 1), s), ', itemize(%qN, |), ', if(gt(%qN, 1), are, is), %b, not allowed on the +who sort list.); }; &who-sort %#=edit(%0, %b, |); @trigger me/tr.success=%#, Your +who will now be sorted by [itemize(%0)].; @force %#=+who;

@@ TODO: Test sorting. Sort by position doesn't seem to be working.

&c.+who/columns [v(d.bc)]=$+who/c*:@break t(setr(N, setdiff(edit(title(rest(%0)), %b, |), v(d.allowed-who-fields), |)))={ @trigger me/tr.error=%#, strcat(The field, if(gt(%qN, 1), s), ', itemize(%qN, |), ', if(gt(%qN, 1), are, is), %b, not allowed on the +who list.); }; &who-fields %#=edit(title(rest(%0)), %b, |); @trigger me/tr.success=%#, Your +who will now display the [if(t(rest(%0)), columns [itemize(title(rest(%0)))], default columns)].; @force %#=+who;

&c.+3who [v(d.bc)]=$+3who:@pemit %#=ulocal(layout.3who, %#);

&c.+2who [v(d.bc)]=$+2who:@pemit %#=ulocal(layout.2who, %#);

&c.+who/watch [v(d.bc)]=$+who/w* *:@break strmatch(%1, *=*); @assert t(setr(P, switch(%1, me, %#, pmatch(%1))))={ @trigger me/tr.error=%#, Could not find a player named '%1'.; }; &friends %#=setunion(xget(%#, friends), %qP); @trigger me/tr.success=%#, moniker(%qP) has been added to your watch list.;

&c.+who/watch_note [v(d.bc)]=$+who/w* *=*:@assert t(setr(P, switch(%1, me, %#, pmatch(%1))))={ @trigger me/tr.error=%#, Could not find a player named '%1'.; }; &friends %#=setunion(xget(%#, friends), %qP); &d.note-%qP %#=%2; @trigger me/tr.success=%#, moniker(%qP) has been added to your watch list with the note '%2'.;

&c.+who/unwatch [v(d.bc)]=$+who/unw* *:@assert t(setr(P, switch(%1, me, %#, pmatch(%1))))={ @trigger me/tr.error=%#, Could not find a player named '%1'.; }; @assert member(xget(%#, friends), %qP)={ @trigger me/tr.error=%#, You aren't currently watching [moniker(%qP)].; }; &friends %#=setdiff(xget(%#, friends), %qP); @trigger me/tr.success=%#, moniker(%qP) has been removed from your watch list.;

&c.+who/hide [v(d.bc)]=$+who/h*:@break xget(%#, watch.hide)={ @trigger me/tr.error=%#, You are already set to hide from +watch.; }; &watch.hide %#=1; @trigger me/tr.success=%#, You are now hiding from +watch. People will no longer be notified when you log in and out.;

&c.+who/unhide [v(d.bc)]=$+who/unh*:@assert xget(%#, watch.hide)={ @trigger me/tr.error=%#, You are not currently set to hide from +watch.; }; &watch.hide %#=0; @trigger me/tr.success=%#, You are no longer hiding from +watch. People will now be notified when you log in and out.;

&c.+who/per [v(d.bc)]=$+who/pe* *:@assert t(setr(P, switch(%1, me, %#, pmatch(%1))))={ @trigger me/tr.error=%#, Could not find a player named '%1'.; }; &watchpermit %#=setunion(xget(%#, watchpermit), %qP); @trigger me/tr.success=%#, moniker(%qP) will now be allowed to see you log in%, even when you're hiding from +watch.;

&c.+who/unper [v(d.bc)]=$+who/unp* *:@assert t(setr(P, switch(%1, me, %#, pmatch(%1))))={ @trigger me/tr.error=%#, Could not find a player named '%1'.; }; @assert member(xget(%#, watchpermit), %qP)={ @trigger me/tr.error=%#, moniker(%qP) is not currently allowed to see when you log in while hidden.; }; &watchpermit %#=setdiff(xget(%#, watchpermit), %qP); @trigger me/tr.success=%#, moniker(%qP) will no longer be allowed to see you log in when you're hiding from +watch.;

&c.+who/note [v(d.bc)]=$+who/n* *=*:@assert t(setr(P, switch(%1, me, %#, pmatch(%1))))={ @trigger me/tr.error=%#, Could not find a player named '%1'.; }; &d.note-%qP %#=%2; @trigger me/tr.success=%#, Your note for [moniker(%qP)] is now '%2'.;

&c.+who/page [v(d.bc)]=$+who/page *:@assert hasattr(%#, friends)={ @trigger me/tr.error=%#, You don't have anyone on your +watch list. +watch/add <name> to add someone!; }; @eval setq(P, filter(filter.not_dark, xget(%#, friends),,, %#)); @assert t(%qP)={ @trigger me/tr.error=%#, None of your +watch friends appear to be online.; }; @dolist %qP=@force %#={ page ##=%0; };


@@ =============================================================================
@@ +watch - it's tied to +who so might as well keep it close.
@@ =============================================================================

&layout.watch [v(d.bf)]=strcat(setq(P, xget(%0, friends)), header(Your +watch list, %0), %r, multicol(strcat(edit(setr(F, ulocal(f.get-fields, %0, v(d.default-watch-fields))), Doing, poll()), |, iter(%qP, ulocal(layout.who_data, itext(0), %0, %qF),, |)), ulocal(f.get-field-widths, %qF), 1, |, %0), %r, footer(+watch/del or +who/unwatch <name> to remove someone, %0))

&c.+watch [v(d.bc)]=$+watch:@assert hasattr(%#, friends)={ @trigger me/tr.error=%#, You don't have anyone on your +watch list. +watch/add to add someone!; }; @assert t(filter(filter.not_dark, xget(%#, friends),,, %#))={ @trigger me/tr.error=%#, Looks like none of your friends are on right now.; }; @pemit %#=ulocal(layout.who, %#, filter(filter.watched, ulocal(f.get-players, %#),,, %#), watch);

&c.+watch/list [v(d.bc)]=$+watch/l*:@assert hasattr(%#, friends)={ @trigger me/tr.error=%#, You don't have anyone on your +watch list. +watch/add <name> to add someone!; }; @pemit %#=ulocal(layout.watch, %#);

&c.+watch/add [v(d.bc)]=$+watch/add *:@force %#=+who/watch %0;

&c.+watch/who [v(d.bc)]=$+watch/who:@force %#=+watch;

&c.+watch/del [v(d.bc)]=$+watch/d* *:@force %#=+who/unwatch %1;

&c.+watch/rem [v(d.bc)]=$+watch/r* *:@force %#=+who/unwatch %1;

&c.+watch/hide [v(d.bc)]=$+watch/h*:@force %#=+who/hide;

&c.+watch/unhide [v(d.bc)]=$+watch/unh*:@force %#=+who/unhide;

&c.+watch/per [v(d.bc)]=$+watch/pe* *:@force %#=+who/permit %1;

&c.+watch/unper [v(d.bc)]=$+watch/unp* *:@force %#=+who/unpermit %1;

&c.+watch/note [v(d.bc)]=$+watch/n* *=*:@force %#=+who/note %1=%2;

&c.+watch/page [v(d.bc)]=$+watch/page *:@force %#=+who/page %0;

&c.+watch/on [v(d.bc)]=$+watch/on:@assert t(xget(%#, watch.off))={ @trigger me/tr.error=%#, Your watch notifications are already turned on. If you're not seeing someone connect%, they may have opted out of being +watched.; }; &watch.off %#=0; @trigger me/tr.success=%#, Your +watch is now turned on.;

&c.+watch/off [v(d.bc)]=$+watch/off:@break t(xget(%#, watch.off))={ @trigger me/tr.error=%#, Your watch notifications are already turned off.; }; &watch.off %#=1; @trigger me/tr.success=%#, Your +watch is now turned off.;

&c.+watch/all_on [v(d.bc)]=$+watch/all on:@break t(xget(%#, watch.all.on))={ @trigger me/tr.error=%#, Your +watch/all is already turned on.; }; &watch.all.on %#=1; &watch.off %#=0; @trigger me/tr.success=%#, You will now see all connects and disconnects.;

&c.+watch/all_off [v(d.bc)]=$+watch/all off:@assert t(xget(%#, watch.all.on))={ @trigger me/tr.error=%#, Your +watch/all is already turned off.; }; &watch.all.on %#=0; @trigger me/tr.success=%#, You will no longer see all connects and disconnects.;

&f.people_to_notify [v(d.bf)]=strcat(setq(P, lwho()), setq(P, filter(filter.watching_target, %qP,,, %0)), setq(P, filter(filter.allowed_to_watch_target, %qP,,, %0)), setq(P, filter(filter.watch_on, %qP)), %qP)

&layout.watch-connect [v(d.bf)]=udefault(%0/watchfmt, cat(alert(prettytime()), moniker(%1), has connected.), %1, connected)

&layout.watch-disconnect [v(d.bf)]=udefault(%0/watchfmt, cat(alert(prettytime()), moniker(%1), has disconnected.), %1, disconnected)

&tr.aconnect-watch [v(d.bc)]=@dolist ulocal(f.people_to_notify, %0)={ @pemit ##=ulocal(layout.watch-connect, ##, %0); @trigger/quiet ##/awatch=[moniker(%0)], connected; };

&tr.adisconnect-watch [v(d.bc)]=@dolist ulocal(f.people_to_notify, %0)={ @pemit ##=ulocal(layout.watch-disconnect, ##, %0); @trigger/quiet ##/awatch=[moniker(%0)], disconnected; };

@@ =============================================================================
@@ +staff
@@ =============================================================================

&layout.staff [v(d.bf)]=strcat(header(%2, %0), %r,multicol(strcat(edit(setr(F, ulocal(f.get-fields, %0, v(d.default-staff-fields))), Doing, poll()), |, iter(%1, ulocal(layout.who_data, itext(0), %0, %qF),, |)), ulocal(f.get-field-widths, %qF), 1, |, %0), %r, footer(ulocal(layout.who_footer, %1), %0))

&c.+staff [v(d.bc)]=$+staff:@pemit %#=ulocal(layout.staff, %#, ulocal(f.sort-players, filter(filter.isstaff, ulocal(f.get-players, %#)), %#), Connected staff);

&c.+staff/all [v(d.bc)]=$+staff/all:@pemit %#=ulocal(layout.staff, %#, ulocal(f.sort-players, ulocal(f.get-staff), %#), All staff);
