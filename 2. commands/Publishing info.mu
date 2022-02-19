@@ Commands related to handing out information - +motd, etc.

@@ =============================================================================
@@ +motd
@@ =============================================================================

&tr.aconnect-motd [v(d.bc)]=@pemit %0=ulocal(layout.motd, %0);

&tr.error [v(d.bc)]=@pemit %0=alert(Error) %1;

&tr.success [v(d.bc)]=@pemit %0=alert(Success) %1;

&tr.message [v(d.bc)]=@pemit %0=alert(Alert) %1;

&tr.motd-change [v(d.bc)]=@switch %0=player, { @wall/emit/no_prefix strcat(alert(MOTD), %b, moniker(%1) just changed the MOTD. +motd to see it.); }, { @pemit/list filter(filter.isstaff, lwho())=strcat(alert(Staff MOTD), %b, moniker(%1) just changed the staff-only MOTD. +motd to see it.); };

&layout.motd_string [v(d.bf)]=formattext(strcat(setq(0, ulocal(d.motd_%0)), %q0, if(t(%q0), strcat(%r%r, indent(), Set by, %b, v(d.%0_motd_set_by), %b, on, %b, timefmt($m/$d/$Y $r, v(d.%0_motd_date)).), None set.)), 1, %1)

&layout.staff_motd [v(d.bf)]=if(isstaff(%0), strcat(%r, header(Staff-only MOTD, %0), %r, ulocal(layout.motd_string, staff, %0)))

&layout.motd [v(d.bf)]=strcat(header(MOTD, %0), %r, ulocal(layout.motd_string, player, %0), ulocal(layout.staff_motd, %0), %r, footer(, %0))

&c.+motd [v(d.bc)]=$+motd:@pemit %#=ulocal(layout.motd, %#);

&c.+motd/set [v(d.bc)]=$+motd* *=*:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to execute this command. }; @assert switch(%1, g*, 1, d*, 1, s*, 1, w*, 1, 0)={ @trigger me/tr.error=%#, Could not figure out what you meant by '%0 %1'.; }; &d.motd_[setr(L, if(switch(%1, g*, 1, d*, 1, s*, 0, w*, 0, 1), player, staff))] %vD=%2; &d.%qL_motd_date %vD=secs(); &d.%qL_motd_set_by %vD=moniker(%#); @trigger me/tr.motd-change=%qL, %#;

@set [v(d.bc)]/c.+motd/set=no_parse

&c.+motd/set_no_target [v(d.bc)]=$+motd* *:@break strmatch(%1, *=*); @assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to execute this command. }; &d.motd_player %vD=%1; &d.player_motd_date %vD=secs(); &d.player_motd_set_by %vD=moniker(%#); @trigger me/tr.motd-change=player, %#;

@set [v(d.bc)]/c.+motd/set_no_target=no_parse

@@ TODO: Set it up so that MOTD can be randomly selected from a LIST of MOTDs, because honestly I just use it for a pun or joke most of the time. Make sure that random cooperates with static. Do not announce randoms? Or do? Hm. Also do we want *random* or do we want iterative?

@@ =============================================================================
@@ +glance
@@ =============================================================================

&layout.glance_line [v(d.bf)]=strcat(moniker(%0), |, first(secs2hrs(idle(%0))), |, shortdesc(%0, %1))

&layout.glance [v(d.bf)]=strcat(setq(P, filter(filter.is_connected_player, lcon(loc(%0)))), setq(O, filter(filter.isobject, lcon(loc(%0)))), header(At a glance..., %0), %r, formattext(shortdesc(loc(%0)), 0, %0), %r, divider(People and things present..., %0), %r, multicol(iter(%qP %qO, ulocal(layout.glance_line, itext(0), %0),, |), 20 4 *, 0, |, %0), %r, footer(l <name> for more, %0))

&c.+glance [v(d.bc)]=$+glance:@pemit %#=ulocal(layout.glance, %#);
