package Schema::Session;
use v5.10;
use Mongoose::Class;
with 'Mongoose::Document';
use Digest::MD5;

has_one 'user' => 'User';
has_one 'session' => 'Any', required=>1;
has_one 'fnid' => 'Any';

sub BUILD {
    my $self = shift;

    my $id = md5_b64 $self->session;
    $self->fnid( $id );
}

1;
