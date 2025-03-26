If you ran orthofinder with stable protein ids, you may be interested in identifying their gene symbols. The scripts in this repository do just that. 

It takes as input 1) the pairwise ortholog file from orthofinder (here, Astyanax_mexicanus_GCA_023375975_1_2022_07_pep__v__Homo_sapiens.GRCh38.pep.all.tsv) and 2) a user formatted file with stableid;genesymbol for the two species in the ortholog file. Expectations of the user formatted file is that the stable id will have one underscore (e.g. stable ids are often formatted XP_049325020.1 NP_002463.2). Stable ids and gene symbols should be separated by a semi colon. For example:
NP_066008.2;PCDHB16


Script descriptions:
1) orthologs_assignsymbols.sh : This script will append stable ids in the pairwise orthology file from Orthofinder with gene symbols. The output will retain original formatting but stable ids will be appended with gene symbol (stableid_genesymbol). 
2) appendsymbols_cleanup.sh : If you're interested in pulling just the gene symbols for the second species in the comparison use this script. It will create a new column in the file with just the 'second species' symbols. For example, if you ran orthologs_assignsymbols on the OrthoFinder ortholog file containing asytanax and human orthologs, appendsymbols_cleanup.sh will extract all of the human symbols in the third column (stableID_symbol), and add just hte symbols to a new fourth column. 
3) append_line_fullorthology.sh : If you have a pre-set list of gene symbols that you'd like to know the orthologs for use this script. Use the table created by orthologs_assignsymbols.sh as input + your list of candidate genes.  
4) orthologs_assignsymbols_multiple.sh : use this script to assign symbols to multiple pairwise orthology files

Note: input file names must be changed to work on your files. 
