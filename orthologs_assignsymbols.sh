#!/bin/bash -e
#SBATCH --account=warrenlab
#SBATCH --job-name=symbol_orthos.sh
#SBATCH --time=48:00:00
#SBATCH --partition=BioCompute
#SBATCH --ntasks=1
#SBATCH --mem=10G
#SBATCH -o pipeline.out
#SBATCH -e pipeline.err

cd /storage/hpc/group/warrenlab/users/maggsx/Workingdir/cavefish/projects/Verts_Orthofinder/Ensemble_runs/assigning_symbols/Ortholog_working/Drer_Amex_Orthologues

# Dictionary to store Ensembl Stable IDs and corresponding gene symbols
declare -A ensembl_to_symbol

# Read the annotation file and populate the dictionary
while IFS=';' read -r ensembl_id gene_symbol; do
    gene_symbol="${gene_symbol%(*}"  # Removing parentheses and contents
    ensembl_to_symbol["$ensembl_id"]="$gene_symbol"
done < Bothspecies_annotation.txt #Format is StableID;GeneSymbol

# Function to append gene symbols to Ensembl IDs in a cell
append_gene_symbols() {
    local ids=$1
    local appended_ids=""
    IFS=', ' read -r -a ensembl_array <<< "$ids"
    for ((i=0; i<${#ensembl_array[@]}; i++)); do
        ensembl_id="${ensembl_array[i]}"
        gene_symbol="${ensembl_to_symbol[$ensembl_id]}"
        if [ -n "$gene_symbol" ]; then
            appended_ids+="${ensembl_id}_${gene_symbol}"  # Append gene symbol to Ensembl ID
        else
            appended_ids+="${ensembl_id}"  # Ensembl ID only if gene symbol not found
        fi
        if [ $i -lt $((${#ensembl_array[@]} - 1)) ]; then
            appended_ids+=", "  # Add comma and space unless it's the last element
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
done < Astyanax_mexicanus_GCA_023375975_1_2022_07_pep__v__Danio_rerio.GRCz11.pep.all.tsv > Drer_Amex_Orthologs_symbols.txt
