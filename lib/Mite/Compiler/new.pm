package Mite::Compiler::new;

use strict;
use warnings;

use parent qw(Mite::Compiler::Base);


use Scalar::Util qw{looks_like_number};
use B::Deparse;

my $deparse = B::Deparse->new(qw{ -p -d -sC });

# unpack or quote a $thing based on what it is
sub disp {
  my $thing = shift;
  my $ref   = ref($thing);
  return ref($thing)               ? 'sub'. $deparse->coderef2text($thing) .'->()'
       : looks_like_number($thing) ? $thing
       :                             qq{'$thing'}
       ;
}

sub compile {
    my $self = shift;

    my $code = sprintf q[
sub new {
    my $class = shift;
    return bless { %s
                 , @_ 
                 }, $class;
}

], join qq{\n                 , } 
 , map { sprintf '%s => %s', $_->{name}, disp( $_->{default} ) } 
   grep{ defined $_->{default} }
   @{ $self->{package_content}->{attrs} }
; 

    $self->save_code(\$code);

    return;
}

1;

