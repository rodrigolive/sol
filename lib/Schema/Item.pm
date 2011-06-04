package Schema::Item;
use v5.10;
use Mongoose::Class; with 'Mongoose::Document';

has_one 'item' => 'Role::Leaf';
has_one 'parent' => 'Schema::Item';
has 'level'   => is=>'rw', isa=>'Num', default=>0, traits=>['DoNotMongoSerialize'];

sub tree {
    my ($self, $lev) = @_;
    $lev //= 0;
    my @children;
    my $id = $self->{_id};
    $self->find({ 'parent.$id'=>$id })->each( sub{
        my $leaf = shift;
        my $tree = $leaf->tree( $lev + 1 );
        push @children, { %$leaf, level=>$lev, children=>$tree };
    });
    return \@children;
}

sub flat_tree {
    my ($self, $lev) = @_;
    $lev //= 0;
    my @children;
    my $id = $self->{_id};
    $self->find({ 'parent.$id'=>$id })->each( sub{
        my $leaf = shift;
        $leaf=bless($leaf, ref($self)) if ref $leaf eq 'HASH';
        my @tree = $leaf->flat_tree( $lev + 1 );
        $leaf->level( $lev || 0 );
        push @children, $leaf;
        push @children, @tree; 
    });
    return @children;
}

sub children_count {
    my ($self) = @_;
    my $cnt=0;
    my $id = $self->{_id};
    $self->find({ 'parent.$id'=>$id })->each( sub{
        my $leaf = shift;
        $cnt++;
        $cnt += $leaf->tree;
    });
    return $cnt;
}


1;
