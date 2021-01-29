@@ Commands related to running the game, only usable by staffers.

@@ =============================================================================
@@ +staff/add, +staff/del, +duty, +dark
@@ =============================================================================

&c.+staff/add [v(d.bc)]=$+staff/add *:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to add staffers.; }; @assert t(setr(P, ulocal(f.find-player, %0, %#)))={ @trigger me/tr.error=%#, Could not find the player '%0'.; }; @break member(v(d.staff_list), %qP)={ @trigger me/tr.error=%#, moniker(%qP) is already on the staff list.; };  &d.staff_list %vD=setunion(v(d.staff_list), %qP); @trigger me/tr.success=%#, You have added [moniker(%qP)] to the staff list.;

&c.+staff/del [v(d.bc)]=$+staff/* *:@break strmatch(%0, a*); @assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to add staffers.; }; @assert t(setr(P, ulocal(f.find-player, %0, %#)))={ @trigger me/tr.error=%#, Could not find the staffer '%1'.; }; @assert member(v(d.staff_list), %qP)={ @trigger me/tr.error=%#, moniker(%qP) is not currently on the staff list.; }; @moniker %qP=[name(%qP)]; &d.staff_list %vD=setdiff(v(d.staff_list), %qP); @trigger me/tr.success=%#, You have removed [moniker(%qP)] from the staff list. [if(hasflag(%qP, wizard), Remember to use #1 to take away their wizard powers.)];

&c.+duty [v(d.bc)]=$+duty:@assert isstaff(%#)={ @trigger me/tr.error=%#, This command only matters for staffers.; }; @set %#=[if(hasflag(%#, transparent), !)]transparent; @trigger me/tr.success=%#, You have set yourself [if(hasflag(%#, transparent), on, off)] duty.;

&c.+dark [v(d.bc)]=$+dark:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to use this command.; }; @set %#=[if(hasflag(%#, dark), !)]dark; @trigger me/tr.success=%#, You have set yourself [if(hasflag(%#, dark), dark, visible)].;

&c.+staffnote [v(d.bc)]=$+staffnote *=*:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to use this command.; }; @assert t(setr(P, ulocal(f.find-player, %0, %#)))={ @trigger me/tr.error=%#, Could not find a player named '%0'.; }; &_d.staff-notes %qP=%1; @trigger me/tr.success=%#, moniker(%qP)'s staff note now reads: %1;
