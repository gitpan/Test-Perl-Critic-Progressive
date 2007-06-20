#######################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Test-Perl-Critic-Progressive/t/01_api.t $
#     $Date: 2007-06-16 23:03:15 -0700 (Sat, 16 Jun 2007) $
#   $Author: thaljef $
# $Revision: 1646 $
########################################################################

use strict;
use warnings;
use Test::More tests => 5;
use Test::Perl::Critic::Progressive ();
use English qw(-no_match_vars);

#---------------------------------------------------------------------------
# Accessor tests

{
    my ($expected, $got);

    $expected = 10;
    Test::Perl::Critic::Progressive::set_step_size($expected);
    $got = Test::Perl::Critic::Progressive::get_step_size();
    is($got, $expected, 'Accessor: set_step_size');

    $expected = 'foo/bar/baz';
    Test::Perl::Critic::Progressive::set_history_file($expected);
    $got = Test::Perl::Critic::Progressive::get_history_file();
    is($got, $expected, 'Accessor: set_history_file');
}


#---------------------------------------------------------------------------
# Exception tests

{
    my $bogus_path = 'foo/bar/baz';

    eval{ progressive_critic_ok($bogus_path) };
    ok( defined $EVAL_ERROR, 'Critique bogus code file' );

    eval { Test::Perl::Critic::Progressive::_open_history_file($bogus_path) };
    like( $EVAL_ERROR, qr/Can't open/m, 'Open bogus history file' );

    my $got = eval { Test::Perl::Critic::Progressive::_read_history($bogus_path) };
    is_deeply( $got, [], 'Load bogus history file' );
}

##############################################################################
# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab :
