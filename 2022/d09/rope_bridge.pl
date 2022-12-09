#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

# Advent of Code Day 9:
# - Rope Bridge (https://adventofcode.com/2022/day/9)
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

    my ($motions) = parse_input($filename);

    # Row, column
    my @head_pos = (0,0);
    my @tail_pos = (0,0);
    my %tail_visited = (
        "0,0" => 1,
    );

    for my $motion (@$motions) {
        for my $i (1 .. $motion->{count}) {
            my @old_head = @head_pos;
            if ($motion->{dir} eq 'R') {
                $head_pos[1]++; # Increase col
            } elsif ($motion->{dir} eq 'L') {
                $head_pos[1]--; # Decrease col
            } elsif ($motion->{dir} eq 'U') {
                $head_pos[0]++; # Increase row
            } elsif ($motion->{dir} eq 'D') {
                $head_pos[0]--; # Decrease row
            }

            if (abs($tail_pos[0] - $head_pos[0]) > 1) {
                @tail_pos = ($old_head[0], $head_pos[1]);
                my $key = join ',', @tail_pos;
                $tail_visited{$key} = 1;
            } elsif (abs($tail_pos[1] - $head_pos[1]) > 1) {
                @tail_pos = ($head_pos[0], $old_head[1]);
                my $key = join ',', @tail_pos;
                $tail_visited{$key} = 1;
            }
            say "Head: ($head_pos[0],$head_pos[1]), Tail: ($tail_pos[0],$tail_pos[1])" if $g_verbose;
        }
    }

    print_map(\%tail_visited, 6) if $g_verbose;
    my $part1 = scalar keys %tail_visited;
    say "Part 1: $part1";
}

sub print_map
{
    my ($visited, $size) = @_;

    for my $row (reverse(0 .. $size)) {
        for my $col (0 .. $size) {
            if ($visited->{join ',', $row, $col}) {
                print "#";
            } else {
                print ".";
            }
        }
        print "\n";
    }

}

sub parse_input
{
    my ($filename) = @_;

    my @motions;
    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    while (my $line = <$fh>) {
        chomp $line;
        my ($dir, $count) = split / /, $line;
        push @motions, {dir => $dir, count => $count};
    }
    close($fh);

    return \@motions;
}
