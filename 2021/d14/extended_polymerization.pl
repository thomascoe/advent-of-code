#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

# Advent of Code Day 14:
# - Extended Polymerization (https://adventofcode.com/2021/day/14)
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

    my ($template, $rules) = parse_input($filename);
    say "$template" if $g_verbose;

    # Run 10 iterations of pair insertion
    for (1..10) {
        $template = pair_insertion($template, $rules);
    }

    # Calc the difference between most/least common elements
    my $result = calc_diff($template);
    say ("Part 1: $result");

    ### TODO: Finish part 2. This naive implementation is too slow
    exit;
    for (11..40) {
        $template = pair_insertion($template, $rules);
    }
    $result = calc_diff($template);
    say ("Part 2: $result");
}

sub parse_input
{
    my ($filename) = @_;

    my $template;
    my %rules;

    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");

    # Template is first line
    $template = <$fh>;
    chomp $template;

    while (my $line = <$fh>) {
        chomp $line;
        if ($line =~ m/^(..) -> (.)$/) {
            $rules{$1} = $2;
        }
    }
    close($fh);

    return $template, \%rules;
}

sub pair_insertion
{
    my ($template, $rules) = @_;
    my @elements = split //, $template;

    # Iterate through all the pairs. $i should point to index of second elem in pair
    for (my $i = 1; $i < scalar @elements; $i++) {
        my $pair = join "", @elements[$i-1..$i];
        if (defined $rules->{$pair}) {
            # If we had a rule for this pair, insert the new element into the array
            splice(@elements,$i,0,$rules->{$pair});
            # Increment $i so that we are still pointing at the correct next pair
            $i++;
        }
    }

    return join "", @elements;
}

sub calc_diff
{
    my ($template) = @_;
    my @elements = split //, $template;

    # Count up occurences of each element
    my %counts;
    for my $elem (@elements) {
        $counts{$elem}++;
    }

    # Find the least common and most common elements (initialize them to a random value in the hash)
    my $least_common = (keys %counts)[0];
    my $most_common = $least_common;
    for my $key (keys %counts) {
        $least_common = $key if ($counts{$least_common} > $counts{$key});
        $most_common = $key if ($counts{$most_common} < $counts{$key});
    }

    # We want to know the difference between counts of the most and least common elements
    return $counts{$most_common} - $counts{$least_common};
}
