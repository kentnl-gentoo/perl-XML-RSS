#!/usr/bin/perl -w
# creates and prints RSS 1.0 file
# This is an example of using the XML::RSS
# module to create an RSS file with all
# the trimmings so you can see what elements
# are available.

use strict;
use XML::RSS;

my $rss = new XML::RSS (positioning => 1,     # if we set this to 0, it would
			                      # not add the position attribute
			                      # in item elements

			output      => '1.0', # you can also pick 0.9 or 0.91
                                              # as the output format

			encoding    => 'ISO-8859-1'); # default it UTF8

$rss->channel(title          => 'freshmeat.net',
	      link           => 'http://freshmeat.net',
	      description    => 'the one-stop-shop for all your Linux software needs'
	      );

$rss->image(title       => 'freshmeat.net',
	    url         => 'http://freshmeat.net/images/fm.mini.jpg',
	    link        => 'http://freshmeat.net'
	    );

$rss->add_item(title       => 'kdbg 1.0beta2',
	       link        => 'http://www.freshmeat.net/news/1999/08/23/935449823.html',
	       description => 'KDbg is a graphical user interface to gdb, the GNU debugger. It provides an intuitive interface for setting breakpoints, inspecting variables, and stepping through code.'
	       );

$rss->add_item(title => 'HTML-Tree 1.7',
	       link        => 'http://www.freshmeat.net/news/1999/08/23/935449856.html',
	       description => 'HTML-Tree is a Perl program that recursively decends directories, and creates a web-page based graphical map of HTML pages on a webserver.'
	       );

$rss->textinput(title       => "quick finder",
		description => "Use the text input below to search freshmeat",
		name        => "query",
		link        => "http://core.freshmeat.net/search.php3"
		);

print $rss->as_string;
