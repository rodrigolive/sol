package Schema::User;
use v5.10;
use Mongoose::Class;
with 'Mongoose::Document';
use Digest::MD5 qw/md5_base64/;

has_one 'name'     => 'Str';
has_one 'karma'    => 'Num', default=>0;
has_one 'about'    => 'Any';
has_one 'password' => 'Str', required => 1;
has_one 'email'    => 'Str';
has_one 'created_on' => 'DateTime', default=>sub { DateTime->now };
has_one 'last_login' => 'DateTime';
has_one 'registrar' => 'Any', default=>'local';  # local, facebook, ...
has_one 'salt'     => 'Any',
    default => sub { md5_base64( time() * int rand 10000000 ) };

around 'BUILDARGS' => sub {
    my $orig  = shift;
    my $class = shift;
    $class->$orig(@_);
};

sub BUILD {
    my $self = shift;
    $self->password( md5_base64( join ',', $self->salt, $self->password ) );
}

sub check {
    my ( $self, $password ) = @_;
    return $self->password eq md5_base64( join ',', $self->salt, $password );
}

1;

