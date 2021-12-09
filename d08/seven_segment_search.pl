#!/usr/bin/perl

use v5.10.1;
use strict;
use warnings;

# Advent of Code Day 8:
# - Seven Segment Search (https://adventofcode.com/2021/day/8)
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

    my ($displays) = parse_input($filename);

    my $cnt = count_easy_digits($displays);
    say "Part 1: $cnt";

    my $sum = sum_outputs($displays);
    say "Part 2: $sum";
}

sub parse_input
{
    my ($filename) = @_;

    my @displays;

    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    while (my $line = <$fh>) {
        chomp $line;
        my ($patterns, $outputs) = split /\|/, $line;
        $outputs =~ s/^ +//; # Remove leading spaces
        my @arr1 = split / /, $patterns;
        my @arr2 = split / /, $outputs;
        push @displays, {
            patterns => [@arr1],
            outputs => [@arr2],
        };
    }
    close($fh);

    return \@displays;
}

sub count_easy_digits
{
    my ($displays) = @_;
    my $count = 0;

    # Look at just the output values. Count the instances of the digits 1, 4, 7 or 8
    foreach my $display (@$displays) {
        foreach my $digit (@{$display->{outputs}}) {
            my $len = length($digit);
            $count++ if (grep /^$len$/, (2, 4, 3, 7));  # 1, 4, 7, or 8
        }
    }

    return $count;
}

sub sum_outputs
{
    my ($displays) = @_;
    my $sum = 0;

    foreach my $display (@$displays) {
        # Get the set of characters used to represent each digit
        my $char_sets = get_char_sets($display->{patterns});

        # Build the 4-digit number
        my $number;
        foreach my $chars (@{$display->{outputs}}) {
            my $digit = get_num($chars, $char_sets);
            say "Digit: $digit" if $g_verbose;
            $number .= $digit;
        }
        say "Number: $number" if $g_verbose;

        # Add to our sum
        $sum += $number;
    }

    return $sum;
}

sub get_char_sets
{
    my ($patterns) = @_;
    my @char_sets; # List of letter segments for each number

    # Parse out the easy digits we know basd on only the number of segments
    for my $digit (@$patterns) {
        my @chars = split //, $digit;
        given (length($digit)) {
            when (2) { $char_sets[1] = [@chars]; }
            when (4) { $char_sets[4] = [@chars]; }
            when (3) { $char_sets[7] = [@chars]; }
            when (7) { $char_sets[8] = [@chars]; }
            default {}
        }
    }

    # Identify 6-segment digits (9, 0, 6)
    for my $digit (@$patterns) {
        next unless (length($digit) eq 6);
        my @chars = split //, $digit;
        if (is_subset(\@chars, $char_sets[4])) { # 9 is the only 6-segment number containing all segments from 4
            $char_sets[9] = [@chars];
        } elsif (is_subset(\@chars, $char_sets[7])) { # 0 is the only remaining 6-segment number that fully contains 7 (9 also contains 7)
            $char_sets[0] = [@chars];
        } else { # 6 must be the remaining 6-segment number
            $char_sets[6] = [@chars];
        }
    }

    # Identify 5-segment digits (5, 3, and 2)
    for my $digit (@$patterns) {
        next unless (length($digit) eq 5);
        my @chars = split //, $digit;
        if (is_subset($char_sets[6], \@chars)) { # 5 is the only 5-segment number fully contained in 6
            $char_sets[5] = [@chars];
        } elsif (is_subset(\@chars, $char_sets[7])) { # 3 is the only 5-segment number that fully contains 7
            $char_sets[3] = [@chars];
        } else { # 2 must be the remaining 5-segment number
            $char_sets[2] = [@chars];
        }
    }

    return \@char_sets;
}

# Translate from a set of mismatched segments to the number being represented
sub get_num
{
    my ($chars, $char_sets) = @_;
    my @arr = split //, $chars;
    for (my $i = 0; $i < scalar @$char_sets; $i++) {
        return $i if (arr_equals($char_sets->[$i], \@arr));
    }
    say "WARNING: Couldn't find a mapping for the digit $chars";
    return undef;
}

# Check if one array (arr1) contains ALL elements form another (arr2)
# i.e. arr2 is a subset of arr1
sub is_subset
{
    my ($arr1, $arr2) = @_;
    for my $elem (@$arr2) {
        return 0 unless grep /^$elem$/, @$arr1;
    }
    return 1;
}

# Check if two arrays have equivalent contents
sub arr_equals
{
    my ($arr1, $arr2) = @_;
    return (is_subset($arr1, $arr2) and is_subset($arr2, $arr1));
}
