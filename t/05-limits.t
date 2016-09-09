########################################################################
# Verifies period and generate limits
#   uses some k=17 taps that are known to be 65535 < period <= 2**17-1
#       # [17,2]        => 114_681: partial
#       # [17,4,2,1]    => 122_865: partial
#       # [17,3]        => 131_071: maximal
########################################################################
use 5.006;
use strict;
use warnings;
use Test::More;# tests => 15;

use Math::PRBS;

my ($seq, $exp, $got, @g);

# verify PERIOD limits with [17,2]
$seq = Math::PRBS->new( taps => [17,2] );
is( $seq->description, 'PRBS from polynomial x**17 + x**2 + 1', '[17,2]->description');
is( $seq->oeis_anum, undef,                                     '[17,2]->oeis_anum');
is_deeply( $seq->taps(), [17,2],                                '[17,2]->taps' );
is( $seq->period(), undef,                                      '[17,2]->period()                           = not defined yet' );
is( $seq->period('estimate'), 2**17-1,                          '[17,2]->period("estimate")                 = estimate 2**k-1' );
is( $seq->period('force'), undef,                               '[17,2]->period("force")                    = force, but up to default limit' );
is( $seq->period('forceBig'), 114_681,                          '[17,2]->period("forceBig")                 = force, compute the full sequence' );

#verify generate_all() / generate_to_end() limits: they use the same limits-function, because generate_all calls generate_to_end
$got = $seq->generate_all();
is( length($got),  65_535,                                      '[17,2]->generate_all()                     = string length @ default limit');
is( $seq->tell_i,  65_535,                                      '[17,2]->generate_all()                     = tell_i() @ default limit');

$got = $seq->generate_to_end( limit => 70_000);
is( length($got),   4_465,                                      '[17,2]->generate_to_end(limit=>70000)      = string length: 70000-65535');
is( $seq->tell_i,  70_000,                                      '[17,2]->generate_to_end(limit=>70000)      = tell_i()');

$got = $seq->generate_to_end( limit => 'max');  # 131_071 > 114_681, so enough room
is( length($got),  44_681,                                      '[17,2]->generate_to_end(limit=>2**17-1)    = string length: 70000-65535');
is( $seq->tell_i, 114_681,                                      '[17,2]->generate_to_end(limit=>2**17-1)    = tell_i()');

# need to verify limit => 'max' for a maximal [17,3], to make sure it computes correctly
$seq = Math::PRBS->new( taps => [17,3] );
$got = $seq->generate_all( limit => 'max');
is( length($got), 131_071,                                      '[17,3]->generate_all(limit=>2**17-1)       = string length');
is( $seq->tell_i, 131_071,                                      '[17,3]->generate_all(limit=>2**17-1)       = tell_i()');

done_testing();
