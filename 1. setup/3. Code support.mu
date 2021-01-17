@aconnect [v(d.bc)]=@dolist lattr(me/tr.aconnect-*)={ @trigger me/##=%#; };

@adisconnect [v(d.bc)]=@dolist lattr(me/tr.adisconnect-*)={ @trigger me/##=%#; };

@startup [v(d.bf)]=@trigger me/tr.make-functions;

&tr.make-functions [v(d.bf)]=@dolist lattr(me/f.global.*)=@function rest(rest(##, .), .)=me/##; @dolist lattr(me/f.globalp.*)=@function/preserve rest(rest(##, .), .)=me/##; @dolist lattr(me/f.globalpp.*)=@function/preserve/privilege rest(rest(##, .), .)=me/##;

@@ =============================================================================
@@ Filters
@@ =============================================================================

&filter.isstaff [v(d.bf)]=isstaff(%0)

&filter.not_dark [v(d.bf)]=cor(isstaff(%1), andflags(%0, !Dc))

&filter.name [v(d.bf)]=strmatch(name(%0), %1*)

&filter.watched [v(d.bf)]=t(member(xget(%1, friends), %0))

@@ %0: watcher
@@ %1: target
&filter.watch_on [v(d.bf)]=not(t(default(%0/watch.off, 0)))

&filter.watching_target [v(d.bf)]=cor(default(%0/watch.all.on, 0), t(member(default(%0/friends, 0), %1)))

&filter.allowed_to_watch_target [v(d.bf)]=cor(isstaff(%0), cand(default(%1/watch.hide, 0), t(member(default(%1/watchpermit, 0), %0))), not(default(%1/watch.hide, 0)))

@@ =============================================================================
@@ Sorts
@@ =============================================================================

&f.sort-alpha [v(d.bf)]=sort(%0, ?, |, |)

&f.sort.by_idle [v(d.bf)]=strcat(setq(S, iter(%0, ulocal(f.get-idle, itext(0), %1), |, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

&f.sort.by_status [v(d.bf)]=strcat(setq(S, iter(%0, ulocal(f.get-status, itext(0), %1), |, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

&f.sort.by_name [v(d.bf)]=strcat(setq(S, iter(%0, moniker(itext(0)), |, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

&f.sort.by_alias [v(d.bf)]=strcat(setq(S, iter(%0, alias(itext(0)), |, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

&f.sort.by_location [v(d.bf)]=strcat(setq(S, iter(%0, ulocal(f.get-location, itext(0), %1), |, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

&f.sort.by_doing [v(d.bf)]=strcat(setq(S, iter(%0, doing(itext(0)),, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

&f.sort.by_gender [v(d.bf)]=strcat(setq(S, iter(%0, ulocal(f.get-gender, itext(0)), |, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

&f.sort.by_dbref [v(d.bf)]=sort(%0, d)

&f.sort.by_note [v(d.bf)]=strcat(setq(S, iter(%0, ulocal(f.get-note, itext(0), %1), |, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

&f.sort.by_position [v(d.bf)]=strcat(setq(S, iter(%0, xget(itext(0), position), |, |)), munge(f.sort-alpha, %qS, edit(%0, %b, |), |))

@@ =============================================================================
@@ Functions
@@ =============================================================================

&fn.get-alts [v(d.bf)]=search(eplayer=cand(not(isstaff(##)), strmatch(get(##/lastip), extract(get(%0/lastip), 1, 2, .).*), hasattr(%0, _player-info), hasattr(##, _player-info), t(setinter(iter(xget(%0, _player-info), extract(itext(0), 1, 3, -), |, |), iter(xget(##, _player-info), extract(itext(0), 1, 3, -), |, |), |))), 2)

&f.get-staffer-status [v(d.bf)]=if(cand(isstaff(%1), andflags(%0, Dc)), dark, if(andflags(%0, Dc), offline, if(hasflag(%0, connected), if(hasflag(%0, transparent), ansi(first(themecolors()), ON DUTY), off duty), if(hasflag(%0, vacation), vacation, offline))))

&f.get-status [v(d.bf)]=ulocal(f.hilite-text, %0, %1, if(isstaff(%0), ulocal(f.get-staffer-status, %0, %1), if(hasattrp(loc(%0), OOC), ooc, ic)))

&f.get-location [v(d.bf)]=if(cand(hasflag(%0, unfindable), not(isstaff(%1))), Unfindable, name(loc(%0)))

&f.get-gender [v(d.bf)]=switch(xget(%0, sex), M*, male, F*, female, if(t(#$), non-binary, unset))

&f.get-name [v(d.bf)]=ulocal(f.hilite-text, %0, %1, moniker(%0))

&f.get-alias [v(d.bf)]=ulocal(f.hilite-text, %0, %1, alias(%0))

&f.get-dbref [v(d.bf)]=%0

&f.get-note [v(d.bf)]=xget(%1, d.note-%0)

&f.get-position [v(d.bf)]=xget(%0, position)

&f.get-staff [v(d.bf)]=v(d.staff_list)

&f.get-idle [v(d.bf)]=if(cand(not(isstaff(%1)), hasflag(%0, dark)), -, secs2hrs(idle(%0)))

&f.get-doing [v(d.bf)]=if(cand(not(isstaff(%1)), hasflag(%0, dark)),, doing(%0))
