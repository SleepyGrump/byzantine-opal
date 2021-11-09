/*
Picture this: you're a staffer, but you're currently logged in as a player. You put a +request in last week, you want to see how it's going. What do you type? +jobs. What do you get? Permission denied. Annoying, isn't it? Of course you meant '+myjobs' but it's extra characters and harder to remember, etc, etc...

These commands override the default +jobs "Permission denied" messages to instead call the +myjobs version of the command. No more Permission denied, just working commands.

Only works for:
	+jobs
	+job *
	+jobs/catchup
	+jobs/catchup *
	+job/last <#>=<number of comments>
	+job/add <#>=<comment>
	+job/mail <#>=<comment>
	+job/help <#>

To be considered for addition to this list (but not included for now):

	+job/create - didn't include because I can't quite see how to keep the bucket info, even using JRS, if the bucket isn't public for creation.

	+job/tag - not sure letting players tag folks is good? Also, tags are weird. They're automatically removed with every comment so that's kinda pointless (or I just don't see the use).

	+job/esc - I'm not sure player escalation is desired and there's no +myjobs version so I would have to write it.

	+job/new <#> - there's no +myjobs version of this and the logic is a bit convoluted. Not ready to write it myself.
*/

&CMD_JOBS/SELECT [v(JOB_GO)]=$+jobs/select *:@switch [u(%va/HAS_ACCESS, %#)][setq(0, before(lcstr(%0), sort=))][setq(0, u(%va/FN_INFIX2POSTFIX, map(%va/MAP_JOBSELECT, u(%va/FN_TOKENLIST, %q0))))][not(strmatch(%q0, *#-1 MISMATCHED PARENS*))][not(strmatch(%q0, *#-1 SYNTAX ERROR*))][setq(9, u(%va/FN_TRIM, after(lcstr(%0), sort=)))][ifelse(setr(8, strmatch(%q9, -*)), setq(9, mid(%q9, 1, dec(strlen(%q9)))),)][setq(9, ifelse(strlen(%q9), %q9, jobnum))][u(%va/FN_HASATTRP, %va, SORTBY_%q9)][setq(1, filter(%va/FIL_GOING, lcon(%va)))][u(%va/FN_S-INIT)][map(%va/MAP_PARSESTACK, %q0)][setq(7, filter(%va/FIL_JOBSELECT, ifelse(%q8, revwords(sortby(%va/SORTBY_%q9, u(%va/FN_S-PEEK))), sortby(%va/SORTBY_%q9, u(%va/FN_S-PEEK)))))]=0*, { @force %#=+myjobs; }, 10*, @pemit %#=Mismatched parentheses., 110*, @pemit %#=Syntax error., 1110, @pemit %#=Invalid sort type., {@pemit %#=[u(%va/FN_JOBSHEADER, %#)];@dolist %q7=@pemit %#=[u(%va/FN_JOBLIST, ##, %#)];@wait 0=@pemit %#=[u(%va/FN_FOOTER, * Denotes New Activity)]}

&CMD_JOB/VIEW [v(JOB_GO)]=$+job *:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)]=0*, { @force %#=+myjob %0; }, 10*, {@pemit %#=There is no job by that name. Please type '[ansi(h, +jobs/all)]' for all jobs or '[ansi(h, +jobs/list <bucket>)]' to list by bucket.}, 110*, {@pemit %#=You do not have access to that job.}, {@pemit %#=[u(%va/FN_READERS, %q0, %#, 1)][u(%va/FN_HEADER, View [name(%q0)])]%r[ulocal(%va/FN_BANNER, %q0, %#)][ifelse(u(%va/FN_HASATTRP, %q0, SUMMARY), [ulocal(%va/FN_SUMMARY, %q0, %#)],)];@dolist [filter(%va/FIL_COMMENTS, sortby(%va/SORTBY_COMMENTS, lattr(%q0/COMMENT_*)))]={@pemit %#=[u(%va/FN_READJOB, ##, %q0)]};&TAGGED_FOR %q0=[ifelse(default(%#/JOBS_UNTAGREAD, 1), setdiff(get(%q0/TAGGED_FOR), %#), get(%q0/TAGGED_FOR))];@wait 0={@pemit %#=[u(%va/FN_FOOTER, u(%va/FN_FLAGS, %q0))]};}

&CMD_JOB/ADD [v(JOB_GO)]=$+job/add *=*:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][not(u(%va/IS_LOCKED, %q0, %#))][udefault(%q0/ADD_ACCESS, 1, %#)]=0*, { @force %#=+myjob/add %0=%1; }, 10*, {@pemit %#=That is an invalid job number.}, 110*, {@pemit %#=You do not have access to that job.}, 1110*, {@pemit %#=That job is presently [ifelse(u(%va/FN_HASATTRP, %q0, CHECKOUT), checked out to [name(first(get(%q0/CHECKOUT)))], locked)]}, 11110*, {@pemit %#=That action is not available for that job.}, {@pemit %#=Comments to [name(%q0)] added.;&TAGGED_FOR %q0=[remove(get(%q0/TAGGED_FOR), %#)];@trigger %va/TRIG_ADD=%q0, trim(%1), %#, ADD;@trigger %va/TRIG_BROADCAST=%q0, %#, ADD}

&CMD_JOB/MAIL [v(JOB_GO)]=$+job/mail *=*:@switch [u(%va/HAS_ACCESS, %#)][u(%va/MAIL_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][u(%va/IS_PUBLIC, %q0)][not(u(%va/IS_LOCKED, %q0, %#))][udefault(%q0/MAI_ACCESS, 1, %#)]=0*, { @force %#=+myjob/add %0=%1; }, 10*, {@pemit %#=Permission denied.}, 110*, {@pemit %#=There is no job by that number.}, 1110*, {@pemit %#=You do not have access to that job.}, 11110*, {@pemit %#=+job/mail cannot be used on the job because the bucket in which it is stored is not set PUBLIC %(+myjobs-accessible%).}, 111110*, {@pemit %#=That job is presently [ifelse(u(%va/FN_HASATTRP, %q0, CHECKOUT), checked out to [name(first(get(%q0/CHECKOUT)))], locked)]}, 1111110*, {@pemit %#=That action is not available for that job.}, {@pemit %#=You have mailed [u(%va/FN_PLAYERLIST, %q0)] about [name(%q0)], with the comments: [trim(%1)];@trigger %va/TRIG_ADD=%q0, [u(%va/FN_STRTRUNC, ansi(h, Mail sent to [u(%va/FN_PLAYERLIST, %q0)]:)%r%r[trim(%1)], get(%va/BUFFER))], %#, MAI;@trigger %va/TRIG_BROADCAST=%q0, %#, MAI, %q1}

&CMD_JOB/HELP [v(JOB_GO)]=$+job/help *:@switch [u(%va/HAS_ACCESS, %#)][setq(0, parent(u(%va/FN_FIND-JOB, %0)))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, %q0, %#, %q0)]=0*, { @force %#=+myjob/help %0; }, 10*, {@pemit %#=That is not a valid job. Type '[ansi(h, +jobs)]' for a list of valid jobs.}, 110*, {@pemit %#=You do not have access to that job.}, {@pemit %#=[u(%va/FN_HEADER, Job Help For Bucket [name(%q0)])];@pemit %#=[u(%q0/HELP)][ifelse(u(%va/FN_HASATTRP, %q0, MYHELP), %r[u(%va/FN_BREAK, [ansi(c, Myjob Help)])]%r[u(%q0/MYHELP)],)];@pemit %#=[u(%va/FN_FOOTER)]}

&CMD_JOB/LAST [v(JOB_GO)]=$+job/last *=*:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)]=0*, { @force %#=+myjob/last %0=%1; }, 10*, {@pemit %#=There is no job by that name. Please type '+jobs/all' for all jobs or '+jobs/<type>' to list by type.}, 110*, {@pemit %#=You do not have access to that job.}, {@pemit %#=[u(%va/FN_READERS, %q0, %#, 1)][u(%va/FN_HEADER, View [name(%q0)])]%r[ulocal(%va/FN_BANNER, %q0)];@dolist [extract(setr(1, filter(%va/FIL_COMMENTS, sortby(%va/SORTBY_COMMENTS, lattr(%q0/COMMENT_*)))), ifelse(lt(sub(words(%q1), trim(%1)), 1), 1, inc(sub(words(%q1), trim(%1)))), inc(trim(%1)))]={@pemit %#=[u(%va/FN_READJOB, ##, %q0)]};@wait 0={@pemit %#=[u(%va/FN_FOOTER, u(%va/FN_FLAGS, %q0))]};}

&CMD_JOBS/CATCHUP [v(JOB_GO)]=$+jobs/catchup:@switch [u(%va/HAS_ACCESS, %#)]=0*, { @force %#=+myjobs/catchup; }, {@pemit %#=You are now caught up on jobs.;&LAST_CONN %#=[secs()];@dolist lcon(%va)={think [u(%va/FN_READERS, ##, %#)]}}

&CMD_JOBS/CATCHUP2 [v(JOB_GO)]=$+jobs/catchup *:@switch [u(%va/HAS_ACCESS, %#)][setq(0, lcstr(%0))][setq(0, u(%va/FN_INFIX2POSTFIX, map(%va/MAP_JOBSELECT, u(%va/FN_TOKENLIST, %q0))))][not(strmatch(%q0, *#-1 MISMATCHED PARENS*))][not(strmatch(%q0, *#-1 SYNTAX ERROR*))][default(%#/JOBSN, 0)]=0*, { @force %#=+myjobs/catchup %0; }, 10*, @pemit %#=Mismatched parentheses., 110*, @pemit %#=Syntax error., 1110*, @pemit %#=You must set &4JOBSN me=1 to make use of this command., {@pemit %#=You are now caught up on jobs matching %q0.;@dolist [setq(1, filter(%va/FIL_GOING, lcon(%va)))][u(%va/FN_S-INIT)][map(%va/MAP_PARSESTACK, %q0)][u(%va/FN_S-PEEK)]={think [u(%va/FN_READERS, ##, %#)]}}
