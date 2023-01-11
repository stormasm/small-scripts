#!/bin/perl
# Change all MPN fields in .kicad_sch files to manf# for use with KiCost

use File::Copy;
use strict;

foreach my $file (glob "*.kicad_sch" ) {
    print "Processing: $file\n";

    my $updated = "$file.updated";
    open IN, "<", $file or die "Couldn't read from $file";
    open OUT, ">", $updated or die "Couldn't write to $file";

    while (<IN>) {
        my $newline = $_ =~ s/MPN/manf#/r;
        print OUT "$newline";
    }
    copy($updated, $file) or die "Failed to copy $updated -> $file\n";
    unlink($updated) or die "Failed to remove $updated\n";
}
