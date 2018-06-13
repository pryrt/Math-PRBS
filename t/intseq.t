########################################################################
# Verifies the integer sequence generation
########################################################################
use 5.006;
use strict;
use warnings;
use Test::More ;#tests => 42;

use Math::PRBS;

my $seq = Math::PRBS->new( taps => [4,1] );
diag period => " => ", my $p = $seq->period( force => 'max' );
diag nbits  => " => ", my $n = $seq->nbits();
diag oeis   => " => ", $seq->oeis_anum();
diag seq    => " => ", $seq->generate_all();

my $bin; $bin = $seq->generate( $n ), diag "int#$_: ", $bin, " => ", oct("0b$bin") for 1 .. $p;

$seq->rewind();
is_deeply( [$seq->generate_int()], [15],                            '->generate_int() -- first (list)' );
is_deeply( [$seq->generate_int(4)], [5,9,1,14],                     '->generate_int(4) -- next four (list)' );
is( $seq->generate_int(), '11',                                     '->generate_int() -- next (scalar)' );
is( $seq->generate_int(4), '2,3,13,6',                              '->generate_int(4) -- next four (scalar)' );

done_testing();

# TODO: incorporate this into PRBS.pm
