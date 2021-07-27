/*

Before beginning, install Myrddin's mushcron. You can find it at:

https://bitbucket.org/myrddin0/myrddins-mush-code/src/master/Myrddin's%20mushcron/v1.0.0/mushcron.v100.code

You may also want Myrddin's latest BBS, which is well worth installing:

https://bitbucket.org/myrddin0/myrddins-mush-code/src/master/Myrddin's%20BBS/v5/myrddin_bb.v5.code

If you do install it, the installer for this code will create a new theme which matches the game theme and set the BBS up to use it. (TODO: Make sure it's doing this.)

Run this code from a character with a wizard bit or from #1. (#1 is easier but less secure.)

*/

@force me=&d.cron me=[search(ETHING=t(member(name(##), CRON - Myrddin's mushcron, |)))]

think if(t(v(d.cron)), Good%, you have Myrddin's mushcron%, we can continue., ALERT: You don't have Myrddin's mushcron installed! Stop this install and grab that%, then re-run the above command.)

@@ These players do not get used by anyone, so it's not important if anyone knows their passwords. If you ever need to log into them, you're a wizard and can @newpass it.
@force me=@pcreate GridOwner=[iter(lnum(32), pickrand(a b c d e f g h i j k l m n o p q r s t u v w x y z 1 2 3 4 5 6 7 8 9 0 ! @ # $ ^ & * - _ + = |),, @@)]

@force me=@pcreate PlayerParent=[iter(lnum(32), pickrand(a b c d e f g h i j k l m n o p q r s t u v w x y z 1 2 3 4 5 6 7 8 9 0 ! @ # $ ^ & * - _ + = |),, @@)]

@force me=@pcreate GuestParent=[iter(lnum(32), pickrand(a b c d e f g h i j k l m n o p q r s t u v w x y z 1 2 3 4 5 6 7 8 9 0 ! @ # $ ^ & * - _ + = |),, @@)]

@@ Make sure this matches the room you want to make your OOC room.
@tel #0
@force me=&d.ooc me=[loc(%#)]

@dig Room Parent
@dig OOC Room Parent
@dig Commercial Room Parent
@dig Residential Room Parent
@dig Quiet Room=Quiet Room <QR>;qr;quiet,Out <O>;out;o;exit

@dig In Character=In Character <IC>;ic, Out of Character <OOC>;ooc; out;o;exit
@desc IC=Into the game!
&allowed_ic IC=ulocal(lock.allowed_ic, %#)
@lock IC=allowed_ic/1
@set [search(EEXIT=t(member(name(##), Out of Character <OOC>, |)))]=dark

@create Basic Data <BD>=10
@create Basic Functions <BF>=10
@create Basic Commands <BC>=10
@create Hook Object <HO>=10
@create Exit Parent <EP>=10

@force me=&d.go me=[search(EPLAYER=t(member(name(##), GridOwner, |)))]
@force me=&d.pp me=[search(EPLAYER=t(member(name(##), PlayerParent, |)))]
@force me=&d.gp me=[search(EPLAYER=t(member(name(##), GuestParent, |)))]
@force me=&d.rp me=[search(EROOM=t(member(name(##), Room Parent, |)))]
@force me=&d.orp me=[search(EROOM=t(member(name(##), OOC Room Parent, |)))]
@force me=&d.crp me=[search(EROOM=t(member(name(##), Commercial Room Parent, |)))]
@force me=&d.rrp me=[search(EROOM=t(member(name(##), Residential Room Parent, |)))]
@force me=&d.qr me=[search(EROOM=t(member(name(##), Quiet Room, |)))]
@force me=&d.ic me=[search(EROOM=t(member(name(##), In Character, |)))]
@force me=&d.bd me=[search(ETHING=t(member(name(##), Basic Data <BD>, |)))]
@force me=&d.bf me=[search(ETHING=t(member(name(##), Basic Functions <BF>, |)))]
@force me=&d.bc me=[search(ETHING=t(member(name(##), Basic Commands <BC>, |)))]
@force me=&d.ho me=[search(ETHING=t(member(name(##), Hook Object <HO>, |)))]
@force me=&d.ep me=[search(ETHING=t(member(name(##), Exit Parent <EP>, |)))]

@@ These only exist to make sure that if you have a public channel, our two created bits aren't on it.
@force me=@force [v(d.go)]=pub off
@force me=@force [v(d.pp)]=pub off

@set [v(d.pp)]=ANSI COLOR256 KEEPALIVE
@set [v(d.gp)]=ANSI COLOR256 KEEPALIVE

@set [v(d.rp)]=FLOATING HALTED LINK_OK NO_COMMAND OPAQUE
@set [v(d.orp)]=HALTED FLOATING
@set [v(d.crp)]=HALTED FLOATING
@set [v(d.rrp)]=HALTED FLOATING
@set [v(d.bd)]=SAFE
@set [v(d.bf)]=SAFE INHERIT
@set [v(d.bc)]=SAFE INHERIT
@set [v(d.ho)]=SAFE INHERIT
@set [v(d.ep)]=SAFE INHERIT TRANSPARENT
@set [v(d.qr)]=BLIND

@@ Set up parents for the existing rooms as OOC.

@force me=@dolist setdiff(search(TYPE=ROOM), v(d.orp))=@parent ##=[v(d.orp)]

@@ Set up the exit parent.

@force me=@dolist setdiff(search(TYPE=EXIT), v(d.ep))=@parent ##=[v(d.ep)]

@@ Set the existing players' parents to the PlayerParent so they get the code on it.

@force me=@dolist setdiff(search(TYPE=PLAYER), v(d.pp) #1)=@parent ##=[v(d.pp)]

@force me=@parent [v(d.qr)]=[v(d.orp)]
@force me=@parent [v(d.orp)]=[v(d.rp)]
@force me=@parent [v(d.rrp)]=[v(d.rp)]
@force me=@parent [v(d.crp)]=[v(d.rp)]
@force me=@parent [v(d.ic)]=[v(d.rp)]
@force me=@parent [v(d.bf)]=[v(d.bd)]
@force me=@parent [v(d.bc)]=[v(d.bf)]
@force me=@parent [v(d.ho)]=[v(d.bf)]
@force me=@parent [v(d.ep)]=[v(d.bf)]
@force me=@parent [v(d.rp)]=[v(d.bf)]

@tel [v(d.ho)]=[v(d.bf)]
@tel [v(d.ep)]=[v(d.bf)]
@tel [v(d.bd)]=[v(d.bf)]
@tel [v(d.bf)]=[v(d.bc)]

@force me=&vb [v(d.bf)]=[v(d.go)]
@force me=&vc [v(d.go)]=[v(d.bc)]
@force me=&vd [v(d.bf)]=[v(d.bd)]
@force me=&vd [v(d.go)]=[v(d.bd)]
@force me=&ve [v(d.bf)]=[v(d.crp)]
@force me=&vf [v(d.bf)]=[v(d.rrp)]
@force me=&vk [v(d.ep)]=[v(d.bf)]
@force me=&vo [v(d.bf)]=[v(d.orp)]
@force me=&vr [v(d.bf)]=[v(d.rp)]

@tel [v(d.bc)]=#2
