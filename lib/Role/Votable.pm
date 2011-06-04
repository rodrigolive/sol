package Role::Votable;
use Moose::Role;

has 'votes_up' => is=>'rw', isa=>'Num', default=>1;
has 'votes_down' => is=>'rw', isa=>'Num', default=>0;

sub votes {
    my $self = shift;
    return ( $self->votes_up // 1 )
        - ( $self->votes_down // 0 );
}

sub rank {
    my $self = shift;
    $self->votes // 1;
}
1;
