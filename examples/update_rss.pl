#!/usr/bin/perl -w
# update_rss.pl
# Adds a new item to the RSS file
use lib '.';
use strict;
use XML::RSS;

my $rss = new XML::RSS (version => '0.9');
$rss->parsefile("fm.rdf");

$rss->add_item(title => "MpegTV Player (mtv) 1.0.9.7",
               link  => "http://freshmeat.net/news/1999/06/21/930003958.html",
	       mode => 'insert'
	       );

$rss->save("fm2.rdf");
