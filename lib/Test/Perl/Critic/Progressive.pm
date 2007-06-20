##############################################################################
#      $URL: http://perlcritic.tigris.org/svn/perlcritic/trunk/Test-Perl-Critic-Progressive/lib/Test/Perl/Critic/Progressive.pm $
#     $Date: 2007-06-17 01:44:03 -0700 (Sun, 17 Jun 2007) $
#   $Author: thaljef $
# $Revision: 1649 $
##############################################################################

package Test::Perl::Critic::Progressive;

use strict;
use warnings;

use Carp qw(croak confess);
use Data::Dumper qw(Dumper);
use English qw(-no_match_vars);
use File::Spec qw();
use FindBin qw($Bin);

use Perl::Critic qw();
use Perl::Critic::Utils qw( &policy_short_name );

use Test::Builder qw();

#---------------------------------------------------------------------------

our $VERSION = 0.01;

#---------------------------------------------------------------------------

my $STEP_SIZE = undef;
my $DEFAULT_STEP_SIZE = 0;

my $HISTORY_FILE = undef;
my $DEFAULT_HISTORY_FILE = File::Spec->catfile($Bin, '.perlcritic-history');

my $CRITIC = undef;
my %CRITIC_ARGS = ();

my $TEST = Test::Builder->new();

#---------------------------------------------------------------------------
# Public functions

sub progressive_critic_ok {

    my @dirs = @_ ? @_ : _starting_points();
    my @files = _all_code_files( @dirs );
    croak qq{No perl files found\n} if not @files;

    my $caller = caller;
    $TEST->exported_to($caller);
    $TEST->plan( tests => 1 );

    $CRITIC = Perl::Critic->new( get_critic_args() );
    my @violations = map { $CRITIC->critique($_) } @files;

    my $ok = _evaluate_test( @violations );
    $TEST->ok($ok, __PACKAGE__);
    return $ok;
}

#---------------------------------------------------------------------------
# Pulbic accessor functions

sub get_history_file { return $HISTORY_FILE || $DEFAULT_HISTORY_FILE; }
sub set_history_file { return $HISTORY_FILE = shift; }

sub get_step_size { return $STEP_SIZE || $DEFAULT_STEP_SIZE; }
sub set_step_size { return $STEP_SIZE = shift; }

sub set_critic_args { return %CRITIC_ARGS = @_; }
sub get_critic_args { return %CRITIC_ARGS; }

#---------------------------------------------------------------------------
# Private functions

sub _evaluate_test {

    my (@viols) = @_;

    my $ok = 1;
    my $results = {};

    my $history_data = _read_history( get_history_file() );
    my $last_critique = $history_data->[-1];
    my $has_run_before = defined $last_critique;
    my $last_total_violations = undef;


    for my $policy ( $CRITIC->policies() ) {

        my $policy_name = ref $policy;
        my $policy_violations = grep {$_->policy() eq $policy_name} @viols;
        $results->{$policy_name} = $policy_violations;

        my $last_policy_violations = $last_critique->{$policy_name};
        next if not defined $last_policy_violations;
        $last_total_violations += $last_policy_violations;

        if ( $policy_violations > $last_policy_violations ) {

            my $short_name = policy_short_name($policy_name);
            my $diagf = '%s violations was %i, now %i.';

            $TEST->diag( sprintf $diagf, $short_name,
                         $last_policy_violations, $policy_violations );

            $ok = 0; # Failed the test!
        }
    }



    if ( $has_run_before ) {
        my $got = scalar @viols;
        my $target = $last_total_violations - get_step_size();
        my $expected = $target < 0 ? 0 : $target;  # Don't go negative
        if ( $got > $expected ){
            $TEST->diag('Got too many Perl::Critic violations');
            $TEST->diag("Got $got violations, but expected no more than $expected.");
            $ok = 0;
        }
    }




    if ( !$has_run_before || ($ok && $last_total_violations > 0) ) {
        push @{$history_data}, $results;
        _write_history_file( get_history_file(), $history_data);
    }


    return $ok;
}

#---------------------------------------------------------------------------

sub _all_code_files {
    my @dirs = @_ ? @_ : _starting_points();
    return Perl::Critic::Utils::all_perl_files(@dirs);
}

#---------------------------------------------------------------------------

sub _starting_points {
    return -e 'blib' ? 'blib' : 'lib';
}

#---------------------------------------------------------------------------

sub _read_history {

    my ($history_file) = @_;

    return [] if not -e $history_file;

    my $history_data = eval { do $history_file };
    croak qq{Can't read history from "$history_file": $EVAL_ERROR}
      if $EVAL_ERROR;

    return $history_data;
}

#---------------------------------------------------------------------------

sub _open_history_file {

    my ($history_file) = @_;

    open my $history_fh, '>', $history_file
      or confess qq{Can't open "$history_file": $OS_ERROR};

    return $history_fh;
}

#---------------------------------------------------------------------------

sub _write_history_file {

    my ($history_file, $history_data) = @_;

    my $history_fh = _open_history_file($history_file);

    print {$history_fh} Dumper($history_data)
      or confess qq{Can't write to "$history_file": $OS_ERROR};

    close $history_fh
      or confess qq{Can't close "$history_file": $OS_ERROR};

    return 1;
}

#---------------------------------------------------------------------------

1;


__END__

=pod

=for stopwords AntHill CruiseControl

=head1 NAME

Test::Perl::Critic::Progressive - Gradually enforce coding standards

=head1 SYNOPSIS

To test one or more files, and/or all files in one or more directories:

  use Test::Perl::Critic::Progressive;
  Test::Perl::Critic::Progressive::progressive_critic_ok($file1, $file2, $dir1, $dir2);

To test all files in a distribution:

  use Test::Perl::Critic::Progressive;
  Test::Perl::Critic::Progressive::progressive_critic_ok();

Recommended usage for public CPAN distributions:

  use strict;
  use warnings;
  use English qw(-no_match_vars);
  use Test::More;

  eval { require Test::Perl::Critic::Progressive };
  plan skip_all => 'T::P::C::Progressive required for this test' if $EVAL_ERROR;

  Test::Perl::Critic::Progressive::progressive_critic_ok();

=head1 DESCRIPTION

Applying coding standards to large amounts of legacy code is a daunting task.
Often times, legacy code is so non-compliant that it seems downright
impossible.  But, if you consistently chip away at the problem, you will
eventually succeed!  Test::Perl::Critic::Progressive uses the L<Perl::Critic>
engine to B<gradually> to prevent further deterioration of your code and
gradually steer it towards conforming with your chosen coding standards.

The most effective way to use Test::Perl::Critic::Progressive is as a unit
test that is run under a continuous-integration system like CruiseControl or
AntHill.  Each time a developer commits changes to the code, this test will
fail and the build will break unless it has the same (or fewer) Perl::Critic
violations than the last successful test.

=head1 SUBROUTINES

=over 8

=item Test::Perl::Critic::Progressive::progressive_critic_ok(@FILES [, @DIRECTORIES ])

Uses Perl::Critic to analyze each of the given @FILES, and/or all Perl files
beneath the given list of C<@DIRECTORIES>.  If no arguments are given, it
analyzes all the Perl files in the F<blib/> directory.  If the F<blib/>
directory does not exist, then it tries the F<lib/> directory.  The results of
the analysis will be stored as F<.perlcritic-history> in the same directory
where your test script is located.

The first time you run this test, it will always pass.  But on each subsequent
run, the test will pass only if the number of violations found B<is less than
or equal to> the number of violations found during the last passing test.  If
it does pass, then the history file will be updated with the new analysis
results.  Once all the violations are removed from the code, this test will
always pass, a new violation is introduced.

This subroutine emits its own L<Test::More> plan, so you do not need to
specify an expected number of tests yourself.

=back

=head1 CONFIGURATION

You can use the following functions to configure the behavior of
Test::Perl::Critic::Progressive.  You should use these before calling
C<progressive_critic_ok>.  Note that they are B<never> exported.

=over 8

=item Test::Perl::Critic::Progressive::get_history_file();

=item Test::Perl::Critic::Progressive::set_history_file($FILE);

These functions get or set the full path to the history file.  This is
where Test::Perl::Critic::Progressive will store the results of each passing
analysis.  If the C<$FILE> does not exist, it will be created anew.  The
default is C<$Bin/.perlcritic-history> where C<$Bin> is the directory that
the calling test script is located in.

=item Test::Perl::Critic::Progressive::get_step_size();

=item Test::Perl::Critic::Progressive::set_step_size($INTEGER);

These functions get or set the minimum acceptable decrease in the B<total>
number of violations between each test.  The default value is zero, which
means that you are not required to remove any violations, but you are also not
allowed to add any.  If you set the step size to a positive number, the test
will require you to remove C<$INTEGER> violations each time the test is run.
Thus, increasing the step size forces you to correct the code faster.

=item Test::Perl::Critic::Progressive::get_critic_args();

=item Test::Perl::Critic::Progressive::set_critic_args(%ARGS);

These functions get or set the arguments given to L<Perl::Critic>.  By
default, Test::Perl::Critic::Progressive invokes Perl::Critic with its default
configuration.  But if you have developed your code against a custom
Perl::Critic configuration, you will want to configure this test to do the
same.

Any C<%ARGS> given to the C<set_critic_args> will be passed directly into the
L<Perl::Critic> constructor.  So if you have developed your code using a
custom F<.perlcriticrc> file, you can direct Test::Perl::Critic::Progressive
to use a custom file too.

  use Test::Perl::Critic::Progressive;

  Test::Perl::Critic::Progressive::set_critic_args(-profile => 't/perlcriticrc);
  Test::Perl::Critic::Progressive::progressive_critic_ok();

Now place a copy of your own F<.perlcriticrc> file in the distribution as
F<t/perlcriticrc>.  Now, C<progressive_critic_ok> will use this same
Perl::Critic configuration.  See the L<Perl::Critic> documentation for details
on the F<.perlcriticrc> file format.

Any argument that is supported by the L<Perl::Critic> constructor can be
passed through this interface.  For example, you can also set the minimum
severity level, or include & exclude specific policies like this:

  use Test::Perl::Critic::Progressive;

  Test::Perl::Critic::Progressive::set_critic_args(-severity => 2);
  Test::Perl::Critic::Progressive::progressive_critic_ok();

See the L<Perl::Critic> documentation for complete details on its options and
arguments.

=back

=head1 NOTES

The test is evaluated in two ways. First, the number of violations for each
Policy must be B<less than or equal to> the number of the violations found
during the last passing test.  Second, the total number of violations must be
B<less than or equal> the total number of violations found during the last
passing test (minus the step size).  This prevents you from simply
substituting one kind of violation for another.

Over time, you'll probably add new Policies to your L<Perl::Critic> setup.
When Test::Perl::Critic::Progressive uses a Policy for the first time, any
newly discovered violations of that Policy will not be considered in the test.
However, they will be considered in subsequent tests.

=head1 BUGS

If you find any bugs, please submit them to
L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Test-Perl-Critic-Progressive>.
Thanks.


=head1 SEE ALSO

L<criticism>

L<Perl::Critic>

L<Test::Perl::Critic>

L<http://www.perlcritic.com>

=head1 AUTHOR

Jeffrey Ryan Thalhammer <thaljef@cpan.org>

=head1 COPYRIGHT

Copyright (c) 2007 Jeffrey Ryan Thalhammer.  All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.  The full text of this license
can be found in the LICENSE file included with this module.

=cut

##############################################################################
# Local Variables:
#   mode: cperl
#   cperl-indent-level: 4
#   fill-column: 78
#   indent-tabs-mode: nil
#   c-indentation-style: bsd
# End:
# ex: set ts=8 sts=4 sw=4 tw=78 ft=perl expandtab :
