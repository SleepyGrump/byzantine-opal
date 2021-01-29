@@ +who, +watch, +where, +staff - anything related to showing lists of people.

@@ =============================================================================
@@ +who, +3who, +2who, etc.
@@ =============================================================================

&layout.player-info [v(d.bf)]=strcat(terminfo(%0), -, height(%0), -, width(%0), -, colordepth(%0), -, host(%0))

&tr.aconnect-player-info [v(d.bc)]=@set %0=_player-info:[setr(0, ulocal(layout.player-info, %0))]|[remove(xget(%0, _player-info), %q0, |, |)]; @set %0=_last-conn:[secs()];

&f.hilite-text [v(d.bf)]=ansi(if(ulocal(filter.watched, %0, %1), first(themecolors())), %2)

&f.get-players [v(d.bf)]=strcat(setq(P, filter(filter.not_dark, lwho(),,, %0)), ulocal(f.sort-players, %qP, %0, %1))

&f.get-unique-count [v(d.bf)]=strcat(setq(0, 0), setq(1,), null(iter(%0, if(member(%q1, setr(2, xget(itext(0), lastip)), |),, strcat(setq(0, add(%q0, 1)), setq(1, setunion(%q1, %q2, |)))))), %q0)

&layout.who_footer [v(d.bf)]=cat(words(%0), connected, /, ulocal(f.get-unique-count, %0), unique, /, connrecord(), record)

&layout.watch_footer [v(d.bf)]=cat(words(%0) out of, words(xget(%1, friends)), watched players displayed)

&layout.who [v(d.bf)]=strcat(setq(D, if(t(%2), %2, who)), header(%3, %0), %r, whofields(%1, %0, %qD, %qD), %r, footer(ulocal(layout.%qD_footer, %1, %0), %0))

&layout.3who [v(d.bf)]=strcat(setq(C, edit(setr(F, v(d.3who-columns)), Doing, poll())), header(Who's online - 3who, %0), %r, multicol(strcat(%qC|%qC|%qC, |, iter(setr(P, ulocal(f.get-players, %0, who)), ulocal(layout.who_data, itext(0), %0, %qF),, |)), setr(W, ulocal(f.get-field-widths, %qF)) %qW %qW, 1, |, %0), %r, footer(ulocal(layout.who_footer, %qP), %0))

&layout.2who [v(d.bf)]=strcat(setq(C, edit(setr(F, v(d.2who-columns)), Doing, poll())), header(Who's online - 2who, %0), %r, multicol(strcat(%qC|%qC, |, iter(setr(P, ulocal(f.get-players, %0, who)), ulocal(layout.who_data, itext(0), %0, %qF),, |)), setr(W, ulocal(f.get-field-widths, %qF)) %qW, 1, |, %0), %r, footer(ulocal(layout.who_footer, %qP), %0))

&c.+who [v(d.bc)]=$+who:@pemit %#=ulocal(layout.who, %#, ulocal(f.get-players, %#, who),, Who's online);

&c.+who_name [v(d.bc)]=$+who *:@pemit %#=ulocal(layout.who, %#, filter(filter.name, ulocal(f.get-players, %#, who),,, %0),, Who's online - starting with '%0');

&c.+who/notes [v(d.bc)]=$+who/n*:@break strmatch(%0, *=*); @pemit %#=ulocal(layout.who, %#,  ulocal(f.get-players, %#, notes), notes, Who's online - with notes);

&f.get-friendly-who-list-name [v(d.bf)]=switch(%0, room, player list in rooms, object, object list in rooms, note, +who/notes, +%0)

&f.get-available-who-columns [v(d.bf)]=setdiff(v(d.allowed-who-fields), if(isstaff(%0),, v(d.staff-only-who-fields)), |)

&f.get-valid-who-column [v(d.bf)]=trim(squish(iter(%1, grab(%0, itext(0)*, |), |, |), |), b, |)

th ulocal(v(d.bf)/f.get-valid-who-column, ulocal(v(d.bf)/f.get-available-who-columns, %#), position|asdf)
+who/sort who=adsf


&f.is-valid-who-list [v(d.bf)]=t(member(edit(lcstr(lattr(%vD/d.default-*-fields)), d.default-,, -fields,), lcstr(%0)))

&f.get-valid-who-list [v(d.bf)]=edit(lcstr(lattr(%vD/d.default-*-fields)), d.default-,, -fields,)

&f.get-who-field-error [v(d.bf)]=strcat(setq(N, setdiff(%1, %0, |)), The field, if(gt(words(%qN, |), 1), s), %b, ', itemize(%qN, |), ', %b, if(gt(words(%qN, |), 1), are, is), %b, not allowed on the %2 list. Valid options are [itemize(edit(%3, %b, _), |)].)

&c.+who/sort_text [v(d.bc)]=$+who/s* *:@eval strcat(setq(F, switch(%1, *=*, rest(%1, =), %1)), setq(W, edit(%1, +,)), setq(W, switch(%qW, *=*, first(%qW, =), who)), if(eq(strlen(%qW), 0), setq(W, who)), setq(F, edit(title(%qF), %b, |, _, %b))); @assert ulocal(f.is-valid-who-list, %qW)={ @trigger me/tr.error=%#, '%qW' is not a recognized destination list you can sort. Valid options are [itemize(ulocal(f.get-valid-who-list))].; }; @break cand(neq(words(%qF, |), 0), neq(words(setr(N, ulocal(f.get-valid-who-column, setr(A, ulocal(f.get-available-who-columns, %#)), %qF)), |), words(%qF, |)))={ @trigger me/tr.error=%#, ulocal(f.get-who-field-error, %qN, %qF, %qW, %qA); }; &d.%qW-sort %#=revwords(%qN, |); @trigger me/tr.success=%#, Your [ulocal(f.get-friendly-who-list-name, %qW)] will now be sorted by the [if(t(%qN), column[if(gt(words(%qN, |), 1), s)] [itemize(%qN, |)], default columns)].; @force %#=[switch(%qW, room, look, object, look, n*, +who/notes, +%qW)];

&c.+who/sort [v(d.bc)]=$+who/s*:@break strmatch(%0, * *); @force %#=+who/s%0 =;

&c.+who/columns_text [v(d.bc)]=$+who/c* *:@eval strcat(setq(F, switch(%1, *=*, rest(%1, =), %1)), setq(W, edit(%1, +,)), setq(W, switch(%qW, *=*, first(%qW, =), who)), if(eq(strlen(%qW), 0), setq(W, who)), setq(F, edit(title(%qF), %b, |, _, %b))); @assert ulocal(f.is-valid-who-list, %qW)={ @trigger me/tr.error=%#, '%qW' is not a recognized destination list you can set columns for. Valid options are [itemize(ulocal(f.get-valid-who-list))].; }; @break cand(neq(words(%qF, |), 0), neq(words(setr(N, ulocal(f.get-valid-who-column, setr(A, ulocal(f.get-available-who-columns, %#)), %qF)), |), words(%qF, |)))={ @trigger me/tr.error=%#, ulocal(f.get-who-field-error, %qN, %qF, %qW, %qA); }; &d.%qW-fields %#=%qN; @trigger me/tr.success=%#, Your [ulocal(f.get-friendly-who-list-name, %qW)] will now display the [if(t(%qN), column[if(gt(words(%qN, |), 1), s)] [itemize(%qN, |)], default columns)].; @force %#=[switch(%qW, room, look, object, look, n*, +who/notes, +%qW)];

&c.+who/columns [v(d.bc)]=$+who/c*:@break strmatch(%0, * *); @force %#=+who/c%0 =;

&c.+3who [v(d.bc)]=$+3who:@pemit %#=ulocal(layout.3who, %#);

&c.+2who [v(d.bc)]=$+2who:@pemit %#=ulocal(layout.2who, %#);

&c.+who/watch [v(d.bc)]=$+who/w* *:@break strmatch(%1, *=*); @assert t(setr(P, ulocal(f.find-player, %1, %#)))={ @trigger me/tr.error=%#, Could not find a player named '%1'.; }; &friends %#=setunion(xget(%#, friends), %qP); @trigger me/tr.success=%#, moniker(%qP) has been added to your watch list.;

&c.+who/watch_note [v(d.bc)]=$+who/w* *=*:@assert t(setr(P, ulocal(f.find-player, %1, %#)))={ @trigger me/tr.error=%#, Could not find a player named '%1'.; }; &friends %#=setunion(xget(%#, friends), %qP); &d.note-%qP %#=%2; @trigger me/tr.success=%#, moniker(%qP) has been added to your watch list with the note '%2'.;

&c.+who/unwatch [v(d.bc)]=$+who/unw* *:@assert t(setr(P, ulocal(f.find-player, %1, %#)))={ @trigger me/tr.error=%#, Could not find a player named '%1'.; }; @assert member(xget(%#, friends), %qP)={ @trigger me/tr.error=%#, You aren't currently watching [moniker(%qP)].; }; &friends %#=setdiff(xget(%#, friends), %qP); @trigger me/tr.success=%#, moniker(%qP) has been removed from your watch list.;

&c.+who/hide [v(d.bc)]=$+who/h*:@break xget(%#, watch.hide)={ @trigger me/tr.error=%#, You are already set to hide from +watch.; }; &watch.hide %#=1; @trigger me/tr.success=%#, You are now hiding from +watch. People will no longer be notified when you log in and out.;

&c.+who/unhide [v(d.bc)]=$+who/unh*:@assert xget(%#, watch.hide)={ @trigger me/tr.error=%#, You are not currently set to hide from +watch.; }; &watch.hide %#=0; @trigger me/tr.success=%#, You are no longer hiding from +watch. People will now be notified when you log in and out.;

&c.+who/per [v(d.bc)]=$+who/pe* *:@assert t(setr(P, ulocal(f.find-player, %1, %#)))={ @trigger me/tr.error=%#, Could not find a player named '%1'.; }; &watchpermit %#=setunion(xget(%#, watchpermit), %qP); @trigger me/tr.success=%#, moniker(%qP) will now be allowed to see you log in%, even when you're hiding from +watch.;

&c.+who/unper [v(d.bc)]=$+who/unp* *:@assert t(setr(P, ulocal(f.find-player, %1, %#)))={ @trigger me/tr.error=%#, Could not find a player named '%1'.; }; @assert member(xget(%#, watchpermit), %qP)={ @trigger me/tr.error=%#, moniker(%qP) is not currently allowed to see when you log in while hidden.; }; &watchpermit %#=setdiff(xget(%#, watchpermit), %qP); @trigger me/tr.success=%#, moniker(%qP) will no longer be allowed to see you log in when you're hiding from +watch.;

&c.+who/note [v(d.bc)]=$+who/n* *=*:@assert t(setr(P, ulocal(f.find-player, %1, %#)))={ @trigger me/tr.error=%#, Could not find a player named '%1'.; }; &d.note-%qP %#=%2; @trigger me/tr.success=%#, Your note for [moniker(%qP)] is now '%2'.;

&c.+who/page [v(d.bc)]=$+who/page *:@assert hasattr(%#, friends)={ @trigger me/tr.error=%#, You don't have anyone on your +watch list. +watch/add <name> to add someone!; }; @eval setq(P, filter(filter.not_dark, xget(%#, friends),,, %#)); @assert t(%qP)={ @trigger me/tr.error=%#, None of your +watch friends appear to be online.; }; @dolist %qP=@force %#={ page ##=%0; };


@@ =============================================================================
@@ +watch - it's tied to +who so might as well keep it close.
@@ =============================================================================

&layout.watch [v(d.bf)]=strcat(setq(P, xget(%0, friends)), header(Your +watch list, %0), %r, multicol(strcat(edit(setr(F, ulocal(f.get-fields, %0, watch, v(d.default-watch-fields))), Doing, poll()), |, iter(%qP, ulocal(layout.who_data, itext(0), %0, %qF),, |)), ulocal(f.get-field-widths, %qF), 1, |, %0), %r, footer(+watch/del or +who/unwatch <name> to remove someone, %0))

&c.+watch [v(d.bc)]=$+watch:@assert hasattr(%#, friends)={ @trigger me/tr.error=%#, You don't have anyone on your +watch list. +watch/add to add someone!; }; @assert t(filter(filter.not_dark, xget(%#, friends),,, %#))={ @trigger me/tr.error=%#, Looks like none of your friends are on right now.; }; @pemit %#=ulocal(layout.who, %#, filter(filter.watched, ulocal(f.get-players, %#, watch),,, %#), watch, Who's online from your +watch list);

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

&layout.staff_footer [v(d.bf)]=cat(words(%0) out of, words(ulocal(f.get-staff)), staff displayed)

&layout.staff [v(d.bf)]=strcat(header(%2, %0), %r, multicol(strcat(edit(setr(F, ulocal(f.get-fields, %0, staff, v(d.default-staff-fields))), Doing, poll()), |, iter(%1, ulocal(layout.who_data, itext(0), %0, %qF),, |)), ulocal(f.get-field-widths, %qF), 1, |, %0), %r, footer(ulocal(layout.staff_footer, %1), %0))

&c.+staff [v(d.bc)]=$+staff:@pemit %#=ulocal(layout.staff, %#, filter(filter.isstaff, ulocal(f.get-players, %#, staff)), Connected staff);

&c.+staff/all [v(d.bc)]=$+staff/all:@pemit %#=ulocal(layout.staff, %#, ulocal(f.sort-players, ulocal(f.get-staff), %#, staff), All staff);

@@ =============================================================================
@@ +where
@@ =============================================================================

&layout.where_footer [v(d.bf)]=cat(setr(T, words(%0)) findable, if(cor(gt(%qT, 1), lte(%qT, 0)), people, person), out of, words(ulocal(f.get-players, %1, where)) online%, +travel <key> to join)

&layout.where [v(d.bf)]=strcat(setq(L,), null(iter(%0, setq(L, setunion(%qL, loc(itext(0)))))), setq(L, sortby(f.sort-dbref, %qL)), header(%2, %1), %r, multicol(Travel Key|Location|Players|[iter(%qL, strcat(ulocal(f.get-travel-key, itext(0)), |, name(itext(0)), |, itemize(squish(trim(iter(%0, if(member(first(itext(1)), loc(itext(0))), ulocal(f.get-name, itext(0), %1)),, |), b, |), |), |)),, |)], 10 * *, 1, |, %1), %r, footer(ulocal(layout.where_footer, %0, %1), %1))

&c.+where [v(d.bc)]=$+where:@pemit %#=ulocal(layout.where, filter(filter.not_unfindable, ulocal(f.get-players, %#, where),,, %#), %#, +where);

&c.+where_name [v(d.bc)]=$+where *:@pemit %#=ulocal(layout.where, filter(filter.name, filter(filter.not_unfindable, ulocal(f.get-players, %#, where),,, %#),,, %0), %#, +where - starting with '%0');
