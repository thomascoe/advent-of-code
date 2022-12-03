#!/usr/bin/perl -w

use strict;
use warnings;

use Submarine qw();

# Advent of Code Day 2:
# - Dive
#
# Author: Thomas Coe

{
    my $filename = $ARGV[0];
    if (!defined $filename) {
        die("Usage: $0 filename");
    }

    my $submarine1 = new Submarine('basic');
    move_submarine($submarine1, $filename);

    my $submarine2 = new Submarine('advanced');
    move_submarine($submarine2, $filename);
}

sub move_submarine
{
    my ($submarine, $filename) = @_;

    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    while (my $line = <$fh>) {
        chomp $line;

        # Get the command
        my ($command, $units) = split / /, $line;

        # Move the sub
        if ($command eq "forward") {
            $submarine->forward($units);
        } elsif ($command eq "down") {
            $submarine->down($units);
        } elsif ($command eq "up") {
            $submarine->up($units);
        }
    }
    close($fh);

    print "Submarine Type: " . $submarine->getMovement() . "\n";
    print "Current position: " . $submarine->getPos() . "\n";
    print "Current depth " . $submarine->getDepth() . "\n";
    my $res = $submarine->getPos() * $submarine->getDepth();
    print "Result: $res\n";
}
