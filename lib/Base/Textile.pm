package Base::Textile;
use Moose;
use Text::Textile qw(textile);

sub parse_textile {
    my $self = shift;
    $self->body( textile( shift // '' ) );
}

sub parse_mini {
    my $self = shift;
    my $text = shift;
    $text =~s{\*(.+?)\*}{<b>$1</b>}g;
    $text =~s{_(.+?)_}{<i>$1</i>}g;
    $self->body( $text );
}

1;

