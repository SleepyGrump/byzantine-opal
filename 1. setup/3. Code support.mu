@aconnect [v(d.bc)]=@dolist lattr(me/tr.aconnect-*)={ @trigger me/##=%#; };

@adisconnect [v(d.bc)]=@dolist lattr(me/tr.adisconnect-*)={ @trigger me/##=%#; };

@@ TODO: Maybe add dynamic startups to this as well? +doing/poll/random?

@startup [v(d.bf)]=@trigger me/tr.make-functions; @doing/header [v(d.default-poll)]; @disable building;

&tr.make-functions [v(d.bf)]=@dolist lattr(me/f.global.*)=@function rest(rest(##, .), .)=me/##; @dolist lattr(me/f.globalp.*)=@function/preserve rest(rest(##, .), .)=me/##; @dolist lattr(me/f.globalpp.*)=@function/preserve/privilege rest(rest(##, .), .)=me/##;

@@ =============================================================================
@@ Locks
@@ =============================================================================

&lock.isstaff [v(d.bf)]=isstaff(%0)

&lock.isapproved [v(d.bf)]=isapproved(%0)

&lock.isapproved_or_staff [v(d.bf)]=cor(isstaff(%0), isapproved(%0))

@@ =============================================================================
@@ Filters
@@ =============================================================================

&filter.isstaff [v(d.bf)]=isstaff(%0)

&filter.not_dark [v(d.bf)]=cand(ulocal(filter.is_connected_player, %0), cor(isstaff(%1), andflags(%0, !D)))

&filter.not_unfindable [v(d.bf)]=cand(ulocal(filter.is_connected_player, %0), cor(isstaff(%1), andflags(%0, !U!D)))

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

@@ =============================================================================
@@ Sorts
@@ =============================================================================

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

&f.sort.by_name [v(d.bf)]=strcat(setq(S, iter(%0, lcstr(name(itext(0))), |, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

&f.sort.by_alias [v(d.bf)]=strcat(setq(S, iter(%0, lcstr(xget(itext(0), alias)), |, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

&f.sort.by_location [v(d.bf)]=strcat(setq(S, iter(%0, ulocal(f.get-location, itext(0), %1), |, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

&f.sort.by_doing [v(d.bf)]=strcat(setq(S, iter(%0, lcstr(ulocal(f.get-doing, itext(0), %1)), |, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

&f.sort.by_gender [v(d.bf)]=strcat(setq(S, iter(%0, ulocal(f.get-gender, itext(0)), |, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

&f.sort.by_dbref [v(d.bf)]=sort(%0, d)

&f.sort.by_note [v(d.bf)]=strcat(setq(S, iter(%0, ulocal(f.get-note, itext(0), %1), |, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

&f.sort.by_position [v(d.bf)]=strcat(setq(S, iter(%0, lcstr(ulocal(f.get-position, itext(0), %1)), |, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

&f.sort.by_short-desc [v(d.bf)]=strcat(setq(S, iter(%0, lcstr(ulocal(f.get-short-desc, itext(0), %1)), |, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

&f.get-fields [v(d.bf)]=strcat(setq(F,), null(iter(default(%0/d.%1-fields, %2), if(member(v(d.allowed-who-fields), itext(0), |), setq(F, strcat(%qF, |, itext(0)))), |)), trim(squish(%qF, |), b, |))

&f.get-field-widths [v(d.bf)]=iter(%0, if(cand(member(object, %1), member(Name, itext(0))), *, extract(v(d.who-field-widths), member(v(d.allowed-who-fields), itext(0), |), 1)), |)

&f.sort-players [v(d.bf)]=strcat(setq(P,), null(iter(ulocal(f.get-sort-order, %1, %2), setq(P, ulocal(f.sort.by_[itext(0)], edit(%0, %b, |), %1)), |, |)), edit(%qP, |, %b))

&f.get-sort-order [v(d.bf)]=strcat(setq(S,), null(iter(default(%0/d.%1-sort, v(d.who-sort-order)), if(member(v(d.allowed-who-fields), itext(0), |), setq(S, %qS|[itext(0)])), |)), setq(S, trim(%qS, b, |)), %qS)

@@ =============================================================================
@@ Functions
@@ =============================================================================

&f.isstaff-or-staff-object [v(d.bf)]=cor(isstaff(%0), cand(not(member(num(me), %1)), hastype(%1, THING), andflags(%1, I!h!n), isstaff(owner(%1))))

&f.can-build [v(d.bf)]=isstaff(%0)

&fn.get-alts [v(d.bf)]=search(eplayer=cand(not(isstaff(##)), strmatch(get(##/lastip), extract(get(%0/lastip), 1, 2, .).*), hasattr(%0, _player-info), hasattr(##, _player-info), t(setinter(iter(xget(%0, _player-info), extract(itext(0), 1, 3, -), |, |), iter(xget(##, _player-info), extract(itext(0), 1, 3, -), |, |), |))), 2)

&f.get-staffer-status [v(d.bf)]=if(cand(isstaff(%1), andflags(%0, Dc)), dark, if(andflags(%0, Dc), offline, if(hasflag(%0, connected), if(hasflag(%0, transparent), ansi(first(themecolors()), ON DUTY), off duty), if(hasflag(%0, vacation), vacation, offline))))

&f.get-status [v(d.bf)]=ulocal(f.hilite-text, %0, %1, if(isstaff(%0), ulocal(f.get-staffer-status, %0, %1), if(ulocal(f.is-location-ooc, loc(%0)), ooc, ic)))

&f.get-location [v(d.bf)]=if(cand(hasflag(%0, unfindable), not(isstaff(%1))), Unfindable, name(loc(%0)))

&f.get-gender [v(d.bf)]=switch(xget(%0, sex), M*, male, F*, female, if(t(#$), non-binary, unset))

&f.get-name [v(d.bf)]=ulocal(f.hilite-text, %0, %1, moniker(%0))

&f.get-alias [v(d.bf)]=ulocal(f.hilite-text, %0, %1, xget(%0, alias))

&f.get-dbref [v(d.bf)]=%0

&f.get-note [v(d.bf)]=xget(%1, d.note-%0)

&f.get-position [v(d.bf)]=xget(%0, position)

&f.get-short-desc [v(d.bf)]=shortdesc(%0, %1)

&f.get-staff [v(d.bf)]=v(d.staff_list)

&f.get-idle [v(d.bf)]=if(cand(not(isstaff(%1)), hasflag(%0, dark)), -, first(secs2hrs(idle(%0))))

&f.get-idle-secs [v(d.bf)]=if(cand(not(isstaff(%1)), hasflag(%0, dark)), -, idle(%0))

&f.get-doing [v(d.bf)]=if(ulocal(filter.not_dark, %0, %1), doing(%0))

&f.get-travel-key [v(d.bf)]=xget(%0, d.travel-key)

&f.get-travel-categories [v(d.bf)]=xget(%0, d.travel-categories)

&f.is-redirected-to-channel [v(d.bf)]=hasattrp(me, d.redirect-poses.%0)

&f.is-target-room-gagged [v(d.bf)]=member(v(d.gag-emits), %0)

&f.is-player-on-redirected-channel [v(d.bf)]=member(cwho(v(d.redirect-poses.%1)), %0)

@@ %0: Sender
@@ %1: Target
&f.can-sender-message-target [v(d.bf)]=cor(isstaff(%0), member(xget(%1, whitelisted-PCs), %0), not(cor(t(xget(%1, block-all)), member(xget(%1, blocked-PCs), %0))))

&layout.who-list [v(d.bf)]=multicol(strcat(edit(setr(F, ulocal(f.get-fields, %1, %2, v(d.default-%2-fields))), Doing, poll()), |, iter(%0, ulocal(layout.who_data, itext(0), %1, %qF),, |)), ulocal(f.get-field-widths, %qF, %2), 1, |, %1)

@@ =============================================================================
@@ Triggers - these must be globally available to all descendents, so belong on
@@ the Functions object.
@@ =============================================================================

&tr.error [v(d.bf)]=@pemit %0=cat(alert(Error), %1);

&tr.message [v(d.bf)]=@pemit %0=cat(alert(Alert), %1);

&tr.success [v(d.bf)]=@pemit %0=cat(alert(Success), %1);

&tr.redirect-emit-to-channel [v(d.bf)]=@cemit v(d.redirect-poses.%0)=ulocal(f.parse_emit, %2, %1); @assert ulocal(f.is-player-on-redirected-channel, %2, %0)={ @trigger me/tr.message=%2, You aren't seeing the whole conversation. All emits in this location are piped to the [v(d.redirect-poses.%0)] channel. %chaddcom <alias>=[v(d.redirect-poses.%0)]%cn to join in!; };

&tr.remit [v(d.bf)]=@break ulocal(f.is-redirected-to-channel, %0)={ @trigger me/tr.redirect-emit-to-channel=%0, %1, %2; }; @break ulocal(f.is-target-room-gagged, %0)={ @trigger me/tr.error=%2, You can't use this command in here. This room is set quiet.; }; @remit %0=%1;

&tr.remit-quiet [v(d.bf)]=@break ulocal(f.is-redirected-to-channel, %0); @break ulocal(f.is-target-room-gagged, %0); @remit %0=%1;

&tr.pemit [v(d.bf)]=@break t(words(setr(N, trim(squish(iter(%0, if(ulocal(f.can-sender-message-target, %2, itext(0)),, itext(0))))))))={ @trigger me/tr.error=%2, Sorry%, [itemize(iter(%qN, moniker(itext(0)),, |), |)] [case(words(%qN), 1, is, are)] not accepting messages.; }; @pemit %0=%1;

&tr.travel_to_destination [v(d.bf)]=@assert eq(words(%0), 1)={ @trigger me/tr.error=%1, The key you gave resolved to [words(%0)] destinations. Please try again.; }; @assert cor(ulocal(lock.isapproved_or_staff, %1), ulocal(f.is-location-ooc, %0))={ @trigger me/tr.error=%1, You are not approved or staff so can't use +travel to go IC yet.; }; &last-location %1=loc(%1); @trigger me/tr.remit-quiet=loc(%1), ulocal(layout.travel_departure, %1), %1; @tel %1=%0; @trigger me/tr.remit-quiet=%0, ulocal(layout.travel_arrival, %1), %1;
