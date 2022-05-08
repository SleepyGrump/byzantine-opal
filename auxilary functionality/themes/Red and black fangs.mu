@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Header
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

+layout/h l=%c<#444444>,
+layout/h r=%c<#444444>,
+layout/h inner-l=%c<#444444>^V^{
+layout/h inner-r=%c<#444444>}^V^
+layout/h fill=^V^
+layout/h align=l
+layout/h color=c<#555555> c<#553333> c<#550000> c<#690000> c<#8e0000> c<#b40000> c<#d90000> c<#d90000> c<#b40000> c<#8e0000> c<#690000> c<#550000> c<#553333> c<#555555>
+layout/header effect=stretch
+layout/header text-color=c<#aaaaaa>

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Body
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

+layout/b l={
+layout/b r=}
+layout/b color=c<#555555> c<#553333> c<#550000> c<#690000> c<#8e0000> c<#b40000> c<#d90000> c<#d90000> c<#b40000> c<#8e0000> c<#690000> c<#550000> c<#553333> c<#555555>
+layout/b effect=stretch

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Divider
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

+layout/d l=%c<#444444>{
+layout/d r=%c<#444444>}
+layout/d inner-l=%c<#444444>^V^{
+layout/d inner-r=%c<#444444>}^V^
+layout/d fill=^V^
+layout/d align=c
+layout/d text-color=
+layout/d color=c<#555555> c<#553333> c<#550000> c<#690000> c<#8e0000> c<#b40000> c<#d90000> c<#d90000> c<#b40000> c<#8e0000> c<#690000> c<#550000> c<#553333> c<#555555>
+layout/d effect=stretch
+layout/d text-color=c<#aaaaaa>

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Footer
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

+layout/f l=%c<#444444>'
+layout/f r=%c<#444444>'
+layout/f inner-l=%c<#444444>^V^{
+layout/f inner-r=%c<#444444>}^V^
+layout/f fill=^V^
+layout/f align=r
+layout/f text-color=
+layout/f color=c<#555555> c<#553333> c<#550000> c<#690000> c<#8e0000> c<#b40000> c<#d90000> c<#d90000> c<#b40000> c<#8e0000> c<#690000> c<#550000> c<#553333> c<#555555>
+layout/f effect=stretch
+layout/f text-color=c<#aaaaaa>

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Alert message
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

+layout/a l=%c<#444444>.
+layout/a r=%c<#444444>.
+layout/a inner-l=%c<#553333>^%c<#550000>V%c<#690000>^%c<#8e0000>{
+layout/a inner-r=%c<#8e0000>}%c<#690000>^%c<#550000>V%c<#553333>^
+layout/a text-colors=c<#aaaaaa>

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Title color
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

+layout/title color=c<#aaaaaa>

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Gradient commands to get the colors used in this display:
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

+gradient #550000/#ff0000=123456
+gradient #000000/#ffffff=1234567890

@@ The gradient code isn't great at going from gray to color, so that part I did manually, adding #555555 and #553333 before the initial gradient. If I'd tried +gradient #555555/#ff0000=12345678, the gradient would've been weird.
