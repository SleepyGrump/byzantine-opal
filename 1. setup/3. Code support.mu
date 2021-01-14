@aconnect [v(d.bc)]=@dolist lattr(me/tr.aconnect-*)={ @trigger me/##=%#; };

@adisconnect [v(d.bc)]=@dolist lattr(me/tr.adisconnect-*)={ @trigger me/##=%#; };

@startup [v(d.bf)]=@trigger me/tr.make-functions;

&tr.make-functions [v(d.bf)]=@dolist lattr(me/f.global.*)=@function rest(rest(##, .), .)=me/##; @dolist lattr(me/f.globalp.*)=@function/preserve rest(rest(##, .), .)=me/##; @dolist lattr(me/f.globalpp.*)=@function/preserve/privilege rest(rest(##, .), .)=me/##;
