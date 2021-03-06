#!/usr/bin/env perl -w

use strict;
use warnings;

use Test::More;

{
    package mite_shim;
    require "./bin/mite_shim";
}

note "mite_shim"; {
    my $shim = mite_shim::main("Foo::Bar");

    like $shim, qr/package Foo::Bar/;
}

done_testing;
