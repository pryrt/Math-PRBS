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
my ($seq, $exp, $got, @g);

$seq = Math::PRBS->new( prbs => 7 );
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
$seq->generate_to_end();   # $seq->next()    until defined $seq->period();
is( $seq->tell_i, '127',                                        'PRBS7: ->tell_i        = end of sequence, because looped until period defined' );
is( $seq->tell_state, '64',                                     'PRBS7: ->tell_state    = internal LFSR state' );
ok( defined($seq->period()),                                    'PRBS7: ->period        = defined' );
is( $seq->period(), 2**7-1,                                     'PRBS7: ->period        = length of sequence' );
$seq->rewind();
is( $seq->tell_i, '0',                                          'PRBS7: ->rewind        = iterator reset to 0' );
is( $seq->tell_state, '64',                                     'PRBS7: ->tell_state    = internal LFSR state' );
ok( defined($seq->period()),                                    'PRBS7: ->period        = still defined' );
is( $seq->period(), '127',                                      'PRBS7: ->period        = still length of sequence' );
$exp = '1000001100001010001111001000101100111010100111110100001110001001001101101011011110110001101001011101110011001010101111111000000';
########123456789_123456789_123456789_123456789_123456789_123456789_123456789_123456789_123456789_123456789_123456789_123456789_1234567
$got = $seq->generate_all();
is( $got, $exp,                                                 'PRBS7: ->generate_all(): scalar            = full sequence, as string');
$got = $seq->generate(90);                                      # generate the next 90 as string
is( $got, substr($exp,0,90),                                    'PRBS7: ->generate(): scalar                = generate next 90 as scalar');
@g = $seq->generate(10);                                        # generate the next 10 as array
is_deeply( [@g], [1,0,0,1,0,1,1,1,0,1],                         'PRBS7: ->generate(): array                 = generate next 10 as array');
$got = join '', $seq->generate_to_end();                        # continue all should mod the i, and then continue to the end
is( $got, substr($exp,100),                                     'PRBS7: ->generate_to_end(): scalar            = after skipping first 100');
$seq->generate(111);                                            # move 111 beyond end of sequence
@g = $seq->generate_to_end(rewind => 0);                        # continue all should mod the i, and then continue to the end
is_deeply( [@g], [0,1,0,1,1,1,1,1,1,1,0,0,0,0,0,0],             'PRBS7: ->generate_to_end(rewind => 0): array = after skipping first 111');
$seq->generate(107);                                            # move 107 beyond end of sequence
$got = join '', $seq->generate_to_end(rewind => 1);             # continue all should mod the i, and then continue to the end
is( $got, $exp,                                                 'PRBS7: ->generate_to_end(rewind => 1): scalar = after skipping first 107, rewind and grab all');

$seq = Math::PRBS->new( prbs => 15 );
is( $seq->description, 'PRBS from polynomial x**15 + x**14 + 1',  'PRBS15: ->description');
is( $seq->oeis_anum, undef,                                     'PRBS15: ->oeis_anum');
is_deeply( $seq->taps(), [15,14],                               'PRBS15: ->taps         = x**15 + x**14 + 1' );
is( $seq->tell_state, '16384',                                  'PRBS15: ->tell_state   = internal LFSR state' );
$seq->generate_to_end();   # $seq->next()    until defined $seq->period();
is( $seq->period(), 2**15-1,                                    'PRBS15: ->period       = length of sequence' );

$t = time();
diag("\n", "PRBS23: may take quite a few seconds");
$seq = Math::PRBS->new( prbs => 23 );
is( $seq->description, 'PRBS from polynomial x**23 + x**18 + 1',  'PRBS23: ->description');
is( $seq->oeis_anum, undef,                                     'PRBS23: ->oeis_anum');
is_deeply( $seq->taps(), [23,18],                               'PRBS23: ->taps         = x**23 + x**18 + 1' );
is( $seq->tell_state, '4194304',                                'PRBS23: ->tell_state   = internal LFSR state' );
$seq->generate_to_end();   # default limit: 65535 = not long enough
is( $seq->period(), undef,                                      'PRBS23: ->generate_to_end, ->period = should hit limit => 65535' );
is( $seq->tell_i, '65535',                                      'PRBS23: ->tell_i       = hit 65535 limit' );
$seq->generate_to_end( limit => 2**23 );   # $seq->next()    until defined $seq->period();
is( $seq->period(), 2**23-1,                                    'PRBS23: ->generate_to_end(limit = 2**23), ->period = should find actual length of sequence' );
is( $seq->tell_i, 2**23-1,                                      'PRBS23: ->tell_i       = found the whole sequence' );
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

done_testing();