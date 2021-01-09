@@ =============================================================================
@@ TEST SETUP
@@ =============================================================================

&lipsum1 me=Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus tincidunt justo id accumsan luctus. Praesent et consectetur sem, porttitor scelerisque magna. Aenean in eros feugiat, ultrices felis maximus, condimentum est. Nunc nisi nunc, vestibulum a justo eget, iaculis bibendum nibh. Nulla sit amet metus ut nisi congue ultricies. Donec ac dui nec orci vehicula commodo. Aliquam in volutpat odio, vel tempus ante. Aenean et quam facilisis, hendrerit enim id, elementum ipsum.

&lipsum2 me=Phasellus Venenatis Tempor Diam Vitae Turpis Laoreet Eu Fusce Tristique A Elit Hendrerit Volutpat Phasellus Tristique Elit Dignissim Hendrerit Aliquam Magna Enim Sodales Leo Eu Condimentum Turpis Tortor Quis Arcu Praesent Id Consectetur Ligula Quis Pulvinar Ligula Ut Lobortis Nisi Nisi Vel Egestas Dolor Euismod A Vestibulum Luctus Risus Tellus Et Feugiat Turpis Vehicula Ac Nunc Accumsan

&c.+test me=$+test:@pemit %#=strcat(alert() Testing the following configuration:, %r%tEffect:, %b, xget(v(d.bd), d.effect), %r%tColors:, %b, xget(v(d.bd), d.colors), %r%tText color:, %b, xget(v(d.bd), d.text-color), %r%tText left%, repeat%, and right:, %b, xget(v(d.bd), d.text-left), %b, xget(v(d.bd), d.text-repeat), %b, xget(v(d.bd), d.text-right), %r%tTitle left and right:, %b, xget(v(d.bd), d.title-left), %b, xget(v(d.bd), d.title-right), %r%tBody left and right:, %b, xget(v(d.bd), d.body-left), %b, xget(v(d.bd), d.body-right), %r%r, header(iter(lnum(rand(1, 6)), pickrand(v(lipsum2)))), %r, formattext(v(lipsum1)), %r, divider(iter(lnum(rand(0, 6)), pickrand(v(lipsum2)))), %r, formatcolumns(v(lipsum2)), %r, footer(iter(lnum(rand(0, 6)), pickrand(v(lipsum2)))))

@@ =============================================================================
@@ TEST
@@ =============================================================================

&d.text-color [v(d.bd)]=xw

&d.colors [v(d.bd)]=x<#FF0000> x<#AA0055> x<#5500AA> x<#0000FF>

&d.effect [v(d.bd)]=altrev

&d.text-left [v(d.bd)]=.o
&d.text-right [v(d.bd)]=o.
&d.text-repeat [v(d.bd)]=.
&d.title-left [v(d.bd)]=.oO(
&d.title-right [v(d.bd)]=)Oo.
&d.body-left [v(d.bd)]=.
&d.body-right [v(d.bd)]=.

+test

@@ =============================================================================
@@ TEST
@@ =============================================================================

&d.effect [v(d.bd)]=fade

&d.text-left [v(d.bd)]=/
&d.text-right [v(d.bd)]=/
&d.text-repeat [v(d.bd)]==
&d.title-left [v(d.bd)]==/
&d.title-right [v(d.bd)]=/=
&d.body-left [v(d.bd)]=.
&d.body-right [v(d.bd)]=.

+test

@@ =============================================================================
@@ TEST
@@ =============================================================================

&d.effect [v(d.bd)]=alt

&d.text-left [v(d.bd)]=.o
&d.text-right [v(d.bd)]=o.
&d.text-repeat [v(d.bd)]=.oOo.
&d.title-left [v(d.bd)]=.oO(
&d.title-right [v(d.bd)]=)Oo.
&d.body-left [v(d.bd)]=.
&d.body-right [v(d.bd)]=.

+test

@@ =============================================================================
@@ TEST
@@ =============================================================================

&d.effect [v(d.bd)]=random

&d.text-left [v(d.bd)]=.
&d.text-right [v(d.bd)]=.
&d.text-repeat [v(d.bd)]=~
&d.title-left [v(d.bd)]=~{
&d.title-right [v(d.bd)]=}~
&d.body-left [v(d.bd)]=.
&d.body-right [v(d.bd)]=.

+test

@@ =============================================================================
@@ RESET EVERYTHING BACK TO DEFAULT
@@ =============================================================================

&d.colors [v(d.bd)]=x<#FF0000> x<#AA0055> x<#5500AA> x<#0000FF>

&d.text-color [v(d.bd)]=xw

&d.effect [v(d.bd)]=fade

&d.text-left [v(d.bd)]=.
&d.text-right [v(d.bd)]=.
&d.text-repeat [v(d.bd)]=~
&d.title-left [v(d.bd)]=~{
&d.title-right [v(d.bd)]=}~
&d.body-left [v(d.bd)]=.
&d.body-right [v(d.bd)]=.

+test
