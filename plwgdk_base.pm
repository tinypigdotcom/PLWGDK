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

    my $x     = $options{x}     || 10;
    my $y     = $options{y}     || 10;
    my $size  = $options{size}  || 30;
    my $color = $options{color} || 'yellow';

    my $circleID = $canvas->createOval(
        $x, $y,
        $x + $size, $y + $size,
        -fill => $color,
    );

    my $this = bless {
        'id' => $circleID,
    }, $class;

    return $this;
}

sub move {
    my $self = shift;
    my %options = @_;

    my $x     = $options{x}     || 10;
    my $y     = $options{y}     || 10;
print "id is $self->{id}\n";
print "canvas is $canvas\n";
    my $tick_id = $MW->after( 2000, sub { $canvas->move($self->{id}, $x, $y) } );
}


