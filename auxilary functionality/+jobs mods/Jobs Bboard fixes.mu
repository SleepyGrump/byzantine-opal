/*
This mod includes various fixes for the way +jobs posts to boards.

1. If you specify &bboard_dbref on a bucket, instead of posting to the default boards (Job Tracker and Staff Job Tracker), the +jobs commands /approve, /complete, and /deny will post to that board.

2. If a job is public (the bucket is transparent), /approve, /complete. and /deny will post to the public "Job Tracker" board (unless another bboard_dbref is specified).

3. /complete no longer posts to the public "Job Tracker" board by default. Instead, it posts to whatever board is appropriate based on the rules above. (It always bothered me that /complete was set up to specially go to the public board. Weird UI.)

4. If you don't want a bucket to post to a board at all, give it the attribute &bbpref_do-not-post. No posts from that board will be published. This has no effect on standard logging.

5. When a bucket's name appears in a log file or on a board post, after a job has been completed/approved/denied, the bucket name shows up as "GOING" because the job is in the process of gooing away. This removes info from the logs and board posts, so I'm changing it to show both the original bucket name and the "GOING" flag as: BUCKETNAME (GOING) - if the job is in the process of going away.

6. Make BBPosts on completion contain the entire job and all of its comments, posted as +bbreplies to the initial +bbpost. You'll need Myrddin's BBS v5.0+ for this mod to work.

You can find it here: https://bitbucket.org/myrddin0/myrddins-mush-code/src/master/Myrddin's%20BBS/v5/ - and I highly recommend it. It's got themes! Replies! It's excellent. Without it, that last bit won't work, so I'll put a nice big divider in so you don't accidentally drop this stuff in without it.

*/

@force me=&POST_PRIVATE [v(JOB_VC)]=[search(ETHING=t(member(name(##), Staff Job Tracker, |)))]

@force me=&POST_PUBLIC [v(JOB_VC)]=[search(ETHING=cand(t(member(name(##), Job Tracker, |)), hasattr(##, canwrite)))]

&TRIG_POST [v(JOB_VA)]=@break hasattrp(%0, bbpref_do-not-post); @switch [u(%va/FN_HASATTRP, %0, PLETTER_%1)]=1, {@wait 1={@trigger %vb/TRIG_POST=[default(%0/bboard_dbref, if(u(%va/FN_HASATTRP, %0, transparent), get(%0/POST_PUBLIC), get(%0/POST_PRIVATE)))], [switch(%1, APR, A:, DNY, D:, COM, C:, [name(%0)]:)]%b[get(%0/TITLE)], [u(parent(%0)/PLETTER_%1, %0, %1, %2, %3)]};}

&FN_BUCKETNAME [v(JOB_VA)]=strcat(ifelse(isdbref(parent(%0)), name(parent(%0)), ERROR), if(get(%0/GOING), %b%(GOING%)))

@@ ============================================================================
@@ ============================================================================
@@ -
@@ Do not proceed further without installing Myrddin's BBS v5.0!
@@ -
@@ ============================================================================
@@ ============================================================================

&TRIG_POST [v(JOB_VA)]=@break hasattrp(%0, bbpref_do-not-post); @switch [u(%va/FN_HASATTRP, %0, PLETTER_%1)]=1, {@wait 1={@trigger %va/TRIG_FULL_POST=%0, %1, %2, %3};}

&TRIG_REPLY [v(JOB_VB)]=+bbreply %0/%1=%2;

&TRIG_FULL_POST [v(JOB_VA)]=@eval [setq(0, %0)][setq(1, parent(%q0))][setq(x, u(%va/FN_ITEMIZE, map(MAP_NAME, get(%q0/OPENED_BY), %b, |), |))][setq(B, default(%q0/bboard_dbref, if(u(%va/FN_HASATTRP, %q1, transparent), get(%q1/POST_PUBLIC), get(%q1/POST_PRIVATE))))]; @trigger %vb/TRIG_POST=%qB, [switch(%1, APR, A:, DNY, D:, COM, C:, [name(%0)]:)]%b[get(%0/TITLE)], [ljust([rjust(ansi(hc, Bucket:), 10)]%b[u(FN_BUCKETNAME, %q0)], 40)][rjust(ansi(hc, Due On:), 12)]%b[ifelse(get(%q0/DUE_ON), ifelse(gt(secs(), get(%q0/DUE_ON)), OVERDUE!, convsecs(get(%q0/DUE_ON))), -)]%r[ljust([rjust(ansi(hc, Title:), 10)]%b[get(%q0/TITLE)], 40)][rjust(ansi(hc, Assigned To:), 12)]%b[ifelse(isdbref(get(%q0/ASSIGNED_TO)), name(get(%q0/ASSIGNED_TO)), Nobody)]%r[ljust([rjust(ansi(hc, Opened On:), 10)]%b[convsecs(get(%q0/OPENED_ON))], 40)][rjust(ansi(hc, Status:), 12)]%b[switch(get(%q0/PRIORITY), 1, Green, 2, Yellow, 3, Red)]%b%([last(get(%va/STATUS_[get(%q0/STATUS)]), |)]%)%r[rjust(ansi(hc, Opened By:), 10)] %qx%r[setq(C, first(sortby(%va/SORTBY_COMMENTS, lattr(%q0/COMMENT_*))))][u(GAME_BREAK)]%r[extract(get(%q0/%qC), 4, 1, |)]%badded on%b[convsecs(extract(get(%q0/%qC), 2, 1, |))]:%b[edit(last(get(%q0/%qC), |), @@PIPE@@, |)]; @wait 1={ @eval setr(R, words(xget(%qB, mess_lst))); @dolist rest(sortby(%va/SORTBY_COMMENTS, lattr(%q0/COMMENT_*)))={ @trigger %vb/TRIG_REPLY=%qB, %qR, [extract(get(%q0/##), 4, 1, |)]%badded on%b[convsecs(extract(get(%q0/##), 2, 1, |))]:%b[edit(last(get(%q0/##), |), @@PIPE@@, |)]}; };
