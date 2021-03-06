#!/usr/bin/perl
use LWP::Simple;
#$acc_list = 'NC_002677';
#$acc_list = 'NC_000962';
#$acc_list = 'NC_002945';
#$acc_list = 'NC_022663';
#$acc_list = 'NC_015758';
#$acc_list = 'NC_015848';
#$acc_list = 'NC_008611';
#$acc_list = 'NC_021200';
$acc_list = "$ARGV[0]";
@acc_array = split(/,/, $acc_list);
#append [accn] field to each accession
for ($i=0; $i < @acc_array; $i++) {
   $acc_array[$i] .= "[accn]";
}

#join the accessions with OR
$query = join('+OR+',@acc_array);
print "$query";

#assemble the esearch URL
$base = 'http://eutils.ncbi.nlm.nih.gov/entrez/eutils/';
$url = $base . "esearch.fcgi?db=nucleotide&term=$query&usehistory=y";

#post the esearch URL
$output = get($url);

#parse WebEnv, QueryKey and Count (# records retrieved)
$web = $1 if ($output =~ /<WebEnv>(\S+)<\/WebEnv>/);
$key = $1 if ($output =~ /<QueryKey>(\d+)<\/QueryKey>/);
$count = $1 if ($output =~ /<Count>(\d+)<\/Count>/);


#open output file for writing
#open(OUT, ">mycobacterium.africanum.gm041182.fna") || die "Can't open file!\n";
#open(OUT, ">mycobacterium.bovis.af212297.fna") || die "Can't open file!\n";
#open(OUT, ">mycobacterium.tuberculosis.h37rv.fna") || die "Can't open file!\n";
#open(OUT, ">mycobacterium.canettii.cipt.140010059.fna") || die "Can't open file!\n";
#open(OUT, ">mycobacterium.ulcerans.agy99.fna") || die "Can't open file!\n";
#open(OUT, ">mycobacterium.avium.subsp.paratuberculosis.map4.fna") || die "Can't open file!\n";
open(OUT, ">$acc_list.fna") || die "Can't open file!\n";

#retrieve data in batches of 500
$retmax = 4;
for ($retstart = 0; $retstart < $count; $retstart += $retmax) {
        $efetch_url = $base ."efetch.fcgi?db=nucleotide&WebEnv=$web";
        $efetch_url .= "&query_key=$key&retstart=$retstart";
        $efetch_url .= "&retmax=$retmax&rettype=fasta_cds_aa&retmode=text";
        $efetch_out = get($efetch_url);
        print OUT "$efetch_out\n";
} #rettype=fasta_cds_aa returns protein coding sequences
close OUT;
