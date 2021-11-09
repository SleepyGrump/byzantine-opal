/*
In the base +jobs install, +buckets and +jgroups only work for staffers. I find that to be a little TOO paranoid, since I want my players to have some understanding of what kind of workload we're under and what our division of labor is.

I removed the "isstaff" check from the following functions:
	+buckets
	+bucket/help <bucket>
	+bucket/info <bucket> (shows a lot of cool details)
	+jgroups
	+jgroups/info <group>
*/

&CMD_BUCKETS [v(JOB_GO)]=$+buckets:@pemit %#=[u(%va/FN_BUCKETHEADER)];think [setq(x, sortby(%va/SORTBY_NAME, filter(%va/FIL_ISBUCKET, lcon(%vc))))];@pemit %#=[iter(%qX, u(%va/FN_BUCKETLIST, ##), %B, %R)];@pemit %#=[u(%va/FN_FOOTER, [ifelse(u(%va/FN_STAFFALL, %#), ansi(hy, V=Viewing H=Hidden P=Published M=Myjobs L=Locked S=Summary),)])]

&CMD_BUCKET/HELP [v(JOB_GO)]=$+bucket/help *:@switch [setq(0, u(%va/FN_FIND-BUCKET, %0))][isdbref(%q0)]=0*, {@pemit %#=That is not a valid bucket. Type '[ansi(h, +buckets)]' for a list of valid buckets.}, {@pemit %#=[u(%va/FN_HEADER, Bucket Help For [name(%q0)])];@pemit %#=[u(%q0/HELP)][ifelse(u(%va/FN_HASATTRP, %q0, MYHELP), %r[u(%va/FN_BREAK, [ansi(c, Myjob Help)])]%r[u(%q0/MYHELP)],)];@pemit %#=[u(%va/FN_FOOTER)]}

&CMD_BUCKET/INFO [v(JOB_GO)]=$+bucket/info *:@switch [setq(0, u(%va/FN_FIND-BUCKET, %0))][isdbref(%q0)]=0*, {@pemit %#=There is no bucket by that name.}, {@pemit %#=[u(%va/FN_HEADER, Bucket Information For [name(%q0)])]%r[u(%va/DISPLAY_BUCKET)];@pemit %#=[u(%va/DISPLAY_BUCKET2)];@pemit %#=[u(%va/FN_FOOTER)]}

&CMD_JGROUPS [v(JOB_GO)]=$+jgroups:@switch [words(remove(lcon(%vb), #-1))]=0*, {@pemit %#=No jgroups have been defined.}, {@pemit %#=[u(%va/FN_HEADER, JGroup List)]%r[ansi(ulocal(%vA/GAME_TITLE_COLOR), %b%b[ljust(JGroup, 15)]Description)]%r[ulocal(%vA/FN_BREAK)];@pemit %#=[iter(sortby(%va/SORTBY_NAME, lcon(%vb)), %b%b[ljust(name(##), 15)][get(##/Desc)], %B, %R)];@pemit %#=[u(%va/FN_FOOTER)]}

&CMD_JGROUP/INFO [v(JOB_GO)]=$+jgroup/info *:@switch [setq(0, u(%va/FN_FIND-JGROUP, %0))][isdbref(%q0)]=0*, {@pemit %#=There is no jgroup by that name.}, {@pemit %#=[u(%va/FN_HEADER, JGroup Information For [name(%q0)])]%r%b%bDescription: [get(%q0/Desc)]%r%r%b%bMembers: [u(%va/FN_ITEMIZE, map(%va/MAP_NAME, u(%va/FN_JGROUPMEMBERS, %q0), %b, |), |)];@pemit %#=[u(%va/FN_FOOTER)]}
