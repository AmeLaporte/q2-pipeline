#!/bin/bash
#Author: Amelie Laporte

PHYLUM=2
CLASS=3
ORDER=4

#Create the 15 most abundant file to generate the corresponding R bar plot
grep 'Proteobacteria' ../../Analysis/Abundance/table-$PHYLUM-tax.tsv >> ../../Analysis/Abundance/15abundant.tsv
grep 'Chloroflexi' ../../Analysis/Abundance/table-$PHYLUM-tax.tsv >> ../../Analysis/Abundance/15abundant.tsv
grep 'Bacteroidetes' ../../Analysis/Abundance/table-$PHYLUM-tax.tsv >> ../../Analysis/Abundance/15abundant.tsv
grep 'Acidobacteria' ../../Analysis/Abundance/table-$PHYLUM-tax.tsv  >> ../../Analysis/Abundance/15abundant.tsv
grep 'Actinobacteria' ../../Analysis/Abundance/table-$PHYLUM-tax.tsv  >> ../../Analysis/Abundance/15abundant.tsv
grep 'Spirochaetes' ../../Analysis/Abundance/table-$PHYLUM-tax.tsv  >> ../../Analysis/Abundance/15abundant.tsv
grep 'Nitrospirae' ../../Analysis/Abundance/table-$PHYLUM-tax.tsv  >> ../../Analysis/Abundance/15abundant.tsv
grep 'Rokubacteria' ../../Analysis/Abundance/table-$PHYLUM-tax.tsv  >> ../../Analysis/Abundance/15abundant.tsv
grep 'Calditrichaeota' ../../Analysis/Abundance/table-$PHYLUM-tax.tsv  >> ../../Analysis/Abundance/15abundant.tsv
grep 'Latescibacteria' ../../Analysis/Abundance/table-$PHYLUM-tax.tsv  >> ../../Analysis/Abundance/15abundant.tsv
grep 'Cyanobacteria' ../../Analysis/Abundance/table-$PHYLUM-tax.tsv  >> ../../Analysis/Abundance/15abundant.tsv
grep 'Dadabacteria' ../../Analysis/Abundance/table-$PHYLUM-tax.tsv  >> ../../Analysis/Abundance/15abundant.tsv
grep 'Zixibacteria' ../../Analysis/Abundance/table-$PHYLUM-tax.tsv  >> ../../Analysis/Abundance/15abundant.tsv
grep 'Planctomycetes' ../../Analysis/Abundance/table-$PHYLUM-tax.tsv  >> ../../Analysis/Abundance/15abundant.tsv
sed -i '1i\Taxon\t4H\t4S\t1H\t2H\t2S\t3H\t3S\t1S\t8A\t8B' ../../Analysis/Abundance/15abundant.tsv

#Create the files for a more in depth visualization (class and order)
grep 'Proteobacteria' ../../Analysis/Abundance/table-$CLASS-tax.tsv > ../../Analysis/Abundance/proteo.tsv
sed -i '1i\Taxon\t4H\t4S\t1H\t2H\t2S\t3H\t3S\t1S\t8A\t8B' ../../Analysis/Abundance/proteo.tsv
grep 'Chloroflexi' ../../Analysis/Abundance/table-$CLASS-tax.tsv > ../../Analysis/Abundance/chloro.tsv
sed -i '1i\Taxon\t4H\t4S\t1H\t2H\t2S\t3H\t3S\t1S\t8A\t8B' ../../Analysis/Abundance/chloro.tsv
grep 'Acidobacteria' ../../Analysis/Abundance/table-$CLASS-tax.tsv > ../../Analysis/Abundance/acido.tsv
sed -i '1i\Taxon\t4H\t4S\t1H\t2H\t2S\t3H\t3S\t1S\t8A\t8B' ../../Analysis/Abundance/acido.tsv
grep 'Bacteroidetes' ../../Analysis/Abundance/table-$CLASS-tax.tsv > ../../Analysis/Abundance/bacter.tsv
sed -i '1i\Taxon\t4H\t4S\t1H\t2H\t2S\t3H\t3S\t1S\t8A\t8B' ../../Analysis/Abundance/bacter.tsv
grep 'Planctomycetes' ../../Analysis/Abundance/table-$CLASS-tax.tsv > ../../Analysis/Abundance/plancto.tsv
sed -i '1i\Taxon\t4H\t4S\t1H\t2H\t2S\t3H\t3S\t1S\t8A\t8B' ../../Analysis/Abundance/plancto.tsv
grep 'Alphaproteobacteria' ../../Analysis/Abundance/table-$ORDER-tax.tsv > ../../Analysis/Abundance/alpha.tsv
sed -i '1i\Taxon\t4H\t4S\t1H\t2H\t2S\t3H\t3S\t1S\t8A\t8B' ../../Analysis/Abundance/alpha.tsv
grep 'Deltaproteobacteria' ../../Analysis/Abundance/table-$ORDER-tax.tsv > ../../Analysis/Abundance/delta.tsv
sed -i '1i\Taxon\t4H\t4S\t1H\t2H\t2S\t3H\t3S\t1S\t8A\t8B' ../../Analysis/Abundance/delta.tsv
grep 'Gammaproteobacteria' ../../Analysis/Abundance/table-$ORDER-tax.tsv > ../../Analysis/Abundance/gamma.tsv
sed -i '1i\Taxon\t4H\t4S\t1H\t2H\t2S\t3H\t3S\t1S\t8A\t8B' ../../Analysis/Abundance/gamma.tsv

sed -i "s/Bacteria;Proteobacteria;Gammaproteobacteria;//" ../../Analysis/Abundance/gamma.tsv
sed -i "s/Bacteria;Proteobacteria;Gammaproteobacteria/Unclassified/" ../../Analysis/Abundance/gamma.tsv 
sed -i "s/Bacteria;Proteobacteria;Deltaproteobacteria;//" ../../Analysis/Abundance/delta.tsv
sed -i "s/Bacteria;Proteobacteria;Deltaproteobacteria/Unclassified/" ../../Analysis/Abundance/delta.tsv 
sed -i "s/Bacteria;Proteobacteria;Alphaproteobacteria;//" ../../Analysis/Abundance/alpha.tsv
sed -i "s/Bacteria;Proteobacteria;Alphaproteobacteria/Unclassified/" ../../Analysis/Abundance/alpha.tsv 
sed -i "s/Bacteria;Bacteroidetes;//" ../../Analysis/Abundance/bacter.tsv
sed -i "s/Bacteria;Bacteroidetes/Unclassified/" ../../Analysis/Abundance/bacter.tsv
sed -i "s/Bacteria;Planctomycetes;//" ../../Analysis/Abundance/plancto.tsv
sed -i "s/Bacteria;Planctomycetes/Unclassified/" ../../Analysis/Abundance/plancto.tsv
sed -i "s/Bacteria;Acidobacteria;//" ../../Analysis/Abundance/acido.tsv
sed -i "s/Bacteria;Acidobacteria/Unclassified/" ../../Analysis/Abundance/acido.tsv
sed -i "s/Bacteria;Chloroflexi;//" ../../Analysis/Abundance/chloro.tsv
sed -i "s/Bacteria;Chloroflexi/Unclassified/" ../../Analysis/Abundance/chloro.tsv
sed -i "s/Bacteria;Proteobacteria;//" ../../Analysis/Abundance/proteo.tsv
sed -i "s/Bacteria;Proteobacteria/Unclassified/" ../../Analysis/Abundance/proteo.tsv