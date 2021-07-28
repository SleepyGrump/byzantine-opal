@@ Requires:
@@ - alert()
@@ - isstaff()
@@ - header()
@@ - footer()
@@ - title() (to capitalize words correctly)
@@ - The "APPROVED" flag
@@ -
@@ All required functions can be found in my byzantine-opal repo under commands/Basic Commands. The "APPROVED" flag, you'll need to add yourself in your netmux.conf file.
@@ -


/*

Commands:

	+channel - list all channels
	+channel/join <title> - join a channel with the default alias
	+channel/join <title>=<password> - join a password-protected channel
	+channel/create <title>
	+channel/create <title>=<details>

	+channel/claim <existing channel> - (staff only) claim an existing channel and make it possible to administer the channel via this system. Will automatically create a channel log for this channel. If one already exists, use the second form of this command.

	+channel/claim <existing channel>=<dbref> - as above, but with an existing log object.

	+channel/give <channel>=<player> - give a channel you administer to someone else.

	+channel/history <channel> - staff only, see the last 10 history entries
	+channel/history <channel>=<#> - same, last # history of the channel


Only the owner (or staff) can perform the following commands:

	+channel/header <title>=<value> - set a channel's header (the "<format>" part)
	+channel/desc <title>=<value> - set a channel's description

	+channel/public <title> - set a channel public
	+channel/private <title> - set a channel private
	+channel/staff <title> - set a channel staff-only (only usable by staffers) - set it public or private to unset.
	+channel/approved <title> - set a channel approved-only - set it public or private to unset.
	+channel/password <title>=<value> - set a channel's password - set it public or private to unset

	+channel/spoof <title> - set a channel spoofable (anonymous)
	+channel/nospoof <title> - set a channel non-spoofable (not anonymous)

	+channel/loud <title> - set a channel noisy (emits connects/disconnects)
	+channel/quiet <title> - set a channel quiet (no connects/disconnects)

	+channel/destroy <title> - nukes a channel (must be the owner or staff)

	+channel/cleanup - deletes any channel which meets all of these criteria:
		- No one has spoken on the channel in the last 180 days.
		- The owner has not logged in in over 180 days.
		- The owner is not staff.

	Note: This code only locks channels to staff and approved characters. Channels that are locked this way are set Private and locked to the isstaff or isapproved function. Making the channel public unlocks it. If you want to implement another kind of lock, you'll have to implement it manually with something like this:

	@lock <channel object>=CHAN-LOCK/1
	&CHAN-LOCK <channel object>=match(xget(%#, group), My Secret Group)
	@cpflags <ChannelName>=!join

TODO: Clean up +channel <title> so that the lists of players don't reveal the names of the players if the channel is spoofed. (Use comtitles instead.)

Changes:
2021-07-27:
 - Implemented the simplest lock system imaginable. Should cover 90% of players' needs! +channel/staff, +channel/approved, +channel/password. Tadaaaa.
 - Changed the code to rely on data attributes so I don't have to @tel the object to me to edit it.
 - Added channel aliases so that the default instructions to join them would include a decent alias.
 - Added +channel/join <name> - just sets you up with that sucker. It's basically an alias for addcom. Stupid but you know, I forget addcom when I haven't used it in a while. I will never forget +channel/join <name>.
 - Added +channel/join <name>=<password> - join that password-protected sucker.
2020-12-26:
 - Added +channel/give so players can pass control of their channels to someone else.
 - Added an automatic cleanup which fires daily, and +channel/cleanup which can fire whenever anyone needs it to.
2020-04-30:
 - Some tweaks to let the code handle channels with multiple words for their names. (Spaces, OMG!)
 - Also, turns out channel headers have a max limit of 100 characters. (Who knew. :P) This includes the evaluated stuff like colors. So now it'll warn you if you go over that limit but will still set colors correctly.
 - Changed log entries to log names with moniker.
 - Added a list of users who are on each channel to the channel details.
 - Fixed a bug with +channel/claim that caused a new history object to get created and the old one to be ignored.
 - Added a history option, staff only.

*/

@create Channel Database <CDB>=10
@set CDB=SAFE

@create Channel Functions <CHF>=10
@set CHF=SAFE INHERIT
@force me=@parent CHF=[v(d.bf)]

@create Channel Commands <CHC>=10
@set CHC=SAFE INHERIT OPAQUE
@parent CHC=CHF

@force me=&d.chc me=[search(ETHING=t(member(name(##), Channel Commands <CHC>, |)))]
@force me=&d.chf me=[search(ETHING=t(member(name(##), Channel Functions <CHF>, |)))]
@force me=&d.cdb me=[search(ETHING=t(member(name(##), Channel Database <CDB>, |)))]

@force me=&d.channel-functions [v(d.bd)]=[v(d.chf)]

@force me=&vD [v(d.chf)]=[v(d.cdb)]

@daily [v(d.chf)]=@trigger me/tr.channel-cleanup;

@desc [v(d.chc)]=%RCommands:%R%R[space(3)]+channel - list all channels%R[space(3)]+channel/join <title> - join a channel with the default alias%R[space(3)]+channel/join <title>=<password> - join a password-protected channel%R[space(3)]+channel/create <title>%R[space(3)]+channel/create <title>=<details>%R%R[space(3)]+channel/claim <existing channel> - (staff only) claim an existing channel and make it possible to administer the channel via this system. Will automatically create a channel log for this channel. If one already exists, use the second form of this command.%R%R[space(3)]+channel/claim <existing channel>=<dbref> - as above, but with an existing log object.%R%R[space(3)]+channel/give <channel>=<player> - give a channel you administer to someone else.%R%R[space(3)]+channel/history <channel> - staff only, see the last 10 history entries%R[space(3)]+channel/history <channel>=<#> - same, last # history of the channel%R%ROnly the owner (or staff) can perform the following commands:%R%R[space(3)]+channel/header <title>=<value> - set a channel's header (the "<format>" part)%R[space(3)]+channel/desc <title>=<value> - set a channel's description%R[space(3)]+channel/alias <title>=<value> - set a channel's alias. Players can still change this.%R%R[space(3)]+channel/public <title> - set a channel public%R[space(3)]+channel/private <title> - set a channel private%R[space(3)]+channel/staff <title> - set a channel staff-only (only usable by staffers) - set it public or private to unset%R[space(3)]+channel/approved <title> - set a channel approved-only - set it public or private to unset%R[space(3)]+channel/password <title>=<value> - set a channel's password - set it public or private to unset%R%R[space(3)]+channel/spoof <title> - set a channel spoofable (anonymous)%R[space(3)]+channel/nospoof <title> - set a channel non-spoofable (not anonymous)%R%R[space(3)]+channel/loud <title> - set a channel noisy (emits connects/disconnects)%R[space(3)]+channel/quiet <title> - set a channel quiet (no connects/disconnects)%R%R[space(3)]+channel/destroy <title> - nukes a channel (must be the owner or staff)%R%R[space(3)]+channel/cleanup - deletes any channel which meets all of these criteria:%R[space(3)][space(3)]- No one has spoken on the channel in the last 180 days.%R[space(3)][space(3)]- The owner has not logged in in over 180 days.%R[space(3)][space(3)]- The owner is not staff.%R

@@ Add your channels here, separated by |'s.
@@ This should be whatever shows up in @clist.
@@ -
@@ This is really only for channels created not using this system, since there's no way to get a list of them separated by pipes (vital since it's possible to have multi-word channel names). If you haven't created any channels yet, leave it blank.

&d.existing-channels [v(d.cdb)]=

@@ How many channels are non-staffers allowed to create?
@@ Set to 0 to disable player creation of channels.

&d.max-player-channels [v(d.cdb)]=1


@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Layouts
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

@@ %0 - error message
&layout.error [v(d.chf)]=alert(Channel error) %0

@@ %0 - message
&layout.msg [v(d.chf)]=alert(Channel) %0

@@ %0 - user
&layout.channels [v(d.chf)]=strcat(header(Channels, %0), %r, multicol(strcat(Name|Owner|Status|Description|, iter(ulocal(f.get-channels, %0), strcat(setq(O, ulocal(f.get-channel-owner, itext(0))), ulocal(f.get-channel-name, itext(0)), |, if(isstaff(%qO), Staff, ulocal(f.get-name, %qO, %0)), |, ulocal(f.get-channel-lock, itext(0)), |, ulocal(f.get-channel-desc, itext(0))),, |)), 20 15 18 *, 1, |, %0), %R, footer(+channel <name> for details, %0))

@@ %0 - dbref of channel object
@@ %1 - user
&layout.channel-details [v(d.chf)]=strcat(setq(N, ulocal(f.get-channel-name, %0)), setq(O, ulocal(f.get-channel-owner, %0)), header(strcat(%qN channel details, if(isstaff(%1), %b%(%0%))), %1), %r, multicol(strcat(Owner:, |, ulocal(f.get-name, %qO, %1) %(%qO%), |, Description:, |, ulocal(f.get-channel-desc, %0), |, Connected members:, |, ulocal(layout.player-list, cwho(%qN, on))), 20 *, 0, |, %1), if(ulocal(f.can-modify-channel, %1, %0), ulocal(layout.channel-admin-details, %0, %1, %qN)), %r, footer(, %1))

@@ %0 - dbref of channel object
@@ %1 - user
@@ %2 - channel name
&layout.channel-admin-details [v(d.chf)]=strcat(%r, divider(Channel admin details, %1), %r, multicol(strcat(Details:, |, ulocal(f.get-channel-details, %0), |, Status:, |, ulocal(f.get-channel-lock, %0), |, if(t(setr(P, ulocal(f.get-channel-password, %0))), Password:|%qP|), All members:, |, ulocal(layout.player-list, cwho(%2, all))), 20 *, 0, |, %1))

@@ %0 - list of players
@@ %1 - user
&layout.player-list [v(d.chf)]=itemize(iter(%0, case(idle(itext(0)), -1, %ch%cx[name(itext(0))]%cn, ulocal(f.get-name, itext(0), %1)),, |), |)

@@ %0 - dbref of channel object
@@ %1 - number of records to display
@@ %2 - user
&layout.channel-history [v(d.chf)]=strcat(setq(R, if(t(%1), %1, 10)), header(ulocal(f.get-channel-name, %0) channel history - last %qR, %2), %r, iter(ulocal(f.last-x-history, %0, %qR), xget(%0, itext(0)),, %r), %r, footer(, %2))

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Local functions
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

@@ %0 - dbref of channel
@@ %1 - player
&f.can-see-channel [v(d.chf)]=cor(isstaff(%1), not(t(xget(%0, channel.lock))), t(ulocal(%0/channel.lock, %1)))

@@ %0 - player
&f.get-channels [v(d.chf)]=filter(f.can-see-channel, edit(lattr(%vD/channel.*), CHANNEL.,),,, %0)

@@ %0 - player
&f.can-create-channels [v(d.chf)]=or(isstaff(%0), and(hasflag(%0, APPROVED), lt(words(xget(%0, _channels-created)), xget(%vD, d.max-player-channels))))

@@ %0 - the command input
&f.find-command-switch [v(d.chf)]=strcat(setq(0,), setq(1,), setq(2, switch(%0, /*/*, first(rest(first(%0), /), /), /*, rest(first(%0), /), )), null(iter(sort(lattr(%!/switch.*.%q2*)), case(1, match(last(itext(0), .), %q2), setq(0, %q0 [itext(0)]), strmatch(last(itext(0), .), %q2*), setq(1, %q1 [itext(0)])))), trim(if(t(%q0), first(%q0), %q1), b))

@@ %0 - player
@@ %1 - dbref of channel
&f.can-modify-channel [v(d.chf)]=cor(isstaff(%0), cand(hasflag(%0, APPROVED), match(ulocal(f.get-channel-owner, %1), %0, |)))

@@ %0 - title of channel
&f.get-channel-dbref [v(d.chf)]=squish(trim(iter(lattr(%vD/channel.*), if(match(ulocal(f.get-channel-name, rest(itext(0), .)), %0, |), rest(itext(0), .)))))

@@ %0 - dbref of channel
&f.get-channel-owner [v(d.chf)]=xget(%0, creator-dbref)

@@ %0 - dbref of channel
&f.get-channel-name [v(d.chf)]=xget(%0, channel-name)

@@ %0 - dbref of channel
&f.get-channel-details [v(d.chf)]=xget(%vD, channel.%0)

@@ %0 - dbref of channel
&f.get-channel-alias [v(d.chf)]=xget(%0, channel-alias)

@@ %0 - dbref of channel
&f.get-channel-password [v(d.chf)]=xget(%0, channel-password)

@@ %0 - dbref of channel
&f.get-channel-desc [v(d.chf)]=xget(%0, desc)

@@ %0 - dbref of channel
&f.get-channel-lock [v(d.chf)]=xget(%0, channel.lock-status)

@@ %0 - name of channel
&f.get-channel-alias-by-name [v(d.chf)]=strcat(setq(D, ulocal(f.get-channel-dbref, %0)), default(%qD/channel-alias, switch(%0, Chargen, cg, Staff, st, strtrunc(lcstr(%0), 3))))

@@ %0 - title of the new channel
&f.is-banned-name [v(d.chf)]=ladd(strcat(iter(lattr(%vD/channel.*), match(ulocal(f.get-channel-name, rest(itext(0), .)), %0, |)), %b, match(default(%vD/d.existing-channels, 0), %1, |)))

@@ %0 - new alias of the channel
&f.is-banned-alias [v(d.chf)]=ladd(iter(lattr(%vD/channel.*), match(ulocal(f.get-channel-alias, rest(itext(0), .)), %0, |)))

@@ %0 - title of channel
&f.clean-channel-name [v(d.chf)]=title(%0)

@@ %0 - sort option A
@@ %1 - sort option B
&f.sort-history [v(d.chf)]=comp(convtime(%0), convtime(%1))

&f.sort-munge [v(d.chf)]=sortby(f.sort-history, %0, |, |)

@@ %0 - dbref of channel
@@ %1 - number of history records to return
&f.last-x-history [v(d.chf)]=revwords(extract(revwords(munge(f.sort-munge, iter(lattr(%0/history_*), first(rest(xget(%0, itext(0)), \[), \]),, |), edit(lattr(%0/history_*), %b, |), |), |, |), 1, if(t(%1), %1, 10), |), |, %b)

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Command manager
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

&cmd-+channel [v(d.chc)]=$+channel*:@switch setr(E, strcat(setq(C, ulocal(f.find-command-switch, %0)), if(not(t(%qC)), Could not find command: +channel%0)))=, { @trigger me/%qC=%#, %0; }, { @pemit %#=ulocal(layout.error, %qE); }

@set [v(d.chc)]/cmd-+channel=no_parse

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Command switches
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

&switch.0.s [v(d.chc)]=@pemit %0=ulocal(layout.channels, %0);

&switch.1. [v(d.chc)]=@pemit %0=if(and(t(trim(%1)), not(strmatch(%1, s*))), if(t(setr(0, ulocal(f.get-channel-dbref, trim(%1)))), ulocal(layout.channel-details, %q0, %0), ulocal(layout.error, Could not find channel '[trim(%1)]')), ulocal(layout.channels, %0));

&switch.1.create [v(d.chc)]=@trigger me/tr.channel-create=%0, rest(%1);

&switch.1.join [v(d.chc)]=@switch/first %1=*=*, { @trigger me/tr.channel-join-with-password=%0, first(rest(%1), =), rest(%1, =); }, { @trigger me/tr.channel-join=%0, rest(%1); }

&switch.2.header [v(d.chc)]=@trigger me/tr.channel-header=%0, before(rest(%1), =), rest(%1, =);

&switch.2.desc [v(d.chc)]=@trigger me/tr.channel-desc=%0, before(rest(%1), =), rest(%1, =);

&switch.2.alias [v(d.chc)]=@trigger me/tr.channel-alias=%0, before(rest(%1), =), rest(%1, =);

&switch.3.spoof [v(d.chc)]=@trigger me/tr.channel-spoof=%0, rest(%1);

&switch.3.nospoof [v(d.chc)]=@trigger me/tr.channel-nospoof=%0, rest(%1);

&switch.4.public [v(d.chc)]=@trigger me/tr.channel-public=%0, rest(%1);

&switch.4.private [v(d.chc)]=@trigger me/tr.channel-private=%0, rest(%1);

&switch.4.staff [v(d.chc)]=@trigger me/tr.channel-staff=%0, rest(%1);

&switch.4.approved [v(d.chc)]=@trigger me/tr.channel-approved=%0, rest(%1);

&switch.4.password [v(d.chc)]= @trigger me/tr.channel-password=%0, first(rest(%1), =), rest(%1, =);

&switch.5.loud [v(d.chc)]=@trigger me/tr.channel-loud=%0, rest(%1);

&switch.5.quiet [v(d.chc)]=@trigger me/tr.channel-quiet=%0, rest(%1);

&switch.6.claim [v(d.chc)]=@trigger me/tr.channel-claim=%0, first(rest(%1), =), rest(%1, =);

&switch.6.give [v(d.chc)]=@trigger me/tr.channel-give=%0, first(%1, =), rest(%1, =);

&switch.7.history [v(d.chc)]=@trigger me/tr.channel-history=%0, first(rest(%1), =), rest(%1, =);

&switch.7.last [v(d.chc)]=@trigger me/tr.channel-history=%0, first(rest(%1), =), rest(%1, =);

&switch.98.cleanup [v(d.chc)]=@trigger me/tr.channel-cleanup=%0;

&switch.99.destroy [v(d.chc)]=@switch/first %1=*=*, { @trigger me/tr.destroy-channel=%0, first(rest(%1), =), rest(%1, =); }, { @trigger me/tr.confirm-destroy=%0, rest(%1); }


@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Triggers
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

@@ Input:
@@ %0 - %#
@@ %1 - channel title
&tr.channel-join [v(d.chc)]=@switch setr(E, trim(squish(strcat(if(not(t(setr(N, ulocal(f.get-channel-dbref, setr(T, ulocal(f.clean-channel-name, %1)))))), Could not find channel '%qT'. Please use the exact name of the channel you wish to join.), setq(A, comalias(%0, %qT)), if(not(t(%qA)), setq(D, ulocal(f.get-channel-alias-by-name, %qT)))))))=, { @switch t(%qA)=1, { @force %0={ %qA on; }; }, { @force %0={ addcom %qD=%qT }; }; @assert t(setr(D, comalias(%0, %qT))); @pemit %0=strcat(ulocal(layout.msg, Joined %qT with alias %qD. A quick refresher on the commands:%R%T%qD <stuff> - talk on channel%R%T%qD off - leave channel%R%T%qD on - join channel%R%T%qD who - see who's on%R%T%qD last 10 - see last 10 messages)); }, { @pemit %0=ulocal(layout.error, %qE); }

@@ Input:
@@ %0 - %#
@@ %1 - channel title
@@ %2 - password
&tr.channel-join-with-password [v(d.chc)]=@switch setr(E, trim(squish(strcat(if(not(t(setr(N, ulocal(f.get-channel-dbref, setr(T, ulocal(f.clean-channel-name, %1)))))), Could not find channel '%qT'. Please use the exact name of the channel you wish to join.), setq(A, comalias(%0, %qT)), if(not(t(%qA)), setq(D, ulocal(f.get-channel-alias-by-name, %qT)))))))=, { @set %0=_channel-password-%qN:%2; @switch t(%qA)=1, { @force %0={ %qA on; }; }, { @force %0={ addcom %qD=%qT }; }; @assert t(setr(D, comalias(%0, %qT))); @pemit %0=strcat(ulocal(layout.msg, Joined %qT with alias %qD. A quick refresher on the commands:%R%T%qD <stuff> - talk on channel%R%T%qD off - leave channel%R%T%qD on - join channel%R%T%qD who - see who's on%R%T%qD last 10 - see last 10 messages)); }, { @pemit %0=ulocal(layout.error, %qE); }

@@ Input:
@@ %0 - %#
@@ %1 - channel title
&tr.channel-create [v(d.chc)]=@switch setr(E, trim(squish(strcat(if(not(ulocal(f.can-create-channels, %0)), You are not allowed to create channels. This could be because players are not permitted to create channels or because you have already created your max quota of channels.), %b, if(not(t(setr(T, ulocal(f.clean-channel-name, first(%1, =))))), You need to include a title for the new channel.), %b, if(t(ulocal(f.is-banned-name, %qT)), You can't use the name '%qT' because it is in use or not allowed.), setq(D, rest(%1, =))))))=, { @switch setr(E, if(t(setr(N, create(%qT Channel Object, 10))),, Could not create '%qT Channel Object'. %qN))=, { @set %vD=channel.%qN:[strcat(%qT was created by, %b, moniker(%0) %(%0%) on, %b, time()., if(t(%qD), %bIts description was set to: '%qD'.))]; @set %qN=channel-name:%qT; @set %qN=channel-alias:[if(ulocal(f.is-banned-alias, setr(A, ulocal(f.get-channel-alias-by-name, %qT))), setr(A, lcstr(%qT)), %qA)]; @set %qN=creator-dbref:%0; @ccreate %qT; @cset/object %qT=%qN; @desc %qN=[if(t(%qD), %qD, The '%qT' channel.)]; @cset/log %qT=200; @cset/timestamp_logs %qT=1; @cset/private %qT; @set %0=_channels-created:[setunion(%qN, xget(%0, _channels-created))]; @set %qN=channel.lock-status:Private; @pemit %0=strcat(ulocal(layout.msg, Channel '%qT' created.), %r, ulocal(layout.msg, The channel has been automatically set 'Private'. +channel/public %qT if you want to change it.), %r, ulocal(layout.msg, This channel was automatically set 'Nospoof'. You can allow spoofing with +channel/spoof %qT.), %r, ulocal(layout.msg, To set your channel header%, type +channel/header %qT=<your decorative header containing %qT for the channel name>. Color codes are allowed. Headers may be a max of 100 characters long.), %r, ulocal(layout.msg, The default alias of your new channel is %qA. To change this%, type +channel/alias %qT=<your alias>. Aliases should be 2-3 characters long.)); }, { @pemit %0=ulocal(layout.error, %qE); }; }, { @pemit %0=ulocal(layout.error, %qE); }

@@ Input:
@@ %0 - %#
@@ %1 - channel title
@@ %2 - header
&tr.channel-header [v(d.chc)]=@switch setr(E, trim(squish(strcat(if(not(t(setr(N, ulocal(f.get-channel-dbref, setr(T, ulocal(f.clean-channel-name, %1)))))), Could not find channel '%qT'. You must use the exact name of the channel you wish to modify.), %b, if(not(ulocal(f.can-modify-channel, %0, %qN)), You are not staff or the owner of the channel '%qT' and cannot change it.), %b, if(not(t(%2)), You need to include a header value for the channel.), %b, if(gt(strlen(%2), 100), Channel headers are limited to a max of 100 characters by hardcode.)))))=, { @set %vD=channel.%qN:[strcat(xget(%vD, channel.%qN), %b, Header changed to '%2' on, %b, time(), %b, by, %b, moniker(%0) %(%0%).)]; @force me=@cset/header %qT=%2; @pemit %0=ulocal(layout.msg, Changed the header of '%qT' to '%2'.); }, { @pemit %0=ulocal(layout.error, %qE); }

@@ Input:
@@ %0 - %#
@@ %1 - channel title
@@ %2 - description
&tr.channel-desc [v(d.chc)]=@switch setr(E, trim(squish(strcat(if(not(t(setr(N, ulocal(f.get-channel-dbref, setr(T, ulocal(f.clean-channel-name, %1)))))), Could not find channel '%qT'. You must use the exact name of the channel you wish to modify.), %b, if(not(ulocal(f.can-modify-channel, %0, %qN)), You are not staff or the owner of the channel '%qT' and cannot change it.), setq(D, if(not(t(%2)), The '%qT' channel., %2))))))=, { @set %vD=channel.%qN:[strcat(xget(%vD, channel.%qN), %b, Desc changed to '%qD' on, %b, time(), %b, by, %b, moniker(%0) %(%0%).)]; @desc %qN=%qD; @pemit %0=ulocal(layout.msg, Changed the desc of '%qT' to '%qD'.); }, { @pemit %0=ulocal(layout.error, %qE); }

@@ Input:
@@ %0 - %#
@@ %1 - channel title
@@ %2 - alias
&tr.channel-alias [v(d.chc)]=@switch setr(E, trim(squish(strcat(if(not(t(setr(N, ulocal(f.get-channel-dbref, setr(T, ulocal(f.clean-channel-name, %1)))))), Could not find channel '%qT'. You must use the exact name of the channel you wish to modify.), %b, if(t(ulocal(f.is-banned-alias, %2)), You can't use the alias '%2' because it is already in use.), %b, if(not(ulocal(f.can-modify-channel, %0, %qN)), You are not staff or the owner of the channel '%qT' and cannot change it.), setq(D, if(not(t(%2)), The '%qT' channel., %2))))))=, { @set %vD=channel.%qN:[strcat(xget(%vD, channel.%qN), %b, Alias changed to '%qD' on, %b, time(), %b, by, %b, moniker(%0) %(%0%).)]; &channel-alias %qN=%qD; @pemit %0=ulocal(layout.msg, Changed the alias of '%qT' to '%qD'.); }, { @pemit %0=ulocal(layout.error, %qE); }

@@ Input:
@@ %0 - %#
@@ %1 - channel title
&tr.channel-public [v(d.chc)]=@switch setr(E, trim(squish(strcat(if(not(t(setr(N, ulocal(f.get-channel-dbref, setr(T, ulocal(f.clean-channel-name, %1)))))), Could not find channel '%qT'. You must use the exact name of the channel you wish to modify.), %b, if(not(ulocal(f.can-modify-channel, %0, %qN)), You are not staff or the owner of the channel '%qT' and cannot change it.)))))=, { @set %vD=channel.%qN:[strcat(xget(%vD, channel.%qN), %b, Set public on, %b, time(), %b, by, %b, moniker(%0) %(%0%).)]; @cset/public %qT; @cpflags %qT=join; @set %qN=channel.lock:; @set %qN=channel.lock-status:Public; @set %qN=!INHERIT; @unlock %qN; @set %qN=channel-password:; @pemit %0=ulocal(layout.msg, Changed '%qT' to 'Public'.); }, { @pemit %0=ulocal(layout.error, %qE); }

@@ Input:
@@ %0 - %#
@@ %1 - channel title
&tr.channel-private [v(d.chc)]=@switch setr(E, trim(squish(strcat(if(not(t(setr(N, ulocal(f.get-channel-dbref, setr(T, ulocal(f.clean-channel-name, %1)))))), Could not find channel '%qT'. You must use the exact name of the channel you wish to modify.), %b, if(not(ulocal(f.can-modify-channel, %0, %qN)), You are not staff or the owner of the channel '%qT' and cannot change it.)))))=, { @set %vD=channel.%qN:[strcat(xget(%vD, channel.%qN), %b, Set private on, %b, time(), %b, by, %b, moniker(%0) %(%0%).)]; @set %qN=channel.lock-status:Private; @cset/private %qT; @cpflags %qT=join; @set %qN=channel.lock:; @set %qN=!INHERIT; @unlock %qN; @set %qN=channel-password:; @pemit %0=ulocal(layout.msg, Changed '%qT' to 'Private'.); }, { @pemit %0=ulocal(layout.error, %qE); }

@@ Input:
@@ %0 - %#
@@ %1 - channel title
&tr.channel-staff [v(d.chc)]=@switch setr(E, trim(squish(strcat(if(not(t(setr(N, ulocal(f.get-channel-dbref, setr(T, ulocal(f.clean-channel-name, %1)))))), Could not find channel '%qT'. You must use the exact name of the channel you wish to modify.), %b, if(not(ulocal(f.can-modify-channel, %0, %qN)), You are not staff or the owner of the channel '%qT' and cannot change it.)))))=, { @set %vD=channel.%qN:[strcat(xget(%vD, channel.%qN), %b, Set private and staff-only on, %b, time(), %b, by, %b, moniker(%0) %(%0%).)]; @set %qN=channel.lock-status:Staff-only; @cset/private %qT; @lock %qN=CHAN-LOCK/1; @set %qN=CHAN-LOCK:isstaff\(\%#); @cpflags %qT=!join; @set %qN=!INHERIT; @set %qN=channel.lock:isstaff\(\%0\); @set %qN=channel-password:; @pemit %0=ulocal(layout.msg, Changed '%qT' to 'Staff-only'.); }, { @pemit %0=ulocal(layout.error, %qE); }

@@ Input:
@@ %0 - %#
@@ %1 - channel title
&tr.channel-approved [v(d.chc)]=@switch setr(E, trim(squish(strcat(if(not(t(setr(N, ulocal(f.get-channel-dbref, setr(T, ulocal(f.clean-channel-name, %1)))))), Could not find channel '%qT'. You must use the exact name of the channel you wish to modify.), %b, if(not(ulocal(f.can-modify-channel, %0, %qN)), You are not staff or the owner of the channel '%qT' and cannot change it.)))))=, { @set %vD=channel.%qN:[strcat(xget(%vD, channel.%qN), %b, Set private and approved-only on, %b, time(), %b, by, %b, moniker(%0) %(%0%).)]; @set %qN=channel.lock-status:Approved-only; @cset/private %qT; @lock %qN=CHAN-LOCK/1; @set %qN=CHAN-LOCK:isapproved\(\%#); @cpflags %qT=!join; @set %qN=!INHERIT; @set %qN=channel.lock:isapproved\(\%0\); @set %qN=channel-password:; @pemit %0=ulocal(layout.msg, Changed '%qT' to 'Approved-only'.); }, { @pemit %0=ulocal(layout.error, %qE); }

@@ Input:
@@ %0 - %#
@@ %1 - channel title
@@ %2 - channel password
&tr.channel-password [v(d.chc)]=@switch setr(E, trim(squish(strcat(if(not(t(setr(N, ulocal(f.get-channel-dbref, setr(T, ulocal(f.clean-channel-name, %1)))))), Could not find channel '%qT'. You must use the exact name of the channel you wish to modify.), %b, if(not(ulocal(f.can-modify-channel, %0, %qN)), You are not staff or the owner of the channel '%qT' and cannot change it.), %b, if(not(t(%2)), You must specify a password if you want to password-protect the channel.)))))=, { @set %vD=channel.%qN:[strcat(xget(%vD, channel.%qN), %b, Set private and password-protected on, %b, time(), %b, by, %b, moniker(%0) %(%0%).)]; @set %qN=channel.lock-status:Password-protected; @cset/private %qT; @lock %qN=CHAN-LOCK/1; @set %qN=CHAN-LOCK:match\(xget\(\%#, _channel-password-%qN), %2\); @set %qN=channel-password:%2; @cpflags %qT=!join; @set %qN=channel.lock:match\(xget\(\%0, _channel-password-%qN), %2\); @set %qN=INHERIT; @pemit %0=ulocal(layout.msg, Changed '%qT' to password-protected with the password '%2'.); }, { @pemit %0=ulocal(layout.error, %qE); }

@@ Input:
@@ %0 - %#
@@ %1 - channel title
&tr.channel-loud [v(d.chc)]=@switch setr(E, trim(squish(strcat(if(not(t(setr(N, ulocal(f.get-channel-dbref, setr(T, ulocal(f.clean-channel-name, %1)))))), Could not find channel '%qT'. You must use the exact name of the channel you wish to modify.), %b, if(not(ulocal(f.can-modify-channel, %0, %qN)), You are not staff or the owner of the channel '%qT' and cannot change it.)))))=, { @set %vD=channel.%qN:[strcat(xget(%vD, channel.%qN), %b, Set loud on, %b, time(), %b, by, %b, moniker(%0) %(%0%).)]; @cset/loud %qT; @pemit %0=ulocal(layout.msg, Changed '%qT' to 'Loud'.); }, { @pemit %0=ulocal(layout.error, %qE); }

@@ Input:
@@ %0 - %#
@@ %1 - channel title
&tr.channel-quiet [v(d.chc)]=@switch setr(E, trim(squish(strcat(if(not(t(setr(N, ulocal(f.get-channel-dbref, setr(T, ulocal(f.clean-channel-name, %1)))))), Could not find channel '%qT'. You must use the exact name of the channel you wish to modify.), %b, if(not(ulocal(f.can-modify-channel, %0, %qN)), You are not staff or the owner of the channel '%qT' and cannot change it.)))))=, { @set %vD=channel.%qN:[strcat(xget(%vD, channel.%qN), %b, Set quiet on, %b, time(), %b, by, %b, moniker(%0) %(%0%).)]; @cset/quiet %qT; @pemit %0=ulocal(layout.msg, Changed '%qT' to 'Quiet'.); }, { @pemit %0=ulocal(layout.error, %qE); }

@@ Input:
@@ %0 - %#
@@ %1 - channel title
&tr.channel-spoof [v(d.chc)]=@switch setr(E, trim(squish(strcat(if(not(t(setr(N, ulocal(f.get-channel-dbref, setr(T, ulocal(f.clean-channel-name, %1)))))), Could not find channel '%qT'. You must use the exact name of the channel you wish to modify.), %b, if(not(ulocal(f.can-modify-channel, %0, %qN)), You are not staff or the owner of the channel '%qT' and cannot change it.)))))=, { @set %vD=channel.%qN:[strcat(xget(%vD, channel.%qN), %b, Set spoofable on, %b, time(), %b, by, %b, moniker(%0) %(%0%).)]; @cset/spoof %qT; @pemit %0=ulocal(layout.msg, Changed '%qT' to 'Spoofable'.); }, { @pemit %0=ulocal(layout.error, %qE); }

@@ Input:
@@ %0 - %#
@@ %1 - channel title
&tr.channel-nospoof [v(d.chc)]=@switch setr(E, trim(squish(strcat(if(not(t(setr(N, ulocal(f.get-channel-dbref, setr(T, ulocal(f.clean-channel-name, %1)))))), Could not find channel '%qT'. You must use the exact name of the channel you wish to modify.), %b, if(not(ulocal(f.can-modify-channel, %0, %qN)), You are not staff or the owner of the channel '%qT' and cannot change it.)))))=, { @set %vD=channel.%qN:[strcat(xget(%vD, channel.%qN), %b, Set non-spoofable on, %b, time(), %b, by, %b, moniker(%0) %(%0%).)]; @cset/nospoof %qT; @pemit %0=ulocal(layout.msg, Changed '%qT' to 'Non-spoofable'.); }, { @pemit %0=ulocal(layout.error, %qE); }


@@ Input:
@@ %0 - %#
@@ %1 - channel title
@@ %2 - existing log object (if exists)
&tr.channel-claim [v(d.chc)]=@assert isstaff(%0)={ @pemit %0=ulocal(layout.error, Staff only.); }; @assert t(comalias(%0, %1))={ @pemit %0=ulocal(layout.error, Can't find a channel you joined named '%1'. Please enter the exact name of the channel - it is case sensitive - and make sure you have joined the channel.); }; @assert cor(cand(isdbref(%2), match(type(%2), THING), t(setr(N, %2))), t(setr(N, create(%1 Channel Object, 10))))={ @pemit %0=ulocal(layout.error, if(t(%2), '%2' is not a valid channel log object., Could not create '%1 Channel Object'.)); }; @set %vD=channel.%qN:[strcat(%1 was claimed by, %b, moniker(%0) %(%0%) on, %b, time().)]; @set %qN=channel-name:%1; @set %qN=creator-dbref:%0; @cset/object %1=%qN; @desc %qN=[default(%qN/desc, The '%1' channel.)]; @cset/log %1=200; @cset/timestamp_logs %1=1; @set %0=_channels-created:[setunion(%qN, xget(%0, _channels-created))]; @set %vD=d.existing-channels:[setdiff(xget(%vD, d.existing-channels), %1, |)]; @pemit %0=ulocal(layout.msg, Channel '%1' claimed. It's yours now. Take good care of it!);


@@ Input:
@@ %0 - %#
@@ %1 - channel title
@@ %2 - player the channel is to be given to
&tr.channel-give [v(d.chc)]=@assert t(comalias(%0, %1))={ @pemit %0=ulocal(layout.error, Can't find a channel you joined named '%1'. Please enter the exact name of the channel - it is case sensitive - and make sure you have joined the channel.); }; @assert t(setr(P, switch(%2, me, %0, pmatch(%2))))={ @pemit %0=ulocal(layout.error, Cannot find a player named '%2'.); }; @assert ulocal(f.can-create-channels, %qP)={ @pemit %0=ulocal(layout.error, name(%qP) cannot create channels%, either because they are at the max number of channels already%, or because they are not approved%, or because player-owned channels are disabled.); }; @assert match(ulocal(f.get-channel-owner, %1), %0)={ @pemit %0=ulocal(layout.error, You must own the channel you're giving away.); }; @set %vD=channel.%qN:[strcat(%1 was given to, %b, moniker(%qP) %(%qP%) by, %b, moniker(%0) %(%0%) on, %b, time().)]; @set %qN=creator-dbref:%0; @set %0=_channels-created:[setdiff(%qN, xget(%0, _channels-created))]; @set %qP=_channels-created:[setunion(%qN, xget(%qP, _channels-created))]; @pemit %0=ulocal(layout.msg, Channel '%1' given to [moniker(%qP)]!); @pemit %qP=ulocal(layout.msg, moniker(%0) just gave you channel %qN to administer. Type +help Channels to find out more!);


@@ Input:
@@ %0 - %#
@@ %1 - channel title
@@ %2 - number of history rows to check (if sent)
&tr.channel-history [v(d.chc)]=@assert isstaff(%0)={ @pemit %0=ulocal(layout.error, Staff only.); }; @switch setr(E, trim(squish(strcat(if(not(t(setr(N, ulocal(f.get-channel-dbref, setr(T, ulocal(f.clean-channel-name, %1)))))), Could not find channel '%qT'. You must use the exact name of the channel you wish to modify.), %b, if(not(ulocal(f.can-modify-channel, %0, %qN)), You are not staff or the owner of the channel '%qT' and cannot change it.)))))=, { @pemit %0=ulocal(layout.channel-history, %qN, %2, %0); }, { @pemit %0=ulocal(layout.error, %qE); }

@@ Input:
@@ %0 - %#
&tr.channel-cleanup [v(d.chc)]=@dolist lattr(%vD/channel.*)={ @assert not(isstaff(setr(O, ulocal(f.get-channel-owner, setr(N, rest(##, .)))))); @assert not(hasflag(%qO, CONNECTED)); @assert not(hasflag(%qO, CONNECTED));  @assert gt(sub(secs(), convtime(xget(%qO, last))), 15552000); @assert t(setr(T, ulocal(f.clean-channel-name, %qN))); @cdestroy %qT; @wipe %vD/channel.%qN; @destroy %qN; @pemit %0=alert(Channel) The channel '%qT' has been destroyed.; }; @pemit %0=alert(Channel) Cleanup complete.;

@@ Input:
@@ %0 - %#
@@ %1 - title
&tr.confirm-destroy [v(d.chc)]=@switch setr(E, trim(squish(strcat(if(not(t(setr(N, ulocal(f.get-channel-dbref, setr(T, ulocal(f.clean-channel-name, %1)))))), Could not find channel '%qT'. You must use the exact name of the channel you wish to modify.), %b, if(not(ulocal(f.can-modify-channel, %0, %qN)), You are not staff or the owner of the channel '%qT' and cannot change it.)))))=, { @set %0=_channel-nuke:%qN|[secs()]; @pemit %0=ulocal(layout.msg, Before you continue%, make absolutely certain that %qT is the channel you want to destroy. There are [words(cwho(%1, on))] people on this channel. If you're absolutely certain you want to destroy this channel%, type +channel/destroy %qT=YES within the next 5 minutes. It is now [prettytime()].); }, { @pemit %0=ulocal(layout.error, %qE); }


@@ Input:
@@ %0 - %#
@@ %1 - title
@@ %2 - hopefully 'YES'
&tr.destroy-channel [v(d.chc)]=@switch setr(E, trim(squish(strcat(if(not(t(setr(N, ulocal(f.get-channel-dbref, setr(T, ulocal(f.clean-channel-name, %1)))))), Could not find channel '%qT'. You must use the exact name of the channel you wish to modify.), %b, if(not(ulocal(f.can-modify-channel, %0, %qN)), You are not staff or the owner of the channel '%qT' and cannot change it.), %b, setq(W, xget(%0, _channel-nuke)), if(cor(not(strmatch(%qN, first(%qW, |))), gt(sub(secs(), rest(%qW, |)), 300), not(match(%2, YES))), Your destruction timeout expired or you didn't type 'YES'. Please try again.)))))=, { @cdestroy %qT; @wipe %vD/channel.%qN; @destroy %qN; @pemit %0=alert(Channel) The channel '%qT' has been destroyed.; }, { @pemit %0=ulocal(layout.error, %qE); };


@tel [v(d.cdb)]=[v(d.chf)]
@tel [v(d.chf)]=[v(d.chc)]
@tel [v(d.chc)]=#2
