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

&layout.travel_list [v(d.bf)]=strcat(header(Travel categories, %0), %r, multicol(ulocal(f.list-travel-categories), * * *, 0, |, %0), %r, footer(+travel <category> to see more., %0))

&layout.travel_category_list [v(d.bf)]=strcat(header(Travel destinations in the '%1' category, %0), %r, multicol(strcat(Travel Key|Location|Travel Key|Location, |, iter(ulocal(f.get-travel-rooms-matching-category, %1), strcat(ulocal(f.get-travel-key, itext(0)), |, name(itext(0))),, |)), 10 * 10 *, 1, |, %0), %r, footer(+travel <category> to see more., %0))

&c.+travel [v(d.bc)]=$+travel:@pemit %#=ulocal(layout.travel_list, %#);

&c.+travel_key_or_category [v(d.bc)]=$+travel *:@break t(setr(L, ulocal(f.get-travel-rooms-matching-key, %0)))={ @trigger me/tr.travel_to_destination=%qL, %#; }; @assert t(setr(L, grab(ulocal(f.list-travel-categories), %0*, |)))={ @trigger me/tr.error=%#, Could not find a travel category like '%0'.; }; @pemit %#=ulocal(layout.travel_category_list, %#, %qL);

@@ +travel OOCROOM

&c.+travel/add [v(d.bc)]=$+travel/add *:; @trigger me/tr.success=%#, ;

@@ =============================================================================
@@ +join, +summon, +meet, etc.
@@ =============================================================================

@@ %0: summoner
@@ %1: summonee
@@ %2: type of summons
&f.has-invited-player [v(d.bf)]=cor(isstaff(%0), lt(sub(secs(), default(%0/_invite-%2-%1, v(d.meeting-timeout))), v(d.meeting-timeout)))

@@ %0: person summoning/joining.
@@ %1: person being summoned/joined.
@@ %2: the action itself, summon or join.
@@ %3: the destination.

@@ TODO: Make sure this doesn't expose unfindable people.
&layout.join_summon_invite [v(d.bf)]=strcat(moniker(%0) would like to %2 you to, %b, ansi(h, name(%3)). To, %b, switch(%2, join, bring, join), %b, them%, type %ch+, ansi(h, switch(%2, join, summon, join)), %b, ansi(h, name(%0)), . It is [prettytime()] and this invitation will expire in [first(secs2hrs(v(d.meeting-timeout)))]. [if(cand(not(ulocal(lock.allowed_ic, %0)), not(ulocal(f.is-location-ooc, %3))), cat(Warning: this player is not yet approved and you are bringing, obj(%0), to an IC location.))])

&layout.join_summon_invite_sent [v(d.bf)]=strcat(moniker(%0) has been issued an invitation to %2 you, %b, switch(%2, summon, to, in), %b, ansi(h, name(%3)), . It is [prettytime()] and this invitation will expire in [first(secs2hrs(v(d.meeting-timeout)))]. [if(cand(not(ulocal(lock.allowed_ic, %0)), not(ulocal(f.is-location-ooc, %3))), You are not yet approved and may be heading into an IC location.)])

&c.+join [v(d.bc)]=$+join *:@assert t(setr(P, ulocal(f.find-player, %0, %#)))={ @trigger me/tr.error=%#, Can't find a player named '%0'.; }; @break match(%qP, %#)={ @trigger me/tr.error=%#, You can't join yourself.; }; @break match(loc(%qP), %l)={ @trigger me/tr.error=%#, cat(You are already at, ulocal(f.get-name, %qP)'s location.); }; @assert cor(ulocal(lock.allowed_ic, %#), ulocal(f.is-location-ooc, loc(%qP)), ulocal(lock.isstaff, %qP))={ @trigger me/tr.error=%#, You are not approved so can't use +join to go IC. Try asking a staffer to bring you - they can override this rule - or meet your friend somewhere OOC.; }; @assert ulocal(f.has-invited-player, %#, %qP, join)={ @trigger me/tr.message=%qP, ulocal(layout.join_summon_invite, %#, %qP, join, loc(%qP)); &_invite-summon-%# %qP=secs(); @trigger me/tr.message=%#, ulocal(layout.join_summon_invite_sent, %qP, %#, summon, loc(%qP)); }; @trigger me/tr.travel_to_destination=loc(%qP), %#, %qP, joining;

&c.+return [v(d.bc)]=$+return *:@assert t(setr(P, ulocal(f.find-player, %0, %#)))={ @trigger me/tr.error=%#, Can't find a player named '%0'.; }; @break match(%qP, %#)={ @break match(default(%qP/_last-location, v(d.default-ooc-room)), %l)={ @trigger me/tr.error=%#, You are already at the destination.; }; @trigger me/tr.travel_to_destination=default(%qP/_last-location, v(d.default-ooc-room)), %qP; }; @break match(default(%qP/_last-location, v(d.default-ooc-room)), %l)={ @trigger me/tr.error=%#, ulocal(f.get-name, %qP) is already at the destination.; };  @assert isstaff(%#)={ @trigger me/tr.message=%#, Only staff can send other players back.; }; @trigger me/tr.travel_to_destination=default(%qP/_last-location, v(d.default-ooc-room)), %qP, %#, returned by;

&c.+summon [v(d.bc)]=$+summon *:@assert t(setr(P, ulocal(f.find-player, %0, %#)))={ @trigger me/tr.error=%#, Can't find a player named '%0'.; }; @break match(%qP, %#)={ @trigger me/tr.error=%#, You can't summon yourself.; }; @break match(loc(%qP), %l)={ @trigger me/tr.error=%#, ulocal(f.get-name, %qP) is already at the destination.; }; @assert cor(ulocal(lock.allowed_ic, %qP), ulocal(f.is-location-ooc, %l), ulocal(lock.isstaff, %#))={ @trigger me/tr.error=%#, You are not approved so can't use +summon to bring unapproved players IC. Try asking a staffer to bring them - they can override this rule - or meet your friend somewhere OOC.; }; @assert ulocal(f.has-invited-player, %#, %qP, summon)={ @trigger me/tr.message=%qP, ulocal(layout.join_summon_invite, %#, %qP, summon, %l); &_invite-join-%# %qP=secs(); @trigger me/tr.message=%#, ulocal(layout.join_summon_invite_sent, %qP, %#, join, %l); }; @trigger me/tr.travel_to_destination=%l, %qP, %#, summoned by;

&c.+ooc [v(d.bc)]=$+ooc:@trigger me/tr.travel_to_destination=default(%#/_last-ooc-location, v(d.default-ooc-room)), %#;

&c.+ic [v(d.bc)]=$+ic:@trigger me/tr.travel_to_destination=default(%#/_last-ic-location, v(d.default-ic-room)), %#;



@@ =============================================================================
@@ +dig
@@ =============================================================================

&f.get-exit-name [v(d.bf)]=strcat(setr(0, %0), %b, setq(0, iter(%q0, if(ulocal(f.should-word-be-capitalized, lcstr(itext(0)), inum(0)), itext(0)))), setq(0, squish(trim(%q0))), <, setr(1, iter(%q0, mid(itext(0), 0, 1),, @@)), >, ;, %q1, ;, iter(%q0, itext(0),, ;))

&f.exit-is-not-in-use [v(d.bf)]=lte(iter(lexits(%0), t(setinter(fullname(itext(0)), %, ;))), 0)

&tr.digger [v(d.go)]=@eval strcat(setq(R, create(cat(name(loc(%0)), -, %1), 10, r)), setq(A, create(%2, 10, e)), setq(B, create(xget(%vD, d.default-out-exit), 10, e))); @trigger %vC/tr.finish-room=%0, %qR, %qA, %qB;

&c.+dig [v(d.bc)]=$+dig *:@assert ulocal(f.can-build, %#)={ @trigger me/tr.error=%#, You are not authorized to build.; }; @assert valid(roomname, setr(N, title(%0)))={ @trigger me/tr.error=%#, '%qN' is not a valid room name.; }; @assert valid(exitname, setr(E, ulocal(f.get-exit-name, %qN)))={ @trigger me/tr.error=%#, '%qE' is not a valid exit name.; }; @assert ulocal(f.exit-is-not-in-use, loc(%#), %qE)={ @trigger me/tr.error=%#, One of your exit names is already in use.; }; @trigger %vB/tr.digger=%#, %qN, %qE;

&tr.finish-room [v(d.bc)]=@link %2=%1; @tel %2=loc(%0); @link %3=loc(%0); @tel %3=%1; @parent %1=parent(loc(%0)); &_exit-pair %2=%3; &_exit-pair %3=%2; @set %2=TRANSPARENT; @set %3=TRANSPARENT; @trigger me/tr.success=%0, The room '[name(%1)]' is built and ready for use.;

