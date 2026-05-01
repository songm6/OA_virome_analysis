#!/bin/bash
#SBATCH --job-name=fastq_to_fasta
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err
#SBATCH --time=4:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=16G
#SBATCH --ntasks=1
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=your_email@example.com

#######################################
# USER INPUTS
#######################################
SAMPLE=sample_name

UNMAPPED_DIR=/path/to/star_output
OUT_DIR=/path/to/output/fasta
SCRIPT_DIR=/path/to/scripts

mkdir -p "$OUT_DIR"

#######################################
# CONVERT FASTQ → FASTA
#######################################
python3 "$SCRIPT_DIR"/fastq2fasta.py \
  "${UNMAPPED_DIR}/${SAMPLE}_Unmapped.out.mate1" \
  > "${OUT_DIR}/${SAMPLE}_unmapped_1.fas"

python3 "$SCRIPT_DIR"/fastq2fasta.py \
  "${UNMAPPED_DIR}/${SAMPLE}_Unmapped.out.mate2" \
  > "${OUT_DIR}/${SAMPLE}_unmapped_2.fas"

#######################################
# DONE
#######################################
echo "Conversion complete: $(date)"
