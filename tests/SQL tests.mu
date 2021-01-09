@@ These tests assume a default MediaWiki 1.35 installed with no prefix. Modify to your liking.

th fetch()
th fetch(actor)
th fetch(actor, actor_id actor_name)
th fetch(actor, actor_id actor_name, actor_id=1)
th fetch(,,, %r, @)
th fetch(actor,,, %r, %,%b)
th fetch(actor, actor_id actor_name,, %r, %.%b)
th fetch(actor, actor_id actor_name, actor_id=1, %r, %.%b)
th fetch(actor, actor_id actor_name, actor_name LIKE 'B*')

@@ Have a non-staffer do this - they should get #-1 PERMISSION DENIED. If not, you're missing isstaff().

th fetch()

@@ Should return no rows, only the header row, because of sanitation:

th fetch(actor, actor_id actor_name, actor_name LIKE 'B%')

@@ Should error, can't get two tables:

th fetch(actor archive)

@@ Now to test the randomness function.

th fetch(actor,, rand)
th fetch(actor, actor_id actor_name, rand)

