#!/usr/bin/perl -w

use strict;
use warnings;

# Advent of Code Day 3:
# - Binary Diagnostic
#
# Author: Thomas Coe

{
    my $filename = $ARGV[0];
    if (!defined $filename) {
        die("Usage: $0 filename");
    }

    get_power($filename);
    get_life_support_rating($filename);
}

sub get_power
{
    my ($filename) = @_;
    my @counts = ();

    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    while (my $line = <$fh>) {
        chomp $line;

        my $i = 0;
        foreach my $bit (split //, $line) {
            $bit == "1" ? $counts[$i++]++ : $counts[$i++]--;
        }
    }
    close($fh);

    # If counts is negative, 0 is most common. Otherwise, 1 is most common (or there is a tie)
    # Don't consider the case where they tie..
    my @gamma_bits = map { $_ < 0 ? 0 : 1 } @counts;
    my @epsilon_bits = map { $_ < 0 ? 1 : 0 } @counts;

    # Convert the arrays of bits into decimal numbers
    my $gamma = 0;
    my $epsilon = 0;
    my $num_bits = scalar @counts;
    for (my $i = 0; $i < $num_bits; $i++) {
        $gamma += 2 ** $i if $gamma_bits[$num_bits - 1 - $i]; # If the bit is set, increment our total
        $epsilon += 2 ** $i if $epsilon_bits[$num_bits - 1 - $i]; # If the bit is set, increment our total
    }

    my $power = $gamma * $epsilon;
    print "Gamma: $gamma, Epsilon: $epsilon, Power: $power\n";
}

sub get_life_support_rating
{
    my ($filename) = @_;
    my @counts = ();

    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    my @lines = <$fh>;
    close($fh);
    chomp(@lines);

    my $oxy_rating = filter_lines(\@lines, 0);
    print "Oxygen Generator Rating: $oxy_rating\n";

    my $co2_rating = filter_lines(\@lines, 1);
    print "CO2 Scrubber Rating: $co2_rating\n";

    my $life_rating = $oxy_rating * $co2_rating;
    print "Life Support Rating: $life_rating\n";
}

# Filter the lines down using two different methods
# least_mode = false: filter for most common value in each bit position
# least_mode = true: filter for least common value in each bit position
#
# Return the decimal value of the final remaining binary line
sub filter_lines
{
    my ($lines, $least_mode) = @_;
    my @dup_lines = @$lines; # Don't modify initial array

    my $bit_index = 0; # index into the bit string
    while (scalar @dup_lines > 1) {
        my $bit_sum = 0; # Used to determine most/least common bit
        foreach my $line (@dup_lines) {
            (split //, $line)[$bit_index] eq "1" ? $bit_sum++ : $bit_sum--;
        }

        # Filter to keep lines based on the most/least common bit in the current bit index
        if ((!$least_mode and $bit_sum < 0) or ($least_mode and $bit_sum >= 0)) {
            @dup_lines = grep /^.{$bit_index}0/, @dup_lines; # Keep the 0 bit
        } else {
            @dup_lines = grep /^.{$bit_index}1/, @dup_lines; # Keep the 1 bit
        }

        $bit_index++;
    }
    return eval("0b".$dup_lines[0]);
}
