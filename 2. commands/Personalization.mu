@@ Commands related to personalizing your character or experience on the game.

@@ =============================================================================
@@ +doing - aliases for @doing, @poll, etc.
@@ =============================================================================

&f.find-doing-by-number [v(d.bf)]=extract(lattr(%0/doing.*), %1, 1)

&f.choose-random-doing [v(d.bf)]=pickrand(lattr(%0/doing.*))

&layout.doing_list [v(d.bf)]=strcat(header(Your @doing list, %0), %r, multicol(iter(lattr(%0/doing.*), strcat(inum(0)., |, xget(%0, itext(0))),, |), 3 *,, |), %r, footer(+doing/add <text> or +doing/del <number>, %0))

&c.+doing [v(d.bc)]=$+doing:@trigger me/tr.message=%#, The current poll is: [poll()]. Your @doing is: [doing(%#)];

&c.+doing_set [v(d.bc)]=$+doing *:@force %#=@doing %0; @wait .1=@trigger me/tr.success=%#, Your @doing is: [doing(%#)];

&c.+doing_set_random [v(d.bc)]=$+doing/r*:@assert t(lattr(%#/doing.*)); @force %#=@doing \[v(pickrand(lattr(%#/doing.*)))\]; @wait .1=@trigger me/tr.success=%#, The current poll is: [poll()]. Your randomly-chosen @doing of the day is: [doing(%#)];

&c.+doing/list [v(d.bc)]=$+doing/l*:@pemit %#=ulocal(layout.doing_list, %#);

&c.+doing/add [v(d.bc)]=$+doing/a*:@assert t(setr(D, rest(%0, if(strmatch(%0, *=*), =, %b))))={ @trigger me/tr.error=%#, Couldn't figure out what you want to add!; }; @assert valid(doing, %qD)={ @trigger me/tr.error=%#, '%qD' is not a valid @doing string.; }; @eval setq(C, inc(lmax(edit(lattr(%#/doing.*), DOING.,)))); &doing.%qC %#=%qD; @trigger me/tr.success=%#, Added a new @doing '%qD'. Your @doing will be automatically set to a random one from your list every time you connect.; @eval setq(A, setunion(xget(%#, aconnect), +doing/random, ;)); @aconnect %#=%qA; @eval setq(S, setunion(xget(%#, startup), +doing/random, ;)); @startup %#=%qS;

&c.+doing/delete [v(d.bc)]=$+doing/d*:@assert cand(t(strcat(setq(N, trim(%0)), setr(N, switch(%qN, *=*, rest(%qN, =), * *, last(%qN), %qN)))), isnum(%qN))={ @trigger me/tr.error=%#, Couldn't figure out which @doing you want to delete. Got '%qN'?; }; @assert t(setr(D, ulocal(f.find-doing-by-number, %#, %qN)))={ @trigger me/tr.error=%#, Can't find a @doing at position #%qN.; }; @eval setq(O, xget(%#, %qD)); @wipe %#/%qD; @trigger me/tr.success=%#, You deleted the @doing '%qO'. This does not unset your current @doing.;

&c.+doing/remove [v(d.bc)]=$+doing/r* *:@force %#=+doing/delete %1;

&c.+doing/poll [v(d.bc)]=$+doing/poll *:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to set the poll.; }; @doing/header %0; @wall/emit/no_prefix strcat(alert(Poll), %b, moniker(%#) just changed the poll to:, %b, poll(), %b, +help Poll for more info.);

@@ =============================================================================
@@ +view
@@ =============================================================================

&layout.view_list [v(d.bf)]=strcat(alert(Views), %b, if(t(%0), strcat(The following view, if(gt(words(%0), 1), s are, is), %b, available here:, %b, itemize(%0)), There are no views available in your current location.))

&c.+view [v(d.bc)]=$+view:

@@ =============================================================================
@@ +finger code
@@ =============================================================================

&layout.finger-section [v(d.bf)]=strcat(setq(F,), setq(M, 0), null(iter(v(d.section.[edit(%2, %b, _)]), if(t(setr(V, ulocal(f.get-[edit(itext(0), %b, _)], %0, %1))), setq(F, strcat(%qF, |, itext(0):, |, %qV, if(gt(strlen(itext(0):), %qM), setq(M, strlen(itext(0):)))))), |)), setq(F, trim(squish(%qF, |), b, |)), if(t(%qF), strcat(divider(%2, %1), %r, multicol(%qF, %qM *, 0, |, %1), %r)))

&layout.finger-sections [v(d.bf)]=iter(v(d.finger-sections), ulocal(layout.finger-section, %0, %1, itext(0)), |, @@)

&layout.finger-header [v(d.bf)]=strcat(ulocal(f.get-name, %0, %1), %b, %(, ulocal(f.get-alias, %0, %1), %), %b, if(isstaff(%1), cat(%0, flags(%0))))

&layout.finger-footer [v(d.bf)]=cat(ulocal(f.get-status, %0, %1), case(1, isstaff(%0), staff, isapproved(%0), approved, unapproved))

&layout.finger [v(d.bf)]=strcat(header(ulocal(layout.finger-header, %0, %1), %1), %r, ulocal(layout.finger-sections, %0, %1), footer(ulocal(layout.finger-footer, %0, %1), %1))

&c.+finger [v(d.bc)]=$+finger *:@assert t(setr(P, ulocal(f.find-player, %0, %#)))={ @trigger me/tr.error=%#, Could not find player '%0'.; }; @pemit %#=ulocal(layout.finger, %qP, %#);

&f.get-finger-field-destination [v(d.bf)]=switch(%0, Gender, sex, Position, position, Short-desc, short-desc, d.[edit(%0, %b, _)])

&c.+finger/set [v(d.bc)]=$+finger/set *=*:@assert t(setr(N, grab(setr(A, v(d.finger-settable-fields)), %0*, |)))={ @trigger me/tr.error=%#, strcat(The field '%0' is not settable on +finger. Valid options are [itemize(%qA, |)].); }; @assert t(setr(D, ulocal(f.get-finger-field-destination, %qN)))={ @trigger me/tr.error=%#, Could not figure out where to set the field '%qN'.; }; &%qD %#=%1; @trigger me/tr.success=%#, You have [if(t(%1), set, cleared)] your %qN field. [if(t(%1), Its value is now: [xget(%#, %qD)])];
