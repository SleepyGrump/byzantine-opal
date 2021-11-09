/*
While working on the GAME skin, I noticed that column widths in +jobs are scattered in many places. This code is to help with that. It centralizes the column widths for several other mods, including:
	- The GAME skin
	- Allow longer bucket names
	- Show dates as interval, then date
*/

&WIDTH_JOB [v(JOB_VA)]=5

&WIDTH_# [v(JOB_VA)]=8

&WIDTH_A [v(JOB_VA)]=16

&WIDTH_B [v(JOB_VA)]=5

&WIDTH_C [v(JOB_VA)]=8

&WIDTH_D [v(JOB_VA)]=8

&WIDTH_F [v(JOB_VA)]=4

&WIDTH_M [v(JOB_VA)]=8

&WIDTH_O [v(JOB_VA)]=16

&WIDTH_S [v(JOB_VA)]=8

&FOREACH_LEFTOVER [v(JOB_VA)]=%b[inc(switch(%0, #, default(%#/JOBSWIDTH_#, v(WIDTH_#)), A, default(%#/JOBSWIDTH_A, v(WIDTH_A)), B, default(%#/JOBSWIDTH_B, v(WIDTH_B)), C, default(%#/JOBSWIDTH_C, v(WIDTH_C)), D, default(%#/JOBSWIDTH_D, v(WIDTH_D)), F, default(%#/JOBSWIDTH_F, v(WIDTH_F)), M, default(%#/JOBSWIDTH_M, v(WIDTH_M)), O, default(%#/JOBSWIDTH_O, v(WIDTH_O)), S, default(%#/JOBSWIDTH_S, v(WIDTH_S)), 0))]

&HEADER_# [v(JOB_VA)]=u(FN_STREXACT, DB#, default(%#/JOBSWIDTH_#, v(WIDTH_#)))

&HEADER_A [v(JOB_VA)]=u(FN_STREXACT, Assigned To, default(%#/JOBSWIDTH_A, v(WIDTH_A)))

&HEADER_B [v(JOB_VA)]=u(FN_STREXACT, Type, default(%#/JOBSWIDTH_B, v(WIDTH_B)))

&HEADER_C [v(JOB_VA)]=u(FN_STREXACT, Opened, default(%#/JOBSWIDTH_C, v(WIDTH_C)))

&HEADER_D [v(JOB_VA)]=u(FN_STREXACT, Due On, default(%#/JOBSWIDTH_D, v(WIDTH_D)))

&HEADER_F [v(JOB_VA)]=u(FN_STREXACT, Flag, default(%#/JOBSWIDTH_F, v(WIDTH_F)))

&HEADER_M [v(JOB_VA)]=u(FN_STREXACT, Modified, default(%#/JOBSWIDTH_M, v(WIDTH_M)))

&HEADER_O [v(JOB_VA)]=u(FN_STREXACT, Opened By, default(%#/JOBSWIDTH_O, v(WIDTH_O)))

&HEADER_S [v(JOB_VA)]=u(FN_STREXACT, Status, default(%#/JOBSWIDTH_S, v(WIDTH_S)))

&DISPLAY_# [v(JOB_VA)]=[u(%va/FN_STREXACT, %0, default(%#/JOBSWIDTH_#, v(WIDTH_#)))]

&DISPLAY_A [v(JOB_VA)]=[u(%va/FN_STREXACT, ifelse(isdbref(get(%0/ASSIGNED_TO)), name(get(%0/ASSIGNED_TO)), -), default(%#/JOBSWIDTH_A, v(WIDTH_A)))]

&DISPLAY_B [v(JOB_VA)]=[u(%va/FN_STREXACT, u(%va/FN_BUCKETNAME, %0), default(%#/JOBSWIDTH_B, v(WIDTH_B)))]

&DISPLAY_C [v(JOB_VA)]=[u(%va/FN_STREXACT, u(%va/FN_SHORT_DATE, convsecs(get(%0/OPENED_ON))), default(%#/JOBSWIDTH_C, v(WIDTH_C)))]

&DISPLAY_D [v(JOB_VA)]=[u(%va/FN_STREXACT, switch(get(%0/STATUS), 0, --HOLD--, ifelse(get(%0/DUE_ON), ifelse(gt(secs(), get(%0/DUE_ON)), OVERDUE!, [u(%va/FN_SHORT_DATE, convsecs(get(%0/DUE_ON)))]), --------)), default(%#/JOBSWIDTH_D, v(WIDTH_D)))]

&DISPLAY_F [v(JOB_VA)]=[u(%va/FN_STREXACT, [ifelse(u(me/IS_LOCKED, %0), ifelse(u(%va/FN_HASATTRP, %0, CHECKOUT), C, L), -)][ifelse(u(me/IS_PUBLIC, %0), M, -)][ifelse(u(me/IS_TAGGED, %0), T, -)][ifelse(u(me/IS_PUBLISHED, %0), P, -)], default(%#/JOBSWIDTH_F, v(WIDTH_F)))]

&DISPLAY_M [v(JOB_VA)]=[u(%va/FN_STREXACT, u(%va/FN_SHORT_DATE, convsecs(get(%0/MODIFIED_ON))), default(%#/JOBSWIDTH_M, v(WIDTH_M)))]

&DISPLAY_O [v(JOB_VA)]=[u(%va/FN_STREXACT, name(first(get(%0/OPENED_BY))), default(%#/JOBSWIDTH_O, v(WIDTH_O)))]

&DISPLAY_S [v(JOB_VA)]=[u(%va/FN_STRTRUNC, center(switch([u(%va/FN_HASATTRP, %0, LOCKED)][u(%va/FN_HASATTRP, %0, CHECKOUT)], 1*, LOCKED, 01*, CHECKED, first(get(%va/STATUS_[get(%0/STATUS)]), |)), default(%#/JOBSWIDTH_S, 8)), default(%#/JOBSWIDTH_S, v(WIDTH_S)))]

&DEFAULT_JOBSHEADER [v(JOB_VA)]=[u(FN_HEADER, Anomaly Jobs [u(VERSION)])]%r[setq(j, [secure(switch(u(%va/FN_HASATTRP, %0, JOBS), 1, lcstr(mid(get(%0/JOBS), 0, 20)), u(JOBS_DEFAULT)))])][ansi(hc, *%b%b[ljust(Job#, v(WIDTH_JOB))][iter(lnum(strlen(%qj)), u(HEADER_[mid(%qj, ##, 1)]))])]%r[u(FN_BREAK)]

&DEFAULT_JOBLIST [v(JOB_VA)]=[setq(j, secure(ifelse(u(%va/FN_HASATTRP, %1, JOBS), lcstr(mid(get(%1/JOBS), 0, 20)), get(%va/JOBS_DEFAULT))))][setq(1, ifelse(get(%0/DUE_ON), ifelse(gt(secs(), get(%0/DUE_ON)), r, switch(get(%0/PRIORITY), 1, g, 2, y, 3, r, g)), switch(get(%0/PRIORITY), 1, g, 2, y, 3, r)))][ifelse(u(%va/FN_ISNEW, %0, %1), [ansi(hr, *)]%b, %b%b)][ansi(h%q1, [rjust([last(name(%0))], v(WIDTH_JOB))]%b[iter(lnum(strlen(%qj)), [u(%va/DISPLAY_[mid(%qj, ##, 1)], %0, %1)])])]

&DEFAULT_MYJOBSHEADER [v(JOB_VA)]=[u(FN_HEADER, Anomaly Jobs [u(VERSION)])]%r[setq(j, TDAS)][ansi(ch, ljust(*%b%b[ljust(Job#, v(WIDTH_JOB))][iter(lnum(strlen(%qj)), u(HEADER_[mid(%qj, ##, 1)]))], [u(FN_FLEXWIDTH, 79)]))]%r[u(FN_BREAK)]

&DEFAULT_MYJOBLIST [v(JOB_VA)]=[ifelse(u(FN_ISNEW, %0, %1), [ansi(hr, *)], %b)]%b[setq(j, TDAS)][ansi(n, [rjust([last(name(%0))], v(WIDTH_JOB))]%b[iter(lnum(strlen(%qj)), u(DISPLAY_[mid(%qj, ##, 1)], %0, %1))])]
