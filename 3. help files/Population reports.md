
# Help

## +who

> +who
> +3who - a 3-column +who.
> +2who - a 2-column +who.
> +who/columns &lt;list>=&lt;columns> - change the columns shown on +who, +staff, +who/notes, and +watch. +who/c who= to reset.
> +who/sort &lt;list>=&lt;columns> - change how columns are sorted. Default sort is by Idle time, then Status.
> +who * - search for specific player
> +who/watch &lt;name> - see when a player logs in and out, highlight them on the +who list.
> +who/unwatch &lt;name> - unhilight them and stop watching their connects.
> +who/hide - don't notify others when you log in or out.
> +who/unhide - allow others to see when you log in or out.
> +who/permit &lt;name> - permit someone to see you when you connect, even when you're hidden.
> +who/unpermit &lt;name> - remove someone from your permitted list.
> +who/note &lt;player>=&lt;note> - make a note so you can remember who a player is.
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

## +where

> +where - see where the people are.
> +where &lt;name> - find one person.
>
> +travel - list locations to travel to.
> +travel &lt;category> - list locations to travel to in a category.
> +travel &lt;key> - visit a destination.
> +travel/random - visit a random location.
>
> TODO: Need some admin commands...
> +travel/add here=&lt;key> - key will be checked for uniqueness and not clashing with categories.
> +travel/categories &lt;location>=&lt;categories> - set the location's categories. Multiple categories must be separated by a | symbol, ex "Nightclubs|Entertainment|Bars".
>
> +ic - go in character.
> +ooc - go out of character.
> +meetme &lt;name> - invite someone to meet.
> +join &lt;name> - join someone.
> +summon &lt;name> - bring them to you.
> +return - go back where you came from.
> +return &lt;name> - send them back where they came from.

## +staff

> +staff - shows all staff
> +staff/all - included for backwards compatibility, does the same as +staff

### Staff-only +staff commands

> +staff/add &lt;name>
> +staff/remove or /delete &lt;name>
> +duty - toggle yourself on or off duty
> +dark - toggle yourself visible or dark. Dark staffers don't show up on the +who.
