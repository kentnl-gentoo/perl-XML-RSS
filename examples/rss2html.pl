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
<head><title>$rss->{rss}->{'channel'}->{'title'}</title></head>
<body>
<h2>
<a href="$rss->{rss}->{'image'}->{'link'}">
<img src="$rss->{rss}->{'image'}->{'url'}" alt="$rss->{rss}->{'image'}->{'title'}" border="0">
</a>
<a href="$rss->{rss}->{'channel'}->{'link'}">$rss->{rss}->{'channel'}->{'title'}: </a>
$rss->{rss}->{'channel'}->{'description'}
</h2>
HTML

    foreach my $item (@{$rss->{rss}->{'items'}}) {
	next unless defined($item->{'title'}) && defined($item->{'link'});
	print "<a href=\"$item->{'link'}\">$item->{'title'}</a><BR>\n";
    }
}

if (defined($rss->{rss}->{'textinput'})) {
    print <<HTML;
<form method="get" action="$rss->{rss}->{'textinput'}->{'link'}">
$rss->{rss}->{'textinput'}->{'description'}<BR>
<B>$rss->{rss}->{'textinput'}->{'title'}: 
<input type="text" name="$rss->{rss}->{'textinput'}->{'name'}">
</form>
HTML
}

print "</body></html>";
