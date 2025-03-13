#!/bin/bash
#SBATCH --job-name=HW3testalign    ## Name of the job.
#SBATCH -A class-ecoevo283       ## account to charge
#SBATCH -p standard        ## partition/queue name
#SBATCH --cpus-per-task=1  ## number of cores the job needs
#SBATCH --error=HW3testalign_%J.err
#SBATCH --output=HW3testalign_%J.out
#SBATCH --mem-per-cpu=3G    ## can go from 3-6GB/core std queue
#SBATCH --time=1-00:00:00   ## 1 day, up to 14 std queue

module load bwa
module load samtools

SourceDir="/pub/delmundz/EE283/HW2/rawdata/DNAseq"
DestDir="/pub/delmundz/EE283/HW3/testalign"
ref="/pub/delmundz/EE283/HW3/ref/dm6.dict"
zcat ${Source}/ADL06_1_1.fq.gz | head -n 4000000 | gizp -c > ${DestDir}/test.ADL06_1_1.fq.gz #creates test file
zcat ${Source}/ADL06_1_2.fq.gz | head -n 4000000 | gzip -c > ${DestDir}/test.ADL06_1_2.fq.gz #creates test file
bwa mem -M $ref test.ADL06_1_1.fq.gz test.ADL06_1_2.fq.gz | samtools view -bS - > test.bam #runs the alignments and piped to samtools view to create a compressed bam file
samtools sort test.bam -o test.sort.bam #sors the final result for downstream steps

