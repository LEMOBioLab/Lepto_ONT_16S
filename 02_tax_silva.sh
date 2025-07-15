#!/bin/bash

# --------------------------------------------------------------
# Prepare SILVA reference-to-taxonomy table for mapping results
#
# This script extracts the SILVA sequence identifiers and their
# corresponding taxonomy from the SILVA 138.2 SSU FASTA header.
#
#Author: LEMOBioLab
#Version: 1.0
# --------------------------------------------------------------

# === Step 1: Download SILVA taxonomy table (Optional) ===
 wget https://www.arb-silva.de/fileadmin/silva_databases/release_138_1/Exports/taxonomy/tax_slv_ssu_138.1.txt.gz
 gunzip tax_slv_ssu_138.1.txt.gz

# extract from taxonomy file
 awk 'BEGIN {FS=OFS="\t"} {print $1, $3}' tax_slv_ssu_138.1.txt > silva_id_to_tax.tsv

# === Step 2: Extract ID and taxonomy from FASTA headers ===
# Input: SILVA_138.2_SSURef_tax_silva.fasta
# Output: silva_ref_to_tax.tsv

echo "Generating taxonomy table from FASTA headers..."

awk '/^>/ {print $1 "\t" $2 "\t" $3}' SILVA_138.2_SSURef_tax_silva.fasta | sed 's/>//g' > silva_ref_to_tax.tsv

echo "Output saved to: silva_ref_to_tax.tsv"
