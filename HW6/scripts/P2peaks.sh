#!/bin/sh
#SBATCH -A CLASS-ECOEVO283
#SBATCH --job-name=HW6peaks 
#SBATCH --cpus-per-task 32
#SBATCH --mem-per-cpu=3G
#SBATCH --error=peaks_%A_%a.err
#SBATCH --output=callsnpsdu_%A_%a.out

module load samtools/1.15.1
module load bedtools2/2.30.0
module load ucsc-tools/v429
module load miniconda3/24.9.2
source /opt/apps/miniconda3/24.9.2/etc/profile.d/conda.sh
conda activate macs2

ref="/pub/delmundz/Work_ee283/HW3/ref"
dir="/pub/delmundz/Work_ee283/HW6"
bam="/pub/delmundz/Work_ee283/HW6/processedbam"
out="/pub/delmundz/Work_ee283/HW3/peaks"
samples="/pub/delmundz/Work_ee283/HW3/alignATACseq/aligned/prefixes.txt"

samtools merge -f -o ${out}/A4ED_merged.bam \
	${bam}/P004_A4_ED_2.chrX.dd.bam \
	${bam}/P005_A4_ED_3.chrX.dd.bam \
	${bam}/P006_A4_ED_4.chrX.dd.bam

bedtools bamtobed -i ${out}/A4ED_merged.bam | \
	awk -F $'\t' 'BEGIN {OFS = FS}{ if ($6 == "+") {$2 = $2 + 4} else if ($6 == "-") {$3 = $3 - 5} print $0}' \
	> ${out}/A4ED_merged.tn5.bed

macs2 callpeak -t ${out}/A4ED_merged.tn5.bed \
	--outdir ${out} \
	-n A4ED \
	-f BED -g mm -q 0.01 --nomodel \
	--shift -75 --extsize 150 \
	--broad --keep-dup all --bdg


LC_COLLATE=C sort -k1,1 -k2,2n ${out}/A4ED_treat_pileup.bdg > ${out}/A4ED_treat_pileup.sorted.bdg

awk 'NR==FNR {if ($1 == "X") chr_size[$1]=$2; next} $1 == "X" && $3 <= chr_size[$1]' ${ref}/dmel-all-chromosome-r6.13.chrom.sizes ${out}/A4ED_treat_pileup.sorted.bdg > ${out}/A4ED_treat_pileup.safeends.bdg 

bedGraphToBigWig ${out}/A4ED_treat_pileup_with_chr.bdg ${ref}/dm6_with_chr.chrom.sizes.ucsc ${out}/A4ED_broad_peaks_with_chr.bw



