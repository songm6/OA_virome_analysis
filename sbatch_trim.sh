#!/bin/bash
#SBATCH --mail-user=minseo.song@vanderbilt.edu
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --job-name=combine_trim_12814
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err
#SBATCH --time=48:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --ntasks=1

WORK=/nobackup/lea_lab/songm6_virome/songm6/12814-AL-0001_raw
TRIMMED=/nobackup/lea_lab/songm6_virome/OA_PBMC_NovaSeqX_17Feb25/trimmed
LOGDIR="$HOME/.12814_logs"
mkdir -p "$LOGDIR" "$TRIMMED"

set -euo pipefail

module purge
module load fastp/0.24.0

echo "Job started: $(date)" > "$LOGDIR"/job_12814.log

# Remove old corrupted trimmed files
rm -f "$TRIMMED"/12814-AL-0001_22_S1_L005_R{1,2}.fastq.gz || true

############################
# 1) GZIP CHECK
############################
BAD=0
for f in "$WORK"/12814-AL-0001_*_S1_L005_R?_001.fastq.gz; do
    if ! gzip -t "$f" >/dev/null 2>&1; then
        echo "BAD FILE: $f" >> "$LOGDIR"/job_12814.log
        BAD=1
    fi
done

if [ $BAD -ne 0 ]; then
    echo "Gzip check failed. Exiting." >> "$LOGDIR"/job_12814.log
    exit 1
fi

echo "Gzip check passed." >> "$LOGDIR"/job_12814.log

############################
# 2) COMBINE
############################
echo "Combining R1..." >> "$LOGDIR"/job_12814.log
zcat $(ls -1v "$WORK"/12814-AL-0001_*_S1_L005_R1_001.fastq.gz) | gzip -c > "$WORK"/12814-AL-0001_R1_combined.fastq.gz

echo "Combining R2..." >> "$LOGDIR"/job_12814.log
zcat $(ls -1v "$WORK"/12814-AL-0001_*_S1_L005_R2_001.fastq.gz) | gzip -c > "$WORK"/12814-AL-0001_R2_combined.fastq.gz

############################
# 3) TRIM WITH FASTP
############################
echo "Running fastp..." >> "$LOGDIR"/job_12814.log

fastp \
  --in1 "$WORK"/12814-AL-0001_R1_combined.fastq.gz \
  --in2 "$WORK"/12814-AL-0001_R2_combined.fastq.gz \
  --out1 "$TRIMMED"/12814-AL-0001_22_S1_L005_R1.fastq.gz \
  --out2 "$TRIMMED"/12814-AL-0001_22_S1_L005_R2.fastq.gz \
  --detect_adapter_for_pe \
  --thread $SLURM_CPUS_PER_TASK \
  --qualified_quality_phred 15 \
  --length_required 25 \
  --json "$LOGDIR"/fastp_12814.json \
  --html "$LOGDIR"/fastp_12814.html

############################
# 4) VERIFY OUTPUT
############################
gzip -t "$TRIMMED"/12814-AL-0001_22_S1_L005_R1.fastq.gz
gzip -t "$TRIMMED"/12814-AL-0001_22_S1_L005_R2.fastq.gz

echo "Job finished successfully: $(date)" >> "$LOGDIR"/job_12814.log
