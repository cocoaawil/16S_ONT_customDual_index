include './nbt/utils'

process run_roary{

    //conda '/tarafs/biobank/data/modules/.local/easybuild/software/Miniconda3/4.4.10/envs/roary_env'
    
    errorStrategy 'ignore'
    
    publishDir "${outputPrefixPath(params, task)}"
    publishDir "${s3OutputPrefixPath(params, task)}"

    tag { sampleId }
    
    input:
    tuple sampleId, file(anotation_gff)


    output:
    tuple sampleId, file("*.fa")
    tuple sampleId, file("*.aln")
    tuple path("gene_presence_absence*"), path("gene_presence_absence*"), path("core_a*"), path("accessory*"), path("*.txt")
    

    script:
    """
    # mkdir GFF

    # ls -alh *gff > list.txt
    
    # cp `awk -F '-> ' '{print \$2}' list.txt` ./GFF/
    # awk -F '-> ' '{print \$2}' list.txt > target.txt

    # cp `cat target.txt` ./GFF/

    roary -f . -e --mafft -n -v -p ${task.cpus} *.gff > roary_stdout.txt
    # roary -f . -e --mafft -n -v -p ${task.cpus} ${anotation_gff} > roary_stdout.txt

    # roary -v > roary.version.txt
    """

}

/*
Usage:   roary [options] *.gff

Options: -p INT    number of threads [1]
         -o STR    clusters output filename [clustered_proteins]
         -f STR    output directory [.]
         -e        create a multiFASTA alignment of core genes using PRANK
         -n        fast core gene alignment with MAFFT, use with -e
         -i        minimum percentage identity for blastp [95]
         -cd FLOAT percentage of isolates a gene must be in to be core [99]
         -qc       generate QC report with Kraken
         -k STR    path to Kraken database for QC, use with -qc
         -a        check dependancies and print versions
         -b STR    blastp executable [blastp]
         -c STR    mcl executable [mcl]
         -d STR    mcxdeblast executable [mcxdeblast]
         -g INT    maximum number of clusters [50000]
         -m STR    makeblastdb executable [makeblastdb]
         -r        create R plots, requires R and ggplot2
         -s        dont split paralogs
         -t INT    translation table [11]
         -ap       allow paralogs in core alignment
         -z        dont delete intermediate files
         -v        verbose output to STDOUT
         -w        print version and exit
         -y        add gene inference information to spreadsheet, doesnt work with -e
         -iv STR   Change the MCL inflation value [1.5]
         -h        this help message

Example: Quickly generate a core gene alignment using 8 threads
         roary -e --mafft -p 8 *.gff
*/
