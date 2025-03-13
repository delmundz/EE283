#!/bin/bash
#SBATCH --job-name=HW1    ## Name of the job.
#SBATCH -A CLASS-ECOEVO283     ## account to charge
#SBATCH -p standard        ## partition/queue name
#SBATCH --cpus-per-task=1  ## number of cores the job needs
#SBATCH --error=HW1.%J.err
#SBATCH --output=HW1.%J.out

wget https://wfitch.bio.uci.edu/~tdlong/problem1.tar.gz
tar -xvf problem1.tar.gz
rm problem1.tar.gz

head -n 10 problem1/p.txt | tail -n 1
head -n 10 problem1/f.txt | tail -n 1


