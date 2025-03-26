#!/bin/bash -e
#SBATCH -p general,requeue
#SBATCH --cpus-per-task 28
#SBATCH --mem=50G
#SBATCH -t 10:00:00
#SBATCH -o assignsymbols.out
#SBATCH -e assignsymbols.err

cd /mnt/pixstor/warrenwc-lab/users/maggs/cavefish/projects/Verts_Orthofinder/NCBI_run/REDO_Mar24_2025/primary_transcripts/OrthoFinder/Results_Mar24/Orthologues/Orthologues_Astyanax_mexicanus_lt/

# Enable debugging to print each command before execution
set -x

# Dictionary to store Ensembl Stable IDs and corresponding gene symbols
declare -A ensembl_to_symbol

# Read the annotation file and populate the dictionary. The file should be formatted proteinid;genesymbol 
while IFS=';' read -r ensembl_id gene_symbol; do
    ensembl_id=$(echo "$ensembl_id" | tr -d '[:space:]')  # Trim spaces
    gene_symbol=$(echo "$gene_symbol" | tr -d '[:space:]')  # Trim spaces
    gene_symbol="${gene_symbol%(*}"  # Remove parentheses and contents
    ensembl_to_symbol["$ensembl_id"]="$gene_symbol"
done < Both_humanandamex_annotation.txt



# Function to append gene symbols to Ensembl IDs in a cell
append_gene_symbols() {
    local ids=$1
    local appended_ids=""
    IFS=',' read -r -a ensembl_array <<< "$ids"  # Corrected IFS to avoid issues with spaces
    for ((i=0; i<${#ensembl_array[@]}; i++)); do
        ensembl_id="${ensembl_array[i]}"
        ensembl_id=$(echo "$ensembl_id" | tr -d '[:space:]')  # Ensure no leading/trailing spaces
        gene_symbol="${ensembl_to_symbol[$ensembl_id]}"
        
        # Debugging statement to check if gene_symbol is being found
        echo "DEBUG: Looking up '$ensembl_id', found: '${ensembl_to_symbol[$ensembl_id]}'" >&2

        if [ -n "$gene_symbol" ]; then
            appended_ids+="${ensembl_id}_${gene_symbol}"
        else
            appended_ids+="${ensembl_id}"
        fi

        if [ $i -lt $((${#ensembl_array[@]} - 1)) ]; then
            appended_ids+=","
        fi
    done
    echo "$appended_ids"
}

# Read the input file, annotate Ensembl IDs, and write to output file
while IFS=$'\t' read -r orthogroup ensembl_ids_1 ensembl_ids_2; do
    # Print orthogroup ID
    echo -n -e "$orthogroup\t"
    # Annotate Ensembl IDs in the second column
    appended_ids_1=$(append_gene_symbols "$ensembl_ids_1")
    echo -n -e "$appended_ids_1\t"
    # Annotate Ensembl IDs in the third column
    appended_ids_2=$(append_gene_symbols "$ensembl_ids_2")
    echo "$appended_ids_2"
done < Astyanax_mexicanus_lt__v__Homosapiens_GRCh38.p14_lt.tsv > Hsap_Amex_Orthologs_symbols.tsv

