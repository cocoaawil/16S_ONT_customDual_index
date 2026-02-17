#!/bin/bash

echo -e "FileName_withTaxalevel(S=Species;G=Genus;F=Family;O=Order;C=Class;P=Phylum)\tTaxa\tNew_est_reads\t%Reads_abundance"
while read -r i; do 
    file="${i}"
    
    if [ -f "$file" ]; then
        base=$(basename "$file" .txt)
        base=${base#passedQC_perfindex_}
        awk -F"\t" -v fname="$base" '
            NR > 1 {
                if ($7 > max || NR == 2) {
                    max = $7
                    species = $1
                    count = $6
                    abun = sprintf("%.3f%%", $7 * 100)
                }
            }
            END {
                if (max != "") {
                    printf "%s\t%s\t%s\t%s\n", fname, species, count, abun
                }
            }
        ' "$file"
    else 
        echo -e "${file}\tNA"
    fi
done < $1

#Print header with borders
# printf "+%-85s+%-32s+%-12s+%-15s+\n" "-------------------------------------------------------------------------------------" "--------------------------------" "------------" "---------------"
# printf "| %-83s | %-30s | %-10s | %-13s |\n" "FileName_withTaxalevel(S=Species;G=Genus;F=Family;O=Order;C=Class;P=Phylum)" "Taxa" "New_est_reads" "%Reads_abundance"
# printf "+%-85s+%-32s+%-12s+%-15s+\n" "-------------------------------------------------------------------------------------" "--------------------------------" "------------" "---------------"
# while read -r i; do 
#     file="${i}"
    
#     if [ -f "$file" ]; then
#         base=$(basename "$file" .txt)
#         base=${base#passedQC_perfindex_}

#         awk -F"\t" -v fname="$base" '
#             NR > 1 {
#                 if ($7 > max || NR == 2) {
#                     max = $7
#                     species = $1
#                     count = $6
#                     abun = sprintf("%.3f%%", $7 * 100)
#                 }
#             }
#             END {
#                 if (max != "") {
#                     printf "| %-83s | %-30s | %-10s | %-13s |\n", fname, species, count, abun
#                 }
#             }
#         ' "$file"
#     else 
#         printf "| %-83s | %-30s | %-10s | %-13s |\n" "$file\t(NA)"
#     fi
# done < $1

# printf "+%-85s+%-32s+%-12s+%-15s+\n" "-------------------------------------------------------------------------------------" "--------------------------------" "------------" "---------------"