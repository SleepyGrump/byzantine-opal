@@ Commands to help you build the grid, get around, etc.

/*
Notes:

+rent - here are the conditions for renting, here's how much it costs, are you sure?
+rent/ok

+buy - display costs and conditions
+buy/ok

+unrent
+unrent/ok

+sell
+sell/ok

+pay <player>=<amount>
+spend <amount>[ for <thing>]

Set the amount players earn by default
Set the amount that rents cost by default
Set the rented room desc by default and let players change it
Add ways for players to set their home to the place they have a key to.
Temprooms are accessible all over the grid.

General exits
Commercial exits
Residential exits

Residential parent, Commercial parent

Buildings expire when players stop paying for them. Players keep paying for them until they run out of money. When they run out, the building is nuked unless it is a commercial space. At that point it becomes property of staff and staff can nuke it or leave it public as they choose.

No approval is necessary to get a residential property. Unowned commercial properties need to be approved or they expire in 30 days.

Maybe reset the timer if people play in them but... meh.

Commercial: %vE
Residential: %vF

*/

@@ =============================================================================
@@ +travel
@@ =============================================================================

&f.get-travel-rooms [v(d.bf)]=search(EROOM=t(ulocal(f.get-travel-key, ##)))

&f.get-travel-rooms-matching-key [v(d.bf)]=search(EROOM=t(grab(ulocal(f.get-travel-key, ##), %0, |)))

&f.get-travel-rooms-matching-category [v(d.bf)]=case(%0, Uncategorized, search(EROOM=cand(hasattr(##, d.travel-key), not(hasattr(d.travel-categories)))), search(EROOM=t(grab(ulocal(f.get-travel-categories, ##), %0, |))))

&f.list-travel-categories [v(d.bf)]=setunion(v(d.travel.categories), Uncategorized, |)

&layout.travel_arrival [v(d.bf)]=cat(alert(+travel), moniker(%0) has arrived.)

&layout.travel_departure [v(d.bf)]=cat(alert(+travel), moniker(%0) has departed.)

&layout.travel_list [v(d.bf)]=strcat(header(Travel categories, %0), %r, multicol(ulocal(f.list-travel-categories), * * *, 0, |, %0), %r, footer(+travel <category> to see more., %0))

&layout.travel_category_list [v(d.bf)]=strcat(header(Travel destinations in the '%1' category, %0), %r, multicol(strcat(Travel Key|Location|Travel Key|Location, |, iter(ulocal(f.get-travel-rooms-matching-category, %1), strcat(ulocal(f.get-travel-key, itext(0)), |, name(itext(0))),, |)), 10 * 10 *, 1, |, %0), %r, footer(+travel <category> to see more., %0))

&c.+travel [v(d.bc)]=$+travel:@pemit %#=ulocal(layout.travel_list, %#);

&c.+travel_key_or_category [v(d.bc)]=$+travel *:@pemit #13=test-%0-[search()]-test; @break t(setr(L, ulocal(f.get-travel-rooms-matching-key, %0)))={ @trigger me/tr.travel_to_destination=%qL, %#; }; @assert t(setr(L, grab(ulocal(f.list-travel-categories), %0*, |)))={ @trigger me/tr.error=%#, Could not find a travel category like '%0'.; }; @pemit %#=ulocal(layout.travel_category_list, %#, %qL);

@@ +travel OOCROOM

&c.+travel/add [v(d.bc)]=$+travel/add *:; @trigger me/tr.success=%#, ;

@@ =============================================================================
@@ +join, +summon, +meet, etc.
@@ =============================================================================

&f.has-invited-player [v(d.bf)]=cor(isstaff(%0), lt(sub(secs(), default(%0/_invite-%2-%1, v(d.meeting-timeout))), v(d.meeting-timeout)))

@@ th ulocal(v(d.bf)/f.has-invited-player, #24, #48)
@@ th ulocal(v(d.bf)/f.has-invited-player, #48, #24)

&c.+join [v(d.bc)]=$+join *:@assert t(setr(P, ulocal(f.find-player, %0, %#)))={ @trigger me/tr.error=%#, Can't find a player named '%0'.; }; @assert ulocal(f.has-invited-player, %#, %qP, summon)={ @trigger me/tr.message=%qP, moniker(%#) would like to join you. To bring them%, type %ch+summon %N%cn. This invitation will expire in [first(secs2hrs(v(d.meeting-timeout)))].; &_invite-summon-%# %qP=secs(); @trigger me/tr.message=%#, moniker(%qP) has been issued an invitation to summon you. This invitation will expire in [first(secs2hrs(v(d.meeting-timeout)))].; }; @trigger me/tr.travel_to_destination=loc(%qP), %#;

&c.+summon [v(d.bc)]=$+summon *:@assert t(setr(P, ulocal(f.find-player, %0, %#)))={ @trigger me/tr.error=%#, Can't find a player named '%0'.; }; @assert ulocal(f.has-invited-player, %#, %qP, join)={ @trigger me/tr.message=%qP, moniker(%#) would like to summon you. To join them%, type %ch+join %N%cn. This invitation will expire in [first(secs2hrs(v(d.meeting-timeout)))].; &_invite-join-%# %qP=secs(); @trigger me/tr.message=%#, moniker(%qP) has been issued an invitation to join you. This invitation will expire in [first(secs2hrs(v(d.meeting-timeout)))].; }; @trigger me/tr.travel_to_destination=loc(%#), %qP;


@@ =============================================================================
@@ +dig
@@ =============================================================================

&f.get-exit-name [v(d.bf)]=strcat(setr(0, %0), %b, setq(0, iter(%q0, if(ulocal(f.should-word-be-capitalized, lcstr(itext(0)), inum(0)), itext(0)))), setq(0, squish(trim(%q0))), <, setr(1, iter(%q0, mid(itext(0), 0, 1),, @@)), >, ;, %q1, ;, iter(%q0, itext(0),, ;))

&f.exit-is-not-in-use [v(d.bf)]=lte(iter(lexits(%0), t(setinter(fullname(itext(0)), %, ;))), 0)

&tr.digger [v(d.go)]=@eval strcat(setq(R, create(cat(name(loc(%0)), -, %1), 10, r)), setq(A, create(%2, 10, e)), setq(B, create(xget(%vD, d.default-out-exit), 10, e))); @trigger %vC/tr.finish-room=%0, %qR, %qA, %qB;

&c.+dig [v(d.bc)]=$+dig *:@assert ulocal(f.can-build, %#)={ @trigger me/tr.error=%#, You are not authorized to build.; }; @assert valid(roomname, setr(N, title(%0)))={ @trigger me/tr.error=%#, '%qN' is not a valid room name.; }; @assert valid(exitname, setr(E, ulocal(f.get-exit-name, %qN)))={ @trigger me/tr.error=%#, '%qE' is not a valid exit name.; }; @assert ulocal(f.exit-is-not-in-use, loc(%#), %qE)={ @trigger me/tr.error=%#, One of your exit names is already in use.; }; @trigger %vB/tr.digger=%#, %qN, %qE;

&tr.finish-room [v(d.bc)]=@link %2=%1; @tel %2=loc(%0); @link %3=loc(%0); @tel %3=%1; @parent %1=parent(loc(%0)); &_exit-pair %2=%3; &_exit-pair %3=%2; @set %2=TRANSPARENT; @set %3=TRANSPARENT; @trigger me/tr.success=%0, The room '[name(%1)]' is built and ready for use.;

