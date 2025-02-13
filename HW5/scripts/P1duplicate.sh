#!/bin/bash
#SBATCH --job-name=HW5callsnpsduplicates    ## Name of the job.
#SBATCH -A class-ecoevo283       ## account to charge
#SBATCH -p standard        ## partition/queue name
#SBATCH --cpus-per-task=12  ## number of cores the job needs
#SBATCH --error=callsnpsduplicates_%A_%a.err
#SBATCH --output=callsnpsduplicates_%A_%a.out
#SBATCH --mem-per-cpu=8G    ## can go from 3-6GB/core std queue
#SBATCH --time=1-00:00:00   ## 1 day, up to 14 std queue
#SBATCH --array=1-4

module load java/1.8.0
module load picard-tools/2.27.1  
module load samtools/1.15.1

# you want to add paths to output files so they are not in your root directory
bamin="/pub/delmundz/Work_ee283/HW3/alignDNAseq/aligned"
bamout="/pub/delmundz/Work_ee283/HW5/P1"

#generated prefixes.txt in DNAseq RawData directory
# ls *.sort.bam | sed -E 's/_[^_]+\.sort\.bam$//' | sort -u > prefixes.txt
#get prefix for current task
prefix=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${bamin}/prefixes.txt)

#remove duplicates
#dedup.bam bam files with duplicates removed
#metrics file - contain statistics about duplicates
java -jar /opt/apps/picard-tools/2.27.1/picard.jar MarkDuplicates \
	--REMOVE_DUPLICATES=true \
	I=${bamout}/readgroupbam/${prefix}.RG.bam \
	O=${bamout}/dedupbam/${prefix}.dedup.bam \
	M=${bamout}/dedupbam/${prefix}_marked_dup_metrics.txt  

#creates index for the duplicated bam file
samtools index ${bamout}/dedupbam/${prefix}.dedup.bam 
