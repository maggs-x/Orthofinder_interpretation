#!/bin/bash -e
#SBATCH --account=warrenlab
#SBATCH --job-name=symbol_orthos.sh
#SBATCH --time=48:00:00
#SBATCH --partition=hpc6
#SBATCH --ntasks=32
#SBATCH --mem=50G
#SBATCH -o pipeline.out
#SBATCH -e pipeline.err

cd /storage/hpc/group/warrenlab/users/maggsx/Workingdir/cavefish/projects/Verts_Orthofinder/NCBI_run/Gene_Symbol_assignment/working

#download gff3
#then format gff3 into correct format (only 4th column, and only CDS)
for file in *.gff ; do awk -F "\t" '$3 == "CDS"' "$file" > "$file"_CDS; done
for file in ./*_CDS; do awk -F "\t" '{print $1 "\t" $4 "\t" $5 "\t" $7"___"$9}' "$file" > "$file".bed; done
for file in ./*.bed; do cut -f4 "$file" | sort -u > tmp && mv tmp "$file".txt; done
for file in ./*.txt; do sed -i 's/___/;/g' "$file"; done

#formatting gene symbol files from last column of gff
#make input files from that, formatted protein_id;gene 
# Define the input files as an array
input_files=("CDS_astyanax.bed.txt" "Daniorerio_GCF_000002035.6.gff_CDS.bed.txt" "Homosapiens_GCF_000001405.40.gff_CDS.bed.txt" "Musmusculus_GCF_000001635.27.gff_CDS.bed.txt")

# Loop through each input file
for input_file in "${input_files[@]}"; do
    # Define the output file specific for this input
    output_file="extracted_info_$(basename "$input_file" .bed.txt).csv"
    
    # Make sure the output file is empty or create it if it doesn't exist
    > "$output_file"

    # Read the input file line by line
    while IFS= read -r line; do
        # Extract the fourth column, then search for gene and protein_id within it
        description=$(echo "$line")
        gene=$(echo "$description" | grep -oP 'gene=\K[^;]+' || echo "NA")
        protein_id=$(echo "$description" | grep -oP 'ID=\K[^;]+' || echo "NA")
        
        # Write the extracted information to the output file, formatted as protein_id;gene
        echo "${protein_id};${gene}" >> "$output_file"
    done < "$input_file"

    echo "Extraction complete for $input_file. Output saved to $output_file."
done

echo "All files processed--output files protein_id-gene as .csv files"

############################################################################################
#for file in *.csv; do sort -u "$file" > tmp && mv tmp "$file"; done
for file in *.csv; do sed -i 's/^cds-//g' "$file"; done
cat *.csv > Fourspecies.txt
All_species="/storage/hpc/group/warrenlab/users/maggsx/Workingdir/cavefish/projects/Verts_Orthofinder/NCBI_run/Gene_Symbol_assignment/working/Fourspecies.txt"


#############################################################################################
########MULTIPLE FILES NOT HARD CODED#########
#create soft link for orthology files
ln -s /storage/hpc/group/warrenlab/users/maggsx/Workingdir/cavefish/projects/Verts_Orthofinder/NCBI_run/outputNCBI/Results_Mar12/Orthologues/Orthologues_Amex_NCBI_GCF_023375975/Amex_NCBI_GCF_023375975__v__Danio_rerio_GCF_000002035.6.tsv
ln -s /storage/hpc/group/warrenlab/users/maggsx/Workingdir/cavefish/projects/Verts_Orthofinder/NCBI_run/outputNCBI/Results_Mar12/Orthologues/Orthologues_Amex_NCBI_GCF_023375975/Amex_NCBI_GCF_023375975__v__Mus_musculus_GCF_000001635.27.tsv
ln -s /storage/hpc/group/warrenlab/users/maggsx/Workingdir/cavefish/projects/Verts_Orthofinder/NCBI_run/outputNCBI/Results_Mar12/Orthologues/Orthologues_Amex_NCBI_GCF_023375975/Amex_NCBI_GCF_023375975__v__Homo_sapiens_GCF_000001405.40.tsv
       
# Define the input files as an array
input_files=("Amex_NCBI_GCF_023375975__v__Mus_musculus_GCF_000001635.27.tsv" "Amex_NCBI_GCF_023375975__v__Homo_sapiens_GCF_000001405.40.tsv" "Amex_NCBI_GCF_023375975__v__Danio_rerio_GCF_000002035.6.tsv")

# Loop through each input file
for input_file in "${input_files[@]}"; do
    # Define the output file specific for this input
    output_file="output_$(basename "$input_file" .txt)_NCBI.txt"
    
    # Dictionary to store NCBI IDs and corresponding gene symbols
    declare -A ncbi_to_symbol
    
    # Read the annotation file and populate the dictionary
    while IFS=';' read -r ncbi_id gene_symbol; do
        gene_symbol="${gene_symbol%(*}"  # Removing parentheses and contents
        ncbi_to_symbol["$ncbi_id"]="$gene_symbol"
    done < "$All_species"
    
    # Function to append gene symbols to NCBI IDs in a cell
    append_gene_symbols() {
        local ids=$1
        local appended_ids=""
        IFS=', ' read -r -a ncbi_array <<< "$ids"
        for ((i=0; i<${#ncbi_array[@]}; i++)); do
            ncbi_id="${ncbi_array[i]}"
            gene_symbol="${ncbi_to_symbol[$ncbi_id]}"
            if [ "$ncbi_id" == "NA" ]; then
                appended_ids+="${gene_symbol}_${gene_symbol}"  # Append gene symbol to gene symbol if NCBI ID is "NA"
            elif [ -n "$gene_symbol" ]; then
                appended_ids+="${ncbi_id}_${gene_symbol}"  # Append gene symbol to NCBI ID
            else
                appended_ids+="${ncbi_id}"  # NCBI ID only if gene symbol not found
            fi
            if [ $i -lt $((${#ncbi_array[@]} - 1)) ]; then
                appended_ids+=", "  # Add comma and space unless it's the last element
            fi
        done
        echo "$appended_ids"
    }
    
    # Read the input file, annotate NCBI IDs, and write to output file
    while IFS=$'\t' read -r orthogroup ncbi_ids_1 ncbi_ids_2; do
        # Print orthogroup ID
        echo -n -e "$orthogroup\t"
        # Annotate NCBI IDs in the second column
        appended_ids_1=$(append_gene_symbols "$ncbi_ids_1")
        echo -n -e "$appended_ids_1\t"
        # Annotate NCBI IDs in the third column
        appended_ids_2=$(append_gene_symbols "$ncbi_ids_2")
        echo "$appended_ids_2"
    done < "$input_file" > "$output_file"
    
    echo "Processing complete for $input_file. Output saved to $output_file."
done

echo "All files processed."

