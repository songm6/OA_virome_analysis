#!/bin/bash
#SBATCH --job-name=trim
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err
#SBATCH --time=48:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=64G
#SBATCH --ntasks=1
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=your_email@example.com

#######################################
# USER INPUTS
#######################################
WORK=/path/to/raw_fastq
TRIMMED=/path/to/trimmed_fastq
LOGDIR="$HOME/logs_trim"
SAMPLE=sample_name

mkdir -p "$LOGDIR" "$TRIMMED"

set -euo pipefail

module purge
module load fastp/0.24.0

echo "Job started: $(date)" > "$LOGDIR"/job.log

#######################################
# 1) GZIP CHECK
#######################################
BAD=0
for f in "$WORK"/${SAMPLE}_*_R?_*.fastq.gz; do
    if ! gzip -t "$f" >/dev/null 2>&1; then
        echo "BAD FILE: $f" >> "$LOGDIR"/job.log
        BAD=1
    fi
done

if [ $BAD -ne 0 ]; then
    echo "Gzip check failed. Exiting." >> "$LOGDIR"/job.log
    exit 1
fi

echo "Gzip check passed." >> "$LOGDIR"/job.log

#######################################
# 2) COMBINE READS
#######################################
echo "Combining R1..." >> "$LOGDIR"/job.log
zcat $(ls -1v "$WORK"/${SAMPLE}_*_R1_*.fastq.gz) | gzip -c > "$WORK"/${SAMPLE}_R1_combined.fastq.gz

echo "Combining R2..." >> "$LOGDIR"/job.log
zcat $(ls -1v "$WORK"/${SAMPLE}_*_R2_*.fastq.gz) | gzip -c > "$WORK"/${SAMPLE}_R2_combined.fastq.gz

#######################################
# 3) TRIM WITH FASTP
#######################################
echo "Running fastp..." >> "$LOGDIR"/job.log

fastp \
  --in1 "$WORK"/${SAMPLE}_R1_combined.fastq.gz \
  --in2 "$WORK"/${SAMPLE}_R2_combined.fastq.gz \
  --out1 "$TRIMMED"/${SAMPLE}_R1.trimmed.fastq.gz \
  --out2 "$TRIMMED"/${SAMPLE}_R2.trimmed.fastq.gz \
  --detect_adapter_for_pe \
  --thread $SLURM_CPUS_PER_TASK \
  --qualified_quality_phred 15 \
  --length_required 25 \
  --json "$LOGDIR"/fastp.json \
  --html "$LOGDIR"/fastp.html

#######################################
# 4) VERIFY OUTPUT
#######################################
gzip -t "$TRIMMED"/${SAMPLE}_R1.trimmed.fastq.gz
gzip -t "$TRIMMED"/${SAMPLE}_R2.trimmed.fastq.gz

echo "Job finished successfully: $(date)" >> "$LOGDIR"/job.log
