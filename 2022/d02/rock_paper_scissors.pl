#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

# Advent of Code Day 2:
# - Rock Paper Scissors (https://adventofcode.com/2022/day/2)
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

    my ($input) = parse_input($filename);

    # X/Y/Z mean what shape I played. Need to determine the outcome based on both shapes
    my $total_score = 0;
    my %shape_values = (
        'X' => 1,
        'Y' => 2,
        'Z' => 3
    );
    my %outcomes = (
        'A' => {
            'X' => 3,
            'Y' => 6,
            'Z' => 0
        },
        'B' => {
            'X' => 0,
            'Y' => 3,
            'Z' => 6
        },
        'C' => {
            'X' => 6,
            'Y' => 0,
            'Z' => 3
        }
    );
    for my $round (@$input) {
        my ($opponent, $me) = @$round;
        my $score = $outcomes{$opponent}{$me} + $shape_values{$me};
        $total_score += $score;
    }
    say "Part 1: Total Score: $total_score";

    # X/Y/Z mean outcomes (lose, draw, win). Need to determine my shape based on opponent shape and outcome
    $total_score = 0;
    %outcomes = (
        'X' => 0,
        'Y' => 3,
        'Z' => 6
    );
    %shape_values = (
        'A' => {
            'X' => 3,
            'Y' => 1,
            'Z' => 2
        },
        'B' => {
            'X' => 1,
            'Y' => 2,
            'Z' => 3
        },
        'C' => {
            'X' => 2,
            'Y' => 3,
            'Z' => 1
        }
    );
    for my $round (@$input) {
        my ($opponent, $me) = @$round;
        my $score = $shape_values{$opponent}{$me} + $outcomes{$me};
        $total_score += $score;
    }
    say "Part 2: Total Score: $total_score";

}

sub parse_input
{
    my ($filename) = @_;

    my @rounds;
    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    while (my $line = <$fh>) {
        chomp $line;
        push @rounds, [split ' ', $line];
    }
    close($fh);

    return \@rounds;
}
