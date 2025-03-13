#!/bin/bash
#SBATCH --job-name=RNAseqIndex    ## Name of the job.
#SBATCH -A class-ecoevo283       ## account to charge
#SBATCH -p standard        ## partition/queue name
#SBATCH --cpus-per-task=8  ## number of cores the job needs
#SBATCH --error=RNAseqIndex%Z.err
#SBATCH --output=RNAseqIndex%Z.out
#SBATCH --mem-per-cpu=16G    ## can go from 3-6GB/core std queue
#SBATCH --time=1-00:00:00   ## 1 day, up to 14 std queue


module load hisat2/2.2.1
dir="/pub/delmundz/EE283/HW3/ref"
fa="${dir}/dmel-all-chromosome-r6.13.fasta"
gtf="${dir}/dmel-al-r6.13.gtf"

python hisat2_extract_splice_sites.py $gtf > "/pub/delmundz/EE283/HW3/alignRNAseq/Index/dm6.ss"
python hisat2_extract_exons.py $gtf > "/pub/delmundz/EE283/HW3/alignRNAseq/Index/dm6.exon"
hisat2-build -p 8 --exon "/pub/delmundz/EE283/HW3/alignRNAseq/Index/dm6.exon" --ss "/pub/delmundz/EE283/HW3/alignRNAseq/Index/dm6.ss" \
 $fa "/pub/delmundz/EE283/HW3/alignRNAseq/Index/dm6_trans"
