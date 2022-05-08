@@ This is an optional package that will allow staffers to set up the game's ansi and layout with simple commands via +layout. Writing this because 1) I like pretty games, and 2) the other package wasn't usable enough. Eventually this will probably replace the default code settings.

@@ Why doesn't this code do gradients by itself? Because calculating gradients is processor-intensive and we can't do that for every single call of header() or footer(). Instead, you're expected to pre-calculate the colors using the +gradient code, and then assign the colors to the various sections.

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Functions
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

&f.get-ansi [v(d.bf)]=extract(%0, if(lte(%1, words(%0)), %1, inc(mod(%1, words(%0)))), 1)

&f.get-working-layout [v(d.bf)]=udefault(%0/d.%1, switch(%1, *alignment, left, alert*,, %b))

&f.get-layout [v(d.bf)]=udefault(%vD/d.%0, switch(%0, *alignment, left, alert*,, %b))

&f.globalpp.header [v(d.bf)]=ulocal(layout.liner, %1, header, %0)

&f.globalpp.footer [v(d.bf)]=ulocal(layout.liner, %1, footer, %0)

&f.globalpp.divider [v(d.bf)]=ulocal(layout.liner, %1, divider, %0)

&f.globalpp.alert [v(d.bf)]=ulocal(layout.alert, %0)

&f.globalpp.formatcolumns [v(d.bf)]=ulocal(layout.columns, %0, %1, %2)

&f.globalpp.formattable [v(d.bf)]=ulocal(layout.table, %0, %1, %2, %3, %4)

&f.globalpp.formatdb [v(d.bf)]=ulocal(layout.formatdb, %0, %1, %2, %3, %4)

&f.globalpp.formattext [v(d.bf)]=ulocal(layout.box, %0, %1, %2)

&f.globalpp.multicol [v(d.bf)]=ulocal(layout.multicol, %0, %1, %2, %3, %4, %5)

&f.globalpp.themecolors [v(d.bf)]=unionset(v(d.title.colors), setunion(v(d.header.colors), setunion(v(d.footer.colors), setunion(v(d.divider.colors), v(d.body.colors)))))

@@ %0: Text to arrange.
@@ %1: Columns to arrange it in.
@@ %2: Delimiter.
@@ %3: alignments
@@ %4: highlight first row
@@ %5: source for colors
&f.wrap-text [v(d.bf)]=iter(lnum(add(div(words(%0, %2), words(%1)), if(gt(mod(words(%0, %2), words(%1)), 0), 1, 0))), ulocal(f.get-rows-from-column, extract(%0, inc(mul(itext(0), words(%1))), words(%1), %2), %1, %2, %3, %4, eq(inum(0), 1), %5),, %2)

@@ %0: Text to columnate.
@@ %1: Column widths to generate
@@ %2: Delimiter
@@ %3: Alignments
@@ %4: highlight first row
@@ %5: is first row
@@ %6: source for colors
&f.get-rows-from-column [v(d.bf)]=iter(lnum(lmax(iter(%1, words(wrap(if(t(setr(A, extract(%0, inum(0), 1, %2))), %qA, %b), itext(0), l), %r)))), iter(%1, ansi(if(cand(t(strlen(setr(0, extract(wrap(extract(%0, inum(0), 1, %2), itext(0), extract(%3, inum(0), 1)), inum(1), 1, %r)))), t(%4), %5), xget(if(t(%6), %6, %vD), d.title.colors) u), if(t(strlen(%q0)), %q0, space(itext(0)))),, %2),, %2)

@@ %0: width of space available
@@ %1: which width to grab
@@ %2: all widths so we can calculate remaining space if * is passed
&f.get-column-width [v(d.bf)]=strcat(setq(W, extract(%2, %1, 1)), if(member(*, %qW), strcat(setq(0,), null(iter(setr(L, trim(squish(edit(%2, *,)))), strcat(setq(C, extract(%qL, inum(0), 1)), setq(P, strmatch(%qC, *p*)), setq(C, strip(%qC, p)), setq(0, add(%q0, ulocal(f.calc-column-width, %qP, %0, %qC, %qL)))))), setq(1, ulocal(f.calc-star-column-width, %0, %q0, %2)), setq(E, mod(sub(%0, %q0), dec(words(%2, *)))), add(%q1, if(eq(%1, member(reverse(%2), *)), %qE))), strcat(setq(I, strmatch(%qW, *p)), setq(W, edit(%qW, p,)), ulocal(f.calc-column-width, %qI, %0, %qW, %2))))

&f.calc-column-width [v(d.bf)]=if(t(%0), floor(mul(%1, fdiv(%2, 100))), %2)

&f.calc-star-column-width [v(d.bf)]=max(0, strcat(setq(S, dec(words(%2, *))), setq(R, sub(%0, add(%1, sub(words(%2), %qS)))), sub(floor(fdiv(%qR, %qS)), if(gt(%qS, 1), 1, 0))))

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Layouts
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

@@ %0: the player
@@ %1: header, footer, or divider
@@ %2: text
&layout.apply-working-effect [v(d.bf)]=ulocal(strcat(effect., default(%0/d.%1.effect, default(%0/d.%1effect, none))), %2, ulocal(f.get-working-layout, %0, switch(%1, *text-*, %1colors, %1.colors)))

&layout.apply-effect [v(d.bf)]=ulocal(strcat(effect., default(d.%1.effect, default(d.%1effect, none))), %2, ulocal(f.get-layout, switch(%1, *text-*, %1colors, %1.colors)))

@@ %0: left border text
@@ %1: right border text
@@ %2: inner left border text
@@ %3: inner right border text
@@ %4: text
@@ %5: fill text
@@ %6: player
@@ %7: header, footer, divider
&layout.repeat-working [v(d.bf)]=ulocal(layout.apply-working-effect, %6, %7, mid(repeat(%5, setr(W, ulocal(f.get-width, %6))), 0, sub(%qW, %8)))

&layout.repeat [v(d.bf)]=ulocal(layout.apply-effect, %6, %7, mid(repeat(%5, setr(W, ulocal(f.get-width, %6))), 0, sub(%qW, %8)))

&layout.repeat-half-working [v(d.bf)]=ulocal(layout.apply-working-effect, %6, %7, mid(repeat(%5, setr(W, ulocal(f.get-width, %6))), 0, add(div(setr(0, sub(%qW, %8)), 2), if(%9, mod(%q0, 2)))))

&layout.repeat-half [v(d.bf)]=ulocal(layout.apply-effect, %6, %7, repeat(%5, setr(2, div(div(setr(0, sub(ulocal(f.get-width, %6), %8)), setr(1, strlen(%5))), 2))), mid(repeat(%5, 10), 0, add(mod(%q0, %q1), if(t(%9), mod(%q2, 2)))))

&layout.left-working-align [v(d.bf)]=strcat(setr(0, strcat(%b, %0, %2, if(t(%4), %b), %4, if(t(%4), %b), %3)), ulocal(layout.repeat-working, %0, %1, %2, %3, %4, %5, %6, %7, strlen(%q0%1)), %1)

&layout.left-align [v(d.bf)]=strcat(setr(0, strcat(%b, %0, %2, if(t(%4), %b), %4, if(t(%4), %b), %3)), ulocal(layout.repeat, %0, %1, %2, %3, %4, %5, %6, %7, strlen(%q0%1)), %1)

&layout.right-working-align [v(d.bf)]=strcat(setr(0, strcat(%b, %0)), setq(1, strcat(%2, if(t(%4), %b), %4, if(t(%4), %b), %3, %1)), ulocal(layout.repeat-working, %0, %1, %2, %3, %4, %5, %6, %7, strlen(%q0%q1)), %q1)

&layout.right-align [v(d.bf)]=strcat(setr(0, strcat(%b, %0)), setq(1, strcat(%2, if(t(%4), %b), %4, if(t(%4), %b), %3, %1)), ulocal(layout.repeat, %0, %1, %2, %3, %4, %5, %6, %7, strlen(%q0%q1)), %q1)

&layout.center-working-align [v(d.bf)]=strcat(setr(0, strcat(%b, %0)), setq(1, strcat(%2, if(t(%4), %b), %4, if(t(%4), %b), %3)), setr(2, ulocal(layout.repeat-half-working, %0, %1, %2, %3, %4, %5, %6, %7, strlen(%q0%q1%1))), %q1, ulocal(layout.repeat-working, %0, %1, %2, %3, %4, %5, %6, %7, strlen(%q0%q1%q2%1)), %1)

&layout.center-align [v(d.bf)]=strcat(setr(0, strcat(%b, %0)), setq(1, strcat(%2, if(t(%4), %b), %4, if(t(%4), %b), %3)), setr(2, ulocal(layout.repeat-half, %0, %1, %2, %3, %4, %5, %6, %7, strlen(%q0%q1%1))), %q1, ulocal(layout.repeat, %0, %1, %2, %3, %4, %5, %6, %7, strlen(%q0%q1%1%q2), 1), %1)

@@ %0: text to format
@@ %1: indent (default no)
@@ %2: player to format for or numeric width (optional)
@@ Registers:
@@ %q0: player width
@@ %q1: left text
@@ %q2: right text
@@ %q3: remaining width
@@ %q4: how many lines
@@ %q5: lines
@@ %q6: Left text layout
@@ %q7: Right text layout
@@ %q8: Does the text end with an extra %r?
&layout.working-box [v(d.bf)]=strcat(setq(T, edit(%0, |, %r, %t, indent())), setq(8, strmatch(%qT, *%r)), if(t(%1), setq(T, strcat(%r, indent(), trim(trim(%qT, b, %r)), %r%b))), if(%q8, setq(T, strcat(%qT, %r))), setq(0, ulocal(f.get-width, %2)), setq(1, ulocal(f.get-working-layout, %2, body.left)), setq(2, ulocal(f.get-working-layout, %2, body.right)), setq(3, sub(%q0, add(strlen(%q1), strlen(%q2), 3))), setq(4, words(wrap(%qT, %q3, l, edit(%b%q1%b, |, %b), edit(%b%q2, |, %b),, |), |)), setq(5, wrap(%qT, %q3, l,,,, |)), setq(6, ulocal(layout.apply-working-effect, %2, body, iter(lnum(%q4), %q1,, @@))), setq(7, ulocal(layout.apply-working-effect, %2, body, iter(lnum(%q4), %q2,, @@))), iter(lnum(%q4), strcat(%b, mid(%q6, mul(itext(0), strlen(%q1)), strlen(%q1)), %b, extract(%q5, inum(0), 1, |), %b, mid(%q7, mul(itext(0), strlen(%q2)), strlen(%q2))),, %r))

&layout.box [v(d.bf)]=strcat(setq(T, edit(%0, |, %r, %t, indent())), setq(8, strmatch(%qT, *%r)), if(t(%1), setq(T, strcat(%r, indent(), trim(trim(%qT, b, %r)), %r%b))), if(%q8, setq(T, strcat(%qT, %r))), setq(0, ulocal(f.get-width, %2)), setq(1, ulocal(f.get-layout, body.left)), setq(2, ulocal(f.get-layout, body.right)), setq(3, sub(%q0, add(strlen(%q1), strlen(%q2), 3))), setq(4, words(wrap(%qT, %q3, l, edit(%b%q1%b, |, %b), edit(%b%q2, |, %b),, |), |)), setq(5, wrap(%qT, %q3, l,,,, |)), setq(6, ulocal(layout.apply-effect, %2, body, iter(lnum(%q4), %q1,, @@))), setq(7, ulocal(layout.apply-effect, %2, body, iter(lnum(%q4), %q2,, @@))), iter(lnum(%q4), strcat(%b, mid(%q6, mul(itext(0), strlen(%q1)), strlen(%q1)), %b, extract(%q5, inum(0), 1, |), %b, mid(%q7, mul(itext(0), strlen(%q2)), strlen(%q2))),, %r))

@@ %0: data to work with
@@ %1: a list of column widths
@@   Number: interpreted as the number of characters.
@@   Number followed by a "p": interpreted as percentage.
@@   Asterisk: interpreted as "all remaining space".
@@   Example: 50p 16 *
@@     Would be interpreted as:
@@     The first column takes up 50% of the available width.
@@     The second column takes up 16 characters.
@@     The third column takes up all the remaining width.
@@ %2: first row is a header row (optional, default no)
@@ %3: data delimiter (optional, default space)
@@ %4: player to format for or numeric width (optional)
@@ %5: if 1, skip the container
@@ Registers:
@@ %q0: player width
@@ %q1: left text
@@ %q2: right text
@@ %q3: remaining width
@@ %q5: number of columns
@@ %q6: number of rows
@@ %q7: Left text layout
@@ %q8: Right text layout
@@ %q9: temp var for line output
@@ %qT: wrapped text
@@ %qW: Column widths, calculated
@@ %qD: Delimiter
@@ Output: A table formatted according to the given column widths. Contents that extend past the given width will be wrapped to the next line, pushing the whole thing down a row.
&layout.working-multicol [v(d.bf)]=strcat(setq(T, %0), setq(D, if(t(%3), %3, strcat(|, setq(T, edit(%qT, %b, |))))), setq(0, ulocal(f.get-width, %4)), setq(1, if(not(t(%5)), ulocal(f.get-working-layout, %4, body.left))), setq(2, if(not(t(%5)), ulocal(f.get-working-layout, %4, body.right))), setq(3, sub(%q0, add(strlen(%q1), strlen(%q2), 3))), setq(W,), null(iter(%1, setq(W, cat(%qW, ulocal(f.get-column-width, %q3, inum(0), strip(%1, strip(%1, 0123456789 *p))))))), setq(W, trim(%qW)), setq(5, words(%1)), setq(T, ulocal(f.wrap-text, %qT, %qW, %qD, iter(edit(strip(%1, strip(%1, r c)), %b, |), if(t(itext(0)), itext(0), l), |, %b), %2, %4)), setq(6, ceil(fdiv(words(%qT, %qD), %q5))), setq(7, ulocal(layout.apply-working-effect, %4, body, iter(lnum(%q6), %q1,, @@))), setq(8, ulocal(layout.apply-working-effect, %4, body, iter(lnum(%q6), %q2,, @@))), iter(lnum(%q6), strcat(%b, mid(%q7, mul(itext(0), strlen(%q1)), strlen(%q1)), %b, setq(9, iter(lnum(%q5), extract(%qT, add(mul(itext(1), %q5), inum(0)), 1, %qD),, %b)), %q9, space(sub(%q3, strlen(%q9))), %b, mid(%q8, mul(itext(0), strlen(%q2)), strlen(%q2))),, %r))

&layout.multicol [v(d.bf)]=strcat(setq(T, %0), setq(D, if(t(%3), %3, strcat(|, setq(T, edit(%qT, %b, |))))), setq(0, ulocal(f.get-width, %4)), setq(1, if(not(t(%5)), ulocal(f.get-layout, body.left))), setq(2, if(not(t(%5)), ulocal(f.get-layout, body.right))), setq(3, sub(%q0, add(strlen(%q1), strlen(%q2), 3))), setq(W,), null(iter(%1, setq(W, cat(%qW, ulocal(f.get-column-width, %q3, inum(0), strip(%1, strip(%1, 0123456789 *p))))))), setq(W, trim(%qW)), setq(5, words(%1)), setq(T, ulocal(f.wrap-text, %qT, %qW, %qD, iter(edit(strip(%1, strip(%1, r c)), %b, |), if(t(itext(0)), itext(0), l), |, %b), %2)), setq(6, ceil(fdiv(words(%qT, %qD), %q5))), setq(7, ulocal(layout.apply-effect, %4, body, iter(lnum(%q6), %q1,, @@))), setq(8, ulocal(layout.apply-effect, %4, body, iter(lnum(%q6), %q2,, @@))), iter(lnum(%q6), strcat(%b, mid(%q7, mul(itext(0), strlen(%q1)), strlen(%q1)), %b, setq(9, iter(lnum(%q5), extract(%qT, add(mul(itext(1), %q5), inum(0)), 1, %qD),, %b)), %q9, space(sub(%q3, strlen(%q9))), %b, mid(%q8, mul(itext(0), strlen(%q2)), strlen(%q2))),, %r))

@@ %0: data to format
@@ %1: input delimiter (optional, space is default)
@@ %2: player to format for or numeric width (optional)
@@ Registers:
@@ %q0: player width
@@ %q1: left text
@@ %q2: right text
@@ %q3: remaining width
@@ %q4: widest column
@@ %q5: number of columns
@@ %q6: number of rows
@@ %q7: Left text layout
@@ %q8: Right text layout
@@ %q9: temp var for line output
@@ %qE: extra space
@@ Output: As many columns wedged onto the page as will fit.
&layout.columns [v(d.bf)]=strcat(setq(0, ulocal(f.get-width, %2)), setq(1, ulocal(f.get-layout, body.left)), setq(2, ulocal(f.get-layout, body.right)), setq(3, sub(%q0, add(strlen(%q1), strlen(%q2), 3))), setq(4, ulocal(f.get-widest, %0, %1)), setq(5, if(gt(inc(mul(%q4, 2)), %q3), strcat(1, setq(4, %q3)), div(%q3, inc(%q4)))), if(lt(words(%0, %1), %q5), setq(5, words(%0, %1))), setq(6, ceil(fdiv(words(%0, %1), %q5))), setq(7, ulocal(layout.apply-effect, %2, body, iter(lnum(%q6), %q1,, @@))), setq(8, ulocal(layout.apply-effect, %2, body, iter(lnum(%q6), %q2,, @@))), setq(E, sub(%q3, add(mul(%q4, %q5), %q5))), setq(4, add(%q4, div(%qE, %q5))), iter(lnum(%q6), strcat(%b, mid(%q7, mul(itext(0), strlen(%q1)), strlen(%q1)), %b, setq(9, mid(iter(lnum(%q5), ljust(mid(extract(%0, add(mul(itext(1), %q5), inum(0)), 1, %1), 0, %q4), %q4)), 0, %q3)), %q9, space(sub(%q3, strlen(%q9))), %b, mid(%q8, mul(itext(0), strlen(%q2)), strlen(%q2))),, %r))

@@ %0: data to format
@@ %1: number of columns
@@ %2: first row is a header row (optional, default no)
@@ %3: input delimiter (optional, space is default)
@@ %4: player to format for or numeric width (optional)
@@ Registers:
@@ %q0: player width
@@ %q1: left text
@@ %q2: right text
@@ %q3: remaining width
@@ %q4: widest column
@@ %q6: number of rows
@@ %q7: Left text layout
@@ %q8: Right text layout
@@ %q9: temp var for line output
@@ %qE: extra space
@@ Output: A table fit into one screen as best as possible.

&layout.table [v(d.bf)]=strcat(setq(0, ulocal(f.get-width, %4)), setq(1, ulocal(f.get-layout, body.left)), setq(2, ulocal(f.get-layout, body.right)), setq(3, sub(%q0, add(strlen(%q1), strlen(%q2), 3))), setq(4, div(%q3, inc(%1))), setq(6, ceil(fdiv(words(%0, %3), %1))), setq(7, ulocal(layout.apply-effect, %2, body, iter(lnum(%q6), %q1,, @@))), setq(8, ulocal(layout.apply-effect, %2, body, iter(lnum(%q6), %q2,, @@))), setq(E, sub(%q3, add(mul(%q4, %1), %1))), setq(4, add(%q4, div(%qE, %1))), iter(lnum(%q6), strcat(%b, mid(%q7, mul(itext(0), strlen(%q1)), strlen(%q1)), %b, setq(9, mid(iter(lnum(%1), ansi(if(cand(t(%2), eq(itext(1), 0)), strcat(v(d.title.colors), %b, u)), ljust(mid(extract(%0, add(mul(itext(1), %1), inum(0)), 1, %3), 0, %q4), %q4)),, %b), 0, %q3)), %q9, space(sub(%q3, strlen(%q9))), %b, mid(%q8, mul(itext(0), strlen(%q2)), strlen(%q2))),, %r))

@@ %0: db data to format
@@ %1: first row is a header row (optional, default no)
@@ %2: row delimiter (optional)
@@ %3: column delimiter (optional)
@@ %4: player to format for or numeric width (optional)
@@ Registers:
@@ %q0: player width
@@ %q1: left text
@@ %q2: right text
@@ %q3: remaining width
@@ %q4: widest column
@@ %q5: number of columns
@@ %q6: number of rows
@@ %q7: Left text layout
@@ %q8: Right text layout
@@ %q9: temp var for line output
@@ %qE: extra space
@@ %qT: text to translate
@@ %qR: row delimiter
@@ %qC: column delimiter
@@ Input: data as formatted by fetch()
@@ Output: a table with rows and columns determined from the given data.

&layout.formatdb [v(d.bf)]=strcat(setq(R, if(t(%2), %2, v(d.default-row-delimiter))), setq(C, if(t(%3), %3, v(d.default-column-delimiter))), setq(5, words(first(%0, %qR), %qC)), setq(T, edit(%0, %qC, %qR)), setq(0, ulocal(f.get-width, %4)), setq(1, ulocal(f.get-layout, body.left)), setq(2, ulocal(f.get-layout, body.right)), setq(3, sub(%q0, add(strlen(%q1), strlen(%q2), 4))), setq(4, div(%q3, inc(%q5))), setq(6, ceil(fdiv(words(%qT, %qR), %q5))), setq(7, ulocal(layout.apply-effect, %4, body, iter(lnum(%q6), %q1,, @@))), setq(8, ulocal(layout.apply-effect, %4, body, iter(lnum(%q6), %q2,, @@))), setq(E, sub(%q3, add(mul(%q4, %q5), %q5))), setq(4, add(%q4, div(%qE, %q5))), iter(lnum(%q6), strcat(%b, mid(%q7, mul(itext(0), strlen(%q1)), strlen(%q1)), %b, setq(9, mid(iter(lnum(%q5), ansi(if(cand(t(%1), eq(itext(1), 0)), strcat(v(d.title.colors), %b, u)), ljust(mid(extract(%qT, add(mul(itext(1), %q5), inum(0)), 1, %qR), 0, %q4), %q4)),, %b), 0, %q3)), %q9, space(sub(%q3, strlen(%q9))), %b, mid(%q8, mul(itext(0), strlen(%q2)), strlen(%q2))),, %r))

@@ %0: player
@@ %1: header, footer, or divider
@@ %2: text to display
&layout.working-liner [v(d.bf)]=ulocal(strcat(layout., ulocal(f.get-working-layout, %0, %1.alignment), -working-align), ulocal(f.get-working-layout, %0, %1.left), ulocal(f.get-working-layout, %0, %1.right), ulocal(f.get-working-layout, %0, %1.inner-left), ulocal(f.get-working-layout, %0, %1.inner-right), ulocal(layout.apply-working-effect, %0, %1.text-, %2), ulocal(f.get-working-layout, %0, %1.fill), %0, %1)

&layout.liner [v(d.bf)]=ulocal(strcat(layout., ulocal(f.get-layout, %1.alignment), -align), ulocal(f.get-layout, %1.left), ulocal(f.get-layout, %1.right), ulocal(f.get-layout, %1.inner-left), ulocal(f.get-layout, %1.inner-right), ulocal(layout.apply-effect, %0, %1.text-, %2), ulocal(f.get-layout, %1.fill), %0, %1)

&layout.working-alert [v(d.bf)]=strcat(ulocal(f.get-working-layout, %0, alert.left), ulocal(f.get-working-layout, %0, alert.inner-left), %b, ulocal(layout.apply-working-effect, %0, alert.text-, v(d.default-alert)), %b, ulocal(f.get-working-layout, %0, alert.inner-right), ulocal(f.get-working-layout, %0, alert.right))

&layout.alert [v(d.bf)]=strcat(ulocal(f.get-layout, alert.left), ulocal(f.get-layout, alert.inner-left), %b, if(t(%0), %0, ulocal(layout.apply-effect, %0, alert.text-, v(d.default-alert))), %b, ulocal(f.get-layout, alert.inner-right), ulocal(f.get-layout, alert.right))

&layout.working-layout [v(d.bf)]=strcat(ulocal(layout.working-liner, %0, header, Working layout and appearance), %r, ulocal(layout.working-box, strcat(This is your current working example for the game's general appearance. You should customize this to look different from other games so that players don't get confused and so that you have your own unique game style., %r%r%t, This display is a sample. As such%, it may not look quite as good as the real thing. You may need to try a few different variants to get the real thing to look the way you want it to.), 1, %0), %r, ulocal(layout.working-liner, %0, divider, Layout commands), %r, ulocal(layout.working-box, %b, 0, %0), %r, ulocal(layout.working-multicol, strcat(Commands, |, Description, |, +layout/<section> <field>=<value>, |, Set various layout values., |, space(3), Sections are:, |, ulocal(layout.list, v(d.layout-sections)), |, space(3), Settings are:, |, ulocal(layout.list, v(d.layout-settings)), |, space(3), Alignments are:, |, left%, right%, and center, |, space(3), Effects are:, |, ulocal(layout.list, v(d.layout-effects)), |, +layout/save, |, Replace the game's current layout., |, +layout/current, |, View the game's current layout., |, +layout/clear, |, Clear your current working layout. Will ask if you're sure.), * *, 1, |, %0), %r, ulocal(layout.working-box, %b, 0, %0), %r, ulocal(layout.working-liner, %0, footer, +layout/save to make this the game's layout!), %r, ulocal(layout.working-alert, %0) This is what the alert looks like.)

&layout.current [v(d.bf)]=strcat(header(Current layout and appearance, %0), %r, formattext(This is the game's current appearance using all of our standard commands and functions. It should look different from other games so that players don't get confused when flipping between windows. Each game has its own unique style. This is yours., 1, %0), %r, divider(Layout commands, %0), %r, formattext(%b, 0, %0), %r, multicol(strcat(Commands, |, Description, |, +layout/<section> <field>=<value>, |, Set various layout values., |, space(3), Sections are:, |, ulocal(layout.list, v(d.layout-sections)), |, space(3), Settings are:, |, ulocal(layout.list, v(d.layout-settings)), |, space(3), Alignments are:, |, left%, right%, and center, |, space(3), Effects are:, |, ulocal(layout.list, v(d.layout-effects)), |, +layout/save, |, Replace the game's current layout., |, +layout/current, |, View the game's current layout., |, +layout/clear, |, Clear your current working layout. Will ask if you're sure.), * *, 1, |, %0), %r, formattext(%b, 0, %0), %r, footer(+layout to view your working layout, %0), %r, alert() This is what the alert looks like.)

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Effects
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

@@ Effects:
@@ 	Repeat: ABCABCABC
@@ 	Stretch: AAABBBCCC
@@ 	Start: ABCCCCCCC
@@ 	End: AAAAAAABC
@@ 	Random: CABBCAACB
@@  None: no colors

&effect.none [v(d.bf)]=ansi(%1, %0)

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

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Commands
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

&c.+layout [v(d.bc)]=$+layout:@pemit %#=ulocal(layout.working-layout, %#);

&c.+layout/current [v(d.bc)]=$+layout/cu*:@break strmatch(%0, *=*); @pemit %#=ulocal(layout.current, %#);

&c.+layout/clear [v(d.bc)]=$+layout/cl*:@break strmatch(%0, *=*); @assert gettimer(%#, clear-layout)={ @trigger me/tr.message=%#, You are about to clear your current working layout. This will start you over from scratch. Are you sure? If yes%, type %ch+layout/clear%cn again within the next 10 minutes. The time is now [prettytime()].; @eval settimer(%#, clear-layout, 600); }; @dolist iter(v(d.layout-sections), iter(v(d.layout-settings), strcat(d., itext(1), ., itext(0)), |,), |,)={ @wipe %#/##; }; @trigger me/tr.success=%#, Your working layout has been cleared.;

&d.layout-sections [v(d.bd)]=body|header|footer|divider|title|alert

&d.layout-effects [v(d.bd)]=repeat|random|start|end|stretch|none

&d.layout-settings [v(d.bd)]=left|right|fill|inner-left|inner-right|alignment|colors|effect|text-colors|text-effect

&c.+layout/set [v(d.bc)]=$+layout/* *=*:@assert isstaff(%#)={ @trigger me/tr.error=#, Only staff can set the game's layout.; }; @assert t(setr(F, finditem(setr(L, v(d.layout-sections)), %0, |)))={ @trigger me/tr.error=%#, Layout section must be either [ulocal(layout.list, %qL, or)]. You provided '%0'.; }; @assert t(setr(S, finditem(setr(L, v(d.layout-settings)), %1, |)))={ @trigger me/tr.error=%#, Layout setting must be either [ulocal(layout.list, %qL, or)]. You provided '%1'.; }; @eval setq(V, %2); @assert cor(not(strmatch(%qS, alignment)), t(setr(V, finditem(left|right|center, %2, |))))={ @trigger me/tr.error=%#, You must specify either left%, right%, or center for alignment.; }; @assert cor(switch(%qS, effect, 0, text-effect, 0, 1), cor(t(setr(V, finditem(setr(L, v(d.layout-effects)), %qV, |))), not(t(strlen(%qV)))))={ @trigger me/tr.error=%#, Valid values for 'effect' are [ulocal(layout.list, %qL)].; }; @assert cor(not(cand(strmatch(%qF, title), strmatch(%qS, colors))), eq(words(%qV), 1))={ @trigger me/tr.error=%#, Title only supports one color right now.; }; &d.%qF.%qS %#=%qV; @trigger me/tr.success=%#, You set your working layout's %qF %qS to: %qV;

@set [v(d.bc)]/c.+layout/set=no_parse

&c.+layout/save [v(d.bc)]=$+layout/save:@assert isstaff(%#)={ @trigger me/tr.error=%#, Only staff can change the game's layout.; }; @assert gettimer(%#, save-layout)={ @trigger me/tr.message=%#, You are about to save your current working layout as the game's layout. This will override whatever you already have there%, which you can see with %ch+layout/current%cn. Are you sure? If yes%, type %ch+layout/save%cn again within the next 10 minutes. The time is now [prettytime()].; @eval settimer(%#, save-layout, 600); }; @dolist iter(v(d.layout-sections), iter(v(d.layout-settings), strcat(d., itext(1), ., itext(0)), |,), |,)={ @cpattr %#/##=%vD; }; @trigger me/tr.success=%#, Your game's layout has been updated.;
