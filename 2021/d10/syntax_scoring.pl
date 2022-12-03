#!/usr/bin/perl

use v5.10.1;
use strict;
use warnings;

# Advent of Code Day 10:
# - Syntax Scoring (https://adventofcode.com/2021/day/10)
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

    my ($lines) = parse_input($filename);

    my $score = syntax_error_score($lines);
    say "Part 1: $score";

    $score = incomplete_score($lines);
    say "Part 2: $score";
}

sub parse_input
{
    my ($filename) = @_;

    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    my @lines = <$fh>;
    chomp @lines;
    close($fh);

    return \@lines;
}

# Calculate the part 1 answer
# The total syntax error score for all lines
sub syntax_error_score
{
    my ($lines) = @_;

    my %score_map = (
        ')' => 3,
        ']' => 57,
        '}' => 1197,
        '>' => 25137,
    );

    my $score = 0;
    LINE: foreach my $line (@$lines) {
        my @closing_chars; # Maintain a stack of expected closing characters
        foreach my $char (split //, $line) {
            for ($char) {
                # If it's an opening character, push the expected closing character to the top of the stack
                push @closing_chars, ')' when '(';
                push @closing_chars, ']' when '[';
                push @closing_chars, '}' when '{';
                push @closing_chars, '>' when '<';
                # Otherwise, it must be a closing character
                default {
                    my $expected = pop @closing_chars;
                    if ($char ne $expected) {
                        # If the character is not what we expect, update the score with this first illegal character
                        say "Line $line: Expected $expected, but found $char instead." if $g_verbose;
                        $score += $score_map{$char};
                        next LINE; # Don't consider any more characters in this line
                    }
                }
            }
        }
    }
    return $score;
}

# Calculate the part 2 answer
# The middle score of all of the lines' completion scores
sub incomplete_score
{
    my ($lines) = @_;

    my %score_map = (
        ')' => 1,
        ']' => 2,
        '}' => 3,
        '>' => 4,
    );

    # Calculate the scores for each line
    my @line_scores;
    LINE: foreach my $line (@$lines) {
        my @closing_chars; # Maintain a stack of expected closing characters
        foreach my $char (split //, $line) {
            for ($char) {
                # If it's an opening character, push the expected closing character to the top of the stack
                push @closing_chars, ')' when '(';
                push @closing_chars, ']' when '[';
                push @closing_chars, '}' when '{';
                push @closing_chars, '>' when '<';
                # Otherwise, it must be a closing character
                default {
                    next LINE if $char ne pop @closing_chars; # If we hit an illegal character, skip this line
                }
            }
        }

        # If we reach here, the line is valid but incomplete
        # Complete the line by popping the missing @closing_chars off the stack
        my $score = 0;
        while (my $char = pop @closing_chars) {
            # Score the line as we go
            $score *= 5;
            $score += $score_map{$char};
        }
        push @line_scores, $score;
    }

    # Number of scores will be odd
    # Because of zero-indexing, dividing the length by 2 returns the midpoint index
    # Sort the list of scores, return the item in the midpoint index
    my $midpoint = int(scalar @line_scores / 2);
    return (sort { $a <=> $b } @line_scores)[$midpoint];
}
