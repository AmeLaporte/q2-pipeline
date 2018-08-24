#!/bin/bash

#$ -S /bin/bash
#$ -N Q2-TAX
#$ -V
#$ -q normal.q
#$ -pe shmem 1

#Author: Amelie Laporte

MANIFEST="../../Data/manifest.csv"
METADATA="../../Data/metadata.tsv"

GREENGENES="../../Databases/Greengenes/gg-13-99nb.qza"
SILVA="../../Databases/Silva/silva132.qza"

REF_SILVA="../../Databases/Closed_ref/Greengenes97_closed_ref.qza"
REF_GG="../../Databases/Closed_ref/Silva97_closed_ref.qza"

#Which percentage of identity
IDENTITY=97

echo "Activating QIIME2"
source activate qiime2-2018.2


echo "OTU clustering"

echo "Clustering with Silva"
qiime vsearch cluster-features-closed-reference \
  --i-table ../../Analysis/TMP/uchime-output/table-nonchimeric.qza \
  --i-sequences ../../Analysis/TMP/uchime-output/rep-seqs-nonchimeric.qza \
  --i-reference-sequences $REF_SILVA \
  --p-perc-identity 0.$IDENTITY \
  --o-clustered-table ../../Analysis/Closed_ref/table-cr-silva-$IDENTITY.qza \
  --o-clustered-sequences ../../Analysis/Closed_ref/rep-seqs-cr-silva-$IDENTITY.qza \
  --o-unmatched-sequences ../../Analysis/Closed_ref/unmatched-cr-silva-$IDENTITY.qza


echo "Clustering with Greengenes"
qiime vsearch cluster-features-closed-reference \
  --i-table ../../Analysis/TMP/uchime-output/table-nonchimeric.qza \
  --i-sequences ../../Analysis/TMP/uchime-output/rep-seqs-nonchimeric.qza \
  --i-reference-sequences $REF_GG \
  --p-perc-identity 0.$IDENTITY \
  --o-clustered-table ../../Analysis/Closed_ref/table-cr-gg-$IDENTITY.qza \
  --o-clustered-sequences ../../Analysis/Closed_ref/rep-seqs-cr-gg-$IDENTITY.qza \
  --o-unmatched-sequences ../../Analysis/Closed_ref/unmatched-cr-gg-$IDENTITY.qza

# Silva132
echo "Taxonomic assigment with Silva"
qiime feature-classifier classify-sklearn \
  --i-classifier $SILVA \
  --i-reads ../../Analysis/Closed_ref/rep-seqs-cr-silva-$IDENTITY.qza \
  --o-classification ../../Analysis/taxonomy_Silva-closed-ref-$IDENTITY.qza

qiime taxa barplot \
  --i-table ../../Analysis/table-closed-ref-silva-$IDENTITY.qza \
  --i-taxonomy ../../Analysis/taxonomy_Silva-closed-ref-$IDENTITY.qza \
  --m-metadata-file $METADATA \
  --o-visualization ../../Analysis/Visualization/taxa-bar-plot_Silva-closed-ref-$IDENTITY.qzv

# Greengenes
echo "Taxonomic assignment with Greengenes"
qiime feature-classifier classify-sklearn \
  --i-classifier $GREENGENES \
  --i-reads ../../Analysis/Closed_ref/rep-seqs-cr-gg-$IDENTITY.qza \
  --o-classification ../../Analysis/taxonomy_GG-cr-$IDENTITY.qza

qiime taxa barplot \
  --i-table ../../Analysis/Closed_ref/table-cr-gg-$IDENTITY.qza \
  --i-taxonomy ../../Analysis/taxonomy_GG-cr-$IDENTITY.qza \
  --m-metadata-file $METADATA \
  --o-visualization ../../Analysis/Visualization/taxa-bar-plot_GG-cr-$IDENTITY.qzv

source deactivate