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

&f.list-travel-categories [v(d.bf)]=unionset(v(d.travel.categories), Uncategorized, |)

&layout.travel_list [v(d.bf)]=strcat(header(Travel categories, %0), %r, multicol(ulocal(f.list-travel-categories), * * *, 0, |, %0), %r, footer(+travel <category> to see more., %0))

&layout.travel_category_list [v(d.bf)]=strcat(header(Travel destinations in the '%1' category, %0), %r, multicol(strcat(Travel Key|Location|Travel Key|Location, |, iter(ulocal(f.get-travel-rooms-matching-category, %1), strcat(ulocal(f.get-travel-key, itext(0)), |, name(itext(0))),, |)), 10 * 10 *, 1, |, %0), %r, footer(+travel <category> to see more., %0))

&c.+travel [v(d.bc)]=$+travel:@pemit %#=ulocal(layout.travel_list, %#);

&c.+travel_key_or_category [v(d.bc)]=$+travel *:@break t(setr(L, ulocal(f.get-travel-rooms-matching-key, %0)))={ @trigger me/tr.travel_to_destination=%qL, %#; }; @assert t(setr(L, finditem(ulocal(f.list-travel-categories), %0*, |)))={ @trigger me/tr.error=%#, Could not find a travel category like '%0'.; }; @pemit %#=ulocal(layout.travel_category_list, %#, %qL);

&c.+travel/add [v(d.bc)]=$+travel/add *:@assert t(switch(%0, here=*, setr(R, loc(%#)), *=*, setr(R, first(%0, =)), setr(R, loc(%#))))={ @trigger me/tr.error=%#, Could not figure out what room you're referring to. '%qR' doesn't make sense.; }; @assert cor(isdbref(%qR), t(setr(R, search(ROOMS=%qR))))={ @trigger me/tr.error=%#, Could not find a room named '%qR'.; }; @assert eq(words(%qR), 1)={ @trigger me/tr.error=%#, More than one room matches '[first(%0, =)]'.; }; @assert ulocal(filter.is_owner, %qR, %#)={ @trigger me/tr.error=%#, You must be an owner of [name(%qR)] to change the travel code.; }; @eval setq(K, switch(%0, *=*, rest(%0, =), %0)); @eval setq(O, ulocal(f.get-travel-key, %qR)); @break strmatch(%qK, %qO)={ @trigger me/tr.error=%#, The travel key for [name(%qR)] is already '%qK'.; }; @assert cor(not(hasattr(%qR, d.travel-key)), gettimer(%#, replace-travel-key, %qK))={ @trigger me/tr.message=%#, You are about to change the travel key for [name(%qR)] from %qO to '%qK'. Are you sure? If yes%, type %ch+travel/add %0%cn again within the next 10 minutes. The time is now [prettytime()].; @eval settimer(%#, replace-travel-key, 600, %qK); }; @set %qR=d.travel-key:%qK; @trigger me/tr.success=%#, You set the travel key for [name(%qR)] to '%qK'.; @trigger me/tr.log=%qR, _ownerlog-, %#, Added to +travel with key '%qK'.;

&c.+travel/rem [v(d.bc)]=$+travel/rem*:@break switch(%0, c*, 1, *=*, 1, 0); @assert t(switch(trim(%0), * here, setr(R, loc(%#)), here, setr(R, loc(%#)), * *, setr(R, rest(%0)), if(t(trim(%0)), setr(R, trim(%0)), setr(R, loc(%#)))))={ @trigger me/tr.error=%#, Could not figure out what room you're referring to. '%0' doesn't make sense.; }; @pemit %#=%qR?; @eval setq(N, %qR); @assert cor(isdbref(%qR), t(setr(R, search(ROOMS=%qR))))={ @trigger me/tr.error=%#, Could not find a room named '%qN'.; }; @assert eq(words(%qR), 1)={ @trigger me/tr.error=%#, More than one room matches '%qN'.; }; @assert ulocal(filter.is_owner, %qR, %#)={ @trigger me/tr.error=%#, You must be an owner of [name(%qR)] to change the travel code.; }; @eval setq(O, ulocal(f.get-travel-key, %qR)); @assert t(%qO)={ @trigger me/tr.error=%#, [name(%qR)] is not set up for travel.; }; @assert gettimer(%#, remove-travel-key, %qO)={ @trigger me/tr.message=%#, You are about to remove the travel key from [name(%qR)]. Players will no longer be able to  +travel %qO. Are you sure? If yes%, type %ch+travel/rem%0%cn again within the next 10 minutes. The time is now [prettytime()].; @eval settimer(%#, remove-travel-key, 600, %qO); }; @set %qR=d.travel-key:; @trigger me/tr.success=%#, You remove the travel key from [name(%qR)].; @trigger me/tr.log=%qR, _ownerlog-, %#, Removed from +travel.;

&c.+travel/cat [v(d.bc)]=$+travel/cat *:@assert t(switch(%0, here=*, setr(R, loc(%#)), *=*, setr(R, first(%0, =)), setr(R, loc(%#))))={ @trigger me/tr.error=%#, Could not figure out what room you're referring to. '%qR' doesn't make sense.; }; @assert cor(isdbref(%qR), t(setr(R, search(ROOMS=%qR))))={ @trigger me/tr.error=%#, Could not find a room named '%qR'.; }; @assert eq(words(%qR), 1)={ @trigger me/tr.error=%#, More than one room matches '[first(%0, =)]'.; }; @assert ulocal(filter.is_owner, %qR, %#)={ @trigger me/tr.error=%#, You must be an owner of [name(%qR)] to change the travel categories.; }; @eval setr(N, setr(K, switch(%0, *=*, rest(%0, =), %0))); @eval setq(O, ulocal(f.get-travel-categories, %qR)); @assert t(setr(K, finditem(setr(L, xget(%vD, d.travel.categories)), %qK, |)))={ @trigger me/tr.error=%#, Couldn't find an existing travel category matching '%qN'. Allowable categories are [ulocal(layout.list, %qL)].; }; @break strmatch(%qK, %qO)={ @trigger me/tr.error=%#, The travel category for [name(%qR)] is already '%qK'.; }; @assert cor(not(hasattr(%qR, d.travel-categories)), gettimer(%#, replace-travel-categories, %qK))={ @trigger me/tr.message=%#, You are about to change the travel category for [name(%qR)] from %qO to '%qK'. Are you sure? If yes%, type %ch+travel/cat %0%cn again within the next 10 minutes. The time is now [prettytime()].; @eval settimer(%#, replace-travel-categories, 600, %qK); }; @set %qR=d.travel-categories:%qK; @trigger me/tr.success=%#, You set the travel category for [name(%qR)] to '%qK'.; @trigger me/tr.log=%qR, _ownerlog-, %#, Travel category set to '%qK'.;

&c.+travel/addcat [v(d.bc)]=$+travel/addcat *:@break cand(not(strmatch(%0, *=*)), isstaff(%#)); @assert t(switch(%0, here=*, setr(R, loc(%#)), *=*, setr(R, first(%0, =)), setr(R, loc(%#))))={ @trigger me/tr.error=%#, Could not figure out what room you're referring to. '%qR' doesn't make sense.; }; @assert cor(isdbref(%qR), t(setr(R, search(ROOMS=%qR))))={ @trigger me/tr.error=%#, Could not find a room named '%qR'.; }; @assert eq(words(%qR), 1)={ @trigger me/tr.error=%#, More than one room matches '[first(%0, =)]'.; }; @assert ulocal(filter.is_owner, %qR, %#)={ @trigger me/tr.error=%#, You must be an owner of [name(%qR)] to change the travel categories.; }; @eval setr(N, setr(K, switch(%0, *=*, rest(%0, =), %0))); @eval setq(O, ulocal(f.get-travel-categories, %qR)); @assert t(setr(K, finditem(setr(L, xget(%vD, d.travel.categories)), %qK, |)))={ @trigger me/tr.error=%#, Couldn't find an existing travel category matching '%qN'. Allowable categories are [ulocal(layout.list, %qL)].; }; @break t(grab(%qO, %qK, |))={ @trigger me/tr.error=%#, [name(%qR)] is already in the '%qK' category.; }; @break gte(words(%qO, |), xget(%vD, d.max-travel-categories))={ @trigger me/tr.error=%#, name(%qR) is already listed in [words(%qO, |)] travel categories. Remove one before you add another.; }; @set %qR=d.travel-categories:[unionset(%qO, %qK, |, |)]; @trigger me/tr.success=%#, You add a new travel category for [name(%qR)]%, '%qK'. Travel categories for this location are now: [ulocal(layout.list, unionset(%qO, %qK, |, |))].; @trigger me/tr.log=%qR, _ownerlog-, %#, Travel category '%qK' added.;

&c.+travel/remcat [v(d.bc)]=$+travel/remcat *:@break cand(not(strmatch(%0, *=*)), isstaff(%#)); @assert t(switch(%0, here=*, setr(R, loc(%#)), *=*, setr(R, first(%0, =)), setr(R, loc(%#))))={ @trigger me/tr.error=%#, Could not figure out what room you're referring to. '%qR' doesn't make sense.; }; @assert cor(isdbref(%qR), t(setr(R, search(ROOMS=%qR))))={ @trigger me/tr.error=%#, Could not find a room named '%qR'.; }; @assert eq(words(%qR), 1)={ @trigger me/tr.error=%#, More than one room matches '[first(%0, =)]'.; }; @assert ulocal(filter.is_owner, %qR, %#)={ @trigger me/tr.error=%#, You must be an owner of [name(%qR)] to change the travel categories.; }; @eval setr(N, setr(K, switch(%0, *=*, rest(%0, =), %0))); @eval setq(O, ulocal(f.get-travel-categories, %qR)); @assert t(setr(K, finditem(%qO, %qK, |)))={ @trigger me/tr.error=%#, [name(%qR)] isn't in the '%qN' category. This location's categories include [ulocal(layout.list, %qO)].; }; @set %qR=d.travel-categories:[diffset(%qO, %qK, |, |)]; @trigger me/tr.success=%#, You remove the travel category '%qK' from [name(%qR)]. Travel categories for this location are now: [ulocal(layout.list, diffset(%qO, %qK, |, |))].; @trigger me/tr.log=%qR, _ownerlog-, %#, Travel category '%qK' removed.;

&c.+travel/addcat_staff [v(d.bc)]=$+travel/addcat *:@break strmatch(%0, *=*); @assert isstaff(%#); @break t(grab(setr(O, xget(%vD, d.travel.categories)), %0, |))={ @trigger me/tr.error=%#, %0 is already a travel category.; }; @set %vD=d.travel.categories:[setr(C, setunion(%qO, %0, |, |))]; @trigger me/tr.success=%#, You add the category '%0' to the global travel categories. Global categories: [ulocal(layout.list, %qC)];

@@ TODO MAYBE: +travel/movecat <categoryA>=<categoryB> - maybe not needed, you can always +travel/remcat <place>=<category> and then +travel/addcat <place>=<category>. Goal would be to, for example, move the contents of the Travel Category 'Bars' to the new one called 'Taverns' - make it easier to delete travel categories.

&c.+travel/remcat_staff [v(d.bc)]=$+travel/remcat *:@break strmatch(%0, *=*); @assert isstaff(%#); @assert t(setr(N, grab(setr(O, xget(%vD, d.travel.categories)), %0*, |)))={ @trigger me/tr.error=%#, %0 is not currently a travel category.; }; @break t(setr(S, ulocal(f.get-travel-rooms-matching-category, %qN)))={ @trigger me/tr.error=%#, The category %qN is set on [words(%qS)] [plural(words(%qS), room, rooms)]. You must remove it from all rooms before you can remove it as a global category.; }; @set %vD=d.travel.categories:[setr(C, setdiff(%qO, %qN, |, |))]; @trigger me/tr.success=%#, You remove the category '%qN' from the global travel categories. Global categories: [ulocal(layout.list, %qC)];

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
&layout.join_summon_invite [v(d.bf)]=strcat(ulocal(f.get-name, %0, %1) would like to %2 you to, %b, ansi(h, name(%3)). To, %b, switch(%2, join, bring, join), %b, them%, type %ch+, ansi(h, switch(%2, join, summon, join)), %b, ansi(h, ulocal(f.get-name, %0, %1)), . It is [prettytime()] and this invitation will expire in [first(secs2hrs(v(d.meeting-timeout)))]. [if(cand(not(ulocal(lock.allowed_ic, %0)), not(ulocal(f.is-location-ooc, %3))), cat(Warning: this player is not yet approved and you are bringing, obj(%0), to an IC location.))])

&layout.join_summon_invite_sent [v(d.bf)]=strcat(ulocal(f.get-name, %0) has been issued an invitation to %2 you, %b, switch(%2, summon, to, in), %b, ansi(h, name(%3)), . It is [prettytime()] and this invitation will expire in [first(secs2hrs(v(d.meeting-timeout)))]. [if(cand(not(ulocal(lock.allowed_ic, %0)), not(ulocal(f.is-location-ooc, %3))), You are not yet approved and may be heading into an IC location.)])

&c.+join [v(d.bc)]=$+join *:@assert t(setr(P, ulocal(f.find-player, %0, %#)))={ @trigger me/tr.error=%#, Can't find a player named '%0'.; }; @break match(%qP, %#)={ @trigger me/tr.error=%#, You can't join yourself.; }; @break match(loc(%qP), %l)={ @trigger me/tr.error=%#, cat(You are already at, ulocal(f.get-name, %qP)'s location.); }; @assert cor(ulocal(lock.allowed_ic, %#), ulocal(f.is-location-ooc, loc(%qP)), ulocal(lock.isstaff, %qP))={ @trigger me/tr.error=%#, You are not approved so can't use +join to go IC. Try asking a staffer to bring you - they can override this rule - or meet your friend somewhere OOC.; }; @assert ulocal(f.has-invited-player, %#, %qP, join)={ @trigger me/tr.message=%qP, ulocal(layout.join_summon_invite, %#, %qP, join, loc(%qP)); &_invite-summon-%# %qP=secs(); @trigger me/tr.message=%#, ulocal(layout.join_summon_invite_sent, %qP, %#, summon, loc(%qP)); }; @trigger me/tr.travel_to_destination=loc(%qP), %#, %qP, joining;

&c.+return [v(d.bc)]=$+return *:@assert t(setr(P, ulocal(f.find-player, %0, %#)))={ @trigger me/tr.error=%#, Can't find a player named '%0'.; }; @break match(%qP, %#)={ @break match(default(%qP/_last-location, v(d.default-ooc-room)), %l)={ @trigger me/tr.error=%#, You are already at the destination.; }; @trigger me/tr.travel_to_destination=default(%qP/_last-location, v(d.default-ooc-room)), %qP; }; @break match(default(%qP/_last-location, v(d.default-ooc-room)), %l)={ @trigger me/tr.error=%#, ulocal(f.get-name, %qP) is already at the destination.; };  @assert isstaff(%#)={ @trigger me/tr.message=%#, Only staff can send other players back.; }; @trigger me/tr.travel_to_destination=default(%qP/_last-location, v(d.default-ooc-room)), %qP, %#, returned by;

&c.+summon [v(d.bc)]=$+summon *:@assert t(setr(P, ulocal(f.find-player, %0, %#)))={ @trigger me/tr.error=%#, Can't find a player named '%0'.; }; @break match(%qP, %#)={ @trigger me/tr.error=%#, You can't summon yourself.; }; @break match(loc(%qP), %l)={ @trigger me/tr.error=%#, ulocal(f.get-name, %qP) is already at the destination.; }; @assert cor(ulocal(lock.allowed_ic, %qP), ulocal(f.is-location-ooc, %l), ulocal(lock.isstaff, %#))={ @trigger me/tr.error=%#, You are not approved so can't use +summon to bring unapproved players IC. Try asking a staffer to bring them - they can override this rule - or meet your friend somewhere OOC.; }; @assert ulocal(f.has-invited-player, %#, %qP, summon)={ @trigger me/tr.message=%qP, ulocal(layout.join_summon_invite, %#, %qP, summon, %l); &_invite-join-%# %qP=secs(); @trigger me/tr.message=%#, ulocal(layout.join_summon_invite_sent, %qP, %#, join, %l); }; @trigger me/tr.travel_to_destination=%l, %qP, %#, summoned by;

&c.+ooc [v(d.bc)]=$+ooc:@trigger me/tr.travel_to_destination=default(%#/_last-ooc-location, v(d.default-ooc-room)), %#;

&c.+ic [v(d.bc)]=$+ic:@trigger me/tr.travel_to_destination=default(%#/_last-ic-location, v(d.default-ic-room)), %#;

@@ =============================================================================
@@ +dig and +open
@@ =============================================================================

&f.get-exit-name [v(d.bf)]=strcat(setr(0, switch(%0, * - *, last(%0, %b-%b), %0)), %b, setq(0, iter(%q0, if(ulocal(f.should-word-be-capitalized, lcstr(itext(0)), inum(0)), itext(0)))), setq(0, squish(trim(%q0))), <, setr(1, iter(%q0, mid(itext(0), 0, 1),, @@)), >, ;, %q1, ;, iter(%q0, itext(0),, ;))

&f.exit-is-not-in-use [v(d.bf)]=lte(iter(lexits(%0), t(setinter(fullname(itext(0)), %, ;))), 0)

&f.get-new-room-name [v(d.bf)]=switch(%1, * - *, %1, cat(name(loc(%0)), -, %1))

&tr.digger [v(d.go)]=@eval strcat(setq(R, create(ulocal(%vC/f.get-new-room-name, %0, %1), 10, r)), setq(A, create(%2, 10, e)), setq(B, create(%3, 10, e))); @trigger %vC/tr.finish-room=%0, %qR, %qA, %qB;

&tr.opener [v(d.go)]=@eval strcat(setq(A, create(%2, 10, e)), setq(B, if(t(%3), create(%3, 10, e))); @trigger %vC/tr.finish-exits=%0, %1, %qA, %qB;

&c.+dig [v(d.bc)]=$+dig *:@assert ulocal(f.can-build, %#)={ @trigger me/tr.error=%#, You are not authorized to build.; }; @eval setr(N, switch(%0, *=*, first(%0, =), %0)); @assert valid(roomname, %qN)={ @trigger me/tr.error=%#, '%qN' is not a valid room name.; }; @eval setr(E, switch(%0, *=*%,*, first(rest(%0, =), %,), *=*, rest(%0, =), ulocal(f.get-exit-name, %qN))); @assert valid(exitname, %qE)={ @trigger me/tr.error=%#, '%qE' is not a valid exit name.; }; @assert ulocal(f.exit-is-not-in-use, loc(%#), %qE)={ @trigger me/tr.error=%#, One of your exit names is already in use.; }; @eval setr(O, switch(%0, *=*%,*, last(%0, %,), xget(%vD, d.default-out-exit))); @assert valid(exitname, %qO)={ @trigger me/tr.error=%#, '%qO' is not a valid exit name.; }; @trigger %vB/tr.digger=%#, %qN, %qE, %qO;

&tr.finish-room [v(d.bc)]=@link %2=%1; @tel %2=loc(%0); @link %3=loc(%0); @tel %3=%1; @parent %1=parent(loc(%0)); &_exit-pair %2=%3; &_exit-pair %3=%2; @set %2=TRANSPARENT; @set %3=TRANSPARENT; @trigger me/tr.success=%0, The room '[name(%1)]' is built and ready for use.;

&tr.finish-exits [v(d.bc)]=@link %2=%1; @tel %2=loc(%0); @if t(%3)={ @link %3=loc(%0); @tel %3=%1; &_exit-pair %2=%3; &_exit-pair %3=%2; @set %3=TRANSPARENT; } @set %2=TRANSPARENT; @trigger me/tr.success=%0, The exit [ulocal(f.get-exit-name, %2)] is open and ready for use.;

&c.+open [v(d.bc)]=$+open *:@assert ulocal(f.can-build, %#)={ @trigger me/tr.error=%#, You are not authorized to build.; }; @eval setr(E, switch(%0, *=*, first(%0, =), %0)); @assert valid(exitname, %qE)={ @trigger me/tr.error=%#, '%qE' is not a valid exit name.; }; @assert ulocal(f.exit-is-not-in-use, loc(%#), %qE)={ @trigger me/tr.error=%#, One of your exit names is already in use.; }; @eval setr(O, switch(%0, *=*, rest(%0, =))); @assert cor(not(t(%qO)), valid(exitname, %qO))={ @trigger me/tr.error=%#, '%qO' is not a valid exit name.; };  @trigger %vB/tr.digger=%#, %qN, %qE, %qO;

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Player ownership of locations
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

@ofail [v(d.ep)]=strcat(tries to go into, %b, trim(first(name(me), <)), %, but the door is locked.)

@fail [v(d.ep)]=strcat(alert(), %b, trim(first(name(me), <)) is locked.)

&d.default-lock [v(d.ep)]=[u(%vK/f.has-key, %#, %!)]

@@ %0 - viewer
@@ %1 - room they're looking at
@@ %2 - key-holder
&layout.key-line [v(d.bf)]=strcat(space(3), xget(%1, _key-%2))

@@ %0 - viewer
@@ %1 - room they're looking at
&layout.keys [v(d.bf)]=strcat(header(name(%1), %0), %r, divider(Room keys, %0), setq(O, ulocal(f.get-keys, %1)), %r, if(gt(words(%qO), 0), strcat(formattext(strcat(The following, %b, plural(words(%qO), person has, people have), %b, keys to this build:), 1, %0), %r, iter(%qO, ulocal(layout.key-line, %0, %1, itext(0)),, %r)), formattext(No one has a key to this place at the moment. Please contact staff via %chreq/build%cn if you have questions or comments., 1, %0)), %r, footer(, %0))

@@ %0 - viewer
@@ %1 - room they're looking at
@@ %2 - owner
&layout.owner-line [v(d.bf)]=strcat(setq(W, getremainingwidth(%0)), setq(N, ulocal(f.get-name, %2, %0)), setq(P, default(%2/position-%1, &position-%1 not set.)), space(2), %qN, %b, repeat(., sub(%qW, add(4, strlen(%qN), strlen(%qP)))), %b, %qP)

@@ %0 - viewer
@@ %1 - room they're looking at
&layout.owners [v(d.bf)]=strcat(header(name(%1), %0), %r, divider(Room owners, %0), setq(O, ulocal(f.get-owners, %1)), %r, if(gt(words(%qO), 0), strcat(formattext(strcat(The following, %b, if(gt(words(%qO), 1), people, person), %b, may be reached for OOC questions/comments regarding this build:), 1, %0), %r, formattext(iter(%qO, ulocal(layout.owner-line, %0, %1, itext(0)),, %r), 0, %0)), formattext(strcat(This place has no registered owners at the moment. Please contact staff via %chreq/build%cn if you have questions or comments., if(hasattr(%1, view-owner), strcat(%r, The old owner view:, %b, ulocal(%1/view-owner))), if(cand(hasattr(%1, view-owners), not(strmatch(xget(%1, view-owners), This location has owners. Use +owners to view them.))), strcat(%r, The old owners view:, %b, ulocal(%1/view-owners)))), 1, %0)), if(cand(isstaff(%0), t(setr(L, ulocal(f.get-last-X-logs, %1, _ownerlog-)))), strcat(%r, divider(Ownership history, %0), %r, formattext(iter(%qL, ulocal(layout.log, xget(%1, itext(0))),, %r), 0, %0))), %r, footer(, %0))

@@ %0 - person to test
@@ %1 - object to test whether they own
&f.has-key [v(d.bf)]=cor(ulocal(filter.is_owner, %1, %0), cand(isapproved(%0), if(hastype(%1, EXIT), cor(hasattr(loc(%1), _key-%0), hasattr(loc(xget(%1, _exit-pair)), _key-%0)), hasattr(%1, _key-%0))))

@@ %0 - location to get the owners of
&f.get-owners [v(d.bf)]=trim(squish(iter(lattr(%0/_owner-*), if(isapproved(rest(itext(0), -)), rest(itext(0), -)))))

@@ %0 - location to get the key-holders of
&f.get-keys [v(d.bf)]=trim(squish(iter(lattr(%0/_key-*), if(isapproved(rest(itext(0), -)), rest(itext(0), -)))))

&c.+ep [v(d.bc)]=$+ep *=*:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to use this command.; }; @assert cor(isdbref(setr(E, %0)), t(setr(E, trim(squish(iter(lexits(%L), if(strmatch(fullname(itext(0)), *;%0;*), itext(0))))))))={ @trigger me/tr.error=%#, Could not find the exit '%0'.; }; @assert cor(isdbref(setr(P, %1)), t(setr(P, trim(squish(iter(lexits(%L), if(strmatch(fullname(itext(0)), *;%1;*), itext(0))))))))={ @trigger me/tr.error=%#, Could not find the exit '%1'.; }; @assert eq(words(%qE), 1)={ @trigger me/tr.error=%#, More than one exit matches '%0'.; }; @assert eq(words(%qP), 1)={ @trigger me/tr.error=%#, More than one exit matches '%1'.; }; @assert type(%qE)=EXIT, { @trigger me/tr.error=%#, name(%qE) is not an exit.; }; @assert type(%qP)=EXIT, { @trigger me/tr.error=%#, name(%qP) is not an exit.; }; @set %qE=_exit-pair:%qP; @set %qP=_exit-pair:%qE; @parent %qE=[v(d.exit-parent)]; @parent %qP=[v(d.exit-parent)]; @chown %qE=[v(d.grid-owner)]; @chown %qP=[v(d.grid-owner)]; @set %qE=INHERIT; @set %qP=INHERIT; @trigger me/tr.success=%#, strcat(name(%qE) (%qE) has been linked to, %b, name(%qP) (%qP).);

&c.+ep_single [v(d.bc)]=$+ep *:@break strmatch(%0, *=*)={}; @assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to use this command.; }; @assert cor(isdbref(setr(E, %0)), t(setr(E, trim(squish(iter(lexits(%L), if(strmatch(fullname(itext(0)), *;%0;*), itext(0))))))))={ @trigger me/tr.error=%#, Could not find the exit '%0'.; }; @assert eq(words(%qE), 1)={ @trigger me/tr.error=%#, More than one exit matches '%0'.; }; @assert type(%qE)=EXIT, { @trigger me/tr.error=%#, name(%qE) is not an exit.; }; @assert t(setr(P, xget(%#, _exit-pairing)))={ @set %#=_exit-pairing:%qE; @parent %qE=[v(d.exit-parent)]; @chown %qE=[v(d.grid-owner)]; @set %qE=INHERIT; @trigger me/tr.success=%#, strcat(name(%qE) (%qE) waiting to be paired.); @tel %#=loc(%qE); }; @force %#=+ep %qE=%qP; @wipe %#/_exit-pairing;

&c.+owners [v(d.bc)]=$+owner*:@break strmatch(%0, */*)={ @assert switch(%0, /add *, 1, /remove *, 1, s/clean, 1, 0)={ @trigger me/tr.error=%#, Did you mean one of the following commands: +owner/add%, +owner/remove%, or +owners/clean?; }; }; @assert t(setr(T, switch(%0, s *, rest(%0),, loc(%#), %bhere, loc(%#), s, loc(%#), trim(%0))))={ @trigger me/tr.error=%#, Couldn't figure out what you meant by '%0'.; }; @assert t(case(1, isdbref(%qT), setr(R, %qT), match(%qT, here), setr(R, loc(%#)), setr(R, search(ROOMS=%qT))))={ @trigger me/tr.error=%#, Could not figure out what room you're referring to. '%qT' doesn't make sense.; }; @assert eq(words(%qR), 1)={ @trigger me/tr.error=%#, More than one room matched '%qT'.; }; @pemit %#=ulocal(layout.owners, %#, %qR);

&c.+view/owners_here [v(d.bc)]=$+view here/own*:@force %#=+owners;

&c.+view/owners [v(d.bc)]=$+view own*:@force %#=+owners;

&c.+owner/add [v(d.bc)]=$+owner/add *:@assert t(switch(%0, here=*, setr(R, loc(%#)), *=*, setr(R, first(%0, =)), setr(R, loc(%#))))={ @trigger me/tr.error=%#, Could not figure out what room you're referring to. '%qR' doesn't make sense.; }; @assert cand(t(switch(%0, *=me, setr(T, %#), me, setr(T, %#), *=*, setr(T, rest(%0, =)), setr(T, %0))), t(setr(P, pmatch(%qT))))={ @trigger me/tr.error=%#, Could not find a player named '%qT'.; }; @assert cor(isdbref(%qR), t(setr(R, search(ROOMS=%qR))))={ @trigger me/tr.error=%#, Could not find a room named '%qR'.; }; @assert eq(words(%qR), 1)={ @trigger me/tr.error=%#, More than one room matches '[first(%0, =)]'.; }; @assert ulocal(filter.is_owner, %qR, %#)={ @trigger me/tr.error=%#, You must be an owner of [name(%qR)] to add another owner to the owners list.; }; @assert not(isstaff(%qP))={ @trigger me/tr.error=%#, ulocal(f.get-name, %qP) is staff. You can't change staff's permissions.; }; @assert not(u(filter.is_owner, %qR, %qP))={ @trigger me/tr.error=%#, ulocal(f.get-name, %qP) is already an owner of [name(%qR)].; }; @assert isapproved(%qP)={ @trigger me/tr.error=%#, name(%qP) is not approved and cannot be made an owner.; }; @chown %qR=[v(d.grid-owner)]; @set %qR=_owner-%qP:[ulocal(f.get-name, %qP)] was added by [ulocal(f.get-name, %#)] on [time()]; @wipe %qR/view-owner; &view-owners %qR=This location has owners. Use +owners to view them.; @trigger me/tr.log=%qR, _ownerlog-, %#, Added [ulocal(f.get-name, %qP)] as an owner.; @trigger me/tr.alert-to-channel=xget(%vD, d.report-target), %#, cat(Added, ulocal(f.get-name, %qP) as an owner of, name(%qR).); @trigger me/tr.success=%#, strcat(ulocal(f.get-name, %qP) (%qP) has been added as an owner of, %b, name(%qR) (%qR).);

&c.+owner/remove [v(d.bc)]=$+owner/remove *:@assert t(switch(%0, here=*, setr(R, loc(%#)), *=*, setr(R, first(%0, =)), setr(R, loc(%#))))={ @trigger me/tr.error=%#, Could not figure out what room you're referring to. '%qR' doesn't make sense.; }; @assert cand(t(switch(%0, *=me, setr(T, %#), me, setr(T, %#), *=*, setr(T, rest(%0, =)), setr(T, %0))), t(setr(P, pmatch(%qT))))={ @trigger me/tr.error=%#, Could not find a player named '%qT'.; }; @assert cor(isdbref(%qR), t(setr(R, search(ROOMS=%qR))))={ @trigger me/tr.error=%#, Could not find a room named '%qR'.; }; @assert eq(words(%qR), 1)={ @trigger me/tr.error=%#, More than one room matches '[first(%0, =)]'.; }; @assert ulocal(filter.is_owner, %qR, %#)={ @trigger me/tr.error=%#, You must be an owner of [name(%qR)] to add another owner to the owners list.; }; @assert u(filter.is_owner, %qR, %qP)={ @trigger me/tr.error=%#, ulocal(f.get-name, %qP) is not currently an owner of [name(%qR)].; }; @assert not(isstaff(%qP))={ @trigger me/tr.error=%#, ulocal(f.get-name, %qP) is staff. You can't change staff's permissions.; }; @wipe %qR/_owner-%qP; @switch/first words(ulocal(f.get-owners, %qR))=0, { @wipe %qR/view-owner*; }; @trigger me/tr.log=%qR, _ownerlog-, %#, Removed [ulocal(f.get-name, %qP)] as an owner.; @trigger me/tr.alert-to-channel=xget(%vD, d.report-target), %#, cat(Removed, ulocal(f.get-name, %qP) as an owner of, name(%qR).); @trigger me/tr.success=%#, strcat(ulocal(f.get-name, %qP) (%qP) has been removed from the owners list of, %b, name(%qR) (%qR).);

&c.+owners/clean [v(d.bc)]=$+owners/clean:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to clean up the owners list.; }; @trigger me/tr.clean-owners=%#;

&tr.clean-owners [v(d.bc)]=@dolist search(eroom=t(lattr(##/_owner-#*)), 2)={ @trigger me/tr.clean-room=%0, ##; }

&tr.clean-room [v(d.bc)]=@dolist lattr(%1/_owner-#*)={ @assert not(isapproved(setr(P, edit(##, _OWNER-,)), approved)); @wipe %1/_owner-%qP; @switch/first words(ulocal(f.get-owners, %1))=0, { @wipe %1/view-owner*; }; @trigger me/tr.log=%1, _ownerlog-, %0, Removed [ulocal(f.get-name, %qP)] as an owner.; @trigger me/tr.alert-to-channel=xget(%vD, d.report-target), %0, cat(Removed, ulocal(f.get-name, %qP) as an owner of, name(%1).); @trigger me/tr.success=%0, strcat(ulocal(f.get-name, %qP) (%qP) has been removed from the owners list of, %b, name(%1) (%1).); }

&c.+keys [v(d.bc)]=$+key*:@break strmatch(%0, */*)={ @assert switch(%0, /give *, 1, /take *, 1, 0)={ @trigger me/tr.error=%#, Did you mean one of the following commands: +key/give or +key/take?; }; }; @assert t(setr(T, switch(%0, s *, rest(%0),, loc(%#), %bhere, loc(%#), s, loc(%#), trim(%0))))={ @trigger me/tr.error=%#, Couldn't figure out what you meant by '%0'.; }; @assert t(case(1, isdbref(%qT), setr(R, %qT), match(%qT, here), setr(R, loc(%#)), setr(R, search(ROOMS=%qT))))={ @trigger me/tr.error=%#, Could not figure out what room you're referring to. '%qT' doesn't make sense.; }; @assert eq(words(%qR), 1)={ @trigger me/tr.error=%#, More than one room matched '%qT'.; }; @pemit %#=ulocal(layout.keys, %#, %qR);

&c.+key/give [v(d.bc)]=$+key/give *:@assert t(switch(%0, here=*, setr(R, loc(%#)), *=*, setr(R, first(%0, =)), setr(R, loc(%#))))={ @trigger me/tr.error=%#, Could not figure out what room you're referring to. '%qR' doesn't make sense.; }; @assert cand(t(switch(%0, *=me, setr(T, %#), me, setr(T, %#), *=*, setr(T, rest(%0, =)), setr(T, %0))), t(setr(P, pmatch(%qT))))={ @trigger me/tr.error=%#, Could not find a player named '%qT'.; }; @assert cor(isdbref(%qR), t(setr(R, search(ROOMS=%qR))))={ @trigger me/tr.error=%#, Could not find a room named '%qR'.; }; @assert eq(words(%qR), 1)={ @trigger me/tr.error=%#, More than one room matches '[first(%0, =)]'.; }; @assert ulocal(filter.is_owner, %qR, %#)={ @trigger me/tr.error=%#, You must be an owner of [name(%qR)] to give someone a key.; }; @assert not(u(f.has-key, %qP, %qR))={ @trigger me/tr.error=%#, ulocal(f.get-name, %qP) already has a key to [name(%qR)].; }; @assert isapproved(%qP)={ @trigger me/tr.error=%#, name(%qP) is not approved and cannot be given a key.; }; @chown %qR=[v(d.grid-owner)]; @set %qR=_key-%qP:[ulocal(f.get-name, %qP)] (%qP) was given a key by [ulocal(f.get-name, %#)] on [time()]; @trigger me/tr.success=%#, strcat(ulocal(f.get-name, %qP) (%qP) has been given a key to, %b, name(%qR) (%qR).); @trigger me/tr.log=%qR, _ownerlog-, %#, Granted [ulocal(f.get-name, %qP)] a key.;

&c.+key/take [v(d.bc)]=$+key/take *:@assert t(switch(%0, here=*, setr(R, loc(%#)), *=*, setr(R, first(%0, =)), setr(R, loc(%#))))={ @trigger me/tr.error=%#, Could not figure out what room you're referring to. '%qR' doesn't make sense.; }; @assert cand(t(switch(%0, *=me, setr(T, %#), me, setr(T, %#), *=*, setr(T, rest(%0, =)), setr(T, %0))), t(setr(P, pmatch(%qT))))={ @trigger me/tr.error=%#, Could not find a player named '%qT'.; }; @assert cor(isdbref(%qR), t(setr(R, search(ROOMS=%qR))))={ @trigger me/tr.error=%#, Could not find a room named '%qR'.; }; @assert eq(words(%qR), 1)={ @trigger me/tr.error=%#, More than one room matches '[first(%0, =)]'.; }; @assert ulocal(filter.is_owner, %qR, %#)={ @trigger me/tr.error=%#, You must be an owner of [name(%qR)] to take away someone's key.; }; @assert u(f.has-key, %qP, %qR)={ @trigger me/tr.error=%#, ulocal(f.get-name, %qP) does not currently have a key to [name(%qR)].; }; @wipe %qR/_key-%qP; @trigger me/tr.success=%#, strcat(ulocal(f.get-name, %qP) (%qP) has lost their key to, %b, name(%qR) (%qR).); @trigger me/tr.log=%qR, _ownerlog-, %#, Took away [ulocal(f.get-name, %qP)]'s key.;

&c.+lock [v(d.bc)]=$+lock *:@assert cor(isdbref(setr(E, %0)), t(setr(E, trim(squish(iter(lexits(%L), if(strmatch(fullname(itext(0)), *;%0;*), itext(0))))))))={ @trigger me/tr.error=%#, Could not find the exit '%0'.; }; @assert eq(words(%qE), 1)={ @trigger me/tr.error=%#, More than one exit matches '%0'.; }; @assert type(%qE)=EXIT, { @trigger me/tr.error=%#, name(%qE) is not an exit.; }; @assert t(setr(P, xget(%qE, _exit-pair)))={ @trigger me/tr.error=%#, name(%qE) is not set up to be locked.; }; @assert cor(u(f.has-key, %#, %qE), u(f.has-key, %#, %qP))={ @trigger me/tr.error=%#, You must have a key to lock the doors.; }; @assert not(t(lock(%qE/DefaultLock)))={ @trigger me/tr.error=%#, name(%qE) is already locked.; }; &_lock-exit %qE=[xget(v(d.exit-parent), d.default-lock)]; @lock/DefaultLock %qE=_lock-exit/1; &_lock-exit %qP=[xget(v(d.exit-parent), d.default-lock)]; @lock/DefaultLock %qP=_lock-exit/1; @trigger me/tr.success=%#, strcat(You just locked, %b, u(f.get-exit-name, %qE).);

&c.+unlock [v(d.bc)]=$+unlock *:@assert cor(isdbref(setr(E, %0)), t(setr(E, trim(squish(iter(lexits(%L), if(strmatch(fullname(itext(0)), *;%0;*), itext(0))))))))={ @trigger me/tr.error=%#, Could not find the exit '%0'.; }; @assert eq(words(%qE), 1)={ @trigger me/tr.error=%#, More than one exit matches '%0'.; }; @assert type(%qE)=EXIT, { @trigger me/tr.error=%#, name(%qE) is not an exit.; }; @assert t(setr(P, xget(%qE, _exit-pair)))={ @trigger me/tr.error=%#, name(%qE) is not set up to be locked.; }; @assert cor(u(f.has-key, %#, %qE), u(f.has-key, %#, %qP))={ @trigger me/tr.error=%#, You must have a key to unlock the doors.; }; @assert t(lock(%qE/DefaultLock))={ @trigger me/tr.error=%#, name(%qE) is already unlocked.; }; @wipe %qE/_lock-exit; @unlock/DefaultLock %qE; @wipe %qP/_lock-exit; @unlock/DefaultLock %qP; @trigger me/tr.success=%#, strcat(You just unlocked, %b, u(f.get-exit-name, %qE).);

&c.+desc [v(d.bc)]=$+desc *=*: @assert t(switch(%0, here, setr(R, loc(%#)), setr(R, %0)))={ @trigger me/tr.error=%#, Could not figure out what room you're referring to. '%qR' doesn't make sense.; }; @assert cor(isdbref(%qR), t(setr(R, search(ROOMS=%qR))))={ @trigger me/tr.error=%#, Could not find a room named '%qR'.; }; @assert eq(words(%qR), 1)={ @trigger me/tr.error=%#, More than one room matches '%0'.; }; @assert t(%1)={ @trigger me/tr.error=%#, You must include a description.; }; @assert ulocal(filter.is_owner, %qR, %#)={ @trigger me/tr.error=%#, You must be an owner of [name(%qR)] to edit the description.; }; @assert cor(not(hasflag(%qR, INHERIT)), isstaff(%#))={ @trigger me/tr.error=%#, This room's description cannot be set by non-staff.; }; @set %qR=desc:[setq(O, xget(%qR, desc))]%1; @trigger me/tr.success=%#, strcat(You have updated the description on, %b, name(%qR) (%qR). The old text was:, %b, %qO); @trigger me/tr.remit-quiet=%qR, ulocal(f.get-name, %#) has updated the description of this room.;

@set [v(d.bc)]/c.+desc=no_parse

&c.+shortdesc [v(d.bc)]=$+shortdesc *=*:@assert t(switch(%0, here, setr(R, loc(%#)), me, setr(R, %#), setr(R, %0)))={ @trigger me/tr.error=%#, Could not figure out what you're referring to. '%0' doesn't make sense.; }; @assert cor(isdbref(%qR), t(setr(R, filter(filter.isowner, search(NAME=%qR),,, %#))))={ @trigger me/tr.error=%#, Could not find anything you own named '%qR'.; }; @assert eq(words(%qR), 1)={ @trigger me/tr.error=%#, More than one thing matches '%0'.; }; @assert t(%1)={ @trigger me/tr.error=%#, You must include a short description.; }; @assert lte(strlen(%1), setr(M, xget(%vD, d.max-shortdesc-length)))={ @trigger me/tr.error=%#, Your shortdesc is too long. Max length is %qM characters.; }; @assert ulocal(filter.is_owner, %qR, %#)={ @trigger me/tr.error=%#, You must be an owner of [name(%qR)] to edit the short description.; }; @assert cor(not(hasflag(%qR, INHERIT)), isstaff(%#))={ @trigger me/tr.error=%#, This room's short description cannot be set by non-staff.; }; @set %qR=short-desc:%1; @trigger me/tr.success=%#, cat(You have updated the short-desc on, name(%qR) (%qR) to: %1);

@set [v(d.bc)]/c.+shortdesc=no_parse

&c.+shortdesc_alias [v(d.bc)]=$+shortdesc:@force %#=+glance;
