/*
Things I have done:

+job/add <#>=OK, player, this is what we need to do...

Three days later, player is like "Why haven't you contacted me on my job yet?"

Me: Oh. Right. THAT bucket is the one I have to +job/mail on, I can't just +job/add to it.

This doesn't get rid of that, but it does send a nice big warning sign in case you fat fingered /add for /mail.
*/

@@ If you're using default +jobs, you want this version:

&CMD_JOB/ADD [v(JOB_GO)]=$+job/add *=*:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][not(u(%va/IS_LOCKED, %q0, %#))][udefault(%q0/ADD_ACCESS, 1, %#)]=0*, {@pemit %#=Permission denied.}, 10*, {@pemit %#=That is an invalid job number.}, 110*, {@pemit %#=You do not have access to that job.}, 1110*, {@pemit %#=That job is presently [ifelse(u(%va/FN_HASATTRP, %q0, CHECKOUT), checked out to [name(first(get(%q0/CHECKOUT)))], locked)]}, 11110*, {@pemit %#=That action is not available for that job.}, {@pemit %#=Comments to [name(%q0)] added. Remember that players cannot see these comments unless you +job/publish [rest(name(%q0))]=<the comment number>, and they do not get notified via @mail if you add a comment. You may want to +job/mail [rest(name(%q0))]=<something> to let the player know you're working on it.;&TAGGED_FOR %q0=[remove(get(%q0/TAGGED_FOR), %#)];@trigger %va/TRIG_ADD=%q0, trim(%1), %#, ADD;@trigger %va/TRIG_BROADCAST=%q0, %#, ADD}

@@ If you're using "Make +jobs work like +myjobs for players" you want this version:

&CMD_JOB/ADD [v(JOB_GO)]=$+job/add *=*:@switch [u(%va/HAS_ACCESS, %#)][setq(0, u(%va/FN_FIND-JOB, %0))][isdbref(%q0)][u(%va/FN_ACCESSCHECK, parent(%q0), %#, %q0)][not(u(%va/IS_LOCKED, %q0, %#))][udefault(%q0/ADD_ACCESS, 1, %#)]=0*, { @force %#=+myjob/add %0=%1; }, 10*, {@pemit %#=That is an invalid job number.}, 110*, {@pemit %#=You do not have access to that job.}, 1110*, {@pemit %#=That job is presently [ifelse(u(%va/FN_HASATTRP, %q0, CHECKOUT), checked out to [name(first(get(%q0/CHECKOUT)))], locked)]}, 11110*, {@pemit %#=That action is not available for that job.}, {@pemit %#=Comments to [name(%q0)] added. Remember that players cannot see these comments unless you +job/publish [rest(name(%q0))]=<the comment number>, and they do not get notified via @mail if you add a comment. You may want to +job/mail [rest(name(%q0))]=<something> to let the player know you're working on it.;&TAGGED_FOR %q0=[remove(get(%q0/TAGGED_FOR), %#)];@trigger %va/TRIG_ADD=%q0, trim(%1), %#, ADD;@trigger %va/TRIG_BROADCAST=%q0, %#, ADD}
