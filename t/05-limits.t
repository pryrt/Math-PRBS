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

use Devel::Size qw(size total_size);
use Data::Dump 'dump';
sub dz($$) { printf STDERR "%-8d# size:%-9d total:%-9d obj:%s\n", $_[0], size($_[1]), total_size($_[1]), size($_[1])<1000 ? dump($_[1]) : 'big'; }

my ($seq, $exp, $got, @g);

# verify PERIOD limits with [17,2]
$seq = Math::PRBS->new( taps => [17,2] );
dz __LINE__, $seq;
is( $seq->description, 'PRBS from polynomial x**17 + x**2 + 1', '[17,2]->description');
is( $seq->oeis_anum, undef,                                     '[17,2]->oeis_anum');
is_deeply( $seq->taps(), [17,2],                                '[17,2]->taps' );
is( $seq->period(), undef,                                      '[17,2]->period()                           = not defined yet' );
is( $seq->period('estimate'), 2**17-1,                          '[17,2]->period("estimate")                 = estimate 2**k-1' );
is( $seq->period('force'), undef,                               '[17,2]->period("force")                    = force, but up to default limit' );
is( $seq->period('forceBig'), 114_681,                          '[17,2]->period("forceBig")                 = force, compute the full sequence' );

#verify generate_all() / generate_to_end() limits: they use the same limits-function, because generate_all calls generate_to_end
$got = join '', @g = $seq->generate_all();
dz __LINE__, \@g; dz __LINE__, $got; dz __LINE__, $seq;
is( length($got),  65_535,                                      '[17,2]->generate_all()                     = string length @ default limit');
is( $seq->tell_i,  65_535,                                      '[17,2]->generate_all()                     = tell_i() @ default limit');

$got = join '', @g = $seq->generate_to_end( limit => 70_000);
dz __LINE__, \@g; dz __LINE__, $got; dz __LINE__, $seq;
is( length($got),   4_465,                                      '[17,2]->generate_to_end(limit=>70000)      = string length: 70000-65535');
is( $seq->tell_i,  70_000,                                      '[17,2]->generate_to_end(limit=>70000)      = tell_i()');

$got = join '', @g = $seq->generate_to_end( limit => 'max');  # 131_071 > 114_681, so enough room
dz __LINE__, \@g; dz __LINE__, $got; dz __LINE__, $seq;
is( length($got),  44_681,                                      '[17,2]->generate_to_end(limit=>2**17-1)    = string length: 70000-65535');
is( $seq->tell_i, 114_681,                                      '[17,2]->generate_to_end(limit=>2**17-1)    = tell_i()');

# need to verify limit => 'max' for a maximal [17,3], to make sure it computes correctly
$seq = Math::PRBS->new( taps => [17,3] );
dz __LINE__, \@g; dz __LINE__, $got; dz __LINE__, $seq;
$got = join '', @g = $seq->generate_all( limit => 'max');
dz __LINE__, \@g; dz __LINE__, $got; dz __LINE__, $seq;
is( length($got), 131_071,                                      '[17,3]->generate_all(limit=>2**17-1)       = string length');
is( $seq->tell_i, 131_071,                                      '[17,3]->generate_all(limit=>2**17-1)       = tell_i()');

done_testing();
__DATA__
With original array -> string
23      # size:430       total:678       obj:bless({ i => 0, lfsr => 65536, period => undef, start => 65536, taps => [17, 2] }, "Math::PRBS")
34      # size:524344    total:4325374   obj:big
34      # size:65568     total:65568     obj:big
34      # size:486       total:904       obj:bless({ i => 65535, lfsr => 77401, period => 114681, start => 65536, taps => [17, 2] }, "Math::PRBS")
39      # size:524344    total:783314    obj:big
39      # size:4499      total:4499      obj:big
39      # size:486       total:938       obj:bless({ i => 70000, lfsr => 88950, period => 114681, start => 65536, taps => [17, 2] }, "Math::PRBS")
44      # size:524344    total:3115842   obj:big
44      # size:44715     total:44715     obj:big
44      # size:486       total:938       obj:bless({ i => 114681, lfsr => 65536, period => 114681, start => 65536, taps => [17, 2] }, "Math::PRBS")
50      # size:524344    total:3115842   obj:big
50      # size:44715     total:44715     obj:big
50      # size:430       total:678       obj:bless({ i => 0, lfsr => 65536, period => undef, start => 65536, taps => [17, 3] }, "Math::PRBS")
52      # size:1153480   total:8755598   obj:big
52      # size:131104    total:131104    obj:big
52      # size:486       total:904       obj:bless({ i => 131071, lfsr => 65536, period => 131071, start => 65536, taps => [17, 3] }, "Math::PRBS")
