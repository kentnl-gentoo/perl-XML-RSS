#!/usr/bin/perl -w
# creates and prints RSS 1.0 file
# with mixed rss091 namespace elements
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

# notice that we're mixing in 0.91 elements freely. This is ok
# since 1.0 will support 0.91 elements via the rss091 namespace.
# You can mix and match at will. The module will automtically
# handle it.
$rss->channel(title          => 'freshmeat.net',
	      link           => 'http://freshmeat.net',
	      language       => 'en', 
	      description    => 'the one-stop-shop for all your Linux software needs',
	      rating         => '(PICS-1.1 "http://www.classify.org/safesurf/" 1 r (SS~~000 1))',
	      copyright      => 'Copyright 1999, Freshmeat.net',
	      pubDate        => 'Thu, 23 Aug 1999 07:00:00 GMT',
	      lastBuildDate  => 'Thu, 23 Aug 1999 16:20:26 GMT',
	      docs           => 'http://www.blahblah.org/fm.cdf',
	      managingEditor => 'scoop@freshmeat.net',
	      webMaster      => 'scoop@freshmeat.net'
	      );

$rss->image(title       => 'freshmeat.net',
	    url         => 'http://freshmeat.net/images/fm.mini.jpg',
	    link        => 'http://freshmeat.net',
	    width       => 88,
	    height      => 31,
	    description => 'This is the Freshmeat image stupid'
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
