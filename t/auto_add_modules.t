# $Id: auto_add_modules.t,v 1.1 2003/01/18 01:57:00 comdog Exp $

use Test::More tests => 3;
use XML::RSS;

my $URL = 'http://freshmeat.net/backend/fm-releases-0.1.dtd';
my $TAG = 'fm';

my $rss = XML::RSS->new();
isa_ok( $rss, 'XML::RSS' );

$rss->parsefile( 'examples/freshmeat.rdf' );

#print STDERR Data::Dumper::Dumper( $rss );
use Data::Dumper;

ok( exists $rss->{modules}{$URL}, 'Freshmeat module exists' );
is( $rss->{modules}{$URL}, $TAG, 'Freshmeat module has right URI' );

