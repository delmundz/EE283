#!/bin/bash
#SBATCH --job-name=extractA4A5    ## Name of the job.
#SBATCH -A class-ecoevo283 ## account to charge
#SBATCH -p standard        ## partition/queue name
#SBATCH --cpus-per-task=16  ## number of cores the job needs
#SBATCH --mem=16GB

#problem 1 prompt
##Use samtools and the gDNA seq bam files to extract a 120kb region of the genome (chrX from 1,880,000 to 2,000,000) from strain “A4”.
#Make sure you only include reads that have mapq > 30.  Also do this for a control strain (A5).

#load modules
module load samtools/1.15.1
module load bedtools2/2.30.0 #module avail before using this

#setr spades path
# Set paths
SPADES_ENV="/data/homezvol3/delmundz/.conda/envs/spades_env"
SPADES_PYTHON="$SPADES_ENV/bin/python"
SPADES_SCRIPT="$SPADES_ENV/bin/spades.py"

# dir for indexed bam files
A4="/pub/delmundz/EE283/HW3/alignDNAseq/aligned/ADL06_1.sort.bam"
A5="/pub/delmundz/EE283/HW3/alignDNAseq/aligned/ADL09_1.sort.bam"
dir="/pub/delmundz/EE283/HW4"

#had an error earlier that AL06_1.sort.bam index can't be retrieved
samtools index $A4
samtools index $A5

# set genomic interval
interval="X:1880000-2000000"

# extract the read IDs from a specified interval and save them to text files
samtools view $A4 $interval | cut -f1 > ${dir}/A4/A4.IDs.txt
samtools view $A5 $interval | cut -f1 > ${dir}/A5/A5.IDs.txt

# extract reads mapping to chromosome X then format as fasta
samtools view $A4 | grep -f ${dir}/A4/A4.IDs.txt |\
    awk '{if($3 == "X"){printf(">%s\n%s\n",$1,$10)}}' >${dir}/A4/A4_X.fa #check if 3rd field of input line (in SAM line, this is the chromosome). If condition is trueprints a FASTA format header line starting with '>" followed by read ID; the next line prints the sequence of the read 
samtools view $A5 | grep -f ${dir}/A5/A5.IDs.txt |\
    awk '{if($3 == "X"){printf(">%s\n%s\n",$1,$10)}}' >${dir}/A5/A5_X.fa

# extract reads that map to elsewhere besides chromX then format as fasta
samtools view $A4 | grep -f ${dir}/A4/A4.IDs.txt |\
    awk '{if($3 != "X"){printf(">%s\n%s\n",$1,$10)}}' >${dir}/A4/A4_other.fa
samtools view $A5 | grep -f ${dir}/A5/A5.IDs.txt |\
    awk '{if($3 != "X"){printf(">%s\n%s\n",$1,$10)}}' >${dir}/A5/A5_other.fa

#conda activate before running script
# need to specify full path to spades install
$SPADES_PYTHON $SPADES_SCRIPT -o ${dir}/A4/assembly -s ${dir}/A4/A4_other.fa --isolate > ${dir}/A4/assembly/A4.messages.txt
$SPADES_PYTHON $SPADES_SCRIPT -o ${dir}/A5/assembly -s ${dir}/A5/A5_other.fa --isolate > ${dir}/A5/assembly/A5.messages.txt

