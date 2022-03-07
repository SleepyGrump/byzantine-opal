@aconnect [v(d.bc)]=@dolist lattr(me/tr.aconnect-*)={ @trigger me/##=%#; };

@adisconnect [v(d.bc)]=@dolist lattr(me/tr.adisconnect-*)={ @trigger me/##=%#; };

@@ TODO: Maybe add dynamic startups to this as well? +doing/poll/random?

@startup [v(d.bf)]=@trigger me/tr.make-functions; @doing/header [v(d.default-poll)]; @enable eventchecking; @disable building; @trigger me/tr.ban-banned-players; @trigger me/tr.clear-timers;

&tr.make-functions [v(d.bf)]=@dolist lattr(me/f.global.*)=@function rest(rest(##, .), .)=me/##; @dolist lattr(me/f.globalp.*)=@function/preserve rest(rest(##, .), .)=me/##; @dolist lattr(me/f.globalpp.*)=@function/preserve/privilege rest(rest(##, .), .)=me/##;

@trigger v(d.bf)/tr.clear-timers

&tr.clear-timers [v(d.bf)]=@dolist search(EPLAYER=t(lattr(##/_timer.*)))={ @trigger me/tr.clear-player-timers=##; };

&tr.clear-player-timers [v(d.bf)]=@dolist lattr(%0/_timer.*)={ @assert t(setr(0, xget(%0, ##))); @assert gte(sub(secs(), extract(%q0, 1, 1, |)), extract(%q0, 2, 1, |)); @wipe %0/##; };

&tr.ban-banned-players [v(d.bf)]=@dolist lattr(%vD/d.ban.*)=@admin forbid_site=rest(##, D.BAN.) 255.255.255.255;

@daily [v(d.bf)]=@trigger me/tr.clear-timers; @trigger me/tr.clean-old-player-logs=_ownerlog-;

@@ =============================================================================
@@ Locks
@@ =============================================================================

&lock.isstaff [v(d.bf)]=isstaff(%0)

&lock.isapproved [v(d.bf)]=isapproved(%0)

&lock.isapproved_or_staff [v(d.bf)]=cor(isstaff(%0), isapproved(%0))

&lock.allowed_ic [v(d.bf)]=cor(isapproved(%0), isstaff(%0), v(d.allow-unapproved-players-IC))

@@ =============================================================================
@@ Filters
@@ =============================================================================

&filter.isstaff [v(d.bf)]=isstaff(%0)

&filter.not_dark [v(d.bf)]=cand(ulocal(filter.is_connected_player, %0), cor(isstaff(%1), andflags(%0, !D)))

&filter.not_unfindable [v(d.bf)]=cand(ulocal(filter.is_connected_player, %0), cor(isstaff(%1), cand(andflags(%0, !U!D), andflags(loc(%0), !U!D))))

&filter.name [v(d.bf)]=strmatch(name(%0), %1*)

&filter.watched [v(d.bf)]=t(member(xget(%1, friends), %0))

&filter.isobject [v(d.bf)]=hastype(%0, THING)

&filter.isplayer [v(d.bf)]=hastype(%0, PLAYER)

&filter.is_connected_player [v(d.bf)]=cand(hastype(%0, PLAYER), hasflag(%0, CONNECTED))

@@ %0: watcher
@@ %1: target
&filter.watch_on [v(d.bf)]=not(t(default(%0/watch.off, 0)))

&filter.watching_target [v(d.bf)]=cor(default(%0/watch.all.on, 0), t(member(default(%0/friends, 0), %1)))

&filter.allowed_to_watch_target [v(d.bf)]=cor(isstaff(%0), cand(default(%1/watch.hide, 0), t(member(default(%1/watchpermit, 0), %0))), not(default(%1/watch.hide, 0)))

&filter.visible-objects [v(d.bf)]=cand(hastype(%0, THING), andflags(%0, !D))

&filter.visible-exit [v(d.bf)]=andflags(%0, E!D)

&filter.is-exit-commercial [v(d.bf)]=member(%vE, parent(loc(%0)))

&filter.is-exit-residential [v(d.bf)]=member(%vF, parent(loc(%0)))

&filter.is-exit-neither-commercial-nor-residential [v(d.bf)]=cand(not(ulocal(filter.is-exit-commercial, %0)), not(ulocal(filter.is-exit-residential, %0)))

&filter.has-views [v(d.bf)]=t(lattr(%0/view-*))

&filter.has-notes [v(d.bf)]=t(ulocal(f.get-visible-notes, %0,, %1))

&filter.is-note-public [v(d.bf)]=gt(first(default(%1/_notesettings-[rest(%0, -)], 0|), |), 0)

&filter.is_owner [v(d.bf)]=cor(isstaff(%1), t(member(%0, %1, |)), cand(isapproved(%1), if(hastype(%0, EXIT), cor(hasattr(loc(%0), _owner-%1), hasattr(loc(xget(%0, _exit-pair)), _owner-%1)), hasattr(%0, _owner-%1))))

&filter.is-not-connected [v(d.bf)]=not(hasflag(%0, CONNECTED))

@@ =============================================================================
@@ Sorts
@@ =============================================================================

&f.get-note-visibility-setting [v(d.bf)]=first(default(%0/_notesettings-%1, 0|), |)

&f.get-note-approval-status [v(d.bf)]=rest(default(%0/_notesettings-%1, 0|), |)

&f.get-visible-notes [v(d.bf)]=strcat(setq(C, v(d.default-column-delimeter)), setq(R, v(d.default-row-delimeter)), setq(L, trim(squish(iter(lattr(%0/_note-*), strcat(setq(G, rest(itext(0), _NOTE-)), setq(T, xget(%0, ulocal(f.get-key-prefix, _note-)%qG)), if(cand(gte(ulocal(f.get-note-visibility-setting, %0, %qG), case(1, isstaff(%2), -1, isowner(%0, %2), 0, 1)), cor(not(t(%1)), strmatch(%qT, %1*))), strcat(itext(0), %qC, %qT))),, %qR), %qR), b, %qR)), if(t(%1), setq(X, trim(squish(iter(%qL, if(strmatch(rest(itext(0), %qC), %1), itext(0)), %qR, %qR), %qR), b, %qR))), if(t(%qX), %qX, %qL))

&f.is-location-ooc [v(d.bf)]=hasattrp(%0, OOC)

&f.sort-alpha [v(d.bf)]=sort(%0, ?, |, |)

&f.sort-dbref [v(d.bf)]=comp(lcstr(name(%0)), lcstr(name(%1)))

&f.sort-idle [v(d.bf)]=strcat(setq(0, edit(%0, -, 999999999)), setq(1, edit(%1, -, 999999999)), case(1, gt(%q0, %q1), 1, lt(%q0, %q1), -1, 0))

&f.sortby-idle [v(d.bf)]=sortby(f.sort-idle, %0, |, |)

&f.sort.by_idle [v(d.bf)]=strcat(setq(S, iter(%0, ulocal(f.get-idle-secs, itext(0), %1), |, |)), munge(f.sortby-idle, %qS, edit(%0, %b, |), |))

&f.rank-status [v(d.bf)]=edit(strip(%0), ic, 1, ooc, 2, ON DUTY, 3, off duty, 4, 0)

&f.sort-status [v(d.bf)]=strcat(setq(0, ulocal(f.rank-status, %0)), setq(1, ulocal(f.rank-status, %1)), case(1, gt(%q0, %q1), 1, lt(%q0, %q1), -1, 0))

&f.sortby-status [v(d.bf)]=sortby(f.sort-status, %0, |, |)

&f.sort.by_status [v(d.bf)]=strcat(setq(S, iter(%0, ulocal(f.get-status, itext(0), %1), |, |)), munge(f.sortby-status, %qS, edit(%0, %b, |), |))

&f.sort.generic [v(d.bf)]=strcat(setq(S, iter(%0, lcstr(strip(ulocal(f.get-[edit(%2, %b, _)], itext(0), %1))), |, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

&f.sort.by_generic [v(d.bf)]=ulocal(f.sort.generic, %0, %1, edit(%2, %b, _))

&f.sort.by_dbref [v(d.bf)]=sort(%0, d, |, |)

&f.sort-connection_time [v(d.bf)]=case(1, gt(%0, %1), -1, lt(%0, %1), 1, 0)

&f.sortby-connection_time [v(d.bf)]=sortby(f.sort-connection_time, %0, |, |)

&f.sort.by_connection_time [v(d.bf)]=strcat(setq(S, iter(%0, xget(itext(0), _last-conn), |, |)), munge(f.sortby-connection_time, %qS, edit(%0, %b, |), |))

@@ =============================================================================
@@ Functions
@@ =============================================================================

&f.is-player [v(d.bf)]=cand(not(strmatch(name(%0), *Parent)), not(strmatch(name(%0), *Owner)), not(isstaff(%0)))

&f.days-since-last-connected [v(d.bf)]=if(hasflag(%0, CONNECTED), 0, div(sub(secs(), xget(%0, _last-conn)), 86400))

&f.isstaff-or-staff-object [v(d.bf)]=cor(isstaff(%0), cand(not(member(num(me), %1)), hastype(%1, THING), andflags(%1, I!h!n), isstaff(owner(%1))))

&f.can-build [v(d.bf)]=cor(isstaff(%0), match(%0, %vB))

@@ Logic:
@@ 	If one of these is true:
@@    Player passes f.can-build (staff or builder object)
@@    Location is TEMPROOMOK
@@    Location is an IC location
@@      AND is not a sub-room (District - Building - Apartment)
@@  And the following are all also true:
@@    Location is not a temproom
@@    Player doesn't have a current temproom already created
@@ -
&f.can-build-temproom [v(d.bf)]=strcat(setq(L, loc(%0)), cand(cor(ulocal(f.can-build, %0), hasflag(%qL, TEMPROOMOK), cand(not(ulocal(f.is-location-ooc, %qL)), not(strmatch(name(%qL), * - * - *)))), not(hasflag(%qL, TEMPROOM)), not(hasattr(%0, _current-temproom))))

&f.find-player [v(d.bf)]=pmatch(switch(%0, me, %1, %0))

&fn.get-alts [v(d.bf)]=search(eplayer=cand(not(isstaff(##)), strmatch(get(##/lastip), extract(get(%0/lastip), 1, 2, .).*), hasattr(%0, _player-info), hasattr(##, _player-info), t(setinter(iter(xget(%0, _player-info), extract(itext(0), 1, 3, -), |, |), iter(xget(##, _player-info), extract(itext(0), 1, 3, -), |, |), |))), 2)

&fn.get-true-alts [v(d.bf)]=search(eplayer=cand(strmatch(get(##/lastip), extract(get(%0/lastip), 1, 2, .).*), hasattr(%0, _player-info), hasattr(##, _player-info), t(setinter(iter(xget(%0, _player-info), extract(itext(0), 1, 3, -), |, |), iter(xget(##, _player-info), extract(itext(0), 1, 3, -), |, |), |))), 2)

&f.get-staffer-status [v(d.bf)]=if(cand(isstaff(%1), andflags(%0, Dc)), dark, if(andflags(%0, Dc), offline, if(hasflag(%0, connected), if(hasflag(%0, transparent), ansi(first(themecolors()), ON DUTY), off duty), if(hasflag(%0, vacation), vacation, offline))))

@@ Added the option for a staffer to give a player a name highlight OOC. &_name-highlights player=<their name with ansi>
&f.hilite-text [v(d.bf)]=if(ulocal(f.is-location-ooc, loc(%0)), udefault(%0/_name-highlights, ansi(if(ulocal(filter.watched, %0, %1), first(themecolors())), %2)), %2)

&f.get-status [v(d.bf)]=ulocal(f.hilite-text, %0, %1, if(isstaff(%0), ulocal(f.get-staffer-status, %0, %1), if(ulocal(f.is-location-ooc, loc(%0)), ooc, ic)))

&f.get-location [v(d.bf)]=if(cand(hasflag(%0, unfindable), not(isstaff(%1))), Unfindable, name(loc(%0)))

&f.get-gender [v(d.bf)]=default(%0/sex, unset)

&f.get-name [v(d.bf)]=ulocal(f.hilite-text, %0, %1, moniker(%0))

&f.get-alias [v(d.bf)]=xget(%0, alias)

&f.get-dbref [v(d.bf)]=%0

&f.get-note [v(d.bf)]=xget(%1, d.note-%0)

&f.get-position [v(d.bf)]=xget(%0, position)

&f.get-short-desc [v(d.bf)]=shortdesc(%0, %1)

&f.get-staff [v(d.bf)]=v(d.staff_list)

&f.get-idle [v(d.bf)]=if(cand(not(isstaff(%1)), hasflag(%0, dark)), -, first(secs2hrs(idle(%0))))

&f.get-idle-secs [v(d.bf)]=if(cand(not(isstaff(%1)), hasflag(%0, dark)), -, idle(%0))

&f.get-doing [v(d.bf)]=if(ulocal(filter.not_dark, %0, %1), doing(%0))

&f.get-played-by [v(d.bf)]=xget(%0, d.played-by)

&f.get-wiki [v(d.bf)]=xget(%0, d.wiki)

&f.get-themesong [v(d.bf)]=xget(%0, d.themesong)

&f.get-ic_full_name [v(d.bf)]=xget(%0, d.ic_full_name)

&f.get-ic_handle [v(d.bf)]=xget(%0, d.ic_handle)

&f.get-ic_occupation [v(d.bf)]=xget(%0, d.ic_occupation)

&f.get-ic_pronouns [v(d.bf)]=xget(%0, d.ic_pronouns)

&f.get-ooc_pronouns [v(d.bf)]=xget(%0, d.ooc_pronouns)

&f.get-connection_time [v(d.bf)]=if(ulocal(filter.is_connected_player, %0, %1), cat(Connected since, prettytime(xget(%0, _last-conn))), cat(Last on, prettytime(convtime(xget(%0, last)))))

&f.get-mail_stats [v(d.bf)]=strcat(setq(M, mail(%0)), if(t(%qM), strcat(extract(%qM, 2, 1) unread out of, %b, ladd(%qM), %b, messages.)))

&f.get-rp_prefs [v(d.bf)]=xget(%0, d.rp_prefs)

&f.get-timezone [v(d.bf)]=xget(%0, d.timezone)

&f.get-public_alts [v(d.bf)]=xget(%0, d.public_alts)

&f.get-private_alts [v(d.bf)]=if(cor(isstaff(%1), t(member(%0, %1, |))), itemize(iter(ulocal(fn.get-true-alts, %0), ulocal(f.get-name, itext(0), %1),, |), |))

&f.get-connection_info [v(d.bf)]=if(cor(isstaff(%1), t(member(%0, %1, |))), if(t(setr(0, first(xget(%0, _player-info), |))), strcat(first(%q0, -)%,, %b, extract(%q0, 3, 1, -), x, extract(%q0, 2, 1, -) screen%,%b, extract(%q0, 4, 1, -) colors), No terminal info found.))

&f.get-last_ip [v(d.bf)]=if(cor(isstaff(%1), t(member(%0, %1, |))), strcat(setr(0, xget(%0, lastip)), if(and(not(strmatch(%q0, setr(1, extract(first(xget(%0, _player-info), |), 5, 100, -)))), t(%q1)), strcat(%,%b, %q1))))

&f.get-staff_notes [v(d.bf)]=if(isstaff(%1), default(%0/_d.staff-notes, Unset))

&f.get-quote [v(d.bf)]=xget(%0, d.quote)

&f.get-apparent_age [v(d.bf)]=xget(%0, d.apparent_age)

&f.get-travel-key [v(d.bf)]=xget(%0, d.travel-key)

&f.get-travel-categories [v(d.bf)]=xget(%0, d.travel-categories)

&f.is-redirected-to-channel [v(d.bf)]=hasattrp(me, d.redirect-poses.%0)

&f.is-target-room-gagged [v(d.bf)]=member(v(d.gag-emits), %0)

&f.is-player-on-redirected-channel [v(d.bf)]=cand(member(cwho(v(d.redirect-poses.%1)), %0), not(hasattr(%0, _mute-channel-[chanobj(v(d.redirect-poses.%1))])))

&f.get-channel-alias [v(d.bf)]=if(t(%vH), ulocal(%vH/f.get-channel-alias-by-name, %0), switch(%0, Chargen, cg, Staff, st, strtrunc(lcstr(%0), 3)))

@@ %0: object to check
@@ %1: attribute cluster to check
@@ Returns: The attribute cluster plus a number greater than all pre-existing numbers on that attribute cluster: ex: _stat.crew_advancement_12 (where the last one was 11) or doing1 if there were no previous attributes starting with doing.
&f.get-next-id-attr [v(d.bf)]=strcat(%1, inc(lmax(edit(lattr(%0/%1*), ucstr(%1),))))

@@ %0: object to check
@@ %1: attribute cluster to check
@@ %2: index to extract
&f.find-attr-by-number [v(d.bf)]=extract(lattr(%0/%1*), %2, 1)

&f.gag-poses-in-quiet-rooms [v(d.bf)]=cand(not(ulocal(f.is-target-room-gagged, loc(%#))), not(ulocal(f.is-redirected-to-channel, loc(%#))))

&f.forward-poses [v(d.bf)]=if(ulocal(f.is-redirected-to-channel, loc(%#)), trigger(me/tr.redirect-emit-to-channel, loc(%#), %m, %#), pemit(%#, Permission denied.))

@@ Posebreak code from:
@@ https://github.com/thenomain/Mu--Support-Systems/blob/main/%2Bposebreak.txt

@@ Slightly modified to use our OOC/IC system
&f.posebreak-allow [v(d.bf)]=not(ulocal(f.is-location-ooc, %l))

@@ switched from and to cand for efficiency
&fil.posebreak [v(d.bf)]=cand(u(%0/_posebreak), udefault(f.posebreak-allow, 1, %0))

&f.posebreak [v(d.bf)]=[iter(filter(fil.posebreak, lcon(loc(%#), connect)), pemit(%i0, default(%i0/posebreak, %b)))]

@@ %0: Player
@@ %1: Pose
@@ %2: Is the player on the channel?
@@ %3: Channel name
&f.parse_emit [v(d.bf)]=strcat(setq(P, if(setr(O, not(ulocal(filter.isplayer, %0))),, if(t(%vH), ulocal(%vH/layout.player-name-or-comtitle, %0,, %3), ulocal(f.get-name, %0)))), switch(%1, *[moniker(%0)]*, %1, strcat(%qP, switch(%1, :*, %b[rest(%1, :)], ;*, rest(%1, ;), pose/*, rest(%1), pose *, %b[rest(%1)], npose *, %b[rest(%1)], "*, %bsays "[rest(%1, ")]", say*, %bsays "[rest(%1)]", nsay*, %bsays "[rest(%1)]", @emit* *, : [rest(%1)], @remit* *=*, : [rest(%1, =)], @remit *, : [rest(%1)], \\*, : [trim(%1, l, \\\\\\\\)], %1))), if(cand(not(%2), not(%qO)), %b--- [capstr(subj(%0))] [switch(subj(%0), they, are, is)] not on this channel and cannot see replies%, but [switch(subj(%0), they, have, has)] been invited to join.))

@@ TODO:
@@ Make sure that objects can pass along their emits, properly formatted.
@@ Make sure that emits by players show up as intended and get logged?
@@ Make sure the player's comtitle appears instead of their name, if they have one.

@@ %0: Sender
@@ %1: Target
&f.can-sender-message-target [v(d.bf)]=cor(isstaff(%0), member(xget(%1, whitelisted-PCs), %0), not(cor(t(xget(%1, block-all)), member(xget(%1, blocked-PCs), %0))))

@@ %0: player
@@ %1: log attribute group
@@ %2: number to get (default 10)
&f.get-last-X-logs [v(d.bf)]=extract(revwords(lattr(%0/%1*)), 1, if(t(%2), %2, 10))

@@ =============================================================================
@@ Triggers - these must be globally available to all descendants, so belong on
@@ the Functions object.
@@ =============================================================================

&tr.error [v(d.bf)]=@pemit %0=cat(alert(Error), %1);

&tr.message [v(d.bf)]=@pemit %0=cat(alert(Alert), %1);

&tr.success [v(d.bf)]=@pemit %0=cat(alert(Success), %1);

&tr.report [v(d.bf)]=@cemit [v(d.report-target)]=%0;

@@ %0: player or object
@@ %1: attribute group
@@ %2: setter
@@ %3: message
&tr.log [v(d.bf)]=@set %0=[ulocal(f.get-next-id-attr, %0, %1)]:[cat(prettytime(), if(isdbref(%2), ulocal(f.get-name, %2), %2):, %3)];

@@ %0: channel
@@ %1: player or message
@@ %2: message (if not given, message is assumed to be %1)
&tr.alert-to-channel [v(d.bf)]=@cemit %0=cat(ansi(xh, extract(prettytime(), 1, 2, /)), ansi(<#777777>, rest(prettytime())), if(t(%2), cat(ulocal(f.get-name, %1):, %2), %1));

@@ %0: attribute group
&tr.clean-old-player-logs [v(d.bf)]=@dolist search(EPLAYER=t(lattr(##/%0*)))={ @trigger me/tr.clean-old-logs=##, %0; };

@@ %0: player
@@ %1: attribute group
@@ Deletes logs that are not in the top 20 log entries and which did not take place within the last 7 days.
&tr.clean-old-logs [v(d.bf)]=@eval setq(L, lattr(%0/%1*)); @eval setq(L, setdiff(%qL, extract(revwords(%qL), 1, 20))) @assert t(%qL); @dolist %qL={ @assert gt(sub(secs(), unprettytime(extract(xget(%0, ##), 1, 2))), 604800); @wipe %0/##; };

@@ TODO: Consider adding options for cemit, job, and msg? And possibly a global trigger which handles all possibilities passed as a flag - channel, job, msg, page, and any future options we come up with, defaulting to remit.

@@ %0: flag
@@ %1: player
@@ %2: message
@@ %3: sender
@@ Note: This is for things that are IC communications. OOC communications should stick to @pemits, @emits, etc, because they cannot be blocked. IC communications are blockable. (For example, IC invitations.)
&tr.msg-player [v(d.bf)]=@trigger %vC/switch.msg=/%0 %1=:sends: %2, %3;

&tr.redirect-emit-to-channel [v(d.bf)]=@break cand(ulocal(filter.isplayer, %2), not(ulocal(f.is-player-on-redirected-channel, %2, %0)))={ @trigger me/tr.message=%2, Sorry%, you're not on the [setr(C, v(d.redirect-poses.%0))] channel right now. Type %ch[if(t(%vH), ulocal(%vH/f.get-channel-alias, %qC)/on%b, addcom [ulocal(f.get-channel-alias, %qC)]=%qC)]%cn to talk here.; }; @cemit v(d.redirect-poses.%0)=ulocal(f.parse_emit, %2, %1, ulocal(f.is-player-on-redirected-channel, %2, %0), %0);

&tr.remit [v(d.bf)]=@break ulocal(f.is-redirected-to-channel, %0)={ @trigger me/tr.redirect-emit-to-channel=%0, %1, %2; }; @break ulocal(f.is-target-room-gagged, %0)={ @trigger me/tr.error=%2, You can't use this command in here. This room is set quiet.; }; @remit %0=%1;

&tr.remit-quiet [v(d.bf)]=@break ulocal(f.is-redirected-to-channel, %0)={ @pemit lcon(%0)=%1; }; @break ulocal(f.is-target-room-gagged, %0); @remit %0=%1;

@@ %0: Location
@@ %1: Message
@@ %2: Player to send to if the room is gagged
&tr.remit-or-pemit [v(d.bf)]=@break ulocal(f.is-redirected-to-channel, %0)={ @trigger me/tr.redirect-emit-to-channel=%0, %1, %2; }; @break ulocal(f.is-target-room-gagged, %0)={ @trigger me/tr.pemit=%2, %1; }; @remit %0=%1;

&tr.pemit [v(d.bf)]=@break t(words(setr(N, trim(squish(iter(%0, if(ulocal(f.can-sender-message-target, %2, itext(0)),, itext(0))))))))={ @trigger me/tr.error=%2, Sorry%, [itemize(iter(%qN, moniker(itext(0)),, |), |)] [case(words(%qN), 1, is, are)] not accepting messages.; }; @pemit %0=%1;

&layout.travel_alert [v(d.bf)]=strcat(alert(+travel), %b, moniker(%0) has %3, if(t(%1), cat(%,, %2, ulocal(f.get-name, %1))), .)

@@ %0: destination
@@ %1: player to transport
@@ %2: player calling/sending them (if any)
@@ %3: type of call or send - summon, join, etc.
&tr.travel_to_destination [v(d.bf)]=@assert eq(words(%0), 1)={ @trigger me/tr.error=%1, The key you gave resolved to [words(%0)] destinations. Please try again.; }; @assert match(type(%0), ROOM)={ @trigger me/tr.error=if(t(%2), %2, %1), The room selected as a destination does not exist.; }; @break match(loc(%1), %0)={ @trigger me/tr.error=if(t(%2), %2, %1), cat(if(t(%2), ulocal(f.get-name, %1) is , You are), already at the destination).; }; @assert cor(ulocal(lock.isapproved_or_staff, %1), ulocal(f.is-location-ooc, %0), ulocal(lock.isstaff, %2))={ @trigger me/tr.error=%1, You are not approved or staff so can't use +travel to go IC yet.; }; &_last-location %1=loc(%1); &_last-[if(hasattrp(loc(%1), ooc), ooc, ic)]-location %1=loc(%1); @trigger me/tr.remit-quiet=loc(%1), ulocal(layout.travel_alert, %1, %2, %3, departed), %1; @tel/quiet %1=%0; @trigger me/tr.remit-quiet=%0, ulocal(layout.travel_alert, %1, %2, %3, arrived), %1;

&tr.report_query_error [v(d.bf)]=if(cand(not(t(%1)), t(strlen(%1))), report(num(me), ulocal(layout.report_query_error, %0, %1, %2)))

@@ When debugging: &tr.report_query_error [v(d.bf)]=report(num(me), ulocal(layout.report_query_error, %0, %1, %2))

&layout.report_query_error [v(d.bf)]=strcat(Error in %0:, %b, \[%1\], :%b, %2)

&layout.log [v(d.bf)]=cat(ansi(xh, extract(%0, 1, 2, /)), rest(rest(rest(%0))))

&layout.list [v(d.bf)]=if(t(%0), itemize(setunion(%0, %0, |), |, if(t(%1), %1, and)), None)
