#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

# Advent of Code Day 11:
# - Dumbo Octopus (https://adventofcode.com/2021/day/11)
#
# Author: Thomas Coe

my $g_verbose = 0;

my %g_flashed; # List of points that have flashed for each step
my $g_flashes = 0; # Total number of flashes
my $g_all_flashed_step; # First step where all flashed simultaneously

{
    my $filename = $ARGV[0];
    if (!defined $filename) {
        die("Usage: $0 filename [-v]");
    }
    if (defined $ARGV[1] and $ARGV[1] eq "-v") {
        $g_verbose = 1;
    }

    my ($grid) = parse_input($filename);

    if ($g_verbose) {
        say "Step 0";
        print_grid($grid);
    }

    # Run through the first 100 steps, counting total flashes
    my $step = 1;
    while ($step <= 100) {
        step_grid($grid, $step);
        if ($g_verbose) {
            say "Step $step";
            print_grid($grid);
            say "$g_flashes total flashes";
        }
        $step++;
    }
    say "Part 1: $g_flashes";

    # Keep stepping if needed, until we've hit a step where all are flashing at once
    while (!defined $g_all_flashed_step) {
        step_grid($grid, $step);
        $step++;
    }
    say "Part 2: $g_all_flashed_step"
}

sub parse_input
{
    my ($filename) = @_;

    my @grid;

    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    while (my $line = <$fh>) {
        chomp $line;
        my @cols = split //, $line;
        push @grid, \@cols;
    }
    close($fh);

    return \@grid;
}

sub step_grid
{
    my ($grid, $step) = @_;

    %g_flashed = (); # Clear out record of flashed octopuses
    my $target_flashes = $g_flashes + 100; # Looking for all 100 octopuses to flash

    # Increment all points on the grid (that haven't already flashed this step)
    for (my $i = 0; $i < scalar @$grid; $i++) {
        my $row = $grid->[$i];
        for (my $j = 0; $j < scalar @$row; $j++) {
            # Skip this one if they've alredy flashed
            next if defined $g_flashed{$i}{$j};

            # Increment energy level, flash if needed
            $row->[$j] = ($row->[$j]+1) % 10;
            flash_octopus($grid, $i, $j) if ($row->[$j] == 0);
        }
    }

    $g_all_flashed_step = $step if ($g_flashes == $target_flashes);
}

sub flash_octopus
{
    my ($grid, $i, $j) = @_;

    # Mark this octopus' location as having been flashed this step
    $g_flashed{$i}{$j} = 1;

    # Count the total flashes
    $g_flashes++;

    my $num_rows = scalar @$grid;
    my $num_cols = scalar @{$grid->[0]};

    # List of adjacent points to this octopus (including diagonal)
    # Some of these may be invalid, need to check bounds later
    my @adjacent_points = (
        [$i-1, $j-1],
        [$i-1, $j],
        [$i-1, $j+1],
        [$i, $j-1],
        [$i, $j+1],
        [$i+1, $j-1],
        [$i+1, $j],
        [$i+1, $j+1],
    );

    for my $point (@adjacent_points) {
        my ($x, $y) = @$point;

        # Skip if point is off the grid or has already flashed
        next if ($x < 0 or $x >= $num_rows);
        next if ($y < 0 or $y >=$num_cols);
        next if defined $g_flashed{$x}{$y};

        # Increment energy level, recursively flash if needed
        $grid->[$x]->[$y] = ($grid->[$x]->[$y]+1) % 10;
        flash_octopus($grid, $x, $y) if ($grid->[$x]->[$y] == 0);
    }
}

sub print_grid
{
    my ($grid) = @_;
    for my $row (@$grid) {
        for my $col (@$row) {
            print "$col";
        }
        print "\n";
    }
}
