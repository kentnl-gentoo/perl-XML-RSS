# $Id: Makefile.PL,v 1.3 2002/11/12 12:04:17 comdog Exp $
use ExtUtils::MakeMaker;
@extras = ();

push(@extras,
     CAPI => 'TRUE')
    if ($PERL_VERSION >= 5.005 and $OSNAME eq 'MSWin32'
        and $Config{archname} =~ /-object\b/i);

push(@extras,
     ABSTRACT_FROM => 'RSS.pm',
     AUTHOR        => 'brian d foy <bdfoy@cpan.org>')
    if ($ExtUtils::MakeMaker::Version >= 5.4301);

sub ExtUtils::MM_Any::test_via_harness
		{
		my($self, $perl, $tests) = @_;

		return qq|\t$perl "-MTest::Manifest" | .
			qq|"-e" "run_t_manifest(\$(TEST_VERBOSE), '\$(INST_LIB)', | .
			qq|'\$(INST_ARCHLIB)')"\n|;
		}
     
WriteMakefile(
    'NAME'	               => 'XML::RSS',
    'VERSION_FROM'         => 'lib/RSS.pm', # finds $VERSION,
	'PM'			       => { 
		'lib/RSS.pm' => '$(INST_LIBDIR)/RSS.pm' 
		},
    'PREREQ_PM'            => { 
		'Test::Manifest'   => '0.9',
		'File::Find::Rule' => '0',
		'Test::More'       => '0',
		'Test::Pod'        => '0',
		'Test::Prereq'     => '0.18',
    	'XML::Parser'      => '2.23', 
    	},
	'MAN3PODS'		       => {
		'lib/RSS.pm'    => '$(INST_MAN3DIR)/XML::RSS.3',
		},
	'clean'			       => { FILES => 'XML-RSS-*' },
    @extras
);
