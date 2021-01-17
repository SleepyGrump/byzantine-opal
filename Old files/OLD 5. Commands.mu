@@ =============================================================================
@@ +motd
@@ =============================================================================

&tr.aconnect-motd [v(d.bc)]=@pemit %0=ulocal(layout.motd, %0);

&layout.motd_string [v(d.bf)]=formattext(strcat(setq(0, ulocal(d.motd_%0)), %q0, if(t(%q0), strcat(%r%r, indent(), Set by, %b, v(d.%0_motd_set_by), %b, on, %b, timefmt($m/$d/$Y $r, v(d.%0_motd_date)).), None set.)), 1, %1)

&layout.staff_motd [v(d.bf)]=if(isstaff(%0), strcat(%r, header(Staff-only MOTD, %0), %r, ulocal(layout.motd_string, staff, %0)))

&layout.motd [v(d.bf)]=strcat(header(MOTD, %0), %r, ulocal(layout.motd_string, player, %0), ulocal(layout.staff_motd, %0), %r, footer(, %0))

&tr.error [v(d.bc)]=@pemit %0=alert(Error) %1;

&tr.success [v(d.bc)]=@pemit %0=alert(Success) %1;

&tr.message [v(d.bc)]=@pemit %0=alert(Alert) %1;

&filter.isstaff [v(d.bf)]=isstaff(%0)

&tr.motd-change [v(d.bc)]=@switch %0=player, { @wall/emit/no_prefix strcat(alert(MOTD), %b, moniker(%1) just changed the MOTD. +motd to see it.); }, { @pemit/list filter(filter.isstaff, lwho())=strcat(alert(Staff MOTD), %b, moniker(%1) just changed the staff-only MOTD. +motd to see it.); };

&c.+motd [v(d.bc)]=$+motd:@pemit %#=ulocal(layout.motd, %#);

&c.+motd/set [v(d.bc)]=$+motd* *=*:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to execute this command. }; @assert switch(%1, g*, 1, d*, 1, s*, 1, w*, 1, 0)={ @trigger me/tr.error=%#, Could not figure out what you meant by '%0 %1'.; }; &d.motd_[setr(L, if(switch(%1, g*, 1, d*, 1, s*, 0, w*, 0, 1), player, staff))] %vD=%2; &d.%qL_motd_date %vD=secs(); &d.%qL_motd_set_by %vD=moniker(%#); @trigger me/tr.motd-change=%qL, %#;

@set [v(d.bc)]/c.+motd/set=no_parse

&c.+motd/set_no_target [v(d.bc)]=$+motd* *:@break strmatch(%1, *=*); @assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to execute this command. }; &d.motd_player %vD=%1; &d.player_motd_date %vD=secs(); &d.player_motd_set_by %vD=moniker(%#); @trigger me/tr.motd-change=player, %#;

@set [v(d.bc)]/c.+motd/set_no_target=no_parse

@@ =============================================================================
@@ +who, +3who, +2who, etc.
@@ =============================================================================

&d.allowed-who-fields [v(d.bd)]=Status|Name|Alias|Location|Doing|Idle|Gender|DBref|Position|Note

&d.default-who-fields [v(d.bd)]=Status|Idle|Name|Location|Doing|Position

&d.default-watch-fields [v(d.bd)]=Status|Idle|Name|Location|Doing|Note

&d.default-notes-fields [v(d.bd)]=Status|Idle|Name|Note

&d.3who-columns [v(d.bd)]=Status|Name|Idle

&d.2who-columns [v(d.bd)]=Status|Name|Idle|Doing

&d.who-field-widths [v(d.bd)]=8 * 10p * * 4 10 5 * *

&d.who-sort-order [v(d.bd)]=Idle|Status

&f.hilite-text [v(d.bf)]=ansi(if(ulocal(filter.watched, %0, %1), first(themecolors())), %2)

&f.get-status [v(d.bf)]=ulocal(f.hilite-text, %0, %1, if(isstaff(%0), ulocal(f.get-staffer-status, %0, %1), if(hasattrp(loc(%0), OOC), ooc, ic)))

&f.get-location [v(d.bf)]=if(cand(hasflag(%0, unfindable), not(isstaff(%1))), Unfindable, name(loc(%0)))

&f.get-gender [v(d.bf)]=switch(xget(%0, sex), M*, male, F*, female, if(t(#$), non-binary, unset))

&f.get-name [v(d.bf)]=ulocal(f.hilite-text, %0, %1, moniker(%0))

&f.get-alias [v(d.bf)]=ulocal(f.hilite-text, %0, %1, alias(%0))

&f.get-dbref [v(d.bf)]=%0

&f.get-note [v(d.bf)]=xget(%1, d.note-%0)

&f.get-position [v(d.bf)]=xget(%0, position)

&f.sort-alpha [v(d.bf)]=sort(%0, ?, |, |)

&f.sort.by_idle [v(d.bf)]=strcat(setq(S, iter(%0, ulocal(f.get-idle, itext(0), %1), |, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

&f.sort.by_status [v(d.bf)]=strcat(setq(S, iter(%0, ulocal(f.get-status, itext(0), %1), |, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

&f.sort.by_name [v(d.bf)]=strcat(setq(S, iter(%0, moniker(itext(0)), |, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

&f.sort.by_alias [v(d.bf)]=strcat(setq(S, iter(%0, alias(itext(0)), |, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

&f.sort.by_location [v(d.bf)]=strcat(setq(S, iter(%0, ulocal(f.get-location, itext(0), %1), |, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

&f.sort.by_doing [v(d.bf)]=strcat(setq(S, iter(%0, doing(itext(0)),, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

&f.sort.by_gender [v(d.bf)]=strcat(setq(S, iter(%0, ulocal(f.get-gender, itext(0)), |, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

&f.sort.by_dbref [v(d.bf)]=sort(%0, d)

&f.sort.by_note [v(d.bf)]=strcat(setq(S, iter(%0, ulocal(f.get-note, itext(0), %1), |, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

&f.sort.by_position [v(d.bf)]=strcat(setq(S, iter(%0, xget(itext(0), position), |, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

&f.get-players [v(d.bf)]=strcat(setq(P, filter(filter.not_dark, lwho(),,, %0)), null(iter(ulocal(f.get-sort-order, %0), setq(P, ulocal(f.sort.by_[itext(0)], edit(%qP, %b, |), %0)), |, |)), edit(%qP, |, %b))

&f.get-fields [v(d.bf)]=strcat(setq(F,), null(iter(default(%0/who-fields, %1), if(member(v(d.allowed-who-fields), itext(0), |), setq(F, strcat(%qF, |, itext(0)))), |)), trim(squish(%qF, |), b, |))

&f.get-field-widths [v(d.bf)]=iter(%0, extract(v(d.who-field-widths), member(v(d.allowed-who-fields), itext(0), |), 1), |)

&f.get-sort-order [v(d.bf)]=strcat(setq(S,), null(iter(default(%0/who-sort, v(d.who-sort-order)), if(member(v(d.allowed-who-fields), itext(0), |), setq(S, %qS|[itext(0)])), |)), setq(S, trim(%qS, b, |)), %qS)

&f.get-unique-count [v(d.bf)]=strcat(setq(0, 0), setq(1,), null(iter(%0, if(member(%q1, setr(2, xget(itext(0), lastip)), |),, strcat(setq(0, add(%q0, 1)), setq(1, setunion(%q1, %q2, |)))))), %q0)

&layout.who_data [v(d.bf)]=iter(%2, ulocal(f.get-[itext(0)], %0, %1), |, |)

&layout.who_footer [v(d.bf)]=cat(words(%0), connected, /, ulocal(f.get-unique-count, %0), unique, /, connrecord(), record)

&layout.who [v(d.bf)]=strcat(setq(P, ulocal(f.get-players, %0)), if(t(%1), setq(P, filter(filter.name, %qP,,, %1))), if(t(%2), setq(P, filter(filter.watched, %qP,,, %0))), header(strcat(Who's online,  if(t(%1), %bnamed '%1'),  if(t(%2), %bfrom your +watch list)), %0), %r,multicol(strcat(edit(setr(F, ulocal(f.get-fields, %0, v(d.default-[if(t(%2), %2, who)]-fields))), Doing, poll()), |, iter(%qP, ulocal(layout.who_data, itext(0), %0, %qF),, |)), ulocal(f.get-field-widths, %qF), 1, |, %0), %r, footer(ulocal(layout.who_footer, %qP), %0))

&layout.3who [v(d.bf)]=strcat(setq(C, edit(setr(F, v(d.3who-columns)), Doing, poll())), header(Who's online - 3who, %0), %r, multicol(strcat(%qC|%qC|%qC, |, iter(setr(P, ulocal(f.get-players, %0)), ulocal(layout.who_data, itext(0), %0, %qF),, |)), setr(W, ulocal(f.get-field-widths, %qF)) %qW %qW, 1, |, %0), %r, footer(ulocal(layout.who_footer, %qP), %0))

&layout.2who [v(d.bf)]=strcat(setq(C, edit(setr(F, v(d.2who-columns)), Doing, poll())), header(Who's online - 2who, %0), %r, multicol(strcat(%qC|%qC, |, iter(setr(P, ulocal(f.get-players, %0)), ulocal(layout.who_data, itext(0), %0, %qF),, |)), setr(W, ulocal(f.get-field-widths, %qF)) %qW, 1, |, %0), %r, footer(ulocal(layout.who_footer, %qP), %0))

&c.+who [v(d.bc)]=$+who:@pemit %#=ulocal(layout.who, %#);

&c.+who_name [v(d.bc)]=$+who *:@pemit %#=ulocal(layout.who, %#, %0);

&c.+who/notes [v(d.bc)]=$+who/n*:@break strmatch(%0, *=*); @pemit %#=ulocal(layout.who, %#,, notes);

&c.+who/sort [v(d.bc)]=$+who/sort *:@break t(setr(N, setdiff(v(d.allowed-who-fields), edit(%0, %b, |), |)))={ @trigger me/tr.error=%#, strcat(The field, if(gt(%qN, 1), s), ', itemize(%qN, |), ', if(gt(%qN, 1), are, is), %b, not allowed on the +who sort list.); }; &who-sort %#=edit(%0, %b, |); @trigger me/tr.success=%#, Your +who will now be sorted by [itemize(%0)].; @pemit %#=ulocal(layout.who, %#);

&c.+who/columns [v(d.bc)]=$+who/c*:@break t(setr(N, setdiff(edit(title(rest(%0)), %b, |), v(d.allowed-who-fields), |)))={ @trigger me/tr.error=%#, strcat(The field, if(gt(%qN, 1), s), ', itemize(%qN, |), ', if(gt(%qN, 1), are, is), %b, not allowed on the +who list.); }; &who-fields %#=edit(title(rest(%0)), %b, |); @trigger me/tr.success=%#, Your +who will now display the [if(t(rest(%0)), columns [itemize(title(rest(%0)))], default columns)].; @pemit %#=ulocal(layout.who, %#);

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

&c.+watch [v(d.bc)]=$+watch:@assert hasattr(%#, friends)={ @trigger me/tr.error=%#, You don't have anyone on your +watch list. +watch/add to add someone!; }; @assert t(filter(filter.not_dark, xget(%#, friends),,, %#))={ @trigger me/tr.error=%#, Looks like none of your friends are on right now.; }; @pemit %#=ulocal(layout.who, %#,, watch);

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

@@ %0: watcher
@@ %1: target
&filter.watch_on [v(d.bf)]=not(t(default(%0/watch.off, 0)))

&filter.watching_target [v(d.bf)]=cor(default(%0/watch.all.on, 0), t(member(default(%0/friends, 0), %1)))

&filter.allowed_to_watch_target [v(d.bf)]=cor(isstaff(%0), cand(default(%1/watch.hide, 0), t(member(default(%1/watchpermit, 0), %0))), not(default(%1/watch.hide, 0)))

&f.people_to_notify [v(d.bf)]=strcat(setq(P, lwho()), setq(P, filter(filter.watching_target, %qP,,, %0)), setq(P, filter(filter.allowed_to_watch_target, %qP,,, %0)), setq(P, filter(filter.watch_on, %qP)), %qP)

&layout.watch-connect [v(d.bf)]=udefault(%0/watchfmt, cat(alert(prettytime()), moniker(%1), has connected.), %1, connected)

&layout.watch-disconnect [v(d.bf)]=udefault(%0/watchfmt, cat(alert(prettytime()), moniker(%1), has disconnected.), %1, disconnected)

&tr.aconnect-watch [v(d.bc)]=@dolist ulocal(f.people_to_notify, %0)={ @pemit ##=ulocal(layout.watch-connect, ##, %0); @trigger/quiet ##/awatch=[moniker(%0)], connected; };

&tr.adisconnect-watch [v(d.bc)]=@dolist ulocal(f.people_to_notify, %0)={ @pemit ##=ulocal(layout.watch-disconnect, ##, %0); @trigger/quiet ##/awatch=[moniker(%0)], disconnected; };

@@ =============================================================================
@@ +staff
@@ =============================================================================

&f.get-staffer-status [v(d.bf)]=if(cand(isstaff(%1), andflags(%0, Dc)), dark, if(andflags(%0, Dc), offline, if(hasflag(%0, connected), if(hasflag(%0, transparent), ansi(first(themecolors()), ON DUTY), off duty), if(hasflag(%0, vacation), vacation, offline))))

&f.get-staff [v(d.bf)]=v(d.staff_list)

&f.get-idle [v(d.bf)]=if(cand(not(isstaff(%1)), hasflag(%0, dark)), -, secs2hrs(idle(%0)))

&f.get-doing [v(d.bf)]=if(cand(not(isstaff(%1)), hasflag(%0, dark)),, doing(%0))

&layout.staff_data [v(d.bf)]=strcat(ulocal(f.get-staffer-status, %0, %1), |, moniker(%0), |, xget(%0, alias), |, xget(%0, position), |, if(hasflag(%0, connected), ulocal(f.get-doing, %0, %1)), |, ulocal(f.get-idle, %0, %1))

&layout.staff [v(d.bf)]=strcat(header(All staff, %0), %r, multicol(strcat(Status|Name|Alias|Position|[poll()]|Idle|, iter(ulocal(f.get-staff), ulocal(layout.staff_data, itext(0), %0),, |)), 8 * 10p * * 4, 1, |, %0), %r, footer(, %0))

&c.+staff [v(d.bc)]=$+staff:@pemit %#=ulocal(layout.staff, %#);

&c.+staff/all [v(d.bc)]=$+staff/all:@pemit %#=ulocal(layout.staff, %#);

&c.+staff/add [v(d.bc)]=$+staff/add *:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to add staffers.; }; @assert t(setr(P, switch(%0, me, %#, pmatch(%0))))={ @trigger me/tr.error=%#, Could not find the player '%0'.; }; @break member(v(d.staff_list), %qP)={ @trigger me/tr.error=%#, moniker(%qP) is already on the staff list.; };  &d.staff_list %vD=setunion(v(d.staff_list), %qP); @trigger me/tr.success=%#, You have added [moniker(%qP)] to the staff list.;

&c.+staff/del [v(d.bc)]=$+staff/* *:@break strmatch(%0, a*); @assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to add staffers.; }; @assert t(setr(P, switch(%0, me, %#, pmatch(%1))))={ @trigger me/tr.error=%#, Could not find the staffer '%1'.; }; @assert member(v(d.staff_list), %qP)={ @trigger me/tr.error=%#, moniker(%qP) is not currently on the staff list.; }; &d.staff_list %vD=setdiff(v(d.staff_list), %qP); @moniker %qP=; @trigger me/tr.success=%#, You have removed [moniker(%qP)] from the staff list. [if(hasflag(%qP, wizard), Remember to use #1 to take away their wizard powers.)];

&c.+duty [v(d.bc)]=$+duty:@assert isstaff(%#)={ @trigger me/tr.error=%#, This command only matters for staffers.; }; @set %#=[if(hasflag(%#, transparent), !)]transparent; @trigger me/tr.success=%#, You have set yourself [if(hasflag(%#, transparent), on, off)] duty.;

&c.+dark [v(d.bc)]=$+dark:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to use this command.; }; @set %#=[if(hasflag(%#, dark), !)]dark; @trigger me/tr.success=%#, You have set yourself [if(hasflag(%#, dark), dark, visible)].;

@@ =============================================================================
@@ +doing - aliases for @doing, @poll, etc.
@@ =============================================================================

&layout.doing_list [v(d.bf)]=strcat(header(Your @doing list, %0), %r, multicol(iter(lattr(%0/doing.*), strcat(inum(0)., |, xget(%0, itext(0))),, |), 3 *,, |), %r, footer(+doing/add <text> or +doing/del <number>, %0))

&f.find-doing-by-number [v(d.bf)]=extract(lattr(%0/doing.*), %1, 1)

&f.choose-random-doing [v(d.bf)]=pickrand(lattr(%0/doing.*))

&c.+doing [v(d.bc)]=$+doing:@trigger me/tr.message=%#, The current poll is: [poll()]. Your @doing is: [doing(%#)];

&c.+doing_set [v(d.bc)]=$+doing *:@force %#=@doing %0; @wait .1=@trigger me/tr.success=%#, Your @doing is: [doing(%#)];

&c.+doing_set_random [v(d.bc)]=$+doing/r*:@assert t(lattr(%#/doing.*)); @force %#=@doing \[v(pickrand(lattr(%#/doing.*)))\]; @wait .1=@trigger me/tr.success=%#, Your randomly-chosen @doing of the day is: [doing(%#)];

&c.+doing/list [v(d.bc)]=$+doing/l*:@pemit %#=ulocal(layout.doing_list, %#);

&c.+doing/add [v(d.bc)]=$+doing/a*:@assert t(setr(D, rest(%0, if(strmatch(%0, *=*), =, %b))))={ @trigger me/tr.error=%#, Couldn't figure out what you want to add!; }; @assert valid(doing, %qD)={ @trigger me/tr.error=%#, '%qD' is not a valid @doing string.; }; @eval setq(C, inc(lmax(edit(lattr(%#/doing.*), DOING.,)))); &doing.%qC %#=%qD; @trigger me/tr.success=%#, Added a new @doing '%qD'. Your @doing will be automatically set to a random one from your list every time you connect.; @eval setq(A, setunion(xget(%#, aconnect), +doing/random, ;)); @aconnect %#=%qA;

&c.+doing/delete [v(d.bc)]=$+doing/d*:@assert cand(t(strcat(setq(N, trim(%0)), setr(N, switch(%qN, *=*, rest(%qN, =), * *, last(%qN), %qN)))), isnum(%qN))={ @trigger me/tr.error=%#, Couldn't figure out which @doing you want to delete. Got '%qN'?; }; @assert t(setr(D, ulocal(f.find-doing-by-number, %#, %qN)))={ @trigger me/tr.error=%#, Can't find a @doing at position #%qN.; }; @eval setq(O, xget(%#, %qD)); @wipe %#/%qD; @trigger me/tr.success=%#, You deleted the @doing '%qO'. This does not unset your current @doing.;

&c.+doing/remove [v(d.bc)]=$+doing/r* *:@force %#=+doing/delete %1;

&c.+doing/poll [v(d.bc)]=$+doing/poll *:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to set the poll.; }; @doing/header %0; @wall/emit/no_prefix strcat(alert(Poll), %b, moniker(%#) just changed the poll to:, %b, poll(), %b, +help Poll for more info.);

@@ =============================================================================
@@ +selfboot
@@ =============================================================================

&c.+selfboot [v(d.bc)]=$+selfboot:@assert gt(words(ports(%#)), 1)={ @trigger me/tr.error=%#, You don't have any frozen connections to boot.; }; @dolist rest(ports(%#))=@boot/port ##; @trigger me/tr.success=%#, You booted your frozen connections.;

@@ =============================================================================
@@ +view
@@ =============================================================================

&layout.view_list [v(d.bf)]=strcat(alert(Views), %b, if(t(%0), strcat(The following view, if(gt(words(%0), 1), s are, is), %b, available here:, %b, itemize(%0)), There are no views available in your current location.))

&c.+view [v(d.bc)]=$+view:

@@ =============================================================================
@@ @gender, an alias for @sex
@@ =============================================================================

&c.@gender [v(d.bc)]=$@gender *:@force %#=@sex me=%0;

