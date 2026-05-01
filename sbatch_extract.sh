#!/bin/bash
#SBATCH --job-name=extract_viral_reads
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=32G
#SBATCH --ntasks=1
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=your_email@example.com

#######################################
# USER INPUTS
#######################################
SAMPLE=sample_name

SCRIPT_DIR=/path/to/scripts
BLAST_DIR=/path/to/blast1_output
UNMAPPED_DIR=/path/to/unmapped_fasta
OUTDIR=/path/to/output/viral_hits

mkdir -p "$OUTDIR"

#######################################
# EXTRACT VIRAL READS (MATE 1)
#######################################
python3 "$SCRIPT_DIR"/extract_vread.py \
  "${BLAST_DIR}/res_first_blast_1.txt" \
  "${UNMAPPED_DIR}/${SAMPLE}_unmapped_1.fas" \
  > "${OUTDIR}/viral_hit_fasta_1.fas"

#######################################
# EXTRACT VIRAL READS (MATE 2)
#######################################
python3 "$SCRIPT_DIR"/extract_vread.py \
  "${BLAST_DIR}/res_first_blast_2.txt" \
  "${UNMAPPED_DIR}/${SAMPLE}_unmapped_2.fas" \
  > "${OUTDIR}/viral_hit_fasta_2.fas"

echo "Viral read extraction completed: $(date)"
