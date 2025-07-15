#!/bin/bash

# --------------------------------------------------------------
# Multiple Sequence Alignment and Phylogenetic Tree Construction
# Author: LEMOBioLab
# Version: 1.0
# --------------------------------------------------------------

# === Step 1: Multiple sequence alignment with MAFFT ===
# echo "Running MAFFT alignment..."
mafft --thread $(nproc) alignment_input.fasta > aligned_sequences.fasta

# === Step 2: Phylogenetic tree construction with IQ-TREE ===
echo "Running IQ-TREE for phylogenetic inference..."
iqtree -s otus20250519outputToEditsSCQ.fas \
       -B 1000 \
       -alrt 1000 \
       -T $(nproc)

echo "Phylogenetic tree construction completed."
