## How to run 16Snanopore based on Dr.Junya
## module load Nextflow/20.10.0
#### nextflow run -profile gb main.nf --pod5folderlist /nbt_main/share/pachyderm/amr/testpod5/test_pod5/listdir.txt --mode pod5 --method nano16SJunya --indexnanofile /nbt_main/home/alisa/sepsis16SlongreadONT/minibar_index_list_16S.txt --qscore 15 --dbtaxonomy ncbi_16S_18S

#### If you use jupyter from NBT server : please use below command :
####  nextflow run -profile gb main.nf --pod5folderlist /nbt_main/share/pachyderm/amr/testpod5/test_pod5/listdir.txt --mode pod5 --method nano16SJunya --model resources/dorado_model/dna_r9.4.1_e8_hac@v3.3 --indexnanofile /nbt_main/home/alisa/sepsis16SlongreadONT/minibar_index_list_16S.txt --qscore 15 --dbtaxonomy ncbi_16S_18S
