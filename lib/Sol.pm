package Sol;
use Dancer ':syntax';

our $VERSION = '0.1';
use Mongoose;
Mongoose->db('sol');
Mongoose->naming( [ 'short', 'lower' ] );
Mongoose->load_schema( search_path => 'Schema', shorten => 1 );
require MongoDB::OID;
use URI::Encode 'uri_encode';

use Controller::Users;

sub current_user {
    die 'User not logged in' unless session->{user};
    User->find_one( { name => session->{username} } ) or die 'User not found';
}

before_template sub {
    shift->{user} = current_user; 
};

get '/' => sub {
    my @articles;
    my $cnt   = 0;
    my $skip  = params->{skip} || 0;
    my $limit = 30;

    session->{id} or die "no session id";
    Article->find->sort( { rank => 1 } )->limit($limit)->skip($skip)->each(
        sub {
            my $article = shift;

     #debug '++++++++++++++++' . $article->user->find_one if ref $article->user;
            push @articles,
              {
                %$article,
                id    => "" . $article->_id,
                votes => $article->votes,
                rank  => $article->rank,
                t     => $article->make_time,
              };
        }
    );
    @articles = sort { $b->{rank} <=> $a->{rank} } @articles;
    template 'articles',
      {
        session  => session,
        articles => \@articles,
        skip     => @articles < $limit ? 0 : $skip + $limit,
      };
};

get '/newest' => sub {
    my @articles;
    my $cnt   = 0;
    my $skip  = params->{skip} || 0;
    my $limit = 30;

    Article->find->sort( { ts => -1 } )->limit($limit)->skip($skip)->each(
        sub {
            my $article = shift;
            push @articles,
              {
                %$article,
                id    => "" . $article->_id,
                votes => $article->votes,
                rank  => $article->rank,
                t     => $article->make_time,
              };
        }
    );
    template 'articles',
      {
        articles => \@articles,
        skip     => @articles < $limit ? 0 : $skip + $limit,
      };
};

get '/newcomments' => sub {
    my @comments;
    my $cnt   = 0;
    my $skip  = params->{skip} || 0;
    my $limit = 30;

    Comment->find->sort( { ts => -1 } )->limit($limit)->skip($skip)->each(
        sub {
            my $comment = shift;
            push @comments,
              {
                %$comment,
                id            => "" . $comment->_id,
                votes         => $comment->votes,
                rank          => $comment->rank,
                t             => $comment->make_time,
                article_title => $comment->article->title,
                article_id    => $comment->article->_id . "",
              };
        }
    );
    template 'comments',
      {
        skip => @comments < $limit ? 0 : $skip + $limit,
        comments => \@comments,
      };
};

get '/submit' => sub {
    forward '/login' unless session->{user};
    template 'submit', {};
};

post '/submit' => sub {
    my $user = current_user;
    params->{title} or die 'Missing title';
    my $article = Article->new( %{ params() }, user => $user );
    $article->parse_textile( params->{text} );
    $article->save;

    redirect '/';
};

get '/xx' => sub {
    my $c = Comment->find_one('4ddb88d63b8fecfb18000003');
    (time - $c->ts ) . '<pre>' . YAML::Dump $c;
};

get '/del' => sub {
    my $user = current_user;
    die "Now permission" unless $user->is_admin;
    my $item = Article->find_one( params->{id} )
      || Comment->find_one( params->{id} );
    die "Not found" unless $item;
    $item->delete;
    redirect '/item?id=' . $item->parent->id if $item->parent;
    redirect '/';
};

post '/comment' => sub {
    my $user = current_user;
    if ( my $item = Article->find_one( params->{item} ) ) {
        my $comm = Comment->new(
            article => $item,
            parent  => $item,
            text    => params->{text},
            user    => $user
        );
        debug YAML::Dump $comm;
        $comm->save;
    }
    elsif ( my $parent = Comment->find_one( params->{item} ) ) {
        my $comm = Comment->new(
            article => $parent->article,
            parent  => $parent,
            text    => params->{text},
            user    => $user
        );
        $comm->save;
    }
    else {
        die "Parent not found";
    }
    redirect '/item?id=' . params->{item};
};

get '/item' => sub {
    my $user = current_user;
    my $item = Article->find_one( params->{id} )
      || Comment->find_one( params->{id} );
    die "Not found" unless ref $item;

    # get comments and flatten
    my @comments = Comment->find( { 'parent.$id' => $item->{_id} } )->all;

    #debug YAML::Dump \@comments;
    my @tree;
    for (@comments) {
        push @tree, $_;
        push @tree, $_->flat_tree(1);
    }

    #debug YAML::Dump \@tree;

    # rebuild comments
    @comments = map {
        +{
            %$_,
            level => $_->{level} || 0,
            t => $_->make_time(),
            id    => "" . $_->{_id},
          }
    } @tree;

    template 'item',
      {
        item => {
            %$item,
            children_count => $item->children_count,
            parent_id => defined $item->parent ? $item->parent->_id . "" : '',
            id        => "" . $item->_id,
            votes     => $item->votes,
            rank      => $item->rank,
            t         => $item->make_time,
        },
        comments => \@comments,
      };
};

get '/reply' => sub {
    my $comment = Comment->find_one( params->{id} );
    die "Not found" unless ref $comment;
    template 'item' => {
        item => {
            %$comment,
            id        => "" . $comment->_id,
            parent_id => defined $comment->parent
            ? $comment->parent->_id . ""
            : '',

            #votes => $article->votes,
            #rank  => $article->rank,
            t     => $comment->make_time,
        },

        #comments => \@comments,
    };
};

get '/vote' => sub {
    my $article = Article->find_one( params->{for} );

    #Event->find_one({ article=>$article, user=>$user });
    if ( ref $article ) {
        die "Can't vote for yourself" if $article->user->name eq session->{username};
        die "Already voted here" if Event->find_one({ id_item => $article->_id."", type=>'vote_up' });
        $article->votes_up( $article->votes_up + 1 );
        $article->save;
        Event->new({ id_item => $article->_id."", type=>'vote_up', id_user=>session->{userid} })->save;
        debug ">>>>> vote saved ";
    }
    else {
        debug "+++++++ not found " . params->{for};
    }
    redirect '/';
};

get '/flag' => sub {
    my $article = Article->find_one( params->{id} );
    if ( ref $article ) {
        $article->flag( $article->flag + 1 );
    }
    redirect '/';
};

get '/*' => sub {
    my ($p) = splat;
    template $p;
};

true;
