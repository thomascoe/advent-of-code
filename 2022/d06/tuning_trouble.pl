#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

# Advent of Code Day 6:
# - Tuning Trouble (https://adventofcode.com/2022/day/6)
#
# Author: Thomas Coe

{
    my $filename = $ARGV[0];
    if (!defined $filename) {
        die("Usage: $0 filename");
    }

    my ($input) = parse_input($filename);

    # Search for start of packet sequence
    my $part1 = find_start_sequence($input, 4);
    say "Part 1: $part1";

    # Search for start of message sequence
    my $part2 = find_start_sequence($input, 14);
    say "Part 2: $part2";
}

# Return the number of characters that had to be parsed in $input to find a set
# of $count unique characters
sub find_start_sequence
{
    my ($input, $count) = @_;

    my $offset = 0;
    while ($offset < (length($input) - $count)) {
        # Count occurences of each character in the current set of $count characters
        my %char_cnt;
        map {
            $char_cnt{$_}++;
        } split //, substr($input, $offset, $count);

        # If all characters are unique, this is the start sequence
        if (scalar keys %char_cnt == $count) {
            last;
        }
        $offset++;
    }
    # Return number of characters that had to be parsed to find the full sequence
    return $offset + $count;
}

sub parse_input
{
    my ($filename) = @_;

    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    my $line = <$fh>;
    chomp $line;
    close($fh);

    return $line;
}
