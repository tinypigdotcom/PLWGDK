#!/usr/local/bin/perl

# For teaching video games

use 5.010001;
use strict;
use warnings;

our $VERSION = '0.02';

use Carp;
use Tk;
use Tk::Dialog;
use Data::Dumper;

our $SCR_WIDTH  = 500;
our $SCR_HEIGHT = 500;
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

my $menu = $frame->Menubutton(
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
            -command   => sub { exit }
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

setup();

$MW->repeat( 15, \&tick );

MainLoop;

#   $canvas->createOval(x1, y1, x2, y2, ?option, value, option, value, ...?)

#    x1, y1, x2, y2, ?option, value, option, value, ...?)

package Circle;

# BEHAVIORS
# wrap - when reaches end-of-screen, goes to the other side
# bounce - when reaches end-of-screen, changes direction

sub new {
    my $class   = shift;
    my %options = @_;

    my $dir_x = $options{dir_x} || 0;
    my $dir_y = $options{dir_y} || 0;

    my $x1        = $options{x}         || 10;
    my $y1        = $options{y}         || 10;
    my $size      = $options{size}      || 30;
    my $color     = $options{color}     || 'yellow';
    my $is_bouncy = $options{is_bouncy} || 0;

    my $x2 = $x1 + $size;
    my $y2 = $y1 + $size;

    my $circleID = $canvas->createOval( $x1, $y1, $x2, $y2, -fill => $color, );

    my $this = bless {
        'id'        => $circleID,
        'size'      => $size,
        'dir_x'     => $dir_x,
        'dir_y'     => $dir_y,
        'is_bouncy' => $is_bouncy,
    }, $class;

    return $this;
}

sub go_some_damn_place {
    my $self    = shift;
    my %options = @_;

    my $x = $options{x} || 10;
    my $y = $options{y} || 10;
    print "id is $self->{id}\n";
    print "canvas is $canvas\n";
    my $tick_id = $MW->after( 50, sub { $self->move( $x, $y ) } );
}

sub set_in_motion {
    my $self = shift;

    my $dir_x = rand(6) - 3;
    my $dir_y = rand(6) - 3;

    $self->{dir_x} = $dir_x;
    $self->{dir_y} = $dir_y;
}

sub go {
    my $self = shift;
    $self->move( $self->{dir_x}, $self->{dir_y} );
}

sub go_random {
    my $self = shift;

    my $dir_x = rand(6) - 3;
    my $dir_y = rand(6) - 3;

    $self->move( $dir_x, $dir_y );
}

sub go_right {
    my $self = shift;
    $self->move( 1, 0 );
}

sub go_down_and_right {
    my $self = shift;
    $self->move( 1, 1 );
}

sub go_up_and_left {
    my $self = shift;
    $self->move( -1, -1 );
}

sub move {
    my $self = shift;

    $canvas->move( $self->{id}, @_ );

    my ( $x1, $y1, $x2, $y2 ) = $canvas->coords( $self->{id} );

    if ( $self->{is_bouncy} ) {
        if ( $x2 > $SCR_WIDTH and $self->{dir_x} > 0 ) {
            $self->{dir_x} = -$self->{dir_x};
        }

        if ( $y2 > $SCR_HEIGHT and $self->{dir_y} > 0 ) {
            $self->{dir_y} = -$self->{dir_y};
        }

        if ( $x1 < 0 and $self->{dir_x} < 0 ) {
            $self->{dir_x} = -$self->{dir_x};
        }

        if ( $y1 < 0 and $self->{dir_y} < 0 ) {
            $self->{dir_y} = -$self->{dir_y};
        }
    }
    else {
        if ( $x1 > $SCR_WIDTH ) {
            $x2 = 1;
            $y2 = $y2;
            $x1 = $x2 - $self->{size};
            $y1 = $y2 - $self->{size};
            $canvas->coords( $self->{id}, $x1, $y1, $x2, $y2, );
        }

        if ( $y1 > $SCR_HEIGHT ) {
            $x2 = $x2;
            $y2 = 1;
            $x1 = $x2 - $self->{size};
            $y1 = $y2 - $self->{size};
            $canvas->coords( $self->{id}, $x1, $y1, $x2, $y2, );
        }

        if ( $x2 < 0 ) {
            $x1 = $SCR_WIDTH;
            $y1 = $y1;
            $x2 = $x1 + $self->{size};
            $y2 = $y1 + $self->{size};
            $canvas->coords( $self->{id}, $x1, $y1, $x2, $y2, );
        }

        if ( $y2 < 0 ) {
            $x1 = $x1;
            $y1 = $SCR_HEIGHT;
            $x2 = $x1 + $self->{size};
            $y2 = $y1 + $self->{size};
            $canvas->coords( $self->{id}, $x1, $y1, $x2, $y2, );
        }
    }
}

sub reset {
    my $self = shift;

    #    print "start_x1 $self->{start_x1}\n";
    #    print "start_y1 $self->{start_y1}\n";
    #    print "start_x2 $self->{start_x2}\n";
    #    print "start_y2 $self->{start_y2}\n";

    $canvas->coords(
        $self->{id},       $self->{start_x1}, $self->{start_y1},
        $self->{start_x2}, $self->{start_y2},
    );
}

1;
__END__

=head1 NAME

PLWGDK - Perl Light-Weight Game Development KIt

=head1 SYNOPSIS

    sub setup {
        # do setup stuff here
        $thingies{circle1} = Circle->new();
        $thingies{circle1}->set_in_motion();
    }

    sub tick {
        # do one step of game stuff
        $thingies{circle1}->go();
    }

    use plwgdk_base;

=head1 DESCRIPTION

PLWGDK is intended to provide basic functionality for creating
games for the purposes of teaching programming.

=head2 EXPORT

None.

=head1 SEE ALSO

Git repository is here: L<https://github.com/tinypigdotcom/PLWGDK>

Tinypig website is here: L<http://www.tinypig.com>

=head1 AUTHOR

David Bradford, E<lt>davembradford@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2011 by David Bradford

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.

=cut

