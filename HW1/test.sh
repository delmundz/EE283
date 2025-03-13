#!/bin/bash
#SBATCH --job-name=test    ## Name of the job.
#SBATCH -A CLASS-ECOEVO283       ## account to charge
#SBATCH -p standard        ## partition/queue name
#SBATCH --cpus-per-task=1  ## number of cores the job needs
#SBATCH --error=test.%J.err
#SBATCH --output=test.%J.out

echo "hello world" 
sleep 2m	# wait 2 minutes




