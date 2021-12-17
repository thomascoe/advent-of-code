#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

# Advent of Code Day 16:
# - Packet Decoder (https://adventofcode.com/2021/day/16)
#
# Author: Thomas Coe

my $g_verbose = 0;
my $g_version_sum = 0;

{
    my $filename = $ARGV[0];
    if (!defined $filename) {
        die("Usage: $0 filename [-v]");
    }
    if (defined $ARGV[1] and $ARGV[1] eq "-v") {
        $g_verbose = 1;
    }

    my ($packets) = parse_input($filename);

    # Parse each packet
    foreach my $packet (@$packets) {
        decode_packet($packet);
        say "Part 1: $g_version_sum";
    }
}

sub parse_input
{
    my ($filename) = @_;

    my @packets;

    open(my $fh, "<", $filename) or die ("Couldn't open file $filename!");
    while (my $line = <$fh>) {
        chomp $line;
        push @packets, $line;
    }
    close($fh);

    return \@packets;
}

sub decode_packet
{
    my ($packet) = @_;

    # Convert the packet into a bit-stream
    my $bits;
    foreach my $nibble (split //, $packet) {
        my $dec = hex($nibble);
        my $bin = sprintf("%04b", $dec);
        $bits .= $bin;
        print "$nibble:$dec:$bin " if $g_verbose;
    }
    print "\n" if $g_verbose;

    say "$bits" if $g_verbose;

    # make a bitvector
    my @bitvec = split //, $bits;

    # Reset the version sum, parse the one outer packet
    $g_version_sum = 0;
    parse_packet(\@bitvec, undef, 1);
}

sub parse_packet
{
    my ($bitvec, $bit_len, $packet_len) = @_;
    my @bitvec = @$bitvec;

    die if scalar @bitvec < 11; # Sanity check.. Smallest valid packet is 11 bits

    # Extract version and type
    my $ver_bits = join '', @bitvec[0..2];
    my $ver = oct("0b".$ver_bits);
    my $type_bits = join '', @bitvec[3..5];
    my $type = oct("0b".$type_bits);
    say "Version: $ver, Type: $type" if $g_verbose;

    # Add to version sum (used for part 1)
    $g_version_sum += $ver;

    # Index of the next bit to read
    my $index = 6;

    if ($type == 4) {
        # Literal
        my $number_bits;
        while (1) {
            my @set = @bitvec[$index..$index+4];
            $index += 5;

            # Add the next 3 bits from the number to the bit string
            $number_bits .= join "", @set[1..4];

            # If this set started with a 0, we're done
            last if $set[0] == 0;
        }
        my $literal = oct("0b".$number_bits);
        say "Literal: $number_bits:$literal" if $g_verbose;
    } else {
        # Operator
        my $len_type_id = $bitvec[6];
        if ($len_type_id == 0) {
            # Next 15 bits are total length in bits of sub-packets in this packet
            my $len_bits = join '', @bitvec[7..21];
            my $bit_length = oct("0b".$len_bits);
            say "ID:0, Next $bit_length bits are sub-packets" if $g_verbose;

            # Update the index by the 15 length bits, plus len_type_id bit
            $index += 16;

            # Create the next packet bitvector, parse the packets contained within
            # Increment the index by the length of all the packets we parsed
            my @next_bitvec = @bitvec[$index..scalar @bitvec-1];
            $index += parse_packet(\@next_bitvec, $bit_length);
        } else {
            # Next 11 bits are number of sub-packets in this packet
            my $len_bits = join '', @bitvec[7..17];
            my $packet_length = oct("0b".$len_bits);
            say "ID:1, Contains $packet_length sub-packets" if $g_verbose;

            # Update the index by the 11 length bits, plus len_type_id bit
            $index += 12;

            # Create the next packet bitvector, parse the packets contained within
            # Increment the index by the length of all the packets we parsed
            my @next_bitvec = @bitvec[$index..scalar @bitvec-1];
            $index += parse_packet(\@next_bitvec, undef, $packet_length);
        }
    }

    # Create a new bitvector with the remaining bits
    my @next_bitvec = @bitvec[$index..scalar @bitvec-1];

    # If there are more packets to parse adjacent to this one, continue parsing them
    if (defined $bit_len and $index < ($bit_len - 1)) {
        $index += parse_packet(\@next_bitvec, $bit_len - $index);
    } elsif (defined $packet_len and $packet_len > 1) {
        $index += parse_packet(\@next_bitvec, undef, $packet_len - 1);
    }

    # Return the number of bits parsed (needed for keeping track of index)
    return $index;
}
