# 
# Copyright (c) 2000 Jonathan Eisenzopf <eisen@pobox.com>
# XML::RSS is free software. You can redistribute it and/or
# modify it under the same terms as Perl itself.

package XML::RSS;

use strict;
use Carp;
use XML::Parser;
use vars qw($VERSION $AUTOLOAD @ISA);

$VERSION = '0.9';
@ISA = qw(XML::Parser);

my %v0_9_ok_fields = (
    channel => { 
	title       => '',
	description => '',
	link        => '',
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
    num_items => 0,
    version         => '',
    encoding        => ''
);

my %v0_9_1_ok_fields = (
    channel => { 
	title          => '',
	copyright      => '',
	description    => '',
	docs           => '',
	language       => '',
	lastBuildDate  => '',
	'link'         => '',
	managingEditor => '',
	pubDate        => '',
	rating         => '',
	webMaster      => ''
	},
    image  => { 
	title       => '',
	url         => '',
	'link'      => '',
	width       => '',
	height      => '',
	description => ''
	},
    skipDays  => {
	day         => ''
	},
    skipHours => {
	hour        => ''
	},
    textinput => {
	title       => '',
	description => '',
	name        => '',
	'link'      => ''
	},
    items           => [],
    num_items       => 0,
    version         => '',
    encoding        => '',
    category        => ''
);

my %v1_0_ok_fields = (
    channel => { 
	title       => '',
	description => '',
	link        => '',
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
    skipDays  => {
	day         => ''
	},
    skipHours => {
	hour        => ''
	},
    items => [],
    num_items => 0,
    version         => '',
    encoding        => '',
    positioning     => 1,
    output          => '',
);

my %languages = (
    'af'    => 'Afrikaans',
    'sq'    => 'Albanian',
    'eu'    => 'Basque',
    'be'    => 'Belarusian',
    'bg'    => 'Bulgarian',
    'ca'    => 'Catalan',
    'zh-cn' => 'Chinese (Simplified)',
    'zh-tw' => 'Chinese (Traditional)',
    'hr'    => 'Croatian',
    'cs'    => 'Czech',
    'da'    => 'Danish',
    'nl'    => 'Dutch',
    'nl-be' => 'Dutch (Belgium)',
    'nl-nl' => 'Dutch (Netherlands)',
    'en'    => 'English',
    'en-au' => 'English (Australia)',
    'en-bz' => 'English (Belize)',
    'en-ca' => 'English (Canada)',
    'en-ie' => 'English (Ireland)',
    'en-jm' => 'English (Jamaica)',
    'en-nz' => 'English (New Zealand)',
    'en-ph' => 'English (Phillipines)',
    'en-za' => 'English (South Africa)',
    'en-tt' => 'English (Trinidad)',
    'en-gb' => 'English (United Kingdom)',
    'en-us' => 'English (United States)',
    'en-zw' => 'English (Zimbabwe)',
    'fo'    => 'Faeroese',
    'fi'    => 'Finnish',
    'fr'    => 'French',
    'fr-be' => 'French (Belgium)',
    'fr-ca' => 'French (Canada)',
    'fr-fr' => 'French (France)',
    'fr-lu' => 'French (Luxembourg)',
    'fr-mc' => 'French (Monaco)',
    'fr-ch' => 'French (Switzerland)',
    'gl'    => 'Galician',
    'gd'    => 'Gaelic',
    'de'    => 'German',
    'de-at' => 'German (Austria)',
    'de-de' => 'German (Germany)',
    'de-li' => 'German (Liechtenstein)',
    'de-lu' => 'German (Luxembourg)',
    'el'    => 'Greek',
    'hu'    => 'Hungarian',
    'is'    => 'Icelandic',
    'in'    => 'Indonesian',
    'ga'    => 'Irish',
    'it'    => 'Italian',
    'it-it' => 'Italian (Italy)',
    'it-ch' => 'Italian (Switzerland)',
    'ja'    => 'Japanese',
    'ko'    => 'Korean',
    'mk'    => 'Macedonian',
    'no'    => 'Norwegian',
    'pl'    => 'Polish',
    'pt'    => 'Portuguese',
    'pt-br' => 'Portuguese (Brazil)',
    'pt-pt' => 'Portuguese (Portugal)',
    'ro'    => 'Romanian',
    'ro-mo' => 'Romanian (Moldova)',
    'ro-ro' => 'Romanian (Romania)',
    'ru'    => 'Russian',
    'ru-mo' => 'Russian (Moldova)',
    'ru-ru' => 'Russian (Russia)',
    'sr'    => 'Serbian',
    'sk'    => 'Slovak',
    'sl'    => 'Slovenian',
    'es'    => 'Spanish',
    'es-ar' => 'Spanish (Argentina)',
    'es-bo' => 'Spanish (Bolivia)',
    'es-cl' => 'Spanish (Chile)',
    'es-co' => 'Spanish (Colombia)',
    'es-cr' => 'Spanish (Costa Rica)',
    'es-do' => 'Spanish (Dominican Republic)',
    'es-ec' => 'Spanish (Ecuador)',
    'es-sv' => 'Spanish (El Salvador)',
    'es-gt' => 'Spanish (Guatemala)',
    'es-hn' => 'Spanish (Honduras)',
    'es-mx' => 'Spanish (Mexico)',
    'es-ni' => 'Spanish (Nicaragua)',
    'es-pa' => 'Spanish (Panama)',
    'es-py' => 'Spanish (Paraguay)',
    'es-pe' => 'Spanish (Peru)',
    'es-pr' => 'Spanish (Puerto Rico)',
    'es-es' => 'Spanish (Spain)',
    'es-uy' => 'Spanish (Uruguay)',
    'es-ve' => 'Spanish (Venezuela)',
    'sv'    => 'Swedish',
    'sv-fi' => 'Swedish (Finland)',
    'sv-se' => 'Swedish (Sweden)',
    'tr'    => 'Turkish',
    'uk'    => 'Ukranian'
		 );

# define required elements for RSS 0.9
my $_REQ_v0_9 = {
    channel => {
	"title"          => [1,40],
	"description"    => [1,500],
	"link"           => [1,500]
	},
    image => {
	"title"          => [1,40],
	"url"            => [1,500],
	"link"           => [1,500]
	},
    item => {
	"title"          => [1,100],
	"link"           => [1,500]
	},
    textinput => {
	"title"          => [1,40],
	"description"    => [1,100],
	"name"           => [1,500],
	"link"           => [1,500]
	}
};

# define required elements for RSS 0.91
my $_REQ_v0_9_1 = {
    channel => {
	"title"          => [1,100],
	"description"    => [1,500],
	"link"           => [1,500],
	"language"       => [1,5],
	"rating"         => [0,500],
	"copyright"      => [0,100],
	"pubDate"        => [0,100],
	"lastBuildDate"  => [0,100],
	"docs"           => [0,500],
	"managingEditor" => [0,100],
	"webMaster"      => [0,100],
    },
    image => {
	"title"          => [1,100],
	"url"            => [1,500],
	"link"           => [0,500],
	"width"          => [0,144],
	"height"         => [0,400],
	"description"    => [0,500]
	},
    item => {
	"title"          => [1,100],
	"link"           => [1,500],
	"description"    => [0,500]
	},
    textinput => {
	"title"          => [1,100],
	"description"    => [1,500],
	"name"           => [1,20],
	"link"           => [1,500]
	},
    skipHours => {
	"hour"           => [1,23]
	},
    skipDays => {
	"day"            => [1,10]
	}
};

# RDF module support
my $modules = {
    rss091 => 'http://purl.org/rss/1.0/modules#rss091'
};

sub new {
    my $class = shift;
    my $self = $class->SUPER::new(Namespaces    => 1,
				  NoExpand      => 1,
				  ParseParamEnt => 0,
				  Handlers      => { Char    => \&handle_char,
					             XMLDecl => \&handle_dec,
					             Start   => \&handle_start});
    bless ($self,$class);
    $self->_initialize(@_);
    return $self;
}

sub _initialize {
    my $self = shift;
    my %hash = @_;

    # internal hash
    $self->{_internal} = {};

    # init num of items to 0
    $self->{num_items} = 0;

    # adhere to Netscape limits; no by default
    $self->{'strict'} = 0;

    # initialize items
    $self->{items} = [];

    # namespaces
    $self->{namespaces} = {};

    #get version info
    (exists($hash{version}))
	? ($self->{version} = $hash{version})
	    : ($self->{version} = '1.0');

    # set default output
    (exists($hash{output}))
	? ($self->{output} = $hash{output})
	    : ($self->{output} = "");

    # turn on positioning for RSS 1.0
    (exists($hash{positioning}))
	? ($self->{positioning} = $hash{positioning})
	    : ($self->{positioning} = 1);

    # encoding
    (exists($hash{encoding})) 
	? ($self->{encoding} = $hash{encoding})
	    : ($self->{encoding} = 'UTF-8');

    # initialize RSS data structure
    # RSS version 0.9
    if ($self->{version} eq '0.9') {
	# Copy the hashes instead of using them directly to avoid
        # problems with multiple XML::RSS objects being used concurrently
        foreach my $i (qw(channel image textinput)) {
	    my %template=%{$v0_9_ok_fields{$i}};
	    $self->{$i} = \%template;
        }

    # RSS version 0.91
    } elsif ($self->{version} eq '0.91') {
	foreach my $i (qw(channel image textinput skipDays skipHours)) {
	    my %template=%{$v0_9_1_ok_fields{$i}};
	    $self->{$i} = \%template;
        }

    # RSS version 1.0
    #} elsif ($self->{version} eq '1.0') {
    } else {
	foreach my $i (qw(channel image textinput)) {
	#foreach my $i (keys(%v1_0_ok_fields)) {
	    my %template=%{$v1_0_ok_fields{$i}};
	    $self->{$i} = \%template;
        }
    }
}

sub add_item {
    my $self = shift;
    my $hash = {@_};

    # strict Netscape Netcenter length checks
    if ($self->{'strict'}) {
	# make sure we have a title and link
	croak "title and link elements are required" 
	    unless ($hash->{title} && $hash->{'link'});
	
	# check string lengths
	croak "title cannot exceed 100 characters in length" 
	    if (length($hash->{title}) > 100);
	croak "link cannot exceed 500 characters in length" 
	    if (length($hash->{'link'}) > 500);
	croak "description cannot exceed 500 characters in length"
	    if (exists($hash->{description}) 
		&& length($hash->{description}) > 500);

	# make sure there aren't already 15 items
	croak "total items cannot exceed 15 " if (@{$self->{items}} >= 15);
    }

    # add the item to the list
    if (defined($hash->{mode}) && $hash->{mode} eq 'insert') {
	unshift (@{$self->{items}}, $hash);
    } else {
	push (@{$self->{items}}, $hash);
    }

    # return reference to the list of items
    return $self->{items};
}

sub as_rss_0_9 {
    my $self = shift;
    my $output;

    # XML declaration
    $output .= '<?xml version="1.0"?>'."\n\n";
    
    # RDF root element
    $output .= '<rdf:RDF'."\n".'xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"'."\n";
    $output .= 'xmlns="http://my.netscape.com/rdf/simple/0.9/">'."\n\n";
    
    ###################
    # Channel Element #
    ###################
    $output .= '<channel>'."\n";
    $output .= '<title>'.$self->{channel}->{title}.'</title>'."\n";
    $output .= '<link>'.$self->{channel}->{'link'}.'</link>'."\n";
    $output .= '<description>'.$self->{channel}->{description}.'</description>'."\n";
    $output .= '</channel>'."\n\n";
    
    #################
    # image element #
    #################
    if ($self->{image}->{url}) {
	$output .= '<image>'."\n";
	
	# title
	$output .= '<title>'.$self->{image}->{title}.'</title>'."\n";
	
	# url
	$output .= '<url>'.$self->{image}->{url}.'</url>'."\n";
	
	# link
	$output .= '<link>'.$self->{image}->{'link'}.'</link>'."\n"
	    if $self->{image}->{link};
	
	# end image element
	$output .= '</image>'."\n\n";
    }
    
    ################
    # item element #
    ################
    foreach my $item (@{$self->{items}}) {
	if ($item->{title}) {
	    $output .= '<item>'."\n";
	    $output .= '<title>'.$item->{title}.'</title>'."\n";
	    $output .= '<link>'.$item->{'link'}.'</link>'."\n";
	    
	    # end image element
	    $output .= '</item>'."\n\n";
	}
    }
    
    #####################
    # textinput element #
    #####################
    if ($self->{textinput}->{'link'}) {
	$output .= '<textinput>'."\n";
	$output .= '<title>'.$self->{textinput}->{title}.'</title>'."\n";
	$output .= '<description>'.$self->{textinput}->{description}.'</description>'."\n";
	$output .= '<name>'.$self->{textinput}->{name}.'</name>'."\n";
	$output .= '<link>'.$self->{textinput}->{'link'}.'</link>'."\n";
	$output .= '</textinput>'."\n\n";
    }
 
    $output .= '</rdf:RDF>';
    
    return $output;
}

sub as_rss_0_9_1 {
    my $self = shift;
    my $output;

    # XML declaration
    $output .= '<?xml version="1.0" encoding="'.$self->{encoding}.'"?>'."\n\n";
    
    # DOCTYPE
    $output .= '<!DOCTYPE rss PUBLIC "-//Netscape Communications//DTD RSS 0.91//EN"'."\n";
    $output .= '            "http://my.netscape.com/publish/formats/rss-0.91.dtd">'."\n\n"; 
    
    # RSS root element 
    $output .= '<rss version="0.91">'."\n\n";
    
    ###################
    # Channel Element #
    ###################
    $output .= '<channel>'."\n";
    $output .= '<title>'.$self->{channel}->{title}.'</title>'."\n";
    $output .= '<link>'.$self->{channel}->{'link'}.'</link>'."\n";
    $output .= '<description>'.$self->{channel}->{description}.'</description>'."\n";
    
    # language
    $output .= '<language>'.$self->{channel}->{language}.'</language>'."\n";
	
    # PICS rating
    $output .= '<rating>'.$self->{channel}->{rating}.'</rating>'."\n"
	if $self->{channel}->{rating};
	
    # copyright
    $output .= '<copyright>'.$self->{channel}->{copyright}.'</copyright>'."\n"
	if $self->{channel}->{copyright};
	
    # publication date
    $output .= '<pubDate>'.$self->{channel}->{pubDate}.'</pubDate>'."\n"
	if $self->{channel}->{pubDate};
	    
    # last build date
    $output .= '<lastBuildDate>'.$self->{channel}->{lastBuildDate}.'</lastBuildDate>'."\n"
	if $self->{channel}->{lastBuildDate};
	    
    # external CDF URL
    $output .= '<docs>'.$self->{channel}->{docs}.'</docs>'."\n"
	if $self->{channel}->{docs};
	
    # managing editor
    $output .= '<managingEditor>'.$self->{channel}->{managingEditor}.'</managingEditor>'."\n"
	if $self->{channel}->{managingEditor};
	
    # webmaster
    $output .= '<webMaster>'.$self->{channel}->{webMaster}.'</webMaster>'."\n"
	if $self->{channel}->{webMaster};
	
    $output .= "\n";
	
    #################
    # image element #
    #################
    if ($self->{image}->{url}) {
	$output .= '<image>'."\n";
	
	# title
	$output .= '<title>'.$self->{image}->{title}.'</title>'."\n";
	
	# url
	$output .= '<url>'.$self->{image}->{url}.'</url>'."\n";
	
	# link
	$output .= '<link>'.$self->{image}->{'link'}.'</link>'."\n"
	    if $self->{image}->{link};
	
	# image width
	$output .= '<width>'.$self->{image}->{width}.'</width>'."\n"
	    if $self->{image}->{width};
	    
	# image height
	$output .= '<height>'.$self->{image}->{height}.'</height>'."\n"
	    if $self->{image}->{height};
	    
	# description
	$output .= '<description>'.$self->{image}->{description}.'</description>'."\n"
	    if $self->{image}->{description};
	
	# end image element
	$output .= '</image>'."\n\n";
    }
    
    ################
    # item element #
    ################
    foreach my $item (@{$self->{items}}) {
	if ($item->{title}) {
	    $output .= '<item>'."\n";
	    $output .= '<title>'.$item->{title}.'</title>'."\n";
	    $output .= '<link>'.$item->{'link'}.'</link>'."\n";
	    
	    $output .= '<description>'.$item->{description}.'</description>'."\n"
		if $item->{description};
	    
	    # end image element
	    $output .= '</item>'."\n\n";
	}
    }
    
    #####################
    # textinput element #
    #####################
    if ($self->{textinput}->{'link'}) {
	$output .= '<textinput>'."\n";
	$output .= '<title>'.$self->{textinput}->{title}.'</title>'."\n";
	$output .= '<description>'.$self->{textinput}->{description}.'</description>'."\n";
	$output .= '<name>'.$self->{textinput}->{name}.'</name>'."\n";
	$output .= '<link>'.$self->{textinput}->{'link'}.'</link>'."\n";
	$output .= '</textinput>'."\n\n";
    }
    
    #####################
    # skipHours element #
    #####################
    if ($self->{skipHours}->{hour}) {
	$output .= '<skipHours>'."\n";
	$output .= '<hour>'.$self->{skipHours}->{hour}.'</hour>'."\n";
	$output .= '</skipHours>'."\n\n";
    }
    
    ####################
    # skipDays element #
    ####################
    if ($self->{skipDays}->{day}) {
	$output .= '<skipDays>'."\n";
	$output .= '<day>'.$self->{skipDays}->{day}.'</day>'."\n";
	$output .= '</skipDays>'."\n\n";
    }
    
    # end channel element
    $output .= '</channel>'."\n";
    $output .= '</rss>';

    return $output;
}

sub as_rss_1_0 {
    my $self = shift;
    my $output;

    # XML declaration
    $output .= '<?xml version="1.0" encoding="'.$self->{encoding}.'"?>'."\n\n";
    
    # RDF namespaces declaration
    $output .="<rdf:RDF"."\n"; 
    $output .=' xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"'."\n"; 
    $output .=' xmlns="http://purl.org/rss/1.0/"'."\n";

    # print all imported namespaces
    #foreach my $namespace (keys(%{$self->{namespaces}})) {
	#$output.=" xmlns:$namespace=\"$self->{namespaces}->{$namespace}\""."\n";
    #}

    # import the rss091 namespace if we have any 0.91 elements
    $output.=" xmlns:rss091=\"$modules->{rss091}\""."\n"
	if ( $self->{channel}->{language}
	     || $self->{channel}->{rating}
	     || $self->{channel}->{copyright}
	     || $self->{channel}->{pubDate}
	     || $self->{channel}->{lastBuildDate}
	     || $self->{channel}->{docs}
	     || $self->{channel}->{managingEditor}
	     || $self->{channel}->{webMaster}
	     || $self->{image}->{width}
	     || $self->{image}->{height}
	     || $self->{image}->{description}
	     || $self->{skipHours}
	     || $self->{skipDays}
	     );

    $output .=">"."\n\n";
			      
    ###################
    # Channel Element #
    ###################
    $output .= '<channel rdf:about="'.$self->{channel}->{'link'}.'">'."\n";

    # inchannel
    $self->{channel}->{'inchannel'} = ($self->{channel}->{'inchannel'} || $self->{channel}->{'link'});
    #$output .= '<inchannel rdf:resource="'.$self->{channel}->{'inchannel'}.'" />'."\n";
    
    # title
    $output .= '<title>'.$self->{channel}->{title}.'</title>'."\n";
    
    # link
    $output .= '<link>'.$self->{channel}->{'link'}.'</link>'."\n";

    # description
    $output .= '<description>'.$self->{channel}->{description}.'</description>'."\n";
    
    # additional elements for RSS 0.91
    # language
    $output .= '<rss091:language>'.$self->{channel}->{language}.'</rss091:language>'."\n"
	if $self->{channel}->{language};
    
    # PICS rating
    $output .= '<rss091:rating>'.$self->{channel}->{rating}.'</rss091:rating>'."\n"
	if $self->{channel}->{rating};
	
    # copyright
    $output .= '<rss091:copyright>'.$self->{channel}->{copyright}.'</rss091:copyright>'."\n"
	if $self->{channel}->{copyright};
	
    # publication date
    $output .= '<rss091:pubDate>'.$self->{channel}->{pubDate}.'</rss091:pubDate>'."\n"
	if $self->{channel}->{pubDate};
	
    # last build date
    $output .= '<rss091:lastBuildDate>'.$self->{channel}->{lastBuildDate}.'</rss091:lastBuildDate>'."\n"
	if $self->{channel}->{lastBuildDate};
	
    # external CDF URL
    $output .= '<rss091:docs>'.$self->{channel}->{docs}.'</rss091:docs>'."\n"
	if $self->{channel}->{docs};
	
    # managing editor
    $output .= '<rss091:managingEditor>'.$self->{channel}->{managingEditor}.'</rss091:managingEditor>'."\n"
	if $self->{channel}->{managingEditor};
	
    # webmaster
    $output .= '<rss091:webMaster>'.$self->{channel}->{webMaster}.'</rss091:webMaster>'."\n"
	if $self->{channel}->{webMaster};

    # skipHours
    if ($self->{skipHours}->{hour}) {
	$output .= '<rss091:skipHours>'."\n";
	$output .= '<rss091:hour>'.$self->{skipHours}->{hour}.'</rss091:hour>'."\n";
	$output .= '</rss091:skipHours>'."\n\n";
    }
    
    # skipDays
    if ($self->{skipDays}->{day}) {
	$output .= '<rss091:skipDays>'."\n";
	$output .= '<rss091:day>'.$self->{skipDays}->{day}.'</rss091:day>'."\n";
	$output .= '</rss091:skipDays>'."\n\n";
    }
	
    # end channel element
    $output .= '</channel>'."\n\n";
    
    #################
    # image element #
    #################
    if ($self->{image}->{url}) {
	$output .= '<image rdf:about="'.$self->{image}->{url}.'">'."\n";
	
	# inchannel
	$output .= '<inchannel rdf:resource="'.($self->{image}->{inchannel} || $self->{channel}->{inchannel}).'" />'."\n";

	# title
	$output .= '<title>'.$self->{image}->{title}.'</title>'."\n";
	
	# url
	$output .= '<url>'.$self->{image}->{url}.'</url>'."\n";
	
	# link
	$output .= '<link>'.$self->{image}->{'link'}.'</link>'."\n"
	    if $self->{image}->{link};
	
	# image width
	$output .= '<rss091:width>'.$self->{image}->{width}.'</rss091:width>'."\n"
	    if $self->{image}->{width};
	    
	# image height
	$output .= '<rss091:height>'.$self->{image}->{height}.'</rss091:height>'."\n"
	    if $self->{image}->{height};
	    
	# description
	$output .= '<rss091:description>'.$self->{image}->{description}.'</rss091:description>'."\n"
	    if $self->{image}->{description};
	
	# end image element
	$output .= '</image>'."\n\n";
    }
    
    ################
    # item element #
    ################
    my $counter = 1;
    foreach my $item (@{$self->{items}}) {
	if ($item->{title}) {
	    $output .= '<item rdf:about="'.$item->{'link'}.'"';
	    $output .= " position=\"$counter\"" if ($self->{positioning} == 1);
	    $output .= ">\n";
	    $output .= '<inchannel rdf:resource="'.($item->{inchannel} || $self->{channel}->{inchannel}).'" />'."\n";
	    $output .= '<title>'.$item->{title}.'</title>'."\n";
	    $output .= '<link>'.$item->{'link'}.'</link>'."\n";
	    $output .= '<description>'.$item->{description}.'</description>'."\n"
		if $item->{description};
	    
	    # end image element
	    $output .= '</item>'."\n\n";
	}
	$counter++;
    }
    
    #####################
    # textinput element #
    #####################
    if ($self->{textinput}->{'link'}) {
	$output .= '<textinput rdf:about="'.$self->{textinput}->{'link'}.'">'."\n";
	$output .= '<inchannel rdf:resource="'.($self->{textinput}->{inchannel} || $self->{channel}->{inchannel}).'" />'."\n";
	$output .= '<title>'.$self->{textinput}->{title}.'</title>'."\n";
	$output .= '<description>'.$self->{textinput}->{description}.'</description>'."\n";
	$output .= '<name>'.$self->{textinput}->{name}.'</name>'."\n";
	$output .= '<link>'.$self->{textinput}->{'link'}.'</link>'."\n";
	$output .= '</textinput>'."\n\n";
    }
    
    $output .= '</rdf:RDF>';
}

sub as_string {
    my $self = shift;
    my $version = ($self->{output} =~ /\d/) ? $self->{output} : $self->{version};
    my $output;

    ###########
    # RSS 0.9 #
    ###########
    if ($version eq '0.9') {
	$output = &as_rss_0_9($self);

    ############
    # RSS 0.91 #
    ############
    } elsif ($version eq '0.91') {
	$output = &as_rss_0_9_1($self);

    ###########
    # RSS 1.0 #
    ###########
    } else {
	$output = &as_rss_1_0($self);
    }

    return $output;
}

sub handle_char {
    my ($self,$cdata) = (@_);
    
    #print $self->{namespaces}->{'#default'};

	# image element
    if (
	$self->within_element("image") 
	|| $self->within_element($self->generate_ns_name("image",$self->{namespaces}->{'#default'}))
	) 
    {
	$self->{image}->{$self->current_element} .= $cdata;

	# item element
	} elsif (
		 $self->within_element("item")
		 || $self->within_element($self->generate_ns_name("item",$self->{namespaces}->{'#default'}))
		 ) 
	{
	$self->{'items'}->[$self->{num_items}-1]->{$self->current_element} .= $cdata;

	# textinput element
    } elsif (
	     $self->within_element("textinput")
	     || $self->within_element($self->generate_ns_name("textinput",$self->{namespaces}->{'#default'}))
	     ) 
    {
	$self->{'textinput'}->{$self->current_element} .= $cdata;

	# skipHours element
    } elsif (
	     $self->within_element("skipHours")
	     || $self->within_element($self->generate_ns_name("skipHours",$self->{namespaces}->{'#default'}))
	     ) 
    {
	$self->{'skipHours'}->{$self->current_element} .= $cdata;

	# skipDays element
    } elsif (
	     $self->within_element("skipDays")
	     || $self->within_element($self->generate_ns_name("skipDays",$self->{namespaces}->{'#default'}))
	     ) 
    {
	$self->{'skipDays'}->{$self->current_element} .= $cdata;

	# channel element
    } elsif (
	     $self->within_element("channel")
	     || $self->within_element($self->generate_ns_name("channel",$self->{namespaces}->{'#default'}))
	     ) 
    {
	$self->{channel}->{$self->current_element} .= $cdata;
    }
}

sub handle_dec {
    my ($self,$version,$encoding,$standalone) = (@_);
    $self->{encoding} = $encoding;
    #print "ENCODING: $encoding\n";
}

sub handle_start {
    my $self = shift;
    my $el   = shift;
    my %attribs = @_;
   
    # beginning of RSS 0.91 
    if ($el eq 'rss') {
	if (exists($attribs{version})) {
	    $self->{_internal}->{version} = $attribs{version};
	} else {
	    croak "Malformed RSS: invalid version\n";
	}

    # beginning of RSS 1.0 or RSS 0.9
    } elsif ($el eq 'RDF') {
	my @prefixes = $self->new_ns_prefixes;
	foreach my $prefix (@prefixes) {
	    my $uri = $self->expand_ns_prefix($prefix);
	    $self->{namespaces}->{$prefix} = $uri;
	}

	
	if ($self->expand_ns_prefix('#default') =~ /\/1.0\//) {
	    $self->{_internal}->{version} = '1.0';
	} elsif ($self->expand_ns_prefix('#default') =~ /\/0.9\//) {
	    $self->{_internal}->{version} = '0.9';
	} else {
	    croak "Malformed RSS: invalid version\n";
	}

    # beginning of inchannel element
    } elsif ($el eq 'inchannel') {
	# channel element
	if ($self->within_element("channel")) {
	    $self->{channel}->{inchannel} = $attribs{resource};

	# item element
	} elsif ($self->within_element("item")) {
	    $self->{'items'}->[$self->{num_items}-1]->{inchannel} = $attribs{resource};
 
        # image element
	} elsif ($self->within_element("image")) {
	    $self->{image}->{inchannel} = $attribs{resource};

	# textinput element
	} elsif ($self->within_element("textinput")) {
	    $self->{textinput}->{inchannel} = $attribs{resource};
	}

    # beginning of item element
    } elsif ($el eq 'item') {
        # increment item count
	$self->{num_items}++;
    }
}

sub parse { 
    my $self = shift;
    $self->SUPER::parse(shift);
    $self->{version} = $self->{_internal}->{version};
}

sub parsefile {
    my $self = shift;
    $self->SUPER::parsefile(shift);
    $self->{version} = $self->{_internal}->{version};
}

sub save {
    my ($self,$file) = @_;
    open(OUT,">$file") || croak "Cannot open file $file for write: $!";
    print OUT $self->as_string;
    close OUT;
}

sub strict {
    my ($self,$value) = @_;
    $self->{'strict'} = $value;
}

sub AUTOLOAD {
    my $self = shift;
    my $type = ref($self) || croak "$self is not an object\n";
    my $name = $AUTOLOAD;
    $name =~ s/.*://;
    return if $name eq 'DESTROY';
    
    croak "Unregistered entity: Can't access $name field in object of class $type"
	unless (exists $self->{$name});

    # return reference to RSS structure
    if (@_ == 1) {
	return $self->{$name}->{$_[0]} if defined $self->{$name}->{$_[0]};
	
    # we're going to set values here
    } elsif (@_ > 1) {
	my %hash = @_;
	my $_REQ;

	# make sure we have required elements and correct lengths
	if ($self->{'strict'}) {
	    ($self->{version} eq '0.9')
		? ($_REQ = $_REQ_v0_9)
		    : ($_REQ = $_REQ_v0_9_1);
	}
	    
	# store data in object
	foreach my $key (keys(%hash)) {
	    if ($self->{'strict'}) {
		my $req_element = $_REQ->{$name}->{$key};
		confess "$key cannot exceed " . $req_element->[1] . " characters in length"
		    if defined $req_element->[1] && length($hash{$key}) > $req_element->[1];
	    }
	    $self->{$name}->{$key} = $hash{$key};
	}
       
	# return value
	return $self->{$name};
	
    # otherwise, just return a reference to the whole thing
    } else {
	return $self->{$name};
    }
    return 0;

    # make sure we have all required elements
	#foreach my $key (keys(%{$_REQ->{$name}})) {
	    #my $element = $_REQ->{$name}->{$key};
	    #croak "$key is required in $name" 
		#if ($element->[0] == 1) && (!defined($hash{$key}));
	    #croak "$key cannot exceed ".$element->[1]." characters in length"
		#unless length($hash{$key}) <= $element->[1];
	#}
}


1;
__END__
# Below is the stub of documentation for your module. You better edit it!

=head1 NAME

XML::RSS - creates and updates RSS files

=head1 SYNOPSIS

 # create an RSS 1.0 file
 use XML::RSS;
 my $rss = new XML::RSS (output => '1.0);

 # create an RSS 0.91 file
 use XML::RSS;
 my $rss = new XML::RSS (version => '0.91');
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

 $rss->add_item(title => "GTKeyboard 0.85",
                link  => "http://freshmeat.net/news/1999/06/21/930003829.html",
		description => 'blah blah'
                );

 $rss->skipHours(hour => 2);
 $rss->skipDays(day => 1);

 $rss->textinput(title => "quick finder",
                 description => "Use the text input below to search freshmeat",
                 name  => "query",
                 link  => "http://core.freshmeat.net/search.php3"
                 );

 # create an RSS 0.9 file
 use XML::RSS;
 my $rss = new XML::RSS (version => '0.9');
 $rss->channel(title => "freshmeat.net",
               link  => "http://freshmeat.net",
               description => "the one-stop-shop for all your Linux software needs",
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
 pop(@{$rss->{'items'}}) if (@{$rss->{'items'}} == 15);
 $rss->add_item(title => "MpegTV Player (mtv) 1.0.9.7",
                link  => "http://freshmeat.net/news/1999/06/21/930003958.html",
                mode  => 'insert'
                );

 # parse a string instead of a file
 $rss->parse($string);

 # print the title and link of each RSS item
 foreach my $item (@{$rss->{'items'}}) {
     print "title: $item->{'title'}\n";
     print "link: $item->{'link'}\n\n";
 }

 # output the RSS 0.9 or 0.91 file as RSS 1.0
 $rss->{output} = '1.0';
 print $rss->as_string;

=head1 DESCRIPTION

This module provides a basic framework for creating and maintaining 
RDF Site Summary (RSS) files. This distribution also contains many 
examples that allow you to generate HTML from an RSS, convert between
0.9, 0.91, and 1.0 version, and other nifty things. 
This might be helpful if you want to include news feeds on your Web 
site from sources like Slashot and Freshmeat or if you want to syndicate
your own content.

XML::RSS currently supports 0.9, 0.91, and 1.0 versions of RSS.
See http://my.netscape.com/publish/help/mnn20/quickstart.html
for information on RSS 0.91. See http://my.netscape.com/publish/help/
for RSS 0.9. See http://www.egroups.com/files/rss-dev/specification.html
for RSS 1.0.

RSS was originally developed by Netscape as the format for 
Netscape Netcenter channels, however, many Web sites have since
adopted it as a simple syndication format. With the advent of RSS 1.0,
users are now able to syndication many different kinds of content
including news headlines, threaded measages, products catalogs, etc.

=head1 METHODS

=over 4

=item new XML::RSS (version=>$version, encoding=>$encoding,
output=>$output, positioning=>1)

Constructor for XML::RSS. It returns a reference to an XML::RSS object.
You may also pass the RSS version and the XML encoding to use. The default
B<version> is 1.0. The default B<encoding> is UTF-8. You may also specify
the B<output> format regarless of the input version. This comes in handy
when you want to convert RSS between versions. The XML::RSS modules
will convert between any of the formats. The B<positioning> parameter
is turned on by default. It can be turned off by passing a 0 when
a new instance of XML::RSS is created. This turns on the item B<position>
attribute when outputting RSS 1.0.

=item add_item (title=>$title, link=>$link, description=>$desc, mode=>$mode)

Adds an item to the XML::RSS object. B<mode> and B<description> are optional. 
The default B<mode> 
is append, which adds the item to the end of the list. To insert an item, set the mode
to B<insert>. 

The items are stored in the array @{$obj->{'items'}} where
B<$obj> is a reference to an XML::RSS object.

=item as_string;

Returns a string containing the RSS for the XML::RSS object. 

=item channel (title=>$title, link=>$link, description=>$desc,
language=>$language, rating=>$rating, copyright=>$copyright,
pubDate=>$pubDate, lastBuildDate=>$lastBuild, docs=>$docs,
managingEditor=>$editor, webMaster=>$webMaster)


Channel information is required in RSS. The B<title> cannot
be more the 40 characters, the B<link> 500, and the B<description>
500 when outputting RSS 0.9. B<title>, B<link>, and B<description>, 
are required for RSS 1.0. B<language> is required for RSS 0.91.
Any of the channel elements can be used in RSS 1.0 since they will
be imported via the rss091 namespace. The other parameters are optional
for RSS 0.91 and 1.0.

To retreive the values of the channel, pass the name of the value
(title, link, or description) as the first and only argument
like so:

$title = channel('title');

=item image (title=>$title, url=>$url, link=>$link, width=>$width,
height=>$height, description=>$desc)

Adding an image is not required. B<url> is the URL of the
image, B<link> is the URL the image is linked to. B<title>, B<url>,
and B<link> parameters are required if you are going to
use an image in your RSS file. The remaining image elements are used
in RSS 0.91 or optionally imported into RSS 1.0 via the rss091 namespace.

The method for retrieving the values for the image is the same as it
is for B<channel()>.

=item parse ($string)

Parses an RDF Site Summary which is passed into B<parse()> as the first parameter.

=item parsefile ($file)

Same as B<parse()> except it parses a file rather than a string.

=item save ($file)

Saves the RSS to a specified file.

=item skipHours (hour=>$hour)

Specifies the number of hours that a server should wait before retrieving
the RSS file. The B<hour> parameter is required if the skipHours method
is used. This method is currently broken.

=item skipDays (day=>$day)

Specified the number of days that a server should wait before retrieving
the RSS file. The B<day> parameter is required if the skipDays method
is used. This method is currently broken.

=item strict ($boolean)

If it's set to 1, it will adhere to the lengths as specified
by Netscape Netcenter requirements. It's set to 0 by default.
Use it if the RSS file you're generating is for Netcenter.
strict will only work for RSS 0.9 and 0.91. Do not use it for
RSS 1.0.

=item textinput (title=>$title, description=>$desc, name=>$name, link=>$link);

This RSS element is also optional. Using it allows users to submit a Query
to a program on a Web server via an HTML form. B<name> is the HTML form name
and B<link> is the URL to the program. Content is submitted using the GET
method.

Access to the B<textinput> values is the the same as B<channel()> and 
B<image()>.

=head1 AUTHOR

Jonathan Eisenzopf <eisen@pobox.com>

=head1 CREDITS

 Wojciech Zwiefka <wojtekz@cnt.pl>
 Chris Nandor <pudge@pobox.com>
 Jim Hebert <jim@cosource.com>
 Randal Schwartz <merlyn@stonehenge.com>
 rjp@browser.org

=head1 SEE ALSO

perl(1), XML::Parser(3).

=cut
