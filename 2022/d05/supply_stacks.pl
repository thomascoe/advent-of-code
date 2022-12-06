#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

use Storable qw(dclone);

# Advent of Code Day 5:
# - Supply Stacks (https://adventofcode.com/2022/day/5)
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

    my ($stacks, $steps) = parse_input($filename);

    # Create a clone of the initial stack state to use for part 2
    my $stacks2 = dclone($stacks);

    execute_steps($stacks, $steps, 1);
    execute_steps($stacks2, $steps, 2);
}

sub execute_steps
{
    my ($stacks, $steps, $part) = @_;

    # Execute the steps
    foreach my $step (@$steps) {
        # Array is zero-indexed, instructions are not
        my $src_stack = $stacks->[$step->{src}-1];
        my $dst_stack = $stacks->[$step->{dst}-1];

        # Remove the first <cnt> crates from the stack
        my @crates = splice(@$src_stack, 0, $step->{cnt});

        # Reverse them (the crane only processes 1 at a time in part 1)
        @crates = reverse(@crates) if $part == 1;

        # Add the crates to the destination stack
        unshift @$dst_stack, @crates;
    }
    print "Part $part: ";
    foreach my $stack (@$stacks) {
        print $stack->[0];
    }
    print "\n";
}

sub parse_input
{
    my ($filename) = @_;

    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    my $parsing_drawing = 1; # start off by parsing the drawing at the top
    my @stacks;
    my @steps;
    while (my $line = <$fh>) {
        chomp $line;
        if ($parsing_drawing and $line =~ m/\[/) {
            # There are 9 stacks with crates
            for (my $i=0; $i<9; $i++) {
                my $crate = substr($line, 0, 4, "");
                chop $crate if $crate =~ m/ $/;
                if ($crate =~ m/^\[(.)\]/) {
                    push @{$stacks[$i]}, $1; # Push onto array top-down
                }
            }
        } elsif ($parsing_drawing and $line eq "") { # empty line indicates next line will be steps
            $parsing_drawing = 0;
        } elsif (!$parsing_drawing) {
            if ($line =~ m/move (\d+) from (\d) to (\d)/) {
                push @steps, {
                    cnt => $1,
                    src => $2,
                    dst => $3
                };
            }
        }
    }
    close($fh);

    return \@stacks, \@steps;
}
