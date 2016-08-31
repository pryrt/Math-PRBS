=head1 NAME

Math::PRBS - Generate Pseudorandom Binary Sequences using an Iterator-based Linear Feedback Shift Register

=cut
package Math::PRBS;
use warnings;
use strict;

use version 0.77; our $VERSION = version->declare('0.001_001');

=head1 SYNOPSIS

    use Math::PRBS;
    my $x3x2  = Math::PRBS->new( taps => [3,2] );
    my $prbs7 = Math::PRBS->new( prbs => 7 );
    my ($i, $value) = $x3x2t->next();
    my @p7 = $prbs7->all();

=head1 DESCRIPTION

This module will generate various Pseudorandom Binary Sequences (PRBS).  The sequences is a series of 0s and 1s which appears random for a certain length, and then repeats thereafter.

It is implemented using an XOR-based Linear Feedback Shift Register (LFSR), which is described using a feedback polynomial (or reciprocal characteristic polynomial).  The terms that appear in the polynomial are called the 'taps', because you tap off of that bit of the shift register for generating the feedback for the next value in the sequence.

This module creates a iterator object, and you can use that object to generate the sequence one value at a time, or I<en masse>.

=head1 FUNCTIONS AND METHODS

=head2 Initiating a Sequence

=over

=item C<$seq = Math::PRBS::new( I<key =E<gt> value> )>

Creates the sequence iterator C<$seq> using one of the C<key =E<gt> value> pairs described below.

=cut

sub new {
    my ($class, %pairs) = @_;
    my $self = bless { lfsr => 0, start => 0, i => 0, period => undef, taps => [] }, $class;

=over

=item C<prbs =E<gt> I<n>>

C<prbs> needs an integer I<n> to indicate one of the "standard" PRBS polynomials.

    # example: PRBS7 = x^7 + x^6 + 1
    $seq = Math::PRBS::new( ptbs => 7 );

The "standard" PRBS polynomials implemented are

    polynomial      | prbs       | taps            | poly (string)
    ----------------+------------+-----------------+---------------
    x^7 + x^6 + 1   | prbs => 7  | taps => [7,6]   | poly => '1100000'
    x^15 + x^14 + 1 | prbs => 15 | taps => [15,14] | poly => '110000000000000'
    x^23 + x^18 + 1 | prbs => 23 | taps => [23,18] | poly => '10000100000000000000000'
    x^31 + x^28 + 1 | prbs => 31 | taps => [31,28] | poly => '1001000000000000000000000000000'

=cut

    if( exists $pairs{prbs} )
    {
        my %prbs = (
            7  => [7,6]  ,
            15 => [15,14],
            23 => [23,18],
            31 => [31,28],
        );
        die __PACKAGE__."::new(prbs => '$pairs{prbs}'): standard PRBS include 7, 15, 23, 31" unless exists $prbs{ $pairs{prbs} };
        $self->{taps} = [ @{ $prbs{ $pairs{prbs} } } ];
    }

=item C<taps =E<gt> [ I<tap>, I<tap>, ... ]>

C<taps> needs an array reference containing the powers in the polynomial that you tap off for creating the feedback. Do I<not> include the C<0> for the C<x^0 = 1> in the polynomial; that's automatically included.

    # example: x^3 + x^2 + 1
    #   3 and 2 are taps, 1 is not tapped, 0 is implied feedback
    $seq = Math::PRBS::new( taps => [3,2] );

=cut

    elsif( exists $pairs{taps} )
    {
        die __PACKAGE__."::new(taps => $pairs{taps}): argument should be an array reference" unless 'ARRAY' eq ref($pairs{taps});
        $self->{taps} = [ reverse sort @{ $pairs{taps} } ];     # taps in descending order
    }

=item C<poly =E<gt> '...'>

C<poly> needs a string for the bits C<k> ... C<1>), with a 1 indicating the power is included in the list, and a 0 indicating it is not.

    # example: x^3 + x^2 + 1
    #   3 and 2 are taps, 1 is not tapped, 0 is implied feedback
    $seq = Math::PRBS::new( poly => '110' );

=cut

    elsif( exists $pairs{poly} )
    {
        local $_ = $pairs{poly};    # used for implicit matching in die-unless and while-condition
        die __PACKAGE__."::new(poly => '$pairs{poly}'): argument should be an binary string" unless /^[01]*$/;
        my @taps = ();
        my $l = length;
        while( m/([01])/g ) {
            push @taps, $l - pos() + 1     if $1;
        }
        $self->{taps} = [ reverse sort @taps ];
        die __PACKAGE__."::new(poly => '$pairs{poly}'): need at least one tap" unless @taps;
    }

=back

=item C<$seq-E<gt>reset()>

Resets the sequence back to the starting state.  The next call to C<next()> will be the initial C<$i,$value> again.

=cut

sub reset {
    my $self = shift;
    $self->{lfsr} = $self->{start};
    $self->{i} = 0;
    return $self;
}

=back

=cut

    $self->{lfsr} = oct('0b1' . '0'x($self->{taps}[0] - 1));
    $self->{start} = $self->{lfsr};

    return $self;
}

=head2 Iterating

=over

=item C<$value = $seq-E<gt>next()>

=item C<($i, $value) = $seq-E<gt>next()>

Computes the next value in the sequence.  (Optionally, in list context, also returns the current value of the i for the sequence.)

=cut

sub next {
    my $self = shift;
    my $newbit = 0;
    my $mask = oct( '0b' . '1'x($self->{taps}[0]) );
    my $i = $self->{i};
    ++ $self->{i};

    $newbit ^= ( $self->{lfsr} >> ($_-1) ) & 1 for @{ $self->{taps} };

    $self->{lfsr} = (($self->{lfsr} << 1) | $newbit) & $mask;

    $self->{period} = $i+1        if $i && !defined($self->{period}) && ($self->{lfsr} eq $self->{start});

    return wantarray ? ( $i , $newbit ) : $newbit;
}

=item C<$seq-E<gt>rewind()>

Rewinds the sequence back to the starting state.  The subsequent call to C<next()> will be the initial C<$i,$value> again.
(This is actually an alias for C<reset()>).

=cut

BEGIN { *rewind = \&reset; }

=back

=head1 THEORY

A pseudorandom binary sequence (PRBS) is the sequence of N unique bits, in this case generated from an LFSR.  Once it generates the N bits, it loops around and repeats that seqence.  While still within the unique N bits, the sequence of N bits shares some properties with a truly random sequence of the same length.  The benefit of this sequence is that, while it shares statistical properites with a random sequence, it is actually deterministic, so is often used to deterministically test hardware or software that requires a data stream that needs pseudorandom properties.

In an LFSR, the polynomial description (like C<x^3 + x^2 + 1>) indicates which bits are "tapped" to create the feedback bit: the taps are the powers of x in the polynomial (3 and 2).  The C<1> is really the C<x^0> term, and isn't a "tap", in the sense that it isn't used for generating the feedback; instead, that is the location where the new feedback bit comes back into the shift register; the C<1> is in all characteristic polynomials, and is implied when creating a new instance of B<Math::PRBS>.

If the largest power of the polynomial is C<k>, there are C<k+1> bits in the register (one for each of the powers C<k..1> and one for the C<x^0 = 1>'s feedback bit).  For any given C<k>, the largest sequence that can be produced is C<N = 2^k - 1>, and that sequence is called a maximum length sequence (MLS); there can be more than one MLS for a given C<k>.  One useful feature of an MLS is that if you divide it into every possible partial sequence that's C<k> bits long (wraping from N-1 to 0 to make the last few partial sequences also C<k> bits), you will generate every possible combination of C<k> bits, except for C<k> zeroes in a row.  For example,

    # x^3 + x^2 + 1 = "1011100"
    "_101_1100 " -> 101
    "1_011_100 " -> 011
    "10_111_00 " -> 111
    "101_110_0 " -> 110
    "1011_100_ " -> 100
    "1_0111_00 " -> 001 (requires wrap to get three digits: 00 from the end, and 1 from the beginning)
    "10_1110_0 " -> 010 (requires wrap to get three digits: 0 from the end, and 10 from the beginning)

The Wikipedia:LFSR article (see L</REFERENCES>) lists some polynomials that create MLS for various register sizes, and links to Philip Koopman's complete list up to C<k=64>.

Since a maximum length sequence contains every k-bit combination (except all zeroes), it can be used for verifying that software or hardware behaves properly for every possible sequence of k-bits.

=head1 REFERENCES

=over

=item * Wikipedia:Linear-feedback Shift Register (LFSR) at L<https://en.wikipedia.org/wiki/Linear-feedback_shift_register>

=over

=item * Contains a list of some L<maximum length polynomials|https://en.wikipedia.org/wiki/Linear-feedback_shift_register#Some_polynomials_for_maximal_LFSRs>

=item * Links to Philip Koopman's complete list of MLS polynomials, up to C<k = 64> at L<https://users.ece.cmu.edu/~koopman/lfsr/index.html>

=back

=item * Wikipedia:Pseudorandom Binary Sequence (PRBS) at L<https://en.wikipedia.org/wiki/Pseudorandom_binary_sequence>

=over

=item * The underlying algorithm in B<Math::PRBS> is based on the C code in L<this article's "Practical Implementation"|https://en.wikipedia.org/w/index.php?title=Pseudorandom_binary_sequence&oldid=700999060#Practical_implementation>

=back

=item * Wikipedia:Maximum Length Sequence (MLS) at L<https://en.wikipedia.org/wiki/Maximum_length_sequence>

=back

=cut

1;