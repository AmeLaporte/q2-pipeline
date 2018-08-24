#!/bin/bash
#Author: Amelie Laporte


qiime tools export ../../Analysis/taxonomy-denovo.qza --output-dir ../../Analysis/Abundance/
sed -i 's/Feature ID\tTaxon\tConfidence/#OTUID\ttaxonomy\tconfidence/' ../../Analysis/Abundance/taxonomy.tsv


for i in `seq 1 7`; do
qiime taxa collapse \
  --i-table ../../Analysis/rep-table-denovo \
  --i-taxonomy ../../Analysis/taxonomy-denovo.qza \
  --p-level $i \
  --o-collapsed-table ../../Analysis/Abundance/TMP/table-$i.qza

qiime tools export table-$i.qza --output-dir ../../Analysis/Abundance/TMP/level-$i
cp ../../Analysis/Abundance/TMP/level-$i/feature-table.biom ../../Analysis/Abundance/TMP/table-$i.biom

biom add-metadata \
-i ../../Analysis/Abundance/TMP/table-$i.biom \
-o ../../Analysis/Abundance/TMP/table-$i-with-taxonomy.biom \
--observation-metadata-fp ../../Analysis/Abundance/taxonomy.tsv \
--sc-separated taxonomy

biom convert \
-i ../../Analysis/Abundance/TMP/table-$i-with-taxonomy.biom \
-o ../../Analysis/Abundance/table-$i-tax.tsv --to-tsv \
--header-key taxonomy

sed -i '1d' ../../Analysis/Abundance/table-$i-tax.tsv

# cleaning tsv file for data generated with SILVA!
sed -i '1d' table-$i-tax.tsv
sed -i 's/D_0__//'  table-$i-tax.tsv
sed -i 's/D_1__//'  table-$i-tax.tsv
sed -i 's/D_2__//'  table-$i-tax.tsv
sed -i 's/D_3__//'  table-$i-tax.tsv
sed -i 's/D_4__//'  table-$i-tax.tsv
sed -i 's/D_5__//'  table-$i-tax.tsv
sed -i 's/D_6__//'  table-$i-tax.tsv
sed -i 's/;__;__;__;__;__//'  table-$i-tax.tsv
sed -i 's/;__;__;__;__//'  table-$i-tax.tsv
sed -i 's/;__;__;__//'  table-$i-tax.tsv
sed -i 's/;__;__//'  table-$i-tax.tsv
sed -i 's/;__//'  table-$i-tax.tsv
sed -i 's/#OTU ID/Taxon/' table-$i-tax.tsv
done

