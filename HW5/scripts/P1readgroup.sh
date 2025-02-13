#!/bin/bash
#SBATCH --job-name=HW5callsnpsreadgroup    ## Name of the job.
#SBATCH -A class-ecoevo283       ## account to charge
#SBATCH -p standard        ## partition/queue name
#SBATCH --cpus-per-task=12  ## number of cores the job needs
#SBATCH --error=callsnpsreadgroup_%A_%a.err
#SBATCH --output=callsnpsreadgroup_%A_%a.out
#SBATCH --mem-per-cpu=8G    ## can go from 3-6GB/core std queue
#SBATCH --time=1-00:00:00   ## 1 day, up to 14 std queue
#SBATCH --array=1-4

module load java/1.8.0
module load picard-tools/2.27.1  

# you want to add paths to output files so they are not in your root directory
bamin="/pub/delmundz/Work_ee283/HW3/alignDNAseq/aligned"
bamout="/pub/delmundz/Work_ee283/HW5/P1"

#generated prefixes.txt in DNAseq RawData directory
# ls *.sort.bam | sed -E 's/_[^_]+\.sort\.bam$//' | sort -u > prefixes.txt
#get prefix for current task
prefix=$(sed -n "${SLURM_ARRAY_TASK_ID}p" ${bamin}/prefixes.txt)

#add read groups information (important for tracking sample, library, and sequencing run info) in BAM files
java -jar /opt/apps/picard-tools/2.27.1/picard.jar AddOrReplaceReadGroups\
        I=${bamout}/sortedbam/${prefix}.sort.bam \
        O=${bamout}/readgroupbam/${prefix}.RG.bam \
        SORT_ORDER=coordinate\
        RGPL=illumina\
        RGPU=D109LACXX\
        RGLB=Lib1\
        RGID=${prefix}\
        RGSM=${prefix}\
        VALIDATION_STRINGENCY=LENIENT
