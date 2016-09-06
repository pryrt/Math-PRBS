# uses Math::PRBS to create Credence AWAV files of my PRBS signal:
#   one with normal encoding, and one with my interpretation of PAM-4
#   (which might be wrong): I am assuming that the two bits are combined
#   as p4 = 2*b0 + b1
use warnings;
use strict;
use autodie;
use lib '..\lib';
use Math::PRBS;

use constant Fs => 2805;                # scaled sampling rate
use constant Ts => 1.0/Fs;              # timestep
use constant Tp => 0.25;                # quarter-second per pulse (Time-pulse)
use constant Np => Tp * Fs;             # quarter-second per pulse times samples-per-second = number of samples for one pulse
use constant BW => Fs / 2.0;            # Nyquist
use constant PI => atan2(0,-1);         #
use constant tau => 1.0 / (2.0*PI*BW);  # tau = RC = 1 / (2pi BW)
use constant Nt => tau * Fs;            # Nt = number of samples in one tau=RC time constant


# for 10-90% rise time in an RC network, tr = tau * ln9 = ~0.35/BW
# tau = 1 / (2*pi*BW)

# incremental timesteps:
#   v_next += (v_target-v_prev)*(exp(-t_step / tau) * t_step/tau)
my($v2, $v4) = 0;
sub set2($)
{
    my $seq = shift;
    my $target = $seq->next;
    my $t = 0;
    print "! DATA = $target\n";
    for(my $t = 0; $t < Tp; $t += Ts ) {
        printf "%+24.16e; ! %15.7fsec | DATA=%d\n", $v2, $t, $target;
        $v2 += ($target - $v2) * exp(-Ts / tau) * (Ts / tau);
    }
}
sub set4($)
{
    my $seq = shift;
    my $target = $seq->next * 2 + $seq->next;     # 2*bit[0] + bit[1]
    my $t = 0;
    print "! DATA = $target\n";
    for(my $t = 0; $t < Tp; $t += Ts ) {
        printf "%+24.16e; ! %15.7fsec | DATA=%d\n", $v2, $t, $target;
        $v2 += ($target - $v2) * exp(-Ts / tau) * (Ts / tau);
    }
}

sub startAwav($$) {
    my $name = shift;
    my $seq = shift;
    open AWAV, '>', "$name.awav";
    select AWAV;
    my @lt = localtime;
    printf "%s %d %d %d;\n", 'version awav', 0, 2, 0;
    printf "%s %d %d %d;\n", date => $lt[4]+1, $lt[3], $lt[5]+1900;
    printf "%s %d %d %d;\n", time => @lt[2,1,0];
    printf "%s = %s;\n", name => qq|"$name"|;
    printf "%s = %s;\n", type => 'rrect';
    printf "%s = %s;\n", size => Np * 4 * $seq->{period};
    printf "%s = %.6e;\n", sample_interval => Ts;
    printf "%s = %.6e;\n", offset => 0;
    printf "%s = %s;\n", x_units => '"s "';
    printf "%s = %s;\n", y_units => '"V "';
    print  "pattern;\n";
}
sub stopAwav() {
    print AWAV "pattern_end;\n";
    select STDOUT;
    close AWAV;
}

###########
my $prbs = Math::PRBS->new( taps => [3,2] );   # PRBS-3: k=3, N=7
$prbs->next while !defined $prbs->{period};

startAwav('prbs3', $prbs);
$prbs->rewind;
set2($prbs) while( $prbs->tell_i < 4*$prbs->{period} );
stopAwav();

startAwav('prbs3pam4', $prbs);
$prbs->rewind;
set4($prbs) while( $prbs->tell_i < 4*2*$prbs->{period} );
stopAwav();

###########
$prbs = Math::PRBS->new( taps => [5,3] );   # PRBS-5: k=5, N=31
$prbs->next while !defined $prbs->{period};

startAwav('prbs5', $prbs);
$prbs->rewind;
set2($prbs) while( $prbs->tell_i < 4*$prbs->{period} );
stopAwav();

startAwav('prbs5pam4', $prbs);
$prbs->rewind;
set4($prbs) while( $prbs->tell_i < 4*2*$prbs->{period} );
stopAwav();

###########
$prbs = Math::PRBS->new( prbs => 7 );   # PRBS-7: k=7, N=127
$prbs->next while !defined $prbs->{period};

startAwav('prbs7', $prbs);
$prbs->rewind;
set2($prbs) while( $prbs->tell_i < 4*$prbs->{period} );
stopAwav();

startAwav('prbs7pam4', $prbs);
$prbs->rewind;
set4($prbs) while( $prbs->tell_i < 4*2*$prbs->{period} );
stopAwav();

exit;
