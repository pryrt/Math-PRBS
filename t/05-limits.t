########################################################################
# Verifies major functionality
########################################################################
use 5.006;
use strict;
use warnings;
use Test::More;# tests => 15;

use Math::PRBS;

my $t = time();
my $dt;
my ($seq, $exp, $got, @g);

$t = time();
diag("\n", "Running a 2**24 pattern to verify estimate/force/forceBig; may take quite a few seconds");
$seq = Math::PRBS->new( taps => [24,5] );
is( $seq->description, 'PRBS from polynomial x**24 + x**5 + 1', 'taps => [24,5]: ->description');
is( $seq->oeis_anum, undef,                                     'taps => [24,5]: ->oeis_anum');
is_deeply( $seq->taps(), [24,5],                                'taps => [24,5]: ->taps         = x**24 + x**5 + 1' );
is( $seq->tell_state, '8388608',                                'taps => [24,5]: ->tell_state   = internal LFSR state' );
is( $seq->period(), undef,                                      'taps => [24,5]: ->period  = not defined yet' );
is( $seq->period('estimate'), 2**24-1,                          'taps => [24,5]: ->period("estimate"): 2**24-1' );
is( $seq->period('force'), undef,                               'taps => [24,5]: ->period("force"): force, but limit to 2**23-1' );
is( $seq->period('forceBig'), 16_766_977,                       'taps => [24,5]: ->period("forceBig"): force it to compute the full sequence' );
diag( "taps => [24,5]: Elapsed time: ", $dt=time()-$t, "sec");

done_testing();