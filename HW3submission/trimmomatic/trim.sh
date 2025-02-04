#!/bin/bash
#SBATCH --job-name=trimDNAseq    ## Name of the job.
#SBATCH -A class-ecoevo283       ## account to charge
#SBATCH -p standard        ## partition/queue name
#SBATCH --cpus-per-task=1  ## number of cores the job needs
#SBATCH --error=trim_%Z.err
#SBATCH --output=trim_%Z.out
#SBATCH --mem-per-cpu=3G    ## can go from 3-6GB/core std queue
#SBATCH --time=1-00:00:00   ## 1 day, up to 14 std queue


java -jar /opt/apps/trimmomatic/0.39/trimmomatic-0.39.jar PE \
-threads 4 \
ADL06_1_1.fq.gz ADL06_1_2.fq.gz \
out_ADL06_1_1.fq.gz out_ADL06_1_2.fq.gz \
 ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:2:True LEADING:3 TRAILING:3 MINLEN:36

