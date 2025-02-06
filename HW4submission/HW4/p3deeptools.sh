#!/bin/bash
#SBATCH --job-name=p3deeptools    ## Name of the job.
#SBATCH -A class-ecoevo283 ## account to charge
#SBATCH -p standard        ## partition/queue name
#SBATCH --cpus-per-task=16  ## number of cores the job needs
#SBATCH --mem=16GB

# Activate conda environment
source /opt/apps/anaconda/2022.05/etc/profile.d/conda.sh
conda activate deeptools_env

# Directory for indexed bam files
A4="/pub/delmundz/EE283/HW3/alignDNAseq/aligned/ADL06_1.sort.bam"
A5="/pub/delmundz/EE283/HW3/alignDNAseq/aligned/ADL09_1.sort.bam"
dir="/pub/delmundz/EE283/HW4"

# Run bamCoverage
bamCoverage -b $A4 -o ${dir}/A4/A4.bedgraph --normalizeUsing RPKM --region X:1903000:1905000 --binSize 10 --outFileFormat bedgraph
bamCoverage -b $A5 -o ${dir}/A5/A5.bedgraph --normalizeUsing RPKM --region X:1903000:1905000 --binSize 10 --outFileFormat bedgraph

# Deactivate conda environment
conda deactivate
