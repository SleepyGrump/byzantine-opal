@@ Commands related to personalizing your character or experience on the game.

@@ =============================================================================
@@ +doing - aliases for @doing, @poll, etc.
@@ =============================================================================

&f.find-doing-by-number [v(d.bf)]=extract(lattr(%0/doing.*), %1, 1)

&f.choose-random-doing [v(d.bf)]=pickrand(lattr(%0/doing.*))

&layout.doing_list [v(d.bf)]=strcat(header(Your @doing list, %0), %r, multicol(iter(lattr(%0/doing.*), strcat(inum(0)., |, xget(%0, itext(0))),, |), 3 *,, |), %r, footer(+doing/add <text> or +doing/del <number>, %0))

&c.+doing [v(d.bc)]=$+doing:@trigger me/tr.message=%#, The current poll is: [poll()]. Your @doing is: [doing(%#)];

&c.+doing_set [v(d.bc)]=$+doing *:@force %#=@doing %0; @wait .1=@trigger me/tr.success=%#, Your @doing is: [doing(%#)];

&c.+doing_set_random [v(d.bc)]=$+doing/r*:@assert t(lattr(%#/doing.*)); @force %#=@doing \[v(pickrand(lattr(%#/doing.*)))\]; @wait .1=@trigger me/tr.success=%#, Your randomly-chosen @doing of the day is: [doing(%#)];

&c.+doing/list [v(d.bc)]=$+doing/l*:@pemit %#=ulocal(layout.doing_list, %#);

&c.+doing/add [v(d.bc)]=$+doing/a*:@assert t(setr(D, rest(%0, if(strmatch(%0, *=*), =, %b))))={ @trigger me/tr.error=%#, Couldn't figure out what you want to add!; }; @assert valid(doing, %qD)={ @trigger me/tr.error=%#, '%qD' is not a valid @doing string.; }; @eval setq(C, inc(lmax(edit(lattr(%#/doing.*), DOING.,)))); &doing.%qC %#=%qD; @trigger me/tr.success=%#, Added a new @doing '%qD'. Your @doing will be automatically set to a random one from your list every time you connect.; @eval setq(A, setunion(xget(%#, aconnect), +doing/random, ;)); @aconnect %#=%qA;

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

&tr.aconnect-store_player_info [v(d.bc)]=@set %0=_player-info:[setr(0, ulocal(layout.player-info, %0))]|[remove(xget(%0, _player-info), %q0, |, |)];
