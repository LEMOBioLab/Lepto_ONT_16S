#!/bin/bash

# --------------------------------------------------------------
# Align 16S nanopore reads against SILVA database,
# extract mapped reads, assign taxonomy, and filter Leptospirae
# 
# Author: LEMOBioLab  
# Version: 1.0
# --------------------------------------------------------------

# === USER CONFIGURATION ===
INPUT_DIR="./data/clean_data"                      # Directory with cleaned fastq files
OUTPUT_DIR="./results/silva"                       # Output directory
SILVA_INDEX="SILVA_SSU.mmi"                        # Minimap2 indexed SILVA SSU database
TAXONOMY_TABLE="silva_ref_to_tax.tsv"              # Reference to taxonomy mapping table

# === CREATE DIRECTORIES ===
mkdir -p "$OUTPUT_DIR/sam_stats"
mkdir -p "$OUTPUT_DIR/fasta_files"

# === MAIN LOOP ===
for file in "$INPUT_DIR"/*.cl.fastq; do
    base=$(basename "$file" .cl.fastq)
    echo "Processing: $base"

    # Step 1: Align reads to SILVA database using minimap2
    echo "Mapping with minimap2..."
    minimap2 -ax map-ont -L "$SILVA_INDEX" "$file" > "$OUTPUT_DIR/${base}_minimap2.sam"

    # Step 2: Collect mapping stats
    echo "Collecting SAM stats..."
    samtools stats "$OUTPUT_DIR/${base}_minimap2.sam" > "$OUTPUT_DIR/sam_stats/${base}.stats"

    # Step 3: Convert SAM to sorted BAM and index
    echo "Converting and indexing BAM..."
    samtools view -Sb "$OUTPUT_DIR/${base}_minimap2.sam" | \
    samtools sort -o "$OUTPUT_DIR/${base}_minimap2_sorted.bam"
    samtools index "$OUTPUT_DIR/${base}_minimap2_sorted.bam"
    samtools quickcheck -v "$OUTPUT_DIR/${base}_minimap2_sorted.bam"

    # Step 4: Extract read alignments and convert to BED
    echo "Extracting alignment BED..."
    bedtools bamtobed -i "$OUTPUT_DIR/${base}_minimap2_sorted.bam" > "$OUTPUT_DIR/${base}_minimap2.bed"

    # Step 5: Sort files for join
    echo "Sorting BED and taxonomy table..."
    sort -k1,1 "$OUTPUT_DIR/${base}_minimap2.bed" > "$OUTPUT_DIR/${base}_minimap2_sorted.bed"
    sort -k1,1 "$TAXONOMY_TABLE" > sorted_silva_ref_to_tax.tsv

    # Step 6: Join to assign taxonomy
    echo "Joining BED with taxonomy info..."
    join -1 1 -2 1 -t $'\t' "$OUTPUT_DIR/${base}_minimap2_sorted.bed" sorted_silva_ref_to_tax.tsv > "$OUTPUT_DIR/${base}_minimap2_tax.bed"

    # Step 7: Filter Leptospirae
    echo "Filtering Leptospirae reads..."
    grep "Leptospirae" "$OUTPUT_DIR/${base}_minimap2_tax.bed" | cut -f4 > "$OUTPUT_DIR/${base}_minimap2_leptospirae_ids.txt"

    # Step 8: Extract Leptospirae reads from FASTA
    echo "Extracting Leptospirae reads..."
    samtools fasta "$OUTPUT_DIR/${base}_minimap2.sam" > "$OUTPUT_DIR/fasta_files/${base}.fasta"
    seqtk subseq "$OUTPUT_DIR/fasta_files/${base}.fasta" "$OUTPUT_DIR/${base}_minimap2_leptospirae_ids.txt" > "$OUTPUT_DIR/${base}_minimap2_leptospirae.fasta"

    # Optional: Add read number / rename
    echo "Renaming reads..."
    python3 02_reads_add_number.py "$OUTPUT_DIR/${base}_minimap2_leptospirae.fasta" "$OUTPUT_DIR/${base}_minimap2_leptospirae_nm.fasta"

    echo "Finished: $base"
    echo
done
