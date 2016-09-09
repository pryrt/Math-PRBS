########################################################################
# Verifies new( taps => [list] )
########################################################################
use 5.006;
use strict;
use warnings;
use Test::More;# tests => 15;

use Math::PRBS;

my ($seq, $exp, $got, @g);

$seq = Math::PRBS->new( taps => [3,2] );
is( $seq->description, 'PRBS from polynomial x**3 + x**2 + 1',    'taps => [3,2] ->description');
is( $seq->oeis_anum, 'A011656',                                 'taps => [3,2] ->oeis_anum');
is_deeply( $seq->taps(), [3,2],                                 'taps => [3,2] ->taps      = x**3 + x**2 + 1' );
$seq->generate_to_end();   # $seq->next()    until defined $seq->period();
is( $seq->period(), 2**3-1,                                     'taps => [3,2] ->period    = length of sequence' );
$seq->reset();
$exp = '1011100';
$got = join '', $seq->generate_all();
is( $got, $exp,                                                 'taps => [3,2] ->all       = full sequence, as string');

$seq = Math::PRBS->new( taps => [3,1] );
is( $seq->description, 'PRBS from polynomial x**3 + x**1 + 1',    'taps => [3,1] ->description');
is( $seq->oeis_anum, 'A011657',                                 'taps => [3,1] ->oeis_anum');
is_deeply( $seq->taps(), [3,1],                                 'taps => [3,1] ->taps      = x**3 + x**1 + 1' );
$seq->generate_to_end();   # $seq->next()    until defined $seq->period();
is( $seq->period(), 2**3-1,                                     'taps => [3,1] ->period    = length of sequence' );
$seq->rewind();
$exp = '1110100';
$got = join '', $seq->generate_all();
is( $got, $exp,                                 'taps => [3,1] ->all       = full sequence, as string');

$seq = Math::PRBS->new( taps => [3,2,1] );
is( $seq->description, 'PRBS from polynomial x**3 + x**2 + x**1 + 1','taps => [3,2,1] ->description');
is( $seq->oeis_anum, undef,                                     'taps => [3,2,1] ->oeis_anum');
is_deeply( $seq->taps(), [3,2,1],                               'taps => [3,2,1] ->taps    = x**3 + x**2 + x**1 + 1' );
is( $seq->period(), undef,                                      'taps => [3,2,1] ->period  = not defined yet' );
is( $seq->period('estimate'), 7,                                'taps => [3,2,1] ->period("estimate"): 2**3-1' );
is( $seq->period('force'), 4,                                   'taps => [3,2,1] ->period("force"): force it to compute the full sequence' );
is( $seq->period(), 4,                                          'taps => [3,2,1] ->period: it has now been computed, so dont need "force" anymore' );
$seq->rewind();
$exp = '1100';
$got = join '', $seq->generate_all();
is( $got, $exp,                                                 'taps => [3,2,1] ->all     = full sequence, as string');

done_testing();