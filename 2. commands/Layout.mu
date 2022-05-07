/* This is a work in progress! This doesn't really DO anything yet. */

&f.get-ansi [v(d.bf)]=extract(%0, if(lte(%1, words(%0)), %1, inc(mod(%1, words(%0)))), 1)

@@ &f.globalpp.header [v(d.bf)]=ulocal(layout.liner, %1, header, %0)

@@ &f.globalpp.footer [v(d.bf)]=ulocal(layout.liner, %1, footer, %0)

@@ &f.globalpp.divider [v(d.bf)]=ulocal(layout.liner, %1, divider, %0)

@@ &f.globalpp.alert [v(d.bf)]=ulocal(layout.alert, %0)

@@ &f.globalpp.themecolors [v(d.bf)]=unionset(v(d.title.colors), setunion(v(d.header.colors), setunion(v(d.footer.colors), setunion(v(d.divider.colors), v(d.other.colors)))))

@@ %0: left border text
@@ %1: right border text
@@ %2: inner left border text
@@ %3: inner right border text
@@ %4: text
@@ %5: fill text
@@ %6: player
@@ %7: header, footer, divider
&layout.left-working-align [v(d.bf)]=strcat(setr(0, strcat(%b, %0, %2, %b, %4, %b, %3)), ulocal(layout.apply-working-effect, %6, %7, repeat(%5, sub(ulocal(f.get-width, %6), add(strlen(%q0), strlen(%1))))), %1)

&layout.left-align [v(d.bf)]=strcat(setr(0, strcat(%b, %0, %2, %b, %4, %b, %3)), ulocal(layout.apply-effect, %6, %7, repeat(%5, sub(ulocal(f.get-width, %6), add(strlen(%q0), strlen(%1))))), %1)

&layout.right-working-align [v(d.bf)]=strcat(setr(0, strcat(%b, %0)), setq(1, strcat(%2, %b, %4, %b, %3, %1)), ulocal(layout.apply-working-effect, %6, %7, repeat(%5, sub(ulocal(f.get-width, %6), add(strlen(%q0), strlen(%q1))))), %q1)

&layout.right-align [v(d.bf)]=strcat(setr(0, strcat(%b, %0)), setq(1, strcat(%2, %b, %4, %b, %3, %1)), ulocal(layout.apply-effect, %6, %7, repeat(%5, sub(ulocal(f.get-width, %6), add(strlen(%q0), strlen(%q1))))), %q1)

&layout.center-working-align [v(d.bf)]=strcat(setr(0, strcat(%b, %0)), setq(1, strcat(%2, %b, %4, %b, %3)), ulocal(layout.apply-working-effect, %6, %7, repeat(%5, strcat(setq(2, sub(ulocal(f.get-width, %6), add(strlen(%q0), strlen(%q1), strlen(%1)))), div(%q2, 2)))), %q1, ulocal(layout.apply-working-effect, %6, %7, repeat(%5, add(div(%q2, 2), mod(%q2, 2)))), %1)

&layout.center-align [v(d.bf)]=strcat(setr(0, strcat(%b, %0)), setq(1, strcat(%2, %b, %4, %b, %3)), ulocal(layout.apply-effect, %6, %7, repeat(%5, strcat(setq(2, sub(ulocal(f.get-width, %6), add(strlen(%q0), strlen(%q1), strlen(%1)))), div(%q2, 2)))), %q1, ulocal(layout.apply-effect, %6, %7, repeat(%5, add(div(%q2, 2), mod(%q2, 2)))), %1)

@@ %0: left border text
@@ %1: text
@@ %2: right border text
@@ %3: inner width
&layout.box-line [v(d.bf)]=strcat(%b, %0, %b, ljust(%1, max(%3, strlen(%1))), %b, %2)

@@ %0: left border text
@@ %1: text
@@ %2: right border text
@@ %3: player
&layout.box-text [v(d.bf)]=iter(wrap(%1, ulocal(f.get-working-remaining-width, %0, %1, %2, %3)), ulocal(layout.box-line, %0, itext(0), %2, ulocal(f.get-working-box-width, %0, itext(0), %2, %3)), %r, %r)

&layout.table-text [v(d.bf)]=strcat(setq(W, ulocal(f.get-working-box-width, %0, space(36), %2, %3)), iter(%1, ulocal(layout.box-line, %0, strcat(setq(C, if(eq(inum(0), 1), first(ulocal(f.get-working-layout, %3, title.colors))u)), ansi(%qC, ljust(first(itext(0), ~), 35)), %b, ansi(%qC, ljust(rest(itext(0), ~), %qW))), %2, ulocal(f.get-working-box-width, %0, itext(0), %2, %3)), |, %r))

&f.get-working-box-width [v(d.bf)]=sub(ulocal(f.get-width, %3), strlen(strcat(%b, %0, %b, %1, %b, %2)))

&f.get-working-remaining-width [v(d.bf)]=sub(ulocal(f.get-width, %3), strlen(strcat(%b, %0, %b, %b, %2)))

@@ Effects:
@@ 	Repeat: ABCABCABC
@@ 	Stretch: AAABBBCCC
@@ 	Start: ABCCCCCCC
@@ 	End: AAAAAAABC
@@ 	Random: CABBCAACB
@@  None: no colors

&effect.none [v(d.bf)]=%0

@@ %0: text to colorize
@@ %1: colors to use
&effect.repeat [v(d.bf)]=if(t(%1), iter(lnum(strlen(%0)), ansi(ulocal(f.get-ansi, %1, inum(0)), mid(%0, itext(0), 1)),, @@), ulocal(effect.none, %0))

&effect.random [v(d.bf)]=if(t(%1), iter(lnum(strlen(%0)), ansi(pickrand(%1), mid(%0, itext(0), 1)),, @@), ulocal(effect.none, %0))

@@ %0: length of the string to stretch across
@@ %1: number of colors to stretch
&f.get-stretch-values [v(d.bf)]=strcat(setq(M, if(gt(%0, %1), mod(%0, %1), 0)), iter(lnum(%1), add(max(floor(fdiv(%0, %1)), 1), if(cand(gt(inum(0), div(%1, 2)), t(%qM)), %qM[setq(M, 0)], 0))))

&effect.stretch [v(d.bf)]=if(t(%1), iter(ulocal(f.get-stretch-values, strlen(%0), words(%1), setq(L, 0)), strcat(ansi(ulocal(f.get-ansi, %1, inum(0)), mid(%0, %qL, itext(0))), setq(L, add(%qL, itext(0)))),, @@), ulocal(effect.none, %0))

&effect.start [v(d.bf)]=if(t(%1), iter(lnum(strlen(%0)), ansi(if(lte(inum(0), words(%1)), ulocal(f.get-ansi, %1, inum(0)), last(%1)), mid(%0, itext(0), 1)),, @@), ulocal(effect.none, %0))

&effect.end [v(d.bf)]=if(t(%1), reverse(ulocal(effect.start, reverse(%0), %1)), ulocal(effect.none, %0))

@@ %0: the player
@@ %1: header, footer, or divider
@@ %2: text
&layout.apply-working-effect [v(d.bf)]=ulocal(strcat(effect., default(%0/d.%1.effect, none)), %2, ulocal(f.get-working-layout, %0, %1.colors))

&layout.apply-effect [v(d.bf)]=ulocal(strcat(effect., default(d.%1.effect, none)), %2, ulocal(f.get-layout, %0, %1.colors))

&f.get-working-layout [v(d.bf)]=udefault(%0/d.%1, switch(%1, *alignment, left, alert*,, %b))

&f.get-layout [v(d.bf)]=udefault(%vD/d.%1, switch(%1, *alignment, left, alert*,, %b), %0)

@@ %0: player
@@ %1: header, footer, or divider
@@ %2: text to test with
&layout.working-liner [v(d.bf)]=ulocal(strcat(layout., ulocal(f.get-working-layout, %0, %1.alignment), -working-align), ulocal(f.get-working-layout, %0, %1.left), ulocal(f.get-working-layout, %0, %1.right), ulocal(f.get-working-layout, %0, %1.inner-left), ulocal(f.get-working-layout, %0, %1.inner-right), %2, ulocal(f.get-working-layout, %0, %1.fill), %0, %1)

&layout.liner [v(d.bf)]=ulocal(strcat(layout., ulocal(f.get-layout, %0, %1.alignment), -align), ulocal(f.get-layout, %0, %1.left), ulocal(f.get-layout, %0, %1.right), ulocal(f.get-layout, %0, %1.inner-left), ulocal(f.get-layout, %0, %1.inner-right), %2, ulocal(f.get-layout, %0, %1.fill), %0, %1)

&layout.working-alert [v(d.bf)]=strcat(ulocal(f.get-working-layout, %0, alert.left), ulocal(f.get-working-layout, %0, alert.inner-left), %b, v(d.default-alert), %b, ulocal(f.get-working-layout, %0, alert.inner-right), ulocal(f.get-working-layout, %0, alert.right), %b)

&layout.alert [v(d.bf)]=strcat(ulocal(f.get-layout, %0, alert.left), ulocal(f.get-layout, %0, alert.inner-left), %b, if(t(%0), %0, v(d.default-alert)), %b, ulocal(f.get-layout, %0, alert.inner-right), ulocal(f.get-layout, %0, alert.right), %b)

@@ %0: player
@@ %1: text
@@ %2: box or table
&layout.working-body [v(d.bf)]=ulocal(layout.%2-text, ulocal(f.get-working-layout, %0, body.left), %1, ulocal(f.get-working-layout, %0, body.right), %0)

@@ Issue: Can't use multicol or formattext with this - will have to hardcode it to use the player's working layout.

@@ Issue: The body is currently missing the vertical patterning.

&layout.working-layout [v(d.bf)]=strcat(ulocal(layout.working-liner, %0, header, Working layout and appearance), %r, ulocal(layout.working-body, %0, strcat(%r, indent(), This is your current working example for the game's general appearance. You should customize this to look different from other games so that players don't get confused and so that you have your own unique game style., %r%r%t, This display is a sample. As such%, it may not look quite as good as the real thing. You may need to try a few different variants to get the real thing to look the way you want it to., %r%b), box), %r, ulocal(layout.working-liner, %0, divider, Layout commands), %r, ulocal(layout.working-body, %0, %b, box), %r, ulocal(layout.working-body, %0, strcat(Commands, ~, Description, |, +layout/<section> <field>=<value>, ~, Set various layout values., |, space(3), Sections are:, ~, body%, header%, divider%, footer%, title%, |~, and alert, |, space(3), Settings are:, ~, left%, right%, fill%, inner-left%,, |~, inner-right%, alignment%, colors%, and, |~, effect, |, space(3), Alignments are:, ~, left%, right%, and center, |, space(3), Effects are:, ~, repeat%, random%, start%, end%, stretch%, and, |~, none (default), |, +layout/save, ~, Replace the game's current layout., |, +layout/current, ~, View the game's current layout., |, +layout/clear, ~, Clear your current working layout. Will, |~, ask if you're sure.), table), %r, ulocal(layout.working-body, %0, %b, box), %r, ulocal(layout.working-liner, %0, footer, +layout/save to make this the game's layout!), %r, ulocal(layout.working-alert, %0) This is what the alert looks like.)

&layout.current [v(d.bf)]=strcat(header(Current layout and appearance, %0), %r, formattext(This is the game's current appearance using all of our standard commands and functions. It should look different from other games so that players don't get confused when flipping between windows. Each game has its own unique style. This is yours., 1, %0), %r, divider(Layout commands, %0), %r, formattext(%b, 0, %0), %r, multicol(strcat(Commands, |, Description, |, +layout/<section> <field>=<value>, |, Set various layout values., |, space(3), Sections are:, |, body%, header%, divider%, footer%, title%, and alert, |, space(3), Settings are:, |, left%, right%, fill%, inner-left%, inner-right%, alignment%, colors%, and, effect, |, space(3), Alignments are:, |, left%, right%, and center, |, space(3), Effects are:, |, repeat%, random%, start%, end%, stretch%, and, none (default), |, +layout/save, |, Replace the game's current layout., |, +layout/current, |, View the game's current layout., |, +layout/clear, |, Clear your current working layout. Will ask if you're sure.), * *, 1, |, %0), %r, formattext(%b, 0, %0), %r, footer(+layout to view your working layout, %0), %r, alert() This is what the alert looks like.)

&c.+layout [v(d.bc)]=$+layout:@pemit %#=ulocal(layout.working-layout, %#);

&c.+layout/current [v(d.bc)]=$+layout/cu*:@break strmatch(%0, *=*); @pemit %#=ulocal(layout.current, %#);

&c.+layout/clear [v(d.bc)]=$+layout/cl*:@break strmatch(%0, *=*); @assert gettimer(%#, clear-layout)={ @trigger me/tr.message=%#, You are about to clear your current working layout. This will start you over from scratch. Are you sure? If yes%, type %ch+layout/clear%cn again within the next 10 minutes. The time is now [prettytime()].; @eval settimer(%#, clear-layout, 600); }; @dolist iter(v(d.layout-sections), iter(v(d.layout-settings), strcat(d., itext(1), ., itext(0)), |,), |,)={ @wipe %#/##; }; @trigger me/tr.success=%#, Your working layout has been cleared.;

&d.layout-sections [v(d.bd)]=body|header|footer|divider|title|alert

&d.layout-effects [v(d.bd)]=repeat|random|start|end|stretch|none

&d.layout-settings [v(d.bd)]=left|right|fill|inner-left|inner-right|alignment|colors|effect

&c.+layout/set [v(d.bc)]=$+layout/* *=*:@assert isstaff(%#)={ @trigger me/tr.error=#, Only staff can set the game's layout.; }; @assert t(setr(F, finditem(setr(L, v(d.layout-sections)), %0, |)))={ @trigger me/tr.error=%#, Layout section must be either [ulocal(layout.list, %qL, or)]. You provided '%0'.; }; @assert t(setr(S, finditem(setr(L, v(d.layout-settings)), %1, |)))={ @trigger me/tr.error=%#, Layout setting must be either [ulocal(layout.list, %qL, or)]. You provided '%1'.; }; @eval setq(V, %2); @assert cor(not(strmatch(%qS, alignment)), t(setr(V, finditem(left|right|center, %2, |))))={ @trigger me/tr.error=%#, You must specify either left%, right%, or center for alignment.; }; @assert cor(not(strmatch(%qS, effect)), t(setr(V, finditem(setr(L, v(d.layout-effects)), %qV, |))))={ @trigger me/tr.error=%#, Valid values for 'effect' are [ulocal(layout.list, %qL)].; }; @assert cor(not(cand(strmatch(%qF, title), strmatch(%qS, colors))), eq(words(%qV), 1))={ @trigger me/tr.error=%#, Title only supports one color right now.; }; @set %#=d.%qF.%qS:%qV; @trigger me/tr.success=%#, You set your working layout's %qF %qS to: %qV;

@set [v(d.bc)]/c.+layout/set=no_parse

&c.+layout/save [v(d.bc)]=$+layout/save:@assert isstaff(%#)={ @trigger me/tr.error=%#, Only staff can change the game's layout.; }; @assert gettimer(%#, save-layout)={ @trigger me/tr.message=%#, You are about to save your current working layout as the game's layout. This will override whatever you already have there%, which you can see with %ch+layout/current%cn. Are you sure? If yes%, type %ch+layout/save%cn again within the next 10 minutes. The time is now [prettytime()].; @eval settimer(%#, save-layout, 600); }; @dolist iter(v(d.layout-sections), iter(v(d.layout-settings), strcat(d., itext(1), ., itext(0)), |,), |,)={ @cpattr %#/##=%vD; }; @trigger me/tr.success=%#, Your game's layout has been updated.;


@@ Try out layouts.

+layout/h l=%cx%ch)%cn%c<#894ff7>xx
+layout/h r=%ch%cx>
+layout/h inner-l=%ch%cx[
+layout/h inner-r=%ch%cx]
+layout/h fill==
+layout/h align=l
+layout/b l=:
+layout/b r=:
+layout/d l=%ch%cx<
+layout/d r=%ch%cx>
+layout/d inner-l=%ch%cx]%c<#894ff7>xx%cx%ch(
+layout/d inner-r=%cx%ch)%cn%c<#894ff7>xx%ch%cx[
+layout/d fill==
+layout/d align=c
+layout/f l=%cx%ch<
+layout/f r=%c<#894ff7>xx%cx%ch(
+layout/f inner-l=%cx%ch[
+layout/f inner-r=%cx%ch]
+layout/f fill==
+layout/f align=r
+layout/a l=%cx%ch)%cn%c<#894ff7>xx
+layout/a r=%c<#b2b2b2>>
+layout/a inner-l=%ch%cx[
+layout/a inner-r=%ch%cx]%c<#585858>=%c<#949494>=

+layout/header color=c<#585858> c<#767676> c<#949494> c<#b2b2b2> c<#d0d0d0> c<#eeeeee> c<#eeeeee> c<#eeeeee> c<#d0d0d0> c<#b2b2b2> c<#949494> c<#767676> c<#585858>
+layout/header effect=stretch

+layout/title color=c<#d4c0fa>

+layout/f color=c<#585858> c<#767676> c<#949494> c<#b2b2b2> c<#d0d0d0> c<#eeeeee> c<#eeeeee> c<#eeeeee> c<#d0d0d0> c<#b2b2b2> c<#949494> c<#767676> c<#585858>
+layout/f effect=stretch

+layout/d color=c<#585858> c<#767676> c<#949494> c<#b2b2b2> c<#d0d0d0> c<#eeeeee> c<#eeeeee> c<#eeeeee> c<#d0d0d0> c<#b2b2b2> c<#949494> c<#767676> c<#585858>
+layout/d effect=start

+layout

@@ th ansi(x<#d4c0fa>, Test, x<#894ff7>, Testing, x<#732bfc>, Test, x<#999999>, Testing)

@@ +gradient #585858/#eeeeee=123456
