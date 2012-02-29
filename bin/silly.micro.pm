package Some::Thing;
use strict;
use warnings;

sub new {
  my $class = shift;
  return bless { somenum => 10
               , somestr => 'hello'
               , someval => sub{
    require Some::Thing;
    "Some::Thing"->new;
}->()
               , @_                 
               } $class
}

sub somenum {
  my $self = shift;
    die qq{somenum is read-only} if @_;
    return $self->{somenum};
}

sub somestr {
  my $self = shift;
    $self->{somestr} = shift if @_;
    return $self->{somestr};
}

sub someval {
  my $self = shift;
    $self->{someval} = shift if @_;
    return $self->{someval};
}


