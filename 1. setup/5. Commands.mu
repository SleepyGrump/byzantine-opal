
@@ =============================================================================
@@ +motd
@@ =============================================================================

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
@@ +who, +3who
@@ =============================================================================

&f.get-player-status [v(d.bf)]=if(isstaff(%0), ulocal(f.get-staffer-status, %0, %1), if(hasflag(%0, marker1), ic, ooc))

&filter.not_dark [v(d.bf)]=cor(isstaff(%1), andflags(%0, !d))

&f.get-players [v(d.bf)]=filter(filter.not_dark, lwho(),,, %0)

&f.get-location [v(d.bf)]=if(cand(hasflag(%0, unfindable), not(isstaff(%1))), Unfindable, name(loc(%0)))

&layout.who_data [v(d.bf)]=strcat(ulocal(f.get-player-status, %0, %1), |, moniker(%0), |, xget(%0, alias), |, ulocal(f.get-location, %0, %1), |, if(hasflag(%0, connected),  ulocal(f.get-doing, %0, %1)), |, ulocal(f.get-idle, %0, %1))

&layout.who [v(d.bf)]=strcat(header(Who's online, %0), %r, multicol(strcat(Status|Name|Alias|Location|[poll()]|Idle|, iter(ulocal(f.get-players), ulocal(layout.who_data, itext(0), %0),, |)), 8 * 10p * * 4, 1, |, %0), %r, footer(, %0))

&c.+who [v(d.bc)]=$+who:@pemit %#=ulocal(layout.who, %#);

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
+doing/l

&f.find-doing-by-number [v(d.bf)]=extract(lattr(%0/doing.*), %1, 1)

&f.choose-random-doing [v(d.bf)]=pickrand(lattr(%0/doing.*))

&c.+doing [v(d.bc)]=$+doing:@trigger me/tr.message=%#, The current poll is: [poll()]. Your @doing is: [doing(%#)];

&c.+doing_set [v(d.bc)]=$+doing *:@force %#=@doing %0; @wait .1=@trigger me/tr.success=%#, Your @doing is: [doing(%#)];

&c.+doing_set_random [v(d.bc)]=$+doing/r*:@assert t(lattr(%#/doing.*)); @force %#=@doing \[v(pickrand(lattr(%#/doing.*)))\]; @wait .1=@trigger me/tr.success=%#, Your randomly-chosen @doing of the day is: [doing(%#)];

&c.+doing/list [v(d.bc)]=$+doing/l*:@pemit %#=ulocal(layout.doing_list, %#);

&c.+doing/add [v(d.bc)]=$+doing/a*:@assert t(setr(D, rest(%0, if(strmatch(%0, *=*), =, %b))))={ @trigger me/tr.error=%#, Couldn't figure out what you want to add!; }; @assert valid(doing, %qD)={ @trigger me/tr.error=%#, '%qD' is not a valid @doing string.; }; @eval setq(C, inc(lmax(edit(lattr(%#/doing.*), DOING.,)))); &doing.%qC %#=%qD; @trigger me/tr.success=%#, Added a new @doing '%qD'.; @eval setq(A, setunion(xget(%#, aconnect), +doing/random, ;)); @aconnect %#=%qA;

&c.+doing/delete [v(d.bc)]=$+doing/d*:@assert cand(t(strcat(setq(N, trim(%0)), setr(N, switch(%qN, *=*, rest(%qN, =), * *, last(%qN), %qN)))), isnum(%qN))={ @trigger me/tr.error=%#, Couldn't figure out which @doing you want to delete. Got '%qN'?; }; @assert t(setr(D, ulocal(f.find-doing-by-number, %#, %qN)))={ @trigger me/tr.error=%#, Can't find a @doing at position #%qN.; }; @eval setq(O, xget(%#, %qD)); @wipe %#/%qD; @trigger me/tr.success=%#, You deleted the @doing '%qO'. This does not unset your current @doing.;

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
