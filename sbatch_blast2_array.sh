#!/bin/bash
#SBATCH --job-name=blast2_array
#SBATCH --output=%x.%A_%a.out
#SBATCH --error=%x.%A_%a.err
#SBATCH --time=2-00:00:00
#SBATCH --cpus-per-task=1
#SBATCH --mem=200G
#SBATCH --ntasks=1
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --mail-user=your_email@example.com

#######################################
# USER INPUTS
#######################################
BASE_DIR=/path/to/project
OUTDIR=${BASE_DIR}/viral_align
DB=/path/to/blast_db/human_prokaryota_virus

#######################################
# LOAD MODULE
#######################################
module purge
module load blast+/2.14.1

#######################################
# DETERMINE CHUNK COUNTS
#######################################
MATE1_CHUNKS=$(ls ${OUTDIR}/chunks_mate1/viral_hit_fasta_1.part_*.fas | wc -l)
MATE2_CHUNKS=$(ls ${OUTDIR}/chunks_mate2/viral_hit_fasta_2.part_*.fas | wc -l)

#######################################
# SELECT CHUNK
#######################################
if [ "$SLURM_ARRAY_TASK_ID" -le "$MATE1_CHUNKS" ]; then
    CHUNK=$(printf "%03d" "$SLURM_ARRAY_TASK_ID")
    QUERY=${OUTDIR}/chunks_mate1/viral_hit_fasta_1.part_${CHUNK}.fas
    OUT=${OUTDIR}/chunks_mate1/res_second_blast_1_part_${CHUNK}.txt
else
    CHUNK_IDX=$(( SLURM_ARRAY_TASK_ID - MATE1_CHUNKS ))
    CHUNK=$(printf "%03d" "$CHUNK_IDX")
    QUERY=${OUTDIR}/chunks_mate2/viral_hit_fasta_2.part_${CHUNK}.fas
    OUT=${OUTDIR}/chunks_mate2/res_second_blast_2_part_${CHUNK}.txt
fi

#######################################
# SAFETY CHECK
#######################################
if [ -f "$OUT" ] || [ -f "$OUT.gz" ]; then
    echo "Skipping existing chunk $CHUNK"
    exit 0
fi

#######################################
# RUN BLAST
#######################################
echo "Running BLAST for chunk $CHUNK"
echo "Query: $QUERY"
echo "Output: $OUT"
echo "Start: $(date)"

blastn \
  -db "$DB" \
  -query "$QUERY" \
  -out "$OUT" \
  -word_size 11 \
  -outfmt 6 \
  -num_threads $SLURM_CPUS_PER_TASK \
  -evalue 1e-10 \
  -max_target_seqs 10

echo "Finished chunk $CHUNK at $(date)"
