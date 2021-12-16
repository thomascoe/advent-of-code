#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

# Advent of Code Day 15:
# - Chiton (https://adventofcode.com/2021/day/15)
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
    print_map($map) if $g_verbose;

    my $risk = find_lowest_risk($map);
    say "Part 1: $risk";
}

sub parse_input
{
    my ($filename) = @_;

    my @map;
    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    while (my $line = <$fh>) {
        chomp $line;
        my @cols = split //, $line;
        push @map, \@cols;
    }
    close($fh);

    return \@map;
}

sub print_map
{
    my ($map) = @_;
    foreach my $row (@$map) {
        foreach my $col (@$row) {
            print "$col";
        }
        print "\n";
    }
}

sub find_lowest_risk
{
    my ($map) = @_;
    # TODO: find the lowest total risk path

    return 0;
}
