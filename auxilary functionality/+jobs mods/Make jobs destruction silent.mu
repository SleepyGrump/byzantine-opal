/*
When a job gets destroyed, the owner of the jobs code gets a message like:

You get back your 10 Penny deposit for Job 9(#89).

This mod makes that stop.
*/

@force me=@pcreate ThingOwner=[iter(lnum(32), pickrand(a b c d e f g h i j k l m n o p q r s t u v w x y z 1 2 3 4 5 6 7 8 9 0 ! @ # $ ^ & * - _ + = |),, @@)]

&TRIG_DESTROY [v(JOB_VA)]=&going %0=1;@wait 60={@switch get(%0/GOING)=1, {@switch first(version())=PennMUSH, {@parent %0;@nuke %0;@wait 0=@nuke %0}, {@parent %0; @chown %0=pmatch(*thingowner); @dest/instant %0;}}}
