/*
!!Install "Centralize column widths" first!! Otherwise your column widths will be off.

New skin for +jobs.

Features:
	- Slightly more customizable (yellow doesn't HAVE to be yellow)
	- Uses the built-in header/divider/footer/themecolors functions of this repo.
	- Centralize the colors so that you can play with them a bit easier.
	- Shows most dates as interval, then date. For full effect, use the "Show dates as interval, then date" mod.

*/

@@ Shrunk to allow some more room.
&WIDTH_JOB [v(JOB_VA)]=3

@@ If you don't use the "Make bucket names longer" mod, this should be a 5.
&WIDTH_B [v(JOB_VA)]=10

@@ I like a short "Opened by" column.
&WIDTH_O [v(JOB_VA)]=9

@@ Date function for interval display
&FN_INTERVAL_THEN_DATE [v(JOB_VA)]=cat(interval(%0), ago on, u(%va/FN_SHORT_DATE, convsecs(%0)))

@@ Set the default skin to the GAME skin
&FN_SKIN [v(JOB_VA)]=[setq(z, default(%#/JOBSKIN, GAME))][ifelse(and(u(FN_HASATTR, me, %qz_SKIN), u(FN_HASATTR, me, %qz_%0)), u(%qz_%0, %1, %2, %3, %4), u(DEFAULT_%0, %1, %2, %3, %4))]

&GAME_SKIN [v(JOB_VA)]=1

@@ The "overdue" and "top priority" color.
&GAME_RED [v(JOB_VA)]=hr

@@ The "almost overdue" color.
&GAME_YELLOW [v(JOB_VA)]=hy

@@ Default jobs value is hg.
@@ I prefer to have non-urgent jobs be non-highlighted.
&GAME_GREEN [v(JOB_VA)]=

@@ Default jobs value is hr.
@@ IMHO "new" should be a "hey cool" thing not a "urgent" thing, so I went with green.
&GAME_NEW [v(JOB_VA)]=hg

@@ This is the color of the headers of +jobs/+myjobs/etc.
&GAME_TITLE_COLOR [v(JOB_VA)]=first(themecolors())

&GAME_BANNER [v(JOB_VA)]=[setq(0, %0)][setq(x, u(%va/FN_ITEMIZE, map(MAP_NAME, get(%q0/OPENED_BY), %b, |), |))][setq(y, u(%va/FN_ITEMIZE, map(MAP_NAME, get(%q0/TAGGED_FOR), %b, |), |))][ljust([rjust(ansi(ulocal(GAME_TITLE_COLOR), Bucket:), 10)]%b[u(%va/FN_BUCKETNAME, %q0)], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(ulocal(GAME_TITLE_COLOR), Due On:), 12)]%b[ifelse(get(%q0/DUE_ON), ifelse(gt(secs(), get(%q0/DUE_ON)), OVERDUE!, u(%vA/FN_SHORT_DATE, convsecs(get(%q0/DUE_ON)))), -)]%r[ljust([rjust(ansi(ulocal(GAME_TITLE_COLOR), Title:), 10)]%b[get(%q0/TITLE)], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(ulocal(GAME_TITLE_COLOR), Status:), 12)]%b[switch(get(%q0/PRIORITY), 1, Green, 2, Yellow, 3, Red)]%b%([last(get(%va/STATUS_[get(%q0/STATUS)]), |)]%)%r[ljust([rjust(ansi(ulocal(GAME_TITLE_COLOR), Opened On:), 10)] [u(%vA/FN_INTERVAL_THEN_DATE, get(%0/OPENED_ON))], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(ulocal(GAME_TITLE_COLOR), Assigned To:), 12)]%b[ifelse(isdbref(get(%q0/ASSIGNED_TO)), name(get(%q0/ASSIGNED_TO)), Nobody)]%r[rjust(ansi(ulocal(GAME_TITLE_COLOR), Opened By:), 10)]%b%qx[ifelse(words(%qy), %r[rjust(ansi(ulocal(GAME_TITLE_COLOR), Tagged:), 10)]%b%qy,)]

&GAME_BREAK [v(JOB_VA)]=divider(stripansi(%0), %#)

&GAME_BUCKETHEADER [v(JOB_VA)]=[u(FN_HEADER, Bucket List)]%r[ifelse(u(%va/FN_WIZONLY, %#), [ansi(ulocal(GAME_TITLE_COLOR), %b%b[ljust(Name, v(WIDTH_B))]%b%b[ljust(Flags, 7)]%b%b[ljust(Description, u(FN_FLEXWIDTH, 28))][rjust(#, 3)]%b[rjust(Pct, 3)]%b%bC%b%bA%b%bD%b%bDue%b%bARTS)], [ansi(ulocal(GAME_TITLE_COLOR), %b%b[ljust(Name, v(WIDTH_B))]%b%b[ljust(Description, u(FN_FLEXWIDTH, 43))]%b[rjust(Viewing, 20)])])]%r[u(FN_BREAK)]

&GAME_BUCKETLIST [v(JOB_VA)]=[ifelse(u(%va/FN_WIZONLY, %#), %b%b[ljust(name(%0), v(WIDTH_B))]%b%b[ifelse(u(%va/FN_MONITORCHECK, %0, %#), V, -)][ifelse(u(%va/IS_HIDDEN, %0), H, -)][ifelse(u(%va/IS_LOCKED, %0), ifelse(u(%va/FN_HASATTRP, %0, CHECKOUT), C, L), -)][ifelse(u(%va/IS_TAGGED, %0), T, -)][ifelse(u(%va/IS_PUBLIC, %0), M, -)][ifelse(u(%va/IS_PUBLISHED, %0), P, -)][ifelse(u(%va/IS_SUMMARY, %0), S, -)]%b%b[u(%va/FN_STREXACT, get(%0/DESC), u(FN_FLEXWIDTH, 28))][rjust(words(remove(children(%0), #-1)), 3)][rjust(mul(round(fdiv(words(remove(children(%0), #-1)), max(1, words(lcon(%va)))), 2), 100)%%, 4)]%b[rjust(u(%va/FN_FIND-BBNUM, get(%0/POST_COMPLETE)), 2)]%b[rjust(u(%va/FN_FIND-BBNUM, get(%0/POST_APPROVE)), 2)]%b[rjust(u(%va/FN_FIND-BBNUM, get(%0/POST_DENY)), 2)][rjust(default(%0/TURNAROUND, 0), 5)][rjust([ifelse(u(%va/FN_HASATTR, %0, STAT_ART), [round(fdiv(fdiv(first(get(%0/STAT_ART)), rest(get(%0/STAT_ART))), 86400), 0)]d, -)], 6)], %b%b[ljust(name(%0), v(WIDTH_B))]%b%b[u(%va/FN_STREXACT, get(%0/DESC), u(FN_FLEXWIDTH, 43))]%b[rjust(ifelse(u(%va/FN_MONITORCHECK, %0, %#), Yes, -), 20)])]

&GAME_FLAGS [v(JOB_VA)]=[ifelse(u(me/IS_LOCKED, %0), u(me/FN_FLAG, ifelse(u(%va/FN_HASATTRP, %0, CHECKOUT), CHECKED OUT, LOCKED), ulocal(GAME_RED)),)][ifelse(u(me/IS_PUBLIC, %0), u(me/FN_FLAG, Myjobs),)][ifelse(u(me/IS_PUBLISHED, %0), u(me/FN_FLAG, Published),)]

&GAME_FOOTER [v(JOB_VA)]=footer(stripansi(%0), %#)

&GAME_HEADER [v(JOB_VA)]=header(stripansi(%0), %#)

&GAME_JOBLIST [v(JOB_VA)]=[setq(j, secure(ifelse(u(%va/FN_HASATTRP, %1, JOBS), lcstr(mid(get(%1/JOBS), 0, 20)), get(%va/JOBS_DEFAULT))))][setq(1, ifelse(get(%0/DUE_ON), ifelse(gt(secs(), get(%0/DUE_ON)), ulocal(GAME_RED), switch(get(%0/PRIORITY), 1, ulocal(GAME_GREEN), 2, ulocal(GAME_YELLOW), 3, ulocal(GAME_RED), g)), switch(get(%0/PRIORITY), 1, ulocal(GAME_GREEN), 2, ulocal(GAME_YELLOW), 3, ulocal(GAME_RED))))]%b%b[ifelse(u(FN_ISNEW, %0, %1), [ansi(ulocal(GAME_NEW), *)], %b)]%b[ansi(%q1, [rjust([last(name(%0))], v(WIDTH_JOB))]%b[iter(lnum(strlen(%qj)), [u(%va/DISPLAY_[mid(%qj, ##, 1)], %0, %1)])])]

&GAME_JOBSHEADER [v(JOB_VA)]=[u(FN_HEADER, Anomaly Jobs [u(VERSION)])]%r[setq(j, [secure(switch(u(%va/FN_HASATTRP, %0, JOBS), 1, lcstr(mid(get(%0/JOBS), 0, 20)), u(JOBS_DEFAULT)))])][ansi(ulocal(GAME_TITLE_COLOR), %b%b*%b[ljust(Job, v(WIDTH_JOB))]%b[iter(lnum(strlen(%qj)), u(HEADER_[mid(%qj, ##, 1)]))])]%r[u(FN_BREAK)]

&GAME_MYJOBLIST [v(JOB_VA)]=%b%b[ifelse(u(FN_ISNEW, %0, %1), [ansi(ulocal(GAME_NEW), *)], %b)]%b[setq(j, TDAS)][ansi(n, [rjust([last(name(%0))], v(WIDTH_JOB))]%b[iter(lnum(strlen(%qj)), u(DISPLAY_[mid(%qj, ##, 1)], %0, %1))])]

&GAME_MYJOBSHEADER [v(JOB_VA)]=[u(FN_HEADER, Anomaly Jobs [u(VERSION)])]%r[setq(j, TDAS)][ansi(ulocal(GAME_TITLE_COLOR), ljust(%b%b*%b[ljust(Job, v(WIDTH_JOB))]%b[iter(lnum(strlen(%qj)), u(HEADER_[mid(%qj, ##, 1)]))], [u(FN_FLEXWIDTH, 79)]))]%r[u(FN_BREAK)]

&GAME_MYBANNER [v(JOB_VA)]=[setq(0, %0)][setq(x, u(%va/FN_ITEMIZE, map(MAP_NAME, get(%q0/OPENED_BY), %b, |), |))][ljust([rjust(ansi(ulocal(GAME_TITLE_COLOR), Bucket:), 10)]%b[u(%va/FN_BUCKETNAME, %q0)], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(ulocal(GAME_TITLE_COLOR), Due On:), 12)]%b[ifelse(get(%q0/DUE_ON), ifelse(gt(secs(), get(%q0/DUE_ON)), OVERDUE!, u(%vA/FN_SHORT_DATE, convsecs(get(%q0/DUE_ON)))), -)]%r[ljust([rjust(ansi(ulocal(GAME_TITLE_COLOR), Title:), 10)]%b[get(%q0/TITLE)], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(ulocal(GAME_TITLE_COLOR), Assigned To:), 12)]%b[ifelse(isdbref(get(%q0/ASSIGNED_TO)), name(get(%q0/ASSIGNED_TO)), Nobody)]%r[ljust([rjust(ansi(ulocal(GAME_TITLE_COLOR), Opened On:), 10)]%b[u(%vA/FN_INTERVAL_THEN_DATE, get(%0/OPENED_ON))], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(ulocal(GAME_TITLE_COLOR), Status:), 12)]%b[switch(get(%q0/PRIORITY), 1, Green, 2, Yellow, 3, Red)]%b%r[rjust(ansi(ulocal(GAME_TITLE_COLOR), Opened By:), 10)]%b%qx

&GAME_MYSUMMARY [v(JOB_VA)]=%r[u(FN_BREAK, MySummary)]%r[u(parent(%0)/MYSUMMARY, %0)]

&GAME_READ [v(JOB_VA)]=[divider(, %#)]%r[ifelse(u(%va/EDIT_ACCESS, %#), [ansi(h, %[)][ifelse(and(or(u(%va/IS_PUBLISHED, %1), switch(extract(get(%1/%0), 3, 1, |), u(%1/OPENED_BY), 1, 0), hasflag(%1/%0, no_inherit)), u(%va/IS_PUBLIC, %1)), ansi(ulocal(GAME_TITLE_COLOR), [rest(%0, _)]+), ansi(ulocal(GAME_TITLE_COLOR), [rest(%0, _)]-))][ansi(h, %])]%b,)][ansi(h, [extract(get(%1/%0), 4, 1, |)]%badded%b[u(%vA/FN_INTERVAL_THEN_DATE, extract(get(%1/%0), 2, 1, |))]:%b)][edit(last(get(%1/%0), |), @@PIPE@@, |)]

&GAME_STAFFSUM [v(JOB_VA)]=%r[divider(, %#)]%r[rjust(ansi(ulocal(GAME_TITLE_COLOR), DB#:), 10)] %0[space(10)][rjust(ansi(ulocal(GAME_TITLE_COLOR), Comments:), 10)] [setr(z, words(lattr(%0/COMMENT_*)))]%r%r[rjust(ansi(ulocal(GAME_TITLE_COLOR), Players:), 10)] %(Players contributing to this job%)%r[setq(y, setunion(iter(lattr(%0/COMMENT_*), extract(get(%0/##), 4, 1, |), %b, |),, |))][u(%va/fn_columns, %qy, 20, |, 11)][ifelse(u(%va/FN_HASATTR, %0, LIST_READERS), %r[rjust(ansi(ulocal(GAME_TITLE_COLOR), Readers:), 10)]%b%(Players who have read this job in the past%)%r[setq(z, iter(get(%0/LIST_READERS), first(##, |)))][u(%va/fn_columns, map(%va/MAP_NAME, %qz, %b, |), 20, |, 11)],)]%r[rjust(ansi(ulocal(GAME_TITLE_COLOR), Stats:), 10)]%r[u(%va/fn_columns, iter(ifelse(u(%va/FN_HASATTR, %0, LIST_STATS), sort(get(%0/LIST_STATS)),), [first(##, |)]%b[last(##, |)], %b, |), 20, |, 11)]%r

&GAME_SUMMARY [v(JOB_VA)]=%r[divider(, %#)]%r[u(parent(%0)/SUMMARY, %0)]

@@ The following are not actually "skin" attributes, but I'm changing them anyway because I hate the bright cyan, red, yellow, etc.

&REPORT_ARTS [v(JOB_VA)]=[iter(sortby(%va/SORTBY_NAME, lcon(%vc)), [ifelse(u(%va/FN_HASATTR, ##, STAT_ART), u(%va/FN_TIME, round(fdiv(first(get(##/STAT_ART)), rest(get(##/STAT_ART))), 0)), [rjust(-, 11)])]%b[ljust(ansi(ulocal(GAME_TITLE_COLOR), [name(##)]), 20)], %B, %R)]%R[rjust(u(%va/FN_TIME, round(fdiv(first(default(%vc/STAT_ART, 0 0)), rest(default(%vc/STAT_ART, 0 1))), 0)), 11)]%b[ansi(hy, Total ART)]%r[center(Average Resolution Times by Bucket, u(%va/FN_FLEXWIDTH, 79))]

&REPORT_STATS [v(JOB_VA)]=[rjust(ansi(ulocal(GAME_TITLE_COLOR), Install:), 20)]%b[get(%va/INSTALL_DATE)]%r[rjust(ansi(ulocal(GAME_TITLE_COLOR), Version:), 20)]%bAnomaly Jobs [get(%va/VERSION)][space(5)]%r[rjust(ansi(ulocal(GAME_TITLE_COLOR), Release:), 20)]%b[get(%va/RELEASE)]%r[rjust(ansi(ulocal(GAME_TITLE_COLOR), Memory:), 20)]%b[setr(a, fold(%va/FOLD_ADD, iter(setr(b, [num(me)] [loc(me)] %vb %vc [lcon(%vc)] [lcon(me)]), objmem(##))))]%b%([round(fdiv(%qa, 1024), 1)]k in [words(%qb)] objects%)%r[rjust(ansi(ulocal(GAME_TITLE_COLOR), Open Jobs:), 20)]%b[words(remove(lcon(%va), #-1))]%r[rjust(ansi(ulocal(GAME_TITLE_COLOR), Capacity:), 20)]%b[u(%va/FN_PCT)]%% Full%r[rjust(ansi(ulocal(GAME_TITLE_COLOR), Next Job:), 20)]%b[inc(u(%va/JOBS_NUM))]%r[rjust(ansi(ulocal(GAME_TITLE_COLOR), Buckets:), 20)]%b[words(lcon(%vc))]%r[rjust(ansi(ulocal(GAME_TITLE_COLOR), Opened:), 20)]%b[last(grab(get(%va/LIST_STATS), CRE|*), |)][setq(x, iter(APR DNY COM DEL, grab(get(%va/LIST_STATS), ##|*)))][setq(y, map(%va/MAP_ACTIONS, %qx))]%r[rjust(ansi(ulocal(GAME_TITLE_COLOR), Closed:), 20)]%b[fold(%va/FOLD_ADD, %qy, 0)]%r[rjust(ansi(ulocal(GAME_TITLE_COLOR), Actions To Date:), 20)]%b[fold(FOLD_ADD, map(MAP_ACTIONS, v(LIST_STATS)), 0)]%r[rjust(ansi(ulocal(GAME_TITLE_COLOR), ART:), 20)]%b[u(%va/FN_ART, %vc)][space(10)] ART=Average Resolution Time%r[rjust(ansi(ulocal(GAME_TITLE_COLOR), REQ ART:), 20)]%b[u(%va/FN_ART, u(%va/FN_FIND-BUCKET, REQ))][space(18)]DD:HH:MM:SS%r[rjust(ansi(ulocal(GAME_TITLE_COLOR), CODE ART:), 20)]%b[u(%va/FN_ART, u(%va/FN_FIND-BUCKET, CODE))]%r[rjust(ansi(ulocal(GAME_TITLE_COLOR), TPS ART:), 20)]%b[u(%va/FN_ART, u(%va/FN_FIND-BUCKET, TPS))]%r[rjust(ansi(ulocal(GAME_TITLE_COLOR), BUILD ART:), 20)]%b[u(%va/FN_ART, u(%va/FN_FIND-BUCKET, BUILD))]%r
