#!/bin/bash
#SBATCH --job-name=HW2DNAseq    ## Name of the job.
#SBATCH -A class-ecoevo283       ## account to charge
#SBATCH -p standard        ## partition/queue name
#SBATCH --cpus-per-task=1  ## number of cores the job needs
#SBATCH --array=1-12       ## discussed more below
#SBATCH --error=HW2DNAseq%Z.err
#SBATCH --output=HW2DNAseq%Z.out
#SBATCH --mem-per-cpu=3G    ## can go from 3-6GB/core std queue
#SBATCH --time=1-00:00:00   ## 1 day, up to 14 std queue


SourceDir="/data/class/ecoevo283/public/Bioinformatics_Course/DNAseq"
DestDir="/pub/delmundz/EE283/HW2/final/DNASeq"
FILES="$SourceDir/*"
for f in $FILES
do
   ff=$(basename $f)
   echo "Processing $ff file..."
   ln -s $SourceDir/$ff $DestDir/$ff
done

