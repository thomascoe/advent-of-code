package Submarine;

use strict;
use warnings;

require Exporter;
our @ISA       = qw(Exporter);
our @EXPORT    = qw();
our $VERSION   = 1.00;

sub new {
    my $class = shift;
    my $movement = shift;

    my $self = {
        _pos => 0,
        _depth => 0,
        _aim => 0,
        _movement => $movement,
    };
    bless $self, $class;

    return $self;
}

# Get details about the current position and depth
sub getPos {
    my $self = shift;
    return $self->{_pos};
}
sub getDepth {
    my $self = shift;
    return $self->{_depth};
}
sub getMovement {
    my $self = shift;
    return $self->{_movement};
}

# Movement functions
sub forward {
    my $self = shift;
    my ($distance) = @_;

    return if (!defined $distance);

    if ($self->{_movement} eq 'basic') {
        $self->{_pos} = $self->{_pos} + $distance;
    } else { # assume advanced
        $self->{_pos} = $self->{_pos} + $distance;
        $self->{_depth} = $self->{_depth} + ($self->{_aim}*$distance);
    }

    return 1;
}
sub down {
    my $self = shift;
    my ($distance) = @_;

    return if (!defined $distance);

    if ($self->{_movement} eq 'basic') {
        $self->{_depth} = $self->{_depth} + $distance;
    } else { # assume advanced
        $self->{_aim} = $self->{_aim} + $distance;
    }

    return $self->{_depth};
}
sub up {
    my $self = shift;
    my ($distance) = @_;

    return if (!defined $distance);

    if ($self->{_movement} eq 'basic') {
        $self->{_depth} = $self->{_depth} - $distance;
    } else { # assume advanced
        $self->{_aim} = $self->{_aim} - $distance;
    }

    return $self->{_depth};
}

1;
