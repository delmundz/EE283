#!/bin/bash
#SBATCH --job-name=HW2ATACseq    ## Name of the job.
#SBATCH -A class-ecoevo283       ## account to charge
#SBATCH -p standard        ## partition/queue name
#SBATCH --cpus-per-task=1  ## number of cores the job needs
#SBATCH --array=1-12       ## discussed more below
#SBATCH --error=HW2ATACseq_%Z.err
#SBATCH --output=HW2ATACseq_%Z.out
#SBATCH --mem-per-cpu=3G    ## can go from 3-6GB/core std queue
#SBATCH --time=1-00:00:00   ## 1 day, up to 14 std queue

SourceDir="/data/class/ecoevo283/public/Bioinformatics_Course/ATACseq"
DestDir="/pub/delmundz/EE283/HW2/final/ATACseq"

tail -n +2 ${SourceDir}/README.ATACseq.txt | head -n -3 > ${DestDir}/ATACseq.labels.txt
File="${DestDir}/ATACseq.labels.txt"
while read p
do
   echo "${p}"
   barcode=$(echo $p | cut -f1 -d" ")
   genotype=$(echo $p | cut -f2 -d" ")
   tissue=$(echo $p | cut -f3 -d" ")
   bioRep=$(echo $p | cut -f4 -d" ")
   READ1=$(find ${SourceDir}/ -type f -iname "*_${barcode}_R1.fq.gz")
   READ2=$(find ${SourceDir}/ -type f -iname "*_${barcode}_R2.fq.gz")

   sample="${barcode}_${genotype}_${tissue}_${bioRep}"
	
   for f in $READ1 $READ2
   do
      ff=$(basename $f)
      echo "Creating symlink for $ff"
      read=$(echo "$ff" | grep -o 'R[12]')
      ln -s $f  ${DestDir}/${sample}_$read
   done
done < $File

