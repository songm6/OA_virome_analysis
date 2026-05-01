#!/bin/bash
#SBATCH --job-name=split_fasta
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
BASE_DIR=/path/to/project
INPUT_DIR=${BASE_DIR}/viral_align
OUTDIR=${BASE_DIR}/viral_align

CHUNK_SIZE=50000   # number of reads per chunk

mkdir -p ${OUTDIR}/chunks_mate1
mkdir -p ${OUTDIR}/chunks_mate2

#######################################
# SPLIT MATE 1
#######################################
awk -v chunk=${CHUNK_SIZE} '
BEGIN {file=1; count=0}
/^>/ {
    if (count >= chunk) {
        file++;
        count=0;
    }
}
{
    printf "%s\n", $0 >> sprintf("'"${OUTDIR}"'/chunks_mate1/viral_hit_fasta_1.part_%03d.fas", file)
}
(/^>/){count++}
' ${INPUT_DIR}/viral_hit_fasta_1.fas

#######################################
# SPLIT MATE 2
#######################################
awk -v chunk=${CHUNK_SIZE} '
BEGIN {file=1; count=0}
/^>/ {
    if (count >= chunk) {
        file++;
        count=0;
    }
}
{
    printf "%s\n", $0 >> sprintf("'"${OUTDIR}"'/chunks_mate2/viral_hit_fasta_2.part_%03d.fas", file)
}
(/^>/){count++}
' ${INPUT_DIR}/viral_hit_fasta_2.fas

echo "Splitting complete: $(date)"
