If you ran orthofinder with stable protein ids, you may be interested in identifying their gene symbols. The scripts in this repository do just that. 

It takes as input 1) the pairwise ortholog file from orthofinder (here, Astyanax_mexicanus_GCA_023375975_1_2022_07_pep__v__Homo_sapiens.GRCh38.pep.all.tsv) and 2) a user formatted file with stableid;genesymbol for the two species in the ortholog file. 

Script descriptions:
1) orthologs_assignsymbols.sh : This script will append stable ids in the pairwise orthology file from Orthofinder with gene symbols. The output will retain original formatting but stable ids will be appended with gene symbol (stableid_genesymbol). 
2) append_Hsapsymbols_cleanup.sh : If you're interested in pulling just the gene symbols for the second species in the comparison (in this case, human) use this script. It will create a new column in the file with just the 'human' symbols. 
3) append_line_fullorthology.sh : If you have a list of genes that you'd like to know the orthologs for use this script. It will append the output from the above two scripts to the corresponding genes in your list. 

