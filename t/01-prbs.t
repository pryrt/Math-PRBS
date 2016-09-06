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

my $seq = Math::PRBS->new( prbs => 7 );
is( ref($seq), 'Math::PRBS',                                    'PRBS7: Create' );
is( $seq->description, 'PRBS from polynomial x**7 + x**6 + 1',    'PRBS7: ->description');
is( undef, undef,                                               'PRBS7: ->oeis_anum');
is_deeply( $seq->taps(), [7,6],                                 'PRBS7: ->taps          = x**7 + x**6 + 1' );
is( $seq->next(), '1',                                          'PRBS7: ->next: scalar  = v[i]       = first' );
is( $seq->tell_state, '1',                                      'PRBS7: ->tell_state    = internal LFSR state' );
is_deeply( [$seq->next()], ['1','0'],                           'PRBS7: ->next: list    = i, v[i]    = second' );
is( $seq->tell_i, '2',                                          'PRBS7: ->tell_i        = i advanced to 2 after ->next()' );
is( $seq->tell_state, '2',                                      'PRBS7: ->tell_state    = internal LFSR state' );
ok( !defined($seq->period()),                                   'PRBS7: ->period        = period should not be defined yet' );
is_deeply( [$seq->next()], ['2','0'],                           'PRBS7: ->next: list    = i, v[i]    = third' );
$seq->next()    until defined $seq->period();
is( $seq->tell_i, '127',                                        'PRBS7: ->tell_i        = end of sequence, because looped until period defined' );
is( $seq->tell_state, '64',                                     'PRBS7: ->tell_state    = internal LFSR state' );
ok( defined($seq->period()),                                    'PRBS7: ->period        = defined' );
is( $seq->period(), 2**7-1,                                     'PRBS7: ->period        = length of sequence' );
$seq->rewind();
is( $seq->tell_i, '0',                                          'PRBS7: ->rewind        = iterator reset to 0' );
is( $seq->tell_state, '64',                                     'PRBS7: ->tell_state    = internal LFSR state' );
ok( defined($seq->period()),                                    'PRBS7: ->period        = still defined' );
is( $seq->period(), '127',                                      'PRBS7: ->period        = still length of sequence' );
my $exp = '1000001100001010001111001000101100111010100111110100001110001001001101101011011110110001101001011101110011001010101111111000000';
my $got = ''; $got .= $seq->next() while !defined($seq->period()) || ($seq->tell_i < $seq->period());      # replace with $got = $seq->all()
is( $got, $exp,                                                 'PRBS7: ->all: scalar   = full sequence, as string');

$seq = Math::PRBS->new( prbs => 15 );
is( $seq->description, 'PRBS from polynomial x**15 + x**14 + 1',  'PRBS15: ->description');
is( $seq->oeis_anum, undef,                                     'PRBS15: ->oeis_anum');
is_deeply( $seq->taps(), [15,14],                               'PRBS15: ->taps         = x**15 + x**14 + 1' );
is( $seq->tell_state, '16384',                                  'PRBS15: ->tell_state   = internal LFSR state' );
$seq->next()    until defined $seq->period();
is( $seq->period(), 2**15-1,                                    'PRBS15: ->period       = length of sequence' );

$t = time();
diag("\n", "PRBS23: may take quite a few seconds");
$seq = Math::PRBS->new( prbs => 23 );
is( $seq->description, 'PRBS from polynomial x**23 + x**18 + 1',  'PRBS23: ->description');
is( $seq->oeis_anum, undef,                                     'PRBS23: ->oeis_anum');
is_deeply( $seq->taps(), [23,18],                               'PRBS23: ->taps         = x**23 + x**18 + 1' );
is( $seq->tell_state, '4194304',                                'PRBS23: ->tell_state   = internal LFSR state' );
$seq->next()    until defined $seq->period();
is( $seq->period(), 2**23-1,                                    'PRBS23: ->period       = length of sequence' );
diag( "PRBS23: Elapsed time: ", $dt=time()-$t, "sec");

$seq = Math::PRBS->new( prbs => 31 );
is( $seq->description, 'PRBS from polynomial x**31 + x**28 + 1',  'PRBS31: ->description');
is( $seq->oeis_anum, undef,                                     'PRBS32: ->oeis_anum');
is_deeply( $seq->taps(), [31,28],                               'PRBS31: ->taps         = x**31 + x**28 + 1' );
is( $seq->tell_state, '1073741824',                             'PRBS31: ->tell_state   = internal LFSR state' );
SKIP: {
    $dt *= 256;   # 2**31-1 / 2**23-1 =~ 2**8 = 256x as long
    my $str = sprintf 'PRBS31: estimate 2**31-1 iterations would take %dsec', $dt;
    skip $str, 1   if $dt > 60;
    diag( $str );
    $seq->next()    until defined $seq->period();
    is( $seq->period(), 2**31-1,                                'PRBS31: ->period       = length of sequence' );
}

$seq = Math::PRBS->new( taps => [3,2] );
is( $seq->description, 'PRBS from polynomial x**3 + x**2 + 1',    'taps => [3,2] ->description');
is( $seq->oeis_anum, 'A011656',                                 'taps => [3,2] ->oeis_anum');
is_deeply( $seq->taps(), [3,2],                                 'taps => [3,2] ->taps      = x**3 + x**2 + 1' );
$seq->next()    until defined $seq->period();
is( $seq->period(), 2**3-1,                                     'taps => [3,2] ->period    = length of sequence' );
$seq->reset();
$exp = '1011100';
$got = ''; $got .= $seq->next() while !defined($seq->period()) || ($seq->tell_i < $seq->period());      # replace with $got = $seq->all()
is( $got, $exp,                                                 'taps => [3,2] ->all       = full sequence, as string');

$seq = Math::PRBS->new( taps => [3,1] );
is( $seq->description, 'PRBS from polynomial x**3 + x**1 + 1',    'taps => [3,1] ->description');
is( $seq->oeis_anum, 'A011657',                                 'taps => [3,1] ->oeis_anum');
is_deeply( $seq->taps(), [3,1],                                 'taps => [3,1] ->taps      = x**3 + x**1 + 1' );
$seq->next()    until defined $seq->period();
is( $seq->period(), 2**3-1,                                     'taps => [3,1] ->period    = length of sequence' );
$seq->rewind();
$exp = '1110100';
$got = ''; $got .= $seq->next() while !defined($seq->period()) || ($seq->tell_i < $seq->period());      # replace with $got = $seq->all()
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
$got = ''; $got .= $seq->next() while !defined($seq->period()) || ($seq->tell_i < $seq->period());      # replace with $got = $seq->all()
is( $got, $exp,                                                 'taps => [3,2,1] ->all     = full sequence, as string');

$seq = Math::PRBS->new( poly => '110' );
is( $seq->description, 'PRBS from polynomial x**3 + x**2 + 1',    'poly => "110" ->description');
is_deeply( $seq->taps(), [3,2],                                 'poly => "110" ->taps      = x**3 + x**2 + 1' );
$seq->next()    until defined $seq->period();
is( $seq->period(), 2**3-1,                                     'poly => "110" ->period    = length of sequence' );
$seq->reset();
$exp = '1011100';
$got = ''; $got .= $seq->next() while !defined($seq->period()) || ($seq->tell_i < $seq->period());      # replace with $got = $seq->all()
is( $got, $exp,                                                 'poly => "110" ->all       = full sequence, as string');

$seq = Math::PRBS->new( poly => '101' );
is( $seq->description, 'PRBS from polynomial x**3 + x**1 + 1',    'poly => "101" ->description');
is_deeply( $seq->taps(), [3,1],                                 'poly => "101" ->taps      = x**3 + x**1 + 1' );
$seq->next()    until defined $seq->period();
is( $seq->period(), 2**3-1,                                     'poly => "101" ->period    = length of sequence' );
$seq->rewind();
$exp = '1110100';
$got = ''; $got .= $seq->next() while !defined($seq->period()) || ($seq->tell_i < $seq->period());      # replace with $got = $seq->all()
is( $got, $exp,                                                 'poly => "101" ->all       = full sequence, as string' );

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

# test for proper 'die'
eval { $seq = Math::PRBS->new( unknown => 1 ); }; chomp($@);
ok( $@ ,                                                        "new(unknown=>1) should fail due to invalid arguments: '$@'" );

eval { $seq = Math::PRBS->new( 15 ); }; chomp($@);
ok( $@ ,                                                        "new(15) should fail due to invalid arguments: '$@'" );
    # would need { no warnings qw(misc uninitialized); } in ->new() to prevent the warnings from printing
    #   misc: 'odd number of elements in hash assignment'
    #   uninitialized: 'use of uninitialized value $pairs{"15"} in join or string'

eval { $seq = Math::PRBS->new( prbs => 3 ); }; chomp($@);
ok( $@ ,                                                        "new(prbs=>3) should fail due to invalid standard prbs: '$@'" );

eval { $seq = Math::PRBS->new( taps => 3 ); }; chomp($@);
ok( $@ ,                                                        "new(taps=>3) should fail due to taps needing array ref: '$@'" );

eval { $seq = Math::PRBS->new( taps => [] ); }; chomp($@);
ok( $@ ,                                                        "new(taps=>[]) should fail due to taps needing at least one tap: '$@'" );

eval { $seq = Math::PRBS->new( poly => 'xyz' ); }; chomp($@);
ok( $@ ,                                                        "new(taps=>'xyz') should fail due to poly needing binary string: '$@'" );

eval { $seq = Math::PRBS->new( poly => '000' ); }; chomp($@);
ok( $@ ,                                                        "new(taps=>'000') should fail due to poly needing at least one tap: '$@'" );

done_testing();