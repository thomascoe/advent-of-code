#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

# Advent of Code Day 1:
# - Calorie Counting (https://adventofcode.com/2022/day/1)
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

    # Calculate the total calories each elf is carrying
    my @elf_total_calories;
    for my $elf (@$input) {
        my $elf_calories = 0;
        map { $elf_calories += $_ } @$elf;
        push @elf_total_calories, $elf_calories;
    }

    # Sort the total values, grab the top 3
    my @top3 = (sort { $b <=> $a } @elf_total_calories)[0..2];

    # Sum up the top 3 values
    my $total = 0;
    map { $total += $_ } @top3;

    say "The elf carrying the most calories is carrying $top3[0] calories";
    say "The top three elves are carrying a total of $total calories";
}

sub parse_input
{
    my ($filename) = @_;

    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    my @elves;
    my $elf_index = 0;
    while (my $line = <$fh>) {
        chomp $line;
        if ($line ne "") {
            push @{$elves[$elf_index]}, $line; # Add an item to an elf's inventory
        } else {
            $elf_index++; # Empty line, next item goes to the next elf
        }
    }
    close($fh);

    return \@elves;
}
