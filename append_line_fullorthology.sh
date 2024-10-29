append_lines() {
    local file1="$1"
    local file2="$2"
    local output="$3"  # Get the output file from the third argument

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

# Call the function with two input file paths and one output file path
append_lines "$1" "$2" "$3"



###in this case
#./append_lines.sh CDS_withSVins.vcf Astyanax_human_orthologs_NCBI.txt output

#CDS_withSVins.vcf file format: gene symbols for genes with SV insertions in their CDS
#Astyanax_human_orthologs_NCBI.txt file format: orthogroup AmexStableID_AmexGenesymbol HsapStableID_Hsapsymbol 
    #This is the output from orthologs_assignsymbols.sh (which uses orthofinder input)

#run cleanup to create a last column with just orthologous symbols
