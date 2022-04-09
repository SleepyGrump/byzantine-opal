/* This is a work in progress! This doesn't really DO anything yet. */

@@ %0: left border text
@@ %1: right border text
@@ %2: inner left border text
@@ %3: inner right border text
@@ %4: text
@@ %5: fill text
@@ %6: player
&layout.left-align [v(d.bf)]=strcat(setq(0, strcat(%b, %0, %2, %b, %4, %b, %3, @@REPEATHERE@@, %1)), edit(%q0, @@REPEATHERE@@, repeat(%5, sub(ulocal(f.get-width, %6), sub(strlen(%q0), 14)))))

&layout.right-align [v(d.bf)]=strcat(setq(0, strcat(%b, %0, @@REPEATHERE@@, %2, %b, %4, %b, %3, %1)), edit(%q0, @@REPEATHERE@@, repeat(%5, sub(ulocal(f.get-width, %6), sub(strlen(%q0), 14)))))

&layout.center-align [v(d.bf)]=strcat(setq(0, strcat(%b, %0, @@REPEATHERE1@@, %2, %b, %4, %b, %3, @@REPEATHERE2@@, %1)), edit(%q0, @@REPEATHERE1@@, repeat(%5, strcat(setq(1, sub(ulocal(f.get-width, %6), sub(strlen(%q0), 30))), div(%q1, 2))), @@REPEATHERE2@@, repeat(%5, add(div(%q1, 2), mod(%q1, 2)))))

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

&layout.table-text [v(d.bf)]=strcat(setq(W, ulocal(f.get-working-box-width, %0, space(36), %2, %3)), iter(%1, ulocal(layout.box-line, %0, strcat(setq(C, if(eq(inum(0), 1), first(ulocal(f.get-working-layout, %3, colors))u)), ansi(%qC, ljust(first(itext(0), ~), 35)), %b, ansi(%qC, ljust(rest(itext(0), ~), %qW))), %2, ulocal(f.get-working-box-width, %0, itext(0), %2, %3)), |, %r))

&f.get-working-box-width [v(d.bf)]=sub(ulocal(f.get-width, %3), strlen(strcat(%b, %0, %b, %1, %b, %2)))

&f.get-working-remaining-width [v(d.bf)]=sub(ulocal(f.get-width, %3), strlen(strcat(%b, %0, %b, %b, %2)))

@@ %0: the header/footer/whatever to apply the effect to
@@ %1: the text the user wanted to display
@@ %2: the text color
&layout.apply-color [v(d.bf)]=edit(%0, %1, ansi(%2, %1))

&f.get-working-layout [v(d.bf)]=default(%0/d.%1, default(d.%1, switch(%1, *alignment, left, -)))

th ulocal(v(d.bf)/f.get-working-layout, %#, header.alignment)

@@ %0: player
@@ %1: header, footer, or divider
@@ %2: text to test with
&layout.working-liner [v(d.bf)]=ulocal(strcat(layout., ulocal(f.get-working-layout, %0, %1.alignment), -align), ulocal(f.get-working-layout, %0, %1.left), ulocal(f.get-working-layout, %0, %1.right), ulocal(f.get-working-layout, %0, %1.inner-left), ulocal(f.get-working-layout, %0, %1.inner-right), %2, ulocal(f.get-working-layout, %0, %1.fill), %0)

@@ %0: player
@@ %1: text
@@ %2: box or table
&layout.working-body [v(d.bf)]=ulocal(layout.%2-text, ulocal(f.get-working-layout, %0, body.left), %1, ulocal(f.get-working-layout, %0, body.right), %0)

@@ Issue: Can't use multicol or formattext with this - will have to hardcode it to use the player's working layout.

&layout.working-layout [v(d.bc)]=strcat(ulocal(layout.working-liner, %0, header, Layout and appearance), %r, ulocal(layout.working-body, %0, strcat(%r, indent(), This is the game's  general appearance. You should customize this to look different from other games so that players don't get confused and so that you have your own unique game style., %r%b), box), %r, ulocal(layout.working-liner, %0, divider, Commands), %r, ulocal(layout.working-body, %0, %b, box), %r, ulocal(layout.working-body, %0, strcat(Commands, ~, Description, |, +layout/<section> <field>=<value>, ~, Set various layout values., |, +layout/save, ~, Replace the game's current layout.), table), %r, ulocal(layout.working-body, %0, %b, box), %r, ulocal(layout.working-liner, %0, footer, +layout/save to make this the game's layout!))

+layout

&c.+layout [v(d.bc)]=$+layout:@pemit %#=ulocal(layout.working-layout, %#);

&d.layout-sections [v(d.bd)]=body|header|footer|divider

&d.layout-settings [v(d.bd)]=left|right|fill|inner-left|inner-right|alignment

&c.+layout/set [v(d.bc)]=$+layout/* *=*:@assert isstaff(%#)={ @trigger me/tr.error=#, Only staff can set the game's layout.; }; @assert t(setr(F, finditem(setr(L, v(d.layout-sections)), %0, |)))={ @trigger me/tr.error=%#, Layout section must be either [ulocal(layout.list, %qL, or)]. You provided '%0'.; }; @assert t(setr(S, finditem(setr(L, v(d.layout-settings)), %1, |)))={ @trigger me/tr.error=%#, Layout setting must be either [ulocal(layout.list, %qL, or)]. You provided '%1'.; }; @eval setq(V, %2); @assert cor(not(strmatch(%qS, alignment)), t(setr(V, finditem(left|right|center, %2, |))))={ @trigger me/tr.error=%#, You must specify either left%, right%, or center for alignment.; }; @set %#=d.%qF.%qS:%qV; @trigger me/tr.success=%#, You set your working layout's %qF %qS to: %qV;

@set [v(d.bc)]/c.+layout/set=no_parse

&c.+layout/save [v(d.bc)]=$+layout/save:@assert isstaff(%#)={ @trigger me/tr.error=#, Only staff can set the game's layout.; }; @@(Do some checking for a valid minimum set of layouts.); @trigger me/tr.error=%#, Not implemented yet.;


@@ Try out layouts.

+layout/h l=)xx
+layout/h r=>
+layout/h inner-l=[
+layout/h inner-r=]
+layout/h fill==
+layout/h align=l
+layout/b l=:
+layout/b r=:
+layout/d l=)xx[
+layout/d r=]xx(
+layout/d inner-l=>
+layout/d inner-r=<
+layout/d fill==
+layout/d align=c
+layout/f l=<
+layout/f r=xx(
+layout/f inner-l=[
+layout/f inner-r=]
+layout/f fill==
+layout/f align=r
