#!/bin/bash
#SBATCH --job-name=HW3DNAseqAlign    ## Name of the job.
#SBATCH -A class-ecoevo283       ## account to charge
#SBATCH -p standard        ## partition/queue name
#SBATCH --cpus-per-task=12  ## number of cores the job needs
#SBATCH --error=DNAseqAlign.%Z.err
#SBATCH --output=DNAseqAlign.%Z.out
#SBATCH --mem-per-cpu=6G    ## can go from 3-6GB/core std queue
#SBATCH --time=1-00:00:00   ## 1 day, up to 14 std queue
#SBATCH --array=1-24


module load bwa/0.7.8
module load samtools/1.15.1  

idx="/pub/delmundz/EE283/HW3/ref/dmel-all-chromosome-r6.13.fasta"
data="/pub/delmundz/EE283/HW2/rawdata/DNAseq"
bamout="/pub/delmundz/EE283/HW3/alignDNAseq/aligned"

# generate prefixes.txt in DNAseq rawdata directory
#ls *1.fq.gz | sed -E 's/_[^_]+\.fq\.gz$//' | sort -u > prefixes.txt

prefix=`head -n $SLURM_ARRAY_TASK_ID ${data}/prefixes.txt | tail -n 1`

#Align with BWA
bwa mem -t $SLURM_CPUS_PER_TASK -M $idx ${data}/${prefix}_1.fq.gz ${data}/${prefix}_2.fq.gz \
	| samtools sort - -@ $SLURM_CPUS_PER_TASK -m 4G -o ${bamout}/${prefix}.sort.bam
