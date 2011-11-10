#!/cygdrive/c/Perl/bin/perl.exe

# For teaching video games
# Code Should be
# * easy to read and write
# * intuitive
# * perl-ish?

######### DON'T CHANGE CODE INSIDE THIS BOX ##########
;   use strict                                       #
;   use lib '.'                                      #
;   use PLWGDK                                       #
;   my %thingies                                     #
;   PLWGDK::my_game_init()                           #
;   setup()                                          #
;   PLWGDK::repeat( $PLWGDK::TICK_DELAY, \&tick )    #
;   Tkx::MainLoop();                                 #
######################################################

sub setup {
    # do setup stuff here
    $thingies{circle1} = Square->new(
        is_bouncy => 1,
    );

    $thingies{circle2} = Triangle->new(
        x     => 250,
        y     => 290,
        size  => 60,
        color => 'red',
        is_bouncy => 1,
    );

    $thingies{circle3} = Circle->new(
        x         => 250,
        y         => 250,
        size      => 90,
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
    $thingies{circle3}->go();
    $thingies{circle3}->go_random();
}

