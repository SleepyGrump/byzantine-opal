/*
This whole thing is a mod of the Pose Order Machine by skewskewskew and the original is available at: https://github.com/skewskewskew/MUSHCode/blob/master/Pose%20Order%20Machine.txt

This is my attempt to see if I can add a feature or three to this much-beloved (and sometimes controversial) code.

Some people like it because:
	- It saves forgetful folks from missing their turn.
	- It saves them from having to rattle someone's cage with "hey it's your turn to pose".
	- It can help keep one person from running roughshod over slower posers. "Hey, it's not your turn yet! Please follow the +poseorder."
	- It gives you a way to set expectations and stick to them. "We're short on time, so if someone doesn't pose for 10 minutes, we're skipping them."

Some people hate it because:
	- It makes them feel rushed.
	- It regiments things more than they like - they feel like scenes flow more naturally when pose order is ignored.

Even outside those two camps, though, there were issues:
	- It was a little spammy when you only had two people in the room - handy if you're the forgetful sort, but less so if you're paying attention. You're not likely to forget it's your turn when there's only one other player - but you might turn +poseorder off and forget to turn it back on.
	- It warned you belatedly - you'd be tooling around in another window and AAA IT'S MY TURN HAVE TO CATCH UP!! It happens to us all.
	- In large scenes operating on a casual "as long as you're not posing right after yourself" type of rule, it would spam the user every time someone posed out of order (when there is no real order in scenes like that).

This update is an attempt to keep the good of the old version, while fixing some of the issues I perceived with it, and:

1) Make it OK to turn on Pose Order for all players by default.

2) Make it configurable enough to provide some value even for people who don't like the old version.

3) Maybe reduce some of the anxiety-causing features in it. "It will be your turn to pose once <name> has posed" is a little less sudden and stressful, perhaps - a better transition.

The "Fixed pose order" idea is skewskewskew's, as you can see in the original file - I'm just actually coding it, along with a bit of extra work and other commands.

Changes:
- Made compatible with byzantine-opal. Visual updates, function calls, etc. Because of this, this thing does require either byzantine-opal installed or some coding to remove the reliance on it.

- Added +poseorder/style <fixed or regular> - regular is the normal behavior, fixed is for large scenes and alerts you when a minimum of 1/2 the people have posed and a maximum of 5 people have posed (configurable).

- Added +poseorder/idle <time in minutes, hours, or seconds> - vary the pose-oder idle time up. If the idle time hits, you get dropped out of the pose order until you pose back in. Players can set it to a time that's realistic for the group - between 10m and 3h by default - and thus not have a player getting spammed a bunch with "it's your pose!" reminders while they're AFK.

- Silence alerts when there are only 2 players present unless the player has the alert set to LOUD. (Some players use this as a client beep, hang hooks off it, etc.)

- Made it alert the next player up that their pose is coming once the current player poses, unless there are only two players.

- Made it so that players not in the room don't get alerted.

- If someone leaves or gets disconnected and they were at the top of the pose order, alert the next player on the list that it's now their turn to pose. (This might cause issues in large groups with a lot of people ducking in and out - it needs testing.)

- Added some aliases:
	q -> quiet
	l -> loud
	of -> off
	/skip -> /skip me
	/remove -> /remove me
	/leave -> /remove me
	/hel* -> /help
	/her* -> /here
	/h* and you don't own the room -> /help
	+po -> +poseorder
	+skip -> +poseorder/skip
	+leave -> +poseorder/remove me

- Little fixes that bugged me, mostly visual and phrasing. ("You removed yourself from the pose order" vs "You remove <your own name>.") Visual tweaks to make the layout a little more concise and pretty.

- Forced a clear of poseorder settings when all players have left the room, extended clear command to remove all player-settable settings and maintenance attributes.

*/

@create Pose Order Machine <pom>

@set Pose Order Machine <pom>=inherit safe

@fo me=&d.pom me=search(name=Pose Order Machine <pom>)

@tel [v(d.pom)]=[config(master_room)]

@fo me=&d.ho [v(d.pom)]=[v(d.ho)]

@fo me=@parent [v(d.pom)]=[v(d.bf)]

@fo me=&d.pom [v(d.ho)]=v(d.pom)

@set [v(d.pom)]=!halt

@desc [v(d.pom)]=strcat(header(Pose Order Machine <POM>, %#), %r, formattext(Please use +poseorder/help for help! %r%r%tThis thing was made by skew%, with mods by Wrench., 1, %#), %r, footer(+poseorder, %#))

&.msg [v(d.pom)]=cat(alert(%0), %1)

@@ Every min sweeps players who have not posed in (d.pose.time) seconds. Default here is 2700 = 45 minutes
&d.pose.time [v(d.pom)]=2700

@@ How many poses should someone wait in a FIXED scene, max, before they should pose? If your game commonly throws 30 person scenes where players are expected to wait for 15 people to pose before they can pose, you'll want to raise this. If you're more the laissez-faire sorts, 3 might be your max. The number will still be dynamic based on the number of players in the scene (no point in waiting 5 poses if there are only 3 people left in the room!) but this puts a hard limit on how high it can get.
&d.fixed-max-poses [v(d.pom)]=5

@@ Minimum player-settable idle time - 600 is 10 minutes.
&d.pose-time-min [v(d.pom)]=600

@@ Maximum player-settable idle time - 10800 is 3 hours.
&d.pose-time-max [v(d.pom)]=10800

&d.exclude.rooms [v(d.pom)]=@@(Adding this here so you know it's here. Code will set it when needed.)

&d.exclude.zones [v(d.pom)]=@@(Adding this here so you know it's here. Code will set it when needed.)

@@ Hook object is already set in the object creation phase of byzantine-opal.

@@ Configure the hook object to send to the pom object.

@@ First, delete old entries. If you've not installed POM before, this does nothing.

@edit [v(d.ho)]/B_POSE = [u([v(d.pom)]/f.poseorder)],

@edit [v(d.ho)]/B_POSE/NOSPACE = [u([v(d.pom)]/f.poseorder)],

@edit [v(d.ho)]/B_NPOSE = [u([v(d.pom)]/f.poseorder)],

@edit [v(d.ho)]/B_SAY = [u([v(d.pom)]/f.poseorder)],

@edit [v(d.ho)]/B_NSAY = [u([v(d.pom)]/f.poseorder)],

@edit [v(d.ho)]/B_@EMIT = [u([v(d.pom)]/f.poseorder)],

@@ Second, add entries we need. This now contains 'who posed', which is used
@@ in a later part of the code.

@edit [v(d.ho)]/B_POSE = $, [u([v(d.pom)]/f.poseorder, %#)]

@edit [v(d.ho)]/B_POSE/NOSPACE = $, [u([v(d.pom)]/f.poseorder, %#)]

@edit [v(d.ho)]/B_NPOSE = $, [u([v(d.pom)]/f.poseorder, %#)]

@edit [v(d.ho)]/B_SAY = $, [u([v(d.pom)]/f.poseorder, %#)]

@edit [v(d.ho)]/B_NSAY = $, [u([v(d.pom)]/f.poseorder, %#)]

@edit [v(d.ho)]/B_@EMIT = $, [u([v(d.pom)]/f.poseorder, %#)]

@@ Cron is already set in the object creation phase of installing byzantine-opal.

@fo me=&jobs_1minute [v(d.cron)]=[strcat(get([v(d.cron)]/jobs_1minute), %b, [v(d.pom)]/trig.sweep.rooms)]

&cron_time_1minute [v(d.cron)]=||||00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59|

&cron_job_1minute [v(d.cron)]=@dol [v(jobs_1minute)]=@trigger ##

&f.area-prevents-posealert [v(d.pom)]=cor(match(u(d.exclude.zones), zone(%0)), @@(check exclude zones), match(u(d.exclude.rooms), %0), @@(check exclude room list), match(get(%0/_POSE.ORDER), off), @@(check setting on local room), @@(Add no-pose-alert-in-OOC-rooms), strmatch(parent(%0), %vO))

@@ Variables: 0: The target to process as having posed.
@@ Previously, this assumed the poser would always be the 'target'. Now we are
@@ Adding pose skipping, so %0 might not always be the enactor. Might be someone else.

&f.poseorder [v(d.pom)]=strcat(setq(l, loc(%0)), @@(get location), if(ulocal(f.area-prevents-posealert, %ql), @@(If on the no list do nothing), strcat(iter(lattr(%ql/d.pose.*), if(match(last(get(%ql/##), .), %0), wipe(%ql/##), @@(do nothing))), @@(clear your previous poses), set(%ql, u(f.format.pose.attribute, %0):[u(f.format.pose.data, %0)]), settimer(%0, pose-alerted, 0), @@(add that you posed), trigger(me/trig.pose.alert, %ql), @@(alert whoever's up))))

@@ Each time you pose add attrib. Should looks like:
@@ d.pose.34 : 12098570983.#15
@@ d.pose.next available number : time.who posed
@@ We're adding 1000 so the attribute will be 1001+, that makes it easier
@@ To sort (because otherwise d.pose.1 d.pose.2 d.pose.10 ... it'll go 1 10 2 

&f.format.pose.attribute [v(d.pom)]=strcat(d., pose., inc(add(u(f.get.last), 1000)))

@@ Check all attributes for the #s, grab the last (highest) 

&f.get.last [v(d.pom)]=if(lt(setr(5, sub(last(sort(iter(lattr(%ql/d.pose.*), last(##, .), , %b), n)), 1000)), 0), 0, %q5)

&f.format.pose.data [v(d.pom)]=strcat(secs()., %0)

@@ Put the list of poses in order. Output should be Seconds:#DBref Seconds:#DBref

&f.sortby-time [v(d.pom)]=comp(first(get(%0), .), first(get(%1), .))

@@ How the pose order used to be before a player or players left.
&f.old.order.poses [v(d.pom)]=iter(sortby(f.sortby-time, iter(setunion(lattr(%0/d.pose.*), lattr(%0/d.oldpose.*)), strcat(%0, /, itext(0)))), get(itext(0)))

&f.order.poses [v(d.pom)]=strcat(setq(o, sort(lattr(%0/d.pose.*))), squish(trim(iter(%qo, if(cand(ulocal(filter.is_connected_player, setr(P, rest(setr(0, get(%0/##)), .))), strmatch(loc(%qP), %0)), %q0)))), @@(List of who posed is stored on room object))

&trig.sweep.rooms [v(d.pom)]=@dol search(eroom=lattr(##/d.pose.*))={ @trig me/trig.sweep.idle=##; @if t(gettimer(##, alert-someone))={ @if t(setr(F, xget(##, d.removed.players)))={ @set ##=d.removed.players:; @if strmatch(first(%qF), rest(first(ulocal(f.old.order.poses, ##)), .))={ @trigger me/trig.pose.alert=##; }; @wipe ##/d.oldpose.*; }; }; }; @dol search(eroom=lattr(##/d.*pose.*))={ @if eq(words(filter(filter.is_connected_player, lcon(##))), 0)={ @eval ulocal(c.poseorder.clear.here, ##); }; }

@@ Sweep will be triggered via CRON on a one minute. If not in room, if disconnected, or if exceed time
@@ You get swept!

&f.get-pose-time [v(d.pom)]=default(%0/d.pose-time, v(d.pose.time))

&trig.sweep.idle [v(d.pom)]=@dol lattr(%0/d.pose.*)=th strcat(setq(1, get(%0/##)), setq(t, first(%q1, .)), setq(p, rest(%q1, .)), if(cor(not(match(lcon(%0, connect), %qp)), gte(sub(secs(), %qt), u(f.get-pose-time, %0)), not(match(loc(%qP), %0)), @@(if not connected or if idle wipe)), strcat(set(%0, edit(##, .POSE., .OLDPOSE.):[xget(%0, ##)]), wipe(%0/##), settimer(%0, alert-someone, 120, set(%0, strcat(d.removed.players, :, unionset(xget(%0, d.removed.players), %qP)))))))

&f.get-pose-alert-status [v(d.pom)]=switch(xget(%0, _pose.alert), loud, 2, quiet, 1, off, 0, #$)

&f.get-scene-style [v(d.pom)]=default(%0/d.pose-scene-style, normal)

@@ Get all the players who have not posed in the last half or the last 3 poses, minimum. So if there are 20 people, it would show you an alert when you haven't posed in 10 poses. If there are 5 people, it would alert you when you hadn't posed in 2 poses.
&f.get-players-who-can-pose [v(d.pom)]=iter(extract(revwords(%0), inc(%1), words(%0)), rest(itext(0), .))

@@ Filter it down to only the ones that don't have timers saying they've been alerted in the last X minutes.
&f.get-players-to-alert [v(d.pom)]=squish(trim(iter(ulocal(f.get-players-who-can-pose, %0, %1, %2), if(gettimer(itext(0), pose-alerted, %2),, itext(0)))))

&f.calc-max-poses [v(d.pom)]=min(max(1, div(words(%0), 2)), v(d.fixed-max-poses))

&trig.pose.alert [v(d.pom)]=@eval setq(O, u(f.order.poses, %0)); @break eq(setr(W, words(%qO)), 0); @switch/first ulocal(f.get-scene-style, %0)=fixed, { @dolist ulocal(f.get-players-to-alert, %qO, setr(C, ulocal(f.calc-max-poses, %qO)), %0)={ @eval settimer(##, pose-alerted, 80400, %0); @pemit ##=ulocal(.msg, Pose Order, It has been %qC poses since you last posed. You're free to pose.); }; }, { @eval setq(u, rest(first(%qO), .)); @eval setq(n, rest(first(rest(%qO)), .)); @if cand(t(setr(L, ulocal(f.get-pose-alert-status, %qU))), gt(%qW, 2))={ @pemit %qU=[u(.msg, Pose Order, It is your turn to pose.)][if(eq(%qL, 2), cat(beep(), Beep!))]; }; @if cor(cand(t(setr(M, ulocal(f.get-pose-alert-status, %qN))), gt(%qW, 2)), eq(%qM, 2))={ @pemit %qn=[u(.msg, Pose Order, It will be your turn to pose as soon as [ulocal(f.get-name, %qu, %qN)] poses.)][if(cor(eq(%qm, 2)), cat(beep(), Beep!))]; }; }

&layout.poseorder-player-settings [v(d.pom)]=strcat(Your alert is currently set to, %b, case(ulocal(f.get-pose-alert-status, %0), 1, QUIET, 2, LOUD, OFF)., |)

&layout.poseorder-room-settings [v(d.pom)]=multicol(strcat(Scene style:, |, if(t(%2), FIXED %2 poses, REGULAR), |, Idle timeout:, |, remove(secs2hrs(ulocal(f.get-pose-time, %0)), 0s)), 12 * 13r 6, 0, |, getremainingwidth(%1), 1)

&layout.poseorder-off [v(d.pom)]=multicol(strcat(|, Pose Order tracking is currently, %b, ansi(hr, OFF)., ||, Staff or the room owner can turn it on., ||, ulocal(layout.poseorder-player-settings, %1)), *c, 0, |, %1)

&layout.poseorder-excluded [v(d.pom)]=multicol(strcat(|, This room is currently, %b, ansi(hr, excluded) from pose tracking., ||, If it should be on%, please contact staff via %chreq/build%cn., ||, ulocal(layout.poseorder-player-settings, %1)), *c, 0, |, %1)

&layout.poseorder-no-poses [v(d.pom)]=multicol(strcat(|, No one has posed yet., ||, ulocal(layout.poseorder-room-settings, %0, %1), ||, ulocal(layout.poseorder-player-settings, %1)), *c, 0, |, %1)

&layout.player-info [v(d.pom)]=strcat(||, ulocal(f.get-name, %1), |, singletime(sub(secs(), %0)), |, singletime(if(hasflag(%1, connected), idle(%1), sub(secs(), connleft(%1)))), |)

&layout.players [v(d.pom)]=multicol(strcat(|Name|Last|Idle|, iter(%2, ulocal(layout.player-info, first(itext(0), .), rest(itext(0), .)),, @@)), * 20 4 4 *, 1, |, %1)

&layout.poseorder [v(d.pom)]=strcat(multicol(switch(ulocal(f.get-scene-style, %0), fixed, strcat(|, The following players are free to pose:, %b, ulocal(layout.list, iter(ulocal(f.get-players-who-can-pose, %qO, setr(C, ulocal(f.calc-max-poses, %qO)), %0), ulocal(f.get-name, itext(0), %1),, |))., |), strcat(|, It is, %b, ulocal(f.get-name, %3, %1)'s pose., |)), *c, 0, |, %1), %r, ulocal(layout.players, %0, %1, %2), %r, multicol(strcat(|, ulocal(layout.poseorder-room-settings, %0, %1, %qC), ||, ulocal(layout.poseorder-player-settings, %1)), *c, 0, |, %1))

&display.pose.order [v(d.pom)]=strcat(setq(o, u(f.order.poses, %0)), setq(u, rest(first(%qo), .)), case(1, match(get(%0/_POSE.ORDER), off), ulocal(layout.poseorder-off, %0, %1), ulocal(f.area-prevents-posealert, %0), ulocal(layout.poseorder-excluded, %0, %1), not(%qO), ulocal(layout.poseorder-no-poses, %0, %1), ulocal(layout.poseorder, %0, %1, %qO, %qU)))

formattext(strcat(@@(This pulls the list of posers and displays it. Nbd.), setq(o, u(f.order.poses, %0)), setq(u, rest(first(%qo), .)), %r, case(1, match(get(%0/_POSE.ORDER), off), strcat(ljust(, 10), ljust(Pose Order tracking is currently [ansi(hr, OFF)]., 40), %r, ljust(, 10), ljust(Staff or the room owner can turn it on., 40)), ulocal(f.area-prevents-posealert, %0), strcat(ljust(, 10), ljust(This room is [ansi(hr, excluded)] from pose tracking., 40), %r%r, ljust(, 10), ljust(If it should be on%, please contact staff., 40)), not(%qo), strcat(ljust(, 10), ljust(No one has posed yet., 40), %r%r, ljust(, 10), The idle timeout is currently set to, %b, remove(secs2hrs(ulocal(f.get-pose-time, %0)), 0s)., %r%r, ljust(, 10), The scene style is currently set to, %b, switch(ulocal(f.get-scene-style, %0), f*, FIXED, REGULAR),., %r, space(16), +po/style for more information.), strcat(ljust(, 10), ljust(It is [ansi(hy, ulocal(f.get-name, %qu)'s)] turn to pose., 40), %r%r, ljust(, 10), ljust(%xhName%xn, 20), ljust(%xhLast%xn, 10), ljust(%xhIdle%xn, 10), %r, iter(%qo, strcat(setq(t, first(##, .)), setq(p, rest(##, .)), ljust(, 10), ljust(ulocal(f.get-name, %qP), 20), ljust(singletime(sub(secs(), %qt)), 10), setq(i, if(hasflag(%qp, connected), idle(%qp), sub(secs(), connleft(%qp)))), ljust(singletime(%qi), 10)),, %r), %r%r, ljust(, 10), The idle timeout is currently set to, %b, remove(secs2hrs(ulocal(f.get-pose-time, %0)), 0s)., %r%r, ljust(, 10), The scene style is currently set to, %b, switch(ulocal(f.get-scene-style, %0), f*, FIXED, REGULAR),., %r, space(16), +po/style for more information.)), if(ulocal(f.get-pose-alert-status, %1), strcat(%r%r, ljust(, 10), Your alert is currently set to, %b, case(ulocal(f.get-pose-alert-status, %1), 1, QUIET, 2, LOUD, OFF), ., %r), strcat(ljust(, 10), You do not have a pose alert set. See +poseorder/help. %r))), 0, %1)

+po

@@ TODO: Clean this up ^^^ right now it's very repetitive and doesn't use space well.

@@ Mistress command. Captures +poseorder(anything else).

&c.poseorder [v(d.pom)]=$^\+?poseorder([\s\S]+)?$:@pemit %#=[setq(0, secure(%1))][if(cand(strmatch(%q0, /h*), not(isowner(%L, %#))), u(disp.help), switch(%q0, , u(c.display.pose.order, loc(%#), %#), %b*, u(c.poseorder.switch.me, trim(%q0), %#), /hel*, u(disp.help), /clear, u(c.poseorder.clear.here, loc(%#), %#), /idle*, u(c.poseorder.idle.here, loc(%#), %#, trim(rest(%q0))), /style*, u(c.poseorder.style.here, loc(%#), %#, trim(rest(%q0))), /her* *, u(c.poseorder.switch.here, trim(rest(%q0)), loc(%#), %#), /exclude *, u(c.poseorder.exclude, trim(rest(%q0)), loc(%#), %#), /skip *, u(c.poseorder.skip, trim(rest(%q0)), loc(%#), %#), /skip, u(c.poseorder.skip, %N, loc(%#), %#), /remove, u(c.poseorder.remove, %#, loc(%#), %#), /leave, u(c.poseorder.remove, %#, loc(%#), %#), /remove *, u(c.poseorder.remove, trim(rest(%q0)), loc(%#), %#), u(.msg, Pose Order, Please see +poseorder/help.)))]

@set [v(d.pom)]/c.poseorder=regex

&c.+po [v(d.pom)]=$+po*:@break switch(%0, seorder*, 1, sebreak*, 1, 0); @force %#=[switch(%0, */*, +poseorder/[rest(%0, /)], %b*, +poseorder [trim(%0)], * *, +poseorder [rest(%0)], +poseorder)]

&c.+skip [v(d.pom)]=$+skip*:@force %#=+poseorder/skip%0;

&c.+leave [v(d.pom)]=$+leave:@force %#=+poseorder/leave;

&c.display.pose.order [v(d.pom)]=strcat(header(Whose turn is it? <POM>, %#), %r, u(display.pose.order, %0, %1), footer(+poseorder, %#), @@(Displays who is up and pose order))

&c.poseorder.switch.me [v(d.pom)]=strcat(setq(a, switch(%0, on, loud, q*, quiet, l*, loud, of*, off, error)), if(match(%qa, error), u(.msg, Pose Order, Error: Please choose 'on' 'quiet' 'loud' or 'off'), strcat(set(%1, _POSE.ALERT:[switch(%qA, loud, 2, quiet, 1, 0)]), u(.msg, Pose Order, Alert set to [capstr(%qa)]), @@(Pretty straight forward. loud = beep, quiet = no beep, off = nothing))))

&c.poseorder.clear.here [v(d.pom)]=strcat(wipe(%0/d.pose.*), iter(ulocal(f.order.poses, %0), settimer(rest(itext(0), .), pose-alerted, 0)), wipe(%0/d.oldpose.*), wipe(%0/d.pose-time), wipe(%0/d.pose-scene-style), wipe(%0/d.removed.players), if(t(%1), trigger(me/tr.remit-or-pemit, %0, u(.msg, Pose Order, [ulocal(f.get-name, %1)] has cleared the pose order.), %1)))

&c.poseorder.idle.here [v(d.pom)]=if(ulocal(f.area-prevents-posealert, %0), ulocal(.msg, Pose Order, This area does not use pose order.), if(not(t(%2)), u(.msg, Pose Order, The current idle time is [remove(secs2hrs(ulocal(f.get-pose-time, %0)), 0s)]. After that time%, players will be automatically removed from the pose order until they repose.), if(not(isint(%2)), u(.msg, Pose Order, The idle time must be an integer.), if(cand(t(setr(M, v(d.pose-time-min))), t(setr(X, v(d.pose-time-max))), t(setr(2, switch(%2, <4, mul(%2, 3600), <60, mul(%2, 60), %2))), cor(lt(%q2, %qM), gt(%q2, %qX))), u(.msg, Pose Order, The idle time must be between [remove(secs2hrs(%qM), 0s)] and [remove(secs2hrs(%qX), 0s)]. It looks like you entered [remove(secs2hrs(%q2), 0s)].), strcat(set(%0, d.pose-time:%q2), trigger(me/tr.remit-or-pemit, %0, u(.msg, Pose Order, [ulocal(f.get-name, %1)] has set the idle time for pose order to [remove(secs2hrs(%q2), 0s)]. Players who idle longer without posing will be removed from the pose order until they pose back in. Anyone can change this value with +poseorder/idle <#>.), %1))))))

&c.poseorder.style.here [v(d.pom)]=if(ulocal(f.area-prevents-posealert, %0), ulocal(.msg, Pose Order, This area does not use pose order.), if(not(t(%2)), u(.msg, Pose Order, The current pose style is [switch(ulocal(f.get-scene-style, %0), fixed, FIXED. Players will be notified when [ulocal(f.calc-max-poses, ulocal(f.order.poses, %0))] players have posed%, and will not be notified again until they pose., REGULAR. Players will be notified when their turn comes up in pose order.)]), strcat(set(%0, d.pose-scene-style:[switch(%2, f*, fixed, regular)]), trigger(me/tr.remit-or-pemit, %0, u(.msg, Pose Order, [ulocal(f.get-name, %1)] has set the scene style for pose order to [switch(ulocal(f.get-scene-style, %0), fixed, FIXED. Players will be notified when [ulocal(f.calc-max-poses, ulocal(f.order.poses, %0))] players have posed%, and will not be notified again until they pose., REGULAR. Players will be notified when their turn comes up in pose order.)] Anyone can change this value with +poseorder/style <fixed or regular>.), %1))))

&c.poseorder.switch.here [v(d.pom)]=strcat(setq(a, switch(%0, on, on, of*, off, error)), if(isowner(%1, %2), @@(If you are staff or owner leave variable as is else change it to trigger error msg), setq(a, error2)), case(%qa, error, u(.msg, Pose Order, Error: Please choose 'on' or 'off'), error2, u(.msg, Pose Order, Error: You may only change this setting for rooms you own.), strcat(set(%1, _POSE.ORDER:%qa), trigger(me/tr.remit-or-pemit,  %1, [u(.msg, Pose Order, Pose order tracking for this room is now [ucstr(%qa)].)]), @@(Can only accept on or off. Must be staff or room owner. remit sends a message to whole room.))))

&c.poseorder.exclude [v(d.pom)]=strcat(setq(a, if(match(%0, here), %1, %0)), @@(If here grab that loc else process the dbref), setq(d, u(d.exclude.rooms)), case(1, not(isstaff(%2)), u(.msg, Pose Order, Only staff may exclude rooms. If you wish to exclude a room you own%, try: +poseorder/here off), match(%qa, list), strcat(@@(Display what rooms are currently excluded.), header(Excluded Rooms, %#), %r, formattext(strcat(%r, center(If this is empty%, it means there are none., getremainingwidth(%#)), %r, center(Please note%, this does not find rooms set with '/here off'., getremainingwidth(%#)), %r, iter(%qd, center(strcat(name(##), %b, <##>), getremainingwidth(%#)), , %r)), 0, %#), %r, footer(+poseorder/exclude list, %#)), match(%qa, !*), strcat(setq(r, edit(%qa, !, )), if(match(%qd, %qr), strcat(set(%!, d.exclude.rooms:[remove(%qd, %qr)]), u(.msg, Pose Order, Removing [name(%qr)] <%qr> from exclude rooms list.), @@(if you have a ! in it, removes. If you do !#303 #304 should remove both I guess)), u(.msg, Pose Order, No such dbref found on the exclude rooms list.))), hastype(%qa, room), if(match(%qd, %qa), u(.msg, Pose Order, [name(%qa)] <%qa> is already on exclude rooms list.), strcat(set(%!, d.exclude.rooms:[edit(%qd, $, %b%qa)]), u(.msg, Pose Order, Adding [name(%qa)] <%qa> to exclude rooms list.), @@($ keeps the existing list, adds in a space + the room))), u(.msg, Pose Order, You have not entered a valid room #dbref.)))

@@ Check if target is a player, check if they're on the list, process a pose 

@@ u(c.poseorder.skip, trim(rest(%q0)), loc(%#), %#)

&c.poseorder.skip [v(d.pom)]=squish(trim(strcat(setq(p, ulocal(f.find-player, %0, %2)), switch(0, t(ulocal(f.find-player, %qp, %2)), u(.msg, Pose Order, %0 is not a valid player.), strmatch(ulocal(f.order.poses, %1), *%qp*), u(.msg, Pose Order, [ulocal(f.get-name, %qP)] has not posed in this room.), strcat(ulocal(f.poseorder, %qp), trigger(me/tr.remit-or-pemit, %1, u(.msg, Pose Order, [ulocal(f.get-name, %2)] [if(strmatch(%qP, %2), skips [poss(%2)] pose, skips [ulocal(f.get-name, %qP)])] this round.), %2))))))

@@ Remove a person from poseorder. This will actually process that they posed
@@ and then remove them, so it properly alerts the next person.

&c.poseorder.remove [v(d.pom)]=squish(trim(strcat(setq(p, ulocal(f.find-player,  %0, %2)), switch(0, t(ulocal(f.find-player,  %qp, %2)), u(.msg, Pose Order, %0 is not a valid player.), strmatch(ulocal(f.order.poses, %1), *%qp*), u(.msg, Pose Order, [ulocal(f.get-name, %qP)] has not posed in this room.), strcat(trigger(me/tr.remit-or-pemit,  %1, u(.msg, Pose Order, [ulocal(f.get-name, %2)] has [if(strmatch(%2, %qP), left the pose order, removed [ulocal(f.get-name, %qP)] from the pose order)]. Pose back in when you're ready.), %2), u(.msg, Pose Order, You remove [if(strmatch(%qP, %2), yourself, ulocal(f.get-name, %qP))] from the pose order. Pose again to rejoin.), iter(lattr(%1/d.pose.*), if(match(last(get(%1/##), .), %qp), wipe(%1/##), @@(do nothing))), trigger(%!/trig.pose.alert, %1))))))

&disp.help [v(d.pom)]=strcat(header(The Pose Order Machine <POM> Help File, %#), %r, formattext(strcat(The pose order machine tracks poses and alerts you when it's your turn., %r%r, %xhCommands%xn, %r%r, * +poseorder : display the current pose order, %r, * +poseorder <quiet/loud/off> : Turn it on/off%, set it loud/quiet., %r, * +poseorder/clear : Clears the current pose order., %r, * +poseorder/here <on/off> : The Owner can turn off poseorder for the room., %r, * +poseorder/exclude <here/dbref/!dbref/list> : Exclude room from pose order., %r, * +poseorder/skip <name> : Skips a person., %r, * +poseorder/remove <name> : Removes a person from the poseorder, %r, * +poseorder/help : This right here., %r%r, This whole thingy was made by skew., %r%r, Extra commands by Wrench:, %r%r, * +po - short version of +poseorder, %r, * +skip - skip yourself in pose order, %r, * +leave - leave pose order until you choose to pose again, %r, * +po/idle <#> : Set the timeout to between [remove(secs2hrs(v(d.pose-time-min)), 0s)] and [remove(secs2hrs(v(d.pose-time-max)), 0s)]%, default [remove(secs2hrs(v(d.pose.time)), 0s)], %r, * +po/style <fixed or regular> - set the scene style:, %r%t, Regular: Reminds you when your name comes up in the order., %r%t, Fixed:, space(3), Reminds you when enough people in the room have posed., %r%t, space(9), Useful for parties., %r%r, NOTE: Pose alerts will not show when only 2 players are playing unless you set your alerts to LOUD.), 0, %#), %r, footer(+poseorder/help, %#), @@(Displays who is up and pose order))
