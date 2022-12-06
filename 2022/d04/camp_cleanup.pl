#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

# Advent of Code Day 4:
# - Camp Cleanup (https://adventofcode.com/2022/day/4)
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

    # Loop through each pair, count overlaps
    my $count_contained = 0; # part 1
    my $count_overlap = 0; # part 2
    foreach my $pair (@$input) {
        my %range1 = %{$pair->[0]};
        my %range2 = %{$pair->[1]};
        if ($range1{min} <= $range2{min} and $range1{max} >= $range2{max}) {
            $count_contained++;
            $count_overlap++;
        } elsif ($range2{min} <= $range1{min} and $range2{max} >= $range1{max}) {
            $count_contained++;
            $count_overlap++;
        } elsif ($range1{min} >= $range2{min} and $range1{min} <= $range2{max}) {
            $count_overlap++;
        } elsif ($range2{min} >= $range1{min} and $range2{min} <= $range1{max}) {
            $count_overlap++;
        }
    }
    say "Part 1: $count_contained";
    say "Part 2: $count_overlap";
}

sub parse_input
{
    my ($filename) = @_;

    my @pairs;
    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    while (my $line = <$fh>) {
        chomp $line;
        # Line format: x1-y1,x2-y2
        my @ranges;
        map {
            my @range = split /-/, $_;
            push @ranges, {
                min => $range[0],
                max => $range[1]
            };
        } split /,/, $line;
        push @pairs, \@ranges;
    }
    close($fh);

    return \@pairs;
}
