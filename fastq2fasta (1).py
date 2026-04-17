#!/usr/bin/env python2
import sys

with open(sys.argv[1], 'r') as fq:
    for i, line in enumerate(fq):
        if i % 4 == 0:  # Header line
            print('>' + line[1:].strip())
        elif i % 4 == 1:  # Sequence line
            print(line.strip())
