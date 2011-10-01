#!/usr/local/bin/perl

# For teaching video games

use strict;

use lib '.';
use plwgdk_base;
use Moose;

my $circle = Circle->new(
    x     => 50,
    y     => 90,
    size  => 40,
    color => 'red',
);

my $circle2 = Circle->new(
    x     => 90,
    y     => 190,
    size  => 20,
    color => 'pink',
);

MainLoop;




