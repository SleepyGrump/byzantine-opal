@@ This must be done if you want the whole thing to work!

@restart

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

