package Role::Timed;
use Moose::Role;
use DateTime;

has 'ts' => ( is => 'rw', isa => 'Num', default => sub { time() } );
has 'ts1' => (
    is       => 'rw',
    isa      => 'DateTime',
    required => 1,
    default  => sub { DateTime->now }
);
has 'ts2' => ( is => 'rw', isa => 'DateTime' );

sub minutes {
    my $self = shift;
    return '?' unless defined $self->ts1;
    return int( ( time - $self->ts1->epoch ) / 60 );
}

sub hours {
    my $self = shift;
    my $min = $self->minutes;
    return $min ne '?' ? int( $min / 60 ) : $min;
}

sub hours_fast {
    my $self = shift;
    return defined $self->ts ? 
        int( ( time() - ($self->ts) ) / 60 / 60 )
        : '?';
}

sub make_time {
    my $self = shift;
    my $min = $self->minutes;
    return { val=>$min, name=>'minutos' } if $min < 60;
    return { val=>int($min/60), name=>'horas' } if $min < 1440;
    return { val=>int($min/1440), name=>'d&iacute;as' } if $min > 1440;
}

1;
