# 
# Copyright (c) 1999 Jonathan Eisenzopf <eisen@pobox.com>
# XML::RSS is free software. You can redistribute it and/or
# modify it under the same terms as Perl itself.

package XML::RSS;

use strict;
use Carp;
use XML::Parser;
use vars qw($VERSION $AUTOLOAD @ISA);

$VERSION = '0.01';
@ISA = qw(XML::Parser);

my %ok_fields = (
    channel => { 
	title       => '',
	description => '',
	link        => '' 
	},
    image  => { 
	title => '',
	url   => '',
	link  => '' 
	},
    textinput => { 
	title       => '',
	description => '',
	name        => '',
	link        => ''
	},
    items => [],
    num_items => 0
);

my $_REQ = {
    channel => {"title",40,"description",500,"link",500},
    image => {"title",40,"url",500,"link",500},
    item => {"title",100,"link",500},
    textinput => {"title",40,"description",100,"name",500,"link",500}
};

sub new {
    my $class = shift;
    my %_fields = %ok_fields;
    my $self = $class->SUPER::new(Handlers => { Char  => \&handle_char});
    bless ($self,$class);
    $self->{rss} = \%_fields;
    return $self;
}

sub add_item {
    my $self = shift;
    my $hash = {@_};

    # make sure we have a title and link
    croak "title and link elements are required" 
	unless ($hash->{title} && $hash->{link});

    # check string lengths
    croak "title cannot exceed 100 characters in length" if (length($hash->{title}) > 100);
    croak "link cannot exceed 500 characters in length" if (length($hash->{link}) > 500);

    # make sure there aren't already 15 items
    croak "total items cannot exceed 15 " if (@{$self->{rss}->{items}} >= 15);

    # add the item to the list
    if (defined($hash->{mode}) && $hash->{mode} eq 'insert') {
	unshift (@{$self->{rss}->{items}}, $hash);
    } else {
	push (@{$self->{rss}->{items}}, $hash);
    }

    # return reference to the list of items
    return $self->{rss}->{items};
}

sub as_string {
    my $self = shift;
    my $output;

    # XML declaration
    $output .= '<?xml version="1.0"?>'."\n";

    # RDF root element
    $output .= '<rdf:RDF'."\n".'xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"'."\n";
    $output .= 'xmlns="http://my.netscape.com/rdf/simple/0.9/">'."\n\n";

    # channel element
    $output .= '<channel>'."\n";
    $output .= '<title>'.$self->{rss}->{channel}->{title}.'</title>'."\n";
    $output .= '<link>'.$self->{rss}->{channel}->{link}.'</link>'."\n";
    $output .= '<description>'.$self->{rss}->{channel}->{description}.'</description>'."\n";
    $output .= '</channel>'."\n\n";

    # image element
    if ($self->{rss}->{image}->{url}) {
	$output .= '<image>'."\n";
	$output .= '<title>'.$self->{rss}->{image}->{title}.'</title>'."\n";
	$output .= '<url>'.$self->{rss}->{image}->{url}.'</url>'."\n";
	$output .= '<link>'.$self->{rss}->{image}->{link}.'</link>'."\n";
	$output .= '</image>'."\n\n";
    }

    # print item elements
    foreach my $item (@{$self->{rss}->{items}}) {
	if ($item->{title}) {
	    $output .= '<item>'."\n";
	    $output .= '<title>'.$item->{title}.'</title>'."\n";
	    $output .= '<link>'.$item->{link}.'</link>'."\n";
	    $output .= '</item>'."\n\n";
	}
    }

    # textinput element
    if ($self->{rss}->{textinput}->{link}) {
	$output .= '<textinput>'."\n";
	$output .= '<title>'.$self->{rss}->{textinput}->{title}.'</title>'."\n";
	$output .= '<description>'.$self->{rss}->{textinput}->{description}.'</description>'."\n";
	$output .= '<name>'.$self->{rss}->{textinput}->{name}.'</name>'."\n";
	$output .= '<link>'.$self->{rss}->{textinput}->{link}.'</link>'."\n";
	$output .= '</textinput>'."\n\n";
    }

    # end rdf element
    $output .= '</rdf:RDF>';

    return $output;
}

sub handle_char {
    my ($self,$cdata) = (@_);
    return unless $cdata =~ /\S+/;
    if ($self->within_element("channel")) {
	$self->{rss}->{channel}->{$self->current_element} = $cdata;
    } elsif ($self->within_element("image")) {
	$self->{rss}->{image}->{$self->current_element} = $cdata;
    } elsif ($self->within_element("item")) {
	$self->{num_items}++ if $self->current_element eq 'title';
	$self->{rss}->{'items'}->[$self->{num_items}]->{$self->current_element} = $cdata;
    } elsif ($self->within_element("textinput")) {
	$self->{rss}->{'textinput'}->{$self->current_element} = $cdata;
    }
}


sub parse { 
    my $self = shift;
    $self->SUPER::parse(shift);
}

sub parsefile {
    my $self = shift;
    $self->SUPER::parsefile(shift);
}

sub save {
    my ($self,$file) = @_;
    open(OUT,">$file") || croak "Cannot open file $file for write: $!";
    print OUT $self->as_string;
    close OUT;
}

sub AUTOLOAD {
    my $self = shift;
    my $type = ref($self) || croak "$self is not an object\n";
    my $name = $AUTOLOAD;
    $name =~ s/.*://;
    
    croak "Unregistered entity: Can't access $name field in object of class $type"
	unless (exists $self->{rss}->{$name});

    # return reference to RSS structure
    if (@_ == 1) {
	return $self->{rss}->{$name}->{$_[0]} if defined $self->{rss}->{$name}->{$_[0]};
	
    # we're going to set values here
    } elsif (@_ > 1) {
	my %hash = @_;
	
	# make sure we have required elements and correct lengths
	foreach my $key (keys(%{$_REQ->{$name}})) {
	    croak "$key is required" unless defined($hash{$key});
	    croak "$key cannot exceed ".$_REQ->{$name}->{$key}." characters in length"
		unless length($hash{$key}) < $_REQ->{$name}->{$key};
	}

	# store data in object
	foreach my $key (keys(%hash)) {
	    $self->{rss}->{$name}->{$key} = $hash{$key};
	}
	return $self->{rss}->{$name};
	
    # otherwise, just return a reference to the whole thing
    } else {
	return $self->{rss}->{$name};
    }
    return 0;
}


1;
__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

XML::RSS - creates and updates RSS files

=head1 SYNOPSIS

 # create an RSS file
 use XML::RSS;
 $rss->channel(title => "freshmeat.net",
               link  => "http://freshmeat.net",
               description => "the one-stop-shop for all your Linux software needs"
               );

 $rss->image(title => "freshmeat.net",
             url   => "http://freshmeat.net/images/fm.mini.jpg",
             link  => "http://freshmeat.net"
             );

 $rss->add_item(title => "GTKeyboard 0.85",
                link  => "http://freshmeat.net/news/1999/06/21/930003829.html"
                );

 $rss->textinput(title => "quick finder",
                 description => "Use the text input below to search freshmeat",
                 name  => "query",
                 link  => "http://core.freshmeat.net/search.php3"
                 );

 # print the RSS as a string
 print $rss->as_string;

 # or save it to a file
 $rss->save("fm.rdf");

 # insert an item into an RSS file and removes the oldest item if
 # there are already 15 items
 my $rss = new XML::RSS;
 $rss->parsefile("fm.rdf");
 pop(@{$rss->{rss}->{'items'}}) if (@{$rss->{rss}->{'items'}} == 15);
 $rss->add_item(title => "MpegTV Player (mtv) 1.0.9.7",
                link  => "http://freshmeat.net/news/1999/06/21/930003958.html",
                mode  => 'insert'
                );

 # parse a string instead of a file
 $rss->parse($string);

 # print the title and link of each RSS item
 foreach my $item (@{$rss->{rss}->{'items'}}) {
     print "title: $item->{'title'}\n";
     print "link: $item->{'link'}\n\n";
 }

=head1 DESCRIPTION

This module provides a basic framework for creating and maintaining 
RDF Site Summary (RSS) files. This distribution also contains several 
examples that allow you to generate HTML from an RSS file. 
This might be helpful if you want to include news feeds on your Web 
site from sources like Slashot and Freshmeat.

RSS is primarily used by content authors who want to create a 
Netscape Netcenter channel, however, hat doesn't exclude us from using it
in other applications.
For example, you may want to distribute daily news headlines to partners and 
customers who convert it to some other format, like HTML.

For the most part the module adheres to the RSS spec as it exists at 
http://my.netscape.com/publish/help/quickstart.html. 
Unfortunately, the RSS spec also allows one to use any HTML entity without 
first declaring them. Since XML::RSS is based on XML::Parser, you
can only use the default XML entities.

=head1 METHODS

=over 4

=item new XML::RSS;

Constructor for XML::RSS. It returns a reference to an XML::RSS object.

=item add_item(title=>$title, link=>$link, mode=>$mode);

Adds an item to the XML::RSS object. B<mode> is optional. The default B<mode> 
is append, which adds the item to the end of the list. To insert an item, set the mode
to B<insert>. 

The items are stored in the array @{$obj->{rss}->{'items'}} where
B<$obj> is a reference to an XML::RSS object.

=item as_string;

Returns a string containing the RSS for the XML::RSS object. 

=item channel(title=>$title, link=>$link, description=>$desc);

Channel information is required for an RSS. The B<title> cannot
be more the 40 characters, the B<link> 500, and the B<description>
500.

To retreive the values of the channel, pass the name of the value
(title, link, or description) as the first and only argument
like so:

$title = channel('title');

=item image(title=>$title, url=>$url, link=>$link);

Adding an image is not required. B<url> is the URL of the
image, B<link> is the URL the image is linked to.

The method for retrieving the values for the image is the same as it
is for B<channel()>.

=item parse($string);

Parses an RDF Site Summary which is passed into B<parse()> as the first parameter.

=item parsefile($file);

Same as B<parse()> except it parses a file rather than a string.

=item save($file);

Saves the RSS to a specified file.

=item textinput(title=>$title, description=>$desc, name=>$name, link=>$link);

This RSS element is also optional. Using it allows users to submit a Query
to a program on a Web server via an HTML form. B<name> is the HTML form name
and B<link> is the URL to the program. Content is submitted using the GET
method.

Access to the B<textinput> values is the the same as B<channel()> and 
B<image()>.

=head1 AUTHOR

Jonathan Eisenzopf <eisen@pobox.com>

=head1 SEE ALSO

perl(1), XML::Parser(3).

=cut
