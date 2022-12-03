#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

use List::Util qw( sum );

# Advent of Code Day 9:
# - Smoke Basin (https://adventofcode.com/2021/day/9)
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

    my ($map) = parse_input($filename);

    my $low_points = low_points($map);

    my $sum = sum(map { $_->{val} + 1 } @$low_points);
    say "Part 1: $sum";

    my $part2 = largest_basins($map, $low_points);
    say "Part 2: $part2";
}

sub parse_input
{
    my ($filename) = @_;

    my @map;
    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    while (my $line = <$fh>) {
        chomp $line;
        my @digits = split //, $line;
        push @map, \@digits;
    }
    close($fh);

    return \@map;
}

sub low_points
{
    my ($map) = @_;

    my @low_points;

    for (my $i = 0; $i < scalar @$map; $i++) {
        my $row = $map->[$i];
        for (my $j = 0; $j < scalar @$row; $j++) {
            my $val = $row->[$j];
            next if ($i > 0 and $val >= $map->[$i-1]->[$j]);
            next if ($i+1 < scalar @$map and $val >= $map->[$i+1]->[$j]);
            next if ($j > 0 and $val >= $map->[$i]->[$j-1]);
            next if ($j+1 < scalar @$row and $val >= $map->[$i]->[$j+1]);
            push @low_points, { x=>$j, y=>$i, val=>$val };
            say "$i,$j: $val" if $g_verbose;
        }
    }

    return \@low_points;
}

sub largest_basins
{
    my ($map, $low_points) = @_;

    # Initialize a full grid we can use for printing later
    my $total_rows = scalar @$map;
    my $total_cols = scalar @{$map->[0]};
    my @grid;
    for my $row (0..$total_rows-1) {
        for my $col (0..$total_cols-1) {
            $grid[$row][$col] = 0;
        }
    }

    my @sizes;
    foreach my $point (@$low_points) { # Each low point has one basin around it
        my %segments;

        # Initialize first segment around the low point of the basin
        {
            my $row = $map->[$point->{y}];

            # Check backwards from the low point to find the start of the segment
            my $range_start;
            for (my $j = $point->{x}; $j >= 0; $j--) {
                my $val = $row->[$j];
                if ($val eq "9") {
                    $range_start = $j+1;
                    last;
                }
            }
            $range_start = 0 if !defined $range_start;

            # Check forwards from the low point to find the end of the segment
            my $range_end;
            for (my $j = $point->{x}; $j < scalar @$row; $j++) {
                my $val = $row->[$j];
                if ($val eq "9") {
                    $range_end = $j-1;
                    last;
                }
            }
            $range_end = (scalar @$row - 1) if !defined $range_end;

            $segments{$point->{y}}{$range_start} = $range_end;
        }

        my $changed;
        do { # Keep iterating up and down over the rows until we don't have new changes
            $changed = 0;

            # Iterate up from the bottom row
            my $max_row = (sort {$b <=> $a} keys %segments)[0];
            for (my $i = $max_row - 1; $i >= 0; $i--) {
                my $row = $map->[$i];

                # Get candidate ranges
                my $ranges = get_ranges($row);

                last if !defined $segments{$i+1};
                my $adj_segments = $segments{$i+1};

                foreach my $range (@$ranges) {
                    my ($start, $end) = @$range;
                    next if defined $segments{$i} and defined $segments{$i}{$start}; # Already matched range
                    # Check if this range is connected to any saved segments on the next row
                    if (range_is_connected($range, $adj_segments)) {
                        # Save this range in our segments list
                        $changed = 1;
                        $segments{$i}{$start} = $end;
                    }
                }
            }

            # Iterate down from the top row
            my $min_row = (sort {$a <=> $b} keys %segments)[0];
            for (my $i = $min_row + 1; $i < scalar @$map; $i++) {
                my $row = $map->[$i];

                # Get candidate ranges
                my $ranges = get_ranges($row);

                last if !defined $segments{$i-1};
                my $adj_segments = $segments{$i-1};

                foreach my $range (@$ranges) {
                    my ($start, $end) = @$range;
                    next if defined $segments{$i} and defined $segments{$i}{$start}; # Already matched range
                    # Check if this range is connected to any saved segments on the next row
                    if (range_is_connected($range, $adj_segments)) {
                        # Save this range in our segments list
                        $changed = 1;
                        $segments{$i}{$start} = $end;
                    }
                }
            }

        } while ($changed);

        # Get the total size of this basin by adding up the size of each segment
        my $basin_size = 0;
        foreach my $row (keys %segments) {
            foreach my $start (keys %{$segments{$row}}) {
                my $end = $segments{$row}->{$start};

                # Count the number of locations in this segment
                $basin_size += ($end - $start + 1);

                # Save this segment to the grid so we can print a picture if needed
                for my $j ($start .. $end) {
                    $grid[$row][$j] = 1;
                }
            }
        }
        say "Basin size: $basin_size" if $g_verbose;
        push @sizes, $basin_size;
    }

    if ($g_verbose) { # Print the grid
        foreach my $row (@grid) {
            foreach my $col (@$row) {
                if ($col) {
                    print "*";
                } else {
                    print "_";
                }
            }
            print "\n";
        }
    }

    # Extract the top three basin sizes
    my @top_three = (sort {$b <=> $a} @sizes)[0..2];

    # Return the product of the top three basin sizes
    return $top_three[0] * $top_three[1] * $top_three[2];
}

# Check if a new range overlaps any existing segments in the adjacent row
sub range_is_connected
{
    my ($range, $row_segms) = @_;
    foreach my $segm_start (keys %$row_segms) {
        my $segm_end = $row_segms->{$segm_start};
        return 1 if ($range->[0] >= $segm_start and $range->[0] <= $segm_end);
        return 1 if ($range->[1] >= $segm_start and $range->[1] <= $segm_end);
        return 1 if ($range->[0] <= $segm_start and $range->[1] >= $segm_end);
    }
    return 0;
}

# Get all candidate ranges from a row
sub get_ranges
{
    my ($row) = @_;

    # Grab all of the candidate ranges
    my @ranges;
    my $range_start;
    for (my $j = 0; $j < scalar @$row; $j++) {
        my $val = $row->[$j];
        if (!defined $range_start and $val ne "9") {
            # Start of segment
            $range_start = $j;
        }
        if (defined $range_start and $val eq "9") {
            # End of segment
            push @ranges, [$range_start, $j-1];
            $range_start = undef;
        }
    }
    # Catch segments that end on the edge
    if (defined $range_start) {
        push @ranges, [$range_start, scalar @$row - 1];
    }

    return \@ranges;
}
