#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

# Advent of Code Day 5:
# - Hydrothermal Venture (https://adventofcode.com/2021/day/5)
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

    my ($lines) = parse_input($filename);

    my $count = find_overlap($lines, 0);
    say "Part 1: Found $count overlapping points";

    $count = find_overlap($lines, 1);
    say "Part 2: Found $count overlapping points";
}

sub parse_input
{
    my ($filename) = @_;
    my @lines;

    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");

    while (my $line = <$fh>) {
        chomp $line;
        $line =~ m/^(\d+),(\d+) -> (\d+),(\d+)$/;
        push @lines, {
            x1 => $1,
            y1 => $2,
            x2 => $3,
            y2 => $4,
        };
    }
    close($fh);

    return \@lines;
}

sub find_overlap
{
    my ($lines, $b_count_diagonal) = @_;
    my @grid;

    foreach my $line ( @$lines ) {
        if ($line->{x1} eq $line->{x2}) {
            my $x = $line->{x1};
            my ($low_y, $hi_y) = sort {$a <=> $b} ($line->{y1}, $line->{y2});
            for my $y ($low_y..$hi_y) {
                $grid[$y][$x]++;
            }
        } elsif ($line->{y1} eq $line->{y2}) {
            my $y = $line->{y1};
            my ($low_x, $hi_x) = sort {$a <=> $b} ($line->{x1}, $line->{x2});
            for my $x ($low_x..$hi_x) {
                $grid[$y][$x]++;
            }
        } else {
            # Diagonal Line
            next unless $b_count_diagonal;

            # Line should only ever be 45 degrees
            if (abs($line->{x1}-$line->{x2}) ne abs($line->{y1}-$line->{y2})) {
                say "WARNING! Found a non-45 degree diagonal line! ($line->{x1}, $line->{y1}) -> ($line->{x2}, $line->{y2})";
                next;
            }

            # Increment from the lowest to highest x
            my ($low_x, $hi_x) = sort {$a <=> $b} ($line->{x1}, $line->{x2});

            # Start with the matching y value
            my $y = $low_x eq $line->{x1} ? $line->{y1} : $line->{y2};

            # y should either increment or decrement by 1
            my $final_y = $y eq $line->{y1} ? $line->{y2} : $line->{y1};
            my $d_y = $final_y > $y ? 1 : -1;

            # Loop through all the values
            for my $x ($low_x..$hi_x) {
                $grid[$y][$x]++;
                $y += $d_y; # Don't forget to increment y as well
            }
        }
    }

    print_grid(\@grid) if $g_verbose;

    my $count = 0;
    foreach my $row (@grid) {
        foreach my $elem (@$row) {
            $count++ if (defined $elem and $elem > 1);
        }
    }
    return $count;
}

sub print_grid
{
    my ($grid) = @_;

    # Figure out the widest row
    my $max_len = 0;
    for my $row (@$grid) {
        if (defined $row) {
            if (scalar @$row > $max_len) {
                $max_len = scalar @$row;
            }
        }
    }

    for my $row (@$grid) {
        if (!defined $row) {
            say "." x $max_len;
            next;
        }
        for (my $i = 0; $i < $max_len; $i++) {
            if (defined $row->[$i]) {
                print "$row->[$i]";
            } else {
                print ".";
            }
        }
        print "\n";
    }
}
