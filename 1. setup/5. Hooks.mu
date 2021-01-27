&f.gag-poses-in-quiet-rooms [v(d.bf)]=not(ulocal(f.is-target-room-gagged, loc(%#)))

&p_pose [v(d.ho)]=ulocal(f.gag-poses-in-quiet-rooms)
&p_npose [v(d.ho)]=ulocal(f.gag-poses-in-quiet-rooms)
&p_say [v(d.ho)]=ulocal(f.gag-poses-in-quiet-rooms)
&p_nsay [v(d.ho)]=ulocal(f.gag-poses-in-quiet-rooms)
&p_@emit [v(d.ho)]=ulocal(f.gag-poses-in-quiet-rooms)
&p_\ [v(d.ho)]=ulocal(f.gag-poses-in-quiet-rooms)
&p_@remit [v(d.ho)]=ulocal(f.gag-poses-in-quiet-rooms)

&p_@moniker [v(d.ho)]=ulocal(f.isstaff-or-staff-object, %#, %@)

&f.parse_emit [v(d.bf)]=switch(%1, *[moniker(%0)]*, %1, strcat(moniker(%0), switch(%1, :*, %b[rest(%1, :)], ;*, rest(%1, ;), pose/*, rest(%1), pose *, %b[rest(%1)], npose *, %b[rest(%1)], "*, %bsays "[rest(%1, ")]", say*, %bsays "[rest(%1)]", nsay*, %bsays "[rest(%1)]", @emit* *, : [rest(%1)], @remit* *=*, : [rest(%1, =)], @remit *, : [rest(%1)], \\*, : [trim(%1, l, \\\\\\\\)], %1)))

&f.forward-poses [v(d.bf)]=if(ulocal(f.is-redirected-to-channel, loc(%#)), trigger(me/tr.emit_to_channel, loc(%#), %m, %#))

&b_pose [v(d.ho)]=ulocal(f.forward-poses)
&b_npose [v(d.ho)]=ulocal(f.forward-poses)
&b_say [v(d.ho)]=ulocal(f.forward-poses)
&b_nsay [v(d.ho)]=ulocal(f.forward-poses)
&b_@emit [v(d.ho)]=ulocal(f.forward-poses)
&b_\ [v(d.ho)]=ulocal(f.forward-poses)
&b_@remit [v(d.ho)]=ulocal(f.forward-poses)

