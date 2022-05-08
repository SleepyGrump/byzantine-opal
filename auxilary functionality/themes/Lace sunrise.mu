@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Header
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

+layout/h l=%c<#d75faf>.%c<#d76f8c>o%c<#d77f69>.
+layout/h r=%c<#d75faf>.o.
+layout/h inner-l=%c<#d78f46>o%c<#d79f23>O%c<#d7af00>(
+layout/h inner-r=%c<#d75faf>)Oo
+layout/h fill=.o.
+layout/h align=l
+layout/header color=c<#d75faf> c<#d76f8c> c<#d77f69> c<#d78f46> c<#d79f23> c<#d7af00> c<#d7af00> c<#d7af00> c<#d79f23> c<#d78f46> c<#d77f69> c<#d76f8c> c<#d75faf>
+layout/header effect=stretch

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Body
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

+layout/b l=.:
+layout/b r=:.
+layout/b color=c<#d75faf> c<#d76f8c> c<#d77f69> c<#d78f46> c<#d79f23> c<#d7af00> c<#d7af00> c<#d7af00> c<#d79f23> c<#d78f46> c<#d77f69> c<#d76f8c> c<#d75faf>
+layout/b effect=stretch

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Divider
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

+layout/d l=%c<#d75faf>.o.
+layout/d r=%c<#d75faf>.o.
+layout/d inner-l=%c<#d75faf>oO(
+layout/d inner-r=%c<#d75faf>)Oo.
+layout/d fill=.o.
+layout/d align=c
+layout/d color=c<#d75faf> c<#d76f8c> c<#d77f69> c<#d78f46> c<#d79f23> c<#d7af00> c<#d7af00> c<#d7af00> c<#d79f23> c<#d78f46> c<#d77f69> c<#d76f8c> c<#d75faf>
+layout/d effect=Stretch

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Footer
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

+layout/f l=%c<#d75faf>.o.
+layout/f r=%c<#d76f8c>.%c<#d75faf>o.
+layout/f inner-l=%c<#d75faf>.oO(
+layout/f inner-r=%c<#d7af00>)%c<#d79f23>O%c<#d78f46>o%c<#d77f69>.
+layout/f fill=.o.
+layout/f align=r
+layout/f color=c<#d75faf> c<#d76f8c> c<#d77f69> c<#d78f46> c<#d79f23> c<#d7af00> c<#d7af00> c<#d7af00> c<#d79f23> c<#d78f46> c<#d77f69> c<#d76f8c> c<#d75faf>
+layout/f effect=stretch

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Alert message
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

+layout/a l=%c<#d75faf>.%c<#d76f8c>o
+layout/a r=%c<#d75faf>.
+layout/a inner-l=%c<#d77f69>O%c<#d78f46>(
+layout/a inner-r=%c<#d78f46>)%c<#d77f69>O%c<#d76f8c>o
+layout/a text-colors=c<#d7af00>

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Title color
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

+layout/title color=c<#d7af00>

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Below are some extreme examples of what you can do with this code.
@@ They don't really go with the theme, but they're cool to look at.
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

@@ Make the header text a single color, underlined:
@@ +layout/header text-color=c<#d7af00>u

@@ Make the footer text a gradient, also underlined:
@@ +layout/footer text-colors=c<#d75faf>u c<#d76f8c>u c<#d77f69>u c<#d78f46>u c<#d79f23>u c<#d7af00>u c<#d7af00>u c<#d7af00>u c<#d79f23>u c<#d78f46>u c<#d77f69>u c<#d76f8c>u c<#d75faf>u
@@ +layout/footer text-effect=stretch

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ This is the command I used to get the gradients for this theme.
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

+gradient #d75faf/#d7af00=123456

