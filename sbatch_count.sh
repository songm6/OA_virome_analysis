#!/bin/bash
#SBATCH --job-name=virome_counting
#SBATCH --mem=20G
#SBATCH --time=2:00:00
#SBATCH --output=%x.%j.out
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=your_email@example.com

#######################################
# USER INPUTS
#######################################
BASE_DIR=/path/to/project
SCRIPT_DIR=${BASE_DIR}/scripts

COUNT_SCRIPT=${SCRIPT_DIR}/count_reads_mapped_on_virus_rm_multi_mapped.py
BLAST_RESULTS=${BASE_DIR}/blast_results
COUNT_OUTPUT=${BASE_DIR}/counts

SAMPLES=(sample1 sample2 sample3)  # replace with your sample IDs

mkdir -p "$COUNT_OUTPUT"

#######################################
# COUNT PER SAMPLE
#######################################
echo "=== Viral Read Counting ==="
date

for SAMPLE in "${SAMPLES[@]}"; do
    echo "--- Counting $SAMPLE ---"

    BLAST1="${BLAST_RESULTS}/res_second_blast_${SAMPLE}_1.txt"
    BLAST2="${BLAST_RESULTS}/res_second_blast_${SAMPLE}_2.txt"

    if [[ -f "$BLAST1" && -f "$BLAST2" ]]; then
        echo "  Processing BLAST results..."

        python3 "$COUNT_SCRIPT" \
            "$BLAST1" \
            "$BLAST2" \
            1e-10 \
            "$SAMPLE" \
            > "${COUNT_OUTPUT}/count_${SAMPLE}.txt"

        echo "  ✓ Saved: ${COUNT_OUTPUT}/count_${SAMPLE}.txt"
    else
        echo "  ✗ Missing BLAST results for $SAMPLE"
    fi
done

#######################################
# COMBINE RESULTS
#######################################
echo "=== Combining Counts ==="

head -n 1 ${COUNT_OUTPUT}/count_*.txt > ${COUNT_OUTPUT}/combined_counts.txt
grep -h -v "^target" ${COUNT_OUTPUT}/count_*.txt >> ${COUNT_OUTPUT}/combined_counts.txt

echo "Final combined file: ${COUNT_OUTPUT}/combined_counts.txt"
echo "=== Done ==="
date
