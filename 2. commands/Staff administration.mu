@@ Commands related to running the game, only usable by staffers.

@@ =============================================================================
@@ +staff/add, +staff/del, +duty, +dark, +staffnote
@@ =============================================================================

&c.+staff/add [v(d.bc)]=$+staff/add *:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to add staffers.; }; @assert t(setr(P, ulocal(f.find-player, %0, %#)))={ @trigger me/tr.error=%#, Could not find the player '%0'.; }; @break member(v(d.staff_list), %qP)={ @trigger me/tr.error=%#, moniker(%qP) is already on the staff list.; };  &d.staff_list %vD=setunion(v(d.staff_list), %qP); @trigger me/tr.success=%#, You have added [moniker(%qP)] to the staff list.;

&c.+staff/del [v(d.bc)]=$+staff/* *:@break strmatch(%0, a*); @assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to add staffers.; }; @assert t(setr(P, ulocal(f.find-player, %0, %#)))={ @trigger me/tr.error=%#, Could not find the staffer '%1'.; }; @assert member(v(d.staff_list), %qP)={ @trigger me/tr.error=%#, moniker(%qP) is not currently on the staff list.; }; @moniker %qP=[name(%qP)]; &d.staff_list %vD=setdiff(v(d.staff_list), %qP); @trigger me/tr.success=%#, You have removed [moniker(%qP)] from the staff list. [if(hasflag(%qP, wizard), Remember to use #1 to take away their wizard powers.)];

&c.+duty [v(d.bc)]=$+duty:@assert isstaff(%#)={ @trigger me/tr.error=%#, This command only matters for staffers.; }; @set %#=[if(hasflag(%#, transparent), !)]transparent; @trigger me/tr.success=%#, You have set yourself [if(hasflag(%#, transparent), on, off)] duty.;

&c.+offduty [v(d.bc)]=$+offduty:@assert isstaff(%#)={ @trigger me/tr.error=%#, This command only matters for staffers.; }; @assert hasflag(%#, transparent)={ @trigger me/tr.error=%#, You are already off-duty.; };  @set %#=!transparent; @trigger me/tr.success=%#, You have set yourself off duty.;

&c.+onduty [v(d.bc)]=$+onduty:@assert isstaff(%#)={ @trigger me/tr.error=%#, This command only matters for staffers.; }; @break hasflag(%#, transparent)={ @trigger me/tr.error=%#, You are already on-duty.; };  @set %#=transparent; @trigger me/tr.success=%#, You have set yourself on duty.;

&c.+dark [v(d.bc)]=$+dark:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to use this command.; }; @set %#=[if(hasflag(%#, dark), !)]dark; @trigger me/tr.success=%#, You have set yourself [if(hasflag(%#, dark), dark, visible)].;

&c.+undark [v(d.bc)]=$+undark:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to use this command.; }; @assert hasflag(%#, dark)={ @trigger me/tr.error=%#, You are already visible.; };  @set %#=!dark; @trigger me/tr.success=%#, You have set yourself visible.;

&c.+staffnote [v(d.bc)]=$+staffnote *=*:@break strmatch(%0, */*); @assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to use this command.; }; @assert t(setr(P, ulocal(f.find-player, %0, %#)))={ @trigger me/tr.error=%#, Could not find a player named '%0'.; }; &_d.staff-notes %qP=%1; @trigger me/tr.success=%#, moniker(%qP)'s staff note now reads: %1;

@@ =============================================================================
@@ +find
@@ +find[/rooms|/players|/things|/channels] <text>
@@ Because sometimes I put stuff on objects and forget where it's gone.
@@ =============================================================================

&f.find-text [v(d.bf)]=if(t(setr(G, case(1, switch(%0, ^*, 1, *@@STAR@@*, 1, 0), squish(trim(iter(lattr(%1/*), if(strmatch(stripansi(xget(%1, itext(0))), switch(%0, ^*, edit(rest(%0, ^), @@STAR@@, *), strcat(*, edit(%0, @@STAR@@, *)))*), itext(0))))), grepi(%1, *, %0)))), setq(R, setunion(%qR, cat(itext(0), %qG), |)))

&c.+find [v(d.bc)]=$+find*:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to use this command.; }; @assert t(setr(T, edit(trim(switch(%0, /* *, rest(%0), trim(%0)), b, *), *, @@STAR@@)))={ @trigger me/tr.error=%#, You need to include text to search for. '%qT'; }; @assert t(setr(S, switch(%0, /r*, rooms, /p*, players, \/t*, things, /c*, channels, /*,, command objects)))={ @trigger me/tr.error=%#, Available switches are: /rooms%, /players%, \/things%, /channels%, and nothing (command objects).; }; @eval setq(O, switch(%0, /r*, search(TYPE=ROOM), /p*, search(TYPE=PLAYER), /t*, search(TYPE=THING), /c*, edit(lattr(xget(v(d.channel-functions), vD)/CHANNEL.*), CHANNEL.,), cat(%#, lcon(%#), loc(%#), lcon(loc(%#)), config(master_room), lcon(config(master_room))))); @eval iter(%qO, u(f.find-text, %qT, itext(0))); @assert t(%qR)={ @trigger me/tr.error=%#, Sorry%, didn't find any results [case(1, switch(%qT, ^*, 1, *@@STAR@@*, 1, 0), with attributes whose values match [edit(strip(%qT, ^), @@STAR@@, *)], with '%qT' in any of their attributes)]. I searched [words(%qO)] %qS.; }; @trigger me/tr.success=%#, Found [case(1, switch(%qT, ^*, 1, *@@STAR@@*, 1, 0), attributes whose values match [edit(strip(%qT, ^), @@STAR@@, *)], '%qT')] in a search of [words(%qO)] %qS:%R%R[iter(%qR, strcat(-%b, name(setr(I, first(itext(0)))), :, %R%T, iter(rest(itext(0)), strcat(ex %qI/, itext(0)),, %R%T)), |, %r)];

@set [v(d.bc)]/c.+find=no_parse

@@ TODO: Write +newpass so non-wiz staff can newpassword players.

@@ =============================================================================
@@ +ban, +unban
@@ =============================================================================
/*
This gets tricky because while we want to ban people, we can only ban by IP.

We want to ban a player and all their alts and all the IPs they've ever logged in on. If they log in on a banned character, we then want to update the ban and ban that IP too.

However, we do NOT want to ban staff, people on shared clients, and the machine itself.

We also don't want to ban IP addresses forever, but *players*, we do.

So how about this: IP bans expire after 30 days. If the player logs in after that time, they're re-banned at their NEW IP address, unless the ban has been lifted.

Bans: Prevent players from making new alts or logging in guests from that IP.

Player bans: Kick players off as soon as they log in (and log their IP so that it too can be banned).

1. Only staff can ban people. They have to provide a reason. They will see a list of players sharing that player's IPs, and can confirm or cancel out of a ban before it's permanent.

2. It goes on the Monitor channel and is logged. There'll be a list - +bans - that shows you all bans, who did them, and why they happened. The player, too, gets shown the "why you're banned" as well as an email addresss to appeal the ban to when they're booted. If the player is not logged in, they don't see the reason, but will still see the email on the badsite_connect file.

3. There's a list of unbannable people and IP addresses - staffers, #1, Cheese web client, etc. One can ban a player and their alts, without banning these IPs.

4. The IP bans expire after 30 days. This way we don't perma-ban an IP that later belongs to the dude's neighbor.

5. The player bans are permanent, and if a banned player logs back into their banned bits, an alert hits the Monitor channel with their new IP address so that it, too, can be banned (subject to the above exceptions) and the player is booted (so even if they log in via Cheese, they get kicked off).

If a banned player manages to make new alts via Cheese (or some other web client), we can set that site register-only (they have to register via email in order to create a character). This would be a codewiz thing though. COULD theoretically do it just like banning I suppose...

This is definitely Work In Progress.

*/

&f.get-player-ips [v(d.bf)]=xget(%0, _unique-ips)

&f.get-bannable-player-ips [v(d.bf)]=strcat(setq(I, ulocal(f.get-all-player-ips, %0)), setq(I, iter(%qI, if(ulocal(f.is-ip-bannable, itext(0)), itext(0)))), setunion(%qI, %qI))

&f.get-all-player-ips [v(d.bf)]=strcat(setq(I, iter(ulocal(fn.get-true-alts, %0), ulocal(f.get-player-ips, itext(0)))), setunion(%qI, %qI))

&f.get-all-affected-players [v(d.bf)]=search(eplayer=cand(not(t(setinter(##, %1))), t(setinter(%0, ulocal(f.get-player-ips, ##)))))

&f.is-ip-bannable [v(d.bf)]=not(t(finditem(setunion(v(d.unbannable-IP-addresses), iter(setunion(v(d.staff_list), search(EPLAYER=orflags(##, WZw))), xget(itext(0), lastip))), %0)))

&c.+ban_need-reason [v(d.bc)]=$+ban *:@break strmatch(%0, *=*); @assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to use this command.; }; @trigger me/tr.error=%#, You must specify a reason to ban someone.;

&c.+ban [v(d.bc)]=$+ban *=*:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to use this command.; }; @assert t(setr(P, ulocal(f.find-player, %0, %#)))={ @trigger me/tr.error=%#, Could not find a player named '%0'.; }; @break t(setr(S, first(squish(trim(iter(setr(C, ulocal(fn.get-true-alts, %qP)), if(isstaff(itext(0)), itext(0))))))))={ @trigger me/tr.error=%#, cat(ulocal(f.get-name, %qP, %#) appears to be a, if(strmatch(%qP, %qS), staffer, staff alt). Remove them from staff before banning., if(orflags(%qS, WZw), Remember to have #1 @set %qS=!wizard.)); }; @set %#=_banning-player:[secs()] %qC|%1;  @set %#=_banning-affected:[setr(A, ulocal(f.get-all-affected-players, ulocal(f.get-bannable-player-ips, %qP), %qC))]; @set %#=_banning-exempted:; @trigger me/tr.ban-notify=%#, %1, %qP, %qC, %qA;

&tr.ban-notify [v(d.bc)]=@trigger me/tr.message=%0, cat(You are preparing to ban, ulocal(f.get-name, %2, %0), because:, %ch%1%cn. The player and their alts will be shown this reason%, along with the email address, ansi(h, v(d.staff-email-address))%, in case they wish to file an appeal.); @if t(setr(X, xget(%0, _banning-exempted)))={ @trigger me/tr.message=%0, cat(The following players are specifically exempted from this ban:, itemize(iter(%qX, ulocal(f.get-name, itext(0), %0),, |), |).);  }; @if t(setr(L, setdiff(%3, %2)))={ @trigger me/tr.message=%0, cat(We detect the following alts of this player%, which will also be banned:, itemize(iter(%qL, ulocal(f.get-name, itext(0), %0),, |), |). To exempt one%, type %ch+ban/exempt <name>%cn.); }; @trigger me/tr.message=%0, cat(To finalize this ban%, type %ch+ban/finalize%cn, ansi(h, ulocal(f.get-name, %2, %0)), within the next 20 minutes. The time is now, prettytime().); @break t(%4)={ @trigger me/tr.message=%0, cat(The following players may also be affected by this ban:, itemize(iter(%4, ulocal(f.get-name, %2, %0),, |), |)., This means that they have or once had the same IP address as the person being banned. To exempt them from the IP ban%, type %ch+ban/exempt <name>%cn. Any matching IP addresses will be exempted and those that remain will be banned., Note: these players will not themselves be banned - they will be able to log in so long as they do so at a different IP address from those being banned. To include them in the player ban%, type %ch+ban/include <name>%cn.); }

+ban/exempt Test

@@ TODO: Exempted player's %qP is replacing original player's number. Separate and store. Bug is probably also in /include. Might wish to rewrite that when done with exempt.

&c.+ban/exempt [v(d.bc)]=$+ban/exempt *:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to use this command.; }; @assert t(setr(P, ulocal(f.find-player, %0, %#)))={ @trigger me/tr.error=%#, Could not find a player named '%0'.; }; @assert t(setinter(%qP, setunion(xget(%#, _banning-affected), rest(first(xget(%#, _banning-player), |)))))={ @trigger me/tr.error=%#, ulocal(f.get-name, %qP, %#) is not mentioned in the current ban and cannot be exempted.; }; @set %#=_banning-player:[secs()] [setr(C, setdiff(rest(first(setr(E, xget(%#, _banning-player)), |)), %qP))]|[setr(R, rest(%qE, |))]; @set %#=_banning-affected:[setr(A, setdiff(xget(%#, _banning-affected), %qP))]; @set %#=_banning-exempted:[setunion(xget(%#, _banning-exempted), %qP)]; @trigger me/tr.success=%#, ulocal(f.get-name, %qP, %#) has been exempted from the ban.; @trigger me/tr.ban-notify=%#, %qR, %qP, %qC, %qA;

&c.+ban/include [v(d.bc)]=$+ban/include *:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to use this command.; }; @assert t(setr(P, ulocal(f.find-player, %0, %#)))={ @trigger me/tr.error=%#, Could not find a player named '%0'.; }; @set %#=_banning-player:[secs()] [setr(C, setunion(rest(first(setr(E, xget(%#, _banning-player)), |)), %qP))]|[setr(R, rest(%qE, |))]; @set %#=_banning-affected:[setr(A, setunion(xget(%#, _banning-affected), %qP))]; @set %#=_banning-exempted:[setdiff(xget(%#, _banning-exempted), %qP)]; @trigger me/tr.success=%#, ulocal(f.get-name, has been included in the ban.); @trigger me/tr.ban-notify=%#, %qR, %qP, %qC, %qA;

&c.+ban/finalize [v(d.bc)]=$+ban/finalize *: @assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to use this command.; }; @assert t(setr(P, ulocal(f.find-player, %0, %#)))={ @trigger me/tr.error=%#, Could not find a player named '%0'.; }; @trigger me/tr.ban-player=%#, setr(B, xget(%#, _banning-player)), last(%qB, |), extract(%qB, 2, 1, |);

&tr.ban-player [v(d.bc)]=@pemit %qP=cat(alert(Banned), ulocal(f.get-name, %#, %qP), just banned you because: %1); @pemit %qP=cat(alert(Appeals), You can appeal this to, v(d.staff-email-address).); @assert t(setr(I, ulocal(f.get-bannable-player-ips, %qP)))={ @trigger me/tr.error=%#, You can't ban that player - none of their IPs are bannable. Either all of their IP addresses are also used by a staffer%, or they're all on the list of unbannable IP addresses (for example%, an IP used by a browser-based client which would result in blocking many more players than desired).; }; @dolist %qI={ &d.ban.## %vD=cat(ulocal(f.get-name, %#), banned, ulocal(f.get-name, %qP), on, prettytime(), because:, %1); @admin forbid_site=## 255.255.255.255; }; @boot/quiet %qP; @trigger me/tr.success=%#, Banned [ulocal(f.get-name, %qP, %#)] because: %1; @trigger me/tr.report=cat(ulocal(f.get-name, %#), banned, ulocal(f.get-name, %qP), because:, %1); @assert eq(words(%qI), words(ulocal(f.get-player-ips, %qP)))={ @trigger me/tr.message=%#, cat(Not all of, ulocal(f.get-name, %qP, %#)'s, IP addresses were banned. The following IPs could not be banned because they are either staff IP addresses%, or are on the list of unbannable IPs:, itemize(setdiff(%qI, ulocal(f.get-player-ips, %qP))). These may require manual intervention to block. Consider +newpass-ing the player and all their alts.); };

@@ TODO: Restrictions on who can do this and who can't.
&c.+unban [v(d.bc)]=$+unban *:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to use this command.; }; @assert t(setr(P, ulocal(f.find-player, %0, %#)))={ @trigger me/tr.error=%#, Could not find a player named '%0'.; }; @wipe %vD/d.ban.[setr(I, xget(%qP, lastip))]; @admin reset_site=%qI 255.255.255.255; @trigger me/tr.success=%#, Unbanned [ulocal(f.get-name, %qP, %#)].; @trigger me/tr.report=cat(ulocal(f.get-name, %#), unbanned, ulocal(f.get-name, %qP).);
