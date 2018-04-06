#!/bin/bash
#Author: Amelie Laporte
echo "---------------------------------------------------------------------------------------"
echo "This is a pipeline using QIIME2 and Tax4fun in order to analyse Illumina MiSeq data."
echo "This was conceived for the Laboratory of Marine Biology from l'Université des Antilles."
echo "You must have cleaned data to begin this pipeline."
echo "---------------------------------------------------------------------------------------"

echo "Please, enter the path to the manifest file"
read MANIFEST

echo "You entered the following path:" $MANIFEST
echo "Is this correct? Y/N"
read manifest_path

if [[ "$manifest_path" != 'Y' ]] && [[ "$manifest_path" != 'y' ]];then
    echo "Please write the good path to the manifest file"
    read MANIFEST
    echo "This is your new path: $MANIFEST"
fi

echo "Please, enter the path to the metadata file"
read METADATA
echo "You entered the following path:" $METADATA
echo "Is this correct? Y/N"
read metadata_path

if [[ "$metadata_path" != 'Y' ]] && [[ "$metadata_path" != 'y' ]];then
    echo "Please write the good path to the metadata file"
    read METADATA
    echo "This is your new path: $METADATA"
fi

echo "Entering the server node"
#qrsh -q normal.q
echo "Activating QIIME2"
#source activate qiime2-2018.2

mkdir ../Analysis

echo "Importing the data"

qiime tools import \
  --input-path $MANIFEST \
  --output-path ../Analysis/merged-all.qza \
  --type SampleData[JoinedSequencesWithQuality] \
  --source-format SingleEndFastqManifestPhred33

echo "Dereplication of the sequences"

qiime vsearch dereplicate-sequences \
 --i-sequences ../Analysis/merged-all.qza \
 --o-dereplicated-table ../Analysis/merged-all-table-derep \
 --o-dereplicated-sequences ../Analysis/merged-all-seq-derep

 mkdir ../Analysis/TMP/
 mv ../Analysis/merged-all.qza ../Analysis/TMP/

echo "Removing singletons"

qiime feature-table filter-features \
 --i-table ../Analysis/merged-all-table-derep.qza \
 --p-min-frequency 2 \
 --o-filtered-table ../Analysis/merged-all-US-table

mv ../Analysis/merged-all-table-derep.qza ../Analysis/TMP/

qiime feature-table filter-seqs \
 --i-data ../Analysis/merged-all-seq-derep.qza \
 --i-table ../Analysis/merged-all-US-table.qza \
 --o-filtered-data ../Analysis/merged-all-US-seq

mv ../Analysis/merged-all-seq-derep.qza ../Analysis/TMP/

echo "Preclustering of the sequences into OTUs"

qiime vsearch cluster-features-de-novo  \
--i-sequences ../Analysis/merged-all-US-seq.qza \
--i-table ../Analysis/merged-all-US-table.qza \
--p-perc-identity 0.97 \
--o-clustered-table ../Analysis/all-precluster-table \
--o-clustered-sequences ../Analysis/all-precluster-seq

mv ../Analysis/merged-all-US-seq.qza ../Analysis/TMP/
mv ../Analysis/merged-all-US-table.qza ../Analysis/TMP/

echo "De novo chimera removal"

qiime vsearch uchime-denovo \
--i-table ../Analysis/all-precluster-table.qza \
--i-sequences ../Analysis/all-precluster-seq.qza \
--output-dir ../Analysis/uchime-output

qiime feature-table filter-features \
  --i-table ../Analysis/all-precluster-table.qza \
  --m-metadata-file ../Analysis/uchime-output/nonchimeras.qza \
  --o-filtered-table ../Analysis/uchime-output/table-nonchimeric.qza

qiime feature-table filter-seqs \
  --i-data ../Analysis/all-precluster-seq.qza \
  --m-metadata-file ../Analysis/uchime-output/nonchimeras.qza \
  --o-filtered-data ../Analysis/uchime-output/rep-seqs-nonchimeric.qza

mv ../Analysis/all-precluster-seq.qza ../Analysis/TMP/
mv ../Analysis/all-precluster-table.qza ../Analysis/TMP/

echo "Creating the files to visualize the sampling depth"

mkdir ../Analysis/Visualization/

qiime feature-table summarize \
--i-table ../Analysis/uchime-output/table-nonchimeric.qza \
--o-visualization ../Analysis/Visualization/table-nonchimeric.qzv

qiime feature-table tabulate-seqs \
--i-data ../Analysis/uchime-output/rep-seqs-nonchimeric.qza \
--o-visualization ../Analysis/Visualization/rep-seqs-nonchimeric.qzv

echo "Final OTU clustering"

qiime vsearch cluster-features-de-novo  \
--i-sequences ../Analysis/uchime-output/rep-seqs-nonchimeric.qza \
--i-table ../Analysis/uchime-output/table-nonchimeric.qza \
--p-perc-identity 0.97 \
--o-clustered-table ../Analysis/rep-table \
--o-clustered-sequences ../Analysis/rep-seqs

echo "Do you want to use QIIME2 for your diversity analysis? Y/N"
notify-send -u normal -t 5000 "Your need to make a choice! Go check your terminal!"
read diversity_answer
if [[ "$diversity_answer" != 'N' ]] && [[ "$diversity_answer" != 'n' ]];then
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
    
    if [[ "$correct_depth" != 'Y' ]] && [[ "$correct_depth" != 'y' ]];then
        echo "please enter the correct sampling depth"
        read sampling_depth
        echo "This is your new sampling depth: $sampling_depth"
    fi

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
    if [[ "$metadata_answer" != 'Y' ]] && [[ "$metadata_answer" != 'y' ]];then
        echo "please enter the correct parameter"
        read sampling_depth
        echo "This is your new parameter: $metadata_param"
    fi

    qiime diversity beta-group-significance \
    --i-distance-matrix ../Analysis/core-metrics-results/unweighted_unifrac_distance_matrix.qza \
    --m-metadata-file $METADATA \
    --m-metadata-column $metadata_param \
    --o-visualization ../Analysis/core-metrics-results/unweighted-unifrac-body-site-significance.qzv \
    --p-pairwise

    echo "Do you want to export the generated files to use in another software? Y/N"
    notify-send -u normal -t 5000 "Check your terminal, it needs you!"
    read export_diversity
    if [[ "$export_diversity" != 'N' ]] && [[ "$export_diversity" != 'n' ]];then
        mkdir ../Analysis/extracted_diversity
        for file in ../Analysis/core-metrics-results/*.qza;do
            qiime tools export $file \
            --output-dir ../Analysis/extracted_diversity
        done
    fi
fi

echo "Taxonomic analysis"
#Needs to be done in the background

qiime feature-classifier classify-sklearn \
  --i-classifier ../Silva/silva128.qza \
  --i-reads ../Analysis/rep-seqs.qza \
  --o-classification ../Analysis/taxonomy.qza

echo "Generation of an interactive barplot"

  qiime taxa barplot \
  --i-table ../Analysis/rep-table.qza \
  --i-taxonomy ../Analysis/taxonomy.qza \
  --m-metadata-file $METADATA \
  --o-visualization ../Analysis/Visualization/taxa-bar-plot.qzv

echo "You can find it under the name 'taxa-bar-plot.qvz' and visualize it on qiime2 views"

notify-send -u normal -t 5000 "Your analysis is almost done, the taxonomic assignment is done as a background task"

echo "When the taxonomic assignment is finished: use the script 'R-tax4fun-pipeline.sh' "

#source deactivate