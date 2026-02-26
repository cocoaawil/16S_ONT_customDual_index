<h2 align="left">Workflow for Full-Length 16S rRNA Gene Analysis to Identify Bloodstream Pathogens Using Nanopore Sequencing (Up to 144 Samples per Run)</h2>

###

<p align="left">We developed a novel bioinformatics pipeline designed to support the wet-lab protocol using a dual-indexing primer strategy (12 forward × 12 reverse primers). This approach enables simultaneous analysis of up to 144 samples per sequencing run.</p>

###

<h3 align="left">How to run 16Snanopore for Custom Dual-index based on Dr.Junya</h3>

###

<p align="left">✨Example Usage :<br>>module load Nextflow/20.10.0<br>>nextflow run -profile gb main.nf --pod5folderlist resources/listdir.txt --mode pod5 --method nano16SJunya --indexnanofile resources/minibar_index_list_16S.txt --qscore 15 --dbtaxonomy ncbi_16S_18S.<br> #### <b>where : taxonomy database (--dbtaxonomy) contains k2_standard_16gb (default), 16S_RDP, 16S_SILVA138, 16S_Greengenes2, ncbi_16S_18S</b></p>

###

<h3 align="left">If you use jupyter from NBT server : please use the example below command :</h3>

###
<p align="left"> >nextflow run -profile gb main.nf --pod5folderlist resources/listdir.txt --mode pod5 --method nano16SJunya --model resources/dorado_model/dna_r9.4.1_e8_hac@v3.3 --indexnanofile resources/minibar_index_list_16S.txt --qscore 15 --dbtaxonomy ncbi_16S_18S</p>
