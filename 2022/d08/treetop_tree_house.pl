#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

use Data::Dumper;

# Advent of Code Day 8:
# - Treetop Tree House (https://adventofcode.com/2022/day/8)
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

    my ($tree_map) = parse_input($filename);
    print Dumper $tree_map if $g_verbose;

    # Keep track of all locations where a tree is visible
    my %visible;

    my $height = scalar @$tree_map;
    my $width = scalar @{$tree_map->[0]};

    # Scan through all rows
    for my $rownum (0 .. $height - 1) {
        # Search from the left to right
        my $cur_height = -1;
        for my $colnum (0 .. $width - 1) {
            my $tmp = $tree_map->[$rownum][$colnum];
            if ($tmp > $cur_height) {
                $cur_height = $tmp;
                $visible{$rownum}{$colnum} = 1;
            }
        }

        # Search from the right to left
        $cur_height = -1;
        for my $colnum (reverse(0 .. $width - 1)) {
            my $tmp = $tree_map->[$rownum][$colnum];
            if ($tmp > $cur_height) {
                $cur_height = $tmp;
                $visible{$rownum}{$colnum} = 1;
            }
        }
    }

    # Scan through all columns
    for my $colnum (0 .. $width - 1) {
        # Search top to bottom
        my $cur_height = -1;
        for my $rownum (0 .. $height - 1) {
            my $tmp = $tree_map->[$rownum][$colnum];
            if ($tmp > $cur_height) {
                $cur_height = $tmp;
                $visible{$rownum}{$colnum} = 1;
            }
        }

        # Search bottom to top
        $cur_height = -1;
        for my $rownum (reverse(0 .. $height - 1)) {
            my $tmp = $tree_map->[$rownum][$colnum];
            if ($tmp > $cur_height) {
                $cur_height = $tmp;
                $visible{$rownum}{$colnum} = 1;
            }
        }

    }

    # Count up how many locations are visible
    my $total_visible = 0;
    foreach my $row (keys %visible) {
        $total_visible += scalar keys %{$visible{$row}};
    }

    say "Part 1: $total_visible";

    # Calculate the max scenic score
    # Iterate through rows and columns (skip the outside perimeter, all of those
    # will have 1 edge with value 0, so the total score will be 0)
    my $max_score = 0;
    for my $rowno (1 .. @$tree_map - 2) {
        for my $colno (1 .. @$tree_map - 2) {
            # Height of the current tree
            my $cur_height = $tree_map->[$rowno]->[$colno];

            my $up = 0;
            for my $i (reverse(0 .. $rowno - 1)) {
                $up++;
                if ($tree_map->[$i]->[$colno] >= $cur_height) {
                    last;
                }
            }

            my $down = 0;
            for my $i ($rowno + 1 .. $height - 1) {
                $down++;
                if ($tree_map->[$i]->[$colno] >= $cur_height) {
                    last;
                }
            }

            my $left = 0;
            for my $i (reverse(0 .. $colno - 1)) {
                $left++;
                if ($tree_map->[$rowno]->[$i] >= $cur_height) {
                    last;
                }
            }

            my $right = 0;
            for my $i ($colno + 1 .. $width - 1) {
                $right++;
                if ($tree_map->[$rowno]->[$i] >= $cur_height) {
                    last;
                }
            }

            my $score = $up * $down * $left * $right;
            $max_score = $score if $score > $max_score;
            say "($rowno,$colno) Left=$left Right=$right Up=$up Down=$down (Scenic Score: $score)" if $g_verbose;
        }
    }
    say "Part 2: $max_score";

}

sub parse_input
{
    my ($filename) = @_;

    my @tree_map;
    my $row = 0;
    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    while (my $line = <$fh>) {
        chomp $line;
        map { push @{$tree_map[$row]}, $_ } split //, $line;
        $row++;
    }
    close($fh);

    return \@tree_map;
}
