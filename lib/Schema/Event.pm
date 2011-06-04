package Schema::Event;
use v5.10;
use Mongoose::Class;
with 'Mongoose::Document';
use Digest::MD5;

has_one 'id_item' => 'Str', required => 1;
has_one 'id_user' => 'Str', required => 1;
has_one 'type' => 'Str',    required => 1;

has_one 'article' => 'Schema::Article';
has_one 'session' => 'Any';
has_one 'fnid'    => 'Any';

1;

