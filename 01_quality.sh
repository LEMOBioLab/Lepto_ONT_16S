#!/bin/bash
----------------------------------------
Pipeline for adapter trimming, quality filtering, and read length selection using:
- Porechop (adapter trimming)
- fastp (quality and length filtering)
- NanoPlot (read quality and length visualization)
Author: LEMOBioLab
Version: 1.0
----------------------------------------
=== USER CONFIGURATION ===
RAW_DIR="./data/raw" # Directory with raw .fastq files
ADAPTER_CLEAN_DIR="./data/clean_adapters" # Output directory after adapter trimming
FINAL_CLEAN_DIR="./data/clean_data" # Output directory after fastp filtering
NANOPLOT_DIR="./results/NanoPlot_outputQ15" # Output directory for NanoPlot reports

THREADS=$(nproc) # Number of threads to use

=== CREATE OUTPUT DIRECTORIES ===
mkdir -p "$ADAPTER_CLEAN_DIR" "$FINAL_CLEAN_DIR" "$NANOPLOT_DIR"

=== MAIN LOOP ===
for file in "$RAW_DIR"/*.fastq; do
base=$(basename "$file" .fastq)

echo "Processing sample: $base"

# Step 1: Adapter trimming with Porechop
trimmed_file="${ADAPTER_CLEAN_DIR}/${base}.cl.fastq"
echo "Trimming adapters with Porechop..."
porechop -i "$file" --check_reads 1000 -v 1 -o "$trimmed_file"

# Step 2: Quality and length filtering with fastp
filtered_file="${FINAL_CLEAN_DIR}/${base}.cl.fastq"
echo "Filtering with fastp (Q ≥ 15, length 1400–1600)..."
fastp -i "$trimmed_file" -A -G -q 15 -l 1400 --length_limit 1600 -w $THREADS -o "$filtered_file"

# Step 3: Read quality stats with NanoPlot
echo "Generating NanoPlot report..."
NanoPlot --fastq "$filtered_file" --outdir "${NANOPLOT_DIR}/${base}" --threads $THREADS

echo "Finished processing: $base"
echo
done
