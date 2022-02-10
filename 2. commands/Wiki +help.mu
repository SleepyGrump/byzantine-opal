/*
This is designed for MediaWiki version 1.35. If you use an earlier version of MediaWiki, you would be better off using Thenomain's Wiki Help and News available at:

https://github.com/thenomain/Mu--Support-Systems/blob/master/Wiki%20Help%20and%20News.txt

This code requires the use of a Help Template. That's included in this repo under 3. help files/Help template.txt. All that matters is that the help file use the same template field positions and number of fields. If you change it you'll need to change the code in this file to match.

Sample template using the one in "3. help files":

{{help|topic=+command|short=Short description.|detail=Slightly longer details.|example=
* Example 1
* Example 2
* Keep it short, their screens are only so big
* More examples
|link1=+command2|link2=+command3|link3=+command4|link4=|category1=Category_1|category2=Category_2}}



Implementing this template is up to you. Keep your help entries as simple as possible so that they translate into MU* code. Keep them under 8000 characters or the players won't be able to read them.

TODO: Make the search sub-categories list the name it resolved to.

TODO: BUG: on new game, lots of errors get thrown to the Monitor channel when user hits +help and there's no DB set up.

*/

@@ Your prefix, if any:
&vP [v(d.bd)]=wiki_

&sql.get-exact-page-text [v(d.bd)]=SELECT `%vPtext`.`old_text` FROM `%vPpage` INNER JOIN `%vPslots` on `%vPpage`.`page_latest`=`%vPslots`.`slot_revision_id` INNER JOIN `%vPcontent` ON `%vPslots`.`slot_content_id`=`%vPcontent`.`content_id` INNER JOIN `%vPtext` ON SUBSTR(`%vPcontent`.`content_address`, 4)=`%vPtext`.`old_id` INNER JOIN `%vPcategorylinks` ON REPLACE(UPPER(CONVERT(`%vPcategorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`%vPpage`.`page_title` USING latin1)), '_', ' ') WHERE `%vPcategorylinks`.`cl_to`='Help' AND `%vPcategorylinks`.`cl_type` = 'page' AND REPLACE(LOWER(CONVERT(`%vPpage`.`page_title` USING utf8mb4)), "_", " ") = '[ulocal(f.sanitize-where, %0)]'

&sql.get-exact-category-contents [v(d.bd)]=SELECT REPLACE(`%vPcategory`.`cat_title`, '_', ' ') FROM `%vPcategorylinks` INNER JOIN `%vPcategory` ON REPLACE(UPPER(CONVERT(`%vPcategorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`%vPcategory`.`cat_title` USING latin1)), '_', ' ') WHERE `%vPcategorylinks`.`cl_type`='subcat' AND REPLACE(LOWER(CONVERT(`%vPcategorylinks`.`cl_to` USING latin1)), '_', ' ') = '[ulocal(f.sanitize-where, %0)]' UNION SELECT DISTINCT `%vPpage`.`page_title` FROM `%vPcategorylinks` INNER JOIN `%vPpage` ON REPLACE(UPPER(CONVERT(`%vPcategorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`%vPpage`.`page_title` USING latin1)), '_', ' ') WHERE `%vPcategorylinks`.`cl_type`='page' AND REPLACE(LOWER(CONVERT(`%vPcategorylinks`.`cl_to` USING utf8mb4)), "_", " ") = '[ulocal(f.sanitize-where, %0)]'

&sql.get-similar-page-text [v(d.bd)]=SELECT `%vPtext`.`old_text` FROM `%vPpage` INNER JOIN `%vPslots` on `%vPpage`.`page_latest`=`%vPslots`.`slot_revision_id` INNER JOIN `%vPcontent` ON `%vPslots`.`slot_content_id`=`%vPcontent`.`content_id` INNER JOIN `%vPtext` ON SUBSTR(`%vPcontent`.`content_address`, 4)=`%vPtext`.`old_id` INNER JOIN `%vPcategorylinks` ON REPLACE(UPPER(CONVERT(`%vPcategorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`%vPpage`.`page_title` USING latin1)), '_', ' ') WHERE `%vPcategorylinks`.`cl_to`='Help' AND `%vPcategorylinks`.`cl_type` = 'page' AND (REPLACE(LOWER(CONVERT(`%vPpage`.`page_title` USING utf8mb4)), "_", " ") LIKE '[ulocal(f.sanitize-where, %0)]\\\%' OR REPLACE(LOWER(CONVERT(`%vPpage`.`page_title` USING utf8mb4)), "_", " ") LIKE '+[ulocal(f.sanitize-where, %0)]\\\%')

&sql.get-similar-category-contents [v(d.bd)]=SELECT REPLACE(`%vPcategory`.`cat_title`, '_', ' ') FROM `%vPcategorylinks` INNER JOIN `%vPcategory` ON REPLACE(UPPER(CONVERT(`%vPcategorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`%vPcategory`.`cat_title` USING latin1)), '_', ' ') WHERE `%vPcategorylinks`.`cl_type`='subcat' AND REPLACE(LOWER(CONVERT(`%vPcategorylinks`.`cl_to` USING latin1)), '_', ' ') LIKE '[ulocal(f.sanitize-where, %0)]\\\%' UNION SELECT DISTINCT `%vPpage`.`page_title` FROM `%vPcategorylinks` INNER JOIN `%vPpage` ON REPLACE(UPPER(CONVERT(`%vPcategorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`%vPpage`.`page_title` USING latin1)), '_', ' ') WHERE `%vPcategorylinks`.`cl_type`='page' AND (REPLACE(LOWER(CONVERT(`%vPcategorylinks`.`cl_to` USING utf8mb4)), "_", " ") LIKE '[ulocal(f.sanitize-where, %0)]\\\%' OR REPLACE(LOWER(CONVERT(`%vPcategorylinks`.`cl_to` USING utf8mb4)), "_", " ") LIKE '+[ulocal(f.sanitize-where, %0)]\\\%')

&sql.get-help-main-categories [v(d.bd)]=SELECT DISTINCT REPLACE(`%vPpage`.`page_title`, '_', ' ') FROM `%vPcategorylinks` INNER JOIN `%vPpage` ON REPLACE(UPPER(CONVERT(`%vPcategorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`%vPpage`.`page_title` USING latin1)), '_', ' ') WHERE `%vPcategorylinks`.`cl_type`='subcat' AND `%vPcategorylinks`.`cl_to`='Help'

&f.get-exact-page-text [v(d.bf)]=strcat(setr(R, sql(setr(Q, ulocal(sql.get-exact-page-text, lcstr(%0))), v(d.default-row-delimeter), v(d.default-column-delimeter))), ulocal(tr.report_query_error, f.get-exact-page-text, %qR, %qQ))

&f.get-exact-category-contents [v(d.bf)]=strcat(setr(R, sql(setr(Q, ulocal(sql.get-exact-category-contents, lcstr(%0))), v(d.default-row-delimeter), v(d.default-column-delimeter))), ulocal(tr.report_query_error, f.get-exact-category-contents, %qR, %qQ))

&f.get-similar-page-text [v(d.bf)]=strcat(setr(R, sql(setr(Q, ulocal(sql.get-similar-page-text, lcstr(%0))), v(d.default-row-delimeter), v(d.default-column-delimeter))), ulocal(tr.report_query_error, f.get-similar-page-text, %qR, %qQ))

&f.get-similar-category-contents [v(d.bf)]=strcat(setr(R, sql(setr(Q, ulocal(sql.get-similar-category-contents, lcstr(%0))), v(d.default-row-delimeter), v(d.default-column-delimeter))), ulocal(tr.report_query_error, f.get-similar-category-contents, %qR, %qQ))

&f.get-help-main-categories [v(d.bf)]=strcat(setr(R, sql(setr(Q, v(sql.get-help-main-categories)), v(d.default-row-delimeter), v(d.default-column-delimeter))), ulocal(tr.report_query_error, f.get-help-main-categories, %qR, %qQ))

&f.get-page-topic [v(d.bf)]=trim(rest(extract(%0, 2, 1, |), =), b, %r)

&f.get-page-short [v(d.bf)]=trim(rest(extract(%0, 3, 1, |), =), b, %r)

&f.get-page-detail [v(d.bf)]=trim(rest(extract(%0, 4, 1, |), =), b, %r)

&f.get-page-example [v(d.bf)]=trim(rest(extract(%0, 5, 1, |), =), b, %r)

&f.get-page-links [v(d.bf)]=trim(squish(edit(rest(extract(%0, 6, 4, |), =), link1=,, link2=,, link3=,, link4=,), |), b, %r)

&f.get-page-categories [v(d.bf)]=trim(rest(extract(%0, 10, 2, |), =), b, %r)

&layout.examples [v(d.bf)]=if(t(setr(E, ulocal(f.get-page-example, %0))), strcat(divider(Examples, %1), %r, formattext(%qE, 0, %1)))

&layout.see_also [v(d.bf)]=if(t(setr(A, ulocal(f.get-page-links, %0))), formattext(strcat(%r, More +help:, %b, itemize(%qA, |)), 0, %1))

&layout.help-page [v(d.bf)]=strcat(header(ulocal(f.get-page-topic, %0), %1), %r, formattext(strcat(ulocal(f.get-page-short, %0), %r%r, ulocal(f.get-page-detail, %0)), 1, %1), %r, ulocal(layout.examples, %0, %1), %r, ulocal(layout.see_also, %0, %1), %r, footer(+help for more, %1))

&f.format-results [v(d.bf)]=edit(trim(trim(translate(%0, p), b, lit(%r))), lit(%r), %r, %r%r%r, %r%r, lit(%(), %(, lit(%)), %), lit(%[), %[, lit(%]), %], ''', ansi(first(themecolors()), *), '', ansi(first(themecolors()), /))

&layout.list-category [v(d.bf)]=strcat(header(%0, %2), %r, formatcolumns(%1, v(d.default-row-delimeter), %2) %r, footer(+help <file name> for more., %2))

&f.find-help-by-text [v(d.bf)]=if(t(setr(P, ulocal(f.get-exact-page-text, %0))), ulocal(layout.help-page, ulocal(f.format-results, %qP), %1), if(t(setr(C, ulocal(f.get-exact-category-contents, %0))), ulocal(layout.list-category, Help files under '%0', %qC, %1), if(t(setr(P, ulocal(f.get-similar-page-text, %0))), ulocal(layout.help-page, ulocal(f.format-results, %qP), %1), if(t(setr(C, ulocal(f.get-similar-category-contents, %0))), ulocal(layout.list-category, Help files under '%0', %qC, %1), alert(Error) No results found for '%0'.))))

&layout.help-categories [v(d.bf)]=if(t(setr(P, ulocal(f.get-help-main-categories))), ulocal(layout.list-category, Help categories, %qP, %0), alert(Error) No help files found.)

&c.+help_text [v(d.bc)]=$+help *:@pemit %#=ulocal(f.find-help-by-text, %0, %#)

&c.+help [v(d.bc)]=$+help:@pemit %#=ulocal(layout.help-categories, %#)
