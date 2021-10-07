@@ These functions are rewrites of the SGP Globals functions.

&f.globalpp.isstaff [v(d.bf)]=or(member(v(d.staff_list), ulocal(f.find-player, %0, %#)), orflags(%0, WZw))

@@ On with the custom stuff below!

&f.globalpp.isapproved [v(d.bf)]=hasflag(%0, APPROVED)

&f.get-ansi [v(d.bf)]=extract(%0, if(lte(%1, words(%0)), %1, inc(mod(%1, words(%0)))), 1)

@@ All effects take the following parameter:
@@  %0 - text
@@  %1 - effect width, default 1

&effect.none [v(d.bf)]=%0

&effect.alt [v(d.bf)]=strcat(setq(0, v(d.colors)), setq(1, if(t(%1), %1, 1)), iter(lnum(ceil(fdiv(strlen(%0), %q1))), ansi(ulocal(f.get-ansi, %q0, inum(0)), mid(%0, mul(itext(0), %q1), %q1)),, @@))

&effect.altrev [v(d.bf)]=strcat(setq(0, v(d.colors)), setq(0, strcat(%q0, %b, revwords(%q0))), setq(1, if(t(%1), %1, 1)), iter(lnum(ceil(fdiv(strlen(%0), %q1))), ansi(ulocal(f.get-ansi, %q0, inum(0)), mid(%0, mul(itext(0), %q1), %q1)),, @@))

&effect.random [v(d.bf)]=strcat(setq(0, v(d.colors)), setq(1, if(t(%1), %1, 1)), iter(lnum(ceil(fdiv(strlen(%0), %q1))), ansi(pickrand(%q0), mid(%0, mul(itext(0), %q1), %q1)),, @@))

&effect.fade [v(d.bf)]=strcat(setq(0, v(d.colors)), setq(1, if(t(%1), %1, 1)), setq(2, mul(words(%q0), %q1)), setq(3, sub(strlen(%0), mul(%q2, 2))), if(lt(strlen(%0), %q2), strcat(setq(2, strlen(%0)), setq(3, 0), setq(4, 0)), setq(4, if(lt(%q3, 0), strcat(setq(2, add(%q2, div(%q3, 2))), add(%q2, sub(0, mod(%q3, 2))), setq(3, 0)), %q2))), if(lt(strlen(%0), mul(words(%q0), %q1)), setq(4, 0)), ulocal(effect.alt, mid(%0, 0, %q2), %1), if(gt(%q3, 0), ansi(last(%q0), mid(%0, %q2, %q3))), if(gt(%q4, 0), reverse(ulocal(effect.alt, mid(reverse(%0), 0, %q4), %1))))

@@ TODO: Fade header and footer don't take into account the extra that should theoretically be lopped off due to the title's edges.

@@ Missing the start of the title...

&f.reverse-fade [v(d.bf)]=strcat(setq(0, revwords(extract(v(d.colors), 1, strlen(%0)))), setq(1, if(t(%1), %1, 1)), iter(lnum(ceil(fdiv(strlen(%0), %q1))), ansi(ulocal(f.get-ansi, %q0, inum(0)), mid(%0, mul(itext(0), %q1), %q1)),, @@))

&f.construct-title [v(d.bf)]=if(t(%0), strcat(ulocal(f.apply-effect, v(d.title-left)), %b, ansi(v(d.text-color), %0), %b, if(switch(v(d.effect), fade, 1, altrev, 1, 0), ulocal(f.reverse-fade, v(d.title-right)), ulocal(f.apply-effect, v(d.title-right)))))

@@ %0 - the player to get the width of the screen of OR a specific width
@@ Output: the width of the player's screen, max 200 and min 50, or the numeric width given.
&f.get-width [v(d.bf)]=if(isnum(%0), %0, max(min(width(if(t(%0), %0, %#)), 200), 50))

@@ %0 - width of the left and right edges
@@ %1 - width of the middle
&f.repeating-divider [v(d.bf)]=strcat(repeat(u(d.fade-edge), %0), repeat(u(d.fade-middle), %1), repeat(u(d.fade-edge), %0))

@@ A universal var-setter. One of the few u() functions rather than ulocal().
@@ %0 - title text, optional
@@ %1 - player or numeric width, optional
@@ %q0 - player's screen width
@@ %q1 - title
@@ %q2 - left text
@@ %q3 - right text
@@ %q4 - repeat text
@@ %q5 - remainder text width
&f.get-layout-vars [v(d.bf)]=strcat(setq(0, ulocal(f.get-width, %1)), setq(1, ulocal(f.construct-title, %0)), setq(2, v(d.text-left)), setq(3, v(d.text-right)), setq(4, v(d.text-repeat)), setq(5, sub(%q0, add(strlen(%q1), strlen(%q2), strlen(%q3), 2))))

@@ Pass the layout to the effects machines to produce the appropriate result.
@@ %0 - the string to apply the effect to, usually header, footer, or divider.
@@ %1 - width, optional
&f.apply-effect [v(d.bf)]=ulocal(effect.[v(d.effect)], %0, %1)

&f.globalpp.header [v(d.bf)]=strcat(u(f.get-layout-vars, %0, %1), %b, ulocal(f.apply-effect, %q2), %q1, ulocal(f.apply-effect, strcat(mid(repeat(%q4, %q5), 0, %q5), %q3)), %b)

&f.globalpp.footer [v(d.bf)]=strcat(u(f.get-layout-vars, %0, %1), %b, ulocal(f.apply-effect, strcat(%q2, mid(repeat(%q4, %q5), 0, %q5))), %q1, ulocal(f.apply-effect, %q3), %b)

&f.globalpp.divider [v(d.bf)]=strcat(u(f.get-layout-vars, %0, %1), setq(6, strcat(%q2, mid(repeat(%q4, %q5), 0, %q5), %q3)), %b, ulocal(f.apply-effect, mid(%q6, 0, div(strlen(%q6), 2))), %q1, ulocal(f.apply-effect, mid(%q6, div(strlen(%q6), 2), 999)), %b)

@@ %0 - text (optional)
&f.globalpp.alert [v(d.bf)]=strcat(ulocal(f.apply-effect, v(d.text-left)), ulocal(f.construct-title, if(t(%0), %0, v(d.default-alert))), ulocal(f.apply-effect, v(d.text-right)))

&f.globalpp.themecolors [v(d.bf)]=v(d.colors)

&f.globalpp.indent [v(d.bf)]=space(v(d.indent-width))

@@ %0 - player or width to calculate the remaining width of
@@ Output: The width after all the UI elements are removed. Useful for calculating space available to visually display things.
&f.globalpp.getremainingwidth [v(d.bf)]=strcat(setq(0, ulocal(f.get-width, %0)), setq(1, strlen(v(d.text-left))), setq(2, strlen(v(d.text-right))), sub(%q0, add(%q1, %q2, 6)))

@@ %0: List
@@ %1: Columns
@@ %2: Divider
@@ Output: Turns list "a b c d e f g" into "a e b f c g d" so that you can output it with multicol as a vertical 2-column list instead of a horizontal 2-column list.
&f.globalp.fliplist [v(d.bf)]=trim(strcat(setq(R, add(div(words(%0, %2), %1), t(mod(words(%0, %2), %1)))), iter(lnum(%qR), iter(lnum(%1), extract(%0, add(inum(1), mul(%qR, itext(0))), 1, %2),, %2),, %2)), r, %2)


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
&f.globalpp.formattext [v(d.bf)]=strcat(setq(T, edit(%0, |, %r, %t, indent())), setq(8, strmatch(%qT, *%r)), if(t(%1), setq(T, strcat(%r, indent(), trim(trim(%qT, b, %r)), %r%b))), if(%q8, setq(T, strcat(%qT, %r))), setq(0, ulocal(f.get-width, %2)), setq(1, v(d.body-left)), setq(2, v(d.body-right)), setq(3, sub(%q0, add(strlen(%q1), strlen(%q2), 4))), setq(4, words(wrap(%qT, %q3, l, edit(%b%q1%b, |, %b), edit(%b%q2, |, %b),, |), |)), setq(5, wrap(%qT, %q3, l,,,, |)), setq(6, ulocal(f.apply-effect, iter(lnum(%q4), %q1,, @@), strlen(%q1))), setq(7, ulocal(f.apply-effect, iter(lnum(%q4), %q2,, @@), strlen(%q2))), iter(lnum(%q4), strcat(%b, mid(%q6, mul(itext(0), strlen(%q1)), strlen(%q1)), %b, extract(%q5, inum(0), 1, |), %b, mid(%q7, mul(itext(0), strlen(%q2)), strlen(%q2))),, %r))

@@ %0: the list
@@ %1: delimiter (optional, space is default)
&f.get-widest [v(d.bf)]=strcat(setq(0, 0), null(iter(%0, if(gt(setr(1, strlen(itext(0))), %q0), setq(0, %q1)), if(t(%1), %1, %b))), %q0)

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

&f.globalpp.formatcolumns [v(d.bf)]=strcat(setq(0, ulocal(f.get-width, %2)), setq(1, v(d.body-left)), setq(2, v(d.body-right)), setq(3, sub(%q0, add(strlen(%q1), strlen(%q2), 4))), setq(4, ulocal(f.get-widest, %0, %1)), setq(5, if(gt(inc(mul(%q4, 2)), %q3), strcat(1, setq(4, %q3)), div(%q3, inc(%q4)))), if(lt(words(%0, %1), %q5), setq(5, words(%0, %1))), setq(6, ceil(fdiv(words(%0, %1), %q5))), setq(7, ulocal(f.apply-effect, iter(lnum(%q6), %q1,, @@), strlen(%q1))), setq(8, ulocal(f.apply-effect, iter(lnum(%q6), %q2,, @@), strlen(%q2))), setq(E, sub(%q3, add(mul(%q4, %q5), %q5))), setq(4, add(%q4, div(%qE, %q5))), iter(lnum(%q6), strcat(%b, mid(%q7, mul(itext(0), strlen(%q1)), strlen(%q1)), %b, setq(9, mid(iter(lnum(%q5), ljust(mid(extract(%0, add(mul(itext(1), %q5), inum(0)), 1, %1), 0, %q4), %q4)), 0, %q3)), %q9, space(sub(%q3, strlen(%q9))), %b, mid(%q8, mul(itext(0), strlen(%q2)), strlen(%q2))),, %r))

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

&f.globalpp.formattable [v(d.bf)]=strcat(setq(0, ulocal(f.get-width, %4)), setq(1, v(d.body-left)), setq(2, v(d.body-right)), setq(3, sub(%q0, add(strlen(%q1), strlen(%q2), 4))), setq(4, div(%q3, inc(%1))), setq(6, ceil(fdiv(words(%0, %3), %1))), setq(7, ulocal(f.apply-effect, iter(lnum(%q6), %q1,, @@), strlen(%q1))), setq(8, ulocal(f.apply-effect, iter(lnum(%q6), %q2,, @@), strlen(%q2))), setq(E, sub(%q3, add(mul(%q4, %1), %1))), setq(4, add(%q4, div(%qE, %1))), iter(lnum(%q6), strcat(%b, mid(%q7, mul(itext(0), strlen(%q1)), strlen(%q1)), %b, setq(9, mid(iter(lnum(%1), ansi(if(cand(t(%2), eq(itext(1), 0)), strcat(first(v(d.colors)), %b, u)), ljust(mid(extract(%0, add(mul(itext(1), %1), inum(0)), 1, %3), 0, %q4), %q4)),, %b), 0, %q3)), %q9, space(sub(%q3, strlen(%q9))), %b, mid(%q8, mul(itext(0), strlen(%q2)), strlen(%q2))),, %r))

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

&f.globalpp.formatdb [v(d.bf)]=strcat(setq(R, if(t(%2), %2, v(d.default-row-delimeter))), setq(C, if(t(%3), %3, v(d.default-column-delimeter))), setq(5, words(first(%0, %qR), %qC)), setq(T, edit(%0, %qC, %qR)), setq(0, ulocal(f.get-width, %4)), setq(1, v(d.body-left)), setq(2, v(d.body-right)), setq(3, sub(%q0, add(strlen(%q1), strlen(%q2), 4))), setq(4, div(%q3, inc(%q5))), setq(6, ceil(fdiv(words(%qT, %qR), %q5))), setq(7, ulocal(f.apply-effect, iter(lnum(%q6), %q1,, @@), strlen(%q1))), setq(8, ulocal(f.apply-effect, iter(lnum(%q6), %q2,, @@), strlen(%q2))), setq(E, sub(%q3, add(mul(%q4, %q5), %q5))), setq(4, add(%q4, div(%qE, %q5))), iter(lnum(%q6), strcat(%b, mid(%q7, mul(itext(0), strlen(%q1)), strlen(%q1)), %b, setq(9, mid(iter(lnum(%q5), ansi(if(cand(t(%1), eq(itext(1), 0)), strcat(first(v(d.colors)), %b, u)), ljust(mid(extract(%qT, add(mul(itext(1), %q5), inum(0)), 1, %qR), 0, %q4), %q4)),, %b), 0, %q3)), %q9, space(sub(%q3, strlen(%q9))), %b, mid(%q8, mul(itext(0), strlen(%q2)), strlen(%q2))),, %r))

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
@@ Output: A table formatted according to the given column widths. Contents that extend past the given width will be wrapped to the next line, pushing the whole thing down a row.

&f.globalpp.multicol [v(d.bf)]=strcat(setq(0, ulocal(f.get-width, %4)), setq(1, if(not(t(%5)), v(d.body-left))), setq(2, if(not(t(%5)), v(d.body-right))), setq(3, sub(%q0, add(strlen(%q1), strlen(%q2), 4))), setq(W,), null(iter(%1, setq(W, cat(%qW, ulocal(f.get-column-width, %q3, inum(0), %1))))), setq(W, trim(%qW)), setq(5, words(%1)), setq(T, trim(ulocal(f.wrap-text, %0, %qW, %3), b, %3@@BLANK@@)), setq(6, ceil(fdiv(words(%qT, %3), %q5))), setq(7, ulocal(f.apply-effect, iter(lnum(%q6), %q1,, @@), strlen(%q1))), setq(8, ulocal(f.apply-effect, iter(lnum(%q6), %q2,, @@), strlen(%q2))), iter(lnum(%q6), strcat(%b, mid(%q7, mul(itext(0), strlen(%q1)), strlen(%q1)), %b, setq(9, mid(iter(lnum(%q5), ansi(if(cand(t(%2), eq(itext(1), 0)), strcat(first(v(d.colors)), %b, u)), ljust(mid(edit(extract(%qT, add(mul(itext(1), %q5), inum(0)), 1, %3), @@BLANK@@,), 0, extract(%qW, inum(0), 1)), extract(%qW, inum(0), 1))),, %b), 0, %q3)), %q9, space(sub(%q3, strlen(%q9))), %b, mid(%q8, mul(itext(0), strlen(%q2)), strlen(%q2))),, %r))


@@ %0: Text to arrange.
@@ %1: Columns to arrange it in.
@@ %2: Delimiter.
&f.wrap-text [v(d.bf)]=iter(lnum(add(div(words(%0, %2), words(%1)), if(gt(mod(words(%0, %2), words(%1)), 0), 1, 0))), ulocal(f.get-rows-from-column, extract(%0, inc(mul(itext(0), words(%1))), words(%1), %2), %1, %2),, @@)

@@ %0: Text to columnate.
@@ %1: Column widths to generate
@@ %2: Delimiter
@@ %qM: How many rows this will come out to.
@@ %qR: The result.
&f.get-rows-from-column [v(d.bf)]=strcat(setq(M, 0), null(iter(%1, strcat(setq(A, wrap(extract(%0, inum(0), 1, %2), itext(0), l,,,, if(t(%2), %2, %b))), if(gt(words(%qA, %2), %qM), setq(M, words(%qA, %2)))))), setq(R, repeat(@@BLANK@@%2, mul(%qM, words(%1)))), setq(R, %qR@@BLANK@@), null(iter(%1, strcat(setq(A, wrap(extract(%0, inum(0), 1, %2), itext(0), l,,,, if(t(%2), %2, %b))), iter(%qA, setq(R, replace(if(not(t(%2)), edit(%qR, %b, %2), %qR), add(inum(1), mul(dec(inum(0)), words(%1))), trim(itext(0)), %2, %2)), %2)))), %qR)

&f.get-correct-width [v(d.bf)]=extract(repeat(%0%b, %1), %1, 1)

@@ %0: width of space available
@@ %1: which width to grab
@@ %2: all widths so we can calculate remaining space if * is passed
&f.get-column-width [v(d.bf)]=strcat(setq(W, extract(%2, %1, 1)), if(member(*, %qW), strcat(setq(0,), null(iter(setr(L, trim(squish(edit(%2, *,)))), strcat(setq(C, extract(%qL, inum(0), 1)), setq(P, strmatch(%qC, *p)), setq(C, edit(%qC, p,)), setq(0, add(%q0, ulocal(f.calc-column-width, %qP, %0, %qC, %qL)))))), setq(1, ulocal(f.calc-star-column-width, %0, %q0, %2)), setq(E, mod(sub(%0, %q0), dec(words(%2, *)))), add(%q1, if(eq(%1, member(reverse(%2), *)), %qE))), strcat(setq(I, strmatch(%qW, *p)), setq(W, edit(%qW, p,)), ulocal(f.calc-column-width, %qI, %0, %qW, %2))))

&f.calc-column-width [v(d.bf)]=if(t(%0), floor(mul(%1, fdiv(%2, 100))), %2)

&f.calc-star-column-width [v(d.bf)]=max(0, strcat(setq(S, dec(words(%2, *))), setq(R, sub(%0, add(%1, sub(words(%2), %qS)))), sub(floor(fdiv(%qR, %qS)), if(gt(%qS, 1), 1, 0))))

@@ Aliases for the other commands.

&f.globalpp.subheader [v(d.bf)]=divider(%0, %1)

&f.globalpp.wheader [v(d.bf)]=header(%0, %1)

&f.globalpp.wdivider [v(d.bf)]=divider(%0, %1)

&f.globalpp.wfooter [v(d.bf)]=footer(%0, %1)

&f.globalpp.wfooter [v(d.bf)]=footer(%0, %1)

@@ Output: an entire duration string: 3d 4h 5m 57s
@@ %0 - number of seconds to calculate the duration of
&f.duration-string [v(d.bf)]=extract(exptime(%0), 1, 2)

@@ Output: A duration consisting of the largest 2 items in years, 30-day months, weeks, days, hours, minutes, or seconds, but only gives the largest two values.
@@ %0 - number of seconds.
&f.calculate-duration [v(d.bf)]=if(lte(%0, 0), 0s, extract(ulocal(f.duration-string, %0), 1, 2))

@@ Function: Output a duration in the largest 2 numbers - 2d 3h or 1m 20s.
@@ Arguments:
@@  %0 - Timestamp in seconds.
&f.globalpp.interval [v(d.bf)]=ulocal(f.calculate-duration, sub(secs(), %0))

@@ Function: Output a duration in the largest 2 numbers - 2d 3h or 1m 20s.
@@ Arguments:
@@  %0 - number of seconds
&f.globalpp.secs2hrs [v(d.bf)]=if(lt(%0, 0), -, ulocal(f.calculate-duration, %0))

&f.global.prettytime [v(d.bf)]=if(t(%0), timefmt($m/$d/$Y $r, %0), timefmt($m/$d/$Y $r))


@@ %0 - the word
@@ %1 - the position in the string
@@ Cases:
@@ If the word has had its case modified AT ALL from lower-case, leave it alone.
@@ Otherwise, if it is the first word of the sentence, capitalize it,
@@ Otherwise, if it is a member of the don't-touch group, don't capitalize it.

&f.should-word-be-capitalized [v(d.bf)]=cand(member(lcstr(%0), %0), cor(eq(%1, 1), not(member(v(d.words-to-leave-uncapitalized), ulocal(f.word-without-punctuation, itext(0))))))

&f.word-without-punctuation [v(d.bf)]=strip(%0, v(d.punctuation))

@@ Output: A properly capitalized title-case string
@@ %0 - the string to title-case
&f.globalpp.title [v(d.bf)]=iter(%0, if(ulocal(f.should-word-be-capitalized, itext(0), inum(0)), capstr(itext(0)), itext(0)))

@@ Output: The target's shortdesc
@@ %0: Person, place, or thing
@@ %1: Viewer
&f.globalpp.shortdesc [v(d.bf)]=strcat(setq(0, default(%0/short-desc, ansi(xh, if(member(%0, %1), &short-desc me=<short desc> to set your short-desc., No short-desc set.)))), setq(1, v(d.max-shortdesc-length)), if(gt(strlen(%q0), %q1), mid(%q0, 0, sub(%q1, 3))..., %q0))

&f.get-fields [v(d.bf)]=strcat(setq(F,), null(iter(default(%0/d.%1-fields, %2), if(member(v(d.allowed-who-fields), itext(0), |), setq(F, strcat(%qF, |, itext(0)))), |)), trim(squish(%qF, |), b, |))

&f.get-field-widths [v(d.bf)]=iter(%0, if(cand(member(object, %1), member(Name, itext(0))), 50p, extract(v(d.who-field-widths), member(v(d.allowed-who-fields), itext(0), |), 1)), |)

&f.sort-players [v(d.bf)]=strcat(setq(P,), null(iter(ulocal(f.get-sort-order, %1, %2), setq(P, ulocal(f.sort.by_[edit(itext(0), %b, _)], edit(%0, %b, |), %1)), |, |)), edit(%qP, |, %b))

&f.get-sort-order [v(d.bf)]=strcat(setq(S,), null(iter(default(%0/d.%1-sort, v(d.who-sort-order)), if(member(v(d.allowed-who-fields), itext(0), |), setq(S, %qS|[itext(0)])), |)), setq(S, trim(%qS, b, |)), %qS)

&layout.who-list [v(d.bf)]=multicol(strcat(edit(setr(F, ulocal(f.get-fields, %1, %2, v(d.default-%2-fields))), Doing, poll()), |, iter(%0, ulocal(layout.who_data, itext(0), %1, %qF),, |)), ulocal(f.get-field-widths, %qF, %2), 1, |, %1)

&layout.who_data [v(d.bf)]=iter(%2, ulocal(f.get-[edit(itext(0), %b, _)], %0, %1), |, |)

@@ Output: The list sorted by the target's who field settings
@@ %0: list of dbrefs
@@ %1: Viewer
@@ %2: which field list to sort by
&f.globalpp.whosort [v(d.bf)]=if(member(edit(lcstr(lattr(%vD/d.default-*-fields)), d.default-,, -fields,), lcstr(%2)), strcat(setq(P,), null(iter(ulocal(f.get-sort-order, %1, %2), setq(P, ulocal(f.sort.by_[edit(itext(0), %b, _)], edit(%0, %b, |), %1)), |, |)), edit(%qP, |, %b)), #-1 %2 FIELD LIST NOT FOUND)

@@ Output: the data of each object for the target's who field settings
&f.globalpp.whofields [v(d.bf)]=if(member(edit(lcstr(lattr(%vD/d.default-*-fields)), d.default-,, -fields,), lcstr(%2)), ulocal(layout.who-list, %0, %1, %2), #-1 %2 FIELD LIST NOT FOUND)

&layout.debug [v(d.bf)]=strcat(alert(timefmt($X) debug), From, %b, moniker(%0), :%b, %1)

&layout.debug_flag [v(d.bf)]=strcat(Debugging, %b, if(%1, enabled, disabled), %b, on, %b, moniker(%0)., if(%1, strcat(%b, Output will go to, %b, v(d.debug-target).)))

&tr.send_debug_message [v(d.bf)]=if(default(%0/debug.enabled, 0), pemit(v(d.debug-target), ulocal(layout.debug, %0, %1)))

&tr.flip_debug_flag [v(d.bf)]=strcat(set(%0, strcat(debug.enabled:, setr(0, not(default(%0/debug.enabled, 0))))), pemit(%#, ulocal(layout.debug_flag, %0, %q0)))

@@ %0: target object
@@ %1: message
&f.globalpp.debug [v(d.bf)]=if(t(%1), ulocal(tr.send_debug_message, %0, %1), ulocal(tr.flip_debug_flag, %0))


&layout.report [v(d.bf)]=strcat(alert(prettytime() Report), From, %b, moniker(%0), :%b, %1)

@@ %0: target object
@@ %1: message
&f.globalpp.report [v(d.bf)]=if(isdbref(v(d.report-target)), pemit(v(d.report-target), ulocal(layout.report, %0, %1)), cemit(v(d.report-target), ulocal(layout.report, %0, %1)))

&f.escape-characters [v(d.bf)]=if(t(setr(0, member(setr(1, v(d.allowed_with_escapes_in_sql)), %0))), strcat(@@ESCAPE@@, extract(%q1, %q0, 1)), %0)

@@ %0: term to sanitize
@@ This is used by the wiki +help and news systems. It places the phrase '@@ESCAPE@@' in every place it belongs. Before executing the SQL, that phrase must be replaced with ' using the f.sanitize-where function in Code support.mu. Sanitization is thus a two-step process. The reason it isn't globalized is because some setups alter the f.sanitize-where function to do additional things, like convert * to % for LIKE queries. I need to give that some thought.
&f.globalpp.sanitize [v(d.bf)]=strcat(setq(0, strip(%0, v(d.dangerous_in_sql))), setq(1,), null(iter(lnum(strlen(%q0)), setq(1, strcat(%q1, ulocal(f.escape-characters, mid(%q0, itext(0), 1)))))), %q1)



@@ The goal of these two functions is to standardize the storage of key/value pairs. A lot of code I write needs to store and retrieve things by title, and it needs to also be able to search by partial and by exact title. (You need to be able to store "Chain" and "Chainmail" on the same object, and come up with "Chain" before "Chainmail". Made that mistake last repo with the equipment DB.) As such, this should only be usable by staff or staff-owned objects. The naming convention comes from the "pair" portion of Key Value Pairs, which is what this code stores.
@@ -
@@ %0: the object to get the var from
@@ %1: the attribute prefix of the var - _note-, view-, etc. Note that the separator dash is part of the prefix; if you skip it you'll get &view123 obj=<blah>.
@@ %2: (optional) The partial or exact title you're looking up. If you skip, this will return a list of vars and their titles separated by the default row and column delimiters.
@@ Output: #-1 ERROR MESSAGE, the value that matches the key, or a list of keys and attributes.
&f.globalpp.getpair [v(d.bf)]=case(0, cor(isstaff(%#), cand(not(member(num(me), %@)), hastype(%@, THING), andflags(%@, I!h!n), isstaff(owner(%@)))), #-1 PERMISSION DENIED, isdbref(%0), #-2 OBJECT NOT FOUND, t(%1), #-3 PREFIX IS REQUIRED, strcat(setq(K, ulocal(f.get-key-prefix, %1)), t(%2)), ulocal(f.list-matching-pairs, %0, %1, lattr(%0/%qK*), %qK), t(setr(V, ulocal(f.find-pairs-by-title, %0, %1, %2))), #-4 TITLE NOT FOUND, eq(words(%qV, v(d.default-row-delimeter)), 1), ulocal(f.list-matching-pairs, %0, %1, %qV, %qK), ulocal(%0/[strcat(%1, rest(%qV, ucstr(%qK)))]))

&f.get-key-prefix [v(d.bf)]=switch(%0, _*, strcat(_, key-, rest(%0, _)), key-%0)

&f.list-matching-pairs [v(d.bf)]=iter(%2, strcat(%1, rest(itext(0), ucstr(%3)), v(d.default-column-delimeter), xget(%0, itext(0))),, v(d.default-row-delimeter))

&f.find-pairs-by-title [v(d.bf)]=if(t(setr(P, ulocal(f.find-pairs-by-exact-title, %0, %1, %2))), %qP, trim(squish(iter(grepi(%0, ulocal(f.get-key-prefix, %1)*, %2), if(strmatch(xget(%0, itext(0)), %2*), itext(0))))))

&f.find-pairs-by-exact-title [v(d.bf)]=trim(squish(iter(grepi(%0, ulocal(f.get-key-prefix, %1)*, %2), if(strmatch(xget(%0, itext(0)), %2), itext(0)))))

@@ %0: object
@@ %1: prefix
@@ %2: which key to get the proper, stored title of
&f.globalpp.getpairkey [v(d.bf)]=case(0, cor(isstaff(%#), cand(not(member(num(me), %@)), hastype(%@, THING), andflags(%@, I!h!n), isstaff(owner(%@)))), #-1 PERMISSION DENIED, isdbref(%0), #-2 OBJECT NOT FOUND, t(%1), #-3 PREFIX IS REQUIRED, strcat(setq(K, ulocal(f.get-key-prefix, %1)), t(%2)), ulocal(f.list-matching-pairs, %0, %1, lattr(%0/%qK*), %qK), t(setr(V, ulocal(f.find-pairs-by-title, %0, %1, %2))), #-4 TITLE NOT FOUND, eq(words(%qV, v(d.default-row-delimeter)), 1), ulocal(f.list-matching-pairs, %0, %1, %qV, %qK), xget(%0, %qV))

@@ %0: object
@@ %1: prefix
@@ %2: which key to get the attribute index of
@@ Output: the destination attribute, without the prefix.
&f.globalpp.getpairattr [v(d.bf)]=case(0, cor(isstaff(%#), cand(not(member(num(me), %@)), hastype(%@, THING), andflags(%@, I!h!n), isstaff(owner(%@)))), #-1 PERMISSION DENIED, isdbref(%0), #-2 OBJECT NOT FOUND, t(%1), #-3 PREFIX IS REQUIRED, strcat(setq(K, ulocal(f.get-key-prefix, %1)), t(%2)), ulocal(f.list-matching-pairs, %0, %1, lattr(%0/%qK*), %qK), t(setr(V, ulocal(f.find-pairs-by-title, %0, %1, %2))), #-4 TITLE NOT FOUND, eq(words(%qV, v(d.default-row-delimeter)), 1), ulocal(f.list-matching-pairs, %0, %1, %qV, %qK), rest(%qV, ucstr(%qK)))

@@ %0: the object to set the var to
@@ %1: the attribute prefix of the var - _note-, view-, _c., etc.
@@ %2: the key to store it under - "A proper title" or "123" are both valid, but you will have to use the same key or a partial key to look it up, so choose your storage text carefully.
@@ %3: the value to store. Can store somewhere around 7,900 characters on MUX. You can parse the output any way you like, and so can use this to store lists, etc, but remember the upper limit of the data and use the storage medium appropriately.
@@ Output: #-1 ERROR MESSAGE or "Set.", "Cleared.", or "Updated." If a key with that exact title already exists, the value on it will be replaced with the new one. If it does not, a new title will be created with the given value.
@@ Note: The destination attribute is specified by a number. Why? Cuz it's easier.
@@ What if you want to specify your own? Maybe you have the key stored in another attribute somewhere and it has to match perfectly? Just use the same conventions: _key<prefix><dest> or key<prefix><dest> for the title, <prefix><dest> for the value. Setting this up is left as an exercise for later, if I determine it's necessary.
&f.globalpp.setpair [v(d.bf)]=case(0, cor(isstaff(%#), cand(not(member(num(me), %@)), hastype(%@, THING), andflags(%@, I!h!n), isstaff(owner(%@)))), #-1 PERMISSION DENIED, isdbref(%0), #-2 OBJECT NOT FOUND, t(%1), #-3 PREFIX IS REQUIRED, t(%2), #-4 EXACT TITLE IS REQUIRED, strcat(setq(K, ulocal(f.get-key-prefix, %1)), lte(words(setr(S, ulocal(f.find-pairs-by-exact-title, %0, %1, %2))), 1)), #-5 MULTIPLE KEYS FOUND - MANUAL EDIT BY STAFF REQUIRED, neq(words(%qS), 0), strcat(set(%0, strcat(%1, setr(T, ulocal(f.get-settable-target, %0, %1)), :, %3)), set(%0, strcat(ulocal(f.get-key-prefix, %1), %qT, :, %2)), Set.), neq(words(%qS), 1), strcat(set(%0, %qS:[if(t(%3), %2)]), set(%0, strcat(%1, rest(%qS, ucstr(%qK)), :, %3)), if(t(%3), Updated., Cleared.)))

&f.get-settable-target [v(d.bf)]=inc(lmax(edit(lattr(%0/%1*), ucstr(%1),)))


@@ %0: object to check
@@ %1: person who might own it
@@ Output: 0 or 1 depending on whether the person owns it.
&f.globalpp.isowner [v(d.bf)]=ulocal(filter.is_owner, %0, %1)


@@ %0: Room number
@@ Output: the views on a room.
&f.globalpp.lviews [v(d.bf)]=case(0, isdbref(%0), #-1 NOT A VALID DBREF, hastype(%0, ROOM), #-1 NOT A ROOM, cor(isstaff(%#), member(loc(%#), %0)), #-1 CAN'T SEE VIEWS ELSEWHERE, strcat(setq(K, ulocal(f.get-key-prefix, view-)), ulocal(f.list-matching-pairs, %0, view-, lattr(%0/%qK*), %qK)))


@@ %0: Room number
@@ Output: the public notes on a room.
&f.globalpp.lnotes [v(d.bf)]=case(0, isdbref(%0), #-1 NOT A VALID DBREF, hastype(%0, ROOM), #-1 NOT A ROOM, cor(isstaff(%#), member(loc(%#), %0)), #-1 CAN'T SEE NOTES ELSEWHERE, strcat(setq(K, ulocal(f.get-key-prefix, _note-)), setq(L, ulocal(f.list-matching-pairs, %0, _note-, lattr(%0/%qK*), %qK)), trim(squish(iter(%qL, if(gte(ulocal(f.get-note-visibility-setting, %0, rest(first(itext(0), v(d.default-column-delimeter)), -)), case(1, isstaff(%2), -1, isowner(%0, %2), 0, 1)), itext(0)), v(d.default-row-delimeter), v(d.default-row-delimeter)), v(d.default-row-delimeter)), b, v(d.default-row-delimeter))))

@@ %0: A delimiter-separated list of items
@@ %1: The item to match
@@ %2: Default space.
@@ finditem(list, item, delimiter) - finds the first item that matches the input. If the input contains a *, then the input itself is returned as a last resort.
@@ NOTE: This code is written so that your input can contain "0" as part of the list, and will match it. To test the output of this code, use t(strlen(finditem(list, item, delimiter))) rather than just t() when a 0 may be involved in the output.
&f.globalpp.finditem [v(d.bf)]=if(strlen(%1), strcat(if(t(%2), setq(D, %2), setq(D, %b)), if(t(strlen(setr(S, extract(%0, member(%0, %1, %qD), 1, %qD)))), %qS, if(t(strlen(setr(S, extract(%0, match(%0, %1*, %qD), 1, %qD)))), %qS, if(member(%0, *, %qD), %1)))))
