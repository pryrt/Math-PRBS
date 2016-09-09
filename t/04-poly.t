########################################################################
# Verifies new( poly => 'binstring' )
########################################################################
use 5.006;
use strict;
use warnings;
use Test::More;# tests => 15;

use Math::PRBS;

my ($seq, $exp, $got, @g);

$seq = Math::PRBS->new( poly => '110' );
is( $seq->description, 'PRBS from polynomial x**3 + x**2 + 1',    'poly => "110" ->description');
is_deeply( $seq->taps(), [3,2],                                 'poly => "110" ->taps      = x**3 + x**2 + 1' );
$seq->generate_to_end();   # $seq->next()    until defined $seq->period();
is( $seq->period(), 2**3-1,                                     'poly => "110" ->period    = length of sequence' );
$seq->reset();
$exp = '1011100';
$got = join '', $seq->generate_all();
is( $got, $exp,                                                 'poly => "110" ->all       = full sequence, as string');

$seq = Math::PRBS->new( poly => '101' );
is( $seq->description, 'PRBS from polynomial x**3 + x**1 + 1',    'poly => "101" ->description');
is_deeply( $seq->taps(), [3,1],                                 'poly => "101" ->taps      = x**3 + x**1 + 1' );
$seq->generate_to_end();   # $seq->next()    until defined $seq->period();
is( $seq->period(), 2**3-1,                                     'poly => "101" ->period    = length of sequence' );
$seq->rewind();
$exp = '1110100';
$got = join '', $seq->generate_all();
is( $got, $exp,                                                 'poly => "101" ->all       = full sequence, as string' );

done_testing();