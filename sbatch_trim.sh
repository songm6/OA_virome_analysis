#!/bin/bash
#SBATCH --job-name=trim
#SBATCH --output=trim.%j.out
#SBATCH --error=trim.%j.err
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --ntasks=1
#SBATCH --mail-user=minseo.song@vanderbilt.edu
#SBATCH --mail-type=BEGIN,END,FAIL

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../config.sh"

: "${RAW_R1:?Set RAW_R1 in config.sh}"
: "${RAW_R2:?Set RAW_R2 in config.sh}"

mkdir -p "${TRIMMED}"

OUT_R1="${TRIMMED}/${SAMPLE_ID}_${SAMPLE_TAG}_R1.fastq.gz"
OUT_R2="${TRIMMED}/${SAMPLE_ID}_${SAMPLE_TAG}_R2.fastq.gz"
OUT_R1_UNP="${TRIMMED}/${SAMPLE_ID}_${SAMPLE_TAG}_R1_unpaired.fastq.gz"
OUT_R2_UNP="${TRIMMED}/${SAMPLE_ID}_${SAMPLE_TAG}_R2_unpaired.fastq.gz"

module load trimmomatic

java -Xms4g -jar trimmomatic PE -phred33 \
  "${RAW_R1}" "${RAW_R2}" \
  "${OUT_R1}" "${OUT_R1_UNP}" \
  "${OUT_R2}" "${OUT_R2_UNP}" \
  MINLEN:50 SLIDINGWINDOW:4:20

echo "Trim finished at: $(date)"
