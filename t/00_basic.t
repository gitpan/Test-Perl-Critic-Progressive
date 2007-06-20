#############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Test-Perl-Critic-Progressive/t/00_basic.t $
#     $Date: 2007-06-17 01:44:03 -0700 (Sun, 17 Jun 2007) $
#   $Author: thaljef $
# $Revision: 1649 $
##############################################################################

use strict;
use warnings;
use Test::More tests => 6;

#-----------------------------------------------------------------------------

my $package = 'Test::Perl::Critic::Progressive';

#-----------------------------------------------------------------------------


use_ok($package);
can_ok($package, 'get_step_size');
can_ok($package, 'set_step_size');
can_ok($package, 'get_history_file');
can_ok($package, 'set_history_file');
can_ok($package, 'progressive_critic_ok');