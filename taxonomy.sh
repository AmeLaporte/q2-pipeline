#!/bin/bash
#This script is launched as a background task in the server so you can go home while it is working.
#Yes, this step is long.

#$ -S /bin/bash
#$ -N Q2-TAX
#$ -V
#$ -q normal.q
#$ -pe shmem 1

qiime feature-classifier classify-sklearn \
  --i-classifier ../Silva/silva128.qza \
  --i-reads ../Analysis/rep-seqs.qza \
  --o-classification ../Analysis/taxonomy.qza

  qiime taxa barplot \
  --i-table ../Analysis/rep-table.qza \
  --i-taxonomy ../Analysis/taxonomy.qza \
  --m-metadata-file $METADATA \
  --o-visualization ../Analysis/Visualization/taxa-bar-plot.qzv
