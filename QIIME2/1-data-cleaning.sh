#!/bin/bash

#$ -S /bin/bash
#$ -N Q2-PIPELINE
#$ -V
#$ -q normal.q
#$ -pe shmem 1

#The path to the manifest can be modify
MANIFEST="../../Data/manifest.csv"

source activate qiime2-2018.2

echo "Importing the data"

qiime tools import \
  --input-path $MANIFEST \
  --output-path ../../Analysis/TMP/merged-all.qza \
  --type SampleData[JoinedSequencesWithQuality] \
  --source-format SingleEndFastqManifestPhred33

echo "Dereplication of the sequences"

qiime vsearch dereplicate-sequences \
 --i-sequences ../../Analysis/TMP/merged-all.qza \
 --o-dereplicated-table ../../Analysis/TMP/merged-all-table-derep \
 --o-dereplicated-sequences ../../Analysis/TMP/merged-all-seq-derep



echo "Removal of the singletons"

qiime feature-table filter-features \
 --i-table ../../Analysis/TMP/merged-all-table-derep.qza \
 --p-min-frequency 2 \
 --o-filtered-table ../../Analysis/TMP/merged-all-US-table


qiime feature-table filter-seqs \
 --i-data ../../Analysis/TMP/merged-all-seq-derep.qza \
 --i-table ../../Analysis/TMP/merged-all-US-table.qza \
 --o-filtered-data ../../Analysis/TMP/merged-all-US-seq

echo "Chimara removal by de novo method"

qiime vsearch uchime-denovo \
--i-table ../../Analysis/TMP/merged-all-US-table.qza \
--i-sequences ../../Analysis/TMP/merged-all-US-seq.qza \
--output-dir ../../Analysis/TMP/uchime-output

qiime feature-table filter-features \
  --i-table ../../Analysis/TMP/merged-all-US-table.qza \
  --m-metadata-file ../../Analysis/TMP/uchime-output/nonchimeras.qza \
  --o-filtered-table ../../Analysis/TMP/uchime-output/table-nonchimeric.qza

qiime feature-table filter-seqs \
  --i-data ../../Analysis/TMP/merged-all-US-seq.qza \
  --m-metadata-file ../../Analysis/TMP/uchime-output/nonchimeras.qza \
  --o-filtered-data ../../Analysis/TMP/uchime-output/rep-seqs-nonchimeric.qza


echo "Sampling depth "
echo "Go visualize the created file on view.qiime2.org to choose the best sampling depth for diversity analysis"

qiime feature-table summarize \
--i-table ../../Analysis/TMP/uchime-output/table-nonchimeric.qza \
--o-visualization ../../Analysis/Visualization/table-nonchimeric.qzv


source deactivate