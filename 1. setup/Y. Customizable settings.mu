@@ This definitely needs changed:

@@ Unbannable IPs - for browser-based clients, common sites, etc. Enter your unbannable IP addresses here, separated by spaces.
@@ Note: staff IPs are always unbannable.
@@ 54.200.22.252 - Cheese WebMU at http://www.cheesesoftware.com/MUCon/
@@ 0.0.0.0 - the "all" IP - if blocked, blocks all connections.
@@ You should add your #1's IP address (e #1/lastip)
@@ You should add your game's IP address
&d.unbannable-IP-addresses [v(d.bd)]=54.200.22.252 0.0.0.0

@@ An email address to be shown to players who are banned where they can appeal the banning. It's important to give them some way to reach you, in case someone bans the wrong person.
&d.staff-email-address [v(d.bd)]=test@example.com

@@ Make sure to also edit your badsite_connect file to include the above email address.

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ +help and news settings
@@ +help and news require additional customization to work with your wiki.
@@ See the files Wiki +help.mu and Wiki news.mu for additional changes.
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

@@ Your wiki prefix, if any:
&vP [v(d.bd)]=wiki_

@@ This is for if you're using wiki help and news.
&d.wiki-url [v(d.bd)]=<your wiki url here>

@@ The Help namespace text. We're going with MediaWiki's built in Help namespace by default. If you put it in a custom namespace, change it to your custom namespace name. This might involve a _ instead of a space if you have a space in your namespace, AKA Game Help. Try it both ways and make sure it works.
&d.help.namespace [v(d.bd)]=Help

@@ The Help namespace ID. This is 12 by default and is set by MediaWiki. Change it to the new ID if you're putting Help in a new namespace.
&d.help.namespace.id [v(d.bd)]=12

@@ News Settings ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

@@ The News namespace text.
&d.news.namespace [v(d.bd)]=News

@@ The News namespace ID.
&d.news.namespace.id [v(d.bd)]=3000

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Other settings
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

@@ I like Posebreak on by default. Change this to 0 if you don't.
&_posebreak [v(d.pp)]=1

@@ Do you want pose alerts? (Warns players when they're up next, alerts when it's their turn.) This only applies if you add the Pose Order Machine.
@@  2, loud: beep the client when messaging them about their pose order.
@@  1, quiet: simple message when it's their turn/about to be their turn (no "beep")
@@  0, off: no pose alerts unless the player enables them
&_pose.alert [v(d.pp)]=1

@@ Default alert message
&d.default-alert [v(d.bd)]=GAME

@@ How much of an indent to use. The default 8 spaces is a bit long for some.
&d.indent-width [v(d.bd)]=5

@@ How long to wait before allowing a player to claim someone's name:
&d.max-days-before-name-available [v(d.bd)]=45

@@ For coders.
&d.debug-target [v(d.bd)]=#1

@@ Where reports go - messages from the code that are important.
@@ Most games have a private staff-only channel called Monitor.
&d.report-target [v(d.bd)]=Monitor

@@ A few notes about color:
@@ 1. Not everyone likes it.
@@ 2. They can turn it off.
@@ 3. Use it to give the feel of your game.
@@ 4. Never use it for important text, it can obscure the meaning.
@@ 5. A little goes a long way.
@@ 6. Definitely change the defaults.

@@ Effect controls the color of the header, footer, and divider functions.
@@ -
@@ Available effects are:
@@   none - no colors
@@   alt - as in alternating - colors go A > B > C > A > B > C...
@@   altrev - as in alternating reverse - colors go A > B > C > B > A
@@   random - colors vary randomly, chosen from your list
@@   fade - colors go on the left and right of all functions.
@@ -
&d.effect [v(d.bd)]=fade

@@ These are the colors. Players won't see them unless they are set ANSI and
@@ COLOR256. You can set that up in your netmux.conf config with:
@@ -
@@   player_flags ansi color256 ascii keepalive
@@ -
@@ That means every player will be created with those flags already set.
@@ Remember that players can change these flags at any time if they want!
@@ Also, setting the flags doesn't magically make the player's client able to
@@ view colors or parse ascii characters. If they can they'll see it; if not,
@@ it won't change a thing.
@@ -
&d.colors [v(d.bd)]=x<#FF0000> x<#AA0055> x<#5500AA> x<#0000FF>

@@ What color is your text? 99% of people should just go with white for
@@ readability.
&d.text-color [v(d.bd)]=xw

@@ Now on to the structure of your header/footer/divider!
@@ -
@@ Effect:
@@ .o.oO( GAME )Oo.o. Alert message
@@ .o.oO( test )Oo...........................................................o.
@@ . text goes here and there is surely going to be a lot of text whee txting .
@@ .o..............................oO( test )Oo..............................o.
@@ . text goes here and there is surely going to be a lot of text whee txting .
@@ .o...........................................................oO( test )Oo.o.
@@ -
&d.text-left [v(d.bd)]=.o
&d.text-right [v(d.bd)]=o.
&d.text-repeat [v(d.bd)]=.
&d.title-left [v(d.bd)]=.oO(
&d.title-right [v(d.bd)]=)Oo.
&d.body-left [v(d.bd)]=.
&d.body-right [v(d.bd)]=.

@@ Effect:
@@ /=/ GAME /=/ Alert message
@@  /=/ test /=================================================================/
@@  / text goes here and there is surely going to be a lot of text whee txting /
@@  /=================================/ test /=================================/
@@  / text goes here and there is surely going to be a lot of text whee txting /
@@  /=================================================================/ test /=/
@@ -
&d.text-left [v(d.bd)]=/
&d.text-right [v(d.bd)]=/
&d.text-repeat [v(d.bd)]==
&d.title-left [v(d.bd)]==/
&d.title-right [v(d.bd)]=/=
&d.body-left [v(d.bd)]=/
&d.body-right [v(d.bd)]=/

@@ You can produce more complex results by using more characters for the repeat
@@ section, but they will be cut off after a certain point. Notice how the
@@ Footer below has a character missing from its cut-off side. If you or your
@@ players are perfectionists, stay away from the multiple-character repeats.
@@ -
@@ Effect:
@@ .o.oO( GAME )Oo.o. Alert message
@@  .o.oO( test )Oo..oOo..oOo..oOo..oOo..oOo..oOo..oOo..oOo..oOo..oOo..oOo..oOo.
@@  . text goes here and there is surely going to be a lot of text whee txting .
@@  .o.oOo..oOo..oOo..oOo..oOo..oOo..oO( test )Oo..oOo..oOo..oOo..oOo..oOo..oOo.
@@  . text goes here and there is surely going to be a lot of text whee txting .
@@  .o.oOo..oOo..oOo..oOo..oOo..oOo..oOo..oOo..oOo..oOo..oOo..oO.oO( test )Oo.o.
@@ -
&d.text-left [v(d.bd)]=.o
&d.text-right [v(d.bd)]=o.
&d.text-repeat [v(d.bd)]=.oOo.
&d.title-left [v(d.bd)]=.oO(
&d.title-right [v(d.bd)]=)Oo.
&d.body-left [v(d.bd)]=.
&d.body-right [v(d.bd)]=.

@@ Finally, our default, chosen because it shows off the colors well.
@@ -
@@ Effect:
@@ .~{ GAME }~. Alert message
@@  .~{ test }~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.
@@  . text goes here and there is surely going to be a lot of text whee txting .
@@  .~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~{ test }~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~.
@@  . text goes here and there is surely going to be a lot of text whee txting .
@@  .~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~{ test }~.
@@ -
&d.text-left [v(d.bd)]=.
&d.text-right [v(d.bd)]=.
&d.text-repeat [v(d.bd)]=~
&d.title-left [v(d.bd)]=~{
&d.title-right [v(d.bd)]=}~
&d.body-left [v(d.bd)]=.
&d.body-right [v(d.bd)]=.

@@ Other sample ascii art ideas:
@@ ^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^V^
@@ ^V^ text goes here and there is surely going to be a lot of text whee tex ^V^
@@ <--------------------------------------------------------------------------->
@@ | o | text goes here and there is surely going to be a lot of text whee | o |
@@ .o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.o.
@@ () text goes here and there is surely going to be a lot of text whee texti ()
@@ <+><+><+><+><+><+><+><+><+><+><+><+><+><+><+><+><+><+><+><+><+><+><+><+><+<+>
@@ <+> text goes here and there is surely going to be a lot of text whee tex <+>
@@ <+>-+-<+>-+-<+>-+-<+>-+-<+>-+-<+>-+-<+>-+-<+>-+-<+>-+-<+>-+-<+>-+-<+>-+-<-<+>
@@ ][ text goes here and there is surely going to be a lot of text whee texti ][
@@ .:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.:.
@@ : text goes here and there is surely going to be a lot of text whee texting :
@@ /=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/=/
@@ /=/ text goes here and there is surely going to be a lot of text whee tex /=/

@@ The emit prefix that comes out when people use "ooc <text>" to talk.
&d.ooc_text [v(d.bd)]=<OOC>

@@ Default poll (shows when you type DOING or +who). Max length is 45 characters. This is a MUX limit.
&d.default-poll [v(d.bd)]=Whatcha doing?

@@ Travel categories, separated by |. These will be specific to your game and could include categories like "Retail" or "Market" depending on your setting. Your players will group their businesses under these categories. The only default is "OOC Rooms", so that you can add OOC destinations like the OOC room, the RP Nexus, Chargen, etc.
&d.travel.categories [v(d.bd)]=OOC Rooms

@@ The DBref of your OOC room
&d.ooc [v(d.bd)]=#0

@@ All communication in room # will go to this channel. You can add as many of these as you like. Users will be alerted that they need to join the channel to see the rest of the conversation if they're not already on the channel. To disable, just remove this attribute. This functionality can be used to direct convo from, say, the Chargen room to the Chargen channel, the OOC room to the Public channel, etc.
@force me=&d.redirect-poses.[v(d.ooc)] [v(d.bd)]=Public

@@ Include this only if you want things like dice rolls to also be directed to the channel. If you don't include it, only the player who rolled the dice will see the roll. No one else in the OOC room will. Some commands override this, such as the ooc <text> command, and post directly to the channel anyway.
@force me=&d.redirect-remits.[v(d.ooc)] [v(d.bd)]=Public

@@ Set this to the DBref of your quiet room and any other room you want silent.
@force me=&d.gag-emits [v(d.bd)]=[v(d.qr)]

@@ Default meeting timeout in seconds. Sometimes the default 10m is too short!
&d.meeting-timeout [v(d.bd)]=600

&d.default-out-exit [v(d.bd)]=Out <O>;o;out;exit;

@@ If yours is the kind of place where you're fine with players who haven't been approved going through character generation, flip this flag to a 1 and they'll be able to wander around on the IC grid. Most places want at least a little staff involvement with that before letting them wander where they might interfere with roleplay, but some places don't have a definition of IC, or might be fine with allowing players on the grid but not allowing them to pose, etc. Note that this setting affects +travel, +summon, +join, +meet, etc - if disabled, unapproved characters will not be able to use code to get IC. (Staff can still summon them IC, of course.)
&d.allow-unapproved-players-IC [v(d.bd)]=0

