#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

use Data::Dumper;

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

    my $count = spawn_fish($fish, 80);
    say "Part 1: Found $count fish after 80 days";
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
