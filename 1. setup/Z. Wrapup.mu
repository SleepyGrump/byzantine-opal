@@ Set up parents for the 3 built-in default OOC rooms.

@force me=@parent #0=[v(d.orp)]

@force me=@parent #2=[v(d.orp)]

@force me=@parent #11=[v(d.orp)]

@@ Take all the SGP functions out of the master code room.

@tel #4=#11
@tel #5=#11
@tel #6=#11
@tel #7=#11
@tel #8=#11
@tel #9=#11

@@ Get those functions we installed earlier working.

@restart

@@ =============================================================================

/*
IMPORTANT:

If you have not already done so, in your netmux.conf, add the following lines:

player_flags ansi color256 ascii keepalive

# You may also want:

flag_name marker0 approved
flag_access marker0 wizard

public_channel Public
guests_channel Public

idle_timeout 86400

# If you plan on installing the SQL commands, you will need:

module sqlproxy
module sqlslave local
sql_database <your database>
sql_server localhost
sql_user <your database login name>
sql_password <your database password>

*/

