#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

# Advent of Code Day 10:
# - Cathode-Ray Tube (https://adventofcode.com/2022/day/10)
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

    my ($instructions) = parse_input($filename);

    my %interesting = (
        "20" => 20,
        "60" => 60,
        "100" => 100,
        "140" => 140,
        "180" => 180,
        "220" => 220,
    );

    my $cycle = 0;
    my $x = 1;
    my $total_strength = 0;
    for my $inst (@$instructions) {
        if ($inst =~ m/noop/) {
            $cycle++;
            if ($interesting{$cycle}) {
                my $s = $cycle * $x;
                $total_strength += $s;
                say "!!Cycle: $cycle, X: $x, strength: $s" if $g_verbose;
            }
        } else {
            my (undef, $number) = split / /, $inst;
            say "Add: $number" if $g_verbose;
            if ($interesting{$cycle+1}) {
                my $s = ($cycle+1) * $x;
                $total_strength += $s;
                say "!!Cycle: ".($cycle+1).", X: $x, strength: $s" if $g_verbose;
            }
            if ($interesting{$cycle+2}) {
                my $s = ($cycle+2) * $x;
                $total_strength += $s;
                say "!!Cycle: ".($cycle+2).", X: $x, strength: $s" if $g_verbose;
            }
            $x += $number;
            $cycle += 2;
        }
        say "Cycle: $cycle X: $x" if $g_verbose;
    }
    say "Part 1: $total_strength";
}

sub parse_input
{
    my ($filename) = @_;

    my @instructions;
    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    while (my $line = <$fh>) {
        chomp $line;
        push @instructions, $line;
    }
    close($fh);

    return \@instructions;
}
