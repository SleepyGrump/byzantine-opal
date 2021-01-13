@@ RUN THIS FIRST.

@dig/teleport Room Parent
@wait 1=@force me=&d.rp me=[num(here)]

@wait 2=@dig/teleport OOC Room Parent
@wait 3=@force me=&d.orp me=[num(here)]

@wait 4=@set [v(d.rp)]=FLOATING HALTED LINK_OK NO_COMMAND OPAQUE
@wait 4=@set [v(d.orp)]=HALTED FLOATING
@wait 4=@parent [v(d.orp)]=[v(d.rp)]

@wait 5=@create Basic Data <BD>=10
@wait 6=@set BD=SAFE
@wait 7=@force me=&d.bd me=[num(BD)]

@wait 8=@create Basic Functions <BF>=10
@wait 9=@set BF=SAFE INHERIT
@wait 10=@parent BF=BD
@wait 11=@force me=&d.bf me=[num(BF)]

@wait 12=@create Basic Commands <BC>=10
@wait 13=@set BC=SAFE INHERIT
@wait 14=@parent BC=BF
@wait 15=@force me=&d.bc me=[num(BC)]

@wait 16=@tel [v(d.bd)]=[v(d.bf)]
@wait 17=@tel [v(d.bf)]=[v(d.bc)]

@wait 18=@force me=&vd [v(d.bf)]=[v(d.bd)]
