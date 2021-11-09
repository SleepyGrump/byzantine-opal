/*
!!Install "Centralize column widths" first!! If you don't, your column widths will be off and the lines will wrap.

This mod converts the following job fields to first display the interval, THEN the date:
	- Creation date / Opened
	- Modified on / Modified
	- The "comment added" date
	- Action dates

In fact, the only date that's still a date is the due date, and even there, I got rid of the full date in favor of the short date.

I did leave all dates in the logger as they were originally formatted, since those are less for display purposes and more for documentation.

The display fields had to be widened to contain the intervals.

This code relies on the interval() global function in this repo.
*/

&FN_INTERVAL_THEN_DATE [v(JOB_VA)]=cat(interval(%0), ago on, u(%va/FN_SHORT_DATE, convsecs(%0)))

&WIDTH_C [v(JOB_VA)]=12

&WIDTH_M [v(JOB_VA)]=12

&DISPLAY_C [v(JOB_VA)]=[u(%va/FN_STREXACT, extract(u(%vA/FN_INTERVAL_THEN_DATE, get(%0/OPENED_ON)), 1, 3), default(%#/JOBSWIDTH_C, v(WIDTH_C)))]

&DISPLAY_M [v(JOB_VA)]=[u(%va/FN_STREXACT, extract(u(%vA/FN_INTERVAL_THEN_DATE, get(%0/MODIFIED_ON)), 1, 3), default(%#/JOBSWIDTH_M, v(WIDTH_M)))]

&DEFAULT_BANNER [v(JOB_VA)]=[setq(0, %0)][setq(x, u(%va/FN_ITEMIZE, map(MAP_NAME, get(%q0/OPENED_BY), %b, |), |))][setq(y, u(%va/FN_ITEMIZE, map(MAP_NAME, get(%q0/TAGGED_FOR), %b, |), |))][ljust([rjust(ansi(hc, Bucket:), 10)]%b[u(%va/FN_BUCKETNAME, %q0)], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(hc, Due On:), 12)]%b[ifelse(get(%q0/DUE_ON), ifelse(gt(secs(), get(%q0/DUE_ON)), OVERDUE!, u(%va/FN_SHORT_DATE, convsecs(get(%q0/DUE_ON)))), -)]%r[ljust([rjust(ansi(hc, Title:), 10)]%b[get(%q0/TITLE)], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(hc, Status:), 12)]%b[switch(get(%q0/PRIORITY), 1, Green, 2, Yellow, 3, Red)]%b%([last(get(%va/STATUS_[get(%q0/STATUS)]), |)]%)%r[ljust([rjust(ansi(hc, Opened On:), 10)] [u(%vA/FN_INTERVAL_THEN_DATE, get(%q0/OPENED_ON))], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(hc, Assigned To:), 12)]%b[ifelse(isdbref(get(%q0/ASSIGNED_TO)), name(get(%q0/ASSIGNED_TO)), Nobody)]%r[rjust(ansi(hc, Opened By:), 10)]%b%qx[ifelse(words(%qy), %r[rjust(ansi(hc, Tagged:), 10)]%b%qy,)]

&DEFAULT_MYBANNER [v(JOB_VA)]=[setq(0, %0)][setq(x, u(%va/FN_ITEMIZE, map(MAP_NAME, get(%q0/OPENED_BY), %b, |), |))][ljust([rjust(ansi(hc, Bucket:), 10)]%b[u(%va/FN_BUCKETNAME, %q0)], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(hc, Due On:), 12)]%b[ifelse(get(%q0/DUE_ON), ifelse(gt(secs(), get(%q0/DUE_ON)), OVERDUE!, u(%va/FN_SHORT_DATE, convsecs(get(%q0/DUE_ON)))), -)]%r[ljust([rjust(ansi(hc, Title:), 10)]%b[get(%q0/TITLE)], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(hc, Assigned To:), 12)]%b[ifelse(isdbref(get(%q0/ASSIGNED_TO)), name(get(%q0/ASSIGNED_TO)), Nobody)]%r[ljust([rjust(ansi(hc, Opened On:), 10)]%b[u(%vA/FN_INTERVAL_THEN_DATE, get(%q0/OPENED_ON))], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(hc, Status:), 12)]%b[switch(get(%q0/PRIORITY), 1, Green, 2, Yellow, 3, Red)]%b%r[rjust(ansi(hc, Opened By:), 10)]%b%qx

&DEFAULT_READ [v(JOB_VA)]=[repeat(-, u(FN_FLEXWIDTH, 79))]%r[ifelse(u(%va/EDIT_ACCESS, %#), [ansi(h, %[)][ifelse(and(or(u(%va/IS_PUBLISHED, %1), switch(extract(get(%1/%0), 3, 1, |), u(%1/OPENED_BY), 1, 0), hasflag(%1/%0, no_inherit)), u(%va/IS_PUBLIC, %1)), ansi(hc, [rest(%0, _)]+), ansi(hc, [rest(%0, _)]-))][ansi(h, %])]%b,)][ansi(h, [extract(get(%1/%0), 4, 1, |)]%badded%b[ulocal(FN_INTERVAL_THEN_DATE, extract(get(%1/%0), 2, 1, |))]:%b)][edit(last(get(%1/%0), |), @@PIPE@@, |)]

&PLETTER_APR [v(JOB_VC)]=[space(10)][ansi(h, Job:)] #[last(name(%0))]%r[space(8)][ansi(h, Title:)] [get(%0/TITLE)]%r[space(4)][ansi(h, Opened By:)] [u(%va/FN_PLAYERLIST, %0)]%r[space(4)][ansi(h, Opened On:)] [u(%vA/FN_INTERVAL_THEN_DATE, get(%0/OPENED_ON))]%r%b[ansi(h, Completed By:)] [name(%2)]%r%b[ansi(h, Completed On:)] [time()]%r%r[last(get(%0/COMMENT_1), |)]%r[repeat(-, 78)]%r[ansi(h, Comments from [name(%2)]:)] %3%r%rThis job was approved.

&PLETTER_DNY [v(JOB_VC)]=[space(10)][ansi(h, Job:)] #[last(name(%0))]%r[space(8)][ansi(h, Title:)] [get(%0/TITLE)]%r[space(4)][ansi(h, Opened By:)] [u(%va/FN_PLAYERLIST, %0)]%r[space(4)][ansi(h, Opened On:)] [u(%vA/FN_INTERVAL_THEN_DATE, get(%0/OPENED_ON))]%r%b[ansi(h, Completed By:)] [name(%2)]%r%b[ansi(h, Completed On:)] [time()]%r%r[last(get(%0/COMMENT_1), |)]%r[repeat(-, 78)]%r[ansi(h, Comments from [name(%2)]:)] %3%r%rThis job was denied.

&CMD_JOB/ACT [v(JOB_GO)]=$+job/act *:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][or(u(%va/FN_STAFFALL, %#), u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0))]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no job by that name. Please type '+jobs/all' for all jobs or '+jobs/<type>' to list by type.}, 110*, {@pemit %#=You do not have access to that job.}, {@pemit %#=[u(%va/FN_HEADER, View Job Number %0)]%r[ulocal(%va/FN_BANNER, %q0)]%r[u(%va/FN_BREAK)];@dolist sortby(%va/SORTBY_COMMENTS, lattr(%q0/COMMENT_*))={@pemit %#=[u(%vA/FN_INTERVAL_THEN_DATE, extract(get(%q0/##), 2, 1, |))]%b[first(get(%q0/##), |)]%b[ljust(u(%va/FN_STRTRUNC, extract(get(%q0/##), 4, 1, |), 15), 15)]%b[ljust(u(%va/FN_STRTRUNC, u(%va/fn_trim, edit(edit(edit(last(get(%q0/##), |), @@PIPE@@, |), %r, %b), %t, %b), b), 35), 35)]};@wait 0={@pemit %#=[u(%va/FN_FOOTER)]};}
