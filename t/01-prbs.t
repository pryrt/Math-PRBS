########################################################################
# Verifies major functionality
########################################################################
use 5.006;
use strict;
use warnings;
use Test::More tests => 13;

use Math::PRBS;


my $seq = Math::PRBS->new( prbs => 7 );
is( ref($seq), 'Math::PRBS', 'Create PRBS7' );
is( $seq->next(), '1', 'First Element of PRBS7' );
is_deeply( [$seq->next()], ['1','0'], 'Second Element of PRBS7' );
is( $seq->{i}, '2', 'Iterator should have advanced to 2' );
ok( !defined($seq->{period}), 'Period should not be defined yet' );
is_deeply( [$seq->next()], ['2','0'], 'Third Element of PRBS7' );
$seq->next()    until defined $seq->{period};
is( $seq->{i}, '127', 'Iterator should be at 127' );
ok( defined($seq->{period}), 'Period should be defined now' );
is( $seq->{period}, '127', 'Period should be 127' );
$seq->rewind();
is( $seq->{i}, '0', 'Iterator should be rewound to 0' );
ok( defined($seq->{period}), 'Period should still be defined' );
is( $seq->{period}, '127', 'Period should still be 127' );
my $exp = '1000001100001010001111001000101100111010100111110100001110001001001101101011011110110001101001011101110011001010101111111000000';
my $got = ''; $got .= $seq->next() while !defined($seq->{period}) || ($seq->{i} < $seq->{period});
is( $got, $exp, "whole PRBS7 string");