#!/bin/bash
#This script is launched as a background task in the server so you can go home while it is working.
#Yes, this step is long.

#$ -S /bin/bash
#$ -N Q2-TAX
#$ -V
#$ -q normal.q
#$ -pe shmem 1

METADATA="../../Data/metadata.tsv"
#To choose the sampling depth you must look at the "table-nonchimeric.qzv" from the "Visualization" folder on view.qiime2.org.
SAMPLING_DEPTH=18000
#The criteria correspond to the column title of the metadata you want to test (ex: Site or Season).
CRITERIA="Site"

echo "Activating QIIME2"
source activate qiime2-2018.2

echo "Generating the tree for phylogenetic diversity analysis"

qiime alignment mafft \
--i-sequences ../../Analysis/rep-seqs-denovo.qza \
--o-alignment ../../Analysis/Tree/aligned-rep-seqs-denovo.qza

qiime alignment mask \
--i-alignment ../../Analysis/Tree/aligned-rep-seqs-denovo.qza \
--o-masked-alignment ../../Analysis/Tree/masked-aligned-rep-seqs-denovo.qza

qiime phylogeny fasttree \
--i-alignment ../../Analysis/Tree/masked-aligned-rep-seqs-denovo.qza \
--o-tree ../../Analysis/Tree/unrooted-tree-denovo.qza

qiime phylogeny midpoint-root \
--i-tree ../../Analysis/Tree/unrooted-tree-denovo.qza \
--o-rooted-tree ../../Analysis/Tree/rooted-tree-denovo.qza

echo "ALPHA DIVERSITY"

echo "Observed OTUs"
qiime diversity alpha \
  --i-table ../../Analysis/rep-table-denovo.qza \
  --p-metric observed_otus \
  --o-alpha-diversity ../../Analysis/Diversity/Alpha_diversity/observed_otus_vector.qza

echo "Chao1"
qiime diversity alpha \
  --i-table ../../Analysis/rep-table-denovo.qza \
  --p-metric chao1 \
  --o-alpha-diversity ../../Analysis/Diversity/Alpha_diversity/chao1_vector.qza

echo "Shannon index"
qiime diversity alpha \
  --i-table ../../Analysis/rep-table-denovo.qza \
  --p-metric shannon \
  --o-alpha-diversity ../../Analysis/Diversity/Alpha_diversity/shannon_vector.qza

echo "FaithPD"
qiime diversity alpha-phylogenetic \
  --i-table ../../Analysis/rep-table-denovo.qza \
  --i-phylogeny ../../Analysis/Tree/rooted-tree-denovo.qza \
  --p-metric faith_pd \
  --o-alpha-diversity ../../Analysis/Diversity/Alpha_diversity/faith_pd_vector.qza

echo "Calculating the main core metrics to see the metrics significance (boxplots+statistics)"

qiime diversity core-metrics-phylogenetic \
--i-phylogeny ../../Analysis/Tree/rooted-tree-denovo.qza \
--i-table ../../Analysis/rep-table-denovo.qza \
--p-sampling-depth $sampling_depth \
--m-metadata-file $METADATA \
--output-dir ../../Analysis/core-metrics-results-denovo

echo "Calculating Faith PD significance"

qiime diversity alpha-group-significance \
  --i-alpha-diversity ../../Analysis/Diversity/core-metrics-results-denovo/faith_pd_vector.qza \
  --m-metadata-file $METADATA \
  --o-visualization ../../Analysis/Diversity/core-metrics-results-denovo/faith-pd-group-significance.qzv 

echo "Calculating Shannon's specie richness significance"

qiime diversity alpha-group-significance \
  --i-alpha-diversity ../../Analysis/Diversity/core-metrics-results-denovo/shannon_vector.qza \
  --m-metadata-file $METADATA \
  --o-visualization ../../Analysis/Diversity/core-metrics-results-denovo/shannon-group-significance.qzv

echo "Creation of the rarefaction curves"
qiime diversity alpha-rarefaction \
  --i-table ../../Analysis/rep-table-denovo.qza \
  --i-phylogeny ../../Analysis/Tree/rooted-tree-denovo.qza \
  --p-max-depth $sampling_depth \
  --m-metadata-file $METADATA \
  --o-visualization ../../Analysis/Diversity/Alpha_diversity/alpha-rarefaction.qzv

echo "Exporting the visualization plots"

qiime tools export ../../Analysis/Diversity/Alpha_diversity/observed_otus_vector.qza --output-dir ../../Analysis/Diversity/Alpha_diversity/observed_otus

qiime tools export ../../Analysis/Diversity/Alpha_diversity/chao1_vector.qza --output-dir ../../Analysis/Diversity/Alpha_diversity/chao1

qiime tools export ../../Analysis/Diversity/Alpha_diversity/shannon_vector.qza --output-dir ../../Analysis/Diversity/Alpha_diversity/shannon

qiime tools export ../../Analysis/Diversity/Alpha_diversity/faith_pd_vector.qza --output-dir ../../Analysis/Diversity/Alpha_diversity/faith_pd

qiime tools export ../../Analysis/Diversity/core-metrics-results-denovo/faith-pd-group-significance.qzv --output-dir ../../Analysis/Diversity/Alpha_diversity/faith_pd_significance

qiime tools export ../../Analysis/Diversity/core-metrics-results-denovo/shannon-group-significance.qzv --output-dir ../../Analysis/Diversity/Alpha_diversity/shannon_richness_significance

qiime tools export ../../Analysis/Diversity/alpha-rarefaction.qzv --output-dir ../../Analysis/Diversity/Alpha_diversity/alpha_rarefaction_curve

echo "Calculating the Beta diversity"

echo "Unweighted UniFrac PCoA"

qiime emperor plot \
  --i-pcoa ../../Analysis/Diversity/core-metrics-results-denovo/unweighted_unifrac_pcoa_results.qza \
  --m-metadata-file $METADATA \
  --o-visualization ../../Analysis/Diversity/core-metrics-results-denovo/unweighted-unifrac-emperor.qzv 

echo "Bray-Curtis weighted PCoA"

qiime emperor plot \
  --i-pcoa ../../Analysis/Diversity/core-metrics-results-denovo/bray_curtis_pcoa_results.qza \
  --m-metadata-file $METADATA \
--o-visualization ../../Analysis/Diversity/core-metrics-results-denovo/bray-curtis-emperor.qzv 

echo "Beta group significance"

qiime diversity beta-group-significance \
--i-distance-matrix ../../Analysis/Diversity/core-metrics-results-denovo/unweighted_unifrac_distance_matrix.qza \
--m-metadata-file $METADATA \
--m-metadata-column $CRITERIA \
--o-visualization ../../Analysis/Diversity/core-metrics-results-denovo/unweighted-unifrac-$CRITERIA-significance.qzv \
--p-pairwise

qiime diversity beta-group-significance \
 --i-distance-matrix ../../Analysis/Diversity/core-metrics-results-denovo/bray_curtis_distance_matrix.qza \
 --m-metadata-file $METADATA \
 --m-metadata-column $CRITERIA \
 --o-visualization ../../Analysis/Diversity/core-metrics-results-denovo/bray-curtis-$CRITERIA-significance.qzv \
--p-pairwise


echo "Exporting the visualization files"

# Export all figures 
qiime tools export ../../Analysis/Diversity/core-metrics-results-denovo/unweighted-unifrac-emperor.qzv --output-dir ../../Analysis/Diversity/Beta_diversity/unweighted-unifrac-pcoa

qiime tools export ../../Analysis/Diversity/core-metrics-results-denovo/bray-curtis-emperor.qzv --output-dir ../../Analysis/Diversity/Beta_diversity/bray-curtis-pcoa

qiime tools export ../../Analysis/Diversity/core-metrics-results-denovo/unweighted-unifrac-$CRITERIA-significance.qzv --output-dir ../../Analysis/Diversity/Beta_diversity/unweighted-unifrac-$CRITERIA-significance

qiime tools export ../../Analysis/Diversity/core-metrics-results-denovo/bray-curtis-$CRITERIA-significance.qzv --output-dir ../../Analysis/Diversity/Beta_diversity/bray-curtis-$CRITERIA-significance

source deactivate