########################################################################
# Verifies the seek functions with a smallish PRBS: [5,2]
########################################################################
use 5.006;
use strict;
use warnings;
use Test::More;# tests => 15;

use Math::PRBS;

my ($seq);

$seq = Math::PRBS->new( taps => [5,2] );    # 1010111011000111110011010010000
is_deeply( $seq->taps(), [5,2],                                 'SEEK->new                          = x**5 + x**2 + 1' );

$seq->seek_to_i(15);
is( $seq->tell_i,                15,                            'SEEK->seek_to_i(15)                = find specific iterator value' );
is( $seq->tell_state,             3,                            'SEEK->tell_state                   = internal LFSR state' );

$seq->ith(7);
is( $seq->tell_i,                 7,                            'SEEK->ith(7)                       = verify backup and alias=ith()' );
is( $seq->tell_state,            23,                            'SEEK->tell_state                   = internal LFSR state' );

$seq->rewind();
$seq->seek_to_state(16);    # this is the rewind-state
is( $seq->tell_state,            16,                            'SEEK->seek_to_state(16)            = find specific LFSR state: the state it started on' );
is( $seq->tell_i,                 0,                            'SEEK->tell_i                       = iterator index' );
$seq->seek_to_state(29);
is( $seq->tell_state,            29,                            'SEEK->seek_to_state(29)            = find specific LFSR state: a different state than where it started' );
is( $seq->tell_i,                 9,                            'SEEK->tell_i                       = iterator index' );

$seq->seek_forward_n(5);
is( $seq->tell_i,                14,                            'SEEK->seek_forward_n(5)->tell_i    = go forward 5: old_i(9)+forward(5) => tell_i' );
is( $seq->tell_state,            17,                            'SEEK->tell_state                   = internal LFSR state' );

$seq->seek_forward_n(21);
is( $seq->tell_i,                35,                            'SEEK->seek_forward_n(21)->tell_i   = go forward 21' );
is( $seq->tell_state,            10,                            'SEEK->tell_state                   = internal LFSR state' );

$seq->seek_forward_n(31);   # move forward 1 period
is( $seq->tell_i,                66,                            'SEEK->seek_forward_n(31)->tell_i   = this i should be equivalent to previous i' );
is( $seq->tell_state,            10,                            'SEEK->tell_state                   = internal LFSR state' );

$seq->seek_to_i(4);         # i % 31
is( $seq->tell_i,                 4,                            'SEEK->seek_to_i(4)->tell_i         = this i should be equivalent to previous i' );
is( $seq->tell_state,            10,                            'SEEK->tell_state                   = internal LFSR state' );

done_testing();