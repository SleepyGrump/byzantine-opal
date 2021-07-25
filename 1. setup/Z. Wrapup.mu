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

player_flags ansi color256 keepalive

flag_name marker0 approved
flag_access marker0 wizard

public_channel Public
guests_channel Public

idle_timeout 86400

# These numbers should match the dbrefs of the various objects you built in Step 0!

room_parent 19
exit_parent 33
player_parent 17
guest_parent 18
hook_obj 32

# For the channel forwarding and pose notices:

hook_cmd pose before permit
hook_cmd npose before permit
hook_cmd : before permit
hook_cmd ; before permit
hook_cmd say before permit
hook_cmd nsay before permit
hook_cmd " before permit
hook_cmd @emit before permit
hook_cmd \ before permit
hook_cmd @remit before permit
# This is only necessary if you plan to restrict moniker to staffers-only.
hook_cmd @moniker permit

# If you plan on installing the SQL commands, you will need:

module sqlproxy
module sqlslave local
sql_database <your database>
sql_server localhost
sql_user <your database login name>
sql_password <your database password>

*/

