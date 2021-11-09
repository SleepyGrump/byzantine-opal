/*
I can't remember half the +jobs commands and I don't like it, so I added the following aliases:

+job/esc:
	+job/priority
	+job/pri
	+job/escalate

+job/trans
	+job/transfer
	+job/move

*/

&CMD_JOB/ESCALATE [v(JOB_GO)]=$+job/escalate *=*: @force %#=+job/esc %0=%1;

&CMD_JOB/PRI [v(JOB_GO)]=$+job/pri *=*: @force %#=+job/esc %0=%1;

&CMD_JOB/PRIORITY [v(JOB_GO)]=$+job/priority *=*: @force %#=+job/esc %0=%1;

&CMD_JOB/TRANSFER [v(JOB_GO)]=$+job/transfer *=*: @force %#=+job/trans %0=%1;

&CMD_JOB/MOVE [v(JOB_GO)]=$+job/move *=*: @force %#=+job/trans %0=%1;
