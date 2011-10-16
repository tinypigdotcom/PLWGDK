package PLWGDK;

# NO CODE SHOULD RUN AS A RESULT OF "USE"
# Documentation at end

use 5.010001;
use strict;
use warnings;

use Carp;
use Tkx;
#use Tk::Dialog;
use Data::Dumper;

our $VERSION = "0.02";

our $SCR_WIDTH;
our $SCR_HEIGHT;
our $RANGE_OF_MOTION;
our $DEBUG_MOTION_MULTIPLIER = 0;
our $TICK_DELAY;
our $IS_AQUA;
our $progname;
our $mw;
our $canvas;

sub my_game_init {
    my ( $class, %options ) = @_;

    $SCR_WIDTH  = 500;
    $SCR_HEIGHT = 500;
    $RANGE_OF_MOTION = 3;
    $TICK_DELAY = 15;

    ($progname = $0) =~ s,.*[\\/],,;
    $IS_AQUA = Tkx::tk_windowingsystem() eq "aqua";

    Tkx::package_require("style");
    Tkx::style__use("as", -priority => 70);

    $mw = Tkx::widget->new(".");
    $mw->configure(-menu => mk_menu($mw));

    $canvas = $mw->new_tk__canvas(
        -width      => $SCR_WIDTH,
        -height     => $SCR_HEIGHT,
        -border     => 1,
        -relief     => 'ridge',
        -background => 'black'
    );
    $canvas->g_pack();
}

sub repeat {
    my $ms  = shift;
    my $sub = shift;
    my $repeater; # repeat wrapper

    $repeater = sub { $sub->(@_); Tkx::after($ms, $repeater); };

    Tkx::after($ms, $repeater);
}

sub mk_menu {
    my $mw = shift;
    my $menu = $mw->new_menu;

    my $file = $menu->new_menu(
        -tearoff => 0,
    );
    $menu->add_cascade(
        -label => "File",
        -underline => 0,
        -menu => $file,
    );
    $file->add_command(
        -label => "New",
        -underline => 0,
        -accelerator => "Ctrl+N",
        -command => \&new,
    );
    $mw->g_bind("<Control-n>", \&new);
    $file->add_command(
        -label   => "Exit",
        -underline => 1,
        -command => [\&Tkx::destroy, $mw],
    ) unless $IS_AQUA;

    my $help = $menu->new_menu(
        -name => "help",
        -tearoff => 0,
    );
    $menu->add_cascade(
        -label => "Help",
        -underline => 0,
        -menu => $help,
    );
    $help->add_command(
        -label => "\u$progname Manual",
        -command => \&show_manual,
    );

    my $about_menu = $help;
    if ($IS_AQUA) {
        # On Mac OS we want about box to appear in the application
        # menu.  Anything added to a menu with the name "apple" will
        # appear in this menu.
        $about_menu = $menu->new_menu(
            -name => "apple",
        );
        $menu->add_cascade(
            -menu => $about_menu,
        );
    }
    $about_menu->add_command(
        -label => "About \u$progname",
        -command => \&about,
    );

    return $menu;
}


sub about {
    Tkx::tk___messageBox(
        -parent => $mw,
        -title => "About \u$progname",
        -type => "ok",
        -icon => "info",
        -message => "$progname v$VERSION\n" .
                    "Copyright 2005 ActiveState. " .
                    "All rights reserved.",
    );
}

package Thingie;
use Moose;

has 'dir_x'     => ( isa => 'Num',           is => 'rw',  default =>  0       );
has 'dir_y'     => ( isa => 'Num',           is => 'rw',  default =>  0       );
has 'x1'        => ( isa => 'Num',           is => 'rw',  default => 10       );
has 'y1'        => ( isa => 'Num',           is => 'rw',  default => 10       );
has 'x2'        => ( isa => 'Num',           is => 'rw',                      );
has 'y2'        => ( isa => 'Num',           is => 'rw',                      );
has 'coords'    => ( isa => 'ArrayRef[Int]', is => 'rw',                      );
has 'size'      => ( isa => 'Int',           is => 'rw',  default => 30       );
has 'ID'        => ( isa => 'Int',           is => 'rw',                      );
has 'is_bouncy' => ( isa => 'Bool',          is => 'rw',  default =>  0       );
has 'color'     => ( isa => 'Str',           is => 'rw',  default => 'yellow' );

sub set_in_motion {
    my ( $self ) = @_;

    my $dir_x = rand($RANGE_OF_MOTION * 2) - $RANGE_OF_MOTION + $DEBUG_MOTION_MULTIPLIER;
    my $dir_y = rand($RANGE_OF_MOTION * 2) - $RANGE_OF_MOTION + $DEBUG_MOTION_MULTIPLIER;

    $self->dir_x($dir_x);
    $self->dir_y($dir_y);

    return;
}

sub go {
    my $self = shift;
    $self->move( $self->dir_x, $self->dir_y );

    return;
}

sub go_random {
    my $self = shift;

    my $dir_x = rand($RANGE_OF_MOTION * 2) - $RANGE_OF_MOTION;
    my $dir_y = rand($RANGE_OF_MOTION * 2) - $RANGE_OF_MOTION;

    $self->move( $dir_x, $dir_y );

    return;
}

sub move {
    my ( $self, @args ) = @_;

    $canvas->move( $self->ID, @args );

    my $x1 = 0;
    my $y1 = 1;
    my $x2 = 2;
    my $y2 = 3;
    my ( @coords ) = $self->_coords();

    if ( $self->is_bouncy ) {
        if ( $coords[$x2] > $SCR_WIDTH and $self->dir_x > 0 ) {
            $self->dir_x( -$self->dir_x );
        }

        if ( $coords[$y2] > $SCR_HEIGHT and $self->dir_y > 0 ) {
            $self->dir_y( -$self->dir_y );
        }

        if ( $coords[$x1] < 0 and $self->dir_x < 0 ) {
            $self->dir_x( -$self->dir_x );
        }

        if ( $coords[$y1] < 0 and $self->dir_y < 0 ) {
            $self->dir_y( -$self->dir_y );
        }
    }
    else {
        if ( $coords[$x1] > $SCR_WIDTH ) {
            $self->x2( 1 );
            $self->y2( $coords[$y2] );
            $self->reset_coords('x2');
        }

        if ( $coords[$y1] > $SCR_HEIGHT ) {
            $self->y2( 1 );
            $self->x2( $coords[$x2] );
            $self->reset_coords('y2');
        }

        if ( $coords[$x2] < 0 ) {
            $self->x1( $SCR_WIDTH );
            $self->y1( $coords[$y1] );
            $self->reset_coords('x1');
        }

        if ( $coords[$y2] < 0 ) {
            $self->y1( $SCR_HEIGHT );
            $self->x1( $coords[$x1] );
            $self->reset_coords('y1');
        }
    }

    return;
}

sub _coords {
    my ($self, @args) = @_;

    return split /\s+/, $canvas->coords( $self->ID, @args );
}


package Circle;
use Moose;

extends 'Thingie';

sub BUILD {
    my ( $self, $params ) = @_;

    $self->calc_coords();

    $self->ID(
        $canvas->create_oval(
            $self->x1,
            $self->y1,
            $self->x2,
            $self->y2,
            -fill => $self->color,
        )
    );
}

sub calc_coords {
    my ( $self, $params ) = @_;

    $self->x2( $self->x1 + $self->size );
    $self->y2( $self->y1 + $self->size );
}

sub reset_coords {
    my ( $self, $basis ) = @_;

    if ( $basis eq 'x2' ) {
        $self->x1( $self->x2 - $self->size );
        $self->y1( $self->y2 - $self->size );
    }
    elsif ( $basis eq 'y2') {
        $self->x1( $self->x2 - $self->size );
        $self->y1( $self->y2 - $self->size );
    }
    elsif ( $basis eq 'x1' ) {
        $self->x2( $self->x1 + $self->size );
        $self->y2( $self->y1 + $self->size );
    }
    elsif ( $basis eq 'y1' ) {
        $self->x2( $self->x1 + $self->size );
        $self->y2( $self->y1 + $self->size );
    }
    $self->_coords( $self->x1, $self->y1, $self->x2, $self->y2 );
}


package Square;
use Moose;

extends 'Thingie';

sub BUILD {
    my ( $self, $params ) = @_;

    $self->calc_coords();

    $self->ID(
        $canvas->create_rectangle(
            $self->x1,
            $self->y1,
            $self->x2,
            $self->y2,
            -fill => $self->color,
        )
    );
}

sub calc_coords {
    my ( $self, $params ) = @_;

    $self->x2( $self->x1 + $self->size );
    $self->y2( $self->y1 + $self->size );
}

sub reset_coords {
    my ( $self, $basis ) = @_;

    if ( $basis eq 'x2' ) {
        $self->x1( $self->x2 - $self->size );
        $self->y1( $self->y2 - $self->size );
    }
    elsif ( $basis eq 'y2') {
        $self->x1( $self->x2 - $self->size );
        $self->y1( $self->y2 - $self->size );
    }
    elsif ( $basis eq 'x1' ) {
        $self->x2( $self->x1 + $self->size );
        $self->y2( $self->y1 + $self->size );
    }
    elsif ( $basis eq 'y1' ) {
        $self->x2( $self->x1 + $self->size );
        $self->y2( $self->y1 + $self->size );
    }
    $self->_coords( $self->x1, $self->y1, $self->x2, $self->y2 );
}


package Triangle;
use Moose;

extends 'Thingie';

sub BUILD {
    my ( $self, $params ) = @_;

    my $x1 = $self->x1 + ($self->size/2);
    my $y1 = $self->y1;
    my $x2 = $self->x1 + $self->size;
    my $y2 = $self->y1 + $self->size;
    my $x3 = $self->x1;
    my $y3 = $self->y1 + $self->size;

    $self->{ID} = $canvas->create_poly(
        $x1, $y1,
        $x2, $y2,
        $x3, $y3,
        -fill => $self->color,
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
