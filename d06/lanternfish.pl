#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

use List::Util qw( sum );

# Advent of Code Day 6:
# - Lanternfish (https://adventofcode.com/2021/day/6)
#
# Author: Thomas Coe

my $g_verbose = 0;

{
    my $filename = $ARGV[0];
    if (!defined $filename) {
        die("Usage: $0 filename [-v]");
    }
    if (defined $ARGV[1] and $ARGV[1] eq "-v") {
        $g_verbose = 1;
    }

    my ($fish) = parse_input($filename);

    my $count = spawn_fish_efficient($fish, 80);
    say "Part 1: Found $count fish after 80 days";

    $count = spawn_fish_efficient($fish, 256);
    say "Part 2: Found $count fish after 256 days";
}

sub parse_input
{
    my ($filename) = @_;

    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    my $line = <$fh>;
    close($fh);

    my @fish = split /,/, $line;

    return \@fish;
}

# Initial basic implementation (too slow for part 2)
sub spawn_fish
{
    my ($fish, $days) = @_;

    my @arr = @{$fish};

    for my $day (1..$days) {
        # Count how many new fish to add
        my $new_cnt = scalar grep /0/, @arr;

        # Replace 0's with 7's
        @arr = map { $_ eq 0 ? 7 : $_ } @arr;

        # Decrease internal timer
        @arr = map { $_ - 1 } @arr;

        # Add new fish
        for (1..$new_cnt) {
            push @arr, 8;
        }

        say "After $day days: " . join ',', @arr if $g_verbose
    }

    return scalar @arr;
}

# More efficient implementation
# Keep an array of the days, not fish
# Count how many fish are on each day
sub spawn_fish_efficient
{
    my ($fish, $days) = @_;

    # Initialize the @fish_per_day array
    my @fish_per_day;
    for my $day (0..8) {
        my $count = scalar grep /$day/, @{$fish};
        $fish_per_day[$day] = $count;
    }

    for my $day (1..$days) {
        # Grab count of spawning fish, while decrementing the day for all other fish
        my $spawning = shift @fish_per_day;

        # Spawning fish get added back to day 6, and this same count of new fish is added to day 8
        $fish_per_day[6] += $spawning;
        $fish_per_day[8] += $spawning;

        say "After $day days: " . sum(@fish_per_day) if $g_verbose
    }

    return sum(@fish_per_day);
}
