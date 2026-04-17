#!/bin/bash

# ============================================================
# config.sh
# Central configuration for the virome analysis pipeline
# Source this file from run_pipeline.sh
# ============================================================

# ---------------------
# Sample information
# ---------------------
export SAMPLE_ID="12814-AL-0001"
export SAMPLE_TAG="22_S1_L005"

# ---------------------
# Main directories
# ---------------------
export BASE="/nobackup/lea_lab/songm6_virome/OA_PBMC_NovaSeqX_17Feb25"
export TRIMMED="${BASE}/trimmed"
export ALIGN_DIR="${BASE}/align_human"
export UNMAPPED_DIR="${BASE}/unmapped_fastq"
export VIRAL_ALIGN="${BASE}/viral_align"
export COUNTS_DIR="${BASE}/counts"

# ---------------------
# Reference files
# ---------------------
export GENOME_DIR="/nobackup/lea_lab/arneram/STARIndex_25Feb25"
export GTF="/data/lea_lab/shared/annotation/hg38.ncbiRefSeq.gtf"

# ---------------------
# BLAST databases
# ---------------------
export FIRST_BLAST_DB="${VIRAL_ALIGN}/virus_genome_for_first_blast.db"
export VIRUS_FA="/nobackup/lea_lab/songm6_virome/24_samp_practice_jan26/virus_genome_for_first_blast.fa"
export SECOND_BLAST_DB="/nobackup/lea_lab/songm6_virome/24_samp_practice_jan26/combined_blast_db/human_prokaryota_virus"

# ---------------------
# Helper scripts
# ---------------------
export EXTRACT_SCRIPT="/home/songm6/RNAseq-v/extract_vread_py3_fixed.py"
export COUNT_SCRIPT="/home/songm6/RNAseq-v/count_reads_mapped_on_virus_rm_multi_mapped_py3.py"

# ---------------------
# Other settings
# ---------------------
export EMAIL="minseo.song@vanderbilt.edu"
export N_CHUNKS=448
export EVALUE_THRESHOLD="1e-10"

# ---------------------
# Create output folders
# ---------------------
mkdir -p "${ALIGN_DIR}/${SAMPLE_ID}_${SAMPLE_TAG}"
mkdir -p "${TRIMMED}"
mkdir -p "${UNMAPPED_DIR}"
mkdir -p "${VIRAL_ALIGN}/chunks_mate1"
mkdir -p "${VIRAL_ALIGN}/chunks_mate2"
mkdir -p "${COUNTS_DIR}"
