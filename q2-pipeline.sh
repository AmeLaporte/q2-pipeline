#!/bin/bash
#Author: Amelie Laporte
# "---------------------------------------------------------------------------------------"
# "This is a pipeline using QIIME2 and Tax4fun in order to analyse Illumina MiSeq data."
# "This was conceived for the Laboratory of Marine Biology from l'Université des Antilles."
# "You must have cleaned, demultiplexed and merged data for each sample to begin this pipeline."
# "---------------------------------------------------------------------------------------"

askChoice(){
    if [ $1 != 'Y' ] && [ $1 != 'y' ] && [ $1 != 'yes' ] && [ $1 != 'oui' ];then
        echo "Please write the good answer"
        read $2
        echo "This is your new answer: " $2
        echo "Is it correct? Y/N"
        read ask
        askChoice $ask $2
    else
        echo 'Great!'
    fi
}

echo "Please, enter the path to the manifest file"
read MANIFEST

echo "You entered the following path:" $MANIFEST
echo "Is this correct? Y/N"
read manifest_path

askChoice $manifest_path $MANIFEST

echo "Please, enter the path to the metadata file"
read METADATA
echo "You entered the following path:" $METADATA
echo "Is this correct? Y/N"
read metadata_path

askChoice $metadata_path $METADATA

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
    ./q2-diversity.sh
fi

#Launching the taxonomic assignment as a background task because this step takes a lot of time.

qsub taxonomy.sh

notify-send -u normal -t 5000 "Your analysis is almost done, the taxonomic assignment was launched as a background task"

echo "When the taxonomic assignment is finished: use the script 'R-tax4fun-pipeline.sh' "

#source deactivate