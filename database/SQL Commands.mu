/*

= Why use SQL on MUX? =
 - Because there are visual editors available for it - PHPmySQL, SQL Manager, etc.
 - You gain the ability to import/manage/visualize/etc the data outside the game. For example, the External Data plugin for MediaWiki could reach out and touch the data from your game and display it on your wiki. (Be careful of security with that.)
 - You separate the data from the game, somewhat. If the game is corrupted, you don't lose EVERYTHING - you still have character sheets and game tables.
 - You remove the storage limits of MUX/MUSH/etc. (Yeah, the 8k single-text display limit is still there, but the data isn't lost, just hidden.)

= Why NOT use SQL on MUX? =
 - Because it's more work - set up and secure the server, keep it up to date so you don't get hacked, make sure it's properly backed up, maybe write your own visualization code or implement a wiki plugin, etc.
 - Because it does require more power from the server. A stock TinyMUX server will run happily on a 586. The more programs you add, the more the machine will choke, and older servers really shouldn't bother.
 - Because it gives you two points of failure instead of one. Normally if your game is running you're happy. If you base your game on MySQL as well as TinyMUX, and TinyMUX loses connection to the MySQL service, well... game's down, even if players are able to talk and play without it, since they can't get some of the info they need.
 - You're hosting super-secure stuff. The fewer places you store that info, the less danger there is of it getting out.
 - There is a TinyMUX performance bottleneck with inline SQL. If you run a long-running query - for example, you use SQL to create a report consolidating several very large tables without proper identifying keys into a 15000-record mass - it will lag the whole game. You shouldn't be using TinyMUX if that's what you want to do.
 - This is just the data functions and commands. It's a library for coders to call upon, not a complete solution. Other stuff I write will eventually depend on it.


Requirements:
	TinyMUX with SQL and stubslave enabled. Not tested on other types of games, may need polyfill functions.
	header()
	footer()
	alert()
	isstaff()

@@ MAYBE: You will also need to secure your installation somewhat.

Code functions:
	fetch(table, columns, where query, row delimeter, column delimeter)
		table: optional; if skipped returns a list of mirrored tables
		columns: optional; if skipped returns the entire contents of the table, if given, sorts by the given column order
		where query: optional; if skipped returns the results unfiltered
		row delimeter: defaults to |
		column delimeter: defaults to ~

		* A word about where queries: Please sanitize your inputs. We can't sanitize here without reducing the usefulness of the command. There is a reason it is restricted to staff and staff-owned objects only. If you leave a gaping hole through which someone can drive a "Robert'); DROP TABLE students;--"-sized truck through, that's on your head. Never put user input directly into the WHERE clause. Strip it, snip it, make sure it's exactly as long as you expect and has no special characters, especially these: % * _ ' ` " \

		* If the WHERE query contains LIKE and *'s, we will interpret all *'s as % because % is a MUX reserved character and would have to be mightily escaped otherwise.

		* If the WHERE query is exactly "RAND" (case insensitive), you will receive one random row from the given table.

		* You will need to put quotes around your own where query strings. This allows you to do things like "ID = 1 AND Name LIKE 'B*'" - the syntax is a bit too complex for us to write an entire engine here.

		* Limitations: This doesn't support spaces in column or table names. Use an underscore or dash or just concatenate. Or just use sql() directly.

	post(table, columns, values, where query, column delimeter, value delimeter)
		table, columns, values, and where query are REQUIRED.
		column delimeter: defaults to ~
		value delimeter: defaults to ~

		* Will only update or insert one row. If the where query returns more than one row, will error.

		* The code handles formatting the items in your values into strings or numbers surrounded by quotes.

		* This query performs an INSERT the where query is given as "INSERT" (case-insensitive).

	columninfo(table, column, result delimeter)
		The first two arguments are required.
		Result delimiter defaults to ~.
		Returns data in this order:
			- Is the column nullable?
			- Is it PRI, UNI, or MUL?
			- Is the column manually editable?
			- Column's datatype
			- Maximum number of characters in this field (only relevent for strings)
			- Column comment (settable by the DB admin)

Ideally you would use these functions to write custom code that players can use to view the tables you want to make available to them, like "+equipment" or "+cars" or whatever you're storing. However, we've written a sample below of how such code will work, along with some basic management code that will help you see how these functions are intended to be used.

Commands:
	+db - list all the tables you have permission to see.
	+db <table> - show the raw tabular data, selects that table as your "working" table
	+db/find <column>=<value> - find the rows in the table where the <column> matches <value>.
	+db/rand <table> - get a random value from a table.

Staff Commands:
	+db/allow <table> - add <table> to the list of tables players can look at. By default they are not allowed to view any tables.

	+db/lock <table> - remove <table> from the list of tables players can look at.

	+db/hide <table> - hide <table> from the list of tables staff and players have access to. It's still there, but they won't see it and can only find it if they know its name. (This is easier than it sounds! Don't use this thinking no one will guess it.)

	+db/show <table> - as above, in reverse.

	+db/update [<table>/]<column>=<value> - you're assumed to have a table selected already if you don't include the <table> argument. The first update call is the "where" query - for example "+db/update actor/actor_id=3" - you are now working on the one record where the actor_id is 3. Some fields will not be editable and you will receive an error if that is the case.
	+db/set <column>=<value> - repeat until the columns look the way you want them to
	+db/clear <column> - clear the value you were going to set in that column
	+db/commit - commit your data to the database.

	+db/add [<table>] - you're assumed to have a table selected already if you don't include the <table> argument. Begins the process of inserting a record into a table.
	+db/set <column>=<value> - repeat as necessary to set each field.
	+db/clear <column> - clear the value you were going to set in that column
	+db/commit - commit your data to the database.
*/


@create SQL Data <SD>=10
@set SD=SAFE
@force me=&d.sd me=[num(SD)]

@create SQL Functions <SF>=10
@set SF=SAFE INHERIT
@parent SF=SD

@@ @lock/use [v(d.sf)]=isstaff/1
@@ &isstaff [v(d.sf)]=isstaff(%0)

@create SQL Commands <SC>=10
@set SC=SAFE INHERIT
@parent SC=SF
@force me=&d.sc me=[num(SC)]

@@ @lock/use [v(d.sc)]=isstaff/1
@@ &isstaff [v(d.sc)]=isstaff(%0)

@force me=&d.sf me=[num(SF)]
@force me=&vd [v(d.sf)]=[v(d.sd)]
@tel [v(d.sd)]=[v(d.sf)]
@tel [v(d.sf)]=[v(d.sc)]

&d.default-row-delimeter [v(d.sd)]=|

&d.default-column-delimeter [v(d.sd)]=~

&sql.get-tables [v(d.sd)]=SHOW TABLES;

&sql.get-table-columns [v(d.sd)]=DESCRIBE %0;

&sql.get-table-contents [v(d.sd)]=SELECT * FROM %0;

&sql.get-table-random [v(d.sd)]=SELECT * FROM %0 ORDER BY RAND() LIMIT 0, 1;

&sql.get-table-by-columns [v(d.sd)]=SELECT [setr(0, edit(%1, %b, %,))] FROM %0 ORDER BY %q0;

&sql.get-random-by-columns [v(d.sd)]=SELECT [setr(0, edit(%1, %b, %,))] FROM %0 ORDER BY RAND() LIMIT 0, 1;

&sql.get-whole-row-by-where [v(d.sd)]=SELECT * FROM %0 WHERE [ulocal(f.sanitize-where, %1)]

&sql.get-columns-and-row-by-where [v(d.sd)]=SELECT [setr(0, edit(%1, %b, %,))] FROM %0 WHERE [ulocal(f.sanitize-where, %2)] ORDER BY %q0

&sql.get-single-column-info [v(d.sd)]=SELECT is_nullable, column_key, extra, data_type, character_maximum_length, column_comment FROM information_schema.columns WHERE table_name = '%0' AND column_name = '%1'

@@ is_nullable
@@ character_maximum_length
@@ numeric_precision
@@ numeric_scale
@@ column_key
@@ extra - auto_increment means do not update

@@ column_comment
@@ column_type - bigint(20) unsigned


@startup [v(d.sf)]=@trigger me/tr.make-functions;

&tr.make-functions [v(d.sf)]=@dolist lattr(me/f.global.*)=@function rest(rest(##, .), .)=me/##; @dolist lattr(me/f.globalp.*)=@function/preserve rest(rest(##, .), .)=me/##; @dolist lattr(me/f.globalpp.*)=@function/preserve/privilege rest(rest(##, .), .)=me/##;

&d.sanitize-where [v(d.sd)]=%\

&f.sanitize-where [v(d.sf)]=strcat(setq(0, strip(%0, v(d.sanitize-where))), if(strmatch(%q0, * LIKE *), edit(%q0, *, %%%%%%), %q0))


@@ %0: table
@@ %1: row delimiter
@@ %2: column delimeter

@@ Output: column1~column2~column3
&f.get-table-columns [v(d.sf)]=iter(sql(ulocal(sql.get-table-columns, %0), %1, %2), first(itext(0), %2), %1, %2)

&f.get-table-contents [v(d.sf)]=sql(ulocal(sql.get-table-contents, %0), %1, %2)

&f.get-entire-table [v(d.sf)]=strcat(ulocal(f.get-table-columns, %0, %1, %2), %1, ulocal(f.get-table-contents, %0, %1, %2))

&f.get-random-row [v(d.sf)]=strcat(ulocal(f.get-table-columns, %0, %1, %2), %1, sql(ulocal(sql.get-table-random, %0), %1, %2))

@@ %0: table
@@ %1: where query
@@ %2: row delimiter
@@ %3: column delimeter
&f.get-whole-row-by-where [v(d.sf)]=strcat(ulocal(f.get-table-columns, %0, %2, %3), %2, sql(ulocal(sql.get-whole-row-by-where, %0, %1), %2, %3))

@@ %0: table
@@ %1: columns
@@ %2: row delimiter
@@ %3: column delimeter
&f.get-table-by-columns [v(d.sf)]=strcat(edit(%1, %b, %3), %2, sql(ulocal(sql.get-table-by-columns, %0, %1), %2, %3))

&f.get-random-row-by-columns [v(d.sf)]=strcat(edit(%1, %b, %3), %2, sql(ulocal(sql.get-random-by-columns, %0, %1), %2, %3))

@@ %0: table
@@ %1: columns
@@ %2: where query
@@ %3: row delimiter
@@ %4: column delimeter
&f.get-columns-and-row-by-where [v(d.sf)]=strcat(edit(%1, %b, %4), %3, sql(ulocal(sql.get-columns-and-row-by-where, %0, %1, %2), %3, %4))

@@ %0: table: optional; if skipped returns a list of tables
@@ %1: columns: optional; if skipped returns the entire contents of the table, if given, sorts by the given column order
@@ %2: where query: optional; if skipped returns the results unfiltered
@@ %3: row delimeter: defaults to |
@@ %4: column delimeter: defaults to ~
@@ Output:
@@ If no table: list of tables.
@@ If no columns and no where: Everything in table.
@@ If no columns yes where: All rows of table matching where.
@@ If yes columns yes where: Columns and rows matching where.
@@ If where = RAND, get a random row.

&f.globalpp.fetch [v(d.sf)]=strcat(setq(R, if(t(strlen(%3)), %3, v(d.default-row-delimeter))), setq(C, if(t(strlen(%4)), %4, v(d.default-column-delimeter))), case(0, cor(isstaff(%#), cand(not(member(num(me), %@)), hastype(%@, THING), andflags(%@, I!h!n), isstaff(owner(%@)))), #-1 PERMISSION DENIED, lte(words(%0), 1), #-1 TOO MANY TABLES (%0), t(%0), sql(ulocal(sql.get-tables), %qR, %qC), case(strcat(t(%1), t(%2)), 00, ulocal(f.get-entire-table, %0, %qR, %qC), 01, switch(%2, RAND, ulocal(f.get-random-row, %0, %qR, %qC), ulocal(f.get-whole-row-by-where, %0, %2, %qR, %qC)), 11, switch(%2, RAND, ulocal(f.get-random-row-by-columns, %0, %1, %qR, %qC), ulocal(f.get-columns-and-row-by-where, %0, %1, %2, %qR, %qC)), 10, ulocal(f.get-table-by-columns, %0, %1, %qR, %qC))))

@@ %0: table list
@@ %1: viewer
&f.filter-unlocked-tables [v(d.sf)]=if(isstaff(%1), %0, setinter(%0, v(d.unlocked_tables), v(d.default-row-delimeter)))

@@ %0: table list
&f.filter-hidden-tables [v(d.sf)]=setdiff(%0, v(d.hidden_tables), v(d.default-row-delimeter))

@@ %0: table list
@@ %1: user viewing this
&layout.show_tables [v(d.sf)]=strcat(header(All available tables, %1), %r, formatcolumns(%0, v(d.default-row-delimeter), %1), %r, footer(+db <table name> for more, %1))

&c.+db [v(d.sc)]=$+db:@pemit %#=ulocal(layout.show_tables, ulocal(f.filter-hidden-tables, ulocal(f.filter-unlocked-tables, fetch(), %#)), %#);

@@ Wrapping up:

@restart
