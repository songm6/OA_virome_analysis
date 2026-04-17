Step 1: Trim reads
low quality bases and very short reads are removed with Trimmomatic

Step 2: Align to human genome
cleaned reads are aligned with STAR against the human reference genome
reads that map to human are saved in BAM format. Reads that do not map to human are saved as unmapped FASTQ files

Step 3: Convert unmapped reads to FASTA
