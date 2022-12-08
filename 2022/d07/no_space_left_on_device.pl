#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

use Data::Dumper;

# Advent of Code Day 7:
# - No Space Left On Device (https://adventofcode.com/2022/day/7)
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

    my @dir_tree;
    my %dir_sizes;
    foreach my $line (@$input) {
        # Process cd commands and update the directory tree list
        if ($line =~ m/^\$ cd (.*)$/) {
            my $dir = $1;
            if ($dir eq "/") {
                @dir_tree = ();
            } elsif ($dir eq "..") {
                pop @dir_tree;
            } else {
                push @dir_tree, $1;
            }
            say "cd to $dir" if $g_verbose;
        }

        # Look at file sizes
        if ($line =~ m/^(\d+) (.*)$/) {
            my $size = $1;
            my $file = $2;

            say "$file=$size" if $g_verbose;

            # Build the full path of each directory in the tree
            # Add the size of this file to the size of the directory
            my $path = "/";
            $dir_sizes{$path} += $size;
            foreach my $dir (@dir_tree) {
                $path .= "$dir/";
                $dir_sizes{$path} += $size;
            }
        }
    }
    print Dumper \%dir_sizes if $g_verbose;

    # Sum up the size of all directories that are at most 100000 in size
    my $part1 = 0;
    foreach my $dir (keys %dir_sizes) {
        if ($dir_sizes{$dir} <= 100000) {
            $part1 += $dir_sizes{$dir};
        }
    }
    say "Part 1: $part1";

    # Calculate what we need to free
    my $free_disk = 70000000 - $dir_sizes{"/"};
    my $to_free = 30000000 - $free_disk;
    say "Need to free $to_free" if $g_verbose;

    # Find the candidate directory to remove which is the smallest that is big enough
    my $candidate = $dir_sizes{"/"};
    foreach my $dir (keys %dir_sizes) {
        if ($dir_sizes{$dir} < $candidate and $dir_sizes{$dir} >= $to_free) {
            $candidate = $dir_sizes{$dir};
        }
    }
    say "Part 2: $candidate";
}

sub parse_input
{
    my ($filename) = @_;

    my @lines;
    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    while (my $line = <$fh>) {
        chomp $line;
        push @lines, $line;
    }
    close($fh);

    return \@lines;
}
