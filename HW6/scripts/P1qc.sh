#!/bin/bash
#SBATCH -A CLASS-ECOEVO283
#SBATCH --job-name=HW6qcatac    # Job name 
#SBATCH --cpus-per-task 32
#SBATCH --array=1-6 
#SBATCH --mem-per-cpu=3G
#SBATCH --error=HW6qcatac_%J.err
#SBATCH --output=HW6qcatac_%J.out

module load java/1.8.0
module load samtools/1.15.1
module load picard-tools/2.27.1

samples="/pub/delmundz/Work_ee283/HW3/alignATACseq/aligned/prefixes.txt"
atacbam="/pub/delmundz/Work_ee283/HW3/alignATACseq/aligned"
bamout="/pub/delmundz/Work_ee283/HW6/processedbam"

prefix=`head -n $SLURM_ARRAY_TASK_ID ${samples} | tail -n 1`

# need indexed file to view chr X in the next step
samtools index -c ${atacbam}/${prefix}.sort.bam

samtools view -q 30 -b ${atacbam}/${prefix}.sort.bam X | \
	samtools sort -O BAM -o ${bamout}/${prefix}.chrX.sort.bam #optional? already sorted

java -jar /opt/apps/picard-tools/2.27.1/picard.jar MarkDuplicates \
	I=${bamout}/${prefix}.chrX.sort.bam \
	O=${bamout}/${prefix}.chrX.dd.bam \
	M=${bamout}/${prefix}.chrX.dd.metrics \
	REMOVE_DUPLICATES=true

samtools index ${bamout}/${prefix}.chrX.dd.bam

rm ${bamout}/${prefix}.chrX.sort.bam

