#!/bin/bash

python ~/miniconda2/pkgs/picrust-1.1.3-py27_2/bin/normalize_by_copy_number.py -i otus.biom -o otus_corrected.biom 

biom convert -i otus_corrected.biom -o otus_corrected.txt --to-tsv --header-key taxonomy
biom convert -i otus.biom -o otus.txt --to-tsv --header-key taxonomy
python ~/miniconda2/pkgs/picrust-1.1.3-py27_2/bin/predict_metagenomes.py -i otus_corrected.biom -o ko_predictions.biom
biom convert -i ko_predictions.biom -o ko_predictions.txt --to-tsv --header-key KEGG_Description    
python ~/miniconda2/pkgs/picrust-1.1.3-py27_2/bin/categorize_by_function.py -i ko_predictions.biom -c KEGG_Pathways -l 3 -o pathway_predictions.biom
biom convert -i pathway_predictions.biom -o pathway_predictions.txt --to-tsv --header-key KEGG_Pathways

script biom_to_stamp.py = from microbiome helper 
 biom_to_stamp.py -m taxonomy otus_corrected.biom > otus_corrected.spf
 biom_to_stamp.py -m KEGG_Description ko_predictions.biom > ko_predictions.spf
 biom_to_stamp.py -m KEGG_Pathways pathway_predictions.biom > pathway_predictions.spf