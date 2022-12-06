#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

# Advent of Code Day 3:
# - Rucksack Reorganization (https://adventofcode.com/2022/day/3)
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

    my $priority = 0;
    foreach my $rucksack (@$input) {
        # Count items in each compartment
        # Also count total items for use in part 2
        map {
            $rucksack->{first_items}{$_}++;
            $rucksack->{total_items}{$_}++
        } split //, $rucksack->{first_compartment};
        map {
            $rucksack->{second_items}{$_}++;
            $rucksack->{total_items}{$_}++
        } split //, $rucksack->{second_compartment};

        # Find the items common to both compartments
        my @common_items;
        map {
            push @common_items, $_ if exists $rucksack->{second_items}{$_}
        } keys %{$rucksack->{first_items}};

        # Add the priority of the first (only) common item
        $priority += get_priority($common_items[0]);
    }
    say "Part 1: $priority";

    # Split elves into groups of 3
    my @groups;
    push @groups, [ splice @$input, 0, 3 ] while @$input;
    $priority = 0;
    for my $group (@groups) {
        # Find the common item across all 3 in this group. This is the badge for the group
        my @common_items;
        map {
            push @common_items, $_ if (exists $group->[1]{total_items}{$_} and exists $group->[2]{total_items}{$_})
        } keys %{$group->[0]{total_items}};
        my $badge = $common_items[0];

        # Add up the priority of the badge
        $priority += get_priority($badge);
    }
    say "Part 2: $priority";
}

sub get_priority
{
    my ($item) = @_;

    # Convert theitem to ASCII
    # Subtract an offset based on capital or lowercase to get a priority
    my $ascii = ord($item);
    if ($ascii > 0x60) { # lowercase
        return $ascii - 0x60; # a = 1
    } else { # uppercase
        return $ascii - 0x26; # A = 27
    }
}

sub parse_input
{
    my ($filename) = @_;

    my @rucksacks;
    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    while (my $line = <$fh>) {
        chomp $line;
        my $len = length($line) / 2;
        push @rucksacks, {
            first_compartment => substr($line, 0, $len),
            second_compartment => substr($line, $len)
        };
    }
    close($fh);

    return \@rucksacks;
}
