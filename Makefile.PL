#######################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Test-Perl-Critic-Progressive/Makefile.PL $
#     $Date: 2007-06-16 23:03:15 -0700 (Sat, 16 Jun 2007) $
#   $Author: thaljef $
# $Revision: 1646 $
########################################################################

use strict;
use warnings;

use ExtUtils::MakeMaker;

WriteMakefile( NAME           => 'Test::Perl::Critic::Progressive',
	       AUTHOR         => 'Jeffrey Thalhammer <thaljef@cpan.org>',
	       ABSTRACT_FROM  => 'lib/Test/Perl/Critic/Progressive.pm',
	       VERSION_FROM   => 'lib/Test/Perl/Critic/Progressive.pm',
	       PL_FILES       => {},
	       PREREQ_PM      => {'Perl::Critic'            => 0.21,
                                  'Perl::Critic::Utils'     => 0.21,
                                  'Test::Builder'           => 0,
                                  'Test::More'              => 0,
			      },

);
