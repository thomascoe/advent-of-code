#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

use List::Util qw( sum );

# Advent of Code Day 9:
# - Smoke Basin (https://adventofcode.com/2021/day/9)
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

    my ($map) = parse_input($filename);

    my $sum = low_points($map);
    say "Part 1: $sum";
}

sub parse_input
{
    my ($filename) = @_;

    my @map;
    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    while (my $line = <$fh>) {
        chomp $line;
        my @digits = split //, $line;
        push @map, \@digits;
    }
    close($fh);

    return \@map;
}

sub low_points
{
    my ($map) = @_;

    my @low_points;

    for (my $i = 0; $i < scalar @$map; $i++) {
        my $row = $map->[$i];
        for (my $j = 0; $j < scalar @$row; $j++) {
            my $val = $row->[$j];
            next if ($i > 0 and $val >= $map->[$i-1]->[$j]);
            next if ($i+1 < scalar @$map and $val >= $map->[$i+1]->[$j]);
            next if ($j > 0 and $val >= $map->[$i]->[$j-1]);
            next if ($j+1 < scalar @$row and $val >= $map->[$i]->[$j+1]);
            push @low_points, { x=>$j, y=>$i, val=>$val };
            say "$i,$j: $val" if $g_verbose;
        }
    }

    return sum(map { $_->{val} + 1 } @low_points);
}
