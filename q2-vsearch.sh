#!/bin/bash

# --------------------------------------------------------------
# QIIME 2 pipeline for dereplication, chimera removal, 
# closed-reference OTU picking, and taxonomy assignment
# Author: LEMOBioLab
# Version: 1.0
# --------------------------------------------------------------

# === Activate QIIME 2 environment ===
echo "Activating QIIME2 conda environment..."
source ~/miniconda3/etc/profile.d/conda.sh
conda activate qiime2

# === Directory containing FASTA files ===
dir="/home/soporte/Documents/leptospira/16s_universal/minimap/silva"

# === Loop through each filtered Leptospirae FASTA file ===
for file in "$dir"/*_minimap2_leptospirae_nm.fasta; do
  base=$(basename "$file" _minimap2_leptospirae_nm.fasta)
  echo "Processing sample: $base"

  # === Import sequences ===
   mkdir "${base}"
   qiime tools import \
     --input-path "$file" \
     --output-path "${base}/sequences.qza" \
     --type 'SampleData[Sequences]'

  # === Dereplication ===
   qiime vsearch dereplicate-sequences \
     --i-sequences "${base}/sequences.qza" \
     --o-dereplicated-table "${base}/table.qza" \
     --o-dereplicated-sequences "${base}/rep-seqs.qza"

  # === Chimera removal ===
   qiime vsearch uchime-denovo \
     --i-table "${base}/table.qza" \
     --i-sequences "${base}/rep-seqs.qza" \
     --o-chimeras "${base}/chimeras.qza" \
     --o-nonchimeras "${base}/nonchimeras.qza" \
     --o-stats "${base}/chimera-stats.qza"

  # === Filter chimeras ===
   qiime feature-table filter-features \
     --i-table "${base}/table.qza" \
     --m-metadata-file "${base}/nonchimeras.qza" \
     --o-filtered-table "${base}/table-nonchimeric.qza"

  # qiime feature-table filter-seqs \
     --i-data "${base}/rep-seqs.qza" \
     --m-metadata-file "${base}/nonchimeras.qza" \
     --o-filtered-data "${base}/rep-seqs-nonchimeric.qza"

   qiime metadata tabulate \
     --m-input-file "${base}/chimera-stats.qza" \
     --o-visualization "${base}/chimera-stats.qzv"

  # === Closed-reference clustering with SILVA ===
   qiime vsearch cluster-features-closed-reference \
     --p-threads $(nproc) \
     --i-table "${base}/table-nonchimeric.qza" \
     --i-sequences "${base}/rep-seqs-nonchimeric.qza" \
     --i-reference-sequences silva-138-99-seqs.qza \
     --p-perc-identity 0.97 \
     --p-strand both \
     --o-clustered-table "${base}/table-cr-nonchimeric-silva.qza" \
     --o-clustered-sequences "${base}/rep-seqs-cr-nonchimeric-silva.qza" \
     --o-unmatched-sequences "${base}/nomatch-seqs-cr-nonchimeric-silva.qza"

  # === Export results ===
  qiime tools export \
    --input-path "${base}/table-cr-nonchimeric-silva.qza" \
    --output-path "${base}/exported-table-nonchimeric-silva"

  qiime tools export \
    --input-path "${base}/rep-seqs-cr-nonchimeric-silva.qza" \
    --output-path "${base}/exported-rep-seqs-nonchimeric-silva"

  biom convert \
    -i "${base}/exported-table-nonchimeric-silva/feature-table.biom" \
    -o "${base}/exported-table-nonchimeric-silva/feature-table.tsv" \
    --to-tsv
    
done

echo "Pipeline completed."
