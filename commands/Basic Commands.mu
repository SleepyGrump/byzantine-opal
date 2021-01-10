/*
Note: When done installing this, @restart the game or the functions won't work.

I'm adding SGP functions as I run across the need for them. So far I have:

	isstaff() - allow access if someone is a staffer (now takes into account non-bitted staffers)

	secs2hrs() - functionality updated to return durations in years, months, weeks, days, hours, minutes, and seconds, but only the first two intervals.

Anything else, I haven't come across a need for outside of the SGP Globals themselves.

Some additional functions that are my own work:

	interval() - return a duration between two timestamps in seconds

	title() - a properly cased title which honors the case given by the sentence author: title(a book about the iPad by the BBC) will produce "A Book About the iPad by the BBC". (Note, this is different functionality from the titlestr() function of Thenomain's GMCCG - that was designed to turn all-caps words like "COOKING" into title-cased "Cooking". This would keep the original word's case.)


Layout functions:

	header() and wheader()
	divider(), subheader(), and wdivider()
	footer() and wfooter()
	formattext() - wrap the text up with your default margins and borders
	formatcolumns() - fit tabular data into your default margins and borders
	formattable() - tabular data, optionally with a header, you choose the number of columns
	formatdb() - tabular data straight out of a database, columns determined by the number returned. (Designed to work with the output of SQL Commands.mu.)
	multicol() - lay out tabular data where you want to specify column widths, either as a percentage or explicit widths. Includes the ability to designate "fill" columns - * means "let this column take up all the remaining available space".

The following functions are useful for developers:

	debug(obj, message) - sends a message to the chosen debugger (hard-coded in a setting below so that your debugs have no chance of escaping) only if debugging is turned on for that object. You can turn debugging off and on with debug(obj).

	report(obj, message) - sends a report automatically to a hard-coded target, either a dbref or a channel. I use this for SQL failures, which I always want to know about, and send them to the staff channel.

Below are the old functions formattext and formatcolumns replace. They're not 1:1 replacements, so they are included below but are commented out:

	boxtext() - wrap a bit of text up with margins, optionally tabulated
	fitcolumns() - fit as many columns on the screen as possible
	getlongest() - get the longest item in a list (used for determining width, no longer needs to be its own function)

Commands from SGP I will be duplicating:
	motd
	ooc and '
	+ooc/+ic
	+staff and +staff/all, +staff/add and +staff/remove
	+view
	+glance
	+duty
	+dark
	+join <name> and +rjoin or +return or something cuz I always forgot that command
	+summon <name> and +rsummon or +return <name>

Stuff I will not be duplicating at this time:
	places - this would be its own thing if I created it and would not require fancy setup if I could avoid it
	+beginner - I have never seen a beginner make use of this.
	+info - this is going to be game-specific.
	+selfboot - no need at the moment.
	+knock and +shout
	+uptime
	+warn
	+bg

*/

@create Basic Data <BD>=10
@set BD=SAFE
@force me=&d.bd me=[num(BD)]

@create Basic Functions <BF>=10
@set BF=SAFE INHERIT
@parent BF=BD
@force me=&d.bf me=[num(BF)]
@force me=&vd [v(d.bf)]=[v(d.bd)]

@create Basic Commands <BC>=10
@set BC=SAFE INHERIT
@parent BC=BF
@force me=&d.bc me=[num(BC)]

@tel [v(d.bd)]=[v(d.bf)]
@tel [v(d.bf)]=[v(d.bc)]

@@ Here are where the settings go. Change this if you want!

@@ Append DBRefs here, or just add them when you set up the commands with +staff/add.
&d.staff_list [v(d.bd)]=

@@ Default alert message
&d.default-alert [v(d.bd)]=GAME

&d.indent-width [v(d.bd)]=5

&d.debug-target [v(d.bd)]=#1

&d.report-target [v(d.bd)]=Staff

@@ Effect controls the color of the header, footer, and divider functions.
@@ -
@@ Available effects are:
@@   none - no colors
@@   alt - as in alternating - colors go A > B > C > A > B > C...
@@   altrev - as in alternating reverse - colors go A > B > C > B > A
@@   random - colors vary randomly, chosen from your list
@@   fade - colors go on the left and right of all functions.
@@ -
&d.effect [v(d.bd)]=fade

@@ These are the colors. Players won't see them unless they are set ANSI and
@@ COLOR256. You can set that up in your netmux.conf config with:
@@ -
@@   player_flags ansi color256 ascii keepalive
@@ -
@@ That means every player will be created with those flags already set.
@@ Remember that players can change these flags at any time if they want!
@@ Also, setting the flags doesn't magically make the player's client able to
@@ view colors or parse ascii characters. If they can they'll see it; if not,
@@ it won't change a thing.
@@ -
&d.colors [v(d.bd)]=x<#FF0000> x<#AA0055> x<#5500AA> x<#0000FF>

@@ What color is your text? 99% of people should just go with white for
@@ readability.
&d.text-color [v(d.bd)]=xw

@@ Now on to the structure of your header/footer/divider!
@@ -
@@ Effect:
@@ .o.oO( GAME )Oo.o. Alert message
@@ .o.oO( test )Oo...........................................................o.
@@ . text goes here and there is surely going to be a lot of text whee txting .
@@ .o..............................oO( test )Oo..............................o.
@@ . text goes here and there is surely going to be a lot of text whee txting .
@@ .o...........................................................oO( test )Oo.o.
@@ -
&d.text-left [v(d.bd)]=.o
&d.text-right [v(d.bd)]=o.
&d.text-repeat [v(d.bd)]=.
&d.title-left [v(d.bd)]=.oO(
&d.title-right [v(d.bd)]=)Oo.
&d.body-left [v(d.bd)]=.
&d.body-right [v(d.bd)]=.

@@ Effect:
@@ /=/ GAME /=/ Alert message
@@  /=/ test /=================================================================/
@@  / text goes here and there is surely going to be a lot of text whee txting /
@@  /=================================/ test /=================================/
@@  / text goes here and there is surely going to be a lot of text whee txting /
@@  /=================================================================/ test /=/
@@ -
&d.text-left [v(d.bd)]=/
&d.text-right [v(d.bd)]=/
&d.text-repeat [v(d.bd)]==
&d.title-left [v(d.bd)]==/
&d.title-right [v(d.bd)]=/=
&d.body-left [v(d.bd)]=/
&d.body-right [v(d.bd)]=/

@@ You can produce more complex results by using more characters for the repeat
@@ section, but they will be cut off after a certain point. Notice how the
@@ Footer below has a character missing from its cut-off side. If you or your
@@ players are perfectionists, stay away from the multiple-character repeats.
@@ -
@@ Effect:
@@ .o.oO( GAME )Oo.o. Alert message
@@  .o.oO( test )Oo..oOo..oOo..oOo..oOo..oOo..oOo..oOo..oOo..oOo..oOo..oOo..oOo.
@@  . text goes here and there is surely going to be a lot of text whee txting .
@@  .o.oOo..oOo..oOo..oOo..oOo..oOo..oO( test )Oo..oOo..oOo..oOo..oOo..oOo..oOo.
@@  . text goes here and there is surely going to be a lot of text whee txting .
@@  .o.oOo..oOo..oOo..oOo..oOo..oOo..oOo..oOo..oOo..oOo..oOo..oO.oO( test )Oo.o.
@@ -
&d.text-left [v(d.bd)]=.o
&d.text-right [v(d.bd)]=o.
&d.text-repeat [v(d.bd)]=.oOo.
&d.title-left [v(d.bd)]=.oO(
&d.title-right [v(d.bd)]=)Oo.
&d.body-left [v(d.bd)]=.
&d.body-right [v(d.bd)]=.

@@ Finally, our default, chosen because it shows off the colors well.
@@ -
@@ Effect:
@@ .~{ GAME }~. Alert message
@@  .~{ test }~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.
@@  . text goes here and there is surely going to be a lot of text whee txting .
@@  .~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~{ test }~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.
@@  . text goes here and there is surely going to be a lot of text whee txting .
@@  .~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~{ test }~.
@@ -
&d.text-left [v(d.bd)]=.
&d.text-right [v(d.bd)]=.
&d.text-repeat [v(d.bd)]=~
&d.title-left [v(d.bd)]=~{
&d.title-right [v(d.bd)]=}~
&d.body-left [v(d.bd)]=.
&d.body-right [v(d.bd)]=.

@@ Other sample ascii art ideas:
@@ ^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^
@@ ^V^ text goes here and there is surely going to be a lot of text whee tex ^V^
@@ <--------------------------------------------------------------------------->
@@ | o | text goes here and there is surely going to be a lot of text whee | o |
@@ .o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.
@@ () text goes here and there is surely going to be a lot of text whee texti ()
@@ <+><+><+><+><+><+><+><+><+><+><+><+><+><+><+><+><+><+><+><+><+><+><+><+><+<+>
@@ <+> text goes here and there is surely going to be a lot of text whee tex <+>
@@ <+>-+-<+>-+-<+>-+-<+>-+-<+>-+-<+>-+-<+>-+-<+>-+-<+>-+-<+>-+-<+>-+-<+>-+-<-<+>
@@ ][ text goes here and there is surely going to be a lot of text whee texti ][
@@ .:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.
@@ : text goes here and there is surely going to be a lot of text whee texting :


@@ =============================================================================
@@ Past this point, you shouldn't change anything unless you know what you're
@@ doing.
@@ =============================================================================

@@ Make sure these match the defaults in your SQL Commands install if you change those:
&d.default-row-delimeter [v(d.bd)]=|

&d.default-column-delimeter [v(d.bd)]=~

@@ 31570560 - 365 days we're calling a year
@@ 2592000 - 30 day span we are arbitrarily calling a month
@@ 604800 - week
@@ 86400 - day
@@ 3600 - hour
@@ 60 - minute
&d.durations [v(d.bd)]=31570560 2592000 604800 86400 3600 60

&d.duration-words [v(d.bd)]=y M w d h m

&d.words-to-leave-uncapitalized [v(d.bd)]=a an and as at but by for in it nor of on or the to up von

&d.punctuation [v(d.bd)]=. , ? ! ; : ( ) < > { } * / - + " '

@startup [v(d.bf)]=@trigger me/tr.make-functions;

&tr.make-functions [v(d.bf)]=@dolist lattr(me/f.global.*)=@function rest(rest(##, .), .)=me/##; @dolist lattr(me/f.globalp.*)=@function/preserve rest(rest(##, .), .)=me/##; @dolist lattr(me/f.globalpp.*)=@function/preserve/privilege rest(rest(##, .), .)=me/##;

@@ These functions are rewrites of the SGP Globals functions.

&f.globalpp.isstaff [v(d.bf)]=or(member(v(d.staff_list), pmatch(%0)), orflags(%0, WZw))


@@ On with the custom stuff below!

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
&f.globalpp.formattext [v(d.bf)]=strcat(setq(T, edit(%0, |, %r)), if(t(%1), setq(T, strcat(%r, space(v(d.indent-width)), trim(trim(%qT, b, %r)), %r%b))), setq(0, ulocal(f.get-width, %2)), setq(1, v(d.body-left)), setq(2, v(d.body-right)), setq(3, sub(%q0, add(strlen(%q1), strlen(%q2), 4))), setq(4, words(wrap(%qT, %q3, l, edit(%b%q1%b, |, %b), edit(%b%q2, |, %b),, |), |)), setq(5, wrap(%qT, %q3, l,,,, |)), setq(6, ulocal(f.apply-effect, iter(lnum(%q4), %q1,, @@), strlen(%q1))), setq(7, ulocal(f.apply-effect, iter(lnum(%q4), %q2,, @@), strlen(%q2))), iter(lnum(%q4), strcat(%b, mid(%q6, mul(itext(0), strlen(%q1)), strlen(%q1)), %b, extract(%q5, inum(0), 1, |), %b, mid(%q7, mul(itext(0), strlen(%q2)), strlen(%q2))),, %r))

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

&f.globalpp.formatdb [v(d.bf)]=strcat(setq(R, if(t(%2), %2, v(d.default-row-delimeter))), setq(C, if(t(%3), %3, v(d.default-column-delimeter))), setq(5, words(first(%0, %qR), %qC)), setq(T, edit(%0, %qC, %qR)), setq(0, ulocal(f.get-width, %4)), setq(1, v(d.body-left)), setq(2, v(d.body-right)), setq(3, sub(%q0, add(strlen(%q1), strlen(%q2), 4))), setq(4, div(%q3, inc(%q5))), setq(6, ceil(fdiv(words(%qT, %qR), %q5))), setq(7, ulocal(f.apply-effect, iter(lnum(%q6), %q1,, @@), strlen(%q1))), setq(8, ulocal(f.apply-effect, iter(lnum(%q6), %q2,, @@), strlen(%q2))), setq(E, sub(%q3, add(mul(%q4, %q5), %q5))), setq(4, add(%q4, div(%qE, %q5))), iter(lnum(%q6), strcat(%b, mid(%q7, mul(itext(0), strlen(%q1)), strlen(%q1)), %b, setq(9, mid(iter(lnum(%q5), ansi(if(cand(t(%1), eq(itext(1), 0)), strcat(first(v(d.colors)), %b, u)), ljust(mid(extract(%qT, add(mul(itext(1), %q5), inum(0)), 1, %qR), 0, %q4), %q4)),, %b), 0, %q3)), %q9, space(sub(%q3, strlen(%q9))), %b, mid(%q8, mul(itext(0), strlen(%q2)), strlen(%q2))),, %r))

@@ %0: data to work with
@@ %1: a list of column widths (ie, 4 * 12, * means all remaining space)
@@ %2: first row is a header row (optional, default no)
@@ %3: data delimiter (optional, default space)
@@ %4: column widths are percentages
@@ %5: player to format for or numeric width (optional)
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

&f.globalpp.multicol [v(d.bf)]=strcat(setq(5, words(%1)), setq(0, ulocal(f.get-width, %5)), setq(1, v(d.body-left)), setq(2, v(d.body-right)), setq(3, sub(%q0, add(strlen(%q1), strlen(%q2), 4))), setq(6, ceil(fdiv(words(%0, %3), %q5))), setq(7, ulocal(f.apply-effect, iter(lnum(%q6), %q1,, @@), strlen(%q1))), setq(8, ulocal(f.apply-effect, iter(lnum(%q6), %q2,, @@), strlen(%q2))), iter(lnum(%q6), strcat(%b, mid(%q7, mul(itext(0), strlen(%q1)), strlen(%q1)), %b, setq(9, mid(iter(lnum(%q5), ansi(if(cand(t(%2), eq(itext(1), 0)), strcat(first(v(d.colors)), %b, u)), ljust(mid(extract(%0, add(mul(itext(1), %q5), inum(0)), 1, %3), 0, ulocal(f.get-column-width, %4, %q3, inum(0), %1)), ulocal(f.get-column-width, %4, %q3, inum(0), %1))),, %b), 0, %q3)), %q9, space(sub(%q3, strlen(%q9))), %b, mid(%q8, mul(itext(0), strlen(%q2)), strlen(%q2))),, %r))

@@ %0: is percentage
@@ %1: width of space available
@@ %2: which width to grab
@@ %3: all widths so we can calculate remaining space if * is passed
&f.get-column-width [v(d.bf)]=strcat(setq(W, extract(%3, %2, 1)), if(member(*, %qW), strcat(setq(0,), null(iter(setr(L, trim(squish(edit(%3, *,)))), setq(0, add(%q0, ulocal(f.calc-column-width, %0, %1, extract(%qL, inum(0), 1), %qL))))), setq(1, sub(floor(fdiv(sub(%1, %q0), dec(words(%3, *)))), sub(words(%3), dec(words(%3, *))))), setq(E, mod(sub(%1, %q0), dec(words(%3, *)))), add(%q1, if(eq(%2, member(reverse(%3), *)), %qE))), ulocal(f.calc-column-width, %0, %1, %qW, %3)))

&f.calc-column-width [v(d.bf)]=if(t(%0), floor(mul(%1, fdiv(%2, 100))), %2)

@@ Aliases for the other commands.

&f.globalpp.subheader [v(d.bf)]=divider(%0, %1)

&f.globalpp.wheader [v(d.bf)]=header(%0, %1)

&f.globalpp.wdivider [v(d.bf)]=divider(%0, %1)

&f.globalpp.wfooter [v(d.bf)]=footer(%0, %1)

&f.globalpp.wfooter [v(d.bf)]=footer(%0, %1)

@@ %0 - the width of the screen
@@ %1 - the number of columns
@@ &f.calc-width [v(d.bf)]=sub(ceil(fdiv(%0, %1)), sub(%1, 1))

@@ %0 - %#
@@ %1 - minimum width
@@ Output: a number between 1 and 6 for how many columns can fit on screen.
@@ &f.get-max-columns [v(d.bf)]=strcat(setq(0, sub(ulocal(f.get-width, %0), 2)), setq(1, if(t(%1), %1, 10)), case(1, gt(%q1, ulocal(f.calc-width, %q0, 2)), 1, gt(%q1, ulocal(f.calc-width, %q0, 3)), 2, gt(%q1, ulocal(f.calc-width, %q0, 4)), 3, gt(%q1, ulocal(f.calc-width, %q0, 5)), 4, gt(%q1, ulocal(f.calc-width, %q0, 6)), 5, 6))

@@ %0 - a list
@@ %1 - delimiter (optional)
@@ Output: the length of the longest item in a list.
@@ &f.globalpp.getlongest [v(d.bf)]=strcat(setq(0, 0), null(iter(%0, if(gt(setr(1, strlen(itext(0))), %q0), setq(0, %q1)), if(t(%1), %1, %b))), %q0)

@@ %0 - list of text
@@ %1 - delimiter (optional)
@@ %2 - user (optional)
@@ %3 - margins (optional, default 1)
@@ Output: the list separated into the number of columns that can fit on the screen, max 6.
@@ &f.globalpp.fitcolumns [v(d.bf)]=strcat(setq(0, if(t(%1), %1, %b)), setq(1, ulocal(f.get-max-columns, %2, getlongest(%0, %q0))), boxtext(case(1, gt(%q1, 1), %0, and(lte(%q1, 1), strmatch(%q0, %b)), %0, edit(%0, %q0, %R)), if(gt(%q1, 1), %q0), if(gt(%q1, 1), %q1), %2, %3))


@@ Function: wrap text for display, optionally columnizing it.
@@ Arguments:
@@  %0 - the text to box
@@  %1 - the delimiter to split it by if a table is desired
@@  %2 - the number of columns to display in a table (default 3)
@@  %3 - the user this is getting shown to (optional)
@@  %4 - the margins (optional, default 1)

@@ &f.globalpp.boxtext [v(d.bf)]=strcat(setq(0, ulocal(f.get-width, if(t(%3), %3, %#))), setq(4, if(t(%4), %4, 1)), setq(1, sub(%q0, mul(%q4, 2))), if(or(t(%1), t(%2)), strcat(setq(2, if(t(%2), %2, 3)), setq(3, sub(%q2, 1)), setq(5, mod(%q1, %q2)), setq(3, add(%q3, %q5)), edit(table(%0, div(sub(%q1, %q3), %q2), %q1, %1), ^, space(%q4), %r, strcat(%r, space(%q4)))), wrap(%0, sub(%q1, if(not(mod(%q1, 2)), 1, 0)), left, space(%q4))))

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
&f.globalpp.secs2hrs [v(d.bf)]=ulocal(f.calculate-duration, %0)

&f.global.prettytime [v(d.bf)]=timefmt($m-$d-$Y $r)


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




@@ Wrapping up:

@restart
