#!/bin/bash

# Get the input and output file paths from command-line arguments
input_file="$1"
output_file="$2"

# Check if input file is provided and exists
if [ -z "$input_file" ] || [ ! -f "$input_file" ]; then
    echo "Please provide a valid input file."
    exit 1
fi

# Create or clear the output file
> "$output_file"

# Read the input file line by line
while IFS=$'\t' read -r -a columns; do
    # Extract entries from the 4th column and split by commas
    entries=$(echo "${columns[3]}" | tr ',' '\n')
    
    # Extract gene symbols from each entry and store in a set to remove duplicates
    gene_symbols=()
    for entry in $entries; do
        # Extract gene symbol from the entry
        gene_symbol=$(echo "$entry" | cut -d'_' -f3)
        if [ ! -z "$gene_symbol" ]; then
            gene_symbols+=("$gene_symbol")
        fi
    done
    
    # Combine unique gene symbols separated by commas
    unique_gene_symbols=$(printf "%s\n" "${gene_symbols[@]}" | sort -u | paste -sd "," -)
    
    # Append unique gene symbols to the end of the row
    echo -e "$(IFS=$'\t'; echo "${columns[*]:0:4}")\t$unique_gene_symbols"
done < "$input_file" > "$output_file"


