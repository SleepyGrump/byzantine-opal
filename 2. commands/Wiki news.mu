/*
All the caveats of Wiki +help.mu apply to this file, and then some. 

Install Wiki +help.mu - this code won't work without it.

In your Wiki's LocalSettings.php file, add the following lines, modified as necessary to fit your wiki:

define("NS_NEWS", 3000);
define("NS_NEWS_TALK", 3001);
$wgExtraNamespaces[NS_NEWS] = "News";
$wgExtraNamespaces[NS_NEWS_TALK] = "News_talk";
$wgContentNamespaces[] = 3000;
# This only matters if you're naming your new namespace "News". Skip otherwise.
$wgUrlProtocols = array_diff( $wgUrlProtocols, array( 'news:' ) );

If you already have news pages, follow one of the solutions listed here: https://www.mediawiki.org/wiki/Manual:Using_custom_namespaces#Dealing_with_existing_pages

*/


@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Settings
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

&d.news.topic.field [v(d.bd)]=topic

&d.news.shortdesc.field [v(d.bd)]=short

&d.news.detail.field [v(d.bd)]=detail

&d.news.link.field [v(d.bd)]=link

&d.news.link.count [v(d.bd)]=4

@@ The News namespace text.
&d.news.namespace [v(d.bd)]=News

@@ The News namespace ID.
&d.news.namespace.id [v(d.bd)]=3000

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Layouts
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

&layout.news-page [v(d.bf)]=strcat(header(ulocal(f.get-page-topic, %0), %1), %r, formattext(strcat(ulocal(f.get-page-short, %0), %r%r%t, ulocal(f.get-page-detail, %0)), 1, %1), ulocal(layout.see_also, %0, %1), %r, footer(news for more, %1))

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Commands
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

&c.news_text [v(d.bc)]=$news *:@pemit %#=ulocal(f.find-namespace-by-text, %0, %#, news)

&c.news/search_text [v(d.bc)]=$news/s* *:@pemit %#=ulocal(f.search-namespace-by-text, %1, %#, news)

&c.news [v(d.bc)]=$news:@pemit %#=ulocal(layout.namespace-categories, %#,, news)
