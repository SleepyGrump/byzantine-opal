/*
Default +jobs uses its own definition of the "isstaff()" function, which can differ from your definition if you've customized isstaff() as I have. I use isstaff to:

1. Add any player object to staff.
2. NOT give that player any special flags/bits/fancy stuff.
3. Have most code work for them because isstaff() acknowledges this.

Jobs by default ignored that, so I customized it to call isstaff() and let the function do the work instead.

I left the FN_WIZONLY check alone because I'm fine with some functions of +jobs being restricted to actual wizards.
*/

&FN_STAFFALL [v(JOB_VA)]=isstaff(%0)

@@ This previously was "is it a builder or fn_staffall?" That's not appropriate for my game since the builder character does all the building and any staffer can command it. It's not a person with powers, it's a robot.

&HAS_ACCESS [v(JOB_VA)]=isstaff(%0)

@@ Gotta fix up the default job boards too while we're at it:

&CANREAD [search(ETHING=t(member(name(##), Staff Job Tracker, |)))]=isstaff(%0)

@force me=&CANWRITE [search(ETHING=t(member(name(##), Staff Job Tracker, |)))]=lit(%[or%(strmatch%(%%0, [v(JOB_VB)]%), isstaff%(%%0%)%)%])

@force me=&CANWRITE [search(ETHING=cand(t(member(name(##), Job Tracker, |)), hasattr(##, canwrite)))]=lit(%[or%(strmatch%(%%0, [v(JOB_VB)]%), isstaff%(%%0%)%)%])
