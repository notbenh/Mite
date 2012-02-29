#!/usr/bin/env perl -w

use strict;
use warnings;

use Test::More;

note "making test class"; {
    package Foo;

    use Mite::Shim;

    has int => ( isa => 'Int'
               , default => 10
               );

    has str => ( isa => 'Str'
               , default => "Unemployed"
               );

    has code=> ( isa => 'Foo'
               , default => sub{ 'Hello world' }
               );

    has aref=> ( isa => 'Array'
               , default => [1..10]
               );

    sub method1 {};
    sub method2 {};
    sub method3 {};

    # Sometimes delete the compile code, to test the compiled code.
    END { Mite::Shim::clear_code if 1; }
}


note "basic default creation"; {
    my $obj = Foo->new(
        str => "Yarrow Hock"
    );

    TODO: {
        local $TODO = "Implement defaults";
        is $obj->int , 10           , q{Numeric defaults work};
        is $obj->str , 'Yarrow Hock', q{String defaults work}; 
        is $obj->code, 'Hello World', q{Subref defaults work}; 
    }

}

done_testing;
