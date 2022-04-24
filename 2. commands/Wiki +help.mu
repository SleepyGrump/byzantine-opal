/*
This is designed for MediaWiki version 1.35+, tested all the way up to 1.37. If you use an earlier version of MediaWiki, you would be better off using Thenomain's Wiki Help and News available at:

https://github.com/thenomain/Mu--Support-Systems/blob/master/Wiki%20Help%20and%20News.txt

User customizable settings for this code are in: Y. Customizable settings.mu

Those should be customized! Otherwise it's going to look weird.

Code settings are in 2. Code settings.mu. Those probably don't need customized.

This code requires the use of a Help Template. That's included in this repo under 3. help files/Help template.txt. All that matters is that the help file use the same template field positions and number of fields. If you change it you'll need to change the code in this file to match.

Sample templates are included in "3. help files". Each help file is written for a general audience, but may require editing for your game and settings. Help files belong in sub-categories like "Basic Commands" and "Roleplay Commands". Without this arrangement, +help won't work.

TODO: BUG: on new game, lots of errors get thrown to the Monitor channel when user hits +help and there's no DB set up. That's sort of expected, though...

*/

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ SQL keepalive job: MySQL times out after 8 hours of inactivity. Some games 
@@ don't have enough going on to keep it alive just by players hitting +help.
@@ This job fires off every 4 hours and keeps the connection alive 
@@ automatically.
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

@force me=&CRON_JOB_SQL [v(d.cron)]=@trigger [v(d.bc)]/tr.sql-check

&CRON_TIME_SQL [v(d.cron)]=|||00 04 08 12 16 20|00|

&tr.sql-check [v(d.bc)]=@eval strcat(setr(R, sql(setr(Q, SELECT 1), v(d.default-row-delimiter), v(d.default-column-delimiter))), ulocal(tr.report_query_error, tr.sql-check, %qR, %qQ));

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ MySQL statements
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

&sql.get-exact-page-text [v(d.bd)]=SELECT `%vPtext`.`old_text` FROM `%vPpage` INNER JOIN `%vPslots` on `%vPpage`.`page_latest`=`%vPslots`.`slot_revision_id` INNER JOIN `%vPcontent` ON `%vPslots`.`slot_content_id`=`%vPcontent`.`content_id` INNER JOIN `%vPtext` ON SUBSTR(`%vPcontent`.`content_address`, 4)=`%vPtext`.`old_id` INNER JOIN `%vPcategorylinks` ON REPLACE(UPPER(CONVERT(`%vPcategorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`%vPpage`.`page_title` USING latin1)), '_', ' ') WHERE `%vPcategorylinks`.`cl_to`='[v(d.%1.namespace)]' AND `%vPcategorylinks`.`cl_type` = 'page' AND (REPLACE(LOWER(CONVERT(`%vPpage`.`page_title` USING utf8mb4)), "_", " ") = '[ulocal(f.sanitize-where, %0)]' OR REPLACE(LOWER(CONVERT(`%vPpage`.`page_title` USING utf8mb4)), "_", " ") = '+[ulocal(f.sanitize-where, %0)]') AND `wiki_page`.`page_namespace` = [v(d.%1.namespace.id)]

&sql.get-exact-category-contents [v(d.bd)]=SELECT REPLACE(`%vPcategory`.`cat_title`, '_', ' ') FROM `%vPcategorylinks` INNER JOIN `%vPcategory` ON REPLACE(UPPER(CONVERT(`%vPcategorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`%vPcategory`.`cat_title` USING latin1)), '_', ' ') WHERE `%vPcategorylinks`.`cl_type`='subcat' AND REPLACE(LOWER(CONVERT(`%vPcategorylinks`.`cl_to` USING latin1)), '_', ' ') = '[ulocal(f.sanitize-where, %0)]' UNION SELECT DISTINCT `%vPpage`.`page_title` FROM `%vPcategorylinks` INNER JOIN `%vPpage` ON REPLACE(UPPER(CONVERT(`%vPcategorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`%vPpage`.`page_title` USING latin1)), '_', ' ') WHERE `%vPcategorylinks`.`cl_type`='page' AND REPLACE(LOWER(CONVERT(`%vPcategorylinks`.`cl_to` USING utf8mb4)), "_", " ") = '[ulocal(f.sanitize-where, %0)]'

&sql.get-similar-page-text [v(d.bd)]=SELECT `%vPtext`.`old_text` FROM `%vPpage` INNER JOIN `%vPslots` on `%vPpage`.`page_latest`=`%vPslots`.`slot_revision_id` INNER JOIN `%vPcontent` ON `%vPslots`.`slot_content_id`=`%vPcontent`.`content_id` INNER JOIN `%vPtext` ON SUBSTR(`%vPcontent`.`content_address`, 4)=`%vPtext`.`old_id` INNER JOIN `%vPcategorylinks` ON REPLACE(UPPER(CONVERT(`%vPcategorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`%vPpage`.`page_title` USING latin1)), '_', ' ') WHERE `%vPcategorylinks`.`cl_to`='[v(d.%1.namespace)]' AND `%vPcategorylinks`.`cl_type` = 'page' AND (REPLACE(LOWER(CONVERT(`%vPpage`.`page_title` USING utf8mb4)), "_", " ") LIKE '[ulocal(f.sanitize-where, %0)]\\\%' OR REPLACE(LOWER(CONVERT(`%vPpage`.`page_title` USING utf8mb4)), "_", " ") LIKE '+[ulocal(f.sanitize-where, %0)]\\\%') AND `wiki_page`.`page_namespace` = [v(d.%1.namespace.id)]

&sql.get-similar-category-contents [v(d.bd)]=SELECT REPLACE(`%vPcategory`.`cat_title`, '_', ' ') FROM `%vPcategorylinks` INNER JOIN `%vPcategory` ON REPLACE(UPPER(CONVERT(`%vPcategorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`%vPcategory`.`cat_title` USING latin1)), '_', ' ') WHERE `%vPcategorylinks`.`cl_type`='subcat' AND REPLACE(LOWER(CONVERT(`%vPcategorylinks`.`cl_to` USING latin1)), '_', ' ') LIKE '[ulocal(f.sanitize-where, %0)]\\\%' UNION SELECT DISTINCT `%vPpage`.`page_title` FROM `%vPcategorylinks` INNER JOIN `%vPpage` ON REPLACE(UPPER(CONVERT(`%vPcategorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`%vPpage`.`page_title` USING latin1)), '_', ' ') WHERE `%vPcategorylinks`.`cl_type`='page' AND (REPLACE(LOWER(CONVERT(`%vPcategorylinks`.`cl_to` USING utf8mb4)), "_", " ") LIKE '[ulocal(f.sanitize-where, %0)]\\\%' OR REPLACE(LOWER(CONVERT(`%vPcategorylinks`.`cl_to` USING utf8mb4)), "_", " ") LIKE '+[ulocal(f.sanitize-where, %0)]\\\%') AND `wiki_page`.`page_namespace` = [v(d.%1.namespace.id)]

&sql.get-namespace-main-categories [v(d.bd)]=SELECT DISTINCT REPLACE(`%vPpage`.`page_title`, '_', ' ') FROM `%vPcategorylinks` INNER JOIN `%vPpage` ON REPLACE(UPPER(CONVERT(`%vPcategorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`%vPpage`.`page_title` USING latin1)), '_', ' ') WHERE `%vPcategorylinks`.`cl_type`='subcat' AND `%vPcategorylinks`.`cl_to`='[v(d.%1.namespace)]'

&sql.get-namespace-category-name [v(d.bd)]=SELECT DISTINCT REPLACE(`%vPpage`.`page_title`, '_', ' ') FROM `%vPcategorylinks` INNER JOIN `%vPpage` ON REPLACE(UPPER(CONVERT(`%vPcategorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`%vPpage`.`page_title` USING latin1)), '_', ' ') WHERE `%vPcategorylinks`.`cl_type`='subcat' AND `%vPcategorylinks`.`cl_to`='[v(d.%1.namespace)]' AND CONVERT(LOWER(REPLACE(`%vPpage`.`page_title`, '_', ' ')) USING utf8mb4) LIKE '[ulocal(f.sanitize-where, %0)]\\\%'

&sql.namespace-text-search [v(d.bd)]=SELECT REPLACE(`%vPpage`.`page_title`, '_', ' ') FROM `%vPpage` INNER JOIN `%vPslots` on `%vPpage`.`page_latest`=`%vPslots`.`slot_revision_id` INNER JOIN `%vPcontent` ON `%vPslots`.`slot_content_id`=`%vPcontent`.`content_id` INNER JOIN `%vPtext` ON SUBSTR(`%vPcontent`.`content_address`, 4)=`%vPtext`.`old_id` INNER JOIN `%vPcategorylinks` ON REPLACE(UPPER(CONVERT(`%vPcategorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`%vPpage`.`page_title` USING latin1)), '_', ' ') WHERE `%vPcategorylinks`.`cl_to`='[v(d.%1.namespace)]' AND `%vPcategorylinks`.`cl_type` = 'page' AND REPLACE(LOWER(CONVERT(`%vPtext`.`old_text` USING utf8mb4)), "_", " ") LIKE '\\\%[ulocal(f.sanitize-where, %0)]\\\%' AND `wiki_page`.`page_namespace` = [v(d.%1.namespace.id)]

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Info functions
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

&f.get-page-topic [v(d.bf)]=trim(rest(finditem(%0, v(d.%1.topic.field)=, |), =), b, %r)

&f.get-page-short [v(d.bf)]=trim(rest(finditem(%0, v(d.%1.shortdesc.field)=, |), =), b, %r)

&f.get-page-detail [v(d.bf)]=trim(rest(finditem(%0, v(d.%1.detail.field)=, |), =), b, %r)

&f.get-page-example [v(d.bf)]=trim(rest(finditem(%0, v(d.%1.example.field)=, |), =), b, %r)

&f.get-page-links [v(d.bf)]=squish(trim(edit(iter(lnum(1, v(d.%1.link.count)), trim(rest(finditem(%0, strcat(v(d.%1.link.field), itext(0), =), |), =)),, |), %r,, _, %b), b, |), |)

&f.get-page-categories [v(d.bf)]=squish(trim(edit(iter(lnum(1, v(d.%1.category.count)), edit(trim(rest(finditem(%0, strcat(v(d.%1.category.field), itext(0), =), |), =)), %r,),, |), %%%}%%%},, _, %b), b, |), |)

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Work functions
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

&f.run-query [v(d.bf)]=strcat(setr(R, sql(setr(Q, ulocal(%0, lcstr(%1), %2)), v(d.default-row-delimiter), v(d.default-column-delimiter))), ulocal(tr.report_query_error, %0, %qR, %qQ))

&f.format-punctuation [v(d.bf)]=strcat(setq(0, %0), null(iter(strip(v(d.punctuation), %2), setq(0, iter(%q0, ulocal(%1, strcat(@@BREAK@@, itext(0), @@BREAK@@)), itext(0), itext(0))))), edit(%q0, @@BREAK@@,))

&f.format-paragraph [v(d.bf)]=iter(%0, ulocal(%1, itext(0)), %r%r, %r%r)

&f.format-tabs [v(d.bf)]=iter(%0, if(strmatch(itext(0), :*), strcat(edit(first(itext(0)), :, %t), rest(itext(0))), itext(0)), %r, %r)

&f.format-links [v(d.bf)]=edit(strcat(setq(1, 0), iter(edit(%0, %r, %b%r), if(cor(switch(itext(0), %%%[*, 1, %%%[%%%[*, 1, %[%[*, 1, %[*, 1, 0), t(%q1)), ansi(h, strcat(setq(L, edit(itext(0), %%%[,, %%%],, %[,, %],)), switch(itext(0), *News:*, news%b, *Help:*, +help%b,), edit(if(strmatch(%qL, *@@PIPE@@*), rest(%qL, @@PIPE@@), %qL), _, %b, News:,, Help:,)), setq(1, not(switch(itext(0), *%%%]*, 1, *%%%]%%%]*, 1, *%]%]*, 1, *%]*, 1, 0)))), itext(0)))), %b%r, %r)

&f.format-bold-italic [v(d.bf)]=edit(strcat(setq(2, 0), iter(edit(%0, %r, %b%r, %(, @@LEFTPAREN@@%b, %), %b@@RIGHTPAREN@@), if(cor(strmatch(itext(0), ''*), t(%q2)), ansi(h, trim(edit(itext(0), ''',,'',), b, '), setq(2, not(cand(strmatch(itext(0), *''*), cor(not(strmatch(trim(itext(0), b, %r), ''*)), strmatch(itext(0), ''*''*)))))), itext(0)))), %b%r, %r,@@LEFTPAREN@@%b, %(, %b@@RIGHTPAREN@@, %))

&f.format-cleanse-links [v(d.bf)]=edit(iter(%0, if(strmatch(itext(0), *%[*|*%]*), edit(itext(0), |, @@PIPE@@), itext(0)), =, =), strcat(@@PIPE@@, if(t(setr(X, v(d.%1.example.field))), %qX, setr(X, v(d.%1.link.field)))), |%qX)

&f.format-numbers [v(d.bf)]=if(strmatch(%0, *%r#*), strcat(setq(0, 1), iter(%0, if(cor(t(strlen(edit(itext(0), %r,))), eq(inum(0), 1)), strcat(itext(0), if(cand(cor(strmatch(itext(0), *%r),  eq(inum(0), 1)), neq(inum(0), words(%0, #))), %q0.%b), setq(0, inc(%q0)))), #, @@)), %0)

&f.format-bullets [v(d.bf)]=edit(%0, %r***, %r%b%b%b%b*, %r**, %r%b%b*)

&f.format-results [v(d.bf)]=ulocal(f.format-links, ulocal(f.format-bold-italic, ulocal(f.format-paragraph, ulocal(f.format-punctuation, ulocal(f.format-bullets, trim(trim(%0, b, lit(%r)))), f.format-tabs, :), f.format-numbers)))

&f.sanitize-where [v(d.bf)]=strcat(setq(0, edit(strip(%0, v(d.sanitize-where)), ', '')), setq(0, if(strmatch(%q0, * LIKE *), edit(%q0, *, %%%%), %q0)), edit(%q0, @@ESCAPE@@, \\\\))

&f.find-namespace-by-text [v(d.bf)]=if(t(setr(P, ulocal(f.run-query, sql.get-exact-page-text, %0, %2))), ulocal(layout.page, ulocal(f.cleanse-output, %qP, %2), %1, %2), if(t(setr(C, ulocal(f.run-query, sql.get-exact-category-contents, %0, %2))), ulocal(layout.list-category, ulocal(f.run-query, sql.get-namespace-category-name, %0, %2), %qC, %1, %2), if(t(setr(P, ulocal(f.run-query, sql.get-similar-page-text, %0, %2))), ulocal(layout.page, ulocal(f.cleanse-output, %qP, %2), %1, %2), if(t(setr(C, ulocal(f.run-query, sql.get-similar-category-contents, %0, %2))), ulocal(layout.list-category, ulocal(f.run-query, sql.get-namespace-category-name, %0, %2), %qC, %1, %2), if(t(setr(S, ulocal(f.run-query, sql.namespace-text-search, %0, %2))), ulocal(layout.list-category, capstr(%2) files containing '%0', %qS, %1, %2), alert(Error) No %2 files found for '%0' Try [switch(%2, news, %2, +%2)]/search %0.)))))

&f.search-namespace-by-text [v(d.bf)]=if(t(setr(S, ulocal(f.run-query, sql.namespace-text-search, %0, %2))), ulocal(layout.list-category, capstr(%2) files containing '%0', %qS, %1, %2), alert(Error) No %2 files found for '%0' Try [switch(%2, news, %2, +%2)]/search %0.)

&f.cleanse-output [v(d.bd)]=edit(translate(ulocal(f.format-cleanse-links, first(%0, v(d.default-row-delimiter)), %1), p), lit(%%R), %%R, lit(%%T), %%T, %r%r%r, %r%r, lit(%(), %(, lit(%)), %), \\\\\\\\, \\\\, %%t, %T, <blockquote>,, </blockquote>,,<br>, %r, <br/>, %r, <br />, %r, lit(%r), %r, lit(%t), %t, lit(%b), %b, %%%%, %%)

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Layouts
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

&layout.examples [v(d.bf)]=if(t(setr(E, ulocal(f.format-results, ulocal(f.get-page-example, %0, %2)))), strcat(%r, divider(Commands, %1), %r, formattext(%qE%r, 0, %1)))

&layout.see_also [v(d.bf)]=if(t(setr(A, ulocal(f.get-page-links, %0, %2))), strcat(%r, formattext(strcat(%chOther topics:%cn, %b, ulocal(layout.list, %qA)), 0, %1)))

&layout.categories [v(d.bf)]=if(t(setr(A, ulocal(f.get-page-categories, %0, %2))), strcat(%r, formattext(strcat(%r, ansi(h, plural(words(%qA, |), Category:, Categories:)), %b, ulocal(layout.list, %qA)), 0, %1)))

&layout.wiki_link [v(d.bf)]=formattext(strcat(%r, %chWiki:%cn, %b, v(d.wiki-url), v(d.%2.namespace), :, edit(trim(%3), %b, _)), 0, %1)

&layout.page-text [v(d.bf)]=strcat(setq(P, ulocal(f.format-results, ulocal(f.get-page-detail, %0, %3))), setq(S, ulocal(f.get-page-short, %0, %3)), formattext(strcat(%qS, if(t(%qS), %r%r, %r), %qP, %r), 0, %1))

&layout.page [v(d.bf)]=strcat(header(setr(T, ulocal(f.get-page-topic, %0, %2)), %1), %r, ulocal(layout.page-text, %0, %1, %qT, %2), ulocal(layout.examples, %0, %1, %2), ulocal(layout.see_also, %0, %1, %2), ulocal(layout.categories, %0, %1, %2), %r, ulocal(layout.wiki_link, %0, %1, %2, %qT), %r, footer(switch(%2, news, %2, +%2) for more, %1))

&layout.list-category [v(d.bf)]=strcat(header(%0, %2), %r, formatcolumns(edit(%1, _, %b), v(d.default-row-delimiter), %2) %r, footer(switch(%3, news, %3, +%3) <file name> for more., %2))

&layout.namespace-categories [v(d.bf)]=if(t(setr(P, ulocal(f.run-query, sql.get-namespace-main-categories,, %2))), ulocal(layout.list-category, capstr(%2) categories, %qP, %0, %2), alert(Error) No %2 files found.)

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Commands
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

&c.+help_text [v(d.bc)]=$+help *:@pemit %#=ulocal(f.find-namespace-by-text, %0, %#, help)

&c.+help/search_text [v(d.bc)]=$+help/s* *:@pemit %#=ulocal(f.search-namespace-by-text, %1, %#, help)

&c.+help [v(d.bc)]=$+help:@pemit %#=ulocal(layout.namespace-categories, %#,, help)
