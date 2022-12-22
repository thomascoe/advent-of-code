#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

use Data::Dumper;
use List::Util qw(min);

# Advent of Code Day 13:
# - Distress Signal (https://adventofcode.com/2022/day/13)
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

    my $index = 1;
    my $sum = 0;
    my @all_packets;
    foreach my $pair (@$input) {
        say "#########################" if $g_verbose;
        push @all_packets, map {eval $_} @$pair;
        my $sorted = compare_pairs(eval($pair->[0]), eval($pair->[1]));
        say "Pair $index Sorted: $sorted" if $g_verbose;
        if ($sorted == -1) {
            $sum += $index;
        }
        $index++;
    }

    say "Part 1: $sum";

    # Add divider packets
    push @all_packets, ([[2]], [[6]]);

    # Sort all of the packets using the compare function from part 1
    my @sorted = sort {compare_pairs($a, $b)} @all_packets;

    # Decoder key is the indexes of the divider packets multiplied
    my $decoder_key = 1;
    for my $i (0 .. $#sorted) {
        if (ref($sorted[$i]) eq "ARRAY" and scalar @{$sorted[$i]} == 1) {
            my $sub = $sorted[$i]->[0];
            if (ref($sub) eq "ARRAY" and scalar @{$sub} == 1) {
                $decoder_key *= ($i+1) if ($sub->[0] == "2" or $sub->[0] == "6")
            }
        }
    }

    say "Part 2: $decoder_key";
}

sub compare_pairs
{
    my ($left, $right) = @_;

    say "LEFT Ref: " . ref($left) if $g_verbose;
    print Dumper $left if $g_verbose;
    say "RIGHT Ref: " . ref($left) if $g_verbose;
    print Dumper $right if $g_verbose;

    # If these are both integers, compare directly
    if (ref $left eq "" and ref $right eq "") {
        return ($left <=> $right);
    }

    # Make them both arrays if one of them isn't
    $left = [$left] if ref $left ne "ARRAY";
    $right = [$right] if ref $right ne "ARRAY";

    # Loop through all elements of the shortest list, comparing them recursively
    my $min = min(scalar @$left, scalar @$right);
    for my $i (0 .. $min-1) {
        my $rc = compare_pairs($left->[$i], $right->[$i]);
        # If we found a match where one element is different, return now
        return $rc if $rc != 0;
    }

    # Otherwise, no match. Lists must be different sizes
    return scalar(@$left) <=> scalar(@$right);
}

sub parse_input
{
    my ($filename) = @_;

    my @packet_pairs;
    my @pair;
    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    while (my $line = <$fh>) {
        chomp $line;
        next if $line eq "";

        if (@pair >= 2 ) {
            push @packet_pairs, [@pair];
            @pair = ();
        }
        push @pair, $line;
    }
    close($fh);
    push @packet_pairs, [@pair];

    return \@packet_pairs;
}
