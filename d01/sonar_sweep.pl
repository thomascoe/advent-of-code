#!/usr/bin/perl -w

use strict;
use warnings;

# Advent of Code Day 1:
# - Sonar Sweep
#
# Author: Thomas Coe

{
    my $filename = $ARGV[0];
    if (!defined $filename) {
        die("Usage: $0 filename");
    }

    part1($filename);
    part2($filename);
}

sub part1
{
    my ($filename) = @_;

    my $cur_depth; # Last seen depth
    my $depth_increases = 0;

    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    while (my $line = <$fh>) {
        chomp $line;

        # Count the increase
        if (defined $cur_depth and $line > $cur_depth) {
            $depth_increases++;
        }

        # Update the last seen depth
        $cur_depth = $line;
    }
    close($fh);

    print "Number of individual increases: $depth_increases\n";
}

sub part2
{
    my ($filename) = @_;

    my @cur_window; # Store the sliding window of 3 depths
    my $cur_depth_sum; # Most recent window sum
    my $depth_increases = 0;

    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    while (my $line = <$fh>) {
        chomp $line;
        push @cur_window, $line;

        # Ignore the window until it's filled up
        if (scalar @cur_window == 3) {

            # Sum up all depths in the window
            my $new_depth_sum = 0;
            map { $new_depth_sum += $_ } @cur_window;

            # Count the increase
            if (defined $cur_depth_sum and $new_depth_sum > $cur_depth_sum) {
                $depth_increases++;
            }

            # Update the most recent sum
            $cur_depth_sum = $new_depth_sum;

            # Remove first entry from window, we're done with it now
            shift @cur_window;
        }
    }
    close($fh);

    print "Number of 3-window increases: $depth_increases\n";
}
