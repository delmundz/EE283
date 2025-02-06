#!/bin/bash
#SBATCH --job-name=HW3ATACseqAlign    ## Name of the job.
#SBATCH -A class-ecoevo283       ## account to charge
#SBATCH -p standard        ## partition/queue name
#SBATCH --cpus-per-task=12  ## number of cores the job needs
#SBATCH --error=ATACseqAlign.%Z.err
#SBATCH --output=ATACseqAlign.%Z.out
#SBATCH --mem-per-cpu=6G    ## can go from 3-6GB/core std queue
#SBATCH --time=1-00:00:00   ## 1 day, up to 14 std queue
#SBATCH --array=1-24


module load bwa/0.7.8
module load samtools/1.15.1  

idx="/pub/delmundz/EE283/HW3/ref/dmel-all-chromosome-r6.13.fasta"
data="/pub/delmundz/EE283/HW2/rawdata/ATACseq"
bamout="/pub/delmundz/EE283/HW3/alignATACseq/aligned"

# generated prefixes.txt in ATACseq RawData directory
# ls *.fq.gz | sed -E 's/_[^_]+\.fq\.gz$//' | sort -u > prefixes.txt

prefix=`head -n $SLURM_ARRAY_TASK_ID ${data}/prefixes.txt | tail -n 1`

#Run trimmomatic
trimout="/pub/delmundz/EE283/HW3/alignATACseq/trimmed"
loc="/opt/apps/trimmomatic/0.39"
java -jar ${loc}/trimmomatic-0.39.jar PE -threads 4 \
    ${data}/${prefix}_R1.fq.gz ${data}/${prefix}_R2.fq.gz \
    ${trimout}/${prefix}_R1_paired.fq ${trimout}/${prefix}_R1_unpaired.fq \
    ${trimout}/${prefix}_R2_paired.fq ${trimout}/${prefix}_R2_unpaired.fq \
    ILLUMINACLIP:${loc}/adapters/NexteraPE-PE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

#Align with BWA
bwa mem -t $SLURM_CPUS_PER_TASK -M $idx ${trimout}/${prefix}_R1_paired.fq ${trimout}/${prefix}_R2_paired.fq \
	| samtools sort - -@ $SLURM_CPUS_PER_TASK -m 4G -o ${bamout}/${prefix}.sort.bam
