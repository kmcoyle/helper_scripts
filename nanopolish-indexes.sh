#!/bin/bash

nanopolish="/projects/rmorin/projects/gambl-repos/gambl-kcoyle/results/gambl/nanopolish-1.0/00-inputs/nanopolish/nanopolish"

while read library patient fastq_id; do
[ "$library" == "Library" ] && continue ;
root_dir="/projects/rmorin/data/MCL_promethion" ;
fast5_dir=$patient"_fast5" ; 
init_dir="/projects/analysis/analysis32/$library/$fastq_id" ;
fastq_file="/projects/sbs_primary1/promethion1/data/$library/$fastq_id/concat_fastq/"$fastq_id"_pass_concat.fastq.gz" ;
fastq_file_ln=$root_dir/$fastq_id"_pass_concat.fastq.gz";
mkdir $fast5_dir ;
cd $fast5_dir && ln -s $init_dir/fast5/*/*.fast5 . ; #symlink all fast5 files in one directory
cd $root_dir ;
ln -s $fastq_file $fastq_file_ln ; # no option to specify output directory means fastq must be in writeable directory so symlink to root_dir
$nanopolish index -d fast5_dir \
     -s $init_dir/sequencing_summary.txt  \
     $fastq_file_ln ;
done < head -2 MCL_library_patient.txt
