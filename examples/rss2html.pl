#!/usr/bin/perl -w
use strict;
use XML::RSS;

die "Usage: rss2html.pl <RSS file>\n" unless @ARGV == 1;
my $file = shift;
die "File \"$file\" does't exist.\n" unless -e $file;
my $rss = new XML::RSS;
$rss->parsefile($file);
&print_html($rss);

sub print_html {
    my $rss = shift;
    print <<HTML;
<html>
<head><title>$rss->{'channel'}->{'title'}</title></head>
<body>
<h2>
HTML
    if ($rss->{'image'}->{'link'}) {
	print <<HTML;
<a href="$rss->{'image'}->{'link'}">
<img src="$rss->{'image'}->{'url'}" alt="$rss->{'image'}->{'title'}" border="0">
</a>
HTML
    print <<HTML;
<a href="$rss->{'channel'}->{'link'}">$rss->{'channel'}->{'title'}</a></h3>
<H3>$rss->{'channel'}->{'description'}</H3>
</h2>
HTML

    foreach my $item (@{$rss->{'items'}}) {
	next unless defined($item->{'title'}) && defined($item->{'link'});
	print "<a href=\"$item->{'link'}\">$item->{'title'}</a><BR>\n";
    }
}

if ($rss->{'textinput'}->{'title'}) {
    print <<HTML;
<form method="get" action="$rss->{'textinput'}->{'link'}">
$rss->{'textinput'}->{'description'}<BR>
<B>$rss->{'textinput'}->{'title'}: 
<input type="text" name="$rss->{'textinput'}->{'name'}">
</form>
HTML
}

    if ($rss->{'channel'}->{'copyright'}) {
	print <<HTML;
<p>$rss->{'channel'}->{'copyright'}</p>
HTML
    }
}
print "</body></html>";
