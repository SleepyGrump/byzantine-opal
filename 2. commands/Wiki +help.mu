/*
This is designed for MediaWiki version 1.35. If you use an earlier version of MediaWiki, you would be better off using Thenomain's Wiki Help and News available at:

https://github.com/thenomain/Mu--Support-Systems/blob/master/Wiki%20Help%20and%20News.txt

This code requires the use of a Help Template. That's included in this repo under 3. help files/Help template.txt. All that matters is that the help file use the same template field positions and number of fields. If you change it you'll need to change the code in this file to match.

Template usage:

{{help|topic=+command|short=Short description.|detail=Slightly longer details.|example=
* Example 1
* Example 2
* Keep it short, their screens are only so big
* More examples
|link1=+command2|link2=+command3|link3=+command4|link4=|category1=Category_1|category2=Category_2}}


Implementing this template is up to you. Keep your help entries as simple as possible so that they translate into MU* code. Keep them under 8000 characters or the players won't be able to read them.

TODO: Make the search sub-categories list the name it resolved to.

*/

&sql.get-exact-page-text [v(d.bd)]=SELECT `text`.`old_text` FROM `page` INNER JOIN `slots` on `page`.`page_latest`=`slots`.`slot_revision_id` INNER JOIN `content` ON `slots`.`slot_content_id`=`content`.`content_id` INNER JOIN `text` ON SUBSTR(`content`.`content_address`, 4)=`text`.`old_id` INNER JOIN `categorylinks` ON REPLACE(UPPER(CONVERT(`categorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`page`.`page_title` USING latin1)), '_', ' ') WHERE `categorylinks`.`cl_to`='Help' AND `categorylinks`.`cl_type` = 'page' AND REPLACE(LOWER(CONVERT(`page`.`page_title` USING utf8mb4)), "_", " ") = '[ulocal(f.sanitize-where, %0)]'

&sql.get-exact-category-contents [v(d.bd)]=SELECT REPLACE(`category`.`cat_title`, '_', ' ') FROM `categorylinks` INNER JOIN `category` ON REPLACE(UPPER(CONVERT(`categorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`category`.`cat_title` USING latin1)), '_', ' ') WHERE `categorylinks`.`cl_type`='subcat' AND REPLACE(LOWER(CONVERT(`categorylinks`.`cl_to` USING latin1)), '_', ' ') = '[ulocal(f.sanitize-where, %0)]' UNION SELECT DISTINCT `page`.`page_title` FROM `categorylinks` INNER JOIN `page` ON REPLACE(UPPER(CONVERT(`categorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`page`.`page_title` USING latin1)), '_', ' ') WHERE `categorylinks`.`cl_type`='page' AND REPLACE(LOWER(CONVERT(`categorylinks`.`cl_to` USING utf8mb4)), "_", " ") = '[ulocal(f.sanitize-where, %0)]'

&sql.get-similar-page-text [v(d.bd)]=SELECT `text`.`old_text` FROM `page` INNER JOIN `slots` on `page`.`page_latest`=`slots`.`slot_revision_id` INNER JOIN `content` ON `slots`.`slot_content_id`=`content`.`content_id` INNER JOIN `text` ON SUBSTR(`content`.`content_address`, 4)=`text`.`old_id` INNER JOIN `categorylinks` ON REPLACE(UPPER(CONVERT(`categorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`page`.`page_title` USING latin1)), '_', ' ') WHERE `categorylinks`.`cl_to`='Help' AND `categorylinks`.`cl_type` = 'page' AND (REPLACE(LOWER(CONVERT(`page`.`page_title` USING utf8mb4)), "_", " ") LIKE '[ulocal(f.sanitize-where, %0)]\\\%' OR REPLACE(LOWER(CONVERT(`page`.`page_title` USING utf8mb4)), "_", " ") LIKE '+[ulocal(f.sanitize-where, %0)]\\\%')

&sql.get-similar-category-contents [v(d.bd)]=SELECT REPLACE(`category`.`cat_title`, '_', ' ') FROM `categorylinks` INNER JOIN `category` ON REPLACE(UPPER(CONVERT(`categorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`category`.`cat_title` USING latin1)), '_', ' ') WHERE `categorylinks`.`cl_type`='subcat' AND REPLACE(LOWER(CONVERT(`categorylinks`.`cl_to` USING latin1)), '_', ' ') LIKE '[ulocal(f.sanitize-where, %0)]\\\%' UNION SELECT DISTINCT `page`.`page_title` FROM `categorylinks` INNER JOIN `page` ON REPLACE(UPPER(CONVERT(`categorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`page`.`page_title` USING latin1)), '_', ' ') WHERE `categorylinks`.`cl_type`='page' AND (REPLACE(LOWER(CONVERT(`categorylinks`.`cl_to` USING utf8mb4)), "_", " ") LIKE '[ulocal(f.sanitize-where, %0)]\\\%' OR REPLACE(LOWER(CONVERT(`categorylinks`.`cl_to` USING utf8mb4)), "_", " ") LIKE '+[ulocal(f.sanitize-where, %0)]\\\%')

&sql.get-help-main-categories [v(d.bd)]=SELECT DISTINCT REPLACE(`page`.`page_title`, '_', ' ') FROM `categorylinks` INNER JOIN `page` ON REPLACE(UPPER(CONVERT(`categorylinks`.`cl_sortkey` USING latin1)), '_', ' ')=REPLACE(UPPER(CONVERT(`page`.`page_title` USING latin1)), '_', ' ') WHERE `categorylinks`.`cl_type`='subcat' AND `categorylinks`.`cl_to`='Help'

&f.get-exact-page-text [v(d.bf)]=strcat(setr(R, sql(setr(Q, ulocal(sql.get-exact-page-text, lcstr(%0))), v(d.default-row-delimeter), v(d.default-column-delimeter))), ulocal(tr.report_query_error, f.get-exact-page-text, %qR, %qQ))

&f.get-exact-category-contents [v(d.bf)]=strcat(setr(R, sql(setr(Q, ulocal(sql.get-exact-category-contents, lcstr(%0))), v(d.default-row-delimeter), v(d.default-column-delimeter))), ulocal(tr.report_query_error, f.get-exact-category-contents, %qR, %qQ))

&f.get-similar-page-text [v(d.bf)]=strcat(setr(R, sql(setr(Q, ulocal(sql.get-similar-page-text, lcstr(%0))), v(d.default-row-delimeter), v(d.default-column-delimeter))), ulocal(tr.report_query_error, f.get-similar-page-text, %qR, %qQ))

&f.get-similar-category-contents [v(d.bf)]=strcat(setr(R, sql(setr(Q, ulocal(sql.get-similar-category-contents, lcstr(%0))), v(d.default-row-delimeter), v(d.default-column-delimeter))), ulocal(tr.report_query_error, f.get-similar-category-contents, %qR, %qQ))

&f.get-help-main-categories [v(d.bf)]=strcat(setr(R, sql(setr(Q, v(sql.get-help-main-categories)), v(d.default-row-delimeter), v(d.default-column-delimeter))), ulocal(tr.report_query_error, f.get-help-main-categories, %qR, %qQ))

&f.get-page-topic [v(d.bf)]=trim(rest(extract(%0, 2, 1, |), =), b, %r)

&f.get-page-short [v(d.bf)]=trim(rest(extract(%0, 3, 1, |), =), b, %r)

&f.get-page-detail [v(d.bf)]=trim(rest(extract(%0, 4, 1, |), =), b, %r)

&f.get-page-example [v(d.bf)]=trim(rest(extract(%0, 5, 1, |), =), b, %r)

&f.get-page-links [v(d.bf)]=trim(edit(rest(extract(%0, 6, 4, |), =), link1=,, link2=,, link3=,, link4=,), b, %r)

&f.get-page-categories [v(d.bf)]=trim(rest(extract(%0, 10, 2, |), =), b, %r)

&layout.examples [v(d.bf)]=if(t(setr(E, ulocal(f.get-page-example, %0))), strcat(divider(Examples, %1), %r, formattext(%qE, 0, %1)))

&layout.see_also [v(d.bf)]=if(t(setr(A, ulocal(f.get-page-links, %0))), formattext(strcat(%r, More +help:, %b, itemize(%qA, |)), 0, %1))

&layout.help-page [v(d.bf)]=strcat(header(ulocal(f.get-page-topic, %0), %1), %r, formattext(strcat(ulocal(f.get-page-short, %0), %r%r, ulocal(f.get-page-detail, %0)), 1, %1), %r, ulocal(layout.examples, %0, %1), %r, ulocal(layout.see_also, %0, %1), %r, footer(+help for more, %1))

&f.format-results [v(d.bf)]=edit(trim(trim(translate(%0, p), b, lit(%r))), lit(%r), %r, %r%r%r, %r%r, lit(%(), %(, lit(%)), %), lit(%[), %[, lit(%]), %])

&layout.list-category [v(d.bf)]=strcat(header(%0, %2), %r, formatcolumns(%1, v(d.default-row-delimeter), %2) %r, footer(+help <file name> for more., %2))

&f.find-help-by-text [v(d.bf)]=if(t(setr(P, ulocal(f.get-exact-page-text, %0))), ulocal(layout.help-page, ulocal(f.format-results, %qP), %1), if(t(setr(C, ulocal(f.get-exact-category-contents, %0))), ulocal(layout.list-category, Help files under '%0', %qC, %1), if(t(setr(P, ulocal(f.get-similar-page-text, %0))), ulocal(layout.help-page, ulocal(f.format-results, %qP), %1), if(t(setr(C, ulocal(f.get-similar-category-contents, %0))), ulocal(layout.list-category, Help files under '%0', %qC, %1), alert(Error) No results found for '%0'.))))

&layout.help-categories [v(d.bf)]=if(t(setr(P, ulocal(f.get-help-main-categories))), ulocal(layout.list-category, Help categories, %qP, %0), alert(Error) No help files found.)

&c.+help_text [v(d.bc)]=$+help *:@pemit %#=ulocal(f.find-help-by-text, %0, %#)

&c.+help [v(d.bc)]=$+help:@pemit %#=ulocal(layout.help-categories, %#)
