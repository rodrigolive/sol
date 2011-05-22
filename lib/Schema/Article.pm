package Schema::Article;
use v5.10;
use Mongoose::Class;
with 'Mongoose::Document';
extends 'Base::Textile';

use DateTime;
use namespace::clean;

has_one 'title' => 'Str';
has_one 'url' => 'Str';
has_one 'type' => 'Str';
has_one 'body' => 'Str';  # preparsed html body
has_one 'text' => 'Str';  # original text
has_one 'user' => 'User', required=>1;
has_one 'domain' => 'Str';
has 'votes_up' => is=>'rw', isa=>'Num', default=>1;
has 'votes_down' => is=>'rw', isa=>'Num', default=>0;
has 'flagged' => is=>'rw', isa=>'Num', default=>0;
has 'ts' => is=>'rw', isa=>'DateTime', default=>sub{ DateTime->now };
has 'time' => is=>'rw', isa=>'Num', default=>sub{ time() };
#has_many 'comments'

sub BUILD {
    my $self = shift;
    $self->url ? $self->type('url') : $self->type('textile');
    $self->domain
        or $self->url ? $self->domain( $self->url ) : $self->domain( 'sol.org' );
}

sub votes {
    my $self = shift;
    return ( $self->votes_up // 1 )
        - ( $self->votes_down // 0 );
}

sub rank {
    my $self = shift;
    $self->votes // 1;
}

sub hours {
    my $self = shift;
    return defined $self->time ? 
        int( ( time() - ($self->time) ) / 3600 / 60 )
        : '?';
}

1;
