#######################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Test-Perl-Critic-Progressive/Build.PL $
#     $Date: 2007-06-16 23:03:15 -0700 (Sat, 16 Jun 2007) $
#   $Author: thaljef $
# $Revision: 1646 $
########################################################################

use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(

  module_name    => 'Test::Perl::Critic::Progressive',
  dist_author    => 'Jeffrey Thalhammer <thaljef@cpan.org>',
  dist_abstract  => 'Use Perl::Critic in test scripts',
  license        => 'perl',

  requires       => {
                     'Perl::Critic'              => 0.21,
                     'Perl::Critic::Utils'       => 0.21,
		     'Test::Builder'             => 0,
	            },
  build_requires => {
                     'Test::More'                => 0,
                    },
);

$builder->create_build_script();
