/*
Main goal of this file: mostly unchanged +jobs and JRS install, with a few tiny tweaks to make them compatible with byzantine-opal.

================================================================================

AFTER YOU RUN THIS FILE, log into #1 and use:

@attribute/access JOBSB=WIZARD
@attribute/access JOBSH=HIDDEN

This is a permanent change - it doesn't need to be run more than once.

================================================================================

This code is set up for server-side logging. To do that I had to add these lines as described in the README (https://github.com/lashtear/Anomaly-Jobs/blob/master/full/README):

&HOOK_APR [v(JOB_VC)]=@trigger [v(VA)]/TRIG_LOG=%0,[v(VA)]
&HOOK_DEL [v(JOB_VC)]=@trigger [v(VA)]/TRIG_LOG=%0,[v(VA)]
&HOOK_DNY [v(JOB_VC)]=@trigger [v(VA)]/TRIG_LOG=%0,[v(VA)]
&HOOK_COM [v(JOB_VC)]=@trigger [v(VA)]/TRIG_LOG=%0,[v(VA)]

To make that work, I had to log in on the main game account and run the following, adjusted for each &logfile attribute on each bucket (minimum these two):

cd mux2.13/game
mkdir logs
touch M-joblog.log
touch M-reqlog.log

CHANGES:

Fixed a bug with &CMD_JOB/LOG where a comma wasn't escaped.

================================================================================

This file also includes Thenomain's JRS, available here: https://github.com/thenomain/Mu--Support-Systems/blob/aa764df1618ca22512b6ff09fe5702ae214abc28/Jobs%20Request%20System.txt

JRS adds the ability to let players directly add jobs to the buckets you choose, and creates a new jgroup, +allstaff.

I changed the .msg function to show the request type and formatted it in the game theme style with alert(). I also didn't like how it was formatted "<req/request> <message>", so changed it to just "<PREFIX> <message>".

That single carriage return Theno added? I made it 2 because I like formatting and readability and wanted even more. Thanks Theno!

At the end of this file, I create the jgroups +code and +build because JRS doesn't create those and neither does AnomalyJobs, but JRS does reference both of them.

I also added +allplayers, so that jobs can be assigned to all approved players. This one is not in use in any default JRS buckets. +job/assign <public job everyone can see>=+allplayers might be a handy thing to have.

I added req/typo and made +typo use it. It also reports the player's location.

================================================================================
*/

@switch [ifelse(isdbref(setr(0, switch(first(version()), PennMUSH, lsearch(all, eobjects, %[strmatch(name(##), Job Global Object <JGO>)%]), RhostMUSH, searchng(object=Job Global Object <JGO>), search(object=Job Global Object <JGO>)))), setq(1, get(%q0/VA)), [setq(1, switch(first(version()), PennMUSH, lsearch(all, eobjects, %[strmatch(name(##), Job Database <JD>)%]), RhostMUSH, searchng(object=Job Database <JD>), search(object=Job Database <JD>)))][setq(0, loc(%q1))])][isdbref(%q0)][and(isdbref(%q1), gte(edit(first(default(%q1/version, 0), .), v,), 5))]=0*, {think [ansi(hc, ANOMALY JOBS:)] No previous jobs installation found. Creating a new one.;&JOB_GO %#=setr(0, create(Job Global Object <JGO>, 10));&JOB_VA %#=setr(1, create(Job Database <JD>, 10));&JOB_VB %#=setr(2, create(Job Tracker, 10));&JOB_VC %#=setr(3, create(Job Parent Object <JPO>, 10));&JOB_PATCH %#=0;@tel %q1=%q0;@tel %q2=%q0;@tel %q3=%q0;}, 10*, {think [ansi(hc, ANOMALY JOBS:)] [ansi(hr, Not a valid Jobs 5 or later installation.)];think [ansi(hc, ANOMALY JOBS:)] [ansi(hr, Aborting. Cancel this script in your client.)];&JOB_GO %#=#-1;&JOB_VA %#=#-1;&JOB_VB %#=#-1;&JOB_VC %#=#-1;&JOB_PATCH %#=1;}, {think [ansi(hc, ANOMALY JOBS:)] Current installation found. Updating.;&JOB_GO %#=%q0;&JOB_VA %#=%q1;&JOB_VB %#=get(%q0/VB);&JOB_VC %#=get(%q0/VC);&JOB_PATCH %#=1;}

@dolist GO VA VB VC=@switch [first(version())]=RhostMUSH, {@Desc [v(JOB_##)]=lit(%r[columns(sort(lattr(me/*)), 18, 4)]%r%r[center(Please do not rename this object., 79)])}, {@Desc [v(JOB_##)]=lit(%r[table(sort(lattr(me/*)), 18)]%r%r[center(Please do not rename this object., 79)])}

@switch [v(JOB_PATCH)][hasattr(v(JOB_GO), STARTUP)]=11, @Startup [v(JOB_GO)]

@adisconnect [v(JOB_GO)]=@pemit me=[ifelse(u(%va/HAS_ACCESS, %#), set(%#, LAST_CONN:[secs()]),)]

@aconnect [v(JOB_GO)]=@switch [default(%#/JOBS_LOGIN, 1)][u(%va/HAS_ACCESS, %#)][u(%va/FN_GUEST, %#)]=110, {@force %#=+jobs/new}, 100, {@force %#=+myjobs}

&CMD_BUCKET/ACCESS [v(JOB_GO)]=$+bucket/access *=*:@switch [u(%va/GIVE_ACCESS, %#)][setq(0, switch(trim(%0), me, %#, pmatch(trim(%0))))][setq(1, u(%va/FN_FIND-BUCKET, %1))][isdbref(%q0)][isdbref(%q1)][u(%va/HAS_ACCESS, %q0)][u(%va/FN_WIZONLY, %q0)][u(%va/FN_ACCESSCHECK, %q1, %q0)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no player by that name.}, 110*, {@pemit %#=There is no bucket by that name.}, 1110*, {@pemit %#=That player does not have +jobs access.}, 11111*, {@pemit %#=That player can always access all buckets.}, 111100*, {@pemit %#=You have given [name(%q0)] access to the [name(%q1)] bucket and all jobs in it.;&JOBSB %q0=[ifelse(member(get(%q0/JOBSB), u(%va/FN_OBJID, %q1)), remove(get(%q0/JOBSB), u(%va/FN_OBJID, %q1)), setunion(get(%q0/JOBSB), u(%va/FN_OBJID, %q1)))];@dolist children(%q1)={&JOBACCESS itext(0)=[remove(get([itext(0)]/JOBACCESS), u(%va/FN_OBJID, %q0))]}}, {@pemit %#=You have removed [name(%q0)]'s access to the [name(%q1)] bucket and all jobs in it.;&JOBSB %q0=[ifelse(member(get(%q0/JOBSB), u(%va/FN_OBJID, %q1)), remove(get(%q0/JOBSB), u(%va/FN_OBJID, %q1)), setunion(get(%q0/JOBSB), u(%va/FN_OBJID, %q1)))];@dolist children(%q1)={&JOBACCESS itext(0)=[remove(get([itext(0)]/JOBACCESS), u(%va/FN_OBJID, %q0))]}}

&CMD_BUCKET/CHECK [v(JOB_GO)]=$+bucket/check *:@switch [isdbref(setr(0, switch(trim(%0), me, %#, pmatch(trim(%0)))))]=0, {@pemit %#=There is no such player.}, {@pemit %#=[u(%va/FN_HEADER, Bucket Information For [name(%q0)])]%r%r[ansi(h, [ljust(Bucket, 15)]%bHas Access?)]%r[iter(lcon(%VC), [ljust(name(itext(0)), 15)]%b[ifelse(u(%VA/fn_accesscheck, itext(0), %q0), Yes, No)], %b, %r)];@pemit %#=%r[u(%va/FN_FOOTER)]}

&CMD_BUCKET/CREATE [v(JOB_GO)]=$+bucket/create *=*:@switch [setq(0, u(%va/FN_FIND-BUCKET, %0))][u(%va/FN_WIZONLY, %#)][not(isdbref(%q0))][not(gt(strlen(trim(%0)), 5))]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is already a bucket by that name.}, 110*, {@pemit %#=The name of a bucket is limited to five letters.}, {@pemit %#=You have created a bucket named [ucstr(trim(%0))].[setq(0, create(ucstr(trim(%0)), 10))] Be sure to change %q0/ACCESS to establish who can access the bucket. Presently, it is set to 1, which means that anyone who can access +jobs can access the bucket.;@tel %q0=%vc;@parent %q0=%vc;@desc %q0=[trim(secure(%1))];@set %q0=inherit !safe !halted !no_command;&ACCESS %q0=1;@lock/speech %q0=ACCESS/1}

@switch [first(version())]=PennMUSH, {@edit [v(JOB_GO)]/CMD_BUCKET/CREATE=inherit !safe !halted, wizard !safe !halt}, TinyMUSH, {@edit [v(JOB_GO)]/CMD_BUCKET/CREATE=!no_command, commands}

&CMD_BUCKET/DELETE [v(JOB_GO)]=$+bucket/delete *:@switch [u(%va/FN_WIZONLY, %#)][setq(0, u(%va/FN_FIND-BUCKET, %0))][isdbref(%q0)][eq(words(remove(children(%q0), #-1)), 0)][not(hasflag(%q0, SAFE))]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no bucket by that name.}, 110*, {@pemit %#=The bucket is not empty, and cannot be deleted.}, 1110*, {@pemit %#=That bucket is required for the system to operate properly.}, {@pemit %#=You have deleted the bucket named [ucstr(%0)].;@set %q0=DESTROY_OK;@nuke %q0;@dolist [switch(first(version()), PennMUSH, lsearch(all, type, player), RhostMUSH, searchng(type=player), search(type=player))]={&JOBSH ##=[remove(get(##/JOBSH), %q0)];&JOBSB ##=[remove(get(##/JOBSB), u(%va/FN_OBJID, %q0))]}}

&CMD_BUCKET/HELP [v(JOB_GO)]=$+bucket/help *:@switch [setq(0, u(%va/FN_FIND-BUCKET, %0))][u(%va/FN_ACCESSCHECK, %q0, %#)][isdbref(%q0)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=That is not a valid bucket. Type '[ansi(h, +buckets)]' for a list of valid buckets.}, {@pemit %#=[u(%va/FN_HEADER, Bucket Help For [name(%q0)])];@pemit %#=[u(%q0/HELP)][ifelse(u(%va/FN_HASATTRP, %q0, MYHELP), %r[u(%va/FN_BREAK, [ansi(c, Myjob Help)])]%r[u(%q0/MYHELP)],)];@pemit %#=[u(%va/FN_FOOTER)]}

&CMD_BUCKET/INFO [v(JOB_GO)]=$+bucket/info *:@switch [u(%va/FN_STAFFALL, %#)][setq(0, u(%va/FN_FIND-BUCKET, %0))][isdbref(%q0)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no bucket by that name.}, {@pemit %#=[u(%va/FN_HEADER, Bucket Information For [name(%q0)])]%r[u(%va/DISPLAY_BUCKET)];@pemit %#=[u(%va/DISPLAY_BUCKET2)];@pemit %#=[u(%va/FN_FOOTER)]}

&CMD_BUCKET/MONITOR [v(JOB_GO)]=$+bucket/monitor *:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-BUCKET, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, %q0, %#)][u(%va/FN_MONITORCHECK, %q0, %#)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no bucket by that name.}, 110*, {@pemit %#=You do not have access to that bucket.}, 1110*, {@pemit %#=You have added bucket [name(%q0)] to your monitored list.;&JOBSH %#=[ifelse(u(%va/FN_HASATTR, %q0, HIDDEN), setunion(get(%#/JOBSH), %q0), remove(get(%#/JOBSH), %q0))]}, {@pemit %#=You have removed bucket [name(%q0)] from your monitored list.;&JOBSH %#=[ifelse(u(%va/FN_HASATTR, %q0, HIDDEN), remove(get(%#/JOBSH), %q0), setunion(get(%#/JOBSH), %q0))]}

&CMD_BUCKET/SET [v(JOB_GO)]=$+bucket/set */*=*:@switch [setq(0, u(%va/FN_FIND-BUCKET, %0))][and(u(%va/HAS_ACCESS, %#), u(%va/CONFIG_ACCESS, %#), u(%q0/ACCESS_[trim(%1)], %#))][isdbref(%q0)][u(%va/FN_HASATTRP, %q0, ACCESS_%1)][u(%q0/PROCESS_[trim(%1)], trim(%2), %q0, %#)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no bucket by that name. See '[ansi(h, +buckets)]' for a list of valid buckets.}, 110*, {@pemit %#='%1' is not a valid parameter. Valid parameters for [name(%q0)] are [u(%va/FN_ITEMIZE, map(%va/MAP_PARAMS, lattr(%vc/PROCESS_*)))].}, 1110*, {@pemit %#=[u(%q0/ERROR_[trim(%1)]%q2)]}, {@pemit %#=[name(%q0)]'s [ucstr(trim(%1))] successfully updated to: '[trim(%2)]'.;&%q3 %q0=%q1}

&CMD_BUCKETS [v(JOB_GO)]=$+buckets:@switch [u(%va/HAS_ACCESS, %#)]=0*, {@pemit %#=Permission denied.}, {@pemit %#=[u(%va/FN_BUCKETHEADER)];think [setq(x, sortby(%va/SORTBY_NAME, filter(%va/FIL_ISBUCKET, lcon(%vc))))];@pemit %#=[iter(filter(%va/FIL_ACCESS, %qx), u(%va/FN_BUCKETLIST, ##), %B, %R)];@pemit %#=[u(%va/FN_FOOTER, [ifelse(u(%va/FN_STAFFALL, %#), ansi(hy, V=Viewing H=Hidden P=Published M=Myjobs L=Locked S=Summary),)])]}

&CMD_BUG [v(JOB_GO)]=$+bug *=*:@switch [u(%va/FN_GUEST, %#)]=1, {@pemit %#=This command is not available to guests.}, {@pemit %#=You have notified production staff of the [secure(u(%va/FN_STRTRUNC, trim(%0), 30))] bug, with the details '[secure(u(%va/FN_STRTRUNC, trim(%1), get(%va/BUFFER)))]';@trigger %va/TRIG_CREATE=%#, u(%va/FN_FIND-BUCKET, CODE), 3, BUG: [u(%va/FN_STRTRUNC, trim(%0), 30)], [u(%va/FN_STRTRUNC, trim(%1), get(%va/BUFFER))],,, 5}

&CMD_JGROUPS [v(JOB_GO)]=$+jgroups:@switch [u(%va/HAS_ACCESS, %#)][words(remove(lcon(%vb), #-1))]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=No jgroups have been defined.}, {@pemit %#=[u(%va/FN_HEADER, JGroup List)]%r[ljust(JGroup, 15)]Description;@pemit %#=[iter(sortby(%va/SORTBY_NAME, lcon(%vb)), [ljust(name(##), 15)][get(##/Desc)], %B, %R)];@pemit %#=[u(%va/FN_FOOTER)]}

&CMD_JGROUP/CREATE [v(JOB_GO)]=$+jgroup/create *=*:@switch [u(%va/FN_WIZONLY, %#)][setq(0, u(%va/FN_FIND-JGROUP, %0))][not(isdbref(%q0))][strmatch(%0, +*)][eq(words(%0), 1)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is already a jgroup by that name.}, 110*, {@pemit %#=Jgroup names must begin with +.}, 1110*, {@pemit %#=Jgroup names may not contain spaces.}, {@pemit %#=You have created a jgroup named [trim(%0)].[setq(0, create(trim(%0), 10))] The %q0/ISMEMBER is set to use the %q0/MEMBERLIST attribute and +jgroup/member command. Override %q0/ISMEMBER if you wish to change this.;@tel %q0=%vb;@desc %q0=[secure(trim(%1))];&ISMEMBER %q0=lit(t(member(v(MEMBERLIST), %0)));@set %q0=inherit !safe !halted !no_command;}

@switch [first(version())]=PennMUSH, {@edit [v(JOB_GO)]/CMD_JGROUP/CREATE=inherit !safe !halted, wizard !safe !halt}, TinyMUSH, {@edit [v(JOB_GO)]/CMD_JGROUP/CREATE=!no_command, commands}

&CMD_JGROUP/DELETE [v(JOB_GO)]=$+jgroup/delete *:@switch [u(%va/FN_WIZONLY, %#)][setq(0, u(%va/FN_FIND-JGROUP, %0))][isdbref(%q0)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no jgroup by that name.}, {@pemit %#=You have deleted the jgroup named %0.;@set %q0=DESTROY_OK;@nuke %q0;@wait 0=@nuke %q0;}

&CMD_JGROUP/INFO [v(JOB_GO)]=$+jgroup/info *:@switch [u(%va/FN_STAFFALL, %#)][setq(0, u(%va/FN_FIND-JGROUP, %0))][isdbref(%q0)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no jgroup by that name.}, {@pemit %#=[u(%va/FN_HEADER, JGroup Information For [name(%q0)])]%rDescription: [get(%q0/Desc)]%rMembers: [u(%va/FN_ITEMIZE, map(%va/MAP_NAME, u(%va/FN_JGROUPMEMBERS, %q0), %b, |), |)];@pemit %#=[u(%va/FN_FOOTER)]}

&CMD_JGROUP/MEMBER [v(JOB_GO)]=$+jgroup/member *=*:@switch [u(%va/FN_WIZONLY, %#)][setq(0, switch(trim(%0), me, %#, pmatch(trim(%0))))][setq(1, u(%va/FN_FIND-JGROUP, %1))][isdbref(%q0)][isdbref(%q1)][or(u(%va/HAS_ACCESS, %q0), u(%q1/ISMEMBER, %q0))][strmatch(get(%q1/ISMEMBER), *MEMBERLIST*)][u(%q1/ISMEMBER, %q0)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no player by that name.}, 110*, {@pemit %#=There is no jgroup by that name.}, 1110*, {@pemit %#=That player does not have +jobs access.}, 11110*, {@pemit %#=Membership in that jgroup is unaffected by this command.}, 111110*, {@pemit %#=You have added [name(%q0)] to membership in the [name(%q1)] jgroup.;&memberlist %q1=setunion(get(%q1/memberlist), %q0);}, {@pemit %#=You have removed [name(%q0)] from membership in the [name(%q1)] jgroup.;&memberlist %q1=remove(get(%q1/memberlist), %q0);}

&CMD_JOB/ACCESS [v(JOB_GO)]=$+job/access *=*:@switch [u(%va/GIVE_ACCESS, %#)][setq(0, switch(trim(%0), me, %#, pmatch(trim(%1))))][setq(1, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][isdbref(%q1)][u(%va/FN_WIZONLY, %q0)][u(%va/FN_ACCESSCHECK, parent(%q1), %q0, %q1)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no player by that name.}, 110*, {@pemit %#=There is no job by that name. Please type '[ansi(h, +jobs/all)]' for all jobs or '[ansi(h, +jobs/list <bucket>)]' to list by bucket.}, 1111*, {@pemit %#=That player can always access all jobs.}, 11100*, {@pemit %#=You have given [name(%q0)] access to [name(%q1)].;&JOBACCESS %q1=[ifelse(member(get(%q1/JOBACCESS), u(%va/FN_OBJID, %q0)), remove(get(%q1/JOBACCESS), u(%va/FN_OBJID, %q0)), setunion(get(%q1/JOBACCESS), u(%va/FN_OBJID, %q0)))]}, {@pemit %#=You have removed [name(%q0)]'s access to [name(%q1)].;&JOBACCESS %q1=[ifelse(member(get(%q1/JOBACCESS), u(%va/FN_OBJID, %q0)), remove(get(%q1/JOBACCESS), u(%va/FN_OBJID, %q0)), setunion(get(%q1/JOBACCESS), u(%va/FN_OBJID, %q0)))]}

&CMD_JOB/ACT [v(JOB_GO)]=$+job/act *:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][or(u(%va/FN_STAFFALL, %#), u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0))]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no job by that name. Please type '+jobs/all' for all jobs or '+jobs/<type>' to list by type.}, 110*, {@pemit %#=You do not have access to that job.}, {@pemit %#=[u(%va/FN_HEADER, View Job Number %0)]%r[ulocal(%va/FN_BANNER, %q0)]%r[u(%va/FN_BREAK)];@dolist sortby(%va/SORTBY_COMMENTS, lattr(%q0/COMMENT_*))={@pemit %#=[rest(convsecs(extract(get(%q0/##), 2, 1, |)))]%b[first(get(%q0/##), |)]%b[ljust(u(%va/FN_STRTRUNC, extract(get(%q0/##), 4, 1, |), 15), 15)]%b[ljust(u(%va/FN_STRTRUNC, u(%va/fn_trim, edit(edit(edit(last(get(%q0/##), |), @@PIPE@@, |), %r, %b), %t, %b), b), 35), 35)]};@wait 0={@pemit %#=[u(%va/FN_FOOTER)]};}

&CMD_JOB/ADD [v(JOB_GO)]=$+job/add *=*:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][not(u(%va/IS_LOCKED, %q0, %#))][udefault(%q0/ADD_ACCESS, 1, %#)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=That is an invalid job number.}, 110*, {@pemit %#=You do not have access to that job.}, 1110*, {@pemit %#=That job is presently [ifelse(u(%va/FN_HASATTRP, %q0, CHECKOUT), checked out to [name(first(get(%q0/CHECKOUT)))], locked)]}, 11110*, {@pemit %#=That action is not available for that job.}, {@pemit %#=Comments to [name(%q0)] added.;&TAGGED_FOR %q0=[remove(get(%q0/TAGGED_FOR), %#)];@trigger %va/TRIG_ADD=%q0, trim(%1), %#, ADD;@trigger %va/TRIG_BROADCAST=%q0, %#, ADD}

&CMD_JOB/ALL [v(JOB_GO)]=$+job/all *:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no job by that name. Please type '[ansi(h, +jobs/all)]' for all jobs or '[ansi(h, +jobs/list <bucket>)]' to list by bucket.}, 110*, {@pemit %#=You do not have access to that job.}, {@pemit %#=[u(%va/FN_READERS, %q0, %#, 1)][u(%va/FN_HEADER, View [name(%q0)])]%r[ulocal(%va/FN_BANNER, %q0, %#)][ifelse(u(%va/FN_HASATTRP, %q0, SUMMARY), [ulocal(%va/FN_SUMMARY, %q0, %#)],)];@dolist [sortby(%va/SORTBY_COMMENTS, lattr(%q0/COMMENT_*))]={@pemit %#=[u(%va/FN_READJOB, ##, %q0)]};&TAGGED_FOR %q0=[ifelse(default(%#/JOBS_UNTAGREAD, 1), setdiff(get(%q0/TAGGED_FOR), %#), get(%q0/TAGGED_FOR))];@wait 0={@pemit %#=[u(%va/FN_FOOTER, u(%va/FN_FLAGS, %q0))]};}

&CMD_JOB/APPROVE [v(JOB_GO)]=$+job/approve *=*:@switch [u(%va/HAS_ACCESS, %#)][u(%va/APPROVE_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][not(u(%va/IS_LOCKED, %q0, %#))][udefault(%q0/APR_ACCESS, 1, %#)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=Permission denied.}, 110*, {@pemit %#=There is no job by that number.}, 1110*, {@pemit %#=You do not have access to that job.}, 11110*, {@pemit %#=That job is presently [ifelse(u(%va/FN_HASATTRP, %q0, CHECKOUT), checked out to [name(first(get(%q0/CHECKOUT)))], locked)]}, 111110*, {@pemit %#=That action is not available for that job.}, {@pemit %#=[u(%va/FN_ADDSTAT_ART, parent(%q0), %q0)][u(%va/FN_ADDSTAT_ART, %vc, %q0)]You have approved [name(%q0)], adding the comments: [trim(%1)];@trigger %va/TRIG_BROADCAST=%q0, %#, APR;@trigger %va/TRIG_ADD=%q0, [u(%va/FN_STRTRUNC, trim(%1), get(%va/BUFFER))], %#, APR;@trigger %va/TRIG_DESTROY=%q0}

&CMD_JOB/ASSIGN [v(JOB_GO)]=$+job/assign *=*:@switch [u(%va/HAS_ACCESS, %#)][setq(1, switch(trim(%1), +*, u(%va/FN_FIND-JGROUP, %1), me, %#, pmatch(trim(%1))))][setq(2, switch(trim(%1), NONE, 1, 0))][or(isdbref(%q1), %q2)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][not(u(%va/IS_LOCKED, %q0, %#))][udefault(%q0/ASN_ACCESS, 1, %#)][switch(1, %q2, 1, strmatch(%1, +*), [setq(3, u(%va/FN_JGROUPMEMBERS, %q1))][setq(4, iter(%q3, u(%va/FN_ACCESSCHECK, parent(%q0), itext(0), %q0)))][setq(5, member(%q4, 0))][not(gt(%q5, 0))], u(%va/FN_ACCESSCHECK, parent(%q0), %q1, %q0))]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no player or jgroup by that name.}, 110*, {@pemit %#=That is not a valid job number.}, 1110*, {@pemit %#=You do not have access to that job.}, 11110*, {@pemit %#=That job is presently [ifelse(u(%va/FN_HASATTRP, %q0, CHECKOUT), checked out to [name(first(get(%q0/CHECKOUT)))], locked)]}, 111110*, {@pemit %#=That action is not available on that job.}, 1111110*, {@pemit %#=[ifelse(strmatch(%1, +*), [name(%q1)] member [name(extract(%q3, %q5, 1))], name(%q1))] does not have access to that bucket.}, {@pemit %#=You have [ifelse(strmatch(%q1, %#), claimed, assigned)] [name(%q0)][ifelse(strmatch(%q1, %#), ., %bto [ifelse(isdbref(%q1), name(%q1), nobody)])];&ASSIGNED_TO %q0=[ifelse(%q2,, %q1)];@trigger %va/TRIG_ADD=%q0, [ifelse(%q2, Assignment removed., Assigned to [name(%q1)])]., %#, ASN, %q1;@trigger %va/TRIG_BROADCAST=%q0, %#, ASN, [ifelse(%q2,, %q1)]}

&CMD_JOB/CHECKOUT [v(JOB_GO)]=$+job/checkout *:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][not(u(%va/IS_LOCKED, %q0, %#))][not(u(%va/FN_HASATTR, %q0, CHECKOUT))][udefault(%q0/CKO_ACCESS, 1, %#)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no job by that name. Please type '[ansi(h, +jobs/all)]' for all jobs or '[ansi(h, +jobs/list <bucket>)]' to list by bucket.}, 110*, {@pemit %#=You do not have access to that job.}, 1110*, {@pemit %#=That job is presently [ifelse(u(%va/FN_HASATTRP, %q0, CHECKOUT), checked out to [name(first(get(%q0/CHECKOUT)))], locked)].}, 11110*, {@pemit %#=That job is already checked out.}, 111110*, {@pemit %#=That action is not available on that job.}, 1111110*, {@pemit %#=That action is not available for that job.}, {@pemit %#=[u(%va/FN_READERS, %q0, %#)]You have checked out [name(%q0)]. Nobody but you will be able to modify it until you check it back in.;&CHECKOUT %q0=%# [secs()];@trigger %va/TRIG_ADD=%q0, Checked out by [name(%#)]., %#, CKO;@trigger %va/TRIG_BROADCAST=%q0, %#, CKO}

&CMD_JOB/CHECKIN [v(JOB_GO)]=$+job/checkin *:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][u(%va/FN_HASATTR, %q0, CHECKOUT)][or(u(%va/FN_WIZONLY, %#), switch(first(get(%q0/CHECKOUT)), %#, 1, 0))][udefault(%q0/CKI_ACCESS, 1, %#)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no job by that name. Please type '[ansi(h, +jobs/all)]' for all jobs or '[ansi(h, +jobs/list <bucket>)]' to list by bucket.}, 110*, {@pemit %#=You do not have access to that job.}, 1110*, {@pemit %#=That job is not checked out.}, 11110*, {@pemit %#=You cannot check that job back in.}, 111110*, {@pemit %#=That action is not available for that job.}, {@pemit %#=[u(%va/FN_READERS, %q0, %#)]You have checked [name(%q0)] back in.;&CHECKOUT %q0=;@trigger %va/TRIG_ADD=%q0, Checked in by [name(%#)]., %#, CKI;@trigger %va/TRIG_BROADCAST=%q0, %#, CKI}

&CMD_JOB/CLAIM [v(JOB_GO)]=$+job/claim *:@force %#=+job/assign %0=%#

&CMD_JOB/CLONE [v(JOB_GO)]=$+job/clone *:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][udefault(%q0/CLN_ACCESS, 1, %#)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no job by that number.}, 110*, {@pemit %#=You do not have access to that job.}, 11110*, {@pemit %#=That action is not available for that job.}, {@pemit [setq(1, inc(get(%va/JOBS_NUM)))]%#=Job copied as Job %q1.;&JOBS_NUM %va=%q1;@clone %q0=Job %q1;@tel [setr(2, num(Job %q1))]=%va;@trigger %va/TRIG_ADD=%q2, Cloned job., %#, CLN, %q0;@trigger %va/TRIG_BROADCAST=%q0, %#, CLN, %q1}

&CMD_JOB/COMPLETE [v(JOB_GO)]=$+job/complete *=*:@switch [u(%va/HAS_ACCESS, %#)][u(%va/COMPLETE_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][not(u(%va/IS_LOCKED, %q0, %#))][udefault(%q0/COM_ACCESS, 1, %#)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=Permission denied.}, 110*, {@pemit %#=That is not a valid job #. See '+jobs/all' for valid jobs.}, 1110*, {@pemit %#=Permission denied.}, 11110*, {@pemit %#=That job is presently [ifelse(u(%va/FN_HASATTRP, %q0, CHECKOUT), checked out to [name(first(get(%q0/CHECKOUT)))], locked)]}, 111110*, {@pemit %#=That action is not available for that job.}, {@pemit %#=[u(%va/FN_ADDSTAT_ART, parent(%q0), %q0)][u(%va/FN_ADDSTAT_ART, %vc, %q0)]You have completed [name(%q0)].;@trigger %va/TRIG_ADD=%q0, [u(%va/FN_STRTRUNC, trim(%1), get(%va/BUFFER))], %#, COM;@trigger %va/TRIG_BROADCAST=%q0, %#, COM, %q1;@trigger %va/TRIG_DESTROY=%q0}

&CMD_JOB/CREATE [v(JOB_GO)]=$+job/create */*=*:@switch [u(%va/HAS_ACCESS, %#)][u(%va/CREATE_ACCESS, %#)][setq(0, u(%va/FN_FIND-BUCKET, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, %q0, %#, %q0)][udefault(%q0/CRE_ACCESS, 1, %#)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=Permission denied.}, 110*, {@pemit %#=There is no bucket by that name. Type '[ansi(h, +buckets)]' to get a list of buckets.}, 1110*, {@pemit %#=You cannot access that bucket.}, 11110*, {@pemit %#=That action is not available for that bucket.}, {@pemit [setq(1, inc(get(%va/JOBS_NUM)))]%#=You have created job number %q1 entitled '[u(%va/FN_STRTRUNC, trim(%1), 30)]'.;@trigger %va/TRIG_CREATE=%#, %q0, 1, [u(%va/FN_STRTRUNC, trim(%1), 30)], [u(%va/FN_STRTRUNC, trim(%2), u(%va/BUFFER))],,, 1}

&CMD_JOB/DELETE [v(JOB_GO)]=$+job/delete *:@switch [u(%va/HAS_ACCESS, %#)][or(u(%va/DELETE_ACCESS, %#), u(%va/FN_WIZONLY, %#), switch(%#, %va, 1, 0))][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][not(u(%va/IS_LOCKED, %q0, %#))][udefault(%q0/DEL_ACCESS, 1, %#)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=Permission denied.}, 110*, {@pemit %#=That is not a valid job number.}, 1110*, {@pemit %#=You do not have access to that job.}, 11110*, {@pemit %#=That job is presently [ifelse(u(%va/FN_HASATTRP, %q0, CHECKOUT), checked out to [name(first(get(%q0/CHECKOUT)))], locked)]}, 111110*, {@pemit %#=That action is not available for that job.}, {@pemit %#=[u(%va/FN_ADDSTAT_ART, parent(%q0), %q0)][u(%va/FN_ADDSTAT_ART, %vc, %q0)]You have deleted [name(%q0)].;@trigger %va/TRIG_ADD=%q0, Job %0 Deleted, %#, DEL;@trigger %va/TRIG_DESTROY=%q0}

&CMD_JOB/DENY [v(JOB_GO)]=$+job/deny *=*:@switch [u(%va/HAS_ACCESS, %#)][or(u(%va/DENY_ACCESS, %#), u(%va/FN_STAFFALL, %#))][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][not(u(%va/IS_LOCKED, %q0, %#))][udefault(%q0/DNY_ACCESS, 1, %#)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=Permission denied.}, 110*, {@pemit %#=There is no job by that number.}, 1110*, {@pemit %#=You cannot access that job.}, 11110*, {@pemit %#=That job is presently [ifelse(u(%va/FN_HASATTRP, %q0, CHECKOUT), checked out to [name(first(get(%q0/CHECKOUT)))], locked)]}, 111110*, {@pemit %#=That action is not available for that job.}, {@pemit %#=[u(%va/FN_ADDSTAT_ART, parent(%q0), %q0)][u(%va/FN_ADDSTAT_ART, %vc, %q0)]You have denied [name(%q0)].;@trigger %va/TRIG_BROADCAST=%q0, %#, DNY;@trigger %va/TRIG_ADD=%q0, [u(%va/FN_STRTRUNC, trim(%1), get(%va/BUFFER))], %#, DNY;@trigger %va/TRIG_DESTROY=%q0}

&CMD_JOB/DUE [v(JOB_GO)]=$+job/due *=*:@switch [not(eq(words(trim(%1), /), 3))][u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][udefault(%q0/DUE_ACCESS, 1, %#)][switch(lcstr(trim(%1)), none, 2, ifelse(gt(setr(1, u(%va/FN_STRINGSECS, trim(%1))), 0), 1[setq(1, add(%q1, secs()))], ifelse(gt(setr(1, convtime(trim(%1))), 0), 1, ifelse(gt(setr(1, convtime(trim(XXX %1))), 0), 1, t(gt(setr(1, convtime(trim(%1 23:59:59))), 0))))))]=0*, {@@}, 10*, {@pemit %#=Permission denied.}, 110*, {@pemit %#=That is not a valid job number.}, 1110*, {@pemit %#=You do not have access to that job.}, 11110*, {@pemit %#=That action is not available for that job.}, 111110*, {@pemit %#=Invalid date. Use date formatting as '[rest(time())]'.}, 111112*, {@pemit %#=You have cleared [name(%q0)]'s date.;&DUE_ON %q0=;@trigger %va/TRIG_ADD=%q0, Due date cleared., %#, DUE;@trigger %va/TRIG_BROADCAST=%q0, %#, DUE}, {@pemit %#=You have set [name(%q0)]'s date to [convsecs(%q1)].;&DUE_ON %q0=%q1;@trigger %va/TRIG_ADD=%q0, Due on [secure(%1)]., %#, DUE, [secure(%1)];@trigger %va/TRIG_BROADCAST=%q0, %#, DUE}

&CMD_JOB/DUE2 [v(JOB_GO)]=$+job/due *=*/*/*:@switch [u(%va/HAS_ACCESS, %#)][isdbref(setr(0, u(%va/FN_FIND-JOB, %0)))][setq(1, convtime(XXX [switch([rjust(trim(%1), 2, 0)], 01, Jan, 02, Feb, 03, Mar, 04, Apr, 05, May, 06, Jun, 07, Jul, 08, Aug, 09, Sep, 10, Oct, 11, Nov, 12, Dec)] [rjust(trim(%2), 2, 0)] 23:59:00 [switch(strlen(trim(%3)), 2, 20[rjust(trim(%3), 2, 0)], trim(%3))]))][gt(%q1, 0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][udefault(%q0/DUE_ACCESS, 1, %#)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=That is not a valid job number.}, 110*, {@pemit %#=Invalid date. Use date formatting as 'MM/DD/YY', '[rest(time())]', 'none' to clear.}, 1110*, {@pemit %#=You do not have access to that job.}, 11110*, {@pemit %#=That action is not available for that job.}, {@pemit %#=You have set [name(%q0)]'s date to [convsecs(%q1)].;&DUE_ON %q0=%q1;@trigger %va/TRIG_ADD=%q0, Due on [convsecs(%q1)]., %#, DUE;@trigger %va/TRIG_BROADCAST=%q0, %#, DUE}

&CMD_JOB/EDIT [v(JOB_GO)]=$+job/edit */*=*/*:@switch [u(%va/HAS_ACCESS, %#)][u(%va/EDIT_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][setq(1, get(%q0/COMMENT_[trim(%1)]))][switch(first(%q1, |), ADD, 1, CRE, 1, 0)][not(u(%va/IS_LOCKED, %q0, %#))][switch(extract(%q1, 3, 1, |), %#, 1, u(%va/FN_WIZONLY, %#))][udefault(%q0/EDT_ACCESS, 1, %#)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=Permission denied.}, 110*, {@pemit %#=That is an invalid job number.}, 1110*, {@pemit %#=You do not have access to that job.}, 11110*, {@pemit %#=You cannot modify that entry.}, 111110*, {@pemit %#=That job is presently [ifelse(u(%va/FN_HASATTRP, %q0, CHECKOUT), checked out to [name(first(get(%q0/CHECKOUT)))], locked)]}, 1111110*, {@pemit %#=You can only edit entries that belong to you.}, 11111110*, {@pemit %#=That action is not available for that job.}, {&COMMENT_[trim(%1)] %q0=[extract(%q1, 1, 4, |)]|[edit(last(%q1, |), edit(%2, |, @@PIPE@@), edit(%3, |, @@PIPE@@))];@pemit %#=Edited: [last(u(%q0/COMMENT_[trim(%1)]), |)];@trigger %va/TRIG_ADD=%q0, Comment %1 edited by %n., %#, EDT, [objeval(%#, secure(%1))];@trigger %va/TRIG_BROADCAST=%q0, %#, EDT}

&CMD_JOB/ERROR [v(JOB_GO)]=$+job:@switch [u(%va/HAS_ACCESS, %#)]=0*, {@pemit %#=Use +myjobs to access your jobs.}, {@pemit %#=Type '+jobs' for a list of jobs, or '+job <#>' to view a specific job.}

&CMD_JOB/ESC [v(JOB_GO)]=$+job/esc *=*:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][setq(1, match(green yellow red, [trim(%1)]*))][setq(2, extract(GREEN YELLOW RED, %q1, 1))][gt(%q1, 0)][not(u(%va/IS_LOCKED, %q0, %#))][udefault(%q0/ESC_ACCESS, 1, %#)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=That is not a valid job number.}, 110*, {@pemit %#=You do not have access to that job.}, 1110*, {@pemit %#=That is not a valid escalation code. Valid codes are red, yellow, and green.}, 11110*, {@pemit %#=That job is presently [ifelse(u(%va/FN_HASATTRP, %q0, CHECKOUT), checked out to [name(first(get(%q0/CHECKOUT)))], locked)]}, 111110*, {@pemit %#=That action is not available for that job.}, {@pemit %#=You have escalated job # %0 to %q2 status.;&PRIORITY %q0=%q1;@trigger %va/TRIG_ADD=%q0, Priority To %q2., %#, ESC, ucstr(trim(%1));@trigger %va/TRIG_BROADCAST=%q0, %#, ESC, %q2}

&CMD_JOB/HELP [v(JOB_GO)]=$+job/help *:@switch [u(%va/HAS_ACCESS, %#)][setq(0, parent(u(%va/FN_FIND-JOB, %0)))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, %q0, %#, %q0)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=That is not a valid job. Type '[ansi(h, +jobs)]' for a list of valid jobs.}, 110*, {@pemit %#=You do not have access to that job.}, {@pemit %#=[u(%va/FN_HEADER, Job Help For Bucket [name(%q0)])];@pemit %#=[u(%q0/HELP)][ifelse(u(%va/FN_HASATTRP, %q0, MYHELP), %r[u(%va/FN_BREAK, [ansi(c, Myjob Help)])]%r[u(%q0/MYHELP)],)];@pemit %#=[u(%va/FN_FOOTER)]}

&CMD_JOB/LAST [v(JOB_GO)]=$+job/last *=*:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no job by that name. Please type '+jobs/all' for all jobs or '+jobs/<type>' to list by type.}, 110*, {@pemit %#=You do not have access to that job.}, {@pemit %#=[u(%va/FN_READERS, %q0, %#, 1)][u(%va/FN_HEADER, View [name(%q0)])]%r[ulocal(%va/FN_BANNER, %q0)];@dolist [extract(setr(1, filter(%va/FIL_COMMENTS, sortby(%va/SORTBY_COMMENTS, lattr(%q0/COMMENT_*)))), ifelse(lt(sub(words(%q1), trim(%1)), 1), 1, inc(sub(words(%q1), trim(%1)))), inc(trim(%1)))]={@pemit %#=[u(%va/FN_READJOB, ##, %q0)]};@wait 0={@pemit %#=[u(%va/FN_FOOTER, u(%va/FN_FLAGS, %q0))]};}

&CMD_JOB/LOCK [v(JOB_GO)]=$+job/lock *:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][not(u(%va/FN_HASATTR, %q0, LOCKED))][udefault(%q0/LOK_ACCESS, 1, %#)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=That is an invalid job number.}, 110*, {@pemit %#=You do not have access to that job.}, 1110*, {@pemit %#=That job is already locked.}, 11110*, {@pemit %#=That action is not available for that job.}, {@pemit %#=You have locked [name(%q0)]. No further modifications can be made to this job until it is unlocked.;&LOCKED_BY %q0=%#;&LOCKED %q0=1;@trigger %va/TRIG_ADD=%q0, Locked by %n., %#, LOK;@trigger %va/TRIG_BROADCAST=%q0, %#, LOK}

@@ Fixed a bug with this code where a comma wasn't escaped: "does not exist," should have been "does not exist%,":
&CMD_JOB/LOG [v(JOB_GO)]=$+job/log *:@switch [u(%va/HAS_ACCESS, %#)][u(%va/LOG_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][u(%va/FN_HASATTRP, %q0, LOGFILE)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=Permission denied.}, 110*, {@pemit %#=There is no job by that name. Please type '+jobs/all' for all jobs or '+jobs/<type>' to list by type.}, 1110*, {@pemit %#=You do not have access to that job.}, 11110*, {@pemit %#=There is no logfile for that bucket.}, {@pemit %#=Logging [name(%q0)] to game/[switch(first(version()), PennMUSH, log/command.log, TinyMUSH, netmush.log, RhostMUSH, [get(%q0/LOGFILE)]_manual.log, logs/M-[get(%q0/LOGFILE)].log%rNote that if the log file does not exist%, then it did not get logged.)]; @trigger %va/TRIG_LOG=%q0, %#}

&CMD_JOB/MAIL [v(JOB_GO)]=$+job/mail *=*:@switch [u(%va/HAS_ACCESS, %#)][u(%va/MAIL_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][u(%va/IS_PUBLIC, %q0)][not(u(%va/IS_LOCKED, %q0, %#))][udefault(%q0/MAI_ACCESS, 1, %#)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=Permission denied.}, 110*, {@pemit %#=There is no job by that number.}, 1110*, {@pemit %#=You do not have access to that job.}, 11110*, {@pemit %#=+job/mail cannot be used on the job because the bucket in which it is stored is not set PUBLIC %(+myjobs-accessible%).}, 111110*, {@pemit %#=That job is presently [ifelse(u(%va/FN_HASATTRP, %q0, CHECKOUT), checked out to [name(first(get(%q0/CHECKOUT)))], locked)]}, 1111110*, {@pemit %#=That action is not available for that job.}, {@pemit %#=You have mailed [u(%va/FN_PLAYERLIST, %q0)] about [name(%q0)], with the comments: [trim(%1)];@trigger %va/TRIG_ADD=%q0, [u(%va/FN_STRTRUNC, ansi(h, Mail sent to [u(%va/FN_PLAYERLIST, %q0)]:)%r%r[trim(%1)], get(%va/BUFFER))], %#, MAI;@trigger %va/TRIG_BROADCAST=%q0, %#, MAI, %q1}

&CMD_JOB/MERGE [v(JOB_GO)]=$+job/merge *=*:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %1))][setq(1, u(%va/FN_FIND-JOB, %0))][isdbref(%q1)][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][u(%va/FN_ACCESSCHECK, parent(%q1), %#, %q0)][setq(2, u(%q0/NUM_COMMENT))][setq(3, u(%q1/NUM_COMMENT))][and(not(u(%va/IS_LOCKED, %q0, %#)), not(u(%va/IS_LOCKED, %q1, %#)))][not(eq(%0, %1))][udefault(%q0/MRG_ACCESS, 1, %#)][udefault(%q1/MRG_ACCESS, 1, %#)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no job number %0.}, 110*, {@pemit %#=There is no job number %1.}, 1110*, {@pemit %#=You do not have access to [name(%q0)].}, 11110*, {@pemit %#=You do not have access to [name(%q1)].}, 111110*, {@pemit %#=One of those jobs is locked or checked out.}, 1111110*, {@pemit %#=Sort of like a Klein bottle, eh?}, 11111110*, {@pemit %#=That action is not available for [name(%q0)].}, 111111110*, {@pemit %#=That action is not available for [name(%q1)].}, {@trigger %va/TRIG_ADD=%q0, [name(%q1)] merged into this one., %#, MRG;@trigger %va/TRIG_BROADCAST=%q0, %#, MRG, %q1;@wait 0={@dolist [sortby(%va/SORTBY_COMMENTS, lattr(%q1/COMMENT_*))]={@cpattr %q1/##=%q0/COMMENT_[get(%q0/NUM_COMMENT)];&NUM_COMMENT %q0=[inc(get(%q0/NUM_COMMENT))]};@trigger %va/TRIG_DESTROY=%q1}};

&CMD_JOB/NAME [v(JOB_GO)]=$+job/name *=*:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][not(u(%va/IS_LOCKED, %q0, %#))][udefault(%q0/NAM_ACCESS, 1, %#)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no job by that name.}, 110*, {@pemit %#=You do not have access to that job.}, 1110*, {@pemit %#=That job is presently [ifelse(u(%va/FN_HASATTRP, %q0, CHECKOUT), checked out to [name(first(get(%q0/CHECKOUT)))], locked)]}, 11110*, {@pemit %#=That action is not available for that job.}, {@pemit %#=You have changed the name of [name(%q0)] to [trim(%1)].;&TITLE %q0=[secure(trim(%1))];@trigger %va/TRIG_ADD=%q0, Renamed to '[secure(trim(%1))]'., %#, NAM;@trigger %va/TRIG_BROADCAST=%q0, %#, NAM, [secure(trim(%1))]}

&CMD_JOB/NEW [v(JOB_GO)]=$+job/new *:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][setq(1, default(%#/LAST_CONN, 0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no job by that name. Please type '+jobs/all' for all jobs or '+jobs/<type>' to list jobs by type.}, 110*, {@pemit %#=You do not have access to that job.}, {@pemit %#=[u(%va/FN_HEADER, View [name(%q0)])]%r[ulocal(%va/FN_BANNER, %q0)][ifelse(u(%va/FN_HASATTRP, %q0, SUMMARY), [ulocal(%va/FN_SUMMARY, %q0)],)];@dolist [filter(%va/FIL_NEWCOMMENTS[default(%#/JOBSN, 0)], sortby(%va/SORTBY_COMMENTS, lattr(%q0/COMMENT_*)))]={@pemit %#=[u(%va/FN_READJOB, ##, %q0)]};@wait 0={@pemit %#=[ifelse(u(%va/IS_LOCKED, %q0, %#), u(%va/FN_FOOTER, u(%va/FN_FLAGS, %q0)), [u(%va/FN_FOOTER, New Activity on [name(%q0)] since [convsecs(%q1)])])][u(%va/FN_READERS, %q0, %#, 1)]};}

&CMD_JOB/PUBLISH [v(JOB_GO)]=$+job/publish *:@switch [eq(words(%0, =), 1)][u(%va/HAS_ACCESS, %#)][u(%va/EDIT_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][u(%va/FN_HASATTRP, %q0, PUBLIC)][not(u(%va/IS_LOCKED, %q0, %#))][udefault(%q0/PUB_ACCESS, 1, %#)][eq(u(%q0/PUBLISH), 1)]=0*, @@, 10*, {@pemit %#=Permission denied.}, 110*, {@pemit %#=Permission denied.}, 1110*, {@pemit %#=There is no job by that number.}, 11110*, {@pemit %#=You do not have access to that job.}, 111110*, {@pemit %#=That job is not in a bucket that is accessible to +myjobs, so publication is moot.}, 1111110*, {@pemit %#=That job is presently [ifelse(u(%va/FN_HASATTRP, %q0, CHECKOUT), checked out to [name(first(get(%q0/CHECKOUT)))], locked)]}, 11111110*, {@pemit %#=That action is not available for that job.}, 111111110*, {@pemit %#=You have published [name(%q0)].;&PUBLISH %q0=1;@trigger %va/TRIG_ADD=%q0, Published by %n., %#, PUB;@trigger %va/TRIG_BROADCAST=%q0, %#, PUB}, {@pemit %#=[name(%q0)] will now no longer be published.;&PUBLISH %q0=0;@trigger %va/TRIG_ADD=%q0, Unpublished by %n., %#, UNP;@trigger %va/TRIG_BROADCAST=%q0, %#, UNP}

&CMD_JOB/PUBLISH2 [v(JOB_GO)]=$+job/publish *=*:@switch [u(%va/HAS_ACCESS, %#)][u(%va/EDIT_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][not(u(%va/IS_LOCKED, %q0, %#))][u(%va/IS_PUBLIC, %q0)][u(%va/FN_HASATTRP, %q0, COMMENT_[trim(%1)])][udefault(%q0/PUB_ACCESS, 1, %#)][neq(u(%q0/PUBLISH), 1)][hasflag(%q0/COMMENT_%1, no_inherit)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=Permission denied.}, 110*, {@pemit %#=There is no job by that number.}, 1110*, {@pemit %#=You do not have access to that job.}, 11110*, {@pemit %#=That job is presently [ifelse(u(%va/FN_HASATTRP, %q0, CHECKOUT), checked out to [name(first(get(%q0/CHECKOUT)))], locked)]}, 111110*, {@pemit %#=That job is not in a bucket that is accessible to +myjobs, so publication is moot.}, 1111110*, {@pemit %#=That is not a valid comment number.}, 11111110*, {@pemit %#=That action is not available for that job.}, 111111110*, {@pemit %#=That job is published. Comment publication has no effect.}, 1111111110*, {@pemit %#=You have published Comment [trim(%1)] on [name(%q0)].;@set %q0/COMMENT_[trim(%1)]=no_inherit;@trigger %va/TRIG_ADD=%q0, Comment [trim(%1)] published by %n., %#, PUB;@trigger %va/TRIG_BROADCAST=%q0, %#, PUB, %1}, {@pemit %#=[name(%q0)]/Comment [trim(%1)] will no longer be published.;@set %q0/COMMENT_[trim(%1)]=!no_inherit;@trigger %va/TRIG_ADD=%q0, Comment [trim(%1)] Unpublished by %n., %#, UNP;@trigger %va/TRIG_BROADCAST=%q0, %#, UNP, trim(%1)}

&CMD_JOB/QUERY [v(JOB_GO)]=$+job/query */*=*:@switch [and(u(%va/HAS_ACCESS, %#), u(%va/MAIL_ACCESS, %#))]=0*, {@pemit %#=Permission denied.}, {@switch [setq(1, map(%va/MAP_SOURCE, secure(trim(%0))))][setq(2, member(%q1, #-1))][not(gt(%q2, 0))]=0, {@pemit %#='[extract(secure(trim(%0)), %q2, 1)]' is not a valid player or jgroup.}, {@pemit %#=You have sent a query to '[trim(%0)]' regarding '[trim(%1)]'.;@trigger %va/TRIG_CREATE=%#, u(%va/FN_FIND-BUCKET, QUERY), 2, [u(%va/FN_STRTRUNC, secure(trim(%1)), 30)], Queried [u(%va/FN_ITEMIZE, map(%va/MAP_NAME, %q1, %b, |), |)]:%r%r[u(%va/FN_STRTRUNC, trim(%2), get(%va/BUFFER))], %q1,, 0}}

&CMD_JOB/SET [v(JOB_GO)]=$+job/set *=*:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][setq(a, trim(%1))][setq(2, after(first(filter(%va/FIL_STATUS, lattr(%va/STATUS_*))), STATUS_))][gt(strlen(%q2), 0)][not(u(%va/IS_LOCKED, %q0, %#))][udefault(%q0/STA_ACCESS, 1, %#)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=That is not a valid job.}, 110*, {@pemit %#=You do not have access to that job.}, 1110*, {@pemit %#=That is an invalid setting. Valid job settings are:%r[u(%va/FN_ITEMIZE, iter(lattr(%va/STATUS_*), last(get(%va/[itext(0)]), |), %b, |), |)].}, 11110*, {@pemit %#=That job is presently [ifelse(u(%va/FN_HASATTRP, %q0, CHECKOUT), checked out to [name(first(get(%q0/CHECKOUT)))], locked)]}, 111110*, {@pemit %#=That action is not available for that job.}, {@pemit %#=You set [name(%q0)] to [setr(1, last(get(%va/STATUS_%q2), |))] status.;&STATUS %q0=%q2;@trigger %va/TRIG_ADD=%q0, Set to %q1., %#, STA;@trigger %va/TRIG_BROADCAST=%q0, %#, STA, %q1}

&CMD_JOB/SOURCE [v(JOB_GO)]=$+job/source *=*:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][not(u(%va/IS_LOCKED, %q0, %#))][setq(1, map(%va/MAP_SOURCE, secure(trim(%1))))][setq(2, member(%q1, #-1))][not(gt(%q2, 0))][udefault(%q0/SRC_ACCESS, 1, %#)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no job by that number.}, 110*, {@pemit %#=You do not have access to that job.}, 1110*, {@pemit %#=That job is presently [ifelse(u(%va/FN_HASATTRP, %q0, CHECKOUT), checked out to [name(first(get(%q0/CHECKOUT)))], locked)]}, 11110*, {@pemit %#='[extract(secure(trim(%1)), %q2, 1)]' is not a valid player or jgroup.}, 111110*, {@pemit %#=That action is not available for that job.}, {&opened_by %q0=%q1;@pemit %#=You have set job #%0 to have a source of [u(%va/FN_PLAYERLIST, %q0)].;@trigger %va/TRIG_ADD=%q0, Source changed to [u(%va/FN_PLAYERLIST, %q0)]., %#, SRC;@trigger %va/TRIG_BROADCAST=%q0, %#, SRC, %q1}

&CMD_JOB/SUMMARY [v(JOB_GO)]=$+job/summary *:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no job by that name. Please type '[ansi(h, +jobs/all)]' for all jobs or '[ansi(h, +jobs/list <bucket>)]' to list by bucket.}, 110*, {@pemit %#=You do not have access to that job.}, {@pemit %#=[u(%va/FN_HEADER, View [name(%q0)])]%r[ulocal(%va/FN_BANNER, %q0)][ifelse(u(%va/FN_HASATTRP, %q0, SUMMARY), [ulocal(%va/FN_SUMMARY, %q0)],)][ifelse(u(%va/FN_WIZONLY, %#), [ulocal(%va/FN_STAFFSUM, %q0)],)];@wait 0={@pemit %#=[u(%va/FN_FOOTER, u(%va/FN_FLAGS, %q0))]};}

&CMD_JOB/SUMSET [v(JOB_GO)]=$+job/sumset */*=*:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_HASATTRP, parent(%q0), ACCESS_[trim(%1)])][and(u(%va/CONFIG_ACCESS, %#), u(parent(%q0)/ACCESS_[trim(%1)], %#))][not(u(%va/IS_LOCKED, %q0, %#))][u(parent(%q0)/PROCESS_[trim(%1)], trim(%2), %q0, %#)][udefault(%q0/SUM_ACCESS, 1, %#)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no such job. See '[ansi(h, +jobs)]' for a list of valid jobs.}, 110*, {@pemit %#='[trim(%1)]' is not a valid parameter. Valid parameters for [name(%q0)] are [u(%va/FN_ITEMIZE, map(%va/MAP_PARAMS, lattr(parent(%q0)/PROCESS_*)))].}, 1110*, {@pemit %#=You either can not use the +job/sumset command, or set that parameter.}, 11110*, {@pemit %#=That job is presently [ifelse(u(%va/FN_HASATTRP, %q0, CHECKOUT), checked out to [name(first(get(%q0/CHECKOUT)))], locked)]}, 111110*, {@pemit %#=[u(%q0/ERROR_[trim(%1)]%q2)]}, 1111110*, {@pemit %#=That action is not available for that job.}, {@trigger %va/TRIG_BROADCAST=%q0, %#, SUM, [ucstr(trim(%1))];&%q3 %q0=%q1;@trigger %va/TRIG_ADD=%q0, [ucstr(trim(%1))] parameter updated to '[trim(%2)]', %#, SUM}

&CMD_JOB/TAG [v(JOB_GO)]=$+job/tag *:@switch [u(%va/HAS_ACCESS, %#)][switch(strmatch(%0, *=*), 1, [setq(8, first(%0, =))][setq(9, trim(secure(rest(%0, =))))], [setq(8, %0)][setq(9, %#)])][setq(7, map(%va/MAP_JGROUP, %q9))][setq(6, u(%va/fn_trim, squish(map(%va/MAP_JGROUPERROR, %q9))))][setq(0, u(%va/FN_FIND-JOB, %q8))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][not(u(%va/IS_LOCKED, %q0, %#))][udefault(%q0/TAG_ACCESS, 1, %#)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=That is an invalid job number.}, 110*, {@pemit %#=You do not have access to that job.}, 1110*, {@pemit %#=That job is presently [ifelse(u(%va/FN_HASATTRP, %q0, CHECKOUT), checked out to [name(first(get(%q0/CHECKOUT)))], locked)]}, 11110*, {@pemit %#=That action is not available for that job.}, {@switch [t(strlen(%q6))]=1, {@pemit %#=%q6}, {@switch [strlen(setdiff(%q7, get(%q0/tagged_for)))]=0, {@pemit %#={[name(%q0)] is already tagged for the named player(s): [u(%va/FN_ITEMIZE, map(%va/MAP_NAME, %q7, %b, |), |)]}}, {&tagged_for %q0=[setunion(get(%q0/tagged_for), %q7)];@trigger %va/TRIG_ADD=%q0, Added tags for [setr(5, u(%va/FN_ITEMIZE, map(%va/MAP_NAME, %q7, %b, |), |))], %#, TAG, %q7;@trigger %va/TRIG_BROADCAST=%q0, %#, TAG, %q5;@pemit %#={[name(%q0)] updated - tags added. Now tagged for: [u(%va/FN_ITEMIZE, map(%va/MAP_NAME, get(%q0/tagged_for), %b, |), |)]}}}}

&CMD_JOB/TRANS [v(JOB_GO)]=$+job/trans *=*:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][isdbref(setr(1, u(%va/FN_FIND-BUCKET, %1)))][udefault(%q0/TRN_ACCESS, 1, %#)][udefault(%q1/TRN_ACCESS, 1, %#)][not(u(%va/IS_LOCKED, %q0, %#))]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no job by that number.}, 110*, {@pemit %#=You do not have access to that job.}, 1110*, {@pemit %#=There is no bucket by that name. Type '[ansi(h, +buckets)]' for a list of valid buckets.}, 11110*, {@pemit %#=You cannot move that job from there.}, 111110*, {@pemit %#=You cannot move that job to there.}, 1111110*, {@pemit %#=That job is presently [ifelse(u(%va/FN_HASATTRP, %q0, CHECKOUT), checked out to [name(first(get(%q0/CHECKOUT)))], locked)]}, {@pemit %#=You have transferred the job from [u(%va/FN_BUCKETNAME, %q0)] to [name(%q1)].;@set %q0=!going;&going %q0;@parent %q0=%q1;@trigger %va/TRIG_ADD=%q0, Transferred to [name(%q1)]., %#, TRN;@trigger %va/TRIG_BROADCAST=%q0, %#, TRN, %q1}

&CMD_JOB/UNDELETE [v(JOB_GO)]=$+job/undelete *:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][u(%va/FN_HASATTR, %q0, GOING)][udefault(%q0/UND_ACCESS, 1, %#)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no job by that number.}, 110*, {@pemit %#=You do not have access to that job.}, 1110*, {@pemit %#=That job has not been deleted.}, 11110*, {@pemit %#=That action is not available for that job.}, {@pemit %#=You have restored [name(%q0)].;@set %q0=!going;&going %q0;@trigger %va/TRIG_ADD=%q0, Undeleted job., %#, UND;@trigger %va/TRIG_BROADCAST=%q0, %#, UND, %q1}

&CMD_JOB/UNLOCK [v(JOB_GO)]=$+job/unlock *:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][u(%va/FN_HASATTRP, %q0, LOCKED)][udefault(%q0/UNL_ACCESS, 1, %#)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=That is an invalid job number.}, 110*, {@pemit %#=You do not have access to that job.}, 1110*, {@pemit %#=That job is not locked.}, 11110*, {@pemit %#=That action is not available for that job.}, {@pemit %#=You have unlocked [name(%q0)].;&LOCKED %q0=;&LOCKED_BY %q0=;@trigger %va/TRIG_ADD=%q0, Unlocked by %n., %#, UNL;@trigger %va/TRIG_BROADCAST=%q0, %#, UNL}

&CMD_JOB/UNTAG [v(JOB_GO)]=$+job/untag *:@switch [u(%va/HAS_ACCESS, %#)][switch(strmatch(%0, *=*), 1, [setq(8, first(%0, =))][setq(9, trim(secure(rest(%0, =))))], [setq(8, %0)][setq(9, %#)])][setq(7, map(%va/MAP_JGROUP, %q9))][setq(6, u(%va/fn_trim, squish(map(%va/MAP_JGROUPERROR, %q9))))][setq(0, u(%va/FN_FIND-JOB, %q8))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][not(u(%va/IS_LOCKED, %q0, %#))][udefault(%q0/TAG_ACCESS, 1, %#)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=That is an invalid job number.}, 110*, {@pemit %#=You do not have access to that job.}, 1110*, {@pemit %#=That job is presently [ifelse(u(%va/FN_HASATTRP, %q0, CHECKOUT), checked out to [name(first(get(%q0/CHECKOUT)))], locked)]}, 11110*, {@pemit %#=That action is not available for that job.}, {@switch [t(strlen(%q6))]=1, {@pemit %#=%q6}, {@switch [strlen(setinter(%q7, get(%q0/tagged_for)))]=0, {@pemit %#={[name(%q0)] is not tagged for any of the named player(s): [u(%va/FN_ITEMIZE, map(%va/MAP_NAME, %q7, %b, |), |)]}}, {&tagged_for %q0=[setdiff(get(%q0/tagged_for), %q7)];@trigger %va/TRIG_ADD=%q0, Removed tags for [setr(5, u(%va/FN_ITEMIZE, map(%va/MAP_NAME, %q7, %b, |), |))], %#, TAG;@trigger %va/TRIG_BROADCAST=%q0, %#, TAG, %q5;@pemit %#={[name(%q0)] updated - tags removed. Now tagged for: [u(%va/FN_ITEMIZE, map(%va/MAP_NAME, get(%q0/tagged_for), %b, |), |)]}}}}

&CMD_JOB/VIEW [v(JOB_GO)]=$+job *:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no job by that name. Please type '[ansi(h, +jobs/all)]' for all jobs or '[ansi(h, +jobs/list <bucket>)]' to list by bucket.}, 110*, {@pemit %#=You do not have access to that job.}, {@pemit %#=[u(%va/FN_READERS, %q0, %#, 1)][u(%va/FN_HEADER, View [name(%q0)])]%r[ulocal(%va/FN_BANNER, %q0, %#)][ifelse(u(%va/FN_HASATTRP, %q0, SUMMARY), [ulocal(%va/FN_SUMMARY, %q0, %#)],)];@dolist [filter(%va/FIL_COMMENTS, sortby(%va/SORTBY_COMMENTS, lattr(%q0/COMMENT_*)))]={@pemit %#=[u(%va/FN_READJOB, ##, %q0)]};&TAGGED_FOR %q0=[ifelse(default(%#/JOBS_UNTAGREAD, 1), setdiff(get(%q0/TAGGED_FOR), %#), get(%q0/TAGGED_FOR))];@wait 0={@pemit %#=[u(%va/FN_FOOTER, u(%va/FN_FLAGS, %q0))]};}

&CMD_JOBS [v(JOB_GO)]=$+jobs:@force %#=+jobs/select [switch(u(%va/FN_HASATTR, %#, JOBSELECT), 1, get(%#/JOBSELECT), monitor)]

&CMD_JOBS/ALL [v(JOB_GO)]=$+jobs/all:@force %#=+jobs/select all

&CMD_JOBS/CATCHUP [v(JOB_GO)]=$+jobs/catchup:@switch [u(%va/HAS_ACCESS, %#)]=0*, {@pemit %#=Permission denied.}, {@pemit %#=You are now caught up on jobs.;&LAST_CONN %#=[secs()];@dolist lcon(%va)={think [u(%va/FN_READERS, ##, %#)]}}

&CMD_JOBS/CATCHUP2 [v(JOB_GO)]=$+jobs/catchup *:@switch [u(%va/HAS_ACCESS, %#)][setq(0, lcstr(%0))][setq(0, u(%va/FN_INFIX2POSTFIX, map(%va/MAP_JOBSELECT, u(%va/FN_TOKENLIST, %q0))))][not(strmatch(%q0, *#-1 MISMATCHED PARENS*))][not(strmatch(%q0, *#-1 SYNTAX ERROR*))][default(%#/JOBSN, 0)]=0*, @pemit %#=Permission denied., 10*, @pemit %#=Mismatched parentheses., 110*, @pemit %#=Syntax error., 1110*, @pemit %#=You must set &4JOBSN me=1 to make use of this command., {@pemit %#=You are now caught up on jobs matching %q0.;@dolist [setq(1, filter(%va/FIL_GOING, lcon(%va)))][u(%va/FN_S-INIT)][map(%va/MAP_PARSESTACK, %q0)][u(%va/FN_S-PEEK)]={think [u(%va/FN_READERS, ##, %#)]}}

&CMD_JOBS/CLEAN [v(JOB_GO)]=$+jobs/clean:@switch [u(%va/HAS_ACCESS, %#)]=0*, {@pemit %#=Permission denied.}, {@trigger %va/TRIG_CLEAN;@pemit %#=Removing all non-player entries from Job Data.}

&CMD_JOBS/COMPRESS [v(JOB_GO)]=$+jobs/compress:@switch [u(%va/FN_WIZONLY, %#)][words(remove(lcon(%va), #-1))]=0*, {@pemit %#=Permission denied.}, 10*, {&JOBS_NUM %va=0;@pemit %#=Compressed. The next job number will be [inc(get(%va/JOBS_NUM))].}, {@dolist [lnum(1, words(lcon(%va)))]={@name [extract(revwords(lcon(%va)), ##, 1)]=Job ##};&JOBS_NUM %va=[words(lcon(%va))];@pemit %#=Compressed. The next job number will be [inc(get(%va/JOBS_NUM))].}

&CMD_JOBS/CREDITS [v(JOB_GO)]=$+jobs/credits:@pemit %#=[u(%va/FN_HEADER, Anomaly Jobs)]%r%rVersion: [u(%va/VERSION)][space(5)]Release: [u(%va/RELEASE)]%r%rAuthor: [u(%va/CREDITS)]%r%rMaintainer: [u(%va/MAINTAINER)]%r%rContributors: [u(%va/CONTRIBUTORS)]%r%r[u(%va/LICENSE)]%r%r[u(%va/FN_FOOTER)]

&CMD_JOBS/DATE [v(JOB_GO)]=$+jobs/date:@force %#=+jobs/select all sort=date

&CMD_JOBS/DUE [v(JOB_GO)]=$+jobs/due:@force %#=+jobs/select all sort=due

&CMD_JOBS/FROM [v(JOB_GO)]=$+jobs/from *:@force %#=+jobs/select source=%0

&CMD_JOBS/LIST [v(JOB_GO)]=$+jobs/list *:@force %#=+jobs/select bucket=%0

&CMD_JOBS/MINE [v(JOB_GO)]=$+jobs/mine:@force %#=+jobs/select mine

&CMD_JOBS/NEW [v(JOB_GO)]=$+jobs/new:@force %#=+jobs/select new

&CMD_JOBS/OVERDUE [v(JOB_GO)]=$+jobs/overdue:@force %#=+jobs/select overdue

&CMD_JOBS/PRI [v(JOB_GO)]=$+jobs/pri:@force %#=+jobs/select all sort=pri

&CMD_JOBS/REPORTS [v(JOB_GO)]=$+jobs/reports *:@switch [and(u(%va/HAS_ACCESS, %#), u(%va/STATS_ACCESS, %#))][u(%va/FN_HASATTR, %va, REPORT_[first(%0, =)])][gt(words(%0, =), 1)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is no report by that name. See '[ansi(h, +jobs/reports)]' for a list of valid reports.}, 110*, {@pemit %#=[u(%va/FN_HEADER, [secure(ucstr(%0))] Report)]%r;@pemit %#=[u(%va/REPORT_[secure(%0)])];@pemit %#=[u(%va/FN_FOOTER)]}, {@pemit %#=[u(%va/FN_HEADER, [secure(first(ucstr(%0), =))] Report)]%r;@pemit %#=[u(%va/REPORT_[first(secure(%0), =)], rest(secure(%0), =))];@pemit %#=[u(%va/FN_FOOTER)]}

&CMD_JOBS/REPORTS2 [v(JOB_GO)]=$+jobs/reports:@switch [and(u(%va/HAS_ACCESS, %#), u(%va/STATS_ACCESS, %#))]=0, {@pemit %#=Permission denied.}, {@pemit %#=[u(%va/FN_HEADER, Available Reports)]%r[ansi(hc, [ljust(Name, 10)][ljust(Description, u(%va/FN_FLEXWIDTH, 59))][rjust(Type, 10)])]%r[u(%va/FN_BREAK)];@pemit %#=[iter(sort(ucstr(map(%va/MAP_REPORTS, lattr(%va/REPORT_*)))), [ljust(##, 10)][u(%va/FN_STREXACT, rest(get(%va/RTITLE_##), |), u(%va/FN_FLEXWIDTH, 59))][rjust(first(get(%va/RTITLE_##), |), 10)], %B, %R)];@pemit %#=[u(%va/FN_FOOTER, [ansi(h, +jobs/reports <report>)])]}

&CMD_JOBS/SEARCH [v(JOB_GO)]=$+jobs/search *:@force %#=+jobs/select search="%0"

&CMD_JOBS/SELECT [v(JOB_GO)]=$+jobs/select *:@switch [u(%va/HAS_ACCESS, %#)][setq(0, before(lcstr(%0), sort=))][setq(0, u(%va/FN_INFIX2POSTFIX, map(%va/MAP_JOBSELECT, u(%va/FN_TOKENLIST, %q0))))][not(strmatch(%q0, *#-1 MISMATCHED PARENS*))][not(strmatch(%q0, *#-1 SYNTAX ERROR*))][setq(9, u(%va/FN_TRIM, after(lcstr(%0), sort=)))][ifelse(setr(8, strmatch(%q9, -*)), setq(9, mid(%q9, 1, dec(strlen(%q9)))),)][setq(9, ifelse(strlen(%q9), %q9, jobnum))][u(%va/FN_HASATTRP, %va, SORTBY_%q9)][setq(1, filter(%va/FIL_GOING, lcon(%va)))][u(%va/FN_S-INIT)][map(%va/MAP_PARSESTACK, %q0)][setq(7, filter(%va/FIL_JOBSELECT, ifelse(%q8, revwords(sortby(%va/SORTBY_%q9, u(%va/FN_S-PEEK))), sortby(%va/SORTBY_%q9, u(%va/FN_S-PEEK)))))]=0*, @pemit %#=Permission denied., 10*, @pemit %#=Mismatched parentheses., 110*, @pemit %#=Syntax error., 1110, @pemit %#=Invalid sort type., {@pemit %#=[u(%va/FN_JOBSHEADER, %#)];@dolist %q7=@pemit %#=[u(%va/FN_JOBLIST, ##, %#)];@wait 0=@pemit %#=[u(%va/FN_FOOTER, * Denotes New Activity)]}

&CMD_JOBS/SORT [v(JOB_GO)]=$+jobs/sort:@force %#=+jobs/select all sort=bucket

&CMD_JOBS/WHO [v(JOB_GO)]=$+jobs/who *:@force %#=+jobs/select who=%0

&CMD_JOBS/WHO2 [v(JOB_GO)]=$+jobs/who:@switch [u(%va/HAS_ACCESS, %#)]=0*, {@pemit %#=Permission denied.}, {@pemit %#=You must identify a player.}

&CMD_MYJOB/ADD [v(JOB_GO)]=$+myjob/add *=*:@switch [not(u(%va/FN_GUEST, %#))][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][or(and(u(%va/IS_PUBLIC, %q0), match(get(%q0/OPENED_BY), %#)), u(%va/FN_MYACCESSCHECK, parent(%q0), %#, %q0),)][not(u(%va/FN_HASATTR, %q0, LOCKED))]=0*, @pemit %#=This command is not available to guests., 10*, @pemit %#=That is an invalid job number., 110*, @pemit %#=[name(%q0)] is not yours. You can only modify your own jobs., 1110*, @pemit %#=That job is locked and cannot be changed at this time., {@pemit %#=Comments to [name(%q0)] added.;@trigger %va/TRIG_ADD=%q0, trim(%1), %#, ADD;@trigger %va/TRIG_BROADCAST=%q0, %#, ADD}

&CMD_MYJOB/HELP [v(JOB_GO)]=$+myjob/help *:@switch [setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)]=0*, {@pemit %#=That is not a valid job. Type '[ansi(h, +jobs)]' for a list of valid jobs.}, {@pemit %#=[u(%va/FN_HEADER, MyJob Help)];@pemit %#=[ifelse(u(%va/FN_HASATTR, parent(%q0), MYHELP), u(%q0/MYHELP), No +myjob help has been defined for that bucket.)];@pemit %#=[u(%va/FN_FOOTER)]}

&CMD_MYJOB/SUMSET [v(JOB_GO)]=$+myjob/sumset */*=*:@switch [not(u(%va/FN_GUEST, %#))][isdbref(setr(0, u(%va/FN_FIND-JOB, %0)))][u(%va/FN_HASATTRP, parent(%q0), MYACCESS_[trim(%1)])][and(u(%va/CONFIG_ACCESS, %#), u(parent(%q0)/MYACCESS_[trim(%1)], %#))][not(u(%va/IS_LOCKED, %q0, %#))][u(parent(%q0)/MYPROCESS_[trim(%1)], trim(%2), %q0, %#)]=0*, {@pemit %#=This command is not available to guests.}, 10*, {@pemit %#=There is no such job. See '[ansi(h, +jobs)]' for a list of valid jobs.}, 110*, {@pemit %#='[trim(%1)]' is not a valid parameter. Valid parameters for [name(%q0)] are [u(%va/FN_ITEMIZE, map(%va/MAP_PARAMS, lattr(parent(%q0)/MYPROCESS_*)))].}, 1110*, {@pemit %#=You either can not use the +myjob/sumset command, or set that parameter.}, 11110*, {@pemit %#=That job is presently [ifelse(u(%va/FN_HASATTRP, %q0, CHECKOUT), checked out to%b[name(first(get(%q0/CHECKOUT)))], locked)]}, 111110*, {@pemit %#=[u(%q0/MYERROR_[trim(%1)]%q2)]}, {@trigger %va/TRIG_BROADCAST=%q0, %#, MYS, [ucstr(trim(%1))];&%q3 %q0=%q1;@trigger %va/TRIG_ADD=%q0, [ucstr(trim(%1))] parameter updated to '[trim(%2)]', %#, MYS}

&CMD_MYJOB/VIEW [v(JOB_GO)]=$+myjob *:@switch [not(u(%va/FN_GUEST, %#))][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][or(u(%va/FN_MYACCESSCHECK, parent(%q0), %#, %q0), u(%va/IS_TRANSPARENT, %q0), and(get(%q0/PUBLIC), match(get(%q0/OPENED_BY), %#)))]=0*, {@pemit %#=This command is not available to guests.}, 10*, {@pemit %#=That is not a valid job number.}, 110*, {@pemit %#=[name(%q0)] is not yours. You can only view your own jobs.}, {@pemit %#=[u(%va/FN_READERS, %q0, %#, 1)][u(%va/FN_HEADER, View [name(%q0)])]%r[u(%va/FN_MYBANNER, %q0)][ifelse(u(%va/FN_HASATTRP, %q0, MYSUMMARY), [ulocal(%va/FN_MYSUMMARY, %q0, %#)],)];@dolist [filter(%va/FIL_PUBLISHED, filter(%va/FIL_COMMENTS, sortby(%va/SORTBY_COMMENTS, lattr(%q0/COMMENT_*))))]={@pemit %#=[u(%va/FN_READJOB, ##, %q0)]};@wait 0=@pemit %#=[u(%va/FN_FOOTER)]}

&CMD_MYJOB/LAST [v(JOB_GO)]=$+myjob/last *=*:@switch [not(u(%va/FN_GUEST, %#))][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][or(u(%va/FN_MYACCESSCHECK, parent(%q0), %#, %q0), u(%va/IS_TRANSPARENT, %q0), and(get(%q0/PUBLIC), match(get(%q0/OPENED_BY), %#)))]=0*, {@pemit %#=This command is not available to guests.}, 10*, {@pemit %#=That is not a valid job number.}, 110*, {@pemit %#=[name(%q0)] is not yours. You can only view your own jobs.}, {@pemit %#=[u(%va/FN_READERS, %q0, %#, 1)][u(%va/FN_HEADER, View [name(%q0)])]%r[u(%va/FN_MYBANNER, %q0)][ifelse(u(%va/FN_HASATTRP, %q0, MYSUMMARY), [ulocal(%va/FN_MYSUMMARY, %q0, %#)],)];@dolist [extract(setr(1, filter(%va/FIL_PUBLISHED, filter(%va/FIL_COMMENTS, sortby(%va/SORTBY_COMMENTS, lattr(%q0/COMMENT_*))))), ifelse(lt(sub(words(%q1), trim(%1)), 1), 1, inc(sub(words(%q1), trim(%1)))), inc(trim(%1)))]={@pemit %#=[u(%va/FN_READJOB, ##, %q0)]};@wait 0=@pemit %#=[u(%va/FN_FOOTER)]}

&CMD_MYJOBS [v(JOB_GO)]=$+myjobs:@switch [u(%va/FN_GUEST, %#)][words(setr(0, filter(%va/FIL_MYJOBS, revwords(lcon(%va)))))]=1*, @pemit %#=This command is not available to guests., 00, @pemit %#=You have no +myjobs., {@pemit %#=[u(%va/FN_MYJOBSHEADER, %#)];@dolist %q0=@pemit %#=[u(%va/FN_MYJOBLIST, ##, %#)];@wait 0=@pemit %#=[u(%va/FN_FOOTER, [ansi(hr, *)] [ansi(hy, Denotes New Activity)])]}

&CMD_MYJOBS/CATCHUP [v(JOB_GO)]=$+myjobs/catchup:@pemit %#=You are now caught up on jobs.;&LAST_CONN %#=[secs()];@dolist lcon(%va)={think [u(%va/FN_READERS, ##, %#)]}

&CMD_PITCH [v(JOB_GO)]=$+pitch *=*:@switch [u(%va/FN_GUEST, %#)]=1, {@pemit %#=This command is not available to guests.}, {@pemit %#=You have pitched your idea to staff about '[trim(secure(%0))]'. Please remember that this is merely an idea [ansi(hu, pitch)], and not a request. Staff, for one reason or many, may decide not to go with the idea.;@trigger %va/TRIG_CREATE=%#, u(%va/FN_FIND-BUCKET, PITCH), 1, [u(%va/FN_STRTRUNC, trim(secure(%0)), 30)], trim(%1),,, 3}

@@ Deleted so that JRS's version can work.
&CMD_REQUEST [v(JOB_GO)]=

&CMD_TYPO [v(JOB_GO)]=$+typo *:@switch [u(%va/FN_GUEST, %#)]=1, {@pemit %#=This command is not available to guests.}, {@pemit %#=You have notified production staff of the typo, with the details '[u(%va/FN_STRTRUNC, trim(%0), get(%va/BUFFER))]';@trigger %va/TRIG_CREATE=%#, u(%va/FN_FIND-BUCKET, BUILD), 2, Typo Reported at %L, [u(%va/FN_STRTRUNC, trim(%0), get(%va/BUFFER))],,, 4}

@dolist VA VB VC={@cpattr %#/JOB_##=[v(JOB_GO)]/##}

@switch [v(JOB_PATCH)]=1, {@dolist STARTUP BUCKET_HEADER DATA_CHARS2 DISPLAY_MYHEADERS DISPLAY_MYJOB MYJOBS_HEADER FIL_DELETE FN_ANSIFY FN_COORD2ANG FN_EASYPIE_PENN FN_EASYPIE_TINY FN_GENDATA MAP_GENDATA MAP_GENDATA2 PENN_PIE PENN10_PIE PENN12_PIE FN_NEW_JOBS FN_PACK IS_PLAYER JOBS_HEADER JOBS_HEADER2 MAP_ANSIFY MAP_ARTSGRAPH MAP_NAME2 MAP_NEW MAP_ISPLAYER MAP_PMATCH MAP_READERS={@switch [hasattr(v(JOB_VA), ##)]=1, &## [v(JOB_VA)]}}

&CHARGRAPH [v(JOB_VA)]=@+-/!*ox#.X$^`~O>

&COLORGRAPH_1 [v(JOB_VA)]=gG

&COLORGRAPH_2 [v(JOB_VA)]=yY

&COLORGRAPH_3 [v(JOB_VA)]=rR

&COLORGRAPH_4 [v(JOB_VA)]=cC

&COLORGRAPH_5 [v(JOB_VA)]=bB

&COLORGRAPH_6 [v(JOB_VA)]=mM

&COLORGRAPH_7 [v(JOB_VA)]=wW

&COLORGRAPH_8 [v(JOB_VA)]=hX

&COLORGRAPH_9 [v(JOB_VA)]=hC

&COLORGRAPH_10 [v(JOB_VA)]=hB

&COLORGRAPH_11 [v(JOB_VA)]=hR

&COLORGRAPH_12 [v(JOB_VA)]=hY

&COLORGRAPH_13 [v(JOB_VA)]=hG

&COLORGRAPH_14 [v(JOB_VA)]=hM

&COLORGRAPH_15 [v(JOB_VA)]=hW

&COLORGRAPH_16 [v(JOB_VA)]=hX

&COLORGRAPH_17 [v(JOB_VA)]=hC

&DATA_31-15 [v(JOB_VA)]=@@@@####$$$^^^&&&**((())__+++{{}}

&DATA_CHARS [v(JOB_VA)]=abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ`1234567890-=~!@#$^&*()_+{}/;':"<>?, .

&DISPLAY_# [v(JOB_VA)]=[u(%va/FN_STREXACT, %0, default(%#/JOBSWIDTH_#, 8))]

&DISPLAY_A [v(JOB_VA)]=[u(%va/FN_STREXACT, ifelse(isdbref(get(%0/ASSIGNED_TO)), name(get(%0/ASSIGNED_TO)), -), default(%#/JOBSWIDTH_A, 16))]

&DISPLAY_B [v(JOB_VA)]=[u(%va/FN_STREXACT, u(%va/FN_BUCKETNAME, %0), default(%#/JOBSWIDTH_B, 5))]

&DISPLAY_C [v(JOB_VA)]=[u(%va/FN_STREXACT, u(%va/FN_SHORT_DATE, convsecs(get(%0/OPENED_ON))), default(%#/JOBSWIDTH_C, 8))]

&DISPLAY_D [v(JOB_VA)]=[u(%va/FN_STREXACT, switch(get(%0/STATUS), 0, --HOLD--, ifelse(get(%0/DUE_ON), ifelse(gt(secs(), get(%0/DUE_ON)), OVERDUE!, [u(%va/FN_SHORT_DATE, convsecs(get(%0/DUE_ON)))]), --------)), default(%#/JOBSWIDTH_D, 8))]

&DISPLAY_F [v(JOB_VA)]=[u(%va/FN_STREXACT, [ifelse(u(me/IS_LOCKED, %0), ifelse(u(%va/FN_HASATTRP, %0, CHECKOUT), C, L), -)][ifelse(u(me/IS_PUBLIC, %0), M, -)][ifelse(u(me/IS_TAGGED, %0), T, -)][ifelse(u(me/IS_PUBLISHED, %0), P, -)], default(%#/JOBSWIDTH_F, 4))]

&DISPLAY_M [v(JOB_VA)]=[u(%va/FN_STREXACT, u(%va/FN_SHORT_DATE, convsecs(get(%0/MODIFIED_ON))), default(%#/JOBSWIDTH_M, 8))]

&DISPLAY_O [v(JOB_VA)]=[u(%va/FN_STREXACT, name(first(get(%0/OPENED_BY))), default(%#/JOBSWIDTH_O, 16))]

&DISPLAY_S [v(JOB_VA)]=[u(%va/FN_STRTRUNC, center(switch([u(%va/FN_HASATTRP, %0, LOCKED)][u(%va/FN_HASATTRP, %0, CHECKOUT)], 1*, LOCKED, 01*, CHECKED, first(get(%va/STATUS_[get(%0/STATUS)]), |)), default(%#/JOBSWIDTH_S, 8)), default(%#/JOBSWIDTH_S, 8))]

&DISPLAY_T [v(JOB_VA)]=[u(%va/FN_STREXACT, get(%0/TITLE), default(%#/JOBSWIDTH_T, u(%va/FN_LEFTOVER)))]

&DISPLAY_BUCKET [v(JOB_VA)]=[rjust(ansi(h, Name:), 20)] [name(%q0)] [ifelse(u(%va/FN_STAFFALL, %#), %(%q0%),)] %([words(remove(children(%q0), #-1))] jobs in bucket%)%r[rjust(ansi(h, Locked To:), 20)] [ifelse(u(%va/FN_HASATTRP, %q0, ACCESS), [get(%q0/ACCESS)] [ifelse(u(%va/FN_ACCESSCHECK, %q0, %#), %(You have access%), %(You do not have access%))], *UNLOCKED*)]%r[rjust(ansi(h, Post Data:), 20)] %(Job system will post to these boards%)%r[u(%va/fn_columns, Complete: [u(%va/FN_FIND-BBNUM, get(%q0/POST_COMPLETE))]|Approve: [u(%va/FN_FIND-BBNUM, get(%q0/POST_APPROVE))]|Deny: [u(%va/FN_FIND-BBNUM, get(%q0/POST_DENY))], 16, |, 21)][ifelse(u(%va/FN_HASATTRP, %q0, TURNAROUND), %r[rjust(ansi(h, Turnaround:), 20)] [get(%q0/TURNAROUND)] hours %([div(get(%q0/TURNAROUND), 24)] days%),)]%r[rjust(ansi(h, Logfile:), 20)] [switch([first(version())]-[u(%va/FN_HASATTRP, %q0, LOGFILE)], PennMUSH-1, command.log, TinyMUSH-1, netmush.log, RhostMUSH-1, [get(%q0/LOGFILE)]_manual.log, *-1, M-[u(%q0/LOGFILE)].log, None)]%r[rjust(ansi(h, Hidden Status:), 20)] [switch([u(%va/FN_HASATTRP, %q0, HIDDEN)][gt(member(u(%#/JOBSH), %q0), 0)], 00, Unhidden, 01, Locally, 11, Globally Hidden & Locally Watched, 10, Globally, UNKNOWN CASE)]%r[rjust(ansi(h, +Myjobs Status:), 20)] [ifelse(u(%va/FN_HASATTRP, %q0, PUBLIC), Accessible, Inaccessible)]%r[rjust(ansi(h, Avg Resolve Time:), 20)] [u(%va/fn_trim, u(%va/FN_ART, %q0))]%r[rjust(ansi(h, Closure Stats:), 20)]%b[ljust(Completed: [after(grab(get(%q0/LIST_STATS), COM|*), |)], 16)][ljust(Deleted: [after(grab(get(%q0/LIST_STATS), DEL|*), |)], 16)][ljust(Approved: [after(grab(get(%q0/LIST_STATS), APR|*), |)], 16)]Denied: [after(grab(get(%q0/LIST_STATS), DNY|*), |)]%r[rjust(ansi(h, Desc:), 20)] [get(%q0/DESC)][ifelse(gt(words(setr(x, setdiff(lattr(%q0), u(%va/LIST_BADATTR, %q0)))), 0), %r[rjust(ansi(h, Provides:), 20)] %(Attributes provided to jobs in the bucket%)%r[u(%va/fn_columns, %qx, 16,, 21)],)][ifelse(gt(words(lattr(%q0/PROCESS_*)), 0), %r[rjust(ansi(h, Settings:), 20)] %(+job/sumset settings%)%r[u(%va/fn_columns, map(MAP_SETTINGS, lattr(%q0/PROCESS_*)), 16,, 21)],)]

&DISPLAY_BUCKET2 [v(JOB_VA)]=[rjust(ansi(h, Players:), 20)] %(Connected players with access to this bucket%)%r[u(%va/fn_columns, [u(%va/fn_trim, squish(iter(edit(objeval(%#, lwho()), %b, |), ifelse(and(u(%va/HAS_ACCESS, ##), u(%va/FN_ACCESSCHECK, %q0, ##)), name(##),), |, |), |), b, |)], 16, |, 21)]

&FIL_ACCESS [v(JOB_VA)]=u(%va/FN_ACCESSCHECK, %0, %#)

&FIL_BROADCAST [v(JOB_VA)]=ifelse(u(%va/FN_HASATTRP, %0, JOBS_SILENCE), 0, u(%va/FN_ACCESSCHECK, %q0, %0))

&FIL_BUCKET [v(JOB_VA)]=t(member(children(%1), %0))

&FIL_COMMENTS [v(JOB_VA)]=t(member(get(%va/LIST_VISCOMMENTS), first(get(%q0/%0), |)))

&FIL_DUEAFTER [v(JOB_VA)]=or(not(strlen(get(%0/DUE_ON))), eq(get(%0/DUE_ON), 0), gt(get(%0/DUE_ON), %1))

&FIL_ESC [v(JOB_VA)]=eq(get(%0/PRIORITY), %1)

&FIL_GOING [v(JOB_VA)]=not(default(%0/GOING, 0))

&FIL_ISBUCKET [v(JOB_VA)]=member(%vc, parent(%0))

&FIL_ISPLAYER [v(JOB_VA)]=switch(words(%0, :), 1, or(hastype(%0, player), member(lcon(%vb), %0)), and(hastype(first(%0, :), player), strmatch(%0, u(%va/FN_OBJID, first(%0, :)))))

&FIL_JOBSELECT [v(JOB_VA)]=cor(u(%va/FN_ACCESSCHECK, parent(%0), %#, %0), u(%va/FIL_MINE, %0))

&FIL_MINE [v(JOB_VA)]=gt(member([switch(loc(get(%0/assigned_to)), %vb, u(%va/FN_JGROUPMEMBERS, get(%0/assigned_to)), get(%0/assigned_to))] [get(%0/tagged_for)], %#), 0)

&FIL_MYJOBS [v(JOB_VA)]=cor(u(%va/FN_MYACCESSCHECK, parent(%0), %#, %0), cor(cand(get([parent(%0)]/PUBLIC), match(get(%0/OPENED_BY), %#)), u(%va/IS_TRANSPARENT, %0)))

&FIL_NEW [v(JOB_VA)]=u(%va/FIL_NEW0, %0)

&FIL_NEW0 [v(JOB_VA)]=gt(get(%0/MODIFIED_ON), get(%#/LAST_CONN))

&FIL_NEW1 [v(JOB_VA)]=or(not(match(get(%0/LIST_JOBSN), %#|*)), gt(dec(get(%0/NUM_COMMENT)), last(grab(get(%0/LIST_JOBSN), %#|*), |)))

&FIL_NEWCOMMENTS0 [v(JOB_VA)]=and(gt(extract(get(%q0/%0), 2, 1, |), %q1), gt(member(get(%va/LIST_VISCOMMENTS), first(get(%q0/%0), |)), 0))

&FIL_NEWCOMMENTS1 [v(JOB_VA)]=gt(last(%0, _), last(grab(get(%q0/LIST_JOBSN), %#|*), |))

&FIL_NOSPAM [v(JOB_VA)]=not(u(%va/FN_HASATTR, %0, JOBS_NOSPAM))

&FIL_NOTPLAYER [v(JOB_VA)]=not(u(FIL_ISPLAYER, %0))

&FIL_OVERDUE [v(JOB_VA)]=ifelse(get(%0/DUE_ON), gt(secs(), get(%0/DUE_ON)), 0)

&FIL_PUBLISHED [v(JOB_VA)]=or(u(%q0/PUBLISH), hasflag(%q0/%0, no_inherit), u(%va/FN_MYACCESSCHECK, parent(%q0), %#, %q0), strmatch(extract(get(%q0/%0), 3, 1, |), %#))

&FIL_SOURCE [v(JOB_VA)]=t(member(get(%0/OPENED_BY), %1))

&FIL_STAT_STATUS [v(JOB_VA)]=and(strmatch(get(%0/STATUS), %qa), not(u(%va/FIL_OVERDUE, %0)))

&FIL_STATUS [v(JOB_VA)]=t(match(get(%va/%0), %qa*, |))

&FIL_SEARCH [v(JOB_VA)]=t(words(grepi(%0, *, %1)))

&FIL_WHO [v(JOB_VA)]=strmatch(get(%0/ASSIGNED_TO), %1)

&FN_ACCESSCHECK [v(JOB_VA)]=and(u(%va/HAS_ACCESS, %1), or(u(%va/FN_WIZONLY, %1), band(add(elock(%0/speech, %1), gt(member(get(%1/JOBSB), u(FN_OBJID, %0)), 0), ifelse(strlen(%2), gt(member(get(%2/JOBACCESS), u(FN_OBJID, %1)), 0), 0)), 1)))

&FN_MYACCESSCHECK [v(JOB_VA)]=band(add(elock(%0/speech, %1), gt(member(get(%1/JOBSB), u(FN_OBJID, %0)), 0), ifelse(strlen(%2), gt(member(get(%2/JOBACCESS), u(FN_OBJID, %1)), 0), 0)), 1)

&FN_ADDSTAT [v(JOB_VA)]=[setq(x, ifelse(u(%va/FN_HASATTR, %1, LIST_STATS), get(%1/LIST_STATS),))][setq(0, match(%qx, %0|*))][setq(1, grab(%qx, %0|*))][ifelse(gt(%q0, 0), [set(%1, LIST_STATS:[setunion(ldelete(%qx, %q0), [first(%q1, |)]|[inc(rest(%q1, |))])])], [set(%1, LIST_STATS:[setunion(%qx, %0|1)])])]

&FN_ADDSTAT_ART [v(JOB_VA)]=null(set(%0, STAT_ART:[add(first(default(%0/STAT_ART, 0 0)), sub(secs(), get(%1/OPENED_ON)))] [inc(last(default(%0/STAT_ART, 0 0)))]))

&FN_ART [v(JOB_VA)]=u(%va/FN_TIME, round(fdiv(first(default(%0/STAT_ART, 0 0)), rest(default(%0/STAT_ART, 0 1))), 0))

&FN_ASSEMBLEPIE [v(JOB_VA)]=[setq(1, %1)][setq(0, 0)][map(%va/MAP_PIEDATA, %0, switch(%2,, %b, %2), |)]

&FN_BANNER [v(JOB_VA)]=u(%va/FN_SKIN, BANNER, %0, %1, %2, %3)

&FN_BARGRAPH [v(JOB_VA)]=[setq(4, ifelse(%5, %5, %B))][setq(5, ifelse(%2, %2, 2))][setq(6, ifelse(%3, ifelse(gt(%3, 16), 16, %3), 1))][setq(7, switch(%4,, #, %4))][setq(1, ifelse(%1, %1, 18))][setq(2, %q1)][setq(0, last(sort(%0, n, %q4, %q4), %q4))][setq(3, fdiv(%q0, %q1))][setq(x, iter(lnum(%q1), [setq(9, 0)][switch(%q2, %q1, rjust(u(FN_BARGRAPHAXIS, %q0), 5), ifelse(mod(%q1, 2), inc(div(%q1, 2)), div(%q1, 2)), rjust(u(FN_BARGRAPHAXIS, div(%q0, 2)), 5), [space(5)])]|[map(MAP_GRAPH, %0, %q4, %b)][setq(2, sub(%q2, 1))], %B, %R))]%qx%R[space(4)]0+[repeat(-, dec(add(mul(words(%0, %q4), %q5), words(%0, %q4))))]

&FN_BARGRAPHAXIS [v(JOB_VA)]=switch(log(%0), <5, %0, <6, [u(%va/FN_TRIM, u(%va/FN_STRTRUNC, fdiv(%0, 1E3), 4), r, .)]K, <9, [u(%va/FN_TRIM, u(%va/FN_STRTRUNC, fdiv(%0, 1E6), 4), r, .)]M, [u(%va/FN_TRIM, u(%va/FN_STRTRUNC, fdiv(%0, 1E9), 4), r, .)]B)

&FN_BREAK [v(JOB_VA)]=u(%va/FN_SKIN, BREAK, %0, %1, %2, %3)

&FN_BUCKETHEADER [v(JOB_VA)]=u(%va/FN_SKIN, BUCKETHEADER, %0, %1, %2, %3)

&FN_BUCKETLIST [v(JOB_VA)]=u(%va/FN_SKIN, BUCKETLIST, %0, %1, %2, %3)

&FN_BUCKETNAME [v(JOB_VA)]=ifelse(get(%0/GOING), GOING, ifelse(isdbref(parent(%0)), name(parent(%0)), ERROR))

&FN_CLEANFIND [v(JOB_VA)]=t(words(filter(%va/FIL_NOTPLAYER, get(%0/%1))))

&FN_CLEANFIX [v(JOB_VA)]=[setq(0, filter(%va/FIL_ISPLAYER, get(%0/%1)))][ifelse(words(%q0), %q0, owner(me))]

&FN_COLORPIE [v(JOB_VA)]=setq(0, u(fn_equalizepie, %1, %2))[setq(p, %0)][setq(1, u(%va/fn_rotatestr, setr(1, v(data_chars)), mod(round(fdiv(mul(%3, strlen(%q1)), 360), 0), 360)))][setq(a, %]%])][setq(b, %qa%qa)][setq(c, %qb%qb)][null(map(map_colorpie, %q0, %2))][setq(p, edit(%qp, |, ansi(n, |)))]%qP

&FN_COLUMNS [v(JOB_VA)]=switch(first(version()), RhostMUSH, [columns(%0, min(sub(79, ifelse(gt(%3, 78), 1, %3)), %1), div(sub(79, ifelse(gt(%3, 78), 1, %3)), %1), l,,, ifelse(gt(words(%3), 0), space(%3)),,, 1, %2)], PennMUSH, [align([ifelse(%3, dec(%3), 0)] [sub(78, ifelse(%3, dec(%3), 0))], %B, [table(%0, %1, sub(78, ifelse(%3, dec(%3), 0)), %2)])], columns(%0, %1, %2, %3))

&FN_CUTPIE [v(JOB_VA)]=setq(0, inc(%2))[setq(1, fdiv(%1, %2))][setq(2, power(%3, 2))][setq(5, iter(lnum(0, dec(%3)), round(mul(sqrt(sub(%q2, power(add(##, .7), 2))), %q1), 0)))][setq(5, revwords(%q5) [setr(8, inc(ceil(mul(%3, 2))))] %q5)][iter(lnum(-%3, %3), space(sub(%q8, setr(9, extract(%q5, #@, 1))))[mid(extract(%0, add(##, %q0), 1), shl(sub(%1, %q9), 1), shl(%q9, 2))],, |)]

&FN_DATECONV [v(JOB_VA)]=switch(words(%0, /), 3, convtime(XXX [switch([rjust(first(%0, /), 2, 0)], 01, Jan, 02, Feb, 03, Mar, 04, Apr, 05, May, 06, Jun, 07, Jul, 08, Aug, 09, Sep, 10, Oct, 11, Nov, 12, Dec)] [rjust(extract(%0, 2, 1, /), 2, 0)] 23:59:00 [switch(strlen(setr(0, last(%0, /))), 2, 20[rjust(%q0, 2, 0)], %q0)]), switch(convtime(%0), *-*, fold(FOLD_DATECONV, %0, secs()), convtime(%0)))

&FOLD_DATECONV [v(JOB_VA)]=add(%0, switch(%1, *d*, mul(86400, before(%1, d)), *h*, mul(3600, before(%1, h)), *m*, mul(60, before(%1, m)), *s*, before(%1, s), 0))

&FN_EASYPIE [v(JOB_VA)]=edit(u(%va/FN_PIELEGEND, u(%va/FN_COLORPIE, u(%va/FN_CUTPIE, foreach(%va/FOREACH_BRACKET, v(DATA_31-15)), 31, 15, %0), map(%va/MAP_EASYPIE, %1, %2), %2, %4), map(%va/MAP_EASYPIE2, %1, %2), %2, %3), |, %r)

&FN_EQUALIZEPIE [v(JOB_VA)]=setq(0, u(FN_LADD, map(%va/MAP_EQUALIZEPIE, %0, %1), %1))[setq(1, strlen(v(DATA_CHARS)))][map(MAP_EQUALIZEPIE2, %0, %1)]

&FN_FIND-BBDBREF [v(JOB_VA)]=extract(u([get(%vc/BBPOCKET)]/GROUPS), %0, 1)

&FN_FIND-BBNUM [v(JOB_VA)]=member(u([get(%vc/BBPOCKET)]/GROUPS), %0)

&FN_FIND-BUCKET [v(JOB_VA)]=localize(ifelse(or(strmatch(name(setr(0, locate(%vc, trim(%0), iT))), trim(%0)), strmatch(%q0, trim(%0))), %q0, #-1))

&FN_FIND-JGROUP [v(JOB_VA)]=localize(ifelse(or(strmatch(name(setr(0, locate(%vb, trim(%0), iT))), trim(%0)), strmatch(%q0, trim(%0))), %q0, #-1))

&FN_FIND-JOB [v(JOB_VA)]=localize(ifelse(or(strmatch(name(setr(0, locate(%va, Job [trim(%0)], iT))), Job [trim(%0)]), strmatch(%q0, trim(%0))), %q0, #-1))

&FN_FLAG [v(JOB_VA)]=[ansi(h, %[)][ansi(switch(%1,, hy, %1), %0)][ansi(h, %])]

&FN_FLAGS [v(JOB_VA)]=u(%va/FN_SKIN, FLAGS, %0, %1, %2, %3)

&FN_FLEXWIDTH [v(JOB_VA)]=add(%0, switch(default(%#/JOBSWIDTH, [width(%#)]), #-1*, 0, sub(default(%#/JOBSWIDTH, width(%#)), 80)))

&FN_FOOTER [v(JOB_VA)]=u(%va/FN_SKIN, FOOTER, %0, %1, %2, %3)

&FN_HASATTR [v(JOB_VA)]=switch(first(version()), PennMUSH, hasattrval(%0, %1), hasattr(%0, %1))

&FN_HASATTRP [v(JOB_VA)]=switch(first(version()), PennMUSH, hasattrpval(%0, %1), hasattrp(%0, %1))

&FN_HEADER [v(JOB_VA)]=u(%va/FN_SKIN, HEADER, %0, %1, %2, %3)

&FN_INFIX2POSTFIX [v(JOB_VA)]=[u(%va/FN_S-INIT)][setq(v, map(%va/MAP_PARAMS, lattr(%va/SEL_*)))][u(%va/FN_TRIM, squish([map(%va/MAP_INFIX2POSTFIX, %0)]%B[u(%va/FN_S-POP-BINARY)][switch(1, t(member(%( %), u(%va/FN_S-PEEK))), #-1 MISMATCHED PARENS)]))]

&FN_ISNEW [v(JOB_VA)]=u(FIL_NEW[default(%1/JOBSN, 0)], %0)

&FN_ITEMIZE [v(JOB_VA)]=localize(switch([setr(0, [itemize(%0, %1)])], #-1*, switch([setr(1, [elist(%0, and, %1)])], #-1*, u(fn_pretty, %0, %1), %q1), %q0))

&FN_JGROUPMEMBERS [v(JOB_VA)]=switch(first(version()), PennMUSH, lsearch(all, eplayers, %[u(%0/ISMEMBER, ##)%]), RhostMUSH, searchng(eplayer=u(%0/ISMEMBER, ##)), search(eplayer=u(%0/ISMEMBER, ##)))

&FN_JOBLIST [v(JOB_VA)]=ifelse(t(%0), u(%va/FN_SKIN, JOBLIST, %0, %1, %2, %3),)

&FN_JOBSHEADER [v(JOB_VA)]=u(%va/FN_SKIN, JOBSHEADER, %0, %1, %2, %3)

&FN_LADD [v(JOB_VA)]=switch([ladd(%0, %1)], #-1*, lmath(add, %0, %1), ladd(%0, %1))

&FN_LEFTOVER [v(JOB_VA)]=max(5, sub(u(%va/FN_FLEXWIDTH, 79), fold(%va/FOLD_ADD, 7[foreach(%va/FOREACH_LEFTOVER, %qj)])))

&FN_MAXWIDTH [v(JOB_VA)]=last(sort(map(map_maxwidth, %0, |, %b), n))

&FN_MONITORCHECK [v(JOB_VA)]=and(or(u(%va/FN_ACCESSCHECK, %0, %1), u(%va/FN_WIZONLY, %1)), switch([u(%va/FN_HASATTRP, %0, HIDDEN)][gt(member(get(%1/JOBSH), %0), 0)], 01, 0, 10, 0, 11, 1, 1), isdbref(parent(%0)))

&FN_MYBANNER [v(JOB_VA)]=u(%va/FN_SKIN, MYBANNER, %0, %1, %2, %3)

&FN_MYJOBLIST [v(JOB_VA)]=ifelse(t(%0), u(%va/FN_SKIN, MYJOBLIST, %0, %1, %2, %3),)

&FN_MYJOBSHEADER [v(JOB_VA)]=u(%va/FN_SKIN, MYJOBSHEADER, %0, %1, %2, %3)

&FN_MYSUMMARY [v(JOB_VA)]=u(%va/FN_SKIN, MYSUMMARY, %0, %1, %2, %3)

&FN_OBJID [v(JOB_VA)]=localize(switch(1, and(isint(setr(0, convtime(ctime(%0)))), gt(%q0, 0)), %0:%q0, and(isint(setr(0, convtime(createtime(%0)))), gt(%q0, 0)), %0:%q0, %0))

&FN_PCT [v(JOB_VA)]=mul(round(ifelse(gt(get(%va/MAX_JOBS), 0), max(fdiv(words(remove(lcon(%va), #-1)), get(%va/MAX_JOBS)), fdiv(strlen(lcon(%va)), get(%va/BUFFER))), fdiv(strlen(lcon(%va)), get(%va/BUFFER))), 2), 100)

&FN_PIEESCAPE [v(JOB_VA)]=case(ord(%0), 92, %%%%,91, %%%[, 93, %%%], 37, %%%%,%0)

&FN_PIELEGEND [v(JOB_VA)]=[setq(d, inc(u(fn_maxwidth, %0)))][setq(n, %0[repeat(|, max(0, sub(setr(a, add(words(%1, %2), %3)), setr(b, words(%0, |)))))])][setq(m, repeat(|, %3)[edit(%1, ifelse(%2, %2, %b), |)][repeat(|, max(0, sub(%qb, %qa)))])][map(map_pielegend, lnum(1, words(%qm, |)), %b, |)]

&FN_PLAYERLIST [v(JOB_VA)]=u(%va/FN_ITEMIZE, map(MAP_NAME, get(%0/OPENED_BY), %b, |), |)

&FN_PRETTY [v(JOB_VA)]=switch(words(%0, switch(%1,, %b, %1)), 0, %0, 1, %0, [ldelete(edit(%0, switch(%1,, %b, %1), %,%b), words(%0, switch(%1,, %b, %1)), %,)]%band%b[last(%0, switch(%1,, %b, %1))])

&FN_READERS [v(JOB_VA)]=[ifelse(%2, set(%0, LIST_READERS:[setunion(setdiff(get(%0/LIST_READERS), grab(get(%0/LIST_READERS), %1|*)), %1|[dec(get(%0/NUM_COMMENT))])]),)][set(%0, LIST_JOBSN:[setunion(setdiff(get(%0/LIST_JOBSN), grab(get(%0/LIST_JOBSN), %1|*)), %1|[dec(get(%0/NUM_COMMENT))])])]

&FN_READJOB [v(JOB_VA)]=u(%va/FN_SKIN, READ, %0, %1, %2, %3)

&FN_ROTATESTR [v(JOB_VA)]=mid(%0, %1, 3999)[mid(%0, 0, %1)]

&FN_S-INIT [v(JOB_VA)]=setq(S,)

&FN_S-PUSH [v(JOB_VA)]=setq(S, %0`%qS)

&FN_S-POP [v(JOB_VA)]=[first(%qS, `)][setq(S, rest(%qS, `))]

&FN_S-PEEK [v(JOB_VA)]=first(%qS, `)

&FN_S-POP-BINARY [v(JOB_VA)]=switch(1, t(match(OR AND, u(fn_s-peek))), [u(fn_s-pop)]%B[u(fn_s-pop-binary)])

&FN_S-POP-UNARY [v(JOB_VA)]=switch(1, t(match(NOT, u(fn_s-peek))), [u(fn_s-pop)]%B[u(fn_s-pop-unary)])

&FN_SHORT_DATE [v(JOB_VA)]=[switch(extract(%0, 2, 1), Jan, 01, Feb, 02, Mar, 03, Apr, 04, May, 05, Jun, 06, Jul, 07, Aug, 08, Sep, 09, Oct, 10, Nov, 11, Dec, 12, ??)]/[extract(%0, 3, 1)]/[mid(last(%0), 2, 2)]

&FN_SKIN [v(JOB_VA)]=[setq(z, default(%#/JOBSKIN, DEFAULT))][ifelse(and(u(FN_HASATTR, me, %qz_SKIN), u(FN_HASATTR, me, %qz_%0)), u(%qz_%0, %1, %2, %3, %4), u(DEFAULT_%0, %1, %2, %3, %4))]

&FN_STAFFSUM [v(JOB_VA)]=u(FN_SKIN, STAFFSUM, %0, %1, %2, %3)

&FN_STREXACT [v(JOB_VA)]=ljust(u(FN_STRTRUNC, %0, %1), %1)

&FN_STRINGSECS [v(JOB_VA)]=switch(first(version()), PennMUSH, stringsecs(%0), ladd(map(MAP_ETIME, %0)))

&FN_STRTRUNC [v(JOB_VA)]=localize(switch([setr(0, [strtrunc(%0, %1)])], #-1*, left(%0, %1), %q0))

&FN_SUMMARY [v(JOB_VA)]=u(FN_SKIN, SUMMARY, %0, %1, %2, %3)

&FN_TIME [v(JOB_VA)]=localize([setq(2, mod(%0, 86400))][rjust([div(%0, 86400)], 2, 0)]:[rjust(div(%q2, 3600), 2, 0)]:[rjust(div(mod(%q2, 3600), 60), 2, 0)]:[rjust(mod(%q2, 60), 2, 0)])

&FN_TOKENLIST [v(JOB_VA)]=u(fn_trim, squish(foreach(FN_TOKENPARSE, %0)))

&FN_TOKENPARSE [v(JOB_VA)]=switch(%0, ", setq(Q, switch(%qQ, 1, 0, 1)), %B, switch(%qQ, 1, ~, %B), |, %BOR%B, &, %BAND%B, !, %BNOT%B, %(, %B%(%B, %), %B%)%B, %0)

&FN_TRIM [v(JOB_VA)]=switch(first(version()), PennMUSH, trimtiny(%0, %1, %2), trim(%0, %1, %2))

&FOLD_ADD [v(JOB_VA)]=add(%0, %1)

&FOREACH_BRACKET [v(JOB_VA)]=%[%0

&FOREACH_COLORPIE [v(JOB_VA)]=setq(p, edit(%qp, %[%0, %]))

&FOREACH_LEFTOVER [v(JOB_VA)]=%b[inc(switch(%0, #, default(%#/JOBSWIDTH_#, 8), A, default(%#/JOBSWIDTH_A, 16), B, default(%#/JOBSWIDTH_B, 5), C, default(%#/JOBSWIDTH_C, 8), D, default(%#/JOBSWIDTH_D, 8), F, default(%#/JOBSWIDTH_F, 4), M, default(%#/JOBSWIDTH_M, 8), O, default(%#/JOBSWIDTH_O, 16), S, default(%#/JOBSWIDTH_S, 8), 0))]

&HEADER_# [v(JOB_VA)]=u(FN_STREXACT, DB#, default(%#/JOBSWIDTH_#, 8))

&HEADER_A [v(JOB_VA)]=u(FN_STREXACT, Assigned To, default(%#/JOBSWIDTH_A, 16))

&HEADER_B [v(JOB_VA)]=u(FN_STREXACT, Type, default(%#/JOBSWIDTH_B, 5))

&HEADER_C [v(JOB_VA)]=u(FN_STREXACT, Opened, default(%#/JOBSWIDTH_C, 8))

&HEADER_D [v(JOB_VA)]=u(FN_STREXACT, Due On, default(%#/JOBSWIDTH_D, 8))

&HEADER_F [v(JOB_VA)]=u(FN_STREXACT, Flag, default(%#/JOBSWIDTH_F, 4))

&HEADER_M [v(JOB_VA)]=u(FN_STREXACT, Modified, default(%#/JOBSWIDTH_M, 8))

&HEADER_O [v(JOB_VA)]=u(FN_STREXACT, Opened By, default(%#/JOBSWIDTH_O, 16))

&HEADER_S [v(JOB_VA)]=u(FN_STREXACT, Status, default(%#/JOBSWIDTH_S, 8))

&HEADER_T [v(JOB_VA)]=u(%va/FN_STREXACT, Title, default(%#/JOBSWIDTH_T, u(%va/FN_LEFTOVER)))

&IS_HIDDEN [v(JOB_VA)]=udefault(%0/HIDDEN, 0)

&IS_LOCKED [v(JOB_VA)]=ifelse(u(%va/FN_HASATTRP, %0, CHECKOUT), switch(first(get(%0/CHECKOUT)), %1, 0, 1), udefault(%0/LOCKED, 0))

&IS_PUBLIC [v(JOB_VA)]=udefault(%0/PUBLIC, 0)

&IS_PUBLISHED [v(JOB_VA)]=udefault(%0/PUBLISH, 0)

&IS_SUMMARY [v(JOB_VA)]=u(%va/FN_HASATTRP, %0, SUMMARY)

&IS_TAGGED [v(JOB_VA)]=t(words(get(%0/TAGGED_FOR)))

&IS_TRANSPARENT [v(JOB_VA)]=u(%va/FN_HASATTRP, %0, TRANSPARENT)

&JOBS_DEFAULT [v(JOB_VA)]=BTDAS

&LIST_ACTIONS [v(JOB_VA)]=ADD Player input|ASN Assignment|CKI Check In|CKO Check Out|CLN Clone|CRE Create|DUE Due date|EDT Edited job|LOK Locked Job|MRG Merged job|NAM Re-name job|PUB Publication|SRC Source change|STA Status change|SUM Sumset change|TAG Job tag|TRN Transfer|UND Undelete job|UNL Unlock job|UNP Unpublish|COM +job/complete|DNY +job/deny|APR +job/approve|DEL +job/delete

&LIST_BADATTR [v(JOB_VA)]=Created Modified ACCESS Desc [lattr(%0/ACCESS_*)] [lattr(%0/ERROR_*)] [lattr(%0/PROCESS_*)] LIST_STATS STAT_ART TURNAROUND

&LIST_VISCOMMENTS [v(JOB_VA)]=ADD CRE COM MAI APR DEL DNY

&MAP_ACTIONS [v(JOB_VA)]=rest(%0, |)

&MAP_ACTIONS2 [v(JOB_VA)]=first(%0, |)

&MAP_COLORPIE [v(JOB_VA)]=foreach(foreach_colorpie, mid(%q1, 0, setr(9, last(%0, :))))[setq(x, before(mid(%0, 1, 100), :))][setq(h, u(%va/fn_pieescape, mid(%0, 0, 1)))][setq(i, %qh%qh)][setq(j, %qi%qi)][setq(k, %qj%qj)][setq(p, edit(edit(edit(edit(%qp, %qc, ansi(%qx, %qk)), %qb, ansi(%qx, %qj)), %qa, ansi(%qx, %qi)), %], ansi(%qx, %qh)))][setq(1, mid(%q1, %q9, 256))]

&MAP_EASYPIE [v(JOB_VA)]=extract(%0, 1, switch(%0, :*, 3, 2), :)

&MAP_EASYPIE2 [v(JOB_VA)]=ldelete(%0, switch(%0, :*, 3, 2), :)

&MAP_ETIME [v(JOB_VA)]=switch(%0, *d, mul(86400, before(%0, d)), *h, mul(3600, before(%0, h)), *m, mul(60, before(%0, m)), *s, before(%0, s), 0)

&MAP_EQUALIZEPIE [v(JOB_VA)]=last(%0, :)

&MAP_EQUALIZEPIE2 [v(JOB_VA)]=revwords(setr(8, round(fdiv(mul(%q1, setr(7, last(%0, :))), %q0), 0))[setq(1, sub(%q1, %q8))][setq(0, sub(%q0, %q7))]:[rest(revwords(%0, :), :)], :)

&MAP_GRAPH [v(JOB_VA)]=[setq(9, ifelse(gt(inc(%q9), %q6), 1, inc(%q9)))][ifelse(lte(%q2, add(fdiv(%0, %q3), 0.5)), ansi(v(COLORGRAPH_%q9), repeat(%q7, %q5)), repeat(%b, %q5))]

&MAP_INDENT2 [v(JOB_VA)]=%b%b%0

&MAP_INFIX2POSTFIX [v(JOB_VA)]=switch(1, t(match(%qv, first(%0, =))), [%0]%B[u(%va/FN_S-POP-UNARY)], t(match(OR AND, %0)), [u(%va/FN_S-POP-BINARY)][u(%va/FN_S-PUSH, %0)], strmatch(NOT, %0), [u(%va/FN_S-PUSH, %0)], strmatch(%(, %0), [u(%va/FN_S-PUSH, %0)], strmatch(%), %0), [u(%va/FN_S-POP-BINARY)][switch(u(%va/FN_S-PEEK), %(, null(u(%va/FN_S-POP)), #-1 MISMATCHED PARENS)]%B[u(%va/FN_S-POP-UNARY)], #-1 SYNTAX ERROR)

&MAP_JGROUP [v(JOB_VA)]=switch(%0, +*, u(%va/FN_JGROUPMEMBERS, u(%va/FN_FIND-JGROUP, %0)), me, %#, pmatch(%0))

&MAP_JGROUPERROR [v(JOB_VA)]=ifelse(or(strmatch(%0, me), isdbref(pmatch(%0)), isdbref(u(%va/FN_FIND-JGROUP, %0))),, I don't recognize '%0' as a player or jgroup.)

&MAP_JOBSELECT [v(JOB_VA)]=switch(1, t(match(and or not %( %) | & !, %0)), %0, u(%va/FN_HASATTR, %#, JOBSELECT_%0), u(%va/FN_TOKENLIST, get(%#/JOBSELECT_%0)), %0)

&MAP_MAXWIDTH [v(JOB_VA)]=strlen(%0)

&MAP_NAME [v(JOB_VA)]=name(%0)

&MAP_PARAMS [v(JOB_VA)]=lcstr(rest(%0, _))

&MAP_PARSESTACK [v(JOB_VA)]=switch([setr(2, first(%0, =))][setq(a, edit(rest(%0, =), ~, %B))], OR, u(%va/FN_S-PUSH, setunion(u(%va/FN_S-POP), u(%va/FN_S-POP))), AND, u(%va/FN_S-PUSH, setinter(u(%va/FN_S-POP), u(%va/FN_S-POP))), NOT, u(%va/FN_S-PUSH, setdiff(%q1, u(%va/FN_S-POP))), u(%va/FN_S-PUSH, filter(%va/SEL_%q2, %q1)))

&MAP_PIEDATA [v(JOB_VA)]=[mid(get(%va/CHARGRAPH), %q0, 1)][setq(0, inc(%q0))][get(me/COLORGRAPH_%q0)]:%0:[extract(%q1, %q0, 1)]

&MAP_PIELEGEND [v(JOB_VA)]=ljust(extract(%qn, %0, 1, |), %qd) [ansi(before(mid(setr(q, extract(%qm, %0, 1, |)), 1, 10), :), mid(%qq, 0, 1))] [switch(%qq, :*, extract(%qq, 3, 100, :), after(%qq, :))]

&MAP_REPORTS [v(JOB_VA)]=after(lcstr(%0), _)

&MAP_SETTINGS [v(JOB_VA)]=rest(%0, _)

&MAP_SOURCE [v(JOB_VA)]=switch(%0, +*, u(FN_JGROUPMEMBERS, u(%va/FN_FIND-JGROUP, %0)), me, %#, pmatch(%0))

&MAP_STAT_ESC [v(JOB_VA)]=ifelse(and(u(%va/FN_HASATTRP, %0, DUE_ON), gt(secs(), get(%0/DUE_ON))), setq(3, inc(%q3)), switch(default(%0/PRIORITY, 1), 1, setq(1, inc(%q1)), 2, setq(2, inc(%q2)), 3, setq(3, inc(%q3)), setq(0, inc(%q0))))

&MAP_STAT_STATUS [v(JOB_VA)]=switch(%0, OVERDUE, @Rr:[words(filter(%va/FIL_OVERDUE, lcon(%va)))]:Overdue, [mid(get(%va/CHARGRAPH), dec(%1), 1)][get(%va/COLORGRAPH_[switch(%1, 3, 1, 1, 3, %1)])]:[setq(a, after(%0, STATUS_))][words(filter(%va/FIL_STAT_STATUS, lcon(%va)))]:[last(get(%va/%0), |)])

&REPORT_ACTBY [v(JOB_VA)]=[switch(%0,, This report requires you to supply an action code.%r%rUse: '+jobs/reports ACTBY=<action code>'.%r, [setq(0, squish(iter(lcon(%vc), ifelse(eq(words(grab(u(##/LIST_STATS), %0|*)), 0),, ##))))][setq(1, squish(iter(%q0, rest(grab(u(##/LIST_STATS), %0|*), |))))][ifelse(lt(words(%q1), 1), There is no action code '[ucstr(%0)]' presently in the system.%r, [ulocal(FN_BARGRAPH, %q1, 10, 2, 16, #)]%r[space(6)][iter(%q0, [u(%va/FN_STREXACT, name(##), 2)])]%r%r[center([ucstr(%0)] Actions by Bucket, u(%va/FN_FLEXWIDTH, 79))])])]

&REPORT_ACTIONS [v(JOB_VA)]=[ulocal(FN_BARGRAPH, setr(0, map(MAP_ACTIONS, v(LIST_STATS))), 15, 2, 16, #)][setq(0, fold(FOLD_ADD, %q0, 0))]%r[space(6)][setq(1, map(MAP_ACTIONS2, sort(v(LIST_STATS))))][iter(%q1, [mid(##, 0, 1)]%b)]%r[space(6)][iter(%q1, [mid(##, 1, 1)]%b)]%r[space(6)][iter(%q1, [mid(##, 2, 1)]%b)]%r%r[center(%q0 Actions Performed Since [v(INSTALL_DATE)], u(%va/FN_FLEXWIDTH, 79))]

&REPORT_ARTS [v(JOB_VA)]=[iter(sortby(%va/SORTBY_NAME, lcon(%vc)), [ifelse(u(%va/FN_HASATTR, ##, STAT_ART), u(%va/FN_TIME, round(fdiv(first(get(##/STAT_ART)), rest(get(##/STAT_ART))), 0)), [rjust(-, 11)])]%b[ljust(ansi(hc, [name(##)]), 20)], %B, %R)]%R[rjust(u(%va/FN_TIME, round(fdiv(first(default(%vc/STAT_ART, 0 0)), rest(default(%vc/STAT_ART, 0 1))), 0)), 11)]%b[ansi(hy, Total ART)]%r[center(Average Resolution Times by Bucket, u(%va/FN_FLEXWIDTH, 79))]

&REPORT_ARTSGRAPH [v(JOB_VA)]=[setq(0, iter(setr(1, sortby(%va/SORTBY_NAME, lcon(%vc))), ifelse(u(%va/FN_HASATTR, ##, STAT_ART), [div(round(fdiv(first(get(##/STAT_ART)), rest(get(##/STAT_ART))), 0), 86400)], 0)))][ulocal(%va/FN_BARGRAPH, %q0, 15, 2, 16, #)]%r[space(6)][iter(%q1, mid([name(##)]%B, 0, 2))]%r%r[center(Average Resolution Time by Bucket %(in days%), u(%va/FN_FLEXWIDTH, 79))]

&REPORT_BACT [v(JOB_VA)]=[switch(%0,, This report requires you to supply a bucket name.%r%rUse: '+jobs/reports BACT=<bucket name>' to specify a bucket.%r, [setq(0, u(%va/FN_FIND-BUCKET, %0))][ifelse(isdbref(%q0), [ulocal(FN_BARGRAPH, map(MAP_ACTIONS, get(%q0/LIST_STATS)), 15, 1, 16, #)]%r[space(6)][setq(1, map(MAP_ACTIONS2, sort(get(%q0/LIST_STATS))))][iter(%q1, mid(##, 0, 1))]%r[space(6)][iter(%q1, mid(##, 1, 1))]%r[space(6)][iter(%q1, mid(##, 2, 1))]%r%r[center(Number of Actions Performed on Bucket [name(%q0)], u(%va/FN_FLEXWIDTH, 79))], That is not a valid bucket name. See '+buckets' for a list of valid buckets.)])]

&REPORT_BUCKETS [v(JOB_VA)]=[u(FN_BARGRAPH, iter(sortby(SORTBY_NAME, lcon(%vc)), words(remove(children(##), #-1))), 15, 2, 16, #)]%r[space(6)][iter(sortby(SORTBY_NAME, lcon(%vc)), mid([name(##)]%b, 0, 2))]%r%r[center(# of Jobs in Buckets, u(%va/FN_FLEXWIDTH, 79))]

&REPORT_CLOSURE [v(JOB_VA)]=[setq(0, iter(APR DNY COM DEL, grab(get(%va/LIST_STATS), ##|*)))][u(%va/FN_EASYPIE, 10, ulocal(%va/FN_ASSEMBLEPIE, map(MAP_ACTIONS, %q0), iter(map(MAP_ACTIONS2, %q0), case(##, APR, Approved, DNY, Denied, COM, Completed, Deleted))), |, 16, 45)]

&REPORT_CODES [v(JOB_VA)]=[center(List of Action Codes:, u(%va/FN_FLEXWIDTH, 79))]%r%r[setq(0, sort(get(%va/LIST_ACTIONS), b, |, |))][table(map(%va/MAP_INDENT2, %q0, |, |), 25, u(%va/FN_FLEXWIDTH, 78), |)]%r

&REPORT_ESC [v(JOB_VA)]=[setq(z, [iter(lnum(1, 3), setq(##, 0))][map(%va/MAP_STAT_ESC, lcon(%va))])][u(FN_EASYPIE, 10, @Gg:%q1:Green|#Yy:%q2:Yellow|.Rr:%q3:Red, |, 16, 45)]%r%r[center(Job Escalation Colors, u(%va/FN_FLEXWIDTH, 79))]%r

&REPORT_JACT [v(JOB_VA)]=[switch(%0,, This report requires you to supply a job.%r%rUse: +jobs/reports JACT=<#>%r, [setq(0, u(%va/FN_FIND-JOB, %0))][ifelse(isdbref(%q0), [ifelse(u(%va/FN_HASATTR, %q0, LIST_STATS), [ulocal(FN_BARGRAPH, map(MAP_ACTIONS, get(%q0/LIST_STATS)), 15, 1, 16, #)]%r[space(6)][setq(1, map(MAP_ACTIONS2, sort(get(%q0/LIST_STATS))))][iter(%q1, mid(##, 0, 1))]%r[space(6)][iter(%q1, mid(##, 1, 1))]%r[space(6)][iter(%q1, mid(##, 2, 1))], No actions recorded for this job.)]%r%r[center(Actions Performed on [name(%q0)], u(%va/FN_FLEXWIDTH, 79))], That is not a valid job.%r)])]

&REPORT_STATS [v(JOB_VA)]=[rjust(ansi(hc, Install:), 20)]%b[get(%va/INSTALL_DATE)]%r[rjust(ansi(hc, Version:), 20)]%bAnomaly Jobs [get(%va/VERSION)][space(5)]%r[rjust(ansi(hc, Release:), 20)]%b[get(%va/RELEASE)]%r[rjust(ansi(hc, Memory:), 20)]%b[setr(a, fold(%va/FOLD_ADD, iter(setr(b, [num(me)] [loc(me)] %vb %vc [lcon(%vc)] [lcon(me)]), objmem(##))))]%b%([round(fdiv(%qa, 1024), 1)]k in [words(%qb)] objects%)%r[rjust(ansi(hc, Open Jobs:), 20)]%b[words(remove(lcon(%va), #-1))]%r[rjust(ansi(hc, Capacity:), 20)]%b[u(%va/FN_PCT)]%% Full%r[rjust(ansi(hc, Next Job:), 20)]%b[inc(u(%va/JOBS_NUM))]%r[rjust(ansi(hc, Buckets:), 20)]%b[words(lcon(%vc))]%r[rjust(ansi(hc, Opened:), 20)]%b[last(grab(get(%va/LIST_STATS), CRE|*), |)][setq(x, iter(APR DNY COM DEL, grab(get(%va/LIST_STATS), ##|*)))][setq(y, map(%va/MAP_ACTIONS, %qx))]%r[rjust(ansi(hc, Closed:), 20)]%b[fold(%va/FOLD_ADD, %qy, 0)]%r[rjust(ansi(hc, Actions To Date:), 20)]%b[fold(FOLD_ADD, map(MAP_ACTIONS, v(LIST_STATS)), 0)]%r[rjust(ansi(hc, ART:), 20)]%b[u(%va/FN_ART, %vc)][space(10)] ART=Average Resolution Time%r[rjust(ansi(hc, REQ ART:), 20)]%b[u(%va/FN_ART, u(%va/FN_FIND-BUCKET, REQ))][space(18)]DD:HH:MM:SS%r[rjust(ansi(hc, CODE ART:), 20)]%b[u(%va/FN_ART, u(%va/FN_FIND-BUCKET, CODE))]%r[rjust(ansi(hc, TPS ART:), 20)]%b[u(%va/FN_ART, u(%va/FN_FIND-BUCKET, TPS))]%r[rjust(ansi(hc, BUILD ART:), 20)]%b[u(%va/FN_ART, u(%va/FN_FIND-BUCKET, BUILD))]%r

&REPORT_STATUS [v(JOB_VA)]=[u(FN_EASYPIE, 12, iter(OVERDUE [lattr(%va/STATUS_*)], u(%va/MAP_STAT_STATUS, itext(0), inum(0)), %B, |), |, 10, 45)]

&RTITLE_ACTBY [v(JOB_VA)]=BAR|Graph of one action across all buckets

&RTITLE_ACTIONS [v(JOB_VA)]=BAR|System-wide Actions

&RTITLE_ARTS [v(JOB_VA)]=STATS|Average Resolution Times by Bucket

&RTITLE_ARTSGRAPH [v(JOB_VA)]=BAR|Average Resolution Times Graph

&RTITLE_BACT [v(JOB_VA)]=BAR|All actions on a specified bucket

&RTITLE_BUCKETS [v(JOB_VA)]=BAR|Job Dispersal Among Buckets

&RTITLE_CLOSURE [v(JOB_VA)]=PIE|Job Closure Patterns

&RTITLE_CODES [v(JOB_VA)]=STATS|A list of system-generated action codes

&RTITLE_ESC [v(JOB_VA)]=PIE|Job Escalation Status

&RTITLE_JACT [v(JOB_VA)]=BAR|Actions performed on a job

&RTITLE_STATS [v(JOB_VA)]=STATS|General System Stats

&RTITLE_STATUS [v(JOB_VA)]=PIE|Job Status Settings

&SEL_ALL [v(JOB_VA)]=1

&SEL_NEW [v(JOB_VA)]=u(%va/FIL_NEW[default(%#/JOBSN, 0)], %0)

&SEL_OVERDUE [v(JOB_VA)]=u(%va/FIL_OVERDUE, %0)

&SEL_MINE [v(JOB_VA)]=u(%va/FIL_MINE, %0)

&SEL_WHO [v(JOB_VA)]=u(%va/FIL_WHO, %0, switch(%qa, none,, me, %#, pmatch(%qa)))

&SEL_SOURCE [v(JOB_VA)]=u(%va/FIL_SOURCE, %0, switch(%qa, none,, me, %#, pmatch(%qa)))

&SEL_PRI [v(JOB_VA)]=u(%va/SEL_ESC, %0)

&SEL_ESC [v(JOB_VA)]=u(%va/FIL_ESC, %0, match(green yellow red, %qa*))

&SEL_STATUS [v(JOB_VA)]=u(%va/FIL_STATUS, STATUS_[get(%0/STATUS)])

&SEL_BUCKET [v(JOB_VA)]=u(%va/FIL_BUCKET, %0, u(%va/FN_FIND-BUCKET, %qa))

&SEL_SEARCH [v(JOB_VA)]=u(%va/FIL_SEARCH, %0, %qa)

&SEL_VIEWING [v(JOB_VA)]=u(%va/SEL_MONITOR, %0)

&SEL_MONITOR [v(JOB_VA)]=u(%va/FN_MONITORCHECK, parent(%0), %#)

&SEL_HIDDEN [v(JOB_VA)]=u(%va/IS_HIDDEN, parent(%0))

&SEL_LOCKED [v(JOB_VA)]=u(%va/IS_LOCKED, %0)

&SEL_TAGGED [v(JOB_VA)]=u(%va/IS_TAGGED, %0)

&SEL_MYJOBS [v(JOB_VA)]=u(%va/SEL_PUBLIC, %0)

&SEL_PUBLIC [v(JOB_VA)]=u(%va/IS_PUBLIC, parent(%0))

&SEL_PUBLISHED [v(JOB_VA)]=u(%va/IS_PUBLISHED, %0)

&SEL_SUMMARY [v(JOB_VA)]=u(%va/IS_SUMMARY, parent(%0))

&SEL_DUE> [v(JOB_VA)]=u(%va/FIL_DUEAFTER, %0, u(FN_DATECONV, %qa))

&SEL_DUE< [v(JOB_VA)]=not(u(%va/FIL_DUEAFTER, %0, u(FN_DATECONV, %qa)))

&SORTBY_BUCKET [v(JOB_VA)]=comp(name(parent(%0)), name(parent(%1)))

&SORTBY_COMMENTS [v(JOB_VA)]=sub(after(%0, _), after(%1, _))

&SORTBY_DATE [v(JOB_VA)]=sub(get(%0/MODIFIED_ON), get(%1/MODIFIED_ON))

&SORTBY_DUE [v(JOB_VA)]=comp(get(%0/DUE_ON), get(%1/DUE_ON))

&SORTBY_JOBNUM [v(JOB_VA)]=sub(last(name(%0)), last(name(%1)))

&SORTBY_NAME [v(JOB_VA)]=comp(name(%0), name(%1))

&SORTBY_PRI [v(JOB_VA)]=sub(get(%0/PRIORITY), get(%1/PRIORITY))

&STATUS_1 [v(JOB_VA)]=NEW|New

&STATUS_2 [v(JOB_VA)]=UNDERWAY|Underway

&STATUS_3 [v(JOB_VA)]=1/4 DONE|25% Complete

&STATUS_4 [v(JOB_VA)]=1/2 DONE|50% Complete

&STATUS_5 [v(JOB_VA)]=3/4 DONE|75% Complete

&STATUS_6 [v(JOB_VA)]=COMPLETE|Complete

&TRIG_ADD [v(JOB_VA)]=think [setq(0, default(%0/NUM_COMMENT, 1))][setq(1, last(grab(get(%0/LIST_JOBSN), %2|*), |))][setq(2, edit(%1, |, @@PIPE@@))][ifelse(eq(dec(%q0), %q1), set(%0, LIST_JOBSN:[setunion(remove(get(%0/LIST_JOBSN), %2|%q1), %2|%q0)]),)][ulocal(FN_ADDSTAT, %3, %va)][ulocal(FN_ADDSTAT, %3, %0)][ulocal(FN_ADDSTAT, %3, parent(%0))];&COMMENT_%q0 %0=%3|[secs()]|%2|[name(%2)]|[ifelse(u(%va/FN_HASATTRP, parent(%0), ALETTER_%3), u(%va/FN_STRTRUNC, u([parent(%0)]/ALETTER_%3, %0, %2, %q2), get(%va/BUFFER)), u(%va/FN_STRTRUNC, %q2, get(%va/BUFFER)))];&NUM_COMMENT %0=[inc(%q0)];&MODIFIED_ON %0=[secs()];&MODIFIED_BY %0=%2;@trigger parent(%0)/HOOK_%3=%0, %2, [parent(%0)], %1;@trigger %va/TRIG_POST=%0, %3, %2, %1;@trigger %va/TRIG_MAIL=%0, %3, %2, %1

&TRIG_APPLY [v(JOB_VA)]=@trigger %va/TRIG_CREATE=%0, u(%va/FN_FIND-BUCKET, APPS), 2, Application by [name(%0)], -

&TRIG_BROADCAST [v(JOB_VA)]=@switch isdbref(%1)=1, {@pemit/list [setq(0, parent(%0))][setq(0, ifelse(isdbref(%q0), %q0, %vc))][filter(%va/FIL_BROADCAST, setunion(lwho(),))]=[ansi(hc, JOBS:)]%b[u(%q0/BLETTER_%2, %0, %1, %3, %4)]}, {@pemit/list [setq(0, %0)][filter(%va/FIL_BROADCAST, setunion(lwho(),))]=[ansi(hc, JOBS:)]%b%1}

&TRIG_CLEAN [v(JOB_VA)]=@dolist [lcon(%va)] [lcon(%vb)]={@switch [u(FN_CLEANFIND, ##, OPENED_BY)][u(FN_CLEANFIND, ##, ASSIGNED_TO)][u(FN_CLEANFIND, ##, TAGGED_FOR)][u(FN_CLEANFIND, ##, PLAYERS)][u(FN_CLEANFIND, ##, WRITER)][u(FN_CLEANFIND, ##, MEMBERLIST)][u(FN_CLEANFIND, ##, JOBACCESS)]=1??????, {&OPENED_BY ##=U(FN_CLEANFIX, ##, OPENED_BY)}, ?1?????, {&ASSIGNED_TO ##=U(FN_CLEANFIX, ##, ASSIGNED_TO)}, ??1????, {&TAGGED_FOR ##=U(FN_CLEANFIX, ##, TAGGED_FOR)}, ???1???, {&PLAYERS ##=U(FN_CLEANFIX, ##, PLAYERS)}, ????1??, {&WRITER ##=U(FN_CLEANFIX, ##, WRITER)}, ?????1?, {&MEMBERLIST ##=U(FN_CLEANFIX, ##, MEMBERLIST)}, ??????1, {&JOBACCESS ##=U(FN_CLEANFIX, ##, JOBACCESS)}};

&TRIG_CREATE [v(JOB_VA)]=@switch gte(u(%va/FN_PCT), 100)=1, {@pemit %0=[ansi(hr, JOBS ERROR:)] Creation failed. The +jobs system is full. Contact staff immediately.;@trigger %va/TRIG_BROADCAST=%1, JOBS SYSTEM IS FULL! Please complete jobs or boost your MAX_JOBS configuration.}, {think [setq(0, inc(u(%va/JOBS_NUM)))][setq(1, create(Job %q0, 10))][setq(y, case(%7, 1, CRE, OTH))];@tel %q1=%va;@link %q1=%va;&OPENED_BY %q1=[switch(%5,, %0, %5)];&OPENED_ON %q1=[secs()];&MODIFIED_ON %q1=[secs()];&STATUS %q1=1;&TITLE %q1=%3;@parent %q1=[u(%va/FN_FIND-BUCKET, %1)];&NUM_COMMENT %q1=2;&PRIORITY %q1=%2;&COMMENT_1 %q1=CRE|[secs()]|%0|[name(%0)]|[ifelse(u(%va/FN_HASATTRP, parent(%q1), ALETTER_%qy), u(%va/FN_STRTRUNC, u([parent(%q1)]/ALETTER_%qy, %q1, %0, edit(%4, |, @@PIPE@@)), get(%va/BUFFER)), u(%va/FN_STRTRUNC, edit(%4, |, @@PIPE@@), get(%va/BUFFER)))];&LIST_JOBSN %q1=%0|1;&ASSIGNED_TO %q1=%6;&JOBS_NUM %va=%q0;&DUE_ON %q1=[ifelse(u(%va/FN_HASATTRP, %q1, TURNAROUND), add(secs(), mul(60, 60, get(%q1/TURNAROUND))),)];@trigger %va/TRIG_BROADCAST=%q1, %0, %qy, %3;@trigger %1/HOOK_%qy=%q1, %0, %1, %4;@trigger %va/TRIG_POST=%q1, %qy, %0, %4;@trigger %va/TRIG_MAIL=%q1, %qy, %0, %4;think [ulocal(FN_ADDSTAT, CRE, %va)][ulocal(FN_ADDSTAT, CRE, parent(%q1))];@switch gt(u(%va/FN_PCT), 95)=1, {@trigger %va/TRIG_BROADCAST=%1, JOBS SYSTEM IS NEARING CAPACITY! Please complete jobs or boost your MAX_JOBS configuration.}}

&TRIG_DESTROY [v(JOB_VA)]=&going %0=1;@wait 60={@switch get(%0/GOING)=1, {@switch first(version())=PennMUSH, {@parent %0;@nuke %0;@wait 0=@nuke %0}, {@parent %0;@dest/instant %0}}}

&TRIG_LOG [v(JOB_VA)]=@switch [setq(0, %0)][setq(1, parent(%q0))][setq(x, u(%va/FN_ITEMIZE, map(MAP_NAME, get(%q0/OPENED_BY), %b, |), |))][and(u(%va/FN_HASATTRP, %va, JOB_LOGGING), u(%va/FN_HASATTRP, %q1, LOGFILE))]=0, {@@}, {@trigger %va/TRIG_LOG_WRITE=[u(%q1/LOGFILE)], [center(| [name(%q0)] |, 79, =)];@trigger %va/TRIG_LOG_WRITE=[u(%q1/LOGFILE)], [ljust([rjust(ansi(hc, Bucket:), 10)]%b[u(FN_BUCKETNAME, %q0)], 40)][rjust(ansi(hc, Due On:), 12)]%b[ifelse(get(%q0/DUE_ON), ifelse(gt(secs(), get(%q0/DUE_ON)), OVERDUE!, convsecs(get(%q0/DUE_ON))), -)];@trigger %va/TRIG_LOG_WRITE=[u(%q1/LOGFILE)], [ljust([rjust(ansi(hc, Title:), 10)]%b[get(%q0/TITLE)], 40)][rjust(ansi(hc, Assigned To:), 12)]%b[ifelse(isdbref(get(%q0/ASSIGNED_TO)), name(get(%q0/ASSIGNED_TO)), Nobody)];@trigger %va/TRIG_LOG_WRITE=[u(%q1/LOGFILE)], [ljust([rjust(ansi(hc, Opened On:), 10)]%b[convsecs(get(%q0/OPENED_ON))], 40)][rjust(ansi(hc, Status:), 12)]%b[switch(get(%q0/PRIORITY), 1, Green, 2, Yellow, 3, Red)]%b%([last(get(%va/STATUS_[get(%q0/STATUS)]), |)]%);@trigger %va/TRIG_LOG_WRITE=[u(%q1/LOGFILE)], [rjust(ansi(hc, Opened By:), 10)] %qx;@dolist sortby(%va/SORTBY_COMMENTS, lattr(%q0/COMMENT_*))={@trigger %va/TRIG_LOG_WRITE=[u(%q1/LOGFILE)], [repeat(-, 79)];@trigger %va/TRIG_LOG_WRITE=[u(%q1/LOGFILE)], [extract(get(%q0/##), 4, 1, |)]%badded on%b[convsecs(extract(get(%q0/##), 2, 1, |))]:%b[edit(last(get(%q0/##), |), @@PIPE@@, |)]};@wait 1={@trigger %va/TRIG_LOG_WRITE=[u(%q1/LOGFILE)], [repeat(=, 79)]}}

&TRIG_LOG_WRITE [v(JOB_VA)]=@switch [first(version())]=RhostMUSH, {@log/file %0=%1}, PennMUSH, {@log/cmd %1}, {@log %0=%1}

&TRIG_MAIL [v(JOB_VA)]=@switch [u(%va/FN_HASATTRP, %0, MLETTER_%1)]=1, {@wait 1={@trigger %vb/TRIG_MAIL=[switch(%1, MAI, [get(%0/OPENED_BY)], APR, [get(%0/OPENED_BY)], DNY, [get(%0/OPENED_BY)], filter(%va/FIL_NOSPAM, setunion(get(%0/OPENED_BY),)))], [switch(%1, APR, Approved:, DEL, Deleted:, DNY, Denied:, COM, Complete:, [name(%0)]:)]%b[get(%0/TITLE)], [u(parent(%0)/MLETTER_%1, %0, %1, %2, %3)]};}

&TRIG_POST [v(JOB_VA)]=@switch [u(%va/FN_HASATTRP, %0, PLETTER_%1)]=1, {@wait 1={@trigger %vb/TRIG_POST=[get(%0/POST_[case(%1, APR, APPROVE, DEL, DELETE, DNY, DENY, COM, COMPLETE, APPROVE)])], [switch(%1, APR, A:, DNY, D:, COM, C:, [name(%0)]:)]%b[get(%0/TITLE)], [u(parent(%0)/PLETTER_%1, %0, %1, %2, %3)]};}

@dolist VA VB VC={@cpattr %#/JOB_##=[v(JOB_VA)]/##}

&DEFAULT_SKIN [v(JOB_VA)]=1

&DEFAULT_BANNER [v(JOB_VA)]=[setq(0, %0)][setq(x, u(%va/FN_ITEMIZE, map(MAP_NAME, get(%q0/OPENED_BY), %b, |), |))][setq(y, u(%va/FN_ITEMIZE, map(MAP_NAME, get(%q0/TAGGED_FOR), %b, |), |))][ljust([rjust(ansi(hc, Bucket:), 10)]%b[u(%va/FN_BUCKETNAME, %q0)], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(hc, Due On:), 12)]%b[ifelse(get(%q0/DUE_ON), ifelse(gt(secs(), get(%q0/DUE_ON)), OVERDUE!, convsecs(get(%q0/DUE_ON))), -)]%r[ljust([rjust(ansi(hc, Title:), 10)]%b[get(%q0/TITLE)], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(hc, Status:), 12)]%b[switch(get(%q0/PRIORITY), 1, Green, 2, Yellow, 3, Red)]%b%([last(get(%va/STATUS_[get(%q0/STATUS)]), |)]%)%r[ljust([rjust(ansi(hc, Opened On:), 10)] [convsecs(get(%q0/OPENED_ON))], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(hc, Assigned To:), 12)]%b[ifelse(isdbref(get(%q0/ASSIGNED_TO)), name(get(%q0/ASSIGNED_TO)), Nobody)]%r[rjust(ansi(hc, Opened By:), 10)]%b%qx[ifelse(words(%qy), %r[rjust(ansi(hc, Tagged:), 10)]%b%qy,)]

&DEFAULT_BREAK [v(JOB_VA)]=switch(%0,, repeat(-, u(FN_FLEXWIDTH, 79)), rjust(%[%0%], u(FN_FLEXWIDTH, 79), -))

&DEFAULT_BUCKETHEADER [v(JOB_VA)]=[u(FN_HEADER, Bucket List)]%r[ifelse(u(%va/FN_WIZONLY, %#), [ansi(hc, [ljust(Name, 9)][ljust(Flags, 6)]%b%b[ljust(Description, u(FN_FLEXWIDTH, 30))][rjust(#Jobs, 5)][rjust(Pct, 5)][space(3)]C%b%bA%b%bD%b%bDue[space(3)]ARTS)], [ansi(hc, [ljust(NAME, 8)][ljust(Description, u(FN_FLEXWIDTH, 50))]%b[rjust(Viewing, 20)])])]%r[u(FN_BREAK)]

&DEFAULT_BUCKETLIST [v(JOB_VA)]=[ifelse(u(%va/FN_WIZONLY, %#), [ljust(name(%0), 6)]%b%b[ifelse(u(%va/FN_MONITORCHECK, %0, %#), V, -)][ifelse(u(%va/IS_HIDDEN, %0), H, -)][ifelse(u(%va/IS_LOCKED, %0), ifelse(u(%va/FN_HASATTRP, %0, CHECKOUT), C, L), -)][ifelse(u(%va/IS_TAGGED, %0), T, -)][ifelse(u(%va/IS_PUBLIC, %0), M, -)][ifelse(u(%va/IS_PUBLISHED, %0), P, -)][ifelse(u(%va/IS_SUMMARY, %0), S, -)]%b%b[u(%va/FN_STREXACT, get(%0/DESC), u(FN_FLEXWIDTH, 30))][rjust(words(remove(children(%0), #-1)), 5)][rjust(mul(round(fdiv(words(remove(children(%0), #-1)), max(1, words(lcon(%va)))), 2), 100)%%,5)]%b%b[rjust(u(%va/FN_FIND-BBNUM, get(%0/POST_COMPLETE)), 2)]%b[rjust(u(%va/FN_FIND-BBNUM, get(%0/POST_APPROVE)), 2)]%b[rjust(u(%va/FN_FIND-BBNUM, get(%0/POST_DENY)), 2)][rjust(default(%0/TURNAROUND, 0), 5)][rjust([ifelse(u(%va/FN_HASATTR, %0, STAT_ART), [round(fdiv(fdiv(first(get(%0/STAT_ART)), rest(get(%0/STAT_ART))), 86400), 0)]d, -)], 7)], [ljust(name(%0), 6)]%b%b[u(%va/FN_STREXACT, get(%0/DESC), u(FN_FLEXWIDTH, 50))]%b[rjust(ifelse(u(%va/FN_MONITORCHECK, %0, %#), Yes, -), 20)])]

&DEFAULT_FLAGS [v(JOB_VA)]=[ifelse(u(me/IS_LOCKED, %0), u(me/FN_FLAG, ifelse(u(%va/FN_HASATTRP, %0, CHECKOUT), CHECKED OUT, LOCKED), hr),)][ifelse(u(me/IS_PUBLIC, %0), u(me/FN_FLAG, Myjobs),)][ifelse(u(me/IS_PUBLISHED, %0), u(me/FN_FLAG, Published),)]

&DEFAULT_FOOTER [v(JOB_VA)]=[switch(%0,, repeat(=, u(FN_FLEXWIDTH, 79)), center(| %0 |, u(FN_FLEXWIDTH, 79), =))]

&DEFAULT_HEADER [v(JOB_VA)]=[switch(%0,, [repeat(=, u(FN_FLEXWIDTH, 79))], [center(| [ansi(hy, %0)] |, u(FN_FLEXWIDTH, 79), =)])]

&DEFAULT_JOBLIST [v(JOB_VA)]=[setq(j, secure(ifelse(u(%va/FN_HASATTRP, %1, JOBS), lcstr(mid(get(%1/JOBS), 0, 20)), get(%va/JOBS_DEFAULT))))][setq(1, ifelse(get(%0/DUE_ON), ifelse(gt(secs(), get(%0/DUE_ON)), r, switch(get(%0/PRIORITY), 1, g, 2, y, 3, r, g)), switch(get(%0/PRIORITY), 1, g, 2, y, 3, r)))][ifelse(u(%va/FN_ISNEW, %0, %1), [ansi(hr, *)]%b, %b%b)][ansi(h%q1, [rjust([last(name(%0))], 5)]%b[iter(lnum(strlen(%qj)), [u(%va/DISPLAY_[mid(%qj, ##, 1)], %0, %1)])])]

&DEFAULT_JOBSHEADER [v(JOB_VA)]=[u(FN_HEADER, Anomaly Jobs [u(VERSION)])]%r[setq(j, [secure(switch(u(%va/FN_HASATTRP, %0, JOBS), 1, lcstr(mid(get(%0/JOBS), 0, 20)), u(JOBS_DEFAULT)))])][ansi(hc, *%b%b[ljust(Job#, 5)][iter(lnum(strlen(%qj)), u(HEADER_[mid(%qj, ##, 1)]))])]%r[u(FN_BREAK)]

&DEFAULT_MYJOBLIST [v(JOB_VA)]=[ifelse(u(FN_ISNEW, %0, %1), [ansi(hr, *)], %b)]%b[setq(j, TDAS)][ansi(n, [rjust([last(name(%0))], 5)]%b[iter(lnum(strlen(%qj)), u(DISPLAY_[mid(%qj, ##, 1)], %0, %1))])]

&DEFAULT_MYJOBSHEADER [v(JOB_VA)]=[u(FN_HEADER, Anomaly Jobs [u(VERSION)])]%r[setq(j, TDAS)][ansi(ch, ljust(*%b%b[ljust(Job#, 5)][iter(lnum(strlen(%qj)), u(HEADER_[mid(%qj, ##, 1)]))], [u(FN_FLEXWIDTH, 79)]))]%r[u(FN_BREAK)]

&DEFAULT_MYBANNER [v(JOB_VA)]=[setq(0, %0)][setq(x, u(%va/FN_ITEMIZE, map(MAP_NAME, get(%q0/OPENED_BY), %b, |), |))][ljust([rjust(ansi(hc, Bucket:), 10)]%b[u(%va/FN_BUCKETNAME, %q0)], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(hc, Due On:), 12)]%b[ifelse(get(%q0/DUE_ON), ifelse(gt(secs(), get(%q0/DUE_ON)), OVERDUE!, convsecs(get(%q0/DUE_ON))), -)]%r[ljust([rjust(ansi(hc, Title:), 10)]%b[get(%q0/TITLE)], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(hc, Assigned To:), 12)]%b[ifelse(isdbref(get(%q0/ASSIGNED_TO)), name(get(%q0/ASSIGNED_TO)), Nobody)]%r[ljust([rjust(ansi(hc, Opened On:), 10)]%b[convsecs(get(%q0/OPENED_ON))], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(hc, Status:), 12)]%b[switch(get(%q0/PRIORITY), 1, Green, 2, Yellow, 3, Red)]%b%r[rjust(ansi(hc, Opened By:), 10)]%b%qx

&DEFAULT_MYSUMMARY [v(JOB_VA)]=%r[u(FN_BREAK, MySummary)]%r[u(parent(%0)/MYSUMMARY, %0)]

&DEFAULT_READ [v(JOB_VA)]=[repeat(-, u(FN_FLEXWIDTH, 79))]%r[ifelse(u(%va/EDIT_ACCESS, %#), [ansi(h, %[)][ifelse(and(or(u(%va/IS_PUBLISHED, %1), switch(extract(get(%1/%0), 3, 1, |), u(%1/OPENED_BY), 1, 0), hasflag(%1/%0, no_inherit)), u(%va/IS_PUBLIC, %1)), ansi(hc, [rest(%0, _)]+), ansi(hc, [rest(%0, _)]-))][ansi(h, %])]%b,)][ansi(h, [extract(get(%1/%0), 4, 1, |)]%badded on%b[convsecs(extract(get(%1/%0), 2, 1, |))]:%b)][edit(last(get(%1/%0), |), @@PIPE@@, |)]

&DEFAULT_STAFFSUM [v(JOB_VA)]=%r[repeat(-, u(FN_FLEXWIDTH, 79))]%r[rjust(ansi(hc, DB#:), 10)] %0[space(10)][rjust(ansi(hc, Comments:), 10)] [setr(z, words(lattr(%0/COMMENT_*)))]%r%r[rjust(ansi(hc, Players:), 10)] %(Players contributing to this job%)%r[setq(y, setunion(iter(lattr(%0/COMMENT_*), extract(get(%0/##), 4, 1, |), %b, |),, |))][u(%va/fn_columns, %qy, 20, |, 11)][ifelse(u(%va/FN_HASATTR, %0, LIST_READERS), %r[rjust(ansi(hc, Readers:), 10)]%b%(Players who have read this job in the past%)%r[setq(z, iter(get(%0/LIST_READERS), first(##, |)))][u(%va/fn_columns, map(%va/MAP_NAME, %qz, %b, |), 20, |, 11)],)]%r[rjust(ansi(hc, Stats:), 10)]%r[u(%va/fn_columns, iter(ifelse(u(%va/FN_HASATTR, %0, LIST_STATS), sort(get(%0/LIST_STATS)),), [first(##, |)]%b[last(##, |)], %b, |), 20, |, 11)]%r

&DEFAULT_SUMMARY [v(JOB_VA)]=%r[repeat(-, u(FN_FLEXWIDTH, 79))]%r[u(parent(%0)/SUMMARY, %0)]

&CHROME_SKIN [v(JOB_VA)]=1

&CHROME_BANNER [v(JOB_VA)]=%r[setq(0, %0)][setq(x, u(%va/FN_ITEMIZE, map(MAP_NAME, get(%q0/OPENED_BY), %b, |), |))][setq(y, u(%va/FN_ITEMIZE, map(MAP_NAME, get(%q0/TAGGED_FOR), %b, |), |))][ljust([rjust(ansi(hc, Bucket:), 10)]%b[u(%va/FN_BUCKETNAME, %q0)], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(hc, Due On:), 12)]%b[ifelse(get(%q0/DUE_ON), ifelse(gt(secs(), get(%q0/DUE_ON)), OVERDUE!, convsecs(get(%q0/DUE_ON))), -)]%r[ljust([rjust(ansi(hc, Title:), 10)]%b[get(%q0/TITLE)], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(hc, Status:), 12)]%b[switch(get(%q0/PRIORITY), 1, Green, 2, Yellow, 3, Red)]%b%([last(get(%va/STATUS_[get(%q0/STATUS)]), |)]%)%r[ljust([rjust(ansi(hc, Opened On:), 10)]%b[convsecs(get(%q0/OPENED_ON))], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(hc, Assigned To:), 12)]%b[ifelse(isdbref(get(%q0/ASSIGNED_TO)), name(get(%q0/ASSIGNED_TO)), Nobody)]%r[rjust(ansi(hc, Opened By:), 10)]%b%qx[ifelse(words(%qy), %r[rjust(ansi(hc, Tagged:), 10)]%b%qy,)]

&CHROME_BREAK [v(JOB_VA)]=rjust(ifelse(%0, %[%0%]), u(FN_FLEXWIDTH, 79), _)

&CHROME_FLAGS [v(JOB_VA)]=[edit(u(%va/fn_trim, squish([ifelse(u(me/IS_LOCKED, %0), %b[ansi(hr, ifelse(u(%va/FN_HASATTRP, %0, CHECKOUT), CHECKED_OUT, LOCKED))]%b,)][ifelse(u(me/IS_PUBLIC, %0), %bMYJOBS%b,)][ifelse(u(me/IS_PUBLISHED, %0), %bPUBLISHED%b,)])), %b, %b-%b)]

&CHROME_FOOTER [v(JOB_VA)]=%r[switch(%0,, [repeat(~, u(FN_FLEXWIDTH, 79))], [repeat(~, sub(u(FN_FLEXWIDTH, 73), strlen(%0)))]|[ansi(Chw, %b[stripansi(%0)]%b)]|~~)]

&CHROME_HEADER [v(JOB_VA)]=[switch(%0,, [repeat(_, u(FN_FLEXWIDTH, 79))], __|[ansi(Chw, %b%0%b)]|[repeat(_, sub(u(FN_FLEXWIDTH, 73), strlen(%0)))])]

&CHROME_JOBLIST [v(JOB_VA)]=[setq(j, secure(ifelse(u(%va/FN_HASATTRP, %1, JOBS), lcstr(mid(get(%1/JOBS), 0, 20)), get(%va/JOBS_DEFAULT))))][setq(1, ifelse(get(%0/DUE_ON), ifelse(gt(secs(), get(%0/DUE_ON)), h, switch(get(%0/PRIORITY), 1, hx, 2, n, 3, h, hx)), switch(get(%0/PRIORITY), 1, hx, 2, n, 3, h)))][ifelse(u(%va/FN_ISNEW, %0, %1), [ansi(hr, *)]%b, %b%b)][ansi(h%q1, [rjust([last(name(%0))], 5)]%b[iter(lnum(strlen(%qj)), [u(%va/DISPLAY_[mid(%qj, ##, 1)], %0, %1)])])]

&CHROME_JOBSHEADER [v(JOB_VA)]=[u(FN_HEADER, Anomaly Jobs [u(VERSION)])]%r[setq(j, [secure(switch(u(%va/FN_HASATTRP, %0, JOBS), 1, lcstr(mid(get(%0/JOBS), 0, 20)), u(JOBS_DEFAULT)))])][setq(2, *%b%b[ljust(Job#, 5)][iter(lnum(strlen(%qj)), u(HEADER_[mid(%qj, ##, 1)]))])][ansi(Chcu, ljust(%q2, u(FN_FLEXWIDTH, 79)))]%r

&CHROME_MYJOBSHEADER [v(JOB_VA)]=[u(FN_HEADER, Anomaly Jobs [u(VERSION)])]%r[setq(j, TDAS)][ansi(Chcu, ljust(*%b%b[ljust(Job#, 5)][iter(lnum(strlen(%qj)), u(HEADER_[mid(%qj, ##, 1)]))], u(FN_FLEXWIDTH, 79)))]%r

&CHROME_MYJOBLIST [v(JOB_VA)]=[ifelse(u(FN_ISNEW, %0, %1), [ansi(r, *)]%b, %b%b)]%b[setq(j, TDAS)][ansi(hx, [rjust([last(name(%0))], 5)]%b[iter(lnum(strlen(%qj)), u(DISPLAY_[mid(%qj, ##, 1)], %0, %1))])]

&CHROME_READ [v(JOB_VA)]=%r[setq(0, [ifelse(u(%va/EDIT_ACCESS, %#), [ansi(Xhu, %b[rest(%0, _)]:%b)], [ansi(Xhu, %b)])]|[ansi(Xhc, %b[extract(get(%1/%0), 4, 1, |)])]%b|)]%q0[ansi(Xhu, repeat(%b, sub(25, strlen(%q0))))][ifelse(and(or(u(%va/IS_PUBLISHED, %1), switch(extract(get(%1/%0), 3, 1, |), u(%1/OPENED_BY), 1, 0), hasflag(%1/%0, no_inherit)), u(%va/IS_PUBLIC, %1)), [ansi(Xhu, repeat(%b, div(u(FN_FLEXWIDTH, 14), 2)))]|[ansi(Xc, %b+Published+%b)]|[ansi(Xhu, repeat(%b, div(u(FN_FLEXWIDTH, 14), 2)))], [ansi(Xhu, repeat(%b, u(FN_FLEXWIDTH, 29)))])][ansi(Xhu, [convsecs(extract(get(%1/%0), 2, 1, |))]%b)]%r[space(4)][edit(last(get(%1/%0), |), @@PIPE@@, |)]

&CHROME_SUMMARY [v(JOB_VA)]=%r[repeat(_, u(FN_FLEXWIDTH, 79))]%r[u(parent(%0)/SUMMARY, %0)]

&WHITEBG_SKIN [v(JOB_VA)]=1

&WHITEBG_JOBLIST [v(JOB_VA)]=[setq(j, secure(ifelse(u(%va/FN_HASATTRP, %1, JOBS), lcstr(mid(get(%1/JOBS), 0, 20)), get(%va/JOBS_DEFAULT))))][setq(1, ifelse(get(%0/DUE_ON), ifelse(gt(secs(), get(%0/DUE_ON)), r, switch(get(%0/PRIORITY), 1, g, 2, y, 3, r, g)), switch(get(%0/PRIORITY), 1, g, 2, y, 3, r)))][ifelse(u(%va/FN_ISNEW, %0, %1), [ansi(hr, *)]%b, %b%b)][ansi(%q1, [rjust([last(name(%0))], 5)]%b[iter(lnum(strlen(%qj)), [u(%va/DISPLAY_[mid(%qj, ##, 1)], %0, %1)])])]

&WHITEBG_FLAGS [v(JOB_VA)]=[ifelse(u(me/IS_LOCKED, %0), %[[ansi(r, ifelse(u(%va/FN_HASATTRP, %0, CHECKOUT), CHECKED OUT, LOCKED))]%],)][ifelse(u(me/IS_PUBLIC, %0), %[Myjobs%],)][ifelse(u(me/IS_PUBLISHED, %0), %[Published%],)]

&WHITEBG_FOOTER [v(JOB_VA)]=[ansi(x, switch(%0,, repeat(=, u(FN_FLEXWIDTH, 79)), center(| [stripansi(%0)] |, u(FN_FLEXWIDTH, 79), =)))]

&WHITEBG_JOBSHEADER [v(JOB_VA)]=[u(FN_HEADER, Anomaly Jobs [u(VERSION)])]%r[setq(j, [secure(switch(u(%va/FN_HASATTRP, %0, JOBS), 1, lcstr(mid(get(%0/JOBS), 0, 20)), u(JOBS_DEFAULT)))])][ansi(c, *%b%b[ljust(Job#, 5)][iter(lnum(strlen(%qj)), u(HEADER_[mid(%qj, ##, 1)]))])]%r[u(FN_BREAK)]

&WHITEBG_MYJOBSHEADER [v(JOB_VA)]=[u(FN_HEADER, Anomaly Jobs [u(VERSION)])]%r[setq(j, TDAS)][ansi(c, ljust(%b*%b%b[ljust(Job#, 5)][iter(lnum(strlen(%qj)), u(HEADER_[mid(%qj, ##, 1)]))], u(FN_FLEXWIDTH, 79)))]%r[u(FN_BREAK)]

&WHITEBG_MYBANNER [v(JOB_VA)]=[setq(0, %0)][setq(x, u(%va/FN_ITEMIZE, map(MAP_NAME, get(%q0/OPENED_BY), %b, |), |))][ljust([rjust(ansi(c, Bucket:), 10)]%b[u(%va/FN_BUCKETNAME, %q0)], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(c, Due On:), 12)]%b[ifelse(get(%q0/DUE_ON), ifelse(gt(secs(), get(%q0/DUE_ON)), OVERDUE!, convsecs(get(%q0/DUE_ON))), -)]%r[ljust([rjust(ansi(c, Title:), 10)]%b[get(%q0/TITLE)], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(c, Assigned To:), 12)]%b[ifelse(isdbref(get(%q0/ASSIGNED_TO)), name(get(%q0/ASSIGNED_TO)), Nobody)]%r[ljust([rjust(ansi(c, Opened On:), 10)]%b[convsecs(get(%q0/OPENED_ON))], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(c, Status:), 12)]%b[switch(get(%q0/PRIORITY), 1, Green, 2, Yellow, 3, Red)]%b%r[rjust(ansi(c, Opened By:), 10)]%b%qx

&WHITEBG_HEADER [v(JOB_VA)]=[ansi(x, switch(%0,, [repeat(=, u(FN_FLEXWIDTH, 79))], [center(| [stripansi(%0)] |, u(FN_FLEXWIDTH, 79), =)]))]

&WHITEBG_READ [v(JOB_VA)]=[repeat(-, u(FN_FLEXWIDTH, 79))]%r[ifelse(u(%va/EDIT_ACCESS, %#), [ansi(x, %[)][ifelse(and(or(u(%va/IS_PUBLISHED, %1), switch(extract(get(%1/%0), 3, 1, |), u(%1/OPENED_BY), 1, 0), hasflag(%1/%0, no_inherit)), u(%va/IS_PUBLIC, %1)), ansi(c, [rest(%0, _)]+), ansi(c, [rest(%0, _)]-))][ansi(x, %])]%b,)][ansi(x, [extract(get(%1/%0), 4, 1, |)] added on [convsecs(extract(get(%1/%0), 2, 1, |))]: %b)][edit(last(get(%1/%0), |), @@PIPE@@, |)]

&WHITEBG_BUCKETHEADER [v(JOB_VA)]=[u(FN_HEADER, Bucket List)]%r[ifelse(u(%va/FN_WIZONLY, %#), [ansi(c, [ljust(Name, 9)][ljust(Flags, 6)]%b%b[ljust(Description, u(FN_FLEXWIDTH, 30))][rjust(#Jobs, 5)][rjust(Pct, 5)][space(3)]C%b%bA%b%bD%b%bDue[space(3)]ARTS)], [ansi(c, [ljust(NAME, 8)][ljust(Description, u(FN_FLEXWIDTH, 50))]%b[rjust(Viewing, 20)])])]%r[u(FN_BREAK)]

&WHITEBG_STAFFSUM [v(JOB_VA)]=%r[repeat(-, u(FN_FLEXWIDTH, 79))]%r[rjust(ansi(c, DB#:), 10)] %0[space(10)][rjust(ansi(c, Comments:), 10)] [setr(z, words(lattr(%0/COMMENT_*)))]%r%r[rjust(ansi(c, Players:), 10)] %(Players contributing to this job%)%r[setq(y, setunion(iter(lattr(%0/COMMENT_*), extract(get(%0/##), 4, 1, |), %b, |),, |))][u(%va/fn_columns, %qy, 20, |, 11)][ifelse(u(%va/FN_HASATTR, %0, LIST_READERS), %r[rjust(ansi(c, Readers:), 10)] %(Players who have read this job in the past%)%r[setq(z, iter(get(%0/LIST_READERS), first(##, |)))][u(%va/fn_columns, map(%va/MAP_NAME, %qz, %b, |), 20, |, 11)],)][rjust(ansi(c, Stats:), 10)]%r[u(%va/fn_columns, iter(ifelse(u(%va/FN_HASATTR, %0, LIST_STATS), sort(get(%0/LIST_STATS)),), [first(##, |)] [last(##, |)], %b, |), 20, |, 11)]%r

&WHITEBG_BANNER [v(JOB_VA)]=[setq(0, %0)][setq(x, u(%va/FN_ITEMIZE, map(MAP_NAME, get(%q0/OPENED_BY), %b, |), |))][setq(y, u(%va/FN_ITEMIZE, map(MAP_NAME, get(%q0/TAGGED_FOR), %b, |), |))][ljust([rjust(ansi(c, Bucket:), 10)] [u(%va/FN_BUCKETNAME, %q0)], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(c, Due On:), 12)] [ifelse(get(%q0/DUE_ON), ifelse(gt(secs(), get(%q0/DUE_ON)), OVERDUE!, convsecs(get(%q0/DUE_ON))), -)]%r[ljust([rjust(ansi(c, Title:), 10)] [get(%q0/TITLE)], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(c, Status:), 12)] [switch(get(%q0/PRIORITY), 1, Green, 2, Yellow, 3, Red)] %([last(get(%va/STATUS_[get(%q0/STATUS)]), |)]%)%r[ljust([rjust(ansi(c, Opened On:), 10)] [convsecs(get(%q0/OPENED_ON))], div(u(FN_FLEXWIDTH, 80), 2))][rjust(ansi(c, Assigned To:), 12)] [ifelse(isdbref(get(%q0/ASSIGNED_TO)), name(get(%q0/ASSIGNED_TO)), Nobody)]%r[rjust(ansi(c, Opened By:), 10)]%b%qx[ifelse(words(%qy), %r[rjust(ansi(c, Tagged:), 10)]%b%qy,)]

&CREDITS [v(JOB_VA)]=Starfleet@Anomaly

&MAINTAINER [v(JOB_VA)]=Minion@Crossroads

&CONTRIBUTORS [v(JOB_VA)]=Firestorm@Ephemera, Grey@Anomaly, Ian@MUX, Minion@Crossroads

&LICENSE [v(JOB_VA)]=You may port this code to any game provided that these credits remain intact. Please report any and all bugs, feedback, etc. to the project's home: http:

&RELEASE [v(JOB_VA)]=March 18, 2011

&VERSION [v(JOB_VA)]=v6.4

&VERSION [v(JOB_VC)]=v6.4

@switch first(version())=RhostMUSH,{&TRIG_MAIL [v(JOB_VB)]=lit(mail [remove(%0,owner(me))]=%1//%2)},PennMUSH,{&TRIG_MAIL [v(JOB_VB)]=lit(@mail [remove(%0,owner(me))]=%1/%2)},{&TRIG_MAIL [v(JOB_VB)]=lit(@mail/quick [remove(%0,owner(me))]/%1=%2)}

&TRIG_POST [v(JOB_VB)]=+bbpost %0/%1=%2

&daily [v(JOB_VC)]=@dolist lcon(me)={@switch [u(%va/FN_HASATTR, ##, HOOK_AUT)]=1, {@trigger ##/HOOK_AUT=[u(%va/fn_trim, ## [remove(children(##), #-1)], b)], [owner(%va)]}}

@switch first(version())=PennMUSH, {think [ansi(hc, ANOMALY JOBS:)] PennMUSH does not have @daily.%BAdd a daily trigger to [v(JOB_VC)]/DAILY to your CRON object.}, RhostMUSH, {think [ansi(hc, ANOMALY JOBS:)] RhostMUSH does not have @daily.%BInstall an @daily emulator or add a daily trigger to [v(JOB_VC)]/DAILY to your CRON object.}

@switch [v(JOB_PATCH)]=0, {&ACCESS [v(JOB_VC)]=lit([u(%va/FN_STAFFALL, %#)]);&ACCESS_DESC [v(JOB_VC)]=lit([u(%va/FN_STAFFALL, %0)]);&ACCESS_HELP [v(JOB_VC)]=lit([u(%va/FN_STAFFALL, %0)]);&ACCESS_HIDDEN [v(JOB_VC)]=lit([u(%va/FN_WIZONLY, %0)]);&ACCESS_LOCKED [v(JOB_VC)]=lit([u(%va/FN_WIZONLY, %0)]);&ACCESS_LOGFILE [v(JOB_VC)]=lit([u(%va/FN_WIZONLY, %0)]);&ACCESS_MYJOBS [v(JOB_VC)]=lit([u(%va/FN_WIZONLY, %0)]);&ACCESS_POST_APPROVE [v(JOB_VC)]=lit([u(%va/FN_WIZONLY, %0)]);&ACCESS_POST_COMPLETE [v(JOB_VC)]=lit([u(%va/FN_WIZONLY, %0)]);&ACCESS_POST_DENY [v(JOB_VC)]=lit([u(%va/FN_WIZONLY, %0)]);&ACCESS_TURNAROUND [v(JOB_VC)]=lit([u(%va/FN_WIZONLY, %0)]);}

&BLETTER_ADD [v(JOB_VC)]=Comments added to [name(%0)] by [name(%1)].

&BLETTER_APR [v(JOB_VC)]=[name(%0)] has been approved by [name(%1)].

&BLETTER_ASN [v(JOB_VC)]=[name(%0)] has been [ifelse(strmatch(%1, %2), claimed, assigned to [switch(%2,, nobody, name(%2))])] by [name(%1)].

&BLETTER_CKI [v(JOB_VC)]=[name(%0)] has been checked in by [name(%1)].

&BLETTER_CKO [v(JOB_VC)]=[name(%0)] has been checked out by [name(%1)].

&BLETTER_CLN [v(JOB_VC)]=[name(%0)] has been cloned by [name(%1)]. [name(%2)] is the new job.

&BLETTER_COM [v(JOB_VC)]=[name(%0)] has been completed by [name(%1)].

&BLETTER_CRE [v(JOB_VC)]=[name(%0)] has been created by [name(%1)] in [name(parent(%0))]: %2

&BLETTER_DNY [v(JOB_VC)]=[name(%0)] has been denied by [name(%1)].

&BLETTER_DUE [v(JOB_VC)]=[name(%0)]'s due date changed by [name(%1)].

&BLETTER_DEL [v(JOB_VC)]=[name(%0)] has been deleted by [name(%1)].

&BLETTER_EDT [v(JOB_VC)]=[name(%0)] has been edited by [name(%1)].

&BLETTER_ESC [v(JOB_VC)]=[name(%0)] has been escalated to %2 by [name(%1)].

&BLETTER_LOK [v(JOB_VC)]=[name(%0)] has been locked by [name(%1)].

&BLETTER_MAI [v(JOB_VC)]=[name(%1)] has sent mail regarding [name(%0)].

&BLETTER_MRG [v(JOB_VC)]=[name(%2)] has been merged into [name(%0)] by [name(%1)].

&BLETTER_MYS [v(JOB_VC)]=[name(%0)]/%2 mysummary setting has been modified by [name(%1)].

&BLETTER_NAM [v(JOB_VC)]=[name(%0)] has been renamed to '%2' by [name(%1)].

&BLETTER_OTH [v(JOB_VC)]=[name(%0)] has been created by [name(%1)] in [name(parent(%0))]: %2

&BLETTER_PUB [v(JOB_VC)]=[name(%0)][ifelse(t(strlen(%2)), /Comment %2,)] has been published by [name(%1)].

&BLETTER_SRC [v(JOB_VC)]=[name(%0)]'s source has been changed by [name(%1)].

&BLETTER_STA [v(JOB_VC)]=[name(%0)]'s status has been changed by [name(%1)].

&BLETTER_SUM [v(JOB_VC)]=[name(%0)]/%2 summary setting has been modified by [name(%1)].

&BLETTER_TAG [v(JOB_VC)]=[name(%0)]'s tags have been altered by [name(%1)].

&BLETTER_TRN [v(JOB_VC)]=[name(%0)] has been transferred to the [name(%2)] bucket by [name(%1)].

&BLETTER_UND [v(JOB_VC)]=[name(%0)] has been undeleted by [name(%1)].

&BLETTER_UNL [v(JOB_VC)]=[name(%0)] has been unlocked by [name(%1)].

&BLETTER_UNP [v(JOB_VC)]=[name(%0)][ifelse(t(strlen(%2)), /Comment %2,)] has been unpublished by [name(%1)].

&ERROR_HIDDEN [v(JOB_VC)]=Valid options for the HIDDEN parameter are 'yes' and 'no'.

&ERROR_LOCKED [v(JOB_VC)]=Valid settings for the LOCKED parameter are 'yes' and 'no'.

&ERROR_MYJOBS [v(JOB_VC)]=Valid settings for the MYJOBS parameter are 'yes' and 'no'.

&ERROR_POST_APPROVE [v(JOB_VC)]=The setting for the POST_APPROVE parameter must be a positive integer.

&ERROR_POST_COMPLETE [v(JOB_VC)]=The setting for the POST_COMPLETE parameter must be a positive integer.

&ERROR_POST_DENY [v(JOB_VC)]=The setting for the POST_DENY parameter must be a positive integer.

&ERROR_TURNAROUND [v(JOB_VC)]=You must provide a turnaround time in hours.

&HELP [v(JOB_VC)]=%rThere is no help available for that bucket. To set help information for the [name(me)] bucket, use:%r%r[space(5)]+bucket/set [lcstr(name(me))]/help=<information>%r

&HOOK_CKO [v(JOB_VC)]=@cpattr %0/ASSIGNED_TO=%0/TEMP_ASN;&ASSIGNED_TO %0=%1

&HOOK_CKI [v(JOB_VC)]=&ASSIGNED_TO %0=[get(%0/TEMP_ASN)];&TEMP_ASN %0=-

&HOOK_MAI [v(JOB_VC)]=@set %0/[last(sortby(%va/SORTBY_COMMENTS, lattr(%0/COMMENT_*)))]=no_inherit

&MLETTER_APR [v(JOB_VC)]=[name(%0)] has been approved:%r%r[last(get(%0/COMMENT_1), |)]%r[repeat(-, 75)]%r[ansi(h, Comments added by [name(%2)]:)] %3

&MLETTER_DNY [v(JOB_VC)]=[name(%0)] has been denied:%r%r[last(get(%0/COMMENT_1), |)]%r[repeat(-, 75)]%r[ansi(h, Comments added by [name(%2)]:)] %3

&MLETTER_MAI [v(JOB_VC)]=[name(%2)] is mailing you regarding [name(%0)]:%r%r%3%r[repeat(-, 75)]%rUnless this letter indicates otherwise%, you should respond with the following command:%r%r[space(5)][ansi(h, +myjob/add [last(name(%0))]=<your comments>)]

&PLETTER_APR [v(JOB_VC)]=[space(10)][ansi(h, Job:)] #[last(name(%0))]%r[space(8)][ansi(h, Title:)] [get(%0/TITLE)]%r[space(4)][ansi(h, Opened By:)] [u(%va/FN_PLAYERLIST, %0)]%r[space(4)][ansi(h, Opened On:)] [convsecs(get(%0/OPENED_ON))]%r%b[ansi(h, Completed By:)] [name(%2)]%r%b[ansi(h, Completed On:)] [time()]%r%r[last(get(%0/COMMENT_1), |)]%r[repeat(-, 78)]%r[ansi(h, Comments from [name(%2)]:)] %3%r%rThis job was approved.

&PLETTER_COM [v(JOB_VC)]=Job [last(name(%0))] has been completed by [name(%2)]:%r%r[last(get(%0/COMMENT_1), |)]%r[repeat(-, 78)]%r[ansi(h, Comments from [name(%2)]:)] %3

&PLETTER_DNY [v(JOB_VC)]=[space(10)][ansi(h, Job:)] #[last(name(%0))]%r[space(8)][ansi(h, Title:)] [get(%0/TITLE)]%r[space(4)][ansi(h, Opened By:)] [u(%va/FN_PLAYERLIST, %0)]%r[space(4)][ansi(h, Opened On:)] [convsecs(get(%0/OPENED_ON))]%r%b[ansi(h, Completed By:)] [name(%2)]%r%b[ansi(h, Completed On:)] [time()]%r%r[last(get(%0/COMMENT_1), |)]%r[repeat(-, 78)]%r[ansi(h, Comments from [name(%2)]:)] %3%r%rThis job was denied.

&PROCESS_DESC [v(JOB_VC)]=[setq(3, DESC)][setq(1, %0)]1

&PROCESS_HELP [v(JOB_VC)]=[setq(3, HELP)][setq(1, %0)]1

&PROCESS_HIDDEN [v(JOB_VC)]=[setq(3, HIDDEN)][setq(1, switch(lcstr(%0), yes, 1, no,, 0))][switch(%q1,, 1, %q1)]

&PROCESS_LOCKED [v(JOB_VC)]=[setq(3, LOCKED)][setq(1, switch(lcstr(%0), yes, 1, no,, 0))][switch(%q1,, 1, %q1)]

&PROCESS_LOGFILE [v(JOB_VC)]=[setq(3, LOGFILE)][setq(1, %0)]1

&PROCESS_MYJOBS [v(JOB_VC)]=[setq(3, PUBLIC)][setq(1, switch(lcstr(%0), yes, 1, no,, 0))][switch(%q1,, 1, %q1)]

&PROCESS_POST_APPROVE [v(JOB_VC)]=[setq(3, POST_APPROVE)][setq(1, u(%va/FN_FIND-BBDBREF, %0))][gt(%0, 0)]

&PROCESS_POST_COMPLETE [v(JOB_VC)]=[setq(3, POST_COMPLETE)][setq(1, u(%va/FN_FIND-BBDBREF, %0))][gt(%0, 0)]

&PROCESS_POST_DENY [v(JOB_VC)]=[setq(3, POST_DENY)][setq(1, u(%va/FN_FIND-BBDBREF, %0))][gt(%0, 0)]

&PROCESS_TURNAROUND [v(JOB_VC)]=[setq(3, TURNAROUND)][setq(1, %0)][isnum(%0)]

@switch [hasattr(v(JOB_VC), STAT_ART)]=0, {&STAT_ART [v(JOB_VC)]=0 0}

@set [v(JOB_VC)]/STAT_ART=NO_INHERIT

@dolist VA VB VC={@cpattr %#/JOB_##=[v(JOB_VC)]/##}

@switch [v(JOB_PATCH)]=0, {think [ansi(hc, ANOMALY JOBS:)] Setting up buckets.}, {think [ansi(hc, ANOMALY JOBS:)] Keeping your current bucket setup.}

@switch [v(JOB_PATCH)]=0, {think [setq(0, create(ADMIN, 10))][setq(1, create(Job 1, 10))];@Desc %q0=For game administrative issues.;@lock/Speech %q0=ACCESS/1;&ACCESS %q0=lit([u(%va/FN_STAFFALL, %#)]);@parent %q0=[v(JOB_VC)];@tel %q0=[v(JOB_VC)];think [ansi(hc, ANOMALY JOBS:)] Creating initial job.;&OPENED_BY %q1=%#;&OPENED_ON %q1=[secs()];&MODIFIED_ON %q1=[secs()];&STATUS %q1=1;&TITLE %q1=Welcome;@parent %q1=%q0;@tel %q1=[v(JOB_VA)];&NUM_COMMENT %q1=3;&LIST_STATS %q1=ADD|1;&PRIORITY %q1=1;&COMMENT_1 %q1=CRE|[secs()]|#0|Anomaly Jobs|Thank you for choosing Anomaly Jobs. This is fully-featured task tracking code that helps to keep games organized. Please see '+jobs/credits' for information on version, license and other credits.;&COMMENT_2 %q1=ADD|[secs()]|#0|Anomaly Jobs|Remember that /complete posts to the public BBS (unless changed for a bucket - see the help file on buckets). /approve and /deny sends mail to the job-creator, and posts to private BBS.;@set %q1=UNFINDABLE;&JOBS_NUM [v(JOB_VA)]=1;&MAX_JOBS [v(JOB_VA)]=200;@switch [first(version())]=TinyMUSH, {@set %q1=!COMMANDS}, {@set %q1=NO_COMMAND}}

@switch [v(JOB_PATCH)]=0, {think [setq(0, create(APPS, 10))];@Desc %q0=Character applications submitted for review.;@lock/Speech %q0=ACCESS/1;&ALETTER_OTH %q0=lit(Application for approval submitted by [name(%1)].);&MLETTER_OTH %q0=lit(You have submitted an application for approval. Please give staff some time to process the application. You will hear back soon.);&MLETTER_APR %q0=lit(You have been approved by [name(%2)].);&PLETTER_APR %q0=lit([name(%2)] has approved [name(get(%0/OPENED_BY))] for roleplay.);&ACCESS %q0=lit([u(%va/FN_STAFFALL, %#)]);@parent %q0=[v(JOB_VC)];@tel %q0=[v(JOB_VC)]}

@switch [v(JOB_PATCH)]=0, {think [setq(0, create(BUILD, 10))];@Desc %q0=For building issues and typo reports.;@lock/Speech %q0=ACCESS/1;&PUBLIC %q0=1;&ACCESS %q0=lit([or(haspower(%#, builder), u(%va/FN_STAFFALL, %#))]);@set %q0=SAFE;@parent %q0=[v(JOB_VC)];@tel %q0=[v(JOB_VC)]}

@switch [v(JOB_PATCH)]=0, {think [setq(0, create(CGEN, 10))];@Desc %q0=For character generation problems and updates.;@lock/Speech %q0=ACCESS/1;&ACCESS %q0=lit([u(%va/FN_STAFFALL, %#)]);@parent %q0=[v(JOB_VC)];@tel %q0=[v(JOB_VC)]}

@switch [v(JOB_PATCH)]=0, {think [setq(0, create(CODE, 10))];@Desc %q0=For bugs and code enhancements.;@lock/Speech %q0=ACCESS/1;&PUBLIC %q0=1;&ACCESS %q0=lit([u(%va/FN_STAFFALL, %#)]);@set %q0=SAFE;@parent %q0=[v(JOB_VC)];@tel %q0=[v(JOB_VC)]}

@switch [v(JOB_PATCH)]=0, {think [setq(0, create(FEEP, 10))];@Desc %q0=Storage for unimplemented game ideas.;@lock/Speech %q0=ACCESS/1;&HIDDEN %q0=1;&ACCESS %q0=lit([u(%va/FN_STAFFALL, %#)]);@parent %q0=[v(JOB_VC)];@tel %q0=[v(JOB_VC)]}

@switch [v(JOB_PATCH)]=0, {think [setq(0, create(FORUM, 10))];@Desc %q0=Tabled discussion jobs. Feedback needed.;@lock/Speech %q0=ACCESS/1;&ACCESS %q0=lit([u(%va/FN_STAFFALL, %#)]);@parent %q0=[v(JOB_VC)];@tel %q0=[v(JOB_VC)]}

@switch [v(JOB_PATCH)]=0, {think [setq(0, create(PITCH, 10))];@Desc %q0=Pitched plots and stories.;@lock/Speech %q0=ACCESS/1;&ACCESS %q0=lit([u(%va/FN_STAFFALL, %#)]);&HIDDEN %q0=1;@set %q0=SAFE;@parent %q0=[v(JOB_VC)];@tel %q0=[v(JOB_VC)]}

@switch [v(JOB_PATCH)]=0, {think [setq(0, create(PUB, 10))];@Desc %q0=Public jobs. Everyone has +myjobs access.;@lock/Speech %q0=ACCESS/1;&ACCESS %q0=lit([u(%va/FN_STAFFALL, %#)]);&TRANSPARENT %q0=1;&PUBLIC %q0=1;&HOOK_CRE %q0=lit(@set %0/COMMENT_1=no_inherit);@parent %q0=[v(JOB_VC)];@tel %q0=[v(JOB_VC)]}

@switch [v(JOB_PATCH)]=0, {think [setq(0, create(QUERY, 10))];@Desc %q0=Query bucket.;@lock/Speech %q0=ACCESS/1;&PRIORITY %q0=2;&PUBLIC %q0=1;&ACCESS %q0=lit([u(%va/FN_STAFFALL, %#)]);&TURNAROUND %q0=168;&HOOK_OTH %q0=lit(@set %0/COMMENT_1=no_inherit;&ASSIGNED_TO %0=%1);&MLETTER_OTH %q0=lit(You have been issued an official query by the jobs system by [name(%2)]. You have [div(v(TURNAROUND), 24)] days at the time of this mail to respond to the query%, otherwise staff may need to act on the issue without your input. To see your query%, please type '+myjob [last(name(%0))]'.);@set %q0=SAFE;@parent %q0=[v(JOB_VC)];@tel %q0=[v(JOB_VC)]}

@switch [v(JOB_PATCH)]=0, {think [setq(0, create(REQ, 10))];@Desc %q0=Player requests.;@lock/Speech %q0=ACCESS/1;&PUBLIC %q0=1;&PRIORITY %q0=2;&ACCESS %q0=lit([u(%va/FN_STAFFALL, %#)]);&TURNAROUND %q0=72;&LOGFILE %q0=reqlog;&MLETTER_OTH %q0=lit(You have requested '[name(%0)]: [get(%0/TITLE)]' from staff: %r%r%3%r%r[repeat(-, 75)]%rSee '[ansi(h, +help myjobs)]' for help on how to display and add to your jobs.%r%rPlease give staff at least [u(me/TURNAROUND)] hours from the date of this mail to process your request.);@set %q0=SAFE;@parent %q0=[v(JOB_VC)];@tel %q0=[v(JOB_VC)]}

@switch [v(JOB_PATCH)]=0, {think [setq(0, create(RP, 10))];@Desc %q0=For storing potential plots.;@lock/Speech %q0=ACCESS/1;&ACCESS %q0=lit([u(%va/FN_STAFFALL, %#)]);&ACCESS_APPROVED %q0=lit([u(%va/FN_WIZONLY, %0)]);&ACCESS_ARC %q0=lit([u(%va/FN_STAFFALL, %0)]);&ACCESS_PLAYERS %q0=lit([u(%va/FN_STAFFALL, %0)]);&ACCESS_SCHEDULE %q0=lit([u(%va/FN_STAFFALL, %0)]);&ACCESS_STAFF %q0=lit([u(%va/FN_STAFFALL, %0)]);&ACCESS_SYNOPSIS %q0=lit([u(%va/FN_STAFFALL, %0)]);&ERROR_PLAYERS %q0=lit(I don't recognize [ansi(h, %qp)] as a player.);&ERROR_STAFF %q0=lit(I don't recognize [ansi(h, %qp)] as a player.);&HIDDEN %q0=1;&MAP_NAME %q0=lit([name(*%0)]);&PROCESS_APPROVED %q0=lit([setq(3, APPROVED)][setq(1, %0)]1);&PROCESS_ARC %q0=lit([setq(3, PLOT_ARC)][setq(1, u(%va/FN_STRTRUNC, %0, 50))]);&PROCESS_PLAYERS %q0=lit([setq(3, PLAYERS)][ifelse(not(gt(strlen(u(%va/fn_trim, squish(iter(%0, ifelse(not(isdbref(pmatch(itext(0)))), setr(p, itext(0)),))))), 0)), [setq(9, iter(%0, pmatch(itext(0))))][setq(8, get(%1/PLAYERS))][iter(%q9, ifelse(gt(member(%q8, ##), 0), setq(8, remove(%q8, ##)), setq(8, setunion(%q8, ##))))][setq(1, %q8)]1, 0)]);&PROCESS_SCHEDULE %q0=lit([setq(3, SCHEDULE)][setq(1, u(%va/FN_STRTRUNC, %0, 50))]1);&PROCESS_STAFF %q0=lit([setq(3, WRITER)][ifelse(not(gt(strlen(u(%va/fn_trim, squish(iter(%0, ifelse(not(isdbref(pmatch(itext(0)))), setr(p, itext(0)),))))), 0)), [setq(9, iter(%0, pmatch(itext(0))))][setq(8, get(%1/WRITER))][iter(%q9, ifelse(gt(member(%q8, ##), 0), setq(8, remove(%q8, ##)), setq(8, setunion(%q8, ##))))][setq(1, %q8)]1, 0)]);&PROCESS_SYNOPSIS %q0=lit([setq(3, BRIEF)][setq(1, %0)]1);&SUMMARY %q0=lit([rjust(ansi(hc, Approved:), 10)]%b[ifelse(u(%va/FN_HASATTRP, %0, APPROVED), get(%0/APPROVED), Unapproved)]%r[rjust(ansi(hc, Players:), 10)]%b[ifelse(u(%va/FN_HASATTRP, %0, PLAYERS), u(%va/FN_ITEMIZE, map(me/MAP_NAME, get(%0/PLAYERS), %b, |), |), Nobody)]%r[rjust(ansi(hc, Schedule:), 10)]%b[ifelse(u(%va/FN_HASATTRP, %0, SCHEDULE), get(%0/SCHEDULE), Unset)]%r[rjust(ansi(hc, Arc:), 10)]%b[ifelse(u(%va/FN_HASATTRP, %0, PLOT_ARC), get(%0/PLOT_ARC), Unset)]%r[rjust(ansi(hc, Staff:), 10)]%b[ifelse(u(%va/FN_HASATTRP, %0, WRITER), u(%va/FN_ITEMIZE, map(me/MAP_NAME, get(%0/WRITER), %b, |), |), Nobody)]%r[rjust(ansi(hc, Synopsis:), 10)]%b[ifelse(u(%va/FN_HASATTRP, %0, BRIEF), get(%0/BRIEF), Unset)]);&HELP %q0=lit(%r[space(5)]This bucket is for plots that have potential but aren't yet ready to run. Jobs in this bucket should remain here until the plot is approved to be run.%r%r[u(%va/FN_BREAK, ansi(hc, Settings for +job/sumset))]%r[ljust(ansi(h, PLAYERS), 10)] Accepts <player> as a valid parameter.%r[ljust(ansi(h, SCHEDULE), 10)] Describe when the plot is in effect.%r[ljust(ansi(h, ARC), 10)] Describes the story arc associated to this plot.%r[ljust(ansi(h, STAFF), 10)] Accepts <player> as a valid parameter.%r[ljust(ansi(h, SYNOPSIS), 10)] A brief synopsis of the plot.%r[ljust(ansi(h, APPROVED), 10)] Wiz-only, for approving plots. Accepts 'yes' or 'no'.);@parent %q0=[v(JOB_VC)];@tel %q0=[v(JOB_VC)]}

@switch [v(JOB_PATCH)]=0, {think [setq(0, create(TECH, 10))];@Desc %q0=Technology issues - weapon objects, etc.;@lock/Speech %q0=ACCESS/1;&ACCESS %q0=lit([u(%va/FN_STAFFALL, %#)]);@parent %q0=[v(JOB_VC)];@tel %q0=[v(JOB_VC)]}

@switch [v(JOB_PATCH)]=0, {think [setq(0, create(TPS, 10))];@Desc TPS=Actively running tiny plots.;@lock/Speech TPS=ACCESS/1;&SUMMARY TPS=lit([rjust(ansi(hc, Approved:), 10)]%b[ifelse(u(%va/FN_HASATTRP, %0, APPROVED), get(%0/APPROVED), Unapproved)]%r[rjust(ansi(hc, Players:), 10)]%b[ifelse(u(%va/FN_HASATTRP, %0, PLAYERS), u(%va/FN_ITEMIZE, map(me/MAP_NAME, get(%0/PLAYERS), %b, |), |), Nobody)]%r[rjust(ansi(hc, Schedule:), 10)]%b[ifelse(u(%va/FN_HASATTRP, %0, SCHEDULE), get(%0/SCHEDULE), Unset)]%r[rjust(ansi(hc, Arc:), 10)]%b[ifelse(u(%va/FN_HASATTRP, %0, PLOT_ARC), get(%0/PLOT_ARC), Unset)]%r[rjust(ansi(hc, Staff:), 10)]%b[ifelse(u(%va/FN_HASATTRP, %0, WRITER), u(%va/FN_ITEMIZE, map(me/MAP_NAME, get(%0/WRITER), %b, |), |), Nobody)]%r[rjust(ansi(hc, Synopsis:), 10)]%b[ifelse(u(%va/FN_HASATTRP, %0, BRIEF), get(%0/BRIEF), Unset)]);&MAP_NAME TPS=lit([name(*%0)]);&ACCESS TPS=lit([u(%va/FN_STAFFALL, %#)]);&ACCESS_PLAYERS TPS=lit([u(%va/FN_STAFFALL, %0)]);&PROCESS_PLAYERS TPS=lit([setq(3, PLAYERS)][ifelse(not(gt(strlen(u(%va/fn_trim, squish(iter(%0, ifelse(not(isdbref(pmatch(itext(0)))), setr(p, itext(0)),))))), 0)), [setq(9, iter(%0, pmatch(itext(0))))][setq(8, get(%1/PLAYERS))][iter(%q9, ifelse(gt(member(%q8, ##), 0), setq(8, remove(%q8, ##)), setq(8, setunion(%q8, ##))))][setq(1, %q8)]1, 0)]);&ERROR_PLAYERS TPS=lit(I don't recognize [ansi(h, %qp)] as a player.);&ACCESS_SCHEDULE TPS=lit([u(%va/FN_STAFFALL, %0)]);&PROCESS_SCHEDULE TPS=lit([setq(3, SCHEDULE)][setq(1, u(%va/FN_STRTRUNC, %0, 50))]1);&ERROR_SCHEDULE TPS=lit(You must enter a valid date string.);&ACCESS_ARC TPS=lit([u(%va/FN_STAFFALL, %0)]);&PROCESS_ARC TPS=lit([setq(3, PLOT_ARC)][setq(1, u(%va/FN_STRTRUNC, %0, 50))]);&ACCESS_STAFF TPS=lit([u(%va/FN_STAFFALL, %0)]);&PROCESS_STAFF TPS=lit([setq(3, WRITER)][ifelse(not(gt(strlen(u(%va/fn_trim, squish(iter(%0, ifelse(not(isdbref(pmatch(itext(0)))), setr(p, itext(0)),))))), 0)), [setq(9, iter(%0, pmatch(itext(0))))][setq(8, get(%1/WRITER))][iter(%q9, ifelse(gt(member(%q8, ##), 0), setq(8, remove(%q8, ##)), setq(8, setunion(%q8, ##))))][setq(1, %q8)]1, 0)]);&ERROR_STAFF TPS=lit(I don't recognize [ansi(h, %qp)] as a player.);&ACCESS_SYNOPSIS TPS=lit([u(%va/FN_STAFFALL, %0)]);&PROCESS_SYNOPSIS TPS=lit([setq(3, BRIEF)][setq(1, %0)]1);&ACCESS_APPROVED TPS=lit([u(%va/FN_WIZONLY, %0)]);&PROCESS_APPROVED TPS=lit([setq(3, APPROVED)][setq(1, %0)]1);&HELP TPS=lit(%r[space(5)]This bucket is for currently active plots that are running on the grid. Care should be taken to keep the headers of these jobs up-to-date, especially in terms of Progress settings and due dates. When the plot is completed, the job should be set complete and left open until follow-up requests are completed.%r%r[u(%va/FN_BREAK, ansi(hc, Settings for +job/sumset))]%r[ljust(ansi(h, PLAYERS), 10)] Accepts <player> as a valid parameter.%r[ljust(ansi(h, SCHEDULE), 10)] Describe when the plot is in effect.%r[ljust(ansi(h, ARC), 10)] Describes the story arc associated to this plot.%r[ljust(ansi(h, STAFF), 10)] Accepts <player> as a valid parameter.%r[ljust(ansi(h, SYNOPSIS), 10)] A brief synopsis of the plot.%r[ljust(ansi(h, APPROVED), 10)] Wiz-only, for approving plots. Accepts 'yes' or 'no'.);@parent TPS=[v(JOB_VC)];@tel TPS=[v(JOB_VC)]}

@switch [v(JOB_PATCH)]=0, {&HAS_ACCESS [v(JOB_VA)]=lit([or(haspower(%0, builder), u(%va/FN_STAFFALL, %0))]);&ADD_ACCESS [v(JOB_VA)]=lit([u(%va/FN_STAFFALL, %0)]);&APPROVE_ACCESS [v(JOB_VA)]=lit([u(%va/FN_STAFFALL, %0)]);&COMPLETE_ACCESS [v(JOB_VA)]=lit([u(%va/FN_STAFFALL, %0)]);&CREATE_ACCESS [v(JOB_VA)]=lit([u(%va/FN_STAFFALL, %0)]);&DENY_ACCESS [v(JOB_VA)]=lit([u(%va/FN_STAFFALL, %0)]);&EDIT_ACCESS [v(JOB_VA)]=lit([u(%va/FN_STAFFALL, %0)]);&GIVE_ACCESS [v(JOB_VA)]=lit([u(%va/FN_WIZONLY, %0)]);&LOG_ACCESS [v(JOB_VA)]=lit([u(%va/FN_WIZONLY, %0)]);&MAIL_ACCESS [v(JOB_VA)]=lit([u(%va/FN_STAFFALL, %0)]);&STATS_ACCESS [v(JOB_VA)]=lit([u(%va/FN_STAFFALL, %0)]);&CONFIG_ACCESS [v(JOB_VA)]=lit([u(%va/FN_STAFFALL, %0)]);}

@switch first(version())=RhostMUSH, {&FN_WIZONLY [v(JOB_VA)]=lit([gte(bittype(%0), 5)])}, {&FN_WIZONLY [v(JOB_VA)]=lit([hasflag(%0, WIZARD)])}

@switch first(version())=RhostMUSH, {&FN_STAFFALL [v(JOB_VA)]=lit([gte(bittype(%0), 2)])}, PennMUSH, {&FN_STAFFALL [v(JOB_VA)]=lit([orflags(%0, Wr)])}, {&FN_STAFFALL [v(JOB_VA)]=lit([orflags(%0, WZ)])}

@switch first(version())=RhostMUSH, {&FN_GUEST [v(JOB_VA)]=lit([eq(bittype(%0), 0)])}, {&FN_GUEST [v(JOB_VA)]=lit([haspower(%0, Guest)])}

@switch [v(JOB_PATCH)]=0, {&JOB_LOGGING [v(JOB_VA)]=1;&LOGFILE [v(JOB_VC)]=joblog}

@switch [first(version())]=TinyMUSH, {&BUFFER [v(JOB_VA)]=4000}, RhostMUSH, {&BUFFER [v(JOB_VA)]=3999}, {&BUFFER [v(JOB_VA)]=8000}

@switch [first(version())]=PennMUSH, {@set [v(JOB_GO)]=WIZARD}, {@set [v(JOB_GO)]=INHERIT}

@switch [first(version())]=TinyMUSH, {@set [v(JOB_GO)]=COMMANDS}, {@set [v(JOB_GO)]=!NO_COMMAND}

@switch [first(version())]=PennMUSH, {@set [v(JOB_GO)]=!HALT}, {@set [v(JOB_GO)]=!HALTED}

@set [v(JOB_GO)]=UNFINDABLE

@set [v(JOB_GO)]=SAFE

@switch [first(version())]=RhostMUSH, {@set [v(JOB_GO)]=SIDEFX}

@switch [first(version())]=PennMUSH, {@set [v(JOB_VA)]=WIZARD}, {@set [v(JOB_VA)]=INHERIT}

@set [v(JOB_VA)]=UNFINDABLE

@switch [first(version())]=TinyMUSH, {@set [v(JOB_VA)]=!COMMANDS}, {@set [v(JOB_VA)]=NO_COMMAND}

@switch [first(version())]=PennMUSH, {@set [v(JOB_VA)]=!HALT}, {@set [v(JOB_VA)]=!HALTED}

@set [v(JOB_VA)]=SAFE

@switch [first(version())]=RhostMUSH, {@set [v(JOB_VA)]=SIDEFX}

@set [v(JOB_VB)]=UNFINDABLE

@switch [first(version())]=TinyMUSH, {@set [v(JOB_VB)]=!COMMANDS}, {@set [v(JOB_VB)]=NO_COMMAND}

@switch [first(version())]=PennMUSH, {@set [v(JOB_VB)]=!HALT}, {@set [v(JOB_VB)]=!HALTED}

@set [v(JOB_VB)]=SAFE

@switch [first(version())]=PennMUSH, {@set [v(JOB_VC)]=WIZARD}, {@set [v(JOB_VC)]=INHERIT}

@set [v(JOB_VC)]=SAFE

@set [v(JOB_VC)]=UNFINDABLE

@switch [first(version())]=TinyMUSH, {@set [v(JOB_VC)]=COMMANDS}, {@set [v(JOB_VC)]=!NO_COMMAND}

@switch [first(version())]=PennMUSH, {@set [v(JOB_VC)]=!HALT}, {@set [v(JOB_VC)]=!HALTED}

@switch [first(version())]=RhostMUSH, {@set [v(JOB_VC)]=SIDEFX}

@dolist lcon([v(JOB_VC)])={@switch [first(version())]=PennMUSH, {@set ##=!HALT}, {@set ##=!HALTED};@switch [first(version())]=TinyMUSH, {@set ##=!COMMANDS}, {@set ##=NO_COMMAND};@set ##=UNFINDABLE;@switch [first(version())]=PennMUSH, {@set ##=WIZARD}, {@set ##=INHERIT};}

@switch [v(JOB_PATCH)]=0, {&INSTALL_DATE [v(JOB_VA)]=[time()]}

@lock [v(JOB_GO)]=me

@lock [v(JOB_VA)]=me

@lock [v(JOB_VB)]=me

@lock [v(JOB_VC)]=me

@switch [setq(0, switch(first(version()), PennMUSH, lsearch(all, eobjects, %[strmatch(name(##), bbpocket)%]), RhostMUSH, searchng(object=bbpocket), search(object=bbpocket)))][isdbref(%q0)][v(JOB_PATCH)]=0*, {think [ansi(hc, ANOMALY JOBS:)] Couldn't find Myrddin's BBS. Installation is not complete.}, 10, {think [ansi(hc, ANOMALY JOBS:)] Setting up the BBS.;&BBPOCKET [v(JOB_VC)]=%q0;+bbnewgroup Job Tracker;@wait 2={+bbnewgroup Staff Job Tracker};@wait 5={&POST_COMPLETE [setq(1, extract(u(%q0/GROUPS), dec(words(u(%q0/GROUPS))), 1))][setq(2, last(u(%q0/GROUPS)))][setq(3, v(JOB_VB))][setq(4, switch(first(version()), RhostMUSH, lit(gte(bittype(%0), 2)), PennMUSH, lit(orflags(%0, Wr)), lit(orflags(%0, WZ))))][v(JOB_VC)]=%q1;&POST_APPROVE [v(JOB_VC)]=%q2;&POST_DENY [v(JOB_VC)]=%q2;&POST_DELETE [v(JOB_VC)]=%q2;&CANREAD %q1=1;&CANWRITE %q1=%[or%(strmatch%(%%0, %q3%), %q4%)%];&CANREAD %q2=%q4;&CANWRITE %q2=%[or%(strmatch%(%%0, %q3%), %q4%)%];}}, {think [ansi(hc, ANOMALY JOBS:)] Updating BBS settings.;&BBPOCKET [v(JOB_VC)]=%q0;@dolist [v(JOB_VC)] [lcon(v(JOB_VC))]={@switch [and(hasattr(##, POST_COMPLETE), isnum(get(##/POST_COMPLETE)))][and(hasattr(##, POST_APPROVE), isnum(get(##/POST_APPROVE)))][and(hasattr(##, POST_DENY), isnum(get(##/POST_DENY)))][and(hasattr(##, POST_DELETE), isnum(get(##/POST_DELETE)))]=1???, {&POST_COMPLETE ##=[extract(u(%q0/GROUPS), get(##/POST_COMPLETE), 1)]}, ?1??, {&POST_APPROVE ##=[extract(u(%q0/GROUPS), get(##/POST_APPROVE), 1)]}, ??1?, {&POST_DENY ##=[extract(u(%q0/GROUPS), get(##/POST_DENY), 1)]}, ???1, {&POST_DELETE ##=[extract(u(%q0/GROUPS), get(##/POST_DELETE), 1)]}}}

&JOBSH me=-

&JOBSB me=-

@switch [v(JOB_PATCH)]=>0, {think [ansi(hc, ANOMALY JOBS:)] Checking hooks for compatibility.;@dolist [v(JOB_VC)] [lcon(v(JOB_VC))]={@switch [hasattr(##, HOOK_COMPLETE)][hasattr(##, HOOK_APPROVE)][hasattr(##, HOOK_DENY)][hasattr(##, HOOK_DELETE)]=1???, {think [ansi(hc, ANOMALY JOBS:)] ##/HOOK_COMPLETE not valid: move to ##/HOOK_COM;}, ?1??, {think [ansi(hc, ANOMALY JOBS:)] ##/HOOK_APPROVE not valid: move to ##/HOOK_APR;}, ??1?, {think [ansi(hc, ANOMALY JOBS:)] ##/HOOK_DENY not valid: move to ##/HOOK_DNY;}, ???1, {think [ansi(hc, ANOMALY JOBS:)] ##/HOOK_DELETE not valid: move to ##/HOOK_DEL;}}}

@switch [v(JOB_PATCH)]=>0, {think [ansi(hc, ANOMALY JOBS:)] Updating special job access to unique player ID.;@dolist switch(first(version()), PennMUSH, lsearch(all, eplayers, %[hasattrval(##, JOBSB)%]), RhostMUSH, searchng(eplayer=hasattr(##, JOBSB)), search(eplayer=hasattr(##, JOBSB)))={think [name(##)] has access to buckets: [u([v(JOB_VA)]/FN_ITEMIZE, iter(get(##/JOBSB), name(first(itext(0), :)), |), |)];&JOBSB ##=iter(get(##/JOBSB), u([v(JOB_VA)]/FN_OBJID, first(itext(0), :)))}}

@switch [v(JOB_PATCH)]=>0, {think [ansi(hc, ANOMALY JOBS:)] Updating new job indicators.;@dolist lcon(v(JOB_VA))={&LIST_JOBSN ##=[default(##/LIST_JOBSN, get(##/LIST_READERS))];}}

@wait 10={think [ansi(hc, ANOMALY JOBS:)] Script complete. Thanks for using Anomaly Jobs! You should drop the Job Global Object <JGO> in the master room. If you have opened up the system to more than just ROYALTY and WIZARD, you must have #1 lock and hide the attribute LAST_CONN. You should hide & lock JOBSH and JOBSB no matter what. For example:%r%r@attribute/access JOBSB=WIZARD%r@attribute/access JOBSH=HIDDEN[switch(first(version()), PennMUSH, %r%(On PennMUSH%, you must use /retroactive and also add these to a wizard's @startup.%))];}


&HOOK_APR [v(JOB_VC)]=@trigger [v(VA)]/TRIG_LOG=%0,[v(VA)]
&HOOK_DEL [v(JOB_VC)]=@trigger [v(VA)]/TRIG_LOG=%0,[v(VA)]
&HOOK_DNY [v(JOB_VC)]=@trigger [v(VA)]/TRIG_LOG=%0,[v(VA)]
&HOOK_COM [v(JOB_VC)]=@trigger [v(VA)]/TRIG_LOG=%0,[v(VA)]

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Thenomain's JRS, only slightly modified
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

@create Jobs Request System <jrs>=10

@set Jobs Request System <jrs>=inherit safe

@fo me=&d.jrs me=search(name=Jobs Request System <jrs>)

@desc Jobs Request System <jrs>=I know the following request types: %r[titlestr(iter(lattr(%!/d.*.bucket), edit(elements(%i0, 2, .), _, %b),, %,%b))]

@fo me=&d.jgo me=[search(name=Job Global Object <JGO>)]

@fo me=@va [v(d.jrs)]=[get(v(d.jgo)/va)]

@fo me=@vb [v(d.jrs)]=[get(v(d.jgo)/vb)]

@fo me=@vc [v(d.jrs)]=[get(v(d.jgo)/vc)]

@if not(isdbref(v(d.jgo)))=think ansi(rh, HEY! HEY!, n, %bI didn't find the `Jobs Global Object <JGO>`. The jobs request system isn't going to work.)

@if not(search(eobject=cand(strmatch(name(##), +allstaff), strmatch(loc(##), get(jrs/vb)))))={+jgroup/create +allstaff=All staff belong to this group.};@wait 3=&ismember [search(eobject=cand(strmatch(name(##), +allstaff), strmatch(loc(##), get(jrs/vb))))]=isstaff%( %%0 %);@fo me=@parent [v(d.jrs)]=[search(name=Code Object Data Parent <codp>)]

&c.request [v(d.jrs)]=$^\+?req(uest)?(.*)$:@trig %!/trig.command.request=objeval(%#, s(%2)), %#

@set v(d.jrs)/c.request=regex

@set v(d.jrs)/c.request=no_parse

@@ Fixed an issue where the error message would show some weird stuff: Request type not found. It could have been: request, bug, code,  builbucket... Now it shows: Request type not found. It could have been: request, bug, code, build, etc. I sorted it too.

&trig.command.request [v(d.jrs)]=@break u(%va/FN_GUEST, %1)={@pemit %1=u(.msg, %qr, This command is not available to guests.)}; think strcat(s:%b, setr(s, trim(rest(before(%0), /))), %r, 0:%b, setr(0, trim(if(strlen(%qs), rest(%0), %0))), %r, t:%b, setr(t, first(%q0, =)), %r, c:%b, setr(c, rest(%q0, =)), %r, s:%b, setr(s, if(strlen(%qs), %qs, request)), %r, m:%b, setr(m, lattr(%!/d.%qs*.bucket)), %r, m:%b, setr(m, if(words(%qm), %qm, lattr(%!/d.*.bucket))), %r,); @assert hasattr(%!, d.%qs.bucket)={@pemit %1=u(.msg, %qs, strcat(Request type not found., %b, It could have been:, %b, lcstr(itemize(sort(iter(%qM, extract(itext(0), 2, 1, .)), i),, or))))}; @assert u(f.validate.access, %qs, %1)={@pemit %1=u(.msg, %qs, This request type is staff-only.)}; @assert strlen(%qt)={@pemit %1=u(.msg, %qs, Your request needs a title.)}; @assert strlen(%qc)={@pemit %1=u(.msg, %qs, Your request needs some content.)}; @trig %!/trig.create.request=%qs, %1, %qt, %qc;

&trig.create.request [v(d.jrs)]=think strcat(a:%b, setr(a, ucstr(u(f.get.bucket, %0))), %r, b:%b, setr(b, u(%va/FN_FIND-BUCKET, %qa)), %r, i:%b, setr(i, lcstr(u(f.get.jgroup, %0))), %r, j:%b, setr(j, u(%va/FN_FIND-JGROUP, %qi)), %r,); @assert t(%qb)={@pemit %1=u(.msg, %0, I can't find the '%qa' bucket for this.)}; @assert t(%qj)={@pemit %1=u(.msg, %0, I can't find the '%qi' jgroup for this.)}; @pemit %1=u(.msg, %0, u(f.get.msg, %0, %2, %3)); @trigger %!/trig.create.job=%1, %qb, u(f.get.level, %0), [if(strlen(u(f.get.prefix, %0, %1)), [u(f.get.prefix, %0, %1)]:%b)][u(%va/FN_STRTRUNC, trim(%2), 30)], u(%va/FN_STRTRUNC, trim(%3), get(%va/BUFFER)), %qj;

&trig.create.job [v(d.jrs)]=@trigger %va/TRIG_CREATE=%0, %1, %2, %3, cat(%r%r, trimi(%4, l, %r)),, %5, 2

&.msg [v(d.jrs)]=cat(alert(ucstr(%0)), %1)

&f.validate.access [v(d.jrs)]=cor(isstaff(%1), not(udefault(f.%0.staff-only, 0)))

&f.get.bucket [v(d.jrs)]=udefault(d.%0.bucket, REQ)

&f.get.jgroup [v(d.jrs)]=udefault(d.%0.assign, +allstaff)

&f.get.prefix [v(d.jrs)]=udefault(d.%0.prefix, null(none), %1)

&f.get.level [v(d.jrs)]=udefault(d.%0.level, 1)

&f.get.msg [v(d.jrs)]=udefault(d.%0.msg, You have requested '[u(display.msg.job_title, %1)]' from staff. Please allow for some time to process it., %1, %2)

&display.msg.job_title [v(d.jrs)]=ansi(h, secure(u(%va/FN_STRTRUNC, trim(%0), 30)))

&display.generic_msg [v(d.jrs)]=You have requested [u(display.msg.job_title, %0)] as a '%1' request from staff. Please allow for some time to process it.

&d.request.bucket [v(d.jrs)]=REQ

&d.request.jgroup [v(d.jrs)]=+allstaff

&d.bug.bucket [v(d.jrs)]=CODE

&d.bug.jgroup [v(d.jrs)]=+code

&d.bug.prefix [v(d.jrs)]=BUG

&d.bug.level [v(d.jrs)]=3

&d.bug.msg [v(d.jrs)]=You have notified production staff of the [u(display.msg.job_title, %0)] bug with the details '[secure(u(%va/FN_STRTRUNC, trim(%1), get(%va/BUFFER)))]'. Staff will need the EXACT command(s) used to create this bug and, if possible, how the result differs from what you were expecting to happen. If you did not enter this information, please do so now.

&d.code.bucket [v(d.jrs)]=CODE

&d.code.jgroup [v(d.jrs)]=+code

&d.code.msg [v(d.jrs)]=u(display.generic_msg, %0, code)

&d.build.bucket [v(d.jrs)]=BUILD

&d.build.jgroup [v(d.jrs)]=+build

&d.build.msg [v(d.jrs)]=u(display.generic_msg, %0, build)

@tel [v(d.jrs)]=[config(master_room)]

@tel [v(JOB_GO)]=[config(master_room)]

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ JGroup creation
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

+jgroup/create +code=Code monkeys unite!
@force me=+jgroup/member %#=+code

+jgroup/create +allplayers=Every approved player on the grid. Spammy!
@wait 1=&ismember [search(ETHING=t(member(name(##), +allplayers)))]=lit(isapproved(%0))

+jgroup/create +build=For building stuff.
@force me=+jgroup/member %#=+build

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Add a reference to byzantine-opal so that buckets and the JRS can use it
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

@force me=&vZ [v(JOB_GO)]=[v(d.bf)]

@force me=&vZ [v(JOB_VC)]=[v(d.bf)]

@force me=&vZ [v(d.jrs)]=[v(d.bf)]

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Changed +typo to submit the player's location and use JRS:
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

&d.typo.bucket [v(d.jrs)]=BUILD

&d.typo.jgroup [v(d.jrs)]=+allstaff

&d.typo.msg [v(d.jrs)]=u(display.generic_msg, %0, typo)

@@ Use JRS for +typo and grab the player's location along with their comments.
&CMD_TYPO [v(JOB_GO)]=$+typo *:@force %#=req/typo [switch(rest(%0), *=*, %0, strcat(Typo:, %b, name(loc(%#)), =, Player location:, %b, loc(%#), %b>>>%b, name(loc(%#)), %%r, %b, Player comment:, %%r%%r, trimi(%0, l, %r)))]

@set [v(JOB_GO)]/CMD_TYPO=no_parse
