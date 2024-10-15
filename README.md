#if you ran orthofinder with stable protein ids you may be interested in identifying their gene symbols. The scripts in this repository do just that. 
#It takes as input 1) the pairwise ortholog file from orthofinder (here, Astyanax_mexicanus_GCA_023375975_1_2022_07_pep__v__Homo_sapiens.GRCh38.pep.all.tsv) and 2) a user formated file with stableid;genesymbol for the two species in the ortholog file. 

#order of operations is 
#1) orthologs_assignsymbols.sh # will append stable ids in ortholog file (here Astyanax_mexicanus_GCA_023375975_1_2022_07_pep__v__Homo_sapiens.GRCh38.pep.all.tsv) with gene symbols. output will be stableid_genesymbol. 
#2) append_Hsapsymbols_cleanup.sh #will pull all symbols from the species in the third column of the tsv file (here human) and add them to a new column. 

#if you want to run it on a specific list of genes instead of the entire orthology file use append_line_fullorthology.sh
#1) orthologs_assignsymbols.sh 
#2) append_line_fullorthology.sh
#3) append_Hsapsymbols_cleanup.sh (this creates an additional field with just gene symbols for the second species, in this case human)
