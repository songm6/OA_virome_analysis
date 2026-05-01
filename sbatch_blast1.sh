#!/bin/bash
#SBATCH --job-name=blast_first_pass
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --ntasks=1
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=your_email@example.com

#######################################
# USER INPUTS
#######################################
SAMPLE=sample_name

DB=/path/to/blast_db/virus_genome_for_first_blast.db
UNMAPPED_DIR=/path/to/unmapped_fasta
OUTDIR=/path/to/output/blast1

mkdir -p "$OUTDIR"

#######################################
# LOAD MODULE
#######################################
module purge
module load blast+/2.17.0

#######################################
# RUN BLAST (MATE 1)
#######################################
blastn \
  -db "$DB" \
  -query "${UNMAPPED_DIR}/${SAMPLE}_unmapped_1.fas" \
  -out "${OUTDIR}/res_first_blast_1.txt" \
  -word_size 11 \
  -outfmt 6 \
  -num_threads $SLURM_CPUS_PER_TASK

#######################################
# RUN BLAST (MATE 2)
#######################################
blastn \
  -db "$DB" \
  -query "${UNMAPPED_DIR}/${SAMPLE}_unmapped_2.fas" \
  -out "${OUTDIR}/res_first_blast_2.txt" \
  -word_size 11 \
  -outfmt 6 \
  -num_threads $SLURM_CPUS_PER_TASK

echo "BLAST1 completed: $(date)"
