/*
My friends like this: Every time they approve, deny, delete, or complete a job, they get points. Those points show up in their +fingers for everyone to see. It's a source of friendly competition.

Yeah, wizards can technically edit the points attribute to say whatever they want, so it's not worth anything, metrics-wise, but it's nice to see the effort people put in reflected in a public way. If you've got a player who would edit this value manually, they probably don't need to be staff.

NOTE: This code includes the default log-to-a-server file code. To get rid of that, remove "@trigger [v(VA)]/TRIG_LOG=%0,[v(VA)]; ".
*/

&TRIG_POINTS [v(JOB_VC)]=@set %0=_job-points:[inc(default(%0/_job-points, 0))];

&HOOK_APR [v(JOB_VC)]=@trigger [v(VA)]/TRIG_LOG=%0,[v(VA)]; @trigger me/TRIG_POINTS=%1;
&HOOK_DEL [v(JOB_VC)]=@trigger [v(VA)]/TRIG_LOG=%0,[v(VA)]; @trigger me/TRIG_POINTS=%1;
&HOOK_DNY [v(JOB_VC)]=@trigger [v(VA)]/TRIG_LOG=%0,[v(VA)]; @trigger me/TRIG_POINTS=%1;
&HOOK_COM [v(JOB_VC)]=@trigger [v(VA)]/TRIG_LOG=%0,[v(VA)]; @trigger me/TRIG_POINTS=%1;

@@ Here's how to add it to +finger with this system:

&f.get-job_points [v(d.bf)]=xget(%0, _job-points)

@edit [v(d.bd)]/d.section.ooc_info=$,|Job Points

