
# Help

## +who

> +who
> +3who - a 3-column +who.
> +2who - a 2-column +who.
> +who/columns &lt;list> - change the columns shown on +who. Leave blank to reset.
> +who/sort &lt;list>
> +who * - search for specific player
> +who/watch &lt;name> - see when a player logs in and out, highlight them on the +who list.
> +who/unwatch &lt;name> - unhilight them and stop watching their connects
> +who/hide - don't notify others when you log in or out.
> +who/unhide - allow others to see when you log in or out.
> +who/permit &lt;name> - permit someone to see you when you connect, even when you're hidden.
> +who/unpermit &lt;name> - remove someone from your permitted list.
> +who/note &lt;player>=&lt;note> - make a note so you can remember who a player is
> +who/notes - see all connected players and any notes you have on them
> +who/page &lt;message> - page all your watched players who are connected a message.

## +watch

+watch is just a slightly specialized function of +who. Most of the commands here are aliases to their equivalent +who commands.

> +watch/list - list all the people you're watching
> +watch - see just the people you have watched
> +watch/add &lt;name> - watch someone's connections/disconnections
> +watch/delete or /remove &lt;name> - stop watching them
> +watch/hide - hide from +watch
> +watch/unhide - become visible to +watch again
> +watch/permit and /unpermit - same as +who/permit and /unpermit.
> +watch/all on or off - see all logins and disconnects.
> +watch/on or /off - turn connect/disconnect notices on or off entirely.
> +watch/page &lt;message> - page all your watched players who are connected a message.

In addition, you can create a custom format using &watchfmt. Here's the standard syntax:

> &watchfmt me=cat(alert(prettytime()), moniker(%0), has, %1.)

And finally, due to backwards compatibility we also included &awatch. It will be triggered whenever someone connects or disconnects.

> &awatch me=think My &awatch: %0 has %1.

## +staff

> +staff - shows all staff
> +staff/all - included for backwards compatibility, does the same as +staff

### Staff-only +staff commands

> +staff/add &lt;name>
> +staff/remove or /delete &lt;name>
> +duty - toggle yourself on or off duty
> +dark - toggle yourself visible or dark. Dark staffers don't show up on the +who.
