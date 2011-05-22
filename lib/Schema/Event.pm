package Schema::Event;
use v5.10;
use Mongoose::Class;
with 'Mongoose::Document';
use Digest::MD5;

has_one 'user' => 'User';
has_one 'session' => 'Any';
has_one 'fnid' => 'Any';


1;

