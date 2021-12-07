#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

use List::Util qw( min max sum );

# Advent of Code Day 7:
# - The Treachery of Whales (https://adventofcode.com/2021/day/7)
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

    my ($crabs) = parse_input($filename);

    my $cost = move_crabs($crabs, 0);
    say "Part 1: $cost";

    $cost = move_crabs($crabs, 1);
    say "Part 2: $cost";
}

sub parse_input
{
    my ($filename) = @_;

    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    my $line = <$fh>;
    close($fh);

    my @arr = split/,/, $line;
    return \@arr;
}

sub move_crabs
{
    my ($crabs, $b_part2) = @_;

    my $best_cost = 999999999;

    # Best option must be between the min and max of all current positions
    for my $i (min(@$crabs)..max(@$crabs)) {
        my $cost;
        if (!$b_part2) {
            # Total cost is simply the sum of all distances between each crab and $i
            $cost = sum(map {abs($_ - $i)} @$crabs);
        } else {
            # Each cost is a Triangular number (https://en.wikipedia.org/wiki/Triangular_number)
            # The summation from k=1 to the distance between the crab and $i
            # Each cost can be calculated as cost = (n(n+1))/2, where n is the distance
            $cost = sum(
                map {
                    my $distance = abs($_ - $i);
                    ($distance * ($distance+1) / 2)
                } @$crabs );
        }
        $best_cost = $cost if $cost < $best_cost;
    }

    return $best_cost;
}
