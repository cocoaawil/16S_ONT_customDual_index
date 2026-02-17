## How to run 16Snanopore for custom Dual-index based on Dr.Junya
### Example Usage :
### module load Nextflow/20.10.0
#### >nextflow run -profile gb main.nf --pod5folderlist resources/listdir.txt --mode pod5 --method nano16SJunya --indexnanofile resources/minibar_index_list_16S.txt --qscore 15 --dbtaxonomy ncbi_16S_18S
#### where : database taxonomy contains k2_standard_16gb (default), 16S_RDP, 16S_SILVA138, 16S_Greengenes2, ncbi_16S_18S

#### If you use jupyter from NBT server : please use below command :
#### >nextflow run -profile gb main.nf --pod5folderlist resources/listdir.txt --mode pod5 --method nano16SJunya --model resources/dorado_model/dna_r9.4.1_e8_hac@v3.3 --indexnanofile resources/minibar_index_list_16S.txt --qscore 15 --dbtaxonomy ncbi_16S_18S
