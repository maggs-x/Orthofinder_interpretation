append_lines() {
    local file1="$1"
    local file2="$2"
    local output="CDS_withSVdels_humanorthologs.tsv"

    # Check if both input files exist
    if [ ! -f "$file1" ] || [ ! -f "$file2" ]; then
        echo "Input file not found. Please provide valid file paths."
        return 1
    fi

    # Create a new output file
    > "$output"

    # Read each line from file1
    while IFS=$'\t' read -r gene_name; do
        # Initialize the line to append
        line_to_append="${gene_name}\t"

        # Search for matching gene names in column 2 of file2 and append entire lines to output file
        matched_lines=$(awk -v gene_name="$gene_name" -F '\t' '{ if($2 ~ gene_name "($|,|\t)") print }' "$file2")

        # If matched lines are not empty, append them; otherwise, print just the line from file1
        if [[ -n "$matched_lines" ]]; then
            echo -e "$line_to_append\t$matched_lines" >> "$output"
        else
            echo -e "$line_to_append" >> "$output"
        fi
    done < "$file1"
}

# Call the function with two input file paths
append_lines "$1" "$2"

###in this case
#./append_lines.sh CDS_withSVins.vcf_parsing_symbolsassigned Astyanax_human_orthologs_NCBI.txt

#CDS_withSVins.vcf_parsing_symbolsassigned file format: stableid_genesymbol
#Astyanax_human_orthologs_NCBI.txt file format: orthogroup AmexStableID_AmexGenesymbol HsapStableID_Hsapsymbol

#multiple entires in $2 and $3 are separated by commas
