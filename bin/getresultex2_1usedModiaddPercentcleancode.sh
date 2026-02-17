#!/bin/bash

echo -e "FileName_withTaxalevel(S=Species;G=Genus;F=Family;O=Order;C=Class;P=Phylum)\tTaxa\tNew_est_reads\t%Reads_abundance"
while read -r i; do 
    file="${i}"
    
    if [ -f "$file" ]; then
        base=$(basename "$file" .txt)
        base=${base#passedQC_perfindex_} 
        awk -F"\t" -v fname="$base" '
            NR > 1 {
                abundance = sprintf("%.3f%%", $7 * 100)
                line = $1 "\t" $6 "\t" abundance
                if (NR == 2) {
                    # First line with filename
                    print fname "\t" line
                } else {
                    # Indented lines
                    print "\t" line
                }
            }
        ' "$file"
    else 
        echo -e "$file\tNA"
    fi
done < $1

# Print header with borders
# printf "+%-40s|%-30s|%-8s|%-10s+\n" "----------------------------------------" "------------------------------" "--------" "----------"
# printf "| %-38s | %-28s | %-6s | %-8s |\n" "File Name" "Taxa" "New_est_reads" "%Reads_abundance"
# printf "+%-40s|%-30s|%-8s|%-10s+\n" "----------------------------------------" "------------------------------" "--------" "----------"

# while read -r i; do 
#     file="${i}"
    
#     if [ -f "$file" ]; then 
#         awk -F"\t" -v fname="$file" '
#             NR > 1 {
#                 abundance = sprintf("%.3f%%", $7 * 100)
#                 if (NR == 2) {
#                     printf "| %-38s | %-28s | %-6s | %-8s |\n", fname, $1, $6, abundance
#                 } else {
#                     printf "| %-38s | %-28s | %-6s | %-8s |\n", "", $1, $6, abundance
#                 }
#             }
#         ' "$file"
#     else 
#         printf "| %-38s | %-28s | %-6s | %-8s |\n" "$file (NA)" "NA" "NA" "NA"
#     fi
# done < $1

# # Final border
# printf "+%-40s|%-30s|%-8s|%-10s+\n" "----------------------------------------" "------------------------------" "--------" "----------"
