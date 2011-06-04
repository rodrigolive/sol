package Schema::Article;
use v5.10;
use Mongoose::Class; with 'Mongoose::Document';
use URI;
use Try::Tiny;

use DateTime;
use namespace::clean;

has_one 'title' => 'Str', required=>1;
has_one 'url' => 'Str';
has_one 'type' => 'Str';
has_one 'user' => 'Schema::User', required=>1;
has_one 'domain' => 'Str';
has 'flagged' => is=>'rw', isa=>'Num', default=>0;
#has_many 'comments'

with 'Role::Textile';
with 'Role::Timed';
with 'Role::Leaf';
with 'Role::Votable';

sub BUILD {
    my $self = shift;
    $self->url ? $self->type('url') : $self->type('textile');
    $self->domain
        or $self->url
        ? do { try { $self->domain( URI->new($self->url)->host ) } catch { die 'Invalid URL' } }
        : $self->domain( 'participasol.org' );
}

1;
