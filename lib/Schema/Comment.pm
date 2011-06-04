package Schema::Comment;
use v5.10;
use Mongoose::Class; with 'Mongoose::Document';

has_one 'user'    => 'Schema::User';
has_one 'article' => 'Schema::Article';

with 'Role::Textile';
with 'Role::Timed';
with 'Role::Leaf';
with 'Role::Votable';

sub BUILD {
    my $self = shift;
    $self->parse_mini( $self->text );
}

1;


