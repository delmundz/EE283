#!/bin/bash
#SBATCH -A class-ecoevo283
#SBATCH --job-name=HW7featurecounts 
#SBATCH --cpus-per-task 64
#SBATCH --mem-per-cpu=3G
#SBATCH --error=HW7deseq.%J.err
#SBATCH --output=HW7deseq.%J.out

module load subread/2.0.3

gtf="/pub/delmundz/Work_ee283/HW3/ref/dmel-all-r6.13.gtf"
dir="/pub/delmundz/Work_ee283/HW7/output"

myfile=$(cat ${dir}/shortRNAseq.names.txt | tr "\n" " ")
featureCounts -p -T 8 -t exon -g gene_id -Q 30 -F GTF -a $gtf -o ${dir}/fly_counts.txt $myfile
