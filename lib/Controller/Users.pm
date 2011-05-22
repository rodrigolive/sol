package Sol;
use Dancer ':syntax';

get '/user' => sub {
    my $user = User->find_one({ name=>params->{id} }) or die 'Usuario no encontrado';
    template 'user' => {
        user => $user ,
        session => session,
    };
};

get '/logou' => sub {
};
get '/login' => sub {
    debug "------------------ID = " . session->{id};
    template 'login' => {
        callback_url => uri_encode( 'http://votasol.org/logback?id=' . session->{id} ),
        facebook_key => config->{facebook_key},
    }, { layout => undef };
};

post '/create_user' => sub {
    die "Usuario ya existe" if User->find_one({ name=>params->{u} });
    my $user = User->new( name=>params->{u}, password=>params->{p} );
    $user->save;
    session->{username} = $user->name;
    redirect '/';
};


post '/login' => sub {
    my $user = User->find_one({ name => params->{u} });
    die "Usuario no encontrado" unless ref $user; 
    die "Invalid password" unless $user->check( params->{p} );
    session user => { map { $_ => $user->{$_} } qw/_id email/ }; 
    session username => $user->name;
    redirect '/';
};

1;
