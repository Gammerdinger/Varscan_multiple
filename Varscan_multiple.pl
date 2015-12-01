#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long;
use Pod::Usage;
use Data::Dumper;

=pod

=head1 NAME
 
 Varscan_multiple.pl
 
=head1 AUTHORS
 
 Will Gammerdinger - Program Designer, Matt Conte - Coding Advisor and Trey Belew - Coding Advisor
 
=head1 EXAMPLE
 
 perl Varscan_overlap.pl --input_file=file1 --input_file=file2 ... --input_file=fileN --output_file=output_file.bed --track_name=bed_file_track_name --chrom_size_file=chrom_size_file.txt --raw_data_file=raw_data_file.txt --minimum_consensus=[integer]\n\nThe input files are: @input_file\nThe output files is: $output_file\nThe track name of BED output is: $track_name\nThe chromosome size file is: $chrom_size_file\nThe raw data file is: $raw_data_file\nThe minimum consensus is: $minimum_consensus
 
=head1 LICENSE
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
=head1 VERSION
 
 version0.0.1 - Original Version
 
=cut

# Declare and set Getopt variable to empty

my ($output_file, $track_name, $chrom_size_file, $raw_data_file, $minimum_consensus, @input_file, $help) = ("empty", "empty", "empty", "empty", "empty");

# Take in Getopt variables

GetOptions(
"input_file=s"        => \@input_file,
"output_file=s"       => \$output_file,
"track_name=s"        => \$track_name,
"chrom_size_file=s"   => \$chrom_size_file,
"raw_data_file=s"     => \$raw_data_file,
"minimum_consensus=s" => \$minimum_consensus,
) or Usage ( "Invalid command-line option.");

# Get length of input_files array

my $input_file_length = scalar(@input_file);

# See if any of the variable from Getopt failed to get declared

if ($input_file_length == 0 || $minimum_consensus eq "empty" || $output_file eq "empty" || $track_name eq "empty" || $chrom_size_file eq "empty" || $raw_data_file eq "empty"){
    die "\nERROR: The format should be perl Varscan_overlap.pl --input_file=file1 --input_file=file2 ... --input_file=fileN --output_file=output_file.bed --track_name=bed_file_track_name --chrom_size_file=chrom_size_file.txt --raw_data_file=raw_data_file.txt --minimum_consensus=[integer]\n\nThe input files are: @input_file\nThe output files is: $output_file\nThe track name of BED output is: $track_name\nThe chromosome size file is: $chrom_size_file\nThe raw data file is: $raw_data_file\nThe minimum consensus is: $minimum_consensus\n\n"
}

# Print out the files used for the user to see

print "\nThe input files are: @input_file\nThe output files is: $output_file\nThe track name of BED output is: $track_name\nThe chromosome size file is: $chrom_size_file\nThe raw data file is: $raw_data_file\nThe minimum consensus is: $minimum_consensus\n\n";

# Open chromosome size file

open (my $CHROM_SIZE, "<$chrom_size_file");

# These will be used in the next while loop, but the are declared outside so that I can store the last LG and its size (last position)

my $linkage_group;
my $LG_size;


# Define linkage group size hash

my %LG_size_hash;

my @LG_array;

# Read in the chromosome size file for a hash

while (my $line = <$CHROM_SIZE>){
    # Split line on space into an array
    my @array_of_line = split(/ /, $line);
    # Define each element in the array
    $linkage_group = $array_of_line[0];
    $LG_size = $array_of_line[1];
    # Read the key (Linkage Group) and value (Linkage Group size) into a hash
    $LG_size_hash{$linkage_group} = $LG_size;
    push (@LG_array, $linkage_group);
}

# Close chromosome size file

close $CHROM_SIZE;

print "Stage 1: Reading in chrom_size_file complete\n\n";

# Make array to hold file handles

my @handles;

# Make the array which will hold arrays containing the lines from the Varscan files

my @array_of_lines;

# Open input files and make an array of arrays containing the first line of each Varscan file

foreach my $i (@input_file){
    # Open each Varscan file
    open (my $file, "<$i");
    push(@handles, $file);
    # Make the array of arrays to hold the first line of each Varscan file
    my $line = <$file>;
    $line = <$file>;
    if (defined($line)){
        chomp $line;
        my @tmp_array = split(/\t/, $line);
        # Make a reference for the temporary array
        my $ref = \@tmp_array;
        # Push the reference into array that holds each reference
        push (@array_of_lines, $ref);
    }
}

# Open the raw data file

open (RAW_DATA, ">$raw_data_file");

# Define the starting Linkage Group from previous while and position counters

my $LG_counter = 0;
my $LG = $LG_array[$LG_counter];
my $position = 0;

# Define initial VarScan values as neutral until they become defined by the VarScan output

do{
    print RAW_DATA "$LG\t$position";
    for (my $counter = 0; $counter < $input_file_length; $counter++){
        my $Varscan_value = "neutral";
        if ($LG eq $array_of_lines[$counter][0]){
            if ( $position >= $array_of_lines[$counter][1] && $position < $array_of_lines[$counter][2]){
                $Varscan_value = $array_of_lines[$counter][8];
            }
            if ( $position == $array_of_lines[$counter][2]){
                $Varscan_value = $array_of_lines[$counter][8];
                # Dereference the file handle
                my $temp = *{$handles[$counter]};
                my $line = <$temp>;
                if (defined($line)){
                    chomp $line;
                    my @tmp_array = split(/\t/, $line);
                    my $ref = \@tmp_array;
                    $array_of_lines[$counter] = $ref;
                }
                else{
                    my @tmp_array = ("end");
                    my $ref = \@tmp_array;
                    $array_of_lines[$counter] = $ref;
                }
            }
        }
        elsif ( $LG eq "end"){
            $Varscan_value = "neutral";
        }
        print RAW_DATA "\t$Varscan_value";
    }
    print RAW_DATA "\n";
    if ($position == $LG_size_hash{$LG}){
        $position = 0;
        $LG_counter = $LG_counter + 1;
        $LG = $LG_array[$LG_counter];
    }
    $position++;
} until ($LG eq $linkage_group and $position == $LG_size);

close RAW_DATA;

foreach my $handle (@handles){
    close $handle;
}

print "Stage 2: Creating raw_data_file complete\n\n";

open (OUTPUT_FILE, ">$output_file");
open (RAW_DATA, "<$raw_data_file");

print OUTPUT_FILE "track name=$track_name itemRgb=\"On\"\n";

my $amp_LG;
my $amp_start_position;
my $amp_end_position;
my $amp_boolean = 0;
my $neutral_LG;
my $neutral_start_position;
my $neutral_end_position;
my $neutral_boolean = 0;
my $del_LG;
my $del_start_position;
my $del_end_position;
my $del_boolean = 0;

while (my $line = <RAW_DATA>){
    chomp $line;
    my @array_of_line = split(/\t/, $line);
    my $amp_counter = 0;
    my $neutral_counter = 0;
    my $del_counter = 0;
    my $for_loop_length = $input_file_length + 2;
    for (my $element = 2; $element < $for_loop_length; $element++){
        if ($array_of_line[$element] =~ m/amp/){
            $amp_counter++;
        }
        elsif ($array_of_line[$element] =~ m/neutral/){
            $neutral_counter++;
        }
        elsif ($array_of_line[$element] =~ m/del/){
            $del_counter++;
        }
    }
    $amp_end_position = $array_of_line[1];
    $neutral_end_position = $array_of_line[1];
    $del_end_position = $array_of_line[1];
    if($amp_boolean == 1){
        if ($amp_counter < $minimum_consensus){
            print OUTPUT_FILE "$amp_LG\t$amp_start_position\t$amp_end_position\tamp\t0\t+\t$amp_start_position\t$amp_end_position\t0,255,0\n";
            undef $amp_LG;
            undef $amp_start_position;
            undef $amp_end_position;
            $amp_boolean = 0;
        }
    }
    if($amp_boolean == 1){
        if ($amp_LG ne $array_of_line[0]){
            print OUTPUT_FILE "$amp_LG\t$amp_start_position\t$amp_end_position\tamp\t0\t+\t$amp_start_position\t$amp_end_position\t0,255,0\n";
            undef $amp_LG;
            undef $amp_start_position;
            undef $amp_end_position;
            $amp_boolean = 0;
        }
    }
    if($neutral_boolean == 1){
        if ($neutral_counter < $minimum_consensus){
            print OUTPUT_FILE "$neutral_LG\t$neutral_start_position\t$neutral_end_position\tneutral\t0\t+\t$neutral_start_position\t$neutral_end_position\t0,0,255\n";
            undef $neutral_LG;
            undef $neutral_start_position;
            undef $neutral_end_position;
            $neutral_boolean = 0;
        }
    }
    if($neutral_boolean == 1){
        if ($neutral_LG ne $array_of_line[0]){
            print OUTPUT_FILE "$neutral_LG\t$neutral_start_position\t$neutral_end_position\tneutral\t0\t+\t$neutral_start_position\t$neutral_end_position\t0,0,255\n";
            undef $neutral_LG;
            undef $neutral_start_position;
            undef $neutral_end_position;
            $neutral_boolean = 0;
        }
    }
    if($del_boolean == 1){
        if ($del_counter < $minimum_consensus){
            print OUTPUT_FILE "$del_LG\t$del_start_position\t$del_end_position\tdel\t0\t+\t$del_start_position\t$del_end_position\t255,0,0\n";
            undef $del_LG;
            undef $del_start_position;
            undef $del_end_position;
            $del_boolean = 0;
        }
    }
    if($del_boolean == 1){
        if ($del_LG ne $array_of_line[0]){
            print OUTPUT_FILE "$del_LG\t$del_start_position\t$del_end_position\tdel\t0\t+\t$del_start_position\t$del_end_position\t255,0,0\n";
            undef $del_LG;
            undef $del_start_position;
            undef $del_end_position;
            $del_boolean = 0;
        }
    }
    if ($amp_boolean == 0){
        if ($amp_counter >= $minimum_consensus){
            $amp_LG = $array_of_line[0];
            $amp_start_position = $array_of_line[1];
            $amp_boolean = 1;
        }
    }
    if ($neutral_boolean == 0){
        if ($neutral_counter >= $minimum_consensus){
            $neutral_LG = $array_of_line[0];
            $neutral_start_position = $array_of_line[1];
            $neutral_boolean = 1;
        }
    }
    if ($del_boolean == 0){
        if ($del_counter >= $minimum_consensus){
            $del_LG = $array_of_line[0];
            $del_start_position = $array_of_line[1];
            $del_boolean = 1;
        }
    }
}

if(defined($amp_LG)){
    print OUTPUT_FILE "$amp_LG\t$amp_start_position\t$amp_end_position\tamp\t0\t+\t$amp_start_position\t$amp_end_position\t0,255,0\n";
}
if(defined($neutral_LG)){
    print OUTPUT_FILE "$neutral_LG\t$neutral_start_position\t$neutral_end_position\tneutral\t0\t+\t$neutral_start_position\t$neutral_end_position\t0,0,255\n";
}
if(defined($del_LG)){
    print OUTPUT_FILE "$del_LG\t$del_start_position\t$del_end_position\tdel\t0\t+\t$del_start_position\t$del_end_position\t255,0,0\n";
}

close OUTPUT_FILE;
close RAW_DATA;

print "Stage 3: Creating output_file complete\n\n";

# Usage subroutine for errors Getopt protocol

sub Usage
{
    my $command = $0;
    $command =~ s#^[^\s]/##;
    printf STDERR "@_\n" if ( @_ );
    printf STDERR "\nThe format should be perl Varscan_overlap.pl --input_file=file1 --input_file=file2 ... --input_file=fileN --output_file=output_file.bed --track_name=bed_file_track_name --chrom_size_file=chrom_size_file.txt --raw_data_file=raw_data_file.txt --minimum_consensus=[integer]\n\nThe input files are: @input_file\nThe output files is: $output_file\nThe track name of BED output is: $track_name\nThe chromosome size file is: $chrom_size_file\nThe raw data file is: $raw_data_file\nThe minimum consensus is: $minimum_consensus\n\n";
    exit;
}