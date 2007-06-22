#############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Test-Perl-Critic-Progressive/t/00_basic.t $
#     $Date: 2007-06-22 04:26:51 -0700 (Fri, 22 Jun 2007) $
#   $Author: thaljef $
# $Revision: 1698 $
##############################################################################

use strict;
use warnings;
use Test::More tests => 19;

#-----------------------------------------------------------------------------

my $package = 'Test::Perl::Critic::Progressive';

#-----------------------------------------------------------------------------

use_ok($package);
can_ok($package, 'get_critic_args');
can_ok($package, 'set_critic_args');
can_ok($package, 'get_total_step_size');
can_ok($package, 'set_total_step_size');
can_ok($package, 'get_step_size_per_policy');
can_ok($package, 'set_step_size_per_policy');
can_ok($package, 'get_history_file');
can_ok($package, 'set_history_file');
can_ok($package, 'progressive_critic_ok');

#-----------------------------------------------------------------------------

Test::Perl::Critic::Progressive->import( ':all' );

can_ok(__PACKAGE__, 'get_critic_args');
can_ok(__PACKAGE__, 'set_critic_args');
can_ok(__PACKAGE__, 'get_total_step_size');
can_ok(__PACKAGE__, 'set_total_step_size');
can_ok(__PACKAGE__, 'get_step_size_per_policy');
can_ok(__PACKAGE__, 'set_step_size_per_policy');
can_ok(__PACKAGE__, 'get_history_file');
can_ok(__PACKAGE__, 'set_history_file');
can_ok(__PACKAGE__, 'progressive_critic_ok');

##############################################################################
# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab :