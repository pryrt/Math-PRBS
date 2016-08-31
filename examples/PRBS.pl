use warnings;
use strict;
use Data::Dumper;
use Math::PRBS;

$" = ", ";
$, = "; ";
$\ = "\n";

my $seq;

# MLS x^3 + x^2 + 1
$seq = Math::PRBS->new( poly => '110' );
print $seq->next(), $seq->{period}//'<undef>' while !defined($seq->{period});

# short-sequence x^3 + x^2 + x^1 + 1
$seq = Math::PRBS->new( taps => [1..3] );
print $seq->next(), $seq->{period}//'<undef>' while !defined($seq->{period});

# PRBS7
$seq = Math::PRBS->new( prbs => 7 );
$seq->next() while !defined($seq->{period});
$seq->next();
print Dumper($seq);
$seq->rewind();
print Dumper($seq);
my $exp = '1000001100001010001111001000101100111010100111110100001110001001001101101011011110110001101001011101110011001010101111111000000';
my $got = '';
$got .= $seq->next() for (1..$seq->{period});
print $exp eq $got ? 'ok' : 'FAIL';

# first 127 bits of PRBS31
$seq = Math::PRBS->new( prbs => 31 );
$got = '';
$got .= $seq->next() for (0..126);
print "PRBS31[0..126]", $got;
print Dumper($seq);

exit;