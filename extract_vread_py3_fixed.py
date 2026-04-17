#!/usr/bin/env python3
# FIXED - handles FASTA headers with extra metadata

import sys

blast_res = sys.argv[1]
fasta = sys.argv[2]
max_Eval = 1.0E-10

# Read BLAST results
blast_f = open(blast_res, "r")
read_set = set()

for line in blast_f:
    fields = line.strip().split('\t')
    if len(fields) < 12:
        continue
        
    read_id = fields[0]
    try:
        Eval = float(fields[10])
        if Eval < max_Eval:
            read_set.add(read_id)
    except (ValueError, IndexError):
        continue

blast_f.close()

# Read FASTA and output matches
fst = open(fasta, "r")
output_count = 0
current_header = None
current_seq = []

for line in fst:
    line = line.strip()
    if line.startswith('>'):
        # Process previous sequence
        if current_header:
            # Extract just the read ID from header (remove >@ and everything after space)
            header_id = current_header[1:].split()[0]  # Remove '>@' and take first word
            if header_id in read_set:
                print(current_header)
                print(''.join(current_seq))
                output_count += 1
        
        # Start new sequence
        current_header = line
        current_seq = []
    else:
        current_seq.append(line)

# Process last sequence
if current_header:
    header_id = current_header[1:].split()[0]
    if header_id in read_set:
        print(current_header)
        print(''.join(current_seq))
        output_count += 1

fst.close()
