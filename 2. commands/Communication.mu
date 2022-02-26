@@ Communication commands like ooc, ', +txt, etc.

@@ =============================================================================
@@ OOC
@@ =============================================================================

&layout.ooc_action [v(d.bf)]=cat(ulocal(d.ooc_text), moniker(%0), rest(%1, :))

&layout.ooc_apostrophe [v(d.bf)]=strcat(ulocal(d.ooc_text), %b, moniker(%0), rest(%1, ;))

&layout.ooc_text [v(d.bf)]=cat(ulocal(d.ooc_text), moniker(%0), says, "%1")

&c.ooc [v(d.bc)]=$ooc *:@trigger me/tr.remit=loc(%#), ulocal(layout.ooc_[switch(%0, :*, action, ;*, apostrophe, text)], %#, %0), %#;

&c.ooc_single-quote [v(d.bc)]=$'*:@trigger me/tr.remit=loc(%#), ulocal(layout.ooc_[switch(%0, :*, action, ;*, apostrophe, text)], %#, %0), %#;

@@ =============================================================================
@@ msg, +txt, +phone, etc - includes a voicemail system.
@@ =============================================================================

&tr.aconnect-msg [v(d.bc)]=@trigger me/switch.msg.summary=%0, 1;

&cmd-+txt [v(d.bc)]=$+txt*:@trigger me/switch.msg=/text%0, %#;

@set [v(d.bc)]/cmd-+txt=no_parse

&cmd-+text [v(d.bc)]=$+text*:@trigger me/switch.msg=/text%0, %#;

@set [v(d.bc)]/cmd-+text=no_parse

&cmd-+phone [v(d.bc)]=$+phone*:@trigger me/switch.msg=/phone%0, %#;

@set [v(d.bc)]/cmd-+phone=no_parse

&cmd-+tel [v(d.bc)]=$+tel*:@trigger me/switch.msg=/telepathy[switch(%0, epathy *, %b[rest(%0)], %0)], %#;

@set [v(d.bc)]/cmd-+tel=no_parse

&cmd-txt [v(d.bc)]=$txt*:@trigger me/switch.msg=/text%0, %#;

@set [v(d.bc)]/cmd-txt=no_parse

&cmd-text [v(d.bc)]=$text*:@trigger me/switch.msg=/text%0, %#;

@set [v(d.bc)]/cmd-text=no_parse

&cmd-phone [v(d.bc)]=$phone*:@trigger me/switch.msg=/phone%0, %#;

@set [v(d.bc)]/cmd-phone=no_parse

&cmd-tel [v(d.bc)]=$tel*:@trigger me/switch.msg=/telepathy[switch(%0, epathy *, %b[rest(%0)], %0)], %#;

@set [v(d.bc)]/cmd-tel=no_parse

&cmd-msg [v(d.bc)]=$msg*:@switch/first 1=and(strmatch(%0, /*), t(setr(S, first(lattr(me/switch.msg.[first(rest(%0, /), if(strmatch(first(%0), /*/*), /))]*))))), { @trigger me/%qS=first(%0), rest(%0), %#; }, { @trigger me/switch.msg=%0, %#; }

@set [v(d.bc)]/cmd-msg=no_parse

&switch.msg.summary [v(d.bc)]=@pemit setr(P, if(isdbref(%0), %0, %2))=strcat(if(t(%1), %r), alert(MSG) Message delivery, %b, if(t(xget(%qP, msg-receive-off)), disabled, enabled), .%b, if(t(setr(L, xget(%qP, last-msg-target))), strcat(You last messaged, %b, ansi(h, ulocal(f.get-name, %qL)), %b, via, %b, ansi(h, default(%qP/last-msg-type, msg)), .%b)), if(t(setr(0, lattr(%qP/msg-block-*))), strcat(You have blocked the following people:, %b, itemize(iter(%q0, ulocal(f.get-name, last(itext(0), -)),, |), |), .%b)), if(t(setr(0, lattr(%qP/msg-hide-*))), strcat(You have hidden all messages from the following people:, %b, itemize(iter(%q0, ulocal(f.get-name, last(itext(0), -)),, |), |), .%b)), if(t(setr(0, lattr(%qP/msg-send-*))), strcat(You have the following message shortcuts:, %b, itemize(iter(%q0, strcat(last(itext(0), -), :%b, ulocal(%qP/[itext(0)])),, |), |), .%b)), You have, %b, setr(0, words(lattr(%qP/_msg-*))), %b, unseen messages., if(gt(%q0, 0), %bType 'msg/view' to view them.), if(t(%1), %r));

&switch.msg.off [v(d.bc)]=&msg-receive-off %2=1; @pemit %2=alert(MSG) Message delivery disabled. First 50 messages will be queued for display when you turn messages back on.

&switch.msg.on [v(d.bc)]=@wipe %2/msg-receive-off; @pemit %2=alert(MSG) Message delivery enabled.; @trigger me/switch.msg.view=%0, %1, %2;

&switch.msg.view [v(d.bc)]=@switch/first t(setr(L, lattr(%2/_msg-*)))=1, {@pemit %2=alert(MSG) Here are the messages you missed.; @dolist/notify %qL={@pemit %2=strcat(\[, interval(rest(##, -)) ago, \], %b, xget(%2, ##)); @wipe %2/##;}; @wait me=@pemit %2=alert(MSG) All caught up.;}, {@pemit %2=alert(MSG) You have no unseen messages.;};

&switch.msg.block [v(d.bc)]=@eval setq(P, ulocal(f.find-player, first(%1, =), %2)); @assert t(%qP)={@pemit %2=alert(MSG) Could not find player '[first(%1, =)]' (%qP).;}; @eval strcat(setq(R, rest(%1, =)), if(not(t(%qR)), setq(R, 1))); &msg-block-%qP %2=%qR; @pemit %2=alert(MSG) You have blocked [ulocal(f.get-name, %qP)] from sending you messages. When [subj(%qP)] [case(subj(%qP), they, try, tries)] to message you, [subj(%qP)] will receive a message that says:%R[alert(MSG NOT SENT)] [ulocal(f.get-name, %2)] has blocked you[if(match(%qR, 1), ., %bbecause: [s(%qR)])]

&switch.msg.unblock [v(d.bc)]=@eval setq(P, ulocal(f.find-player, first(%1, =), %2)); @assert t(%qP)={@pemit %2=alert(MSG) Could not find player '[first(%1, =)]' (%qP).;}; @assert hasattr(%2, msg-block-%qP)={@pemit %2=alert(MSG) You are not currently blocking [ulocal(f.get-name, %qP)].}; @wipe %2/msg-block-%qP; @pemit %2=alert(MSG) You are no longer blocking [ulocal(f.get-name, %qP)] from sending you messages.

&switch.msg.hide [v(d.bc)]=@eval setq(P, ulocal(f.find-player, first(%1, =), %2)); @assert t(%qP)={@pemit %2=alert(MSG) Could not find player '[first(%1, =)]' (%qP).;}; &msg-hide-%qP %2=1; @pemit %2=alert(MSG) You have hidden all messages from [ulocal(f.get-name, %qP)]. Those messages will be lost forever, and [subj(%qP)] will not be notified that the message was not received.

&switch.msg.unhide [v(d.bc)]=@eval setq(P, ulocal(f.find-player, first(%1, =), %2)); @assert t(%qP)={@pemit %2=alert(MSG) Could not find player '[first(%1, =)]' (%qP).;}; @assert hasattr(%2, msg-hide-%qP)={@pemit %2=alert(MSG) You are not currently blocking [ulocal(f.get-name, %qP)].}; @wipe %2/msg-hide-%qP; @pemit %2=alert(MSG) You are no longer hiding messages from [ulocal(f.get-name, %qP)].

@@ %0 - sender
@@ %1 - title
&layout.title [v(d.bf)]=if(t(%1), udefault(%0/msg-send-%1, strcat(%ch<%cn, %1, %ch>%cn)), %ch<%cnmessage%ch>%cn)

@@ %0 - sender
@@ %1 - recipients
@@ %2 - type
@@ %3 - message
&layout.msg [v(d.bf)]=strcat(ulocal(layout.title, %0, %2), %b, To, %b, itemize(iter(%1, ulocal(f.get-name, itext(0)), |, |), |), :, %b, switch(%3, :*, ulocal(f.get-name, %0) [rest(%3, :)], ;*, ulocal(f.get-name, %0)[rest(%3, ;)], |*, %([ulocal(f.get-name, %0)]%) [rest(%3, |)], ulocal(f.get-name, %0) sends%, "%3"))

@@ %0: command string
@@ %1: receiver
&switch.msg [v(d.bc)]=@break t(xget(%1, msg-receive-off))={@trigger me/tr.error=%1, You cannot send messages while your ability to receive messages is turned off. Type msg/on to enable the message system.;};@break not(t(%0))={@trigger me/switch.msg.summary=%1;};@eval setq(T, if(not(strmatch(%0, %b*)), strip(first(%0), /), xget(%1, last-msg-type)));@eval setq(L, switch(trim(%0), /* *=*, first(rest(%0), =), *=*, first(%0, =), edit(xget(%1, last-msg-target), |, %b)));@eval setq(V, trim(switch(%0, *=*, rest(%0, =), /* *, rest(%0), /*,, %0)));@break not(t(%qV))={@trigger me/switch.msg.summary=%1;};@eval strcat(setq(P, iter(%qL, ulocal(f.find-player, itext(0), %1),, |)), setq(P, setunion(%qP, %qP, |)));@eval iter(%qP, if(not(t(itext(0))), setq(E, %qE Could not find player '[if(t(%qL), extract(%qL, inum(0), 1), itext(0))]' ([itext(0)]).)), |); @break not(t(%qP))={@trigger me/tr.error=%1, You need to choose someone to send the message to. }; @break t(squish(trim(%qE)))={@trigger me/tr.error=%1, %qE;};@set %1=last-msg-target:%qP;@if t(%qT)={@set %1=last-msg-type:%qT;};@pemit %1=ulocal(layout.msg, %1, %qP, %qT, %qV);@dolist/delimit | [setdiff(setunion(%qP, %qP, |), %1, |)]={@switch/first 1=hasattr(##, msg-hide-%1), {}, hasattr(##, msg-block-%1), {@pemit %1=alert(MSG BLOCKED) [ulocal(f.get-name, ##)] has blocked you[if(match(setr(B, u(##/msg-block-%1)), 1), ., %bbecause: %qB)];}, and(or(t(xget(##, msg-receive-off)), not(hasflag(##, connect))), gte(words(lattr(##/_msg-*)), 50)), {@pemit %1=alert(MSG NOT DELIVERED) [ulocal(f.get-name, ##)] is not available and [poss(##)] message queue is full. Resend your message later.;}, or(t(xget(##, msg-receive-off)), not(hasflag(##, connect))), {&_msg-[secs()] ##=ulocal(layout.msg, %1, %qP, %qT, %qV);@pemit %1=alert(MSG DELAYED) Added message to [ulocal(f.get-name, ##)]'s message queue.;}, {@pemit ##=ulocal(layout.msg, %1, %qP, %qT, %qV);}}

@set [v(d.bc)]/switch.msg=no_parse

