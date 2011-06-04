package Role::Textile;
use Moose::Role;
use String::Clean::XSS;
use Text::Textile qw(textile);

has 'body'    => is=>'rw', isa=>'Str'; # html
has 'text'    => is=>'rw', isa=>'Str';

sub parse_textile {
    my $self = shift;
    $self->body( textile( clean_XSS( shift // '' ) ) );
}

sub parse_mini {
    my $self = shift;
    my $text = shift;
    $text = convert_XSS $text;
    $text =~s{\*(.+?)\*}{<b>$1</b>}g;
    $text =~s{_(.+?)_}{<i>$1</i>}g;
    $self->body( $text );
}

1;


