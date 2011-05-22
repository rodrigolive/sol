package Sol;
use Dancer ':syntax';

our $VERSION = '0.1';
use Mongoose;
Mongoose->db('sol');
Mongoose->naming( ['short', 'lower'] ); 
Mongoose->load_schema( search_path => 'Schema', shorten => 1 );
require MongoDB::OID;
use URI::Encode 'uri_encode';

use Controller::Users;

get '/' => sub {
    my @articles;
    my $cnt = 0;

    session->{id} or die "no session id";
    debug ">>>>>>>>>>>>" . session->{id};
    Article->find->each(
        sub {
            my $article = shift;
            push @articles,
              {
                %$article,
                id    => "" . $article->_id,
                votes => $article->votes,
                rank  => $article->rank,
                hours => $article->hours,
              };
        }
    );
    @articles = sort { $b->{rank} <=> $a->{rank} } @articles;
    debug session;
    template 'articles', {
        session  => session,
        articles => \@articles,
    };
};

get '/newest' => sub {
    my @articles;
    my $cnt = 0;

    #push @articles, { cnt=>$cnt++, title=>$cnt.'Noooooooooo', user=>'rodrigolive', domain=>'democracia.es', votes=>1  }
    #    for 1..30;
    Article->find->sort({ time=>1 })->limit(30)->each(
        sub {
            my $article = shift;
            push @articles,
              {
                %$article,
                id    => "" . $article->_id,
                votes => $article->votes,
                rank  => $article->rank,
                hours => $article->hours,
              };
        }
    );
    template 'articles', { articles => \@articles };
};

get '/submit' => sub {
    forward '/login' unless session->{user};
    template 'submit', {};
};

post '/submit' => sub {
    my $article = Article->new( %{ params() }, user => 'rodrigolive' );
    $article->parse_textile( params->{text} );
    $article->save;

    redirect '/';
};

post '/comment' => sub {
    my $article = Article->find_one( params->{article} ) or die "Article not found";
    my $comm = Comment->new( article=>$article, text=>params->{text}, user=>session->{user} );
    $comm->save;
    redirect '/item?id=' . params->{article};
};

get '/item' => sub {
    my $article = Article->find_one( params->{id} );
    die "Not found" unless ref $article;
    my @comments = Comment->find({ 'article.$id'=>$article->{_id} })->all;
    template 'item' => {
        article => {
            %$article,
            id    => "" . $article->_id,
            votes => $article->votes,
            rank  => $article->rank,
            hours => $article->hours,
        },
        comments => \@comments,
    };
};

get '/vote' => sub {
    my $article = Article->find_one( params->{for} );
    if ( ref $article ) {
        $article->votes_up( $article->votes_up + 1 );
        $article->save;
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
