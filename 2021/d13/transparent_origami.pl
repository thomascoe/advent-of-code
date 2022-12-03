#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

# Advent of Code Day 13:
# - Transparent Origami (https://adventofcode.com/2021/day/13)
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

    my ($points, $folds) = parse_input($filename);

    # Perform First Fold
    fold_grid($points, $folds->[0]);
    my $count = count_points($points);
    say "Part 1: $count";

    # Perform remaining folds
    for my $i (1..scalar @$folds - 1) {
        fold_grid($points, $folds->[$i]);
    }

    # Print out the final grid to reveal the code
    say "Part 2:";
    print_grid($points);
}

sub parse_input
{
    my ($filename) = @_;

    my @points;
    my @folds;
    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    while (my $line = <$fh>) {
        chomp $line;
        if ($line =~ m/^\d/) {
            my ($x, $y) = split /,/, $line;
            push @points, [$x, $y]
        } elsif ($line =~ m/^fold along ([xy])=(\d+)/) {
            push @folds, [$1, $2];
        }
    }
    close($fh);

    return \@points, \@folds;
}

# Fold the grid along a line
sub fold_grid
{
    my ($points, $fold) = @_;
    my ($dir, $seam) = @$fold;
    say "Folding along $dir=$seam" if $g_verbose;

    # Fold Left
    map {
        my $x = $_->[0];
        $_->[0] = $x - (($x - $seam) * 2) if ($x > $seam)
    } @$points if $dir eq 'x';

    # Fold Up
    map {
        my $y = $_->[1];
        $_->[1] = $y - (($y - $seam) * 2) if ($y > $seam)
    } @$points if $dir eq 'y';
}

# Count the number of set points
# Filters out duplicate points from the provided array
sub count_points
{
    my ($points) = @_;
    my %grid;
    for my $point (@$points) {
        my ($x, $y) = @$point;
        $grid{"$x,$y"} = 1; # Add to a hash to filter dups
    }
    return scalar keys %grid;
}

sub print_grid
{
    my ($points) = @_;

    # Convert the points to a 2D array
    my @grid;
    for my $point (@$points) {
        my ($x, $y) = @$point;
        $grid[$y][$x] = 1;
    }

    # Calculate the max width of a row
    my $width = 0;
    foreach my $row (@grid) {
        $width = scalar @$row if (defined $row and scalar @$row > $width);
    }

    # Print a # for set points, and a . for unset points
    foreach my $row (@grid) {
        for my $i (0..$width-1) {
            (defined $row and defined $row->[$i]) ? print "#" : print ".";
        }
        print "\n";
    }
}
