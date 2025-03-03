#!/bin/sh
#SBATCH -A CLASS-ECOEVO283
#SBATCH --job-name=HW6bigwigswitch 
#SBATCH --cpus-per-task 32
#SBATCH --mem-per-cpu=3G
#SBATCH --error=test_%J.err
#SBATCH --output=test_%J.out

module load samtools/1.15.1  
module load bedtools2/2.30.0  
module load ucsc-tools/v429

ref="/pub/delmundz/Work_ee283/HW3/ref"
out="/pub/delmundz/Work_ee283/HW6/peaks"

# count the total number of reads
# and create a scaling constant for each bam
chromsizes=${ref}/dmel-all-chromosome-r6.13.chrom.sizes
Nreads=`samtools view -c -q 30 -F 4 ${out}/A4ED_sorted.bam`
Scale=`echo "1.0/($Nreads/1000000)" | bc -l`
samtools view -b ${out}/A4ED_sorted.bam | genomeCoverageBed -pc -ibam - -g ${ref}/dmel-all-chromosome-r6.13.fasta -bg -scale $Scale > ${out}/A4ED.coverage_pc
# these are the so called "kent-tools", useful for converting between various file types
bedGraphToBigWig ${out}/A4ED.coveragepc $chromsizes ${out}/A4ED_pc.bw
