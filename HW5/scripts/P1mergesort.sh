#!/bin/bash
#SBATCH --job-name=HW5callsnpsmerge    ## Name of the job.
#SBATCH -A class-ecoevo283       ## account to charge
#SBATCH -p standard        ## partition/queue name
#SBATCH --cpus-per-task=12  ## number of cores the job needs
#SBATCH --error=callsnpsmerge_%A_%a.err
#SBATCH --output=callsnpsmerge_%A_%a.out
#SBATCH --mem-per-cpu=8G    ## can go from 3-6GB/core std queue
#SBATCH --time=1-00:00:00   ## 1 day, up to 14 std queue
#SBATCH --array=1-4

module load java/1.8.0
module load gatk/4.2.6.1 
module load picard-tools/2.27.1  
module load samtools/1.15.1

# you want to add paths to output files so they are not in your root directory
ref="/pub/delmundz/Work_ee283/HW3/ref/dm6.fasta"
vcf="/pub/delmundz/Work_ee283/HW3/vcf"
bamin="/pub/delmundz/Work_ee283/HW3/alignDNAseq/aligned"
bamout="/pub/delmundz/Work_ee283/HW5/P1"

#generated prefixes.txt in DNAseq RawData directory
# ls *.sort.bam | sed -E 's/_[^_]+\.sort\.bam$//' | sort -u > prefixes.txt
#get prefix for current task
prefix=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${bamin}/prefixes.txt)

#merge bam files associated with same genotype into a single sorted BAM file
samtools merge -o ${bamout}/mergedbam/${prefix}.bam ${bamin}/${prefix}_*.sort.bam
samtools sort -@ 12 -m 6G ${bamout}/mergedbam/${prefix}.bam -o ${bamout}/sortedbam/${prefix}.sort.bam
