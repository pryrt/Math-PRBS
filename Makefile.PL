use ExtUtils::MakeMaker;
use 5.006;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
%mm_args = (
    'NAME'          => 'Math::PRBS',
    'AUTHOR'        => 'Peter C. jones <petercj AT cpan.org>',
    'VERSION_FROM'  => 'lib/Math/PRBS.pm',
    'ABSTRACT_FROM' => 'lib/Math/PRBS.pm',
    'PREREQ_PM'     => {
        'Exporter'      => 5.57,    # needed for `use Exporter qw(import);` notation
        'version'       => 0.77,
        'warnings'      => 0,
        'strict'        => 0,
        'Carp'          => 0,
    },
);

{
    no warnings;
    if( $ExtUtils::MakeMaker::VERSION >= '6.46' ) {
        $mm_args{META_MERGE} = {
            'meta-spec' => {
                version => '2',
                url     => 'http://search.cpan.org/perldoc?CPAN::Meta::Spec',
            },
            resources => {
                bugtracker => {
                    mailto  => 'bug-Math-PRBS@rt.cpan.org',
                    web     => 'https://github.com/pryrt/Math-PRBS/issues',
                },
                repository => {
                    url     => 'https://github.com/pryrt/Math-PRBS.git',
                    web     => 'https://github.com/pryrt/Math-PRBS',
                    type    => 'git',
                },
            },
            keywords => [ 'Pseudorandom Binary Sequence', 'PRBS', 'Linear Feedback Shift Register', 'LFSR'],
            # don't use 'provides', because it's an extra step to maintain, and
            # can cause problems (getting a mismatch between the $VERSION string and the
            # provides->{version} will really make it hard to release a next version into CPAN
        },
        # automatically determine the versions for 'provides'; MM->parse_version exists as of MM v6.31, so not a problem with >= 6.46
        my $v = MM->parse_version( $mm_args{VERSION_FROM} );    # valid back to MM v6.31, so not a problem with >= 6.46
        {
            $mm_args{META_MERGE}{provides} = {
                $mm_args{NAME} => {
                    file => $mm_args{VERSION_FROM},
                    version => "$v",                    # this comes out right when printed... but MYMETA.* shows values that look wrong
                }
            };
        }
    }
    if( $ExtUtils::MakeMaker::VERSION >= '6.31' ) {
        $mm_args{LICENSE} = 'perl_5';
    }
    if( $ExtUtils::MakeMaker::VERSION >= '6.48' ) {
        $mm_args{MIN_PERL_VERSION} = '5.6.0';
    }
    if( $ExtUtils::MakeMaker::VERSION >= '6.52' ) {
        $mm_args{CONFIGURE_REQUIRES} = {
            'ExtUtils::MakeMaker' => 0,
            'warnings' => 0,
            'strict' => 0,
            'Test::More' => 0.86,
            'constant' => 0,
            'Config' => 0,
        },
    }
    if( $ExtUtils::MakeMaker::VERSION >= '6.64' ) {
        $mm_args{TEST_REQUIRES} = {
            'warnings' => 0,
            'strict' => 0,
            'Test::More' => 0.86,
            'constant' => 0,
            'Config' => 0,
        };
    }
}

WriteMakefile( %mm_args )
