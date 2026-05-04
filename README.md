All required pipeline scripts are available in the scripts branch of this repository.

This pipeline analyzes sequencing data to detect viral sequences present in human samples. It first removes human-derived reads and then screens the remaining reads against viral databases to identify potential viruses. Finally, it refines these matches and counts how many reads support each detected virus.

Step 1: Trim reads

low quality bases and very short reads are removed with Trimmomatic

Step 2: Align to human genome

cleaned reads are aligned with STAR against the human reference genome
reads that map to human are saved in BAM format. Reads that do not map to human are saved as unmapped FASTQ files

Step 3: Convert unmapped reads to FASTA

unmapped reads are converted from fastq to fasta format. this makes them ready for BLAST

Step 4: First BLAST search

unmapped reads are searched against a BLAST database that only contains virus genomes. 
this is a first filter to find possible viral reads

Step 5: Extract viral reads

only reads that hit the virus database are kept/ these reads are written into new FASTA files

Step 6: Split viral reads

viral FASTA files are split into smaller chunks. this helps the next BLAST step run in parallel on clusters

Step 7: Second BLAST search

each chunk is searched against a larger database that contains human, prokaryotes, and viruses

Step 8: Count viral reads

all BLAST chunk results are combine. counting script summarizes the final viral read counts for the sample.
