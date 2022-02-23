/*
Stick those "JOB: Comments added to Job ## by Name" notices (and all other types of job notices) on a channel instead of individually pinging people.

If the bucket has its own channel, it'll go there in addition to the main broadcast channel.

To set it up using channel code:

+channel/create Jobs=A channel for jobs spam.
+channel/staff job
+channel/create Request Jobs=Requests jobs channel.
+channel/alias Request Jobs=rj
+channel/staff rj

&BROADCAST_CHANNEL [search(ETHING=t(member(name(##), REQ)))]=Request Jobs

All requests broadcasts would get sent to both the Jobs channel and the bucket's broadcast channel. That way you can monitor buckets individually or all at once. (Or both, but that's a lot of spam.)
*/

&BROADCAST_CHANNEL [v(JOB_VA)]=Jobs

&TRIG_BROADCAST [v(JOB_VA)]=@switch isdbref(%1)=1, { @cemit [setq(0, parent(%0))][setq(0, ifelse(isdbref(%q0), %q0, %vc))][v(BROADCAST_CHANNEL)]=[name(%q0)]: [u(%q0/BLETTER_%2, %0, %1, %3, %4)]; @if hasattr(%q0, BROADCAST_CHANNEL)={ @cemit xget(%q0, BROADCAST_CHANNEL)=[u(%q0/BLETTER_%2, %0, %1, %3, %4)]; }; }, {@cemit [setq(0, parent(%0))][setq(0, ifelse(isdbref(%q0), %q0, %vc))][v(BROADCAST_CHANNEL)]=%1; @if hasattr(%q0, BROADCAST_CHANNEL)={ @cemit xget(%q0, BROADCAST_CHANNEL)=%1; };}
