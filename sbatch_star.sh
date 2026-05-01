#!/bin/bash
#SBATCH --job-name=star_align
#SBATCH --output=%x.%j.out
#SBATCH --error=%x.%j.err
#SBATCH --time=48:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=128G
#SBATCH --ntasks=1
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=your_email@example.com

#######################################
# USER INPUTS
#######################################
SAMPLE=sample_name
GENOME_DIR=/path/to/star_index
GTF=/path/to/annotation.gtf

R1=/path/to/trimmed/${SAMPLE}_R1.trimmed.fastq.gz
R2=/path/to/trimmed/${SAMPLE}_R2.trimmed.fastq.gz

OUTDIR=/path/to/output/star/${SAMPLE}
mkdir -p "$OUTDIR"

#######################################
# SETUP
#######################################
set -euo pipefail
export USER_IS_ROOT=false

module --force purge
module --ignore_cache load StdEnv/2023 || true
module --ignore_cache load star/2.7.11b || module --ignore_cache load star/2.7.11a || true
module --ignore_cache load samtools/1.22.1 || module --ignore_cache load samtools || true

#######################################
# DIAGNOSTICS
#######################################
echo "Modules loaded:"
module list 2>&1 || true
echo "STAR path: $(command -v STAR || echo 'not found')"
STAR --version 2>/dev/null || true
echo "samtools path: $(command -v samtools || echo 'not found')"
samtools --version 2>/dev/null || true
echo "Start time: $(date)"

#######################################
# RUN STAR
#######################################
OUT_PREFIX="${OUTDIR}/${SAMPLE}_"

STAR \
  --genomeDir "$GENOME_DIR" \
  --readFilesCommand zcat \
  --readFilesIn "$R1" "$R2" \
  --runThreadN $SLURM_CPUS_PER_TASK \
  --outFileNamePrefix "$OUT_PREFIX" \
  --outSAMtype BAM SortedByCoordinate \
  --outFilterMultimapNmax 1 \
  --sjdbGTFfile "$GTF" \
  --outReadsUnmapped Fastx \
  --twopassMode Basic

#######################################
# POST-PROCESS
#######################################
SAM_BAM="${OUT_PREFIX}Aligned.sortedByCoord.out.bam"

if [ -s "$SAM_BAM" ]; then
    samtools flagstat "$SAM_BAM" > "${OUT_PREFIX}flagstat.txt"
    samtools index "$SAM_BAM"
    date > "${OUT_PREFIX}STAR.finished"
    echo "STAR finished successfully at: $(date)"
else
    echo "ERROR: STAR did not produce a non-empty BAM: $SAM_BAM" >&2
    ls -lh "$OUTDIR" || true
    tail -n 200 "$OUTDIR"/Log.out "$OUTDIR"/Log.progress.out "$OUTDIR"/Log.final.out 2>/dev/null || true
    exit 5
fi
