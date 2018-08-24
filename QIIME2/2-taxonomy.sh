#!/bin/bash
#This script is launched as a background task in the server so you can go home while it is working.
#Yes, this step is long.

#$ -S /bin/bash
#$ -N Q2-TAX
#$ -V
#$ -q normal.q
#$ -pe shmem 1

#the paths to the database and metadata can be changed.
DATABASE="../../Databases/Silva/silva132.qza"
METADATA="../../Data/metadata.tsv"


source activate qiime2-2018.2

echo "De novo OTU clustering"

qiime vsearch cluster-features-de-novo  \
--i-sequences ../../Analysis/TMP/uchime-output/rep-seqs-nonchimeric.qza \
--i-table ../../Analysis/TMP/uchime-output/table-nonchimeric.qza \
--p-perc-identity 0.97 \
--o-clustered-table ../../Analysis/rep-table-denovo \
--o-clustered-sequences ../../Analysis/rep-seqs-denovo

echo "Taxonomic assignment"

qiime feature-classifier classify-sklearn \
  --i-classifier $DATABASE \
  --i-reads ../../Analysis/rep-seqs-denovo.qza \
  --o-classification ../../Analysis/taxonomy-denovo.qza

  qiime taxa barplot \
  --i-table ../../Analysis/rep-table-denovo.qza \
  --i-taxonomy ../../Analysis/taxonomy-denovo.qza \
  --m-metadata-file $METADATA \
  --o-visualization ../../Analysis/Visualization/taxa-bar-plot-denovo.qzv

source deactivate
