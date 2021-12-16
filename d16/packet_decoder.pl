#!/usr/bin/perl

use v5.10;
use strict;
use warnings;

# Advent of Code Day 16:
# - Packet Decoder (https://adventofcode.com/2021/day/16)
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

    my ($packets) = parse_input($filename);

    foreach my $packet (@$packets) {
        decode_packet($packet);
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

    say "$bits";

    # make a bitvector
    my @bitvec = split //, $bits;

    # Extract version and type
    my $ver_bits = join '', @bitvec[0..2];
    my $ver = oct("0b".$ver_bits);
    my $type_bits = join '', @bitvec[3..5];
    my $type = oct("0b".$type_bits);
    say "Version: $ver, Type: $type";

    if ($type == 4) {
        # Literal
    } else {
        # Operator
        my $len_type_id = $bitvec[6];
        if ($len_type_id == 0) {
            # Next 15 bits are total length in bits of sub-packets in this packet
            my $len_bits = join '', @bitvec[7..21];
            my $bit_length = oct("0b".$len_bits);
            say "ID:0, Next $bit_length bits are sub-packets";
        } else {
            # Next 11 bits are number of sub-packets in this packet
            my $len_bits = join '', @bitvec[7..17];
            my $packet_length = oct("0b".$len_bits);
            say "ID:1, Contains $packet_length sub-packets";
        }
    }

}
