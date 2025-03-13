#!/bin/bash
#SBATCH --job-name=RNAseqAlign    ## Name of the job.
#SBATCH -A class-ecoevo283       ## account to charge
#SBATCH -p standard        ## partition/queue name
#SBATCH --cpus-per-task=12  ## number of cores the job needs
#SBATCH --error=RNAseqAlign.%Z.err
#SBATCH --output=RNAseqAlign.%Z.out
#SBATCH --mem-per-cpu=16G    ## can go from 3-6GB/core std queue
#SBATCH --time=1-00:00:00   ## 1 day, up to 14 std queue
#SBATCH --array=1-6

module load samtools/1.15.1  
module load hisat2/2.2.1

idx = "/pub/delmundz/EE283/HW3/ref/dm6_trans"
data = "/pub/delmundz/EE283/HW2/rawdata/RNAseq"
bamout = "/pub/delmundz/EE283/HW3/alignRNAseq/aligned"

#Create prefix txt file
#ls 2* | sed -E 's/_R[12]$//' | sort -u > prefixes.txt

prefix=`head -n $SLURM_ARRAY_TASK_ID ${data}/prefixes.txt | tail -n 1`


hisat2 -p 2 -x ${idx} -1 ${data}/${prefix}_R1.fq.gz -2 ${data}/${prefix}_R2.fq.gz \
	| samtools sort - -@ $SLURM_CPUS_PER_TASK -m 4G -o ${bamout}/${prefix}.sort.bam

samtools index ${bamout}/${prefix}.sort.bam 
