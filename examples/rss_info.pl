#!/usr/bin/perl -w
# channel_info.pl
# print channel info
use lib '.';
use strict;
use XML::RSS;

my $rss = new XML::RSS;
$rss->parsefile(shift);

print "XML encoding: ".$rss->encoding."\n";
print "RSS Version: ".$rss->version."\n";
print "Title: ".$rss->channel('title')."\n";
print "Language: ".$rss->channel('language')."\n";
print "Rating: ".$rss->channel('rating')."\n";
print "Copright: ".$rss->channel('copyright')."\n";
print "Publish Date: ".$rss->channel('pubDate')."\n";
print "Last Build Date: ".$rss->channel('lastBuildDate')."\n";
print "CDF URL: ".$rss->channel('docs')."\n";