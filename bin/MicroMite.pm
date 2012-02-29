package MicroMite;
use strict;
use warnings;
use Data::Dumper; sub D (@) { warn Dumper(@_) };
#$Data::Dumper::Deparse++;

sub import {
  my $class = shift;
  my ($package,$file) = caller;

  { 
    no strict 'refs';
    for ( qw{class has method} ) {
      *{$package . '::' . $_} = \&{ "MicroMite::$_" };
    }
    *{$package . '::_meta'} = {};
  }
}

sub class ($&) {
  my ($name, $code) = @_;

  $__PACKAGE__::_meta->{class}->{name} = $name;

  $code->(); # compile-ish
  #D { META => $__PACKAGE__::_meta
  #  #, CLASS => \@_
  #  #, CODE => $code->() 
  #  };

  require Template;
  my $t = Template->new(INCLUDE_PATH => '/tmp', POST_CHOMP => 1)
       || die $Template::ERROR, "\n";
  my $template = <<'END';
package [% class.name %];
use strict;
use warnings;

sub new {
  my $class = shift;
  return bless { [% new.defaults.join("\n               , ") %]
                 
               } $class
}

[% FOREACH attr IN has %]
sub [% attr.name %] {
  my $self = shift;
  [% IF attr.is == 'ro' %]
  die qq{[% attr.name %] is read-only} if @_;
  [% ELSE %]
  $self->{[% attr.name %]} = shift if @_;
  [% END %]
  return $self->{[% attr.name %]};
}

[% END %]

END

  push @{ $__PACKAGE__::_meta->{new}->{defaults} }, '@_'; # ikk
  $t->process( \$template
             , $__PACKAGE__::_meta
             ) || die $t->error(), "\n";

}

sub has ($@) {
  my ($name, %def) = @_;
  use Scalar::Util qw{looks_like_number};
  require B::Deparse;
  my $dep = B::Deparse->new(qw{ -p -d -sC });
 
  if ( $def{default} ) { 
    my $ref = ref($def{default});
    if( $ref eq '' && !looks_like_number($def{default}) ){
       $def{default} = qq['$def{default}'];
    }
    elsif( $ref eq 'CODE' ) {
       $def{default} = 'sub' . $dep->coderef2text($def{default}) . '->()';
    }
    push @{$__PACKAGE__::_meta->{new}->{defaults} }, qq[$name => $def{default}];
  }

  push @{$__PACKAGE__::_meta->{has} }, { isa => 'rw'
                                       , name => $name
                                       , %def 
                                       };
}

sub method ($&) {
  #my ($name, $code) = @_;
  #D {METHOD => \@_ };
}



1;

