@@ General commands to help players self-administer and fix their own issues.

@@ =============================================================================
@@ +selfboot
@@ =============================================================================

&c.+selfboot [v(d.bc)]=$+selfboot:@assert gt(words(ports(%#)), 1)={ @trigger me/tr.error=%#, You don't have any frozen connections to boot.; }; @dolist rest(ports(%#))=@boot/port ##; @trigger me/tr.success=%#, You booted your frozen connections.;

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ +name - claim a name
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

&layout.name-list [v(d.bf)]=strcat(header(Names beginning with %0*, %1), %r, setq(D, v(d.max-days-before-name-available)), formattext(The following names match %0*:, 1, %1), %r, multicol(if(t(setr(S, search(EPLAYER=cand(strmatch(name(##), %0*), ulocal(f.is-player, ##))))), iter(%qS, cat(if(cand(gt(ulocal(f.days-since-last-connected, ##), %qD), not(strmatch(name(itext(0)), *_[rest(itext(0), #)]))), %ch*%cn, %b), ulocal(f.get-name, itext(0), %1)),, |), None found.), * * *, 0, |, %1), %r, formattext(cat(%ch*%cn Names may be claimed after the player has gone %qD days without logging in. Any names that are claimable in the above list are marked with a %ch*%cn. If you don't see a %ch*%cn%, the name is not claimable.%r%r%tTo claim a name%, type %ch+name/claim <name>%cn. That player will have their name changed and you will be able to create a character with that name.%r%r%tIf your name was changed by +name/claim%, you can just log in with your changed name%, then %ch@name me=<new name>%cn.), 1, %1), %r, footer(, %1))

&c.+name [v(d.bc)]=$+name *:@pemit %#=ulocal(layout.name-list, %0, %#);

&c.+names [v(d.bc)]=$+names *:@pemit %#=ulocal(layout.name-list, %0, %#);

&c.+name/claim [v(d.bc)]=$+name/claim *:@assert t(setr(P, ulocal(f.find-player, %0, %#)))={ @trigger me/tr.error=%#, Could not find a player named '%0'.; }; @eval setq(N, ulocal(f.get-name, %qP, %#)); @assert ulocal(f.is-player, %qP)={ @trigger me/tr.error=%#, cat(%qN is not the kind of player who can have, poss(%qP), name claimed.); }; @eval setq(D, v(d.max-days-before-name-available)); @assert gt(ulocal(f.days-since-last-connected, %qP), %qD)={ @trigger me/tr.error=%#, %qN has logged in more recently than %qD days ago. You cannot claim this name.; }; @break strmatch(%qN, *_%qP)={ @trigger me/tr.error=%#, cat(%qN has already had, poss(%qP), name changed. You can't claim a name that has already been claimed.); }; @name %qP=strcat(edit(first(%qN, _), %b, _), edit(%qP, #, _)); @wipe %qP/alias; @trigger me/tr.log=%qP, _app-, %#, Name and alias taken by another player after %qD+ days idle.; @trigger me/tr.success=%#, You claim the name %qN. %ch@name me=%qN%cn to use it!; @trigger me/tr.monitor=%#, Claimed the name '%qN'.;

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Sweep disconnected players out of the room
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

&c.+sweep [v(d.bc)]=$+sweep: @break cand(ulocal(f.is-location-ooc, %L), not(isstaff(%#)))={ @trigger me/tr.error=%#, This location is OOC. You can't +sweep here.; }; @assert isowner(%L, %#)={ @trigger me/tr.error=%#, cat(You are not the owner of, name(%qL), and cannot +sweep here.); }; @assert t(setr(A, filter(filter.is-not-connected, filter(filter.isplayer, lcon(%L)))))={ @trigger me/tr.error=%#, There are no disconnected players in your location.; }; @dolist %qA={ @tel/quiet ##=[v(d.ooc)]; }; @trigger me/tr.success=%#, You sweep all disconnected players to the OOC room.;

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Set the player's screen width (for clients that don't report it accurately)
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

&c.+width [v(d.bc)]=$+width:@trigger me/tr.message=%#, Your width reads as [width(%#)] to the game. Your display width is set to %ch[ulocal(f.get-width, %#)]%cn. If you want to change it%, type %ch+width <#>%cn. It must be a number between [v(d.min-possible-player-width)] and [v(d.max-possible-player-width)].;

&c.+width_text [v(d.bc)]=$+width *:@assert isint(%0)={ @wipe %#/width; @trigger me/tr.success=%#, You clear your width. It's back to the default value provided by your client now. Try it out - hit +who!; }; @assert cand(lte(%0, v(d.max-possible-player-width)), gte(%0, v(d.min-possible-player-width)))={ @trigger me/tr.error=%#, '%0' must be an integer between [v(d.min-possible-player-width)] and [v(d.max-possible-player-width)].; }; @set %#=width:%0; @trigger me/tr.success=%#, You set your screen width to %0. Try it out - hit +who!;

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ skewskewskew's Beep Test, slightly  expanded
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

&c.beep [v(d.bc)]=$+beep:@trigger me/tr.message=%#, This is to see if your beep is working. Beep beep![beep()] The test will now wait 3 seconds and beep you again.; @wait 3={ @trigger me/tr.message=%#, This is your second beep test.[beep()] Beep! One more in 3 seconds.; }; @wait 6={ @trigger me/tr.message=%#, This is your third and final beep test.[beep()] Beep! If you heard a sound%, it works. If not%, check your client's settings.; };

&c.+beeptest [v(d.bc)]=$+beeptest:@force %#=+beep;

@@ =============================================================================
@@ @gender, an alias for @sex
@@ =============================================================================

&c.@gender [v(d.bc)]=$@gender *:@force %#=@sex %0;

@@ =============================================================================
@@ +block, a simple page-locker
@@ =============================================================================

&tr.lock-setup [v(d.bc)]=&page-lock %0=cor\(isstaff(\%#), member\(v\(whitelisted-PCs\), \%#\), not\(cor\(t\(v\(block-all\)\), member\(v\(blocked-PCs\), \%#\)\)\)\); @lock/page %0=page-lock/1; @lock/mail %0=page-lock/1; 

&tr.lock-clear [v(d.bc)]=@unlock/page %0; @unlock/mail %0; &page-lock %0=;

&cmd-+block_name [v(d.bc)]=$+block *:@assert t(setr(P, switch(%0, all, all, ulocal(f.find-player, %0, %#))))={ @trigger me/tr.error=%#, Could not find a player named '%0'.; }; @break isstaff(%qP)={ @trigger me/tr.error=%#, [moniker(%qP)] is staff and can't be blocked.; }; @trigger me/tr.+block=%#, %qP, default(%0/reject, Sorry%, [moniker(%#)] is not accepting pages.);

&tr.+block [v(d.bc)]=@trigger me/tr.lock-setup=%0; &block-all %0=[strmatch(%1, all)]; @trigger me/tr.add-blocked-person=%0, %1; @trigger me/tr.success=%0, You have blocked page messages from [switch(%1, all, everyone, moniker(%1))]. Blocked people who try to page you will see: %R%R%2%R%RTo change that message%, type '@reject me=<message>'. To turn paging back on%, +unblock [switch(%1, all, all, moniker(%1))]. You may also wish to use [switch(%1, all, msg/off, msg/block [moniker(%1)])] to keep them from contacting you IC.;

&tr.add-blocked-person [v(d.bc)]=@break strmatch(%1, all); &blocked-PCs %0=setunion(xget(%0, blocked-PCs), u(fn.get-alts, %1)); &blocks %0=setunion(xget(%0, blocks), %1);

&cmd-+unblock [v(d.bc)]=$+unblock *:@assert t(setr(P, switch(%0, all, all, ulocal(f.find-player, %0, %#))))={ @trigger me/tr.error=%#, Could not find a player named '%0'.; }; @assert switch(%qP, all, xget(%#, block-all), member(xget(%#, blocked-PCs), %qP))={ @trigger me/tr.error=%#, You aren't currently blocking [switch(%qP, all, pages from everyone, moniker(%qP))].; }; @trigger me/tr.+unblock=%#, %qP;

&tr.+unblock [v(d.bc)]=@trigger me/tr.lock-setup=%0; &block-all %0=[switch(%1, all, 0, xget(%0, block-all))]; @trigger me/tr.unblock-person=%0, %1; @trigger me/tr.success=%0, You have unblocked pages from [switch(%1, all, everyone, moniker(%1))]. You may also wish to use [switch(%1, all, msg/on, msg/unblock [moniker(%1)])] to allow them to contact you IC.; @assert cor(t(xget(%0, block-all)), t(xget(%0, blocked-PCs)))={ @trigger me/tr.lock-clear=%0; };

&tr.unblock-person [v(d.bc)]=@break strmatch(%1, all); &blocked-PCs %0=setdiff(xget(%0, blocked-PCs), u(fn.get-alts, %1)); &blocks %0=setdiff(xget(%0, blocks), %1);

&cmd-+block/clear [v(d.bc)]=$+block/clear:@assert or(t(xget(%#, blocked-PCs)), t(setr(B, xget(%#, blocks))), t(setr(A, xget(%#, block-all))))={ @trigger me/tr.error=%#, You currently aren't blocking anyone.; }; @wipe %#/blocked-PCs; @wipe %#/block-all; @wipe %#/blocks; @trigger me/tr.success=%#, You have [switch(t(%qB)%qA, 10, unblocked [itemize(iter(%qB, moniker(itext(0)),, |), |)], 01, re-enabled pages for everyone, 11, unblocked [itemize(iter(%qB, moniker(itext(0)),, |), |)]%, and re-enabled pages for everyone, cleared your block list)].

&cmd-+block/who [v(d.bc)]=$+block/who:@trigger me/tr.+block/who=%#;

&cmd-+block [v(d.bc)]=$+block:@trigger me/tr.+block/who=%#;

&cmd-+block/list [v(d.bc)]=$+block/list:@trigger me/tr.+block/who=%#;

&cmd-+whitelist [v(d.bc)]=$+whitelist:@trigger me/tr.+block/who=%#;

&cmd-+blocks [v(d.bc)]=$+blocks:@trigger me/tr.+block/who=%#;

&tr.+block/who [v(d.bc)]=@assert or(t(xget(%0, blocked-PCs)), t(setr(B, xget(%0, blocks))), t(setr(A, xget(%0, block-all))), t(setr(W, xget(%0, whitelisted-PCs))))={ @trigger me/tr.error=%0, You currently aren't blocking or whitelisting anyone.; }; @trigger me/tr.error=%0, You are currently blocking pages from [switch(t(%qB)%qA, 10, itemize(iter(%qB, moniker(itext(0)),, |), |), 01, everyone, 11, everyone%, as well as [itemize(iter(%qB, moniker(itext(0)),, |), |)] specifically, no one)]. [if(t(%qW), You have whitelisted the following people: [itemize(iter(%qW, moniker(itext(0)),, |), |)])]

&cmd-+whitelist_name [v(d.bc)]=$+whitelist *:@assert t(setr(P, ulocal(f.find-player, %0, %#)))={ @trigger me/tr.error=%#, Could not find a player named '%0'.; }; @break isstaff(%qP)={ @trigger me/tr.error=%#, [moniker(%qP)] is staff and doesn't need to be whitelisted.; }; @trigger me/tr.+whitelist=%#, %qP;

&tr.+whitelist [v(d.bc)]=@trigger me/tr.lock-setup=%0; &whitelisted-PCs %0=setunion(xget(%0, whitelisted-PCs), %1); @trigger me/tr.success=%0, You have whitelisted [moniker(%1)]. They will be able to page you even when you have blocked pages from everyone. To remove them, +blacklist [moniker(%1)].;

&cmd-+blacklist [v(d.bc)]=$+blacklist *:@break strmatch(%0, all)={ @trigger me/tr.+whitelist/clear=%#; }; @assert t(setr(P, ulocal(f.find-player, %0, %#)))={ @trigger me/tr.error=%#, Could not find a player named '%0'.; }; @assert member(xget(%#, whitelisted-PCs), %qP)={ @trigger me/tr.error=%#, [moniker(%qP)] is not currently whitelisted, so cannot be blacklisted. Did you mean +block?; }; @trigger me/tr.+blacklist=%#, %qP;

&tr.+blacklist [v(d.bc)]=@trigger me/tr.lock-setup=%0; &whitelisted-PCs %0=setdiff(xget(%0, whitelisted-PCs), %1); @trigger me/tr.success=%0, You have removed [moniker(%1)] from your whitelist. They will no longer be able to page you when you have blocked pages from everyone.;

&cmd-+whitelist/clear [v(d.bc)]=$+whitelist/clear:@trigger me/tr.+whitelist/clear=%#;

&tr.+whitelist/clear [v(d.bc)]=@assert t(setr(W, xget(%0, whitelisted-PCs)))={ @trigger me/tr.error=%0, You currently aren't whitelisting anyone.; }; @wipe %0/whitelisted-PCs; @trigger me/tr.success=%0, You have cleared your whitelist, which contained [itemize(iter(%qW, moniker(itext(0)),, |), |)]. They will no longer be able to page you when you have blocked pages from everyone.

@@ =============================================================================
@@ +beginner
@@ =============================================================================

/*
CMD-BEGINNER: $+beginner:@pemit %#=[center(Commands for Beginning MUSHers,78,
 )]%R%RMUSH is new to some of you and probably a little daunting. To ease your
 feelings of panic, we offer a very basic list of commands that will get you
 looking around and using the various features of the game.%R%R"<message>[
 space(16)]You say <message>%RSay <message> [space(12)]See above.%Rooc
 <message>[space(13)]Makes an OOC statement or pose.%Rpage <person>=<message>[
 space(3)]Pages <person> with <message>%Rlook[space(22)]Shows you the room you
 are standing in.%Rlook <object or person>[space(3)]Shows the desc for that
 object or person%Rpose <message>[space(12)]You pose <message> EX: pose
 grins.->John Doe grins.%R:<message>[space(16)]See 'pose" above%RWHO[space(23)]
 Shows a list of who is connected to the MUSH%R+who[space(22)]Shows a modified
 WHO.%R+help[space(21)]The global +help system.%R+staff[space(20)]Shows
 connected Staff%R+staff/all[space(16)]Shows the staff roster.%R%RNOTE: MUSH
 commands may be case sensitive. You can always page a staffer for help.%R%r"+
 beginner" recalls this file%R

&d.beginner-commands [v(d.bd)]=page

&d.example-page [v(d.bd)]=p [moniker(first(v(d.staff-list)))]=Hi, I'm new and I have some questions!

Welcome to [mudname()]!

If you've never MU*d before, you might like this handy list of commands:

[indent][ansi(first(themecolors()), +)]
*/
