&p_pose [v(d.ho)]=ulocal(f.gag-poses-in-quiet-rooms)
&p_npose [v(d.ho)]=ulocal(f.gag-poses-in-quiet-rooms)
&p_say [v(d.ho)]=ulocal(f.gag-poses-in-quiet-rooms)
&p_nsay [v(d.ho)]=ulocal(f.gag-poses-in-quiet-rooms)
&p_@emit [v(d.ho)]=ulocal(f.gag-poses-in-quiet-rooms)
&p_\ [v(d.ho)]=ulocal(f.gag-poses-in-quiet-rooms)
&p_@remit [v(d.ho)]=ulocal(f.gag-poses-in-quiet-rooms)

&p_@moniker [v(d.ho)]=ulocal(f.isstaff-or-staff-object, %#, %@)

&AF_pose [v(d.ho)]=ulocal(f.forward-poses)
&AF_say [v(d.ho)]=ulocal(f.forward-poses)
&AF_@emit [v(d.ho)]=ulocal(f.forward-poses)
&AF_\ [v(d.ho)]=ulocal(f.forward-poses)
&AF_@remit [v(d.ho)]=ulocal(f.forward-poses)

&b_pose [v(d.ho)]=ulocal(f.posebreak)
&b_npose [v(d.ho)]=ulocal(f.posebreak)
&b_say [v(d.ho)]=ulocal(f.posebreak)
&b_nsay [v(d.ho)]=ulocal(f.posebreak)
&b_@emit [v(d.ho)]=ulocal(f.posebreak)
&b_\ [v(d.ho)]=ulocal(f.posebreak)
&b_@remit [v(d.ho)]=ulocal(f.posebreak)

@@ These lock building commands to staff-only. We want people using +dig and +temproom, which will ensure that each room is parented correctly and that all code functions everywhere.

&f.is-builder [v(d.bf)]=match(%#, GO)

@force me=@edit [v(d.bf)]/f.is-builder=GO, [v(d.go)]

&p_@dig [v(d.ho)]=ulocal(f.is-builder)
&p_@open [v(d.ho)]=ulocal(f.is-builder)
&p_@link [v(d.ho)]=ulocal(f.is-builder)

@startup [v(d.ho)]=@eval strcat(setq(L, lattr(me/*_*)), setq(A,), iter(%qL, setq(A, setunion(%qA, rest(itext(0), _))))); @dolist %qA={ @eval setq(C, squish(trim(cat(if(t(member(%qL, B_##)), before), if(t(member(%qL, A_##)), after), if(t(member(%qL, I_##)), ignore), if(t(member(%qL, P_##)), permit), if(t(member(%qL, AF_##)), fail))))); @admin hook_cmd=[lcstr(##)] %qC; @switch/first ##=POSE, { @admin hook_cmd=: %qC; @admin hook_cmd=\; %qC; }, @EMIT, { @admin hook_cmd=\\ %qC; }, SAY, { @admin hook_cmd=" %qC; }; };
