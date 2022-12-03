#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

# Advent of Code Day 12:
# - Passage Pathing (https://adventofcode.com/2021/day/12)
#
# Author: Thomas Coe

my $g_verbose = 0;
my @g_complete_paths;

{
    my $filename = $ARGV[0];
    if (!defined $filename) {
        die("Usage: $0 filename [-v]");
    }
    if (defined $ARGV[1] and $ARGV[1] eq "-v") {
        $g_verbose = 1;
    }

    my ($map) = parse_input($filename);
    if ($g_verbose) {
        foreach my $src (keys %$map) {
            foreach my $dst (@{$map->{$src}}) {
                say "$src -> $dst";
            }
        }
    }

    my $count = find_paths($map);
    say "Part 1: $count";
}

sub parse_input
{
    my ($filename) = @_;

    my @edges;
    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    while (my $line = <$fh>) {
        chomp $line;
        my ($a, $b) = split /-/, $line;
        push @edges, [$a, $b];
    }
    close($fh);

    my %map;
    foreach my $edge (@edges) {
        my ($a, $b) = @$edge;
        push @{$map{$a}}, $b;
        push @{$map{$b}}, $a;
    }

    return \%map;
}

sub find_paths
{
    my ($map) = @_;

    my @path = ("start");
    explore_path($map, @path);

    if ($g_verbose) {
        for my $path (@g_complete_paths) {
            say join ",", @$path;
        }
    }

    return scalar @g_complete_paths;
}

sub explore_path
{
    my ($map, @path) = @_;
    my $current_cave = $path[-1];
    for my $next_cave (@{$map->{$current_cave}}) {
        # Skip small caves that are already in the path
        next if ($next_cave =~ m/^[a-z]+$/ and grep /^$next_cave$/, @path);

        # Add this new cave to the path in progress
        push @path, $next_cave;

        if ($next_cave eq "end") {
            # End of path. Add to global list of paths
            push @g_complete_paths, [@path];
        } else {
            # Path continues. Explore this next cave
            explore_path($map, @path)
        }

        # Remove the cave we just explored so we can try other branches
        pop @path;
    }
}
