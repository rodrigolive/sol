package Schema::Comment;
use v5.10;
use Mongoose::Class;
with 'Mongoose::Document';
use Digest::MD5 qw/md5_base64/;

has_one 'user'    => 'User';
has_one 'article' => 'Article';
has_one 'parent' => 'Comment';
has_one 'body'    => 'Str';
has_one 'text'    => 'Str';
has_one 'created_on'    => 'DateTime', default=>sub{ DateTime->now } ;
has_one 'ts' => 'Num', default=>sub { time() };

extends 'Base::Textile';

sub BUILD {
    my $self = shift;
    $self->parse_textile( $self->text );
}

sub article_tree {
    my ($self,$article) = @_;
    my @comments;
    Comment->find({ 'article.$id'=>$article->{_id} })->each( sub{
        my $comm = shift;
        my @children = $comm->children;
        push @comments, { %$comm, children=>\@children };
    });
}

1;


