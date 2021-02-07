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

&layout.view_title [v(d.bf)]=cat(moniker(%0)'s, getpairkey(%0, view-, %1), view)

&layout.view [v(d.bf)]=strcat(header(ulocal(layout.view_title, %0, %1), %3), %r, formattext(%2, 0, %3), %r, footer(, %3))

&f.objects-with-views [v(d.bf)]=iter(%0, moniker(itext(0)),, |)

&f.available-objects-to-view [v(d.bf)]=cat(loc(%0), filter(filter.not_dark, lcon(loc(%0)),,, %0), filter(filter.isobject, lcon(loc(%0))), filter(filter.visible-exit, lexits(loc(%0)),,, %0))

&f.grab-matching-object [v(d.bf)]=case(1, strmatch(%0, me), %1, strmatch(%0, here), loc(%1), cand(isstaff(%1), isdbref(%0)), %0, isdbref(%0), if(member(ulocal(f.available-objects-to-%2, %1), %0), %0, #-1 NOT FOUND), t(setr(M, grab(iter(ulocal(f.available-objects-to-%2, %1), strcat(name(itext(0)), ~, itext(0)),, v(d.default-row-delimeter)), %0*, v(d.default-row-delimeter)))), rest(%qM, ~), #-1 NOT FOUND)

&f.available-objects-to-set-views [v(d.bf)]=filter(filter.is_owner, cat(loc(%0), filter(filter.not_dark, lcon(loc(%0)),,, %0), filter(filter.isobject, lcon(loc(%0))), filter(filter.visible-exit, lexits(loc(%0)),,, %0)),,, %0)

&f.grab-matching-settable-object [v(d.bf)]=case(1, strmatch(%0, me), %1, cand(strmatch(%0, here), cor(isstaff(%1), isowner(loc(%0), %1))), loc(%1), cand(isstaff(%1), isdbref(%0)), %0, isdbref(%0), if(member(ulocal(f.available-objects-to-set-%2s, %1), %0), %0, #-1 NOT FOUND), t(setr(M, grab(iter(ulocal(f.available-objects-to-set-%2s, %1), strcat(name(itext(0)), ~, itext(0)),, v(d.default-row-delimeter)), %0*, v(d.default-row-delimeter)))), rest(%qM, ~), #-1 NOT FOUND)

&c.+view [v(d.bc)]=$+view:@assert t(setr(V, filter(filter.has-views, ulocal(f.available-objects-to-view, %#))))={ @trigger me/tr.error=%#, There are no objects with +views in your area.; }; @assert gt(words(%qV), 1)={ @force %#=+view %qV; }; @trigger me/tr.message=%#, The following objects have +views on them: [itemize(ulocal(f.objects-with-views, %qV), v(d.default-row-delimeter))];

&c.+view_item [v(d.bc)]=$+view *:@break strmatch(%0, */*); @assert t(setr(O, ulocal(f.grab-matching-object, %0, %#, view)))={ @trigger me/tr.error=%#, Could not find an object called '%0'.; }; @assert t(setr(V, getpair(%qO, view-)))={ @trigger me/tr.error=%#, moniker(%qO) does not have +views.; }; @assert gt(words(%qV, v(d.default-row-delimeter)), 1)={ @force %#=+view %qO/[rest(%qV, v(d.default-column-delimeter))]; }; @trigger me/tr.message=%#, moniker(%qO) has the following +views: [itemize(iter(%qV, rest(itext(0), v(d.default-column-delimeter)), v(d.default-row-delimeter), v(d.default-row-delimeter)), v(d.default-row-delimeter))];

&c.+view_item_view [v(d.bc)]=$+view */*:@assert t(setr(O, ulocal(f.grab-matching-object, %0, %#, view)))={ @trigger me/tr.error=%#, Could not find an object called '%0'.; }; @assert t(setr(V, getpair(%qO, view-, %1)))={ @trigger me/tr.error=%#, moniker(%qO) does not have a +view matching '%1'.; }; @break strmatch(%qV, view-*[v(d.default-column-delimeter)]*[v(d.default-row-delimeter)]*)={ @trigger me/tr.message=%#, moniker(%qO) has the following +views: [itemize(iter(%qV, rest(itext(0), v(d.default-column-delimeter)), v(d.default-row-delimeter), v(d.default-row-delimeter)), v(d.default-row-delimeter))]; }; @break strmatch(%qV, view-*[v(d.default-column-delimeter)]*)={ @force %#=+view %qO/[rest(%qV, v(d.default-column-delimeter))]; }; @pemit %#=ulocal(layout.view, %qO, %1, %qV, %#);

&c.+view/set_full [v(d.bc)]=$+view/s* */*=*:@assert t(setr(O, ulocal(f.grab-matching-settable-object, %1, %#, view)))={ @trigger me/tr.error=%#, Could not find an object you own called '%1'.; }; @assert t(setr(S, setpair(%qO, view-, %2, %3)))={ @trigger me/tr.error=%#, Could not set +view on [moniker(%qO)] because: %qS; }; @assert t(setr(V, getpair(%qO, view-, %2)))={ @trigger me/tr.success=%#, moniker(%qO)'s +view '%2' cleared.; }; @trigger me/tr.success=%#, moniker(%qO)'s [getpairkey(%qO, view-, %2)] +view was [lcstr(%qS)];  @pemit %#=ulocal(layout.view, %qO, %2, %qV, %#);

@set [v(d.bc)]/c.+view/set_full=no_parse

&c.+view/set [v(d.bc)]=$+view/s* *=*:@break strmatch(%1, */*); @force %#=+view/set me/%1=%2;

@set [v(d.bc)]/c.+view/set=no_parse

&c.+view/add [v(d.bc)]=$+view/add */*=*:@force %#=+view/set %0/%1=%2;

@set [v(d.bc)]/c.+view/add=no_parse

&c.+view/delete [v(d.bc)]=$+view/del* */*:@assert t(setr(O, ulocal(f.grab-matching-settable-object, %1, %#, view)))={ @trigger me/tr.error=%#, Could not find an object you own called '%1'.; }; @assert t(setr(V, getpairkey(%qO, view-, %2)))={ @trigger me/tr.error=%#, Could not find a view on [moniker(%qO)] called '%2'.; }; @assert eq(words(%qV, v(d.default-row-delimeter)), 1)={ @trigger me/tr.error=%#, Your delete matched multiple +views: [itemize(iter(%qV, rest(itext(0), v(d.default-column-delimeter)), v(d.default-row-delimeter), v(d.default-row-delimeter)), v(d.default-row-delimeter))]; }; @force %#=+view/set %qO/%qV=; @pemit %#=%qV;

+view/del me/Testing!

&c.+view/remove [v(d.bc)]=$+view/rem* */*:@assert t(setr(O, ulocal(f.grab-matching-settable-object, %1, %#, view)))={ @trigger me/tr.error=%#, Could not find an object you own called '%1'.; }; @assert t(setr(V, getpairkey(%qO, view-, %2)))={ @trigger me/tr.error=%#, Could not find a view on [moniker(%qO)] called '%2'.; }; @assert eq(words(%qV, v(d.default-row-delimeter)), 1)={ @trigger me/tr.error=%#, Your delete matched multiple +views: [itemize(iter(%qV, rest(itext(0), v(d.default-column-delimeter)), v(d.default-row-delimeter), v(d.default-row-delimeter)), v(d.default-row-delimeter))]; }; @force %#=+view/set %qO/%qV=;

&c.+view/delete_me [v(d.bc)]=$+view/del* *:@break strmatch(%1, */*); @eval setr(O, %#); @assert t(setr(V, getpairkey(%qO, view-, %1)))={ @trigger me/tr.error=%#, Could not find a view on [moniker(%qO)] called '%1'.; }; @assert eq(words(%qV, v(d.default-row-delimeter)), 1)={ @trigger me/tr.error=%#, Your delete matched multiple +views: [itemize(iter(%qV, rest(itext(0), v(d.default-column-delimeter)), v(d.default-row-delimeter), v(d.default-row-delimeter)), v(d.default-row-delimeter))]; }; @force %#=+view/set %qO/%qV=;

&c.+view/remove_me [v(d.bc)]=$+view/rem* *:@break strmatch(%1, */*); @eval setr(O, %#); @assert t(setr(V, getpairkey(%qO, view-, %1)))={ @trigger me/tr.error=%#, Could not find a view on [moniker(%qO)] called '%1'.; }; @assert eq(words(%qV, v(d.default-row-delimeter)), 1)={ @trigger me/tr.error=%#, Your delete matched multiple +views: [itemize(iter(%qV, rest(itext(0), v(d.default-column-delimeter)), v(d.default-row-delimeter), v(d.default-row-delimeter)), v(d.default-row-delimeter))]; }; @force %#=+view/set %qO/%qV=;

@@ =============================================================================
@@ +note
@@ =============================================================================

&layout.note_title [v(d.bf)]=strcat(if(t(%2), %2%b), moniker(%0)'s, %b, if(strmatch(setr(0, getpairkey(%0, _note-, %1)), *[v(d.default-column-delimeter)]*),, %q0), %b, note)

&layout.note_footer [v(d.bf)]=cat(This note is, case(ulocal(f.get-note-visibility-setting, %0, getpairattr(%0, _note-, %1)), -1, hidden, 0, private, 1, public).)

&layout.note [v(d.bf)]=strcat(header(ulocal(layout.note_title, %0, %1, %4), %3), %r, formattext(ulocal(%0/[first(%2, v(d.default-column-delimeter))]), 0, %3), %r, formattext(strcat(%r, if(t(setr(A, rest(default(%0/_notesettings-[getpairattr(%0, _note-, %1)], 0|), |))), %cgApproved%cn: %qA, %crUnapproved%cn: Staff has not approved this +note.)), 0, %3),, %r, footer(ulocal(layout.note_footer, %0, %1), %3))

&f.objects-with-notes [v(d.bf)]=iter(%0, moniker(itext(0)),, |)

&f.available-objects-to-note [v(d.bf)]=cat(loc(%0), filter(filter.not_dark, lcon(loc(%0)),,, %0), filter(filter.isobject, lcon(loc(%0))), filter(filter.visible-exit, lexits(loc(%0)),,, %0))

&f.available-objects-to-set-notes [v(d.bf)]=filter(filter.is_owner, cat(loc(%0), filter(filter.not_dark, lcon(loc(%0)),,, %0), filter(filter.isobject, lcon(loc(%0))), filter(filter.visible-exit, lexits(loc(%0)),,, %0)),,, %0)

&c.+note [v(d.bc)]=$+note:@assert t(setr(V, filter(filter.has-notes, ulocal(f.available-objects-to-note, %#),,, %#)))={ @trigger me/tr.error=%#, There are no objects with +notes in your area.; }; @assert gt(words(%qV), 1)={ @force %#=+note %qV; }; @trigger me/tr.message=%#, The following objects have +notes on them: [itemize(ulocal(f.objects-with-notes, %qV), v(d.default-row-delimeter))];

&c.+note_item [v(d.bc)]=$+note *:@break strmatch(%0, */*); @assert t(setr(O, ulocal(f.grab-matching-object, %0, %#, note)))={ @trigger me/tr.error=%#, Could not find an object called '%0'.; }; @assert t(setr(V, ulocal(f.get-visible-notes, %qO,, %#)))={ @trigger me/tr.error=%#, moniker(%qO) does not have +notes.; }; @assert gt(words(%qV, v(d.default-row-delimeter)), 1)={ @force %#=+note %qO/[rest(%qV, v(d.default-column-delimeter))]; }; @trigger me/tr.message=%#, moniker(%qO) has the following +notes: [itemize(iter(%qV, rest(itext(0), v(d.default-column-delimeter)), v(d.default-row-delimeter), v(d.default-row-delimeter)), v(d.default-row-delimeter))];

&c.+note_item_note [v(d.bc)]=$+note */*:@assert t(setr(O, ulocal(f.grab-matching-object, %0, %#, note)))={ @trigger me/tr.error=%#, Could not find an object called '%0'.; }; @assert t(setr(V, ulocal(f.get-visible-notes, %qO, %1, %#)))={ @trigger me/tr.error=%#, moniker(%qO) does not have a +note matching '%1'.; }; @break strmatch(%qV, _note-*[v(d.default-column-delimeter)]*[v(d.default-row-delimeter)]*)={ @trigger me/tr.message=%#, moniker(%qO) has the following +notes: [itemize(iter(%qV, rest(itext(0), v(d.default-column-delimeter)), v(d.default-row-delimeter), v(d.default-row-delimeter)), v(d.default-row-delimeter))]; }; @pemit %#=ulocal(layout.note, %qO, if(t(%1), %1, xget(%qO, strcat(ulocal(f.get-key-prefix, _note-), after(first(%qV, v(d.default-column-delimeter)), -)))), %qV, %#);

&c.+note/set_full [v(d.bc)]=$+note/s* */*=*:@assert t(setr(O, ulocal(f.grab-matching-settable-object, %1, %#, note)))={ @trigger me/tr.error=%#, Could not find an object you own called '%1'.; }; @eval setq(K, getpairattr(%qO, _note-, %2)); @break t(ulocal(f.get-note-approval-status, %qO, %qK))={ @trigger me/tr.error=%#, This note is approved. Get staff to unapprove it if you'd like to make changes.; }; @assert t(setr(S, setpair(%qO, _note-, %2, %3)))={ @trigger me/tr.error=%#, Could not set +note on [moniker(%qO)] because: %qS; }; @assert t(setr(V, ulocal(f.get-visible-notes, %qO, %2, %#)))={ @wipe %qO/_notesettings-%qK; @trigger me/tr.success=%#, moniker(%qO)'s +note '%2' cleared.; }; @trigger me/tr.success=%#, moniker(%qO)'s [getpairkey(%qO, _note-, %2)] +note was [lcstr(%qS)]; @force %#=+note %qO/%2;

@set [v(d.bc)]/c.+note/set_full=no_parse

&c.+note/set [v(d.bc)]=$+note/s* *=*:@break strmatch(%1, */*); @force %#=+note/set me/%1=%2;

@set [v(d.bc)]/c.+note/set=no_parse

&c.+note/add [v(d.bc)]=$+note/add */*=*:@force %#=+note/set %0/%1=%2;

@set [v(d.bc)]/c.+note/add=no_parse

&c.+note/delete [v(d.bc)]=$+note/del* */*:@assert t(setr(O, ulocal(f.grab-matching-settable-object, %1, %#, note)))={ @trigger me/tr.error=%#, Could not find an object you own called '%1'.; }; @assert t(setr(V, ulocal(f.get-visible-notes, %qO, %2, %#)))={ @trigger me/tr.error=%#, Could not find a note on [moniker(%qO)] called '%2'.; }; @assert eq(words(%qV, v(d.default-row-delimeter)), 1)={ @trigger me/tr.error=%#, Your delete matched multiple +notes: [itemize(iter(%qV, rest(itext(0), v(d.default-column-delimeter)), v(d.default-row-delimeter), v(d.default-row-delimeter)), v(d.default-row-delimeter))]; }; @force %#=+note/set %qO/[rest(%qV, v(d.default-column-delimeter))]=;

&c.+note/remove [v(d.bc)]=$+note/rem* */*:@assert t(setr(O, ulocal(f.grab-matching-settable-object, %1, %#, note)))={ @trigger me/tr.error=%#, Could not find an object you own called '%1'.; }; @assert t(setr(V, ulocal(f.get-visible-notes, %qO, %2, %#)))={ @trigger me/tr.error=%#, Could not find a note on [moniker(%qO)] called '%2'.; }; @assert eq(words(%qV, v(d.default-row-delimeter)), 1)={ @trigger me/tr.error=%#, Your delete matched multiple +notes: [itemize(iter(%qV, rest(itext(0), v(d.default-column-delimeter)), v(d.default-row-delimeter), v(d.default-row-delimeter)), v(d.default-row-delimeter))]; }; @force %#=+note/set %qO/[rest(%qV, v(d.default-column-delimeter))]=;

&c.+note/delete_me [v(d.bc)]=$+note/del* *:@break strmatch(%1, */*); @eval setr(O, %#); @assert t(setr(V, ulocal(f.get-visible-notes, %qO, %1, %#)))={ @trigger me/tr.error=%#, Could not find a note on [moniker(%qO)] called '%1'.; }; @assert eq(words(%qV, v(d.default-row-delimeter)), 1)={ @trigger me/tr.error=%#, Your delete matched multiple +notes: [itemize(iter(%qV, rest(itext(0), v(d.default-column-delimeter)), v(d.default-row-delimeter), v(d.default-row-delimeter)), v(d.default-row-delimeter))]; }; @force %#=+note/set %qO/[rest(%qV, v(d.default-column-delimeter))]=;

&c.+note/remove_me [v(d.bc)]=$+note/rem* *:@break strmatch(%1, */*); @eval setr(O, %#); @assert t(setr(V, ulocal(f.get-visible-notes, %qO, %1, %#)))={ @trigger me/tr.error=%#, Could not find a note on [moniker(%qO)] called '%1'.; }; @assert eq(words(%qV, v(d.default-row-delimeter)), 1)={ @trigger me/tr.error=%#, Your delete matched multiple +notes: [itemize(iter(%qV, rest(itext(0), v(d.default-column-delimeter)), v(d.default-row-delimeter), v(d.default-row-delimeter)), v(d.default-row-delimeter))]; }; @force %#=+note/set %qO/[rest(%qV, v(d.default-column-delimeter))]=;

&c.+note/staffnote [v(d.bc)]=$+staffnote* */*=*:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to create staff notes.; }; @assert t(setr(O, ulocal(f.grab-matching-settable-object, %1, %#, note)))={ @trigger me/tr.error=%#, Could not find an object you own called '%1'.; }; @break strmatch(rest(setr(V, ulocal(f.get-visible-notes, %qO, %2, %#)), v(d.default-column-delimeter)), %2)={ @trigger me/tr.error=%#, There's already a note on [moniker(%qO)] called '%2'. Choose another name or delete the old one.; }; @assert t(setr(S, setpair(%qO, _note-, %2, %3)))={ @trigger me/tr.error=%#, Could not set +note on [moniker(%qO)] because: %qS; }; @assert t(setr(K, getpairattr(%qO, _note-, %2)))={ @trigger me/tr.error=%#, Could not find a note on [moniker(%qO)] called '%2'. Check their +notes.; }; &_notesettings-%qK %qO=strcat(-1, |, ulocal(layout.note-approval, %#)); @trigger me/tr.success=%#, moniker(%qO)'s %2 +note was created%, hidden%, and approved.;

&layout.note-approval [v(d.bf)]=cat(moniker(%0), approved this note on, prettytime())

&c.+note/approve [v(d.bc)]=$+note/ap* */*:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to approve notes.; }; @assert t(setr(O, ulocal(f.grab-matching-settable-object, %1, %#, note)))={ @trigger me/tr.error=%#, Could not find an object you own called '%1'.; }; @assert t(setr(K, getpairattr(%qO, _note-, %2)))={ @trigger me/tr.error=%#, Could not find a note on [moniker(%qO)] called '%2'.; }; &_notesettings-%qK %qO=strcat(ulocal(f.get-note-visibility-setting, %qO, %qK), |, ulocal(layout.note-approval, %#)); @trigger me/tr.success=%#, moniker(%qO)'s [getpairkey(%qO, _note-, %2)] +note was approved.;

&c.+note/unapprove [v(d.bc)]=$+note/unap* */*:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to unapprove notes.; }; @assert t(setr(O, ulocal(f.grab-matching-settable-object, %1, %#, note)))={ @trigger me/tr.error=%#, Could not find an object you own called '%1'.; }; @assert t(setr(K, getpairattr(%qO, _note-, %2)))={ @trigger me/tr.error=%#, Could not find a note on [moniker(%qO)] called '%2'.; }; &_notesettings-%qK %qO=strcat(ulocal(f.get-note-visibility-setting, %qO, %qK), |); @trigger me/tr.success=%#, moniker(%qO)'s [getpairkey(%qO, _note-, %2)] +note was unapproved.;

&c.+note/hide [v(d.bc)]=$+note/h* */*:@assert isstaff(%#)={ @force %#=+note/private %1/%2; }; @assert t(setr(O, ulocal(f.grab-matching-settable-object, %1, %#, note)))={ @trigger me/tr.error=%#, Could not find an object you own called '%1'.; }; @assert t(setr(K, getpairattr(%qO, _note-, %2)))={ @trigger me/tr.error=%#, Could not find a note on [moniker(%qO)] called '%2'.; }; &_notesettings-%qK %qO=strcat(-1|, ulocal(f.get-note-approval-status, %qO, %qK)); @trigger me/tr.success=%#, moniker(%qO)'s [getpairkey(%qO, _note-, %2)] +note was hidden. Only staff can see it now.;

&c.+note/unhide [v(d.bc)]=$+note/unh* */*:@assert isstaff(%#)={ @force %#=+note/public %1/%2; }; @assert t(setr(O, ulocal(f.grab-matching-settable-object, %1, %#, note)))={ @trigger me/tr.error=%#, Could not find an object you own called '%1'.; }; @assert t(setr(K, getpairattr(%qO, _note-, %2)))={ @trigger me/tr.error=%#, Could not find a note on [moniker(%qO)] called '%2'.; }; &_notesettings-%qK %qO=strcat(0|, ulocal(f.get-note-approval-status, %qO, %qK)); @trigger me/tr.success=%#, moniker(%qO)'s [getpairkey(%qO, _note-, %2)] +note was unhidden. The owner of the note and staff can see it now.;

&c.+note/public [v(d.bc)]=$+note/pu* */*:@assert t(setr(O, ulocal(f.grab-matching-settable-object, %1, %#, note)))={ @trigger me/tr.error=%#, Could not find an object you own called '%1'.; }; @assert t(setr(K, getpairattr(%qO, _note-, %2)))={ @trigger me/tr.error=%#, Could not find a note on [moniker(%qO)] called '%2'.; }; &_notesettings-%qK %qO=strcat(1|, ulocal(f.get-note-approval-status, %qO, %qK)); @trigger me/tr.success=%#, moniker(%qO)'s [getpairkey(%qO, _note-, %2)] +note was set public. Everyone can see it now.;

&c.+note/private [v(d.bc)]=$+note/pri* */*:@assert t(setr(O, ulocal(f.grab-matching-settable-object, %1, %#, note)))={ @trigger me/tr.error=%#, Could not find an object you own called '%1'.; }; @assert t(setr(K, getpairattr(%qO, _note-, %2)))={ @trigger me/tr.error=%#, Could not find a note on [moniker(%qO)] called '%2'.; }; &_notesettings-%qK %qO=strcat(0|, ulocal(f.get-note-approval-status, %qO, %qK)); @trigger me/tr.success=%#, moniker(%qO)'s [getpairkey(%qO, _note-, %2)] +note was set private. Only the owner of the note and staff can see it now.;

&c.+note/prove [v(d.bc)]=$+note/pro* */*=*:@assert t(setr(O, ulocal(f.grab-matching-settable-object, %1, %#, note)))={ @trigger me/tr.error=%#, Could not find an object you own called '%1'.; }; @assert cand(t(setr(K, getpairattr(%qO, _note-, %2))), t(setr(V,  ulocal(f.get-visible-notes, %qO, %2, %#))))={ @trigger me/tr.error=%#, Could not find a note on [moniker(%qO)] called '%2'.; }; @assert t(setr(P, ulocal(f.find-player, %3, %#)))={ @assert strmatch(%3, here)={ @trigger me/tr.error=%#, Could not find a player named '%3'.; }; @dolist lcon(loc(%#))={ @trigger me/tr.pemit=##, ulocal(layout.note, %qO, %2, %qV, %#, moniker(%#) proves:), %#; }; }; @pemit %#=ulocal(layout.note, %qO, %2, %qV, %#, moniker(%#) proves:); @trigger me/tr.pemit=%qP, ulocal(layout.note, %qO, %2, %qV, %#, moniker(%#) proves:), %#;

&c.+note/prove_me [v(d.bc)]=$+note/pro* *=*:@break strmatch(%1, */*); @force %#=+note/prove me/%1=%2;

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
