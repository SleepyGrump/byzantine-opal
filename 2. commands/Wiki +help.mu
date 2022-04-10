/*
This is designed for MediaWiki version 1.35+, tested all the way up to 1.37. If you use an earlier version of MediaWiki, you would be better off using Thenomain's Wiki Help and News available at:

https://github.com/thenomain/Mu--Support-Systems/blob/master/Wiki%20Help%20and%20News.txt

This code requires the use of a Help Template. That's included in this repo under 3. help files/Help template.txt. All that matters is that the help file use the same template field positions and number of fields. If you change it you'll need to change the code in this file to match.

Sample templates are included in "3. help files". Each help file is written for a general audience, but may require editing for your game and settings. Help files belong in sub-categories like "Basic Commands" and "Roleplay Commands". Without this arrangement, +help won't work.

TODO: BUG: on new game, lots of errors get thrown to the Monitor channel when user hits +help and there's no DB set up. That's sort of expected, though...

*/

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Settings
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

@@ Your prefix, if any:
&vP [v(d.bd)]=wiki_

&d.help.topic.field [v(d.bd)]=topic

&d.help.shortdesc.field [v(d.bd)]=short

&d.help.detail.field [v(d.bd)]=detail

&d.help.example.field [v(d.bd)]=example

&d.help.link.field [v(d.bd)]=link

&d.help.link.count [v(d.bd)]=4

@@ The Help namespace text. We're going with MediaWiki's built in Help namespace by default. If you put it in a custom namespace, change it to your custom namespace name. This might involve a _ instead of a space if you have a space in your namespace, AKA Game Help. Try it both ways and make sure it works.
&d.help.namespace [v(d.bd)]=Help

@@ The Help namespace ID. This is 12 by default and is set by MediaWiki. Change it to the new ID if you're putting Help in a new namespace.
&d.help.namespace.id [v(d.bd)]=12

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ SQL keepalive job: MySQL times out after 8 hours of inactivity. Some games 
@@ don't have enough going on to keep it alive just by players hitting +help.
@@ This job fires off every 4 hours and keeps the connection alive 
@@ automatically.
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

@force me=&CRON_JOB_SQL [v(d.cron)]=@trigger [v(d.bc)]/tr.sql-check

&CRON_TIME_SQL [v(d.cron)]=|||04 08 12 16 20 24||

&tr.sql-check [v(d.bc)]=@eval strcat(setr(R, sql(setr(Q, SELECT 1), v(d.default-row-delimeter), v(d.default-column-delimeter))), ulocal(tr.report_query_error, tr.sql-check, %qR, %qQ));

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ MySQL statements
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

&sql.get-exact-page-text [v(d.bd)]=SELECT `%vPtext`.`old_text` FROM `%vPpage` INNER JOIN `%vPslots` on `%vPpage`.`page_latest`=`%vPslots`.`slot_revision_id` INNER JOIN `%vPcontent` ON `%vPslots`.`slot_content_id`=`%vPcontent`.`content_id` INNER JOIN `%vPtext` ON SUBSTR(`%vPcontent`.`content_address`, 4)=`%vPtext`.`old_id` INNER JOIN `%vPcategorylinks` ON REPLACE(UPPER(CONVERT(`%vPcategorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`%vPpage`.`page_title` USING latin1)), '_', ' ') WHERE `%vPcategorylinks`.`cl_to`='[v(d.%1.namespace)]' AND `%vPcategorylinks`.`cl_type` = 'page' AND (REPLACE(LOWER(CONVERT(`%vPpage`.`page_title` USING utf8mb4)), "_", " ") = '[ulocal(f.sanitize-where, %0)]' OR REPLACE(LOWER(CONVERT(`%vPpage`.`page_title` USING utf8mb4)), "_", " ") = '+[ulocal(f.sanitize-where, %0)]') AND `wiki_page`.`page_namespace` = [v(d.%1.namespace.id)]

&sql.get-exact-category-contents [v(d.bd)]=SELECT REPLACE(`%vPcategory`.`cat_title`, '_', ' ') FROM `%vPcategorylinks` INNER JOIN `%vPcategory` ON REPLACE(UPPER(CONVERT(`%vPcategorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`%vPcategory`.`cat_title` USING latin1)), '_', ' ') WHERE `%vPcategorylinks`.`cl_type`='subcat' AND REPLACE(LOWER(CONVERT(`%vPcategorylinks`.`cl_to` USING latin1)), '_', ' ') = '[ulocal(f.sanitize-where, %0)]' UNION SELECT DISTINCT `%vPpage`.`page_title` FROM `%vPcategorylinks` INNER JOIN `%vPpage` ON REPLACE(UPPER(CONVERT(`%vPcategorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`%vPpage`.`page_title` USING latin1)), '_', ' ') WHERE `%vPcategorylinks`.`cl_type`='page' AND REPLACE(LOWER(CONVERT(`%vPcategorylinks`.`cl_to` USING utf8mb4)), "_", " ") = '[ulocal(f.sanitize-where, %0)]'

&sql.get-similar-page-text [v(d.bd)]=SELECT `%vPtext`.`old_text` FROM `%vPpage` INNER JOIN `%vPslots` on `%vPpage`.`page_latest`=`%vPslots`.`slot_revision_id` INNER JOIN `%vPcontent` ON `%vPslots`.`slot_content_id`=`%vPcontent`.`content_id` INNER JOIN `%vPtext` ON SUBSTR(`%vPcontent`.`content_address`, 4)=`%vPtext`.`old_id` INNER JOIN `%vPcategorylinks` ON REPLACE(UPPER(CONVERT(`%vPcategorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`%vPpage`.`page_title` USING latin1)), '_', ' ') WHERE `%vPcategorylinks`.`cl_to`='[v(d.%1.namespace)]' AND `%vPcategorylinks`.`cl_type` = 'page' AND (REPLACE(LOWER(CONVERT(`%vPpage`.`page_title` USING utf8mb4)), "_", " ") LIKE '[ulocal(f.sanitize-where, %0)]\\\%' OR REPLACE(LOWER(CONVERT(`%vPpage`.`page_title` USING utf8mb4)), "_", " ") LIKE '+[ulocal(f.sanitize-where, %0)]\\\%') AND `wiki_page`.`page_namespace` = [v(d.%1.namespace.id)]

&sql.get-similar-category-contents [v(d.bd)]=SELECT REPLACE(`%vPcategory`.`cat_title`, '_', ' ') FROM `%vPcategorylinks` INNER JOIN `%vPcategory` ON REPLACE(UPPER(CONVERT(`%vPcategorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`%vPcategory`.`cat_title` USING latin1)), '_', ' ') WHERE `%vPcategorylinks`.`cl_type`='subcat' AND REPLACE(LOWER(CONVERT(`%vPcategorylinks`.`cl_to` USING latin1)), '_', ' ') LIKE '[ulocal(f.sanitize-where, %0)]\\\%' UNION SELECT DISTINCT `%vPpage`.`page_title` FROM `%vPcategorylinks` INNER JOIN `%vPpage` ON REPLACE(UPPER(CONVERT(`%vPcategorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`%vPpage`.`page_title` USING latin1)), '_', ' ') WHERE `%vPcategorylinks`.`cl_type`='page' AND (REPLACE(LOWER(CONVERT(`%vPcategorylinks`.`cl_to` USING utf8mb4)), "_", " ") LIKE '[ulocal(f.sanitize-where, %0)]\\\%' OR REPLACE(LOWER(CONVERT(`%vPcategorylinks`.`cl_to` USING utf8mb4)), "_", " ") LIKE '+[ulocal(f.sanitize-where, %0)]\\\%')

&sql.get-namespace-main-categories [v(d.bd)]=SELECT DISTINCT REPLACE(`%vPpage`.`page_title`, '_', ' ') FROM `%vPcategorylinks` INNER JOIN `%vPpage` ON REPLACE(UPPER(CONVERT(`%vPcategorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`%vPpage`.`page_title` USING latin1)), '_', ' ') WHERE `%vPcategorylinks`.`cl_type`='subcat' AND `%vPcategorylinks`.`cl_to`='[v(d.%1.namespace)]'

&sql.get-namespace-category-name [v(d.bd)]=SELECT DISTINCT REPLACE(`%vPpage`.`page_title`, '_', ' ') FROM `%vPcategorylinks` INNER JOIN `%vPpage` ON REPLACE(UPPER(CONVERT(`%vPcategorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`%vPpage`.`page_title` USING latin1)), '_', ' ') WHERE `%vPcategorylinks`.`cl_type`='subcat' AND `%vPcategorylinks`.`cl_to`='[v(d.%1.namespace)]' AND CONVERT(LOWER(REPLACE(`%vPpage`.`page_title`, '_', ' ')) USING utf8mb4) LIKE '[ulocal(f.sanitize-where, %0)]\\\%'

&sql.namespace-text-search [v(d.bd)]=SELECT REPLACE(`%vPpage`.`page_title`, '_', ' ') FROM `%vPpage` INNER JOIN `%vPslots` on `%vPpage`.`page_latest`=`%vPslots`.`slot_revision_id` INNER JOIN `%vPcontent` ON `%vPslots`.`slot_content_id`=`%vPcontent`.`content_id` INNER JOIN `%vPtext` ON SUBSTR(`%vPcontent`.`content_address`, 4)=`%vPtext`.`old_id` INNER JOIN `%vPcategorylinks` ON REPLACE(UPPER(CONVERT(`%vPcategorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`%vPpage`.`page_title` USING latin1)), '_', ' ') WHERE `%vPcategorylinks`.`cl_to`='[v(d.%1.namespace)]' AND `%vPcategorylinks`.`cl_type` = 'page' AND REPLACE(LOWER(CONVERT(`%vPtext`.`old_text` USING utf8mb4)), "_", " ") LIKE '\\\%[ulocal(f.sanitize-where, %0)]\\\%' AND `wiki_page`.`page_namespace` = [v(d.%1.namespace.id)]

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Info functions
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

&f.get-page-topic [v(d.bf)]=trim(rest(finditem(%0, v(d.help.topic.field)=, |), =), b, %r)

&f.get-page-short [v(d.bf)]=trim(rest(finditem(%0, v(d.help.shortdesc.field)=, |), =), b, %r)

&f.get-page-detail [v(d.bf)]=trim(rest(finditem(%0, v(d.help.detail.field)=, |), =), b, %r)

&f.get-page-example [v(d.bf)]=trim(rest(finditem(%0, v(d.help.example.field)=, |), =), b, %r)

&f.get-page-links [v(d.bf)]=squish(trim(edit(iter(lnum(1, v(d.help.link.count)), rest(finditem(%0, strcat(v(d.help.link.field), itext(0), =), |), =),, |), %r,), b, |), |)

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Work functions
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

&f.run-query [v(d.bf)]=strcat(setr(R, sql(setr(Q, ulocal(%0, lcstr(%1), %2)), v(d.default-row-delimeter), v(d.default-column-delimeter))), ulocal(tr.report_query_error, %0, %qR, %qQ))

&f.format-results [v(d.bf)]=strcat(setq(0, 0), iter(edit(trim(trim(translate(%0, p), b, lit(%r))), lit(%r), %r, lit(%t), %t, lit(%b), %b, lit(%%R), %%R, lit(%%T), %%T, %r%r%r, %r%r, lit(%(), %(, lit(%)), %), lit(%[), %[, lit(%]), %], %r***, %r%b%b%cx>>%cn*, %r**, %r%b%b*, \\\\\\\\, \\\\, %%t, %T, <blockquote>,, </blockquote>,), if(cor(strmatch(itext(0), ''*), t(%q0)), strcat(ansi(h, trim(itext(0), b, ')), setq(0, not(strmatch(itext(0), *'')))), itext(0))))

@@ th ulocal(v(d.bf)/f.format-results, ''Test''. Testing.)

@@ TODO: Format Results doesn't work if the '' comes right before punctuation. ''test''. <-- fails. Easy fix, remove punctuation except for ' in the match, but then that causes the trim to fail. Pity we can't run multiple separators on the iter... well, we could but that's a lot of work for an edge case...

&f.sanitize-where [v(d.bf)]=strcat(setq(0, strip(%0, v(d.sanitize-where))), setq(0, if(strmatch(%q0, * LIKE *), edit(%q0, *, %%%%), %q0)), edit(%q0, @@ESCAPE@@, \\\\))

&f.find-namespace-by-text [v(d.bf)]=if(t(setr(P, ulocal(f.run-query, sql.get-exact-page-text, %0, %2))), ulocal(layout.%2-page, ulocal(f.format-results, %qP), %1), if(t(setr(C, ulocal(f.run-query, sql.get-exact-category-contents, %0, %2))), ulocal(layout.list-category, ulocal(f.run-query, sql.get-namespace-category-name, %0, %2), %qC, %1, %2), if(t(setr(P, ulocal(f.run-query, sql.get-similar-page-text, %0, %2))), ulocal(layout.%2-page, ulocal(f.format-results, %qP), %1), if(t(setr(C, ulocal(f.run-query, sql.get-similar-category-contents, %0, %2))), ulocal(layout.list-category, ulocal(f.run-query, sql.get-namespace-category-name, %0, %2), %qC, %1, %2), if(t(setr(S, ulocal(f.run-query, sql.namespace-text-search, %0, %2))), ulocal(layout.list-category, capstr(%2) files containing '%0', %qS, %1, %2), alert(Error) No %2 files found for '%0' Try [switch(%2, news, %2, +%2)]/search %0.)))))

&f.search-namespace-by-text [v(d.bf)]=if(t(setr(S, ulocal(f.run-query, sql.namespace-text-search, %0, %2))), ulocal(layout.list-category, capstr(%2) files containing '%0', %qS, %1, %2), alert(Error) No %2 files found for '%0' Try [switch(%2, news, %2, +%2)]/search %0.)

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Layouts
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

&layout.examples [v(d.bf)]=if(t(setr(E, ulocal(f.get-page-example, %0))), strcat(divider(Commands, %1), %r, formattext(%qE, 0, %1)))

&layout.see_also [v(d.bf)]=if(t(setr(A, ulocal(f.get-page-links, %0))), strcat(%r, formattext(strcat(%r, Other topics:, %b, ulocal(layout.list, %qA)), 0, %1)))

&layout.help-page [v(d.bf)]=strcat(header(ulocal(f.get-page-topic, %0), %1), %r, formattext(strcat(ulocal(f.get-page-short, %0), %r%r%t, ulocal(f.get-page-detail, %0)), 1, %1), %r, ulocal(layout.examples, %0, %1), ulocal(layout.see_also, %0, %1), %r, footer(+help for more, %1))

&layout.list-category [v(d.bf)]=strcat(header(%0, %2), %r, formatcolumns(edit(%1, _, %b), v(d.default-row-delimeter), %2) %r, footer(switch(%3, news, %3, +%3) <file name> for more., %2))

&layout.namespace-categories [v(d.bf)]=if(t(setr(P, ulocal(f.run-query, sql.get-namespace-main-categories,, %2))), ulocal(layout.list-category, capstr(%2) categories, %qP, %0, %2), alert(Error) No %2 files found.)

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Commands
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

&c.+help_text [v(d.bc)]=$+help *:@pemit %#=ulocal(f.find-namespace-by-text, %0, %#, help)

&c.+help/search_text [v(d.bc)]=$+help/s* *:@pemit %#=ulocal(f.search-namespace-by-text, %1, %#, help)

&c.+help [v(d.bc)]=$+help:@pemit %#=ulocal(layout.namespace-categories, %#,, help)
