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

You could basically duplicate this process for anything you want to show on the MU* that's stored on the wiki, so long as the wiki pages use the templates.

*/

@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@
@@ Commands
@@ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ @@

&c.news_text [v(d.bc)]=$news *:@pemit %#=ulocal(f.find-namespace-by-text, %0, %#, news)

&c.news/search_text [v(d.bc)]=$news/s* *:@pemit %#=ulocal(f.search-namespace-by-text, %1, %#, news)

&c.news [v(d.bc)]=$news:@pemit %#=ulocal(layout.namespace-categories, %#,, news)

&c.+news [v(d.bc)]=$+news*:@force %#=news%0;
