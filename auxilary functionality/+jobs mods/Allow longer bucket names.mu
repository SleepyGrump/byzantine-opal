/*
!!Install "Centralize column widths" first!!

This just makes it so you can have up to 10-letter buckets rather than the current limit of 5. I was annoyed at not being able to have a bucket named FACTIONS. Change WIDTH_B if you want a different width.

This includes a visual skin fix for the DEFAULT skin. I don't actually use the DEFAULT skin (I use the GAME skin) so it's not well-tested and bucket names may be truncated in several spots.
*/

&WIDTH_B [v(JOB_VA)]=10

&CMD_BUCKET/CREATE [v(JOB_GO)]=$+bucket/create *=*:@switch [setq(0, u(%va/FN_FIND-BUCKET, %0))][u(%va/FN_WIZONLY, %#)][not(isdbref(%q0))][not(gt(strlen(trim(%0)), get(%vA/WIDTH_B)))]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=There is already a bucket by that name.}, 110*, {@pemit %#=The name of a bucket is limited to [get(%vA/WIDTH_B)] letters.}, {@pemit %#=You have created a bucket named [ucstr(trim(%0))].[setq(0, create(ucstr(trim(%0)), get(%vA/WIDTH_B)))] Be sure to change %q0/ACCESS to establish who can access the bucket. Presently, it is set to 1, which means that anyone who can access +jobs can access the bucket.;@tel %q0=%vc;@parent %q0=%vc;@desc %q0=[trim(secure(%1))];@set %q0=inherit !safe !halted !no_command;&ACCESS %q0=1;@lock/speech %q0=ACCESS/1}

@@ Change the lookup to find buckets by PARTIAL names so you don't have to type the whole name out.
&FN_FIND-BUCKET [v(JOB_VA)]=if(isdbref(%0), %0, localize(if(t(setr(0, first(iter(lcon(%vC), if(t(strmatch(name(itext(0)), trim(%0)*)), itext(0)))))), %q0, #-1)))

&DEFAULT_BUCKETLIST [v(JOB_VA)]=[ifelse(u(%va/FN_WIZONLY, %#), [ljust(name(%0), v(WIDTH_B))]%b%b[ifelse(u(%va/FN_MONITORCHECK, %0, %#), V, -)][ifelse(u(%va/IS_HIDDEN, %0), H, -)][ifelse(u(%va/IS_LOCKED, %0), ifelse(u(%va/FN_HASATTRP, %0, CHECKOUT), C, L), -)][ifelse(u(%va/IS_TAGGED, %0), T, -)][ifelse(u(%va/IS_PUBLIC, %0), M, -)][ifelse(u(%va/IS_PUBLISHED, %0), P, -)][ifelse(u(%va/IS_SUMMARY, %0), S, -)]%b%b[u(%va/FN_STREXACT, get(%0/DESC), u(FN_FLEXWIDTH, 30))][rjust(words(remove(children(%0), #-1)), 3)][rjust(mul(round(fdiv(words(remove(children(%0), #-1)), max(1, words(lcon(%va)))), 2), 100)%%, 4)]%b[rjust(u(%va/FN_FIND-BBNUM, get(%0/POST_COMPLETE)), 2)]%b[rjust(u(%va/FN_FIND-BBNUM, get(%0/POST_APPROVE)), 2)]%b[rjust(u(%va/FN_FIND-BBNUM, get(%0/POST_DENY)), 2)][rjust(default(%0/TURNAROUND, 0), 5)][rjust([ifelse(u(%va/FN_HASATTR, %0, STAT_ART), [round(fdiv(fdiv(first(get(%0/STAT_ART)), rest(get(%0/STAT_ART))), 86400), 0)]d, -)], 6)], %b%b[ljust(name(%0), v(WIDTH_B))]%b%b[u(%va/FN_STREXACT, get(%0/DESC), u(FN_FLEXWIDTH, 43))]%b[rjust(ifelse(u(%va/FN_MONITORCHECK, %0, %#), Yes, -), 20)])]

&DEFAULT_BUCKETHEADER [v(JOB_VA)]=[u(FN_HEADER, Bucket List)]%r[ifelse(u(%va/FN_WIZONLY, %#), [ansi(hc, [ljust(Name, v(WIDTH_B))]%b%b[ljust(Flags, 6)]%b%b[ljust(Description, u(FN_FLEXWIDTH, 28))][rjust(#Jobs, 4)][rjust(Pct, 4)][space(3)]C%b%bA%b%bD%b%bDue[space(3)]ARTS)], [ansi(hc, [ljust(NAME, 8)][ljust(Description, u(FN_FLEXWIDTH, 50))]%b[rjust(Viewing, 20)])])]%r[u(FN_BREAK)]

