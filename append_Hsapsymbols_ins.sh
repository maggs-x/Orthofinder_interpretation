#!/bin/bash

input_file="CDS_withSVins_humanorthologs.tsv"
output_file="CDS_withSVins_humanorthologs_simplified.tsv"

# Read the input file line by line
while IFS=$'\t' read -r -a columns; do
    # Extract entries from the 4rd column and split by commas
    entries=$(echo "${columns[3]}" | tr ',' '\n')
    
    # Extract gene symbols from each entry and store in a set to remove duplicates
    gene_symbols=()
    for entry in $entries; do
        # Extract gene symbol from the entry
        gene_symbol=$(echo "$entry" | cut -d'_' -f2)
        if [ ! -z "$gene_symbol" ]; then
            gene_symbols+=("$gene_symbol")
        fi
    done
    
    # Combine unique gene symbols separated by commas
    unique_gene_symbols=$(printf "%s\n" "${gene_symbols[@]}" | sort -u | paste -sd "," -)
    
    # Append unique gene symbols to the end of the row
    echo -e "$(IFS=$'\t'; echo "${columns[*]:0:4}")\t$unique_gene_symbols"
done < "$input_file" > "$output_file"

#tab delimited file as input. Last column (column 4) has stableid_genesymbol,stableid_genesymbol separate by commas. This script takes the gene symbols in the last column, puts them into a 5th column and removes duplicate symbols (e.g. multiple transcripts have same symbol). Useful for generating a list ot input in IPA or functional enrichment where you want human orthologs for a list of non-model genes
