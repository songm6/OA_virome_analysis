#!/bin/bash
set -euo pipefail

# ============================================================
# run_pipeline.sh
# Submits the virome analysis jobs in order using Slurm
# ============================================================

# ---------------------
# User settings
# ---------------------
SAMPLE_ID="sample_id"
SAMPLE_TAG="sample_tag"

BASE="/path/to/virome_project"
SLURM_DIR="${BASE}/slurm"

N_CHUNKS=448
ARRAY_MAX=$((N_CHUNKS * 2))   # mate1 + mate2
ARRAY_CONCURRENCY=8

# ---------------------
# Job scripts
# ---------------------
TRIM_SCRIPT="${SLURM_DIR}/sbatch_trim.sh"
STAR_SCRIPT="${SLURM_DIR}/sbatch_star.sh"
FQ2FA_SCRIPT="${SLURM_DIR}/sbatch_fq2fa.sh"
BLAST1_SCRIPT="${SLURM_DIR}/sbatch_blast1.sh"
EXTRACT_SCRIPT="${SLURM_DIR}/sbatch_extract.sh"
SPLIT_SCRIPT="${SLURM_DIR}/sbatch_split.sh"
BLAST2_SCRIPT="${SLURM_DIR}/sbatch_blast2_array.sh"
COUNT_SCRIPT="${SLURM_DIR}/sbatch_count.sh"

# ---------------------
# Export variables so sbatch scripts can use them
# ---------------------
export SAMPLE_ID SAMPLE_TAG BASE N_CHUNKS

# ---------------------
# Submit jobs in order
# ---------------------
echo "Submitting pipeline for ${SAMPLE_ID}..."

trim_job=$(sbatch --parsable "$TRIM_SCRIPT")
echo "Trim job: ${trim_job}"

star_job=$(sbatch --parsable --dependency=afterok:${trim_job} "$STAR_SCRIPT")
echo "STAR job: ${star_job}"

fq2fa_job=$(sbatch --parsable --dependency=afterok:${star_job} "$FQ2FA_SCRIPT")
echo "FASTQ-to-FASTA job: ${fq2fa_job}"

blast1_job=$(sbatch --parsable --dependency=afterok:${fq2fa_job} "$BLAST1_SCRIPT")
echo "First BLAST job: ${blast1_job}"

extract_job=$(sbatch --parsable --dependency=afterok:${blast1_job} "$EXTRACT_SCRIPT")
echo "Extract job: ${extract_job}"

split_job=$(sbatch --parsable --dependency=afterok:${extract_job} "$SPLIT_SCRIPT")
echo "Split job: ${split_job}"

blast2_job=$(sbatch --parsable \
  --dependency=afterok:${split_job} \
  --array=1-${ARRAY_MAX}%${ARRAY_CONCURRENCY} \
  "$BLAST2_SCRIPT")
echo "Second BLAST array job: ${blast2_job}"

count_job=$(sbatch --parsable --dependency=afterok:${blast2_job} "$COUNT_SCRIPT")
echo "Count job: ${count_job}"

echo "Pipeline submitted successfully."
