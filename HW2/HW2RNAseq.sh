#!/bin/bash
#SBATCH --job-name=HW2RNAseq    ## Name of the job.
#SBATCH -A class-ecoevo283       ## account to charge
#SBATCH -p standard        ## partition/queue name
#SBATCH --cpus-per-task=1  ## number of cores the job needs
#SBATCH --array=1-12       ## discussed more below
#SBATCH --error=HW2RNAseq_%Z.err
#SBATCH --output=HW2RNAseq_%Z.out
#SBATCH --mem-per-cpu=3G    ## can go from 3-6GB/core std queue
#SBATCH --time=1-00:00:00   ## 1 day, up to 14 std queue

SourceDir="/data/class/ecoevo283/public/Bioinformatics_Course/RNAseq"
DestDir="/pub/delmundz/EE283/HW2/final/RNAseq"

tail -n +2 ${SourceDir}/RNAseq384_SampleCoding.txt > ${DestDir}/RNAseq_labels.txt 
File="${DestDir}/RNAseq_labels.txt"
while read p
do
   echo "${p}"

   number=$(echo $p | cut -f1 -d" ")
   number="Sample_$number"

   plex=$(echo $p | cut -f2 -d" " | sed 's/_[^_]*$//')
   plex="Project_$plex"

   i7index=$(echo $p | cut -f4 -d" ")

   sampleid=$(echo $p | cut -f12 -d" ")

   path="${SourceDir}/RNAseq384plex_flowcell01/${plex}/${number}"

   READ1=$(find ${path}/ -type f -iname "*_${i7index}_*_R1_*.fastq.gz")
   READ2=$(find ${path}/ -type f -iname "*_${i7index}_*_R2_*.fastq.gz")
   
   for f in $READ1 $READ2
   do
      ff=$(basename $f)
      echo "Creating symlink for $ff file"
      read=$(echo "$ff" | grep -0 'R[12]')
      echo $read
      ln -s $f  $DestDir/${sampleid}_$read
   done
done < $File
