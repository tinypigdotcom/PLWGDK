#!/usr/local/bin/perl

# For teaching video games
# Code Should be
# * easy to read and write
# * intuitive
# * perl-ish?

use strict;
use lib '.';

my %thingies;

sub setup {
    # do setup stuff here
    $thingies{circle1} = Circle->new();

    $thingies{circle2} = Circle->new(
        x     => 250,
        y     => 290,
        size  => 40,
        color => 'red',
    );

    $thingies{circle3} = Circle->new(
        x         => 250,
        y         => 250,
        size      => 50,
        color     => 'purple',
        is_bouncy => 1,
    );
    $thingies{circle1}->set_in_motion();
    $thingies{circle2}->set_in_motion();
    $thingies{circle3}->set_in_motion();
}

sub tick {
    # do one step of game stuff
    $thingies{circle1}->go();
    $thingies{circle2}->go();
    $thingies{circle3}->go_random();
    $thingies{circle3}->go();
}

use xplwgdk_base;

__END__


my $circle2 = Circle->new(
    x     => 50,
    y     => 90,
    size  => 40,
    color => 'red',
);

my $circle3 = Circle->new(
    x     => 90,
    y     => 190,
    size  => 20,
    color => 'pink',
);

$circle->move(
    x     => 90,
    y     => 190,
);

MainLoop;




