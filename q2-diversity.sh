#!/bin/bash
#This script is launched if the user wants to do the diversity analysis with qiime2.

askChoice(){
    if [ $1 != 'Y' ] && [ $1 != 'y' ] && [ $1 != 'yes' ] && [ $1 != 'oui' ];then
        echo "please write the good answer"
        read $2
        echo "This is your new answer: " $2
        echo "Is it correct? Y/N"
        read ask
        askChoice $ask $2
    else
        echo 'Great!'
    fi
}

echo "Generating the tree for phylogenetic diversity analysis"

mkdir ../Analysis/Tree

qiime alignment mafft \
--i-sequences ../Analysis/rep-seqs.qza \
--o-alignment ../Analysis/Tree/aligned-rep-seqs.qza

qiime alignment mask \
--i-alignment ../Analysis/Tree/aligned-rep-seqs.qza \
--o-masked-alignment ../Analysis/Tree/masked-aligned-rep-seqs.qza

qiime phylogeny fasttree \
--i-alignment ../Analysis/Tree/masked-aligned-rep-seqs.qza \
--o-tree ../Analysis/Tree/unrooted-tree.qza

qiime phylogeny midpoint-root \
--i-tree ../Analysis/Tree/unrooted-tree.qza \
--o-rooted-tree T../Analysis/ree/rooted-tree.qza

echo "Go check your 'table-nonchimeric.qvz' file in the QIIME2 views website in order to choose your sampling depth"
notify-send -u normal -t 5000 "Check your terminal, it needs you!"
echo "What is the sampling depth?"
read sampling_depth

echo "You choose:" $sampling_depth
echo "Is this correct? Y/N"
read correct_depth

askChoice $correct_depth $sampling_depth

qiime diversity core-metrics-phylogenetic \
--i-phylogeny ../Analysis/rooted-tree.qza \
--i-table ../Analysis/rep-table.qza \
--p-sampling-depth $sampling_depth \
--m-metadata-file $METADATA \
--output-dir ../Analysis/core-metrics-results

echo "Calculating the alpha diversity"

qiime diversity alpha-group-significance \
--i-alpha-diversity ../Analysis/core-metrics-results/faith_pd_vector.qza \
--m-metadata-file $METADATA \
--o-visualization ../Analysis/core-metrics-results/faith-pd-group-significance.qzv

qiime diversity alpha-group-significance \
--i-alpha-diversity ../Analysis/core-metrics-results/evenness_vector.qza \
--m-metadata-file $METADATA \
--o-visualization ../Analysis/core-metrics-results/evenness-group-significance.qzv

echo "Calculating the beta diversity"
echo "You need to choose the parameter you want to use for this analysis"
notify-send -u normal -t 5000 "Check your terminal, it needs you!"
echo 'head -n 1 $METADATA'
echo "What parameter did you choose?"
read metadata_param
echo "You choose:" $metadata_param ". Is it correct? Y/N"
read metadata_answer

askChoice $metadata_answer $metadata_param

qiime diversity beta-group-significance \
--i-distance-matrix ../Analysis/core-metrics-results/unweighted_unifrac_distance_matrix.qza \
--m-metadata-file $METADATA \
--m-metadata-column $metadata_param \
--o-visualization ../Analysis/core-metrics-results/unweighted-unifrac-body-site-significance.qzv \
--p-pairwise

echo "Do you want to export the generated files to use in another software? Y/N"
notify-send -u normal -t 5000 "Check your terminal, it needs you!"
read export_diversity

if [[ "$export_diversity" != 'N' ]] && [[ "$export_diversity" != 'n' ]] && [[ "$export_diversity" != 'no' ]] && [[ "$export_diversity" != 'non' ]];then
    mkdir ../Analysis/extracted_diversity
    for file in ../Analysis/core-metrics-results/*.qza;do
        qiime tools export $file \
        --output-dir ../Analysis/extracted_diversity
    done
fi