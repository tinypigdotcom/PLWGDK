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

has 'dir_x'     => ( isa => 'Num',   is => 'rw',  default =>  0       );
has 'dir_y'     => ( isa => 'Num',   is => 'rw',  default =>  0       );
has 'x'         => ( isa => 'Int',   is => 'rw',  default => 10       );
has 'y'         => ( isa => 'Int',   is => 'rw',  default => 10       );
has 'size'      => ( isa => 'Int',   is => 'rw',  default => 30       );
has 'id'        => ( isa => 'Int',   is => 'rw',                      );
has 'is_bouncy' => ( isa => 'Bool',  is => 'rw',  default =>  0       );
has 'color'     => ( isa => 'Str',   is => 'rw',  default => 'yellow' );

sub BUILD {
    my ( $self, $params ) = @_;

    my $x2 = $self->{x} + $self->{size};
    my $y2 = $self->{y} + $self->{size};

#    $self->{id} = $canvas->create_oval(
    $self->{id} = $canvas->create_rectangle(
        $self->{x},
        $self->{y},
        $x2,
        $y2,
        -fill => $self->{color},
    );
}

sub xnew {
    my ( $class, %options ) = @_;

    my $dir_x = $options{dir_x} || 0;
    my $dir_y = $options{dir_y} || 0;

    my $x1        = $options{x}         || 10;
    my $y1        = $options{y}         || 10;
    my $size      = $options{size}      || 30;
    my $color     = $options{color}     || 'yellow';
    my $is_bouncy = $options{is_bouncy} || 0;

    my $x2 = $x1 + $size;
    my $y2 = $y1 + $size;

    my $circleID = $canvas->create_oval( $x1, $y1, $x2, $y2, -fill => $color, );

    my $this = bless {
        'id'        => $circleID,
        'size'      => $size,
        'dir_x'     => $dir_x,
        'dir_y'     => $dir_y,
        'is_bouncy' => $is_bouncy,
    }, $class;

    return $this;
}

sub set_in_motion {
    my ( $self ) = @_;

    my $dir_x = rand($RANGE_OF_MOTION * 2) - $RANGE_OF_MOTION;
    my $dir_y = rand($RANGE_OF_MOTION * 2) - $RANGE_OF_MOTION;

    $self->{dir_x} = $dir_x;
    $self->{dir_y} = $dir_y;

    return;
}


sub go {
    my $self = shift;
    $self->move( $self->{dir_x}, $self->{dir_y} );

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

    $canvas->move( $self->{id}, @args );

    my ( $x1, $y1, $x2, $y2 ) = $self->coords( );

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
            $self->coords( $x1, $y1, $x2, $y2, );
        }

        if ( $y1 > $SCR_HEIGHT ) {
            $x2 = $x2;
            $y2 = 1;
            $x1 = $x2 - $self->{size};
            $y1 = $y2 - $self->{size};
            $self->coords( $x1, $y1, $x2, $y2, );
        }

        if ( $x2 < 0 ) {
            $x1 = $SCR_WIDTH;
            $y1 = $y1;
            $x2 = $x1 + $self->{size};
            $y2 = $y1 + $self->{size};
            $self->coords( $x1, $y1, $x2, $y2, );
        }

        if ( $y2 < 0 ) {
            $x1 = $x1;
            $y1 = $SCR_HEIGHT;
            $x2 = $x1 + $self->{size};
            $y2 = $y1 + $self->{size};
            $self->coords( $x1, $y1, $x2, $y2, );
        }
    }

    return;
}

sub coords {
    my ($self, @args) = @_;

    return split /\s+/, $canvas->coords( $self->{id}, @args );
}


package Circle;
use Moose;

extends 'Thingie';

package Square;
use Moose;

extends 'Thingie';

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
