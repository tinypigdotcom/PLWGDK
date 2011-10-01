#!/usr/local/bin/perl

# For teaching video games

use strict;
use warnings;
use Carp;
use Tk;
use Tk::Dialog;

our $SCR_WIDTH            = 500;
our $SCR_HEIGHT           = 500;
our $FONT       = 'Arial 8 normal';

my $MW = MainWindow->new;
$MW->title("Lesson");

my $frame = $MW->Frame(
    -relief      => 'ridge',
    -borderwidth => 2
)->pack(
    -side   => 'top',
    -anchor => 'n',
    -fill   => 'x'
);

my    $menu = $frame->Menubutton(
        -text      => "File",
        -underline => 0,
        -font      => $FONT,
        -tearoff   => 0,
        -menuitems => [
            [
                'command'  => " New (n)",
                -underline => 1,
                -font      => $FONT,
                -command   => \&startGame
            ],
            [
                'command'  => " Options",
                -underline => 1,
                -font      => $FONT,
                -command   => \&showOptions
            ],
            [
                'command'  => " Exit (x)",
                -underline => 2,
                -font      => $FONT,
                -command => sub { exit }
            ]
        ]
    )->pack( -side => 'left' );
    my $hmenu = $frame->Menubutton(
        -text      => "Help",
        -underline => 0,
        -font      => $FONT,
        -tearoff   => 0,
        -menuitems => [
            [
                'command'  => "Help",
                -underline => 0,
                -font      => $FONT,
                -command   => \&showHelp
            ],
            [
                'command'  => "About",
                -underline => 0,
                -font      => $FONT,
                -command   => \&showAbout
            ]
        ]
    )->pack( -side => 'left' );

    my $canvas = $MW->Canvas(
        -width      => $main::SCR_WIDTH,
        -height     => $main::SCR_HEIGHT,
        -border     => 1,
        -relief     => 'ridge',
        -background => 'black'
    )->pack();

#   $canvas->createOval(x1, y1, x2, y2, ?option, value, option, value, ...?)

#    x1, y1, x2, y2, ?option, value, option, value, ...?)


package Circle;

sub new {
    my $class = shift;
    my %options = @_;

    my $SIDE_WIDTH = 10;

    my $circle = $canvas->createOval(
        $options{x}, $options{y},
        $options{x} + $options{size}, $options{y} + $options{size},
        -fill => $options{color},
    );

    my $this       = bless {
        'circle'     => $circle,
    }, $class;

    return $this;
}


