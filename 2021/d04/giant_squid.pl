#!/usr/bin/perl -w

use strict;
use warnings;

use List::Util qw(min max);

# Advent of Code Day 4:
# - Giant Squid
#
# Author: Thomas Coe

{
    my $filename = $ARGV[0];
    if (!defined $filename) {
        die("Usage: $0 filename");
    }

    my ($numbers, $boards) = parse_input($filename);

    # Get the index into called numbers where each board wins
    my @winning_indexes;
    for (my $i = 0; $i < scalar @$boards; $i++) {
        $winning_indexes[$i] = find_winning_index($boards->[$i], $numbers);
    }

    # Find the winning board (part 1)
    my $low_idx = min(@winning_indexes);

    # Find the losing board (part 2)
    my $high_idx = max(@winning_indexes);

    for (my $i = 0; $i < scalar @$boards; $i++) {
        if ($winning_indexes[$i] == $low_idx or $winning_indexes[$i] == $high_idx) {
            # List of the numbers called before the win
            my @winning_numbers = @$numbers[0..$winning_indexes[$i]];

            # Get the sum of unmarked cells
            my $sum = get_unmarked_sum($boards->[$i], \@winning_numbers);

            # Calculate the score
            my $score = $numbers->[$winning_indexes[$i]] * $sum;

            if ($winning_indexes[$i] == $low_idx) { # Winning board
                print "Part 1 Score: $score\n";
            } else { # Losing board
                print "Part 2 Score: $score\n";
            }
        }
    }
}

sub parse_input
{
    my ($filename) = @_;
    my @numbers;
    my @boards;

    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");

    # First line is the list of numbers being called
    my $line = <$fh>;
    chomp $line;
    @numbers = split /,/, $line;

    # The remaining lines contain the boards
    my $board_index = 0; # Which board are we working on?
    my $board_line = 0; # Which line in the board are we parsing?
    while ($line = <$fh>) {
        chomp $line;
        next if $line =~ m/^$/; # Skip empty lines

        $line =~ s/^ +//; # Remove leading spaces
        @{$boards[$board_index]->[$board_line++]} = split / +/, $line;
        if ($board_line == 5) { # Board is full
            $board_line = 0;
            $board_index++;
        }
    }
    close($fh);

    return \@numbers, \@boards;
}

sub find_winning_index
{
    my ($board, $numbers) = @_;

    # start with the first 5 numbers (index 4), can't win before then
    # Loop through all the numbers if needed until this board wins
    my $index = 4; 
    while ($index < scalar @$numbers) {
        # Create a hash of the already called numbers for easy lookup
        my %called = map { $_ => 1 } @$numbers[0..$index];

        # Check rows
        ROW: foreach my $row (@$board) {
            foreach my $element (@$row) {
                next ROW unless defined $called{$element};
            }
            # If we've reached here, all elements in the row were called!
            return $index;
        }

        # Check columns
        COLUMN: for (my $col=0; $col<5; $col++) {
            foreach my $row (@$board) {
                next COLUMN unless defined $called{$row->[$col]};
            }
            # If we've reached here, all elements in the column were called!
            return $index;
        }

        $index++;
    }
    print "WARNING: No win found for board\n";
    return undef; # This board never wins
}

sub get_unmarked_sum
{
    my ($board, $numbers) = @_;

    my %called = map { $_ => 1 } @$numbers;

    my $sum = 0;
    foreach my $row (@$board) {
        foreach my $element (@$row) {
            $sum += $element unless defined $called{$element};
        }
    }
    return $sum;
}
