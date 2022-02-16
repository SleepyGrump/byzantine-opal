/*
Requirements:
	TinyMUX with SQL and stubslave enabled. Not tested on other types of games, may need polyfill functions if used on another type of server.
	header()
	footer()
	alert()
	isstaff()
	formatdb()
	formatcolumns()
	multicol()
	debug()
	report()


= Why use SQL on MUX? =
 - Because there are visual editors available for it - PHPmySQL, SQL Manager, etc.
 - You gain the ability to import/manage/visualize/etc the data outside the game. For example, the External Data plugin for MediaWiki could reach out and touch the data from your game and display it on your wiki. (Be careful of security with that.)
 - You gain the ability to visualize and manage data from your existing database - be it wiki or something else - inside the game.
 - You separate the data from the game, somewhat. If the game is corrupted, you don't lose EVERYTHING - you still have character sheets and game tables.
 - You remove the storage limits of MUX/MUSH/etc. (Yeah, the 8k single-text display limit is still there, but the data isn't lost, just hidden.)

= Why NOT use SQL on MUX? =
 - Because it's more work - set up and secure the server, keep it up to date so you don't get hacked, make sure it's properly backed up, maybe write your own visualization code or implement a wiki plugin, etc.
 - Because it does require more power from the server. A stock TinyMUX server will run happily on a 586. The more programs you add, the more the machine will choke, and older servers really shouldn't bother.
 - Because it gives you two points of failure instead of one. Normally if your game is running you're happy. If you base your game on MySQL as well as TinyMUX, and TinyMUX loses connection to the MySQL service, well... game's down, even if players are able to talk and play without it, since they can't get some of the info they need.
 - You're hosting super-secure stuff. The fewer places you store that info, the less danger there is of it getting out.
 - There is a TinyMUX performance bottleneck with inline SQL. If you run a long-running query - for example, you use SQL to create a report consolidating several very large tables without proper identifying keys into a 15000-record mass - it will lag the whole game. You shouldn't be using TinyMUX if that's what you want to do.


Re: completeness: This is just the data functions and commands. It's a library for coders to call upon, not a complete solution. Other stuff I write will eventually depend on it.


@@ =============================================================================
@@ Help file info
@@ =============================================================================

Code functions:
	moved to parent repo: sanitize(input) - fire this on everything you plan to put into an SQL query that comes directly from a user. That means where clauses, post values, column names, EVERYTHING. This is not built into fetch() by default because that would make queries like fetch(user,, user_name LIKE 'B_b*') impossible. Instead we restricted access to fetch() to staff-only and staff-owned wiz-inherit code objects. Be aware that this will not keep out a truly determined hacker and you should have daily backups (and possibly just remove all single and double quotes from your inputs before you commit them). Sanitize your inputs.

	fetch(table, columns, where query, row delimeter, column delimeter, offset)
		table: optional; if skipped returns a list of mirrored tables
		columns: optional; if skipped returns the entire contents of the table, if given, sorts by the given column order
		where query: optional; if skipped returns the results unfiltered
		row delimeter: defaults to |
		column delimeter: defaults to ~
		offset: defaults to 0

		* If the WHERE query contains LIKE and *'s, we will interpret all *'s as % because % is a MUX reserved character and would have to be mightily escaped otherwise.

		* If the WHERE query is exactly "RAND" (case insensitive), you will receive one random row from the given table.

		* You will need to put quotes around your own where query strings. This allows you to do things like "Email LIKE '*@gmail.com' AND Name LIKE 'B*'" - the syntax is a bit too complex for us to write an entire engine here.

		* Limitations: This doesn't support spaces in column or table names. Use an underscore or dash or just concatenate. Or just use sql() directly.

		* fetch() can only be used by a staffer or a staff-owned, inherit, non-halted, non-no_commands object. Players can't call it directly.

		* fetch() returns records only 25 at a time. For the next 25, you need to include an offset of 25, then 50, etc.

	post(table, columns, values, where query, column delimeter, value delimeter)
		table, columns, values, and where query are REQUIRED.
		column delimeter: defaults to ~
		value delimeter: defaults to column delimeter

		* Will only update or insert one row. If the where query returns more than one row, will error.

		* The code handles formatting the items in your values into strings or numbers surrounded by quotes.

		* This query performs an INSERT the where query is given as "INSERT" (case-insensitive).

Ideally you would use these functions to write custom code that players can use to view the tables you want to make available to them, like "+equipment" or "+cars" or whatever you're storing. However, we've written a sample below of how such code will work, along with some basic management code that will help you see how these functions are intended to be used.

Commands:
	+db - list all the tables you have permission to see.
	+db <table> - show the raw tabular data, selects that table as your "working" table
	+db/find <column>=<value> - find the rows in the table where the <column> matches <value>.
	+db/rand <table> - get a random value from a table.
	+db/next - go to the next page of the table
	+db/prev - go to the previous page of the table
		+db <table> resets your paging position.

Staff Commands:
	+db/unlock <table> - add <table> to the list of tables players can look at. By default they are not allowed to view any tables.

	+db/lock <table> - remove <table> from the list of tables players can look at.

	+db/hide <table> - hide <table> from the list of tables staff and players have access to. It's still there, but they won't see it and can only find it if they know its name. (This is easier than it sounds! Don't use this thinking no one will guess it.)

	+db/show <table> - as above, in reverse.

	+db/columns <table>=<list of columns> - leave blank to return to the default view.

	+db/colwidth <table>=<list of widths - use * for "widest possible"> - set the widths of columns in a table. Must match the number of columns in the table. For example:
		+db/col user=user_id user_name user_email user_editcount
		+db/cw user=7 * * 14

TODO: all items below.

	+db/update [<table>/]<column>=<value> - you're assumed to have a table selected already if you don't include the <table> argument. The first update call is the "where" query - for example "+db/update actor/actor_id=3" - you are now working on the one record where the actor_id is 3. Some fields will not be editable and you will receive an error if that is the case.
		+db/set <column>=<value> - repeat until the columns look the way you want them to
		+db/clear <column> - clear the value you were going to set in that column
		+db/commit - commit your data to the database.

	+db/add [<table>] - you're assumed to have a table selected already if you don't include the <table> argument. Begins the process of inserting a record into a table.
		+db/set <column>=<value> - repeat as necessary to set each field.
		+db/clear <column> - clear the value you were going to set in that column
		+db/commit - commit your data to the database.

	Make it clear at a glance which tables are unlocked if the player is a staffer.
*/


@create SQL Data <SD>=10
@set SD=SAFE
@force me=&d.sd me=[num(SD)]

@create SQL Functions <SF>=10
@set SF=SAFE INHERIT
@parent SF=SD

@create SQL Commands <SC>=10
@set SC=SAFE INHERIT
@parent SC=SF
@force me=&d.sc me=[num(SC)]

@force me=&d.sf me=[num(SF)]
@force me=&vd [v(d.sf)]=[v(d.sd)]
@tel [v(d.sd)]=[v(d.sf)]
@tel [v(d.sf)]=[v(d.sc)]

&d.default-row-delimeter [v(d.sd)]=|

&d.default-column-delimeter [v(d.sd)]=~

&d.dangerous_in_sql [v(d.sd)]=%*_`\

&d.sanitize-where [v(d.sd)]=%\

&d.allowed_with_escapes_in_sql [v(d.sd)]=' "

&sql.get-tables [v(d.sd)]=SHOW TABLES;

&sql.get-table-columns [v(d.sd)]=DESCRIBE %0;

&sql.get-identity [v(d.sd)]=SELECT LAST_INSERT_ID()

&sql.get-table-contents [v(d.sd)]=SELECT * FROM %0 LIMIT 25 OFFSET %1

&sql.get-table-random [v(d.sd)]=SELECT * FROM %0 ORDER BY RAND() LIMIT 0, 1;

&sql.get-table-by-columns [v(d.sd)]=SELECT [setr(0, edit(%1, %b, %,))] FROM %0 ORDER BY %q0 LIMIT 25 OFFSET %2;

&sql.get-random-by-columns [v(d.sd)]=SELECT [setr(0, edit(%1, %b, %,))] FROM %0 ORDER BY RAND() LIMIT 0, 1;

&sql.get-whole-row-by-where [v(d.sd)]=SELECT * FROM %0 WHERE [ulocal(f.sanitize-where, %1)] LIMIT 25 OFFSET %2

&sql.get-columns-and-row-by-where [v(d.sd)]=SELECT [setr(0, edit(%1, %b, %,))] FROM %0 WHERE [ulocal(f.sanitize-where, %2)] ORDER BY %q0 LIMIT 25 OFFSET %3

&sql.get-single-column-info [v(d.sd)]=SELECT is_nullable, column_key, extra, data_type, character_maximum_length, column_comment FROM information_schema.columns WHERE table_name = '%0' AND column_name = '%1' LIMIT 0, 1;

&sql.update-table [v(d.sf)]=UPDATE `%0` SET [iter(%1, ulocal(layout.update-field, itext(0), extract(%2, inum(0), 1, %5)), %4, %,)] WHERE [ulocal(f.sanitize-where, %3)];

&sql.insert-table [v(d.sf)]=INSERT INTO `%0` ([ulocal(layout.columns-list, %1, %4)]) VALUES([ulocal(layout.values-list, %2, %5)]);

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

&f.sanitize-where [v(d.sf)]=strcat(setq(0, strip(%0, v(d.sanitize-where))), setq(0, if(strmatch(%q0, * LIKE *), edit(%q0, *, %%%%), %q0)), edit(%q0, @@ESCAPE@@, \\\\))

&layout.query_error [v(d.sf)]=strcat(Query error in %0:, %b, \[%1\], :%b, %2)

&tr.report_error [v(d.sf)]=if(cand(not(t(%1)), t(strlen(%1))), report(num(me), ulocal(layout.query_error, %0, %1, %2)))

@@ %0: table
@@ %1: row delimiter
@@ %2: column delimeter
@@ %3: offset

@@ Output: column1~column2~column3
&f.get-table-columns [v(d.sf)]=strcat(iter(setr(R, sql(setr(Q, ulocal(sql.get-table-columns, %0)), %1, %2)), first(itext(0), %2), %1, %2), ulocal(tr.report_error, get-table-columns, %qR, %qQ))

&f.get-table-contents [v(d.sf)]=strcat(setr(R, sql(setr(Q, ulocal(sql.get-table-contents, %0, %3)), %1, %2)), ulocal(tr.report_error, get-table-contents, %qR, %qQ))

&f.get-entire-table [v(d.sf)]=strcat(ulocal(f.get-table-columns, %0, %1, %2), %1, ulocal(f.get-table-contents, %0, %1, %2, %3))

&f.get-random-row [v(d.sf)]=strcat(ulocal(f.get-table-columns, %0, %1, %2), %1, setr(R, sql(setr(Q, ulocal(sql.get-table-random, %0)), %1, %2)), ulocal(tr.report_error, get-random-row, %qR, %qQ))

@@ %0: table
@@ %1: where query
@@ %2: row delimiter
@@ %3: column delimeter
@@ %4: offset
&f.get-whole-row-by-where [v(d.sf)]=strcat(ulocal(f.get-table-columns, %0, %2, %3), %2, setr(R, sql(setr(Q, ulocal(sql.get-whole-row-by-where, %0, %1, %4)), %2, %3)), ulocal(tr.report_error, get-whole-row-by-where, %qR, %qQ))

@@ %0: table
@@ %1: columns
@@ %2: row delimiter
@@ %3: column delimeter
@@ %4: offset
&f.get-table-by-columns [v(d.sf)]=strcat(edit(%1, %b, %3), %2, setr(R, sql(setr(Q, ulocal(sql.get-table-by-columns, %0, %1, %4)), %2, %3)), ulocal(tr.report_error, get-table-by-columns, %qR, %qQ))

&f.get-random-row-by-columns [v(d.sf)]=strcat(edit(%1, %b, %3), %2, setr(R, sql(setr(Q, ulocal(sql.get-random-by-columns, %0, %1)), %2, %3)), ulocal(tr.report_error, get-random-row-by-columns, %qR, %qQ))

@@ %0: table
@@ %1: columns
@@ %2: where query
@@ %3: row delimiter
@@ %4: column delimeter
@@ %5: offset
&f.get-columns-and-row-by-where [v(d.sf)]=strcat(edit(%1, %b, %4), %3, setr(R, sql(setr(Q, ulocal(sql.get-columns-and-row-by-where, %0, %1, %2, %5)), %3, %4)), ulocal(tr.report_error, get-columns-and-row-by-where, %qR, %qQ))

@@ %0: table: optional; if skipped returns a list of tables
@@ %1: columns: optional; if skipped returns the entire contents of the table, if given, sorts by the given column order
@@ %2: where query: optional; if skipped returns the results unfiltered
@@ %3: row delimeter: defaults to |
@@ %4: column delimeter: defaults to ~
@@ %5: offset, defaults to 0 (fetch returns records in groups of 25)
@@ Output:
@@ If no table: list of tables.
@@ If no columns and no where: Everything in table.
@@ If no columns yes where: All rows of table matching where.
@@ If yes columns yes where: Columns and rows matching where.
@@ If where = RAND, get a random row.

&f.globalpp.fetch [v(d.sf)]=strcat(setq(R, if(t(strlen(%3)), %3, v(d.default-row-delimeter))), setq(C, if(t(strlen(%4)), %4, v(d.default-column-delimeter))), setq(O, if(cand(t(strlen(%5)), isint(%5)), %5, 0)), case(0, cor(isstaff(%#), cand(not(member(num(me), %@)), hastype(%@, THING), andflags(%@, I!h!n), isstaff(owner(%@)))), #-1 PERMISSION DENIED, lte(words(%0), 1), #-1 TOO MANY TABLES (%0), t(%0), sql(ulocal(sql.get-tables), %qR, %qC), case(strcat(t(%1), t(%2)), 00, ulocal(f.get-entire-table, %0, %qR, %qC, %qO), 01, switch(%2, RAND, ulocal(f.get-random-row, %0, %qR, %qC), ulocal(f.get-whole-row-by-where, %0, %2, %qR, %qC, %qO)), 11, switch(%2, RAND, ulocal(f.get-random-row-by-columns, %0, %1, %qR, %qC), ulocal(f.get-columns-and-row-by-where, %0, %1, %2, %qR, %qC, %qO)), 10, ulocal(f.get-table-by-columns, %0, %1, %qR, %qC, %qO))))


&f.escape-characters [v(d.sf)]=if(t(setr(0, member(setr(1, v(d.allowed_with_escapes_in_sql)), %0))), strcat(@@ESCAPE@@, extract(%q1, %q0, 1)), %0)

@@ %0: term to sanitize
&f.globalpp.sanitize [v(d.sf)]=strcat(setq(0, strip(%0, v(d.dangerous_in_sql))), setq(1,), null(iter(lnum(strlen(%q0)), setq(1, strcat(%q1, ulocal(f.escape-characters, mid(%q0, itext(0), 1)))))), %q1)



&layout.update-field [v(d.sf)]=strcat(`, strip(%0, v(d.allowed_with_escapes_in_sql)), ` = ', edit(%1, @@ESCAPE@@, \\\\), ')

&layout.values-list [v(d.sf)]=iter(%0, strcat(', edit(itext(0), @@ESCAPE@@, repeat(\\\\, 2)), '), %1, %,)

&layout.columns-list [v(d.sf)]=iter(%0, strcat(`, edit(strip(itext(0), v(d.allowed_with_escapes_in_sql)), @@ESCAPE@@,), `), %1, %,)

&f.update-table [v(d.sf)]=strcat(setr(R, sql(setr(Q, ulocal(sql.update-table, %0, %1, %2, %3, %4, %5)))), ulocal(tr.report_error, update-table, %qR, %qQ), ulocal(f.get-columns-and-row-by-where, %0, %1, %3, %4, %4, 0))

&f.insert-table [v(d.sf)]=strcat(setr(R, sql(setr(Q, ulocal(sql.insert-table, %0, %1, %2, %3, %4, %5)))), ulocal(tr.report_error, insert-table-1, %qR, %qQ), setr(I, sql(setr(J, ulocal(sql.get-identity, %0)))), ulocal(tr.report_error, insert-table-2, %qI, %qJ))


@@ %0: table
@@ %1: columns
@@ %2: values
@@ %3: where query
@@ %4: column delimiter
@@ %5: value delimiter
&f.globalpp.post [v(d.sf)]=strcat(setq(C, if(t(strlen(%4)), %4, v(d.default-column-delimeter))), setq(V, if(t(strlen(%5)), %5, %qC)), setq(R, v(d.default-row-delimeter)), case(0, cor(isstaff(%#), cand(not(member(num(me), %@)), hastype(%@, THING), andflags(%@, I!h!n), isstaff(owner(%@)))), #-1 PERMISSION DENIED, lte(words(%0), 1), #-1 TOO MANY TABLES (%0), t(%0), #-1 NO TABLE SPECIFIED, member(fetch(), %0, %qR), #-1 TABLE '%0' NOT FOUND, t(%1), #-1 NO COLUMN SPECIFIED, not(t(setr(D, setdiff(%1, first(fetch(%0), %qR), %qC)))), #-1 COLUMNS '%qD' NOT FOUND, t(%2), #-1 NO VALUE SPECIFIED, eq(words(%1, %qC), words(%2, %qV)), #-1 NUMBER OF COLUMNS AND VALUES MUST MATCH, t(%3), #-1 NO WHERE CRITERIA PROVIDED, member(INSERT, %3), case(0, strmatch(%3, *=*), #-1 WHERE QUERY NOT SPECIFIC ENOUGH, strcat(setq(E, fetch(%0,, %3)), case(1, gt(words(%qE, %qR), 2), #-1 UPDATE WOULD AFFECT TOO MANY ROWS, lte(words(rest(%qE, %qR), %qC), 1), #-1 UPDATE WOULD AFFECT ZERO ROWS, strcat(setq(F, 1), setr(O, ulocal(f.update-table, %0, %1, %2, %3, %qC, %qV)))))), strcat(setq(F, 1), setr(O, ulocal(f.insert-table, %0, %1, %2, %3, %qC, %qV)))), if(cand(%qF, eq(strlen(%qO), 0)), success))

@@ %0: table list
@@ %1: viewer
&f.filter-unlocked-tables [v(d.sf)]=if(isstaff(%1), %0, setinter(%0, v(d.unlocked_tables), v(d.default-row-delimeter)))

@@ %0: table list
&f.filter-hidden-tables [v(d.sf)]=setdiff(%0, v(d.hidden_tables), v(d.default-row-delimeter))

@@ %0: table list
@@ %1: user viewing this
&layout.show_tables [v(d.sf)]=strcat(header(All available tables, %1), %r, formatcolumns(%0, v(d.default-row-delimeter), %1), %r, footer(+db <table name> for more, %1))

&f.flip-data-horizontal [v(d.sf)]=strcat(setq(R, v(d.default-row-delimeter)), setq(C, v(d.default-column-delimeter)), setq(0, setq(1,)), null(iter(first(%0, %qR), setq(1, strcat(if(gt(strlen(itext(0)), %q0), setq(0, strlen(itext(0)))), %q1, %qR, ansi(first(themecolors()), itext(0)), :, %qR, extract(rest(%0, %qR), inum(0), 1, %qC))), %qC, @@)), trim(%q1, b, %qR), @@WIDTH@@, %q0)

&layout.single_row [v(d.sf)]=strcat(setq(0, ulocal(f.flip-data-horizontal, %1)), setq(1, last(%q0, @@WIDTH@@)), setq(0, before(%q0, @@WIDTH@@)), header(Single result from the '%0' table', %2), %r, multicol(%q0, inc(%q1) *,, v(d.default-row-delimeter), %2), %r, footer(Only one result returned., %2))

@@ %0: table name
@@ %1: table contents
@@ %2: user viewing this
&layout.page-footer [v(d.sf)]=strcat(Results, %b, setq(P, default(%2/_current.page.%0, 0)), inc(%qP), %b, -, %b, setr(L, min(add(%qP, 25), add(%qP, dec(words(%1, v(d.default-row-delimeter)))))), if(eq(%qL, 25), strcat(%,%b, +db/n for next page), if(gt(%qP, 0), strcat(%,%b, +db/p for previous page))))

&layout.table [v(d.sf)]=if(gt(words(%1, v(d.default-row-delimeter)), 2), strcat(setq(W, v(d.column_widths.%0)), header(From the '%0' table, %2), %r, if(t(%qW), multicol(edit(%1, v(d.default-column-delimeter), v(d.default-row-delimeter)), %qW, 1, v(d.default-row-delimeter), %2), formatdb(%1, 1,,, %2)), %r, footer(ulocal(layout.page-footer, %0, %1, %2), %2)), ulocal(layout.single_row, %0, %1, %2))

@@ %0: table name
@@ %1: table contents
@@ %2: user viewing this
&layout.table-columns [v(d.sf)]=strcat(setq(R, v(d.default-row-delimeter)), setq(C, v(d.default-column-delimeter)), header(Columns in the the '%0' table, %2), %r, formattable(iter(first(%1, %qR), squish(strcat(itext(0), :, %qR, setq(I, sql(ulocal(sql.get-single-column-info, %0, itext(0)), %qR, %qC)), if(first(%qI, %qC), nullable, required), %b, switch(extract(%qI, 2, 1, %qC), PRI, primary key, UNI, unique, MUL, multi-key,), %b, extract(%qI, 3, 1, %qC), %b, extract(%qI, 4, 1, %qC), %b, extract(%qI, 5, 1, %qC), %b, extract(%qI, 6, 1, %qC))), %qC, %qR), 2,, %qR, %2), %r, footer(, %2))

&tr.error [v(d.sc)]=@pemit %0=alert(Error) %1;

&tr.success [v(d.sc)]=@pemit %0=alert(Success) %1;

&tr.message [v(d.sc)]=@pemit %0=alert(Alert) %1;

&c.+db [v(d.sc)]=$+db:@pemit %#=ulocal(layout.show_tables, ulocal(f.filter-hidden-tables, ulocal(f.filter-unlocked-tables, fetch(), %#)), %#);

&c.+db_table [v(d.sc)]=$+db *:@assert member(ulocal(f.filter-unlocked-tables, fetch(), %#), %0, v(d.default-row-delimeter))={ @trigger me/tr.error=%#, Cannot find a table named '%0'.; }; @pemit %#=ulocal(layout.table, %0, fetch(%0, v(d.columns.%0)), %#); &_current.table %#=%0; @wipe %#/_current.page.*; @wipe %#/_current.search.*; &_current.page.%0 %#=0;

&c.+db_next [v(d.sc)]=$+db/n*:@break strmatch(%0, * *); @assert member(ulocal(f.filter-unlocked-tables, fetch(), %#), setr(0, xget(%#, _current.table)), v(d.default-row-delimeter))={ @trigger me/tr.error=%#, Cannot find a table named '%q0'.; }; @eval if(eq(words(trim(setr(1, fetch(%q0, v(d.columns.%q0), xget(%#, _current.search.%q0),,, setr(2, add(default(%#/_current.page.%q0, 0), 25)))), b, v(d.default-row-delimeter)), v(d.default-row-delimeter)), 1), strcat(setq(1, fetch(%q0, v(d.columns.%q0), xget(%#, _current.search.%q0),,, 0)), setq(2, 0), setq(3, 1))); &_current.page.%q0 %#=%q2; @pemit %#=ulocal(layout.table, %q0, %q1, %#); @break t(%q3)={  @trigger me/tr.message=%#, Reached the end of the list. Starting over.; };

&c.+db_back [v(d.sc)]=$+db/*:@break strmatch(%0, * *); @assert cor(strmatch(%0, p*), strmatch(%0, b*)); @assert member(ulocal(f.filter-unlocked-tables, fetch(), %#), setr(0, xget(%#, _current.table)), v(d.default-row-delimeter))={ @trigger me/tr.error=%#, Cannot find a table named '%q0'.; }; @assert gt(setr(2, default(%#/_current.page.%q0, 0)), 0)={ @trigger me/tr.error=%#, You have reached the beginning and cannot go further back.; }; &_current.page.%q0 %#=setr(2, sub(%q2, 25)); @pemit %#=ulocal(layout.table, %q0, fetch(%q0, v(d.columns.%q0), xget(%#, _current.search.%q0),,, %q2), %#);

&c.+db_rand_table [v(d.sc)]=$+db/rand *:@assert member(ulocal(f.filter-unlocked-tables, fetch(), %#), %0, v(d.default-row-delimeter))={ @trigger me/tr.error=%#, Cannot find a table named '%0'.; }; @pemit %#=ulocal(layout.table, %0, fetch(%0, v(d.columns.%0), RAND), %#); &_current.table %#=%0;

&c.+db_rand [v(d.sc)]=$+db/rand:@assert member(ulocal(f.filter-unlocked-tables, fetch(), %#), setr(0, xget(%#, _current.table)), v(d.default-row-delimeter))={ @trigger me/tr.error=%#, Cannot find a table named '%q0'.; }; @pemit %#=ulocal(layout.table, %q0, fetch(%q0, v(d.columns.%q0), RAND), %#);

&c.+db_find_table [v(d.sc)]=$+db/find */*=*:@assert member(ulocal(f.filter-unlocked-tables, fetch(), %#), %0, v(d.default-row-delimeter))={ @trigger me/tr.error=%#, Cannot find a table named '%0'.; }; @break t(setr(U, setdiff(%1, trim(fetch(%0,, 1=0), r, v(d.default-row-delimeter)), v(d.default-column-delimeter))))={ @trigger me/tr.error=%#, Could not find a column named '%qU'.;}; @pemit %#=ulocal(layout.table, %0, fetch(%0, v(d.columns.%0), setr(S, strcat(LOWER\(CONVERT\(%1 USING utf8mb4\)\), %b, LIKE, %b', setr(A, sanitize(%2)), *'))), %#); &_current.table %#=%0; @wipe %#/_current.page.*; @wipe %#/_current.search.*; &_current.page.%0 %#=0; &_current.search.%0 %#=%qS;

&c.+db_find [v(d.sc)]=$+db/find *=*:@break strmatch(%0, */*); @assert member(ulocal(f.filter-unlocked-tables, fetch(), %#), setr(0, xget(%#, _current.table)), v(d.default-row-delimeter))={ @trigger me/tr.error=%#, Cannot find a table named '%q0'.; }; @break t(setr(U, setdiff(%0, trim(fetch(%q0,, 1=0), r, v(d.default-row-delimeter)), v(d.default-column-delimeter))))={ @trigger me/tr.error=%#, Could not find a column named '%qU'.;}; @pemit %#=ulocal(layout.table, %q0, fetch(%q0, v(d.columns.%q0), setr(S, strcat(LOWER\(CONVERT\(%0 USING utf8mb4\)\), %b, LIKE, %b', setr(A, sanitize(%1)), *'))), %#); @wipe %#/_current.page.*; @wipe %#/_current.search.*; &_current.page.%q0 %#=0; &_current.search.%q0 %#=%qS;


&c.+db_columns_table [v(d.sc)]=$+db/c* *:@break strmatch(%1, *=*); @break strmatch(%1, * *); @assert member(ulocal(f.filter-unlocked-tables, fetch(), %#), %1, v(d.default-row-delimeter))={ @trigger me/tr.error=%#, Cannot find a table named '%1'.; }; @pemit %#=ulocal(layout.table-columns, %1, fetch(%1,, 1=0), %#); &_current.table %#=%1;

&c.+db_columns [v(d.sc)]=$+db/c*:@break strmatch(%0, * *); @assert member(ulocal(f.filter-unlocked-tables, fetch(), %#), setr(0, xget(%#, _current.table)), v(d.default-row-delimeter))={ @trigger me/tr.error=%#, Cannot find a table named '%q0'.; }; @pemit %#=ulocal(layout.table-columns, %q0, fetch(%q0,, 1=0), %#);

&c.+db_columns_set_table [v(d.sc)]=$+db/c* *=*:@break strmatch(%0, *w*); @assert member(ulocal(f.filter-unlocked-tables, fetch(), %#), %1, v(d.default-row-delimeter))={ @trigger me/tr.error=%#, Cannot find a table named '%1'.; }; @break t(setr(U, setdiff(edit(%2, %b, v(d.default-column-delimeter)), trim(fetch(%1,, 1=0), r, v(d.default-row-delimeter)), v(d.default-column-delimeter))))={ @trigger me/tr.error=%#, Could not find all the columns in your list. Can't find: '[itemize(%qU, v(d.default-column-delimeter))]';}; &d.columns.%1 %vD=%2; @trigger me/tr.success=%#, The column list for '%1' is now: %2; @assert cor(not(t(setr(W, v(d.column_widths.%1)))), eq(words(default(d.columns.%1, edit(first(fetch(%1,, 1=0), v(d.default-row-delimeter)), v(d.default-column-delimeter), %b))), words(%qW)))={ &d.column_widths.%1 %vD=; @trigger me/tr.message=%#, Your column widths no longer match your number of columns. This can lead to data leakage. Because of this%, your custom column widths have been wiped. They were: %qW; }; &_current.table %#=%1;

&c.+db_columns_set [v(d.sc)]=$+db/c* *:@break strmatch(%0, *w*); @break strmatch(%1, *=*); @break eq(words(%1), 1); @assert member(ulocal(f.filter-unlocked-tables, fetch(), %#), setr(0, xget(%#, _current.table)), v(d.default-row-delimeter))={ @trigger me/tr.error=%#, Cannot find a table named '%q0'.; }; @break t(setr(U, setdiff(edit(%1, %b, v(d.default-column-delimeter)), trim(fetch(%q0,, 1=0), r, v(d.default-row-delimeter)), v(d.default-column-delimeter))))={ @trigger me/tr.error=%#, Could not find all the columns in your list. Can't find: '[itemize(%qU, v(d.default-column-delimeter))]';}; &d.columns.%q0 %vD=%1; @trigger me/tr.success=%#, The column list for '%q0' is now: %1; @assert cor(not(t(setr(W, v(d.column_widths.%q0)))), eq(words(default(d.columns.%q0, edit(first(fetch(%q0,, 1=0), v(d.default-row-delimeter)), v(d.default-column-delimeter), %b))), words(%qW)))={ &d.column_widths.%q0 %vD=; @trigger me/tr.message=%#, Your column widths no longer match your number of columns. This can lead to data leakage. Because of this%, your custom column widths have been wiped. They were: %qW; };

&c.+db_columns_widths_table [v(d.sc)]=$+db/c* *=*:@assert strmatch(%0, *w*); @assert member(ulocal(f.filter-unlocked-tables, fetch(), %#), %1, v(d.default-row-delimeter))={ @trigger me/tr.error=%#, Cannot find a table named '%1'.; }; @assert eq(words(default(d.columns.%1, edit(first(fetch(%1,, 1=0), v(d.default-row-delimeter)), v(d.default-column-delimeter), %b))), words(%2))={ @trigger me/tr.error=%#, You must have the same number of column widths as columns.; }; &d.column_widths.%1 %vD=%2; @trigger me/tr.success=%#, The column width list for '%1' is now: %2; &_current.table %#=%1;

&c.+db_columns_widths [v(d.sc)]=$+db/c* *:@assert strmatch(%0, *w*); @break strmatch(%q0, *=*); @assert member(ulocal(f.filter-unlocked-tables, fetch(), %#), setr(0, xget(%#, _current.table)), v(d.default-row-delimeter))={ @trigger me/tr.error=%#, Cannot find a table named '%q0'.; }; @assert eq(words(default(d.columns.%q0, edit(first(fetch(%q0,, 1=0), v(d.default-row-delimeter)), v(d.default-column-delimeter), %b))), words(%1))={ @trigger me/tr.error=%#, You must have the same number of column widths as columns.; }; &d.column_widths.%q0 %vD=%1; @trigger me/tr.success=%#, The column width list for '%q0' is now: %1;

&c.+db/hide_table [v(d.sc)]=$+db/hide *:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to use this function.; }; @assert member(fetch(), %0, v(d.default-row-delimeter))={ @trigger me/tr.error=%#, Can't find a table named '%0'.; }; @break member(v(d.hidden_tables), %0, v(d.default-row-delimeter))={ @trigger me/tr.error=%#, The table '%0' is already hidden.; }; &d.hidden_tables %vD=[setunion(v(d.hidden_tables), %0, v(d.default-row-delimeter))]; @trigger me/tr.success=%#, The table '%0' has been added to the list of hidden tables. You will no longer see it in +db.; &_current.table %#=;

&c.+db/hide [v(d.sc)]=$+db/hide:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to use this function.; }; @assert member(fetch(), setr(0, xget(%#, _current.table)), v(d.default-row-delimeter))={ @trigger me/tr.error=%#, Can't find a table named '%q0'.; }; @break member(v(d.hidden_tables), %q0, v(d.default-row-delimeter))={ @trigger me/tr.error=%#, The table '%q0' is already hidden.; }; &d.hidden_tables %vD=[setunion(v(d.hidden_tables), %q0, v(d.default-row-delimeter))]; @trigger me/tr.success=%#, The table '%q0' has been added to the list of hidden tables. You will no longer see it in +db.; &_current.table %#=;

&c.+db/show_table [v(d.sc)]=$+db/show *:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to use this function.; }; @assert member(fetch(), %0, v(d.default-row-delimeter))={ @trigger me/tr.error=%#, Can't find a table named '%0'.; }; @assert member(v(d.hidden_tables), %0, v(d.default-row-delimeter))={ @trigger me/tr.error=%#, The table '%0' is not currently hidden.; }; &d.hidden_tables %vD=[setdiff(v(d.hidden_tables), %0, v(d.default-row-delimeter))]; @trigger me/tr.success=%#, The table '%0' has been unhidden. You will now see it in +db.; &_current.table %#=%0;

&c.+db/show [v(d.sc)]=$+db/show:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to use this function.; }; @assert member(fetch(), setr(0, xget(%#, _current.table)), v(d.default-row-delimeter))={ @trigger me/tr.error=%#, Can't find a table named '%q0'.; }; @assert member(v(d.hidden_tables), %q0, v(d.default-row-delimeter))={ @trigger me/tr.error=%#, The table '%q0' is not currently hidden.; }; &d.hidden_tables %vD=[setdiff(v(d.hidden_tables), %q0, v(d.default-row-delimeter))]; @trigger me/tr.success=%#, The table '%q0' has been unhidden. You will now see it in +db.;

&c.+db/unlock_table [v(d.sc)]=$+db/unlock *:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to use this function.; }; @assert member(fetch(), %0, v(d.default-row-delimeter))={ @trigger me/tr.error=%#, Can't find a table named '%0'.; }; @break member(v(d.unlocked_tables), %0, v(d.default-row-delimeter))={ @trigger me/tr.error=%#, The table '%0' is already unlocked and visible to players.; }; &d.unlocked_tables %vD=[setunion(v(d.unlocked_tables), %0, v(d.default-row-delimeter))]; @trigger me/tr.success=%#, The table '%0' has been unlocked. Players can now see it in +db.; &_current.table %#=%0;

@@ Skipping &c.+db/unlock with no table specified because we don't want to risk unsecuring something by accident.

&c.+db/lock_table [v(d.sc)]=$+db/lock *:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to use this function.; }; @assert member(fetch(), %0, v(d.default-row-delimeter))={ @trigger me/tr.error=%#, Can't find a table named '%0'.; }; @assert member(v(d.unlocked_tables), %0, v(d.default-row-delimeter))={ @trigger me/tr.error=%#, The table '%0' is locked and is not currently visible to players.; }; &d.unlocked_tables %vD=[setdiff(v(d.unlocked_tables), %0, v(d.default-row-delimeter))]; @trigger me/tr.success=%#, The table '%0' has been locked. Players can no longer see it in +db.; &_current.table %#=%0;

&c.+db/lock [v(d.sc)]=$+db/lock:@assert isstaff(%#)={ @trigger me/tr.error=%#, You must be staff to use this function.; }; @assert member(fetch(), setr(0, xget(%#, _current.table)), v(d.default-row-delimeter))={ @trigger me/tr.error=%#, Can't find a table named '%q0'.; }; @assert member(v(d.unlocked_tables), %q0, v(d.default-row-delimeter))={ @trigger me/tr.error=%#, The table '%q0' is locked and is not currently visible to players.; }; &d.unlocked_tables %vD=[setdiff(v(d.unlocked_tables), %q0, v(d.default-row-delimeter))]; @trigger me/tr.success=%#, The table '%q0' has been locked. Players can no longer see it in +db.;

@@ Wrapping up:

@restart
