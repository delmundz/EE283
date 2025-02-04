#!/bin/bash
#SBATCH --job-name=HW3index    ## Name of the job.
#SBATCH -A class-ecoevo283       ## account to charge
#SBATCH -p standard        ## partition/queue name
#SBATCH --cpus-per-task=1  ## number of cores the job needs
#SBATCH --array=1-12       ## discussed more below
#SBATCH --error=HW3index_%J.err
#SBATCH --output=HW3index_%J.out
#SBATCH --mem-per-cpu=3G    ## can go from 3-6GB/core std queue
#SBATCH --time=1-00:00:00   ## 1 day, up to 14 std queue

module load bwa
module load samtools

SourceDir="/pub/delmundz/EE283/HW3/ref"
DestDir="/pub/delmundz/EE283/HW3/ref"
ref="${SourceDir}/dmel-all-chromosome-r6.13.fasta" 
bwa index $ref
samtools faidx $ref
java -jar /opt/apps/picard-tools/2.27.1/picard.jar \
CreateSequenceDictionary R=$ref O=${DestDir}/dm6.dict

