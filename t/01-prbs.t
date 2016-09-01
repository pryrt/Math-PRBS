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
is( ref($seq), 'Math::PRBS',                    'PRBS7: Create' );
is_deeply( $seq->{taps}, [7,6],                 'PRBS7: ->taps          = x^7 + x^6 + 1' );
is( $seq->next(), '1',                          'PRBS7: ->next: scalar  = v[i]       = first' );
is_deeply( [$seq->next()], ['1','0'],           'PRBS7: ->next: list    = i, v[i]    = second' );
is( $seq->tell_i, '2',                          'PRBS7: ->tell_i        = i advanced to 2 after ->next()' );
ok( !defined($seq->{period}),                   'PRBS7: ->period        = period should not be defined yet' );
is_deeply( [$seq->next()], ['2','0'],           'PRBS7: ->next: list    = i, v[i]    = third' );
$seq->next()    until defined $seq->{period};
is( $seq->tell_i, '127',                        'PRBS7: ->tell_i        = end of sequence, because looped until period defined' );
ok( defined($seq->{period}),                    'PRBS7: ->period        = defined' );
is( $seq->{period}, 2**7-1,                     'PRBS7: ->period        = length of sequence' );
$seq->rewind();
is( $seq->tell_i, '0',                          'PRBS7: ->rewind        = iterator reset to 0' );
ok( defined($seq->{period}),                    'PRBS7: ->period        = still defined' );
is( $seq->{period}, '127',                      'PRBS7: ->period        = still length of sequence' );
my $exp = '1000001100001010001111001000101100111010100111110100001110001001001101101011011110110001101001011101110011001010101111111000000';
my $got = ''; $got .= $seq->next() while !defined($seq->{period}) || ($seq->tell_i < $seq->{period});      # replace with $got = $seq->all()
is( $got, $exp,                                 'PRBS7: ->all: scalar   = full sequence, as string');

$seq = Math::PRBS->new( prbs => 15 );
is_deeply( $seq->{taps}, [15,14],               'PRBS15: ->taps         = x^15 + x^14 + 1' );
$seq->next()    until defined $seq->{period};
is( $seq->{period}, 2**15-1,                    'PRBS15: ->period       = length of sequence' );
diag( "Elapsed time: ", $dt=time()-$t, "sec");

$t = time();
diag("PRBS23: may take quite a few seconds");
$seq = Math::PRBS->new( prbs => 23 );
is_deeply( $seq->{taps}, [23,18],               'PRBS23: ->taps         = x^23 + x^18 + 1' );
$seq->next()    until defined $seq->{period};
is( $seq->{period}, 2**23-1,                    'PRBS23: ->period       = length of sequence' );
diag( "Elapsed time: ", $dt=time()-$t, "sec");

$seq = Math::PRBS->new( prbs => 31 );
is_deeply( $seq->{taps}, [31,28],               'PRBS31: ->taps         = x^31 + x^28 + 1' );
SKIP: {
    $dt *= 256;   # 2**31-1 / 2**23-1 =~ 2**8 = 256x as long
    my $str = sprintf 'PRBS31: estimate 2**31-1 iterations would take %dsec', $dt;
    skip $str, 1   if $dt > 60;
    diag( $str );
    $seq->next()    until defined $seq->{period};
    is( $seq->{period}, 2**31-1,                'PRBS31: ->period       = length of sequence' );
}

$seq = Math::PRBS->new( taps => [3,2] );
is_deeply( $seq->{taps}, [3,2],                 'taps => [3,2] ->taps      = x^3 + x^2 + 1' );
$seq->next()    until defined $seq->{period};
is( $seq->{period}, 2**3-1,                     'taps => [3,2] ->period    = length of sequence' );
$seq->reset();
$exp = '1011100';
$got = ''; $got .= $seq->next() while !defined($seq->{period}) || ($seq->tell_i < $seq->{period});      # replace with $got = $seq->all()
is( $got, $exp,                                 'taps => [3,2] ->all       = full sequence, as string');

$seq = Math::PRBS->new( taps => [3,1] );
is_deeply( $seq->{taps}, [3,1],                 'taps => [3,1] ->taps      = x^3 + x^1 + 1' );
$seq->next()    until defined $seq->{period};
is( $seq->{period}, 2**3-1,                     'taps => [3,1] ->period    = length of sequence' );
$seq->rewind();
$exp = '1110100';
$got = ''; $got .= $seq->next() while !defined($seq->{period}) || ($seq->tell_i < $seq->{period});      # replace with $got = $seq->all()
is( $got, $exp,                                 'taps => [3,1] ->all       = full sequence, as string');

$seq = Math::PRBS->new( taps => [3,2,1] );
is_deeply( $seq->{taps}, [3,2,1],               'taps => [3,2,1] ->taps    = x^3 + x^2 + x^1 + 1' );
$seq->next()    until defined $seq->{period};
is( $seq->{period}, 4,                          'taps => [3,2,1] ->period  = not a maximum length sequence' );
$seq->rewind();
$exp = '1100';
$got = ''; $got .= $seq->next() while !defined($seq->{period}) || ($seq->tell_i < $seq->{period});      # replace with $got = $seq->all()
is( $got, $exp,                                 'taps => [3,2,1] ->all     = full sequence, as string');

$seq = Math::PRBS->new( poly => '110' );
is_deeply( $seq->{taps}, [3,2],                 'poly => "110" ->taps      = x^3 + x^2 + 1' );
$seq->next()    until defined $seq->{period};
is( $seq->{period}, 2**3-1,                     'poly => "110" ->period    = length of sequence' );
$seq->reset();
$exp = '1011100';
$got = ''; $got .= $seq->next() while !defined($seq->{period}) || ($seq->tell_i < $seq->{period});      # replace with $got = $seq->all()
is( $got, $exp,                                 'poly => "110" ->all       = full sequence, as string');

$seq = Math::PRBS->new( poly => '101' );
is_deeply( $seq->{taps}, [3,1],                 'poly => "101" ->taps      = x^3 + x^1 + 1' );
$seq->next()    until defined $seq->{period};
is( $seq->{period}, 2**3-1,                     'poly => "101" ->period    = length of sequence' );
$seq->rewind();
$exp = '1110100';
$got = ''; $got .= $seq->next() while !defined($seq->{period}) || ($seq->tell_i < $seq->{period});      # replace with $got = $seq->all()
is( $got, $exp,                                 'poly => "101" ->all       = full sequence, as string' );

# test for proper 'die'
eval { $seq = Math::PRBS->new( unknown => 1 ); };
ok( $@ ,                                        "new(unknown=>1) should fail due to invalid arguments: $@" );

eval { $seq = Math::PRBS->new( 15 ); };
ok( $@ ,                                        "new(15) should fail due to invalid arguments: $@" );
    # would need { no warnings qw(misc uninitialized); } in ->new() to prevent the warnings from printing
    #   misc: 'odd number of elements in hash assignment'
    #   uninitialized: 'use of uninitialized value $pairs{"15"} in join or string'

eval { $seq = Math::PRBS->new( prbs => 3 ); };
ok( $@ ,                                        "new(prbs=>3) should fail due to invalid standard prbs: $@" );

eval { $seq = Math::PRBS->new( taps => 3 ); };
ok( $@ ,                                        "new(taps=>3) should fail due to taps needing array ref: $@" );

eval { $seq = Math::PRBS->new( taps => [] ); };
ok( $@ ,                                        "new(taps=>[]) should fail due to taps needing at least one tap: $@" );

eval { $seq = Math::PRBS->new( poly => 'xyz' ); };
ok( $@ ,                                        "new(taps=>'xyz') should fail due to poly needing binary string: $@" );

eval { $seq = Math::PRBS->new( poly => '000' ); };
ok( $@ ,                                        "new(taps=>'000') should fail due to poly needing at least one tap: $@" );

done_testing();